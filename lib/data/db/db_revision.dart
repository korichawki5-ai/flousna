// ═══════════════════════════════════════════════════════════════
//  db_revision.dart — نبض قاعدة البيانات: كل كتابة تُحدّث كل الشاشات
//
//  ❓ المشكلة: مزوّدات القراءة (transactionsProvider · recentProvider ·
//     periodSummaryProvider · categoriesProvider) تحتفظ بنتيجتها، فلو
//     أضاف المستخدم حركة جديدة تبقى الرئيسية تعرض الرصيد القديم حتى
//     يُغلق التطبيق ويُفتح — وهو أسوأ عطل ممكن في تطبيق مالي.
//
//  ✅ الحل: عدّاد واحد يرتفع تلقائياً عند **أي** كتابة في قاعدة البيانات،
//     والمزوّدات تراقبه فتُعيد القراءة فوراً. الميزة الحاسمة: لا يعتمد
//     على أن يتذكّر كل مُستدعٍ أن يُبطل المزوّد — يستحيل نسيانه، ويعمل
//     مع أي مسار كتابة مستقبلي (استيراد نسخة، مزامنة، صيانة...).
//
//  🔎 المصدر: drift يبثّ تحديثات الجداول عبر db.tableUpdates(...)،
//     وهي تُطلق بعد INSERT/UPDATE/DELETE فعلياً في محرّك SQLite.
//
//  ⏱️ الرفع مؤجَّل بميكرو-مهمة: لا نُشعل قراءة جديدة داخل نداء البث
//     نفسه، فذلك يخلط الكتابة بالقراءة في نفس الدورة (عطل رصده اختبار
//     التدفّق). النتيجة للمستخدم: نفس التحديث الفوري، بلا تعارض.
// ═══════════════════════════════════════════════════════════════
import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database.dart';

/// عدّاد إصدار البيانات — يبدأ من 0 ويرتفع 1 عند كل كتابة.
final class DbRevision extends Notifier<int> {
  bool _disposed = false;

  @override
  int build() {
    final FalousnaDatabase db = ref.watch(falousnaDatabaseProvider);
    _disposed = false;

    StreamSubscription<Set<TableUpdate>>? subscription;

    ref.onDispose(() {
      _disposed = true;
      unawaited(subscription?.cancel());
    });

    // ⚠️ الاشتراك **بعد** انتهاء فتح القاعدة، لا أثناءه.
    //
    //    عند أول تشغيل، drift يبني الجداول ويدخل الملف الشخصي الافتراضي
    //    (كتابة!) في الفتحة الأولى. الاشتراك في بث التحديثات في تلك
    //    اللحظة يوقعنا في «Bad state: Cannot add event while adding
    //    stream» — عطل متقطّع رصده اختبار التدفّق عند تشغيله كأول ملف
    //    في عملية جديدة. الانتظار دورة كاملة يُنهي هذا التزاحم.
    //
    //    لا نخسر شيئاً: قراءات الشاشات الأولى تحدث بعد الفتح أصلاً،
    //    والعدّاد يهمّنا من الكتابة الثانية فصاعداً.
    unawaited(
      Future<void>.delayed(Duration.zero, () {
        if (_disposed) {
          return;
        }
        subscription = db
            .tableUpdates(TableUpdateQuery.any())
            .listen(_onWrite, onError: _onStreamError);
      }),
    );

    return 0;
  }

  /// أي كتابة (INSERT/UPDATE/DELETE) على أي جدول ترفع العدّاد.
  ///
  /// ⏱️ التأجيل بميكرو-مهمة عمداً: لا نُشعل إعادة القراءة داخل نداء البث
  ///    نفسه، فتُفصل الكتابة عن القراءة تماماً.
  void _onWrite(Set<TableUpdate> _) {
    scheduleMicrotask(() {
      if (_disposed) {
        return;
      }
      state = state + 1;
    });
  }

  /// خطأ في بث التحديثات لا يجوز أن يُسقط التطبيق.
  ///
  /// عدّاد فاته تحديث = شاشة قد تُظهر رقماً قديماً حتى الكتابة التالية؛
  /// أما استثناء غير مُلتقط فيُسقط الوجهة كلها — فالأول أهون، وبينهما
  /// فرق «إزعاج» و«انهيار». مهمة العدّاد هنا: ألا يحوّل عطلاً صغيراً
  /// إلى انهيار.
  void _onStreamError(Object error, StackTrace stack) {
    // مقصود وصريح: تجاهل بصمت مقروء (لا `catch` فارغ غامض)
    debugPrint('تحديث تلقائي: تعذّر رفع العدّاد — $error');
  }
}

/// راقب هذا المزوّد في كل مزوّد قراءة، فتُعاد القراءة بعد كل كتابة.
final NotifierProvider<DbRevision, int> dbRevisionProvider =
    NotifierProvider<DbRevision, int>(DbRevision.new);
