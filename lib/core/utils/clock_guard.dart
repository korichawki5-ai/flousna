import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/constants.dart';

/// ═══════════════════════════════════════════════════════════════
///  ClockGuard — منع التلاعب بساعة الجهاز
///
///  🔴 المشكلة: في تطبيق Offline-first، تجربة 7 أيام مجانية تعتمد
///     على ساعة الجهاز. مستخدم يغيّر الساعة للوراء → تجربة أبدية.
///
///  ✅ الحل: نخزّن **أعلى طابع زمني شوهد ever**. الوقت لا يرجع
///     أبداً في الواقع. إن رجع → تلاعب مكشوف.
///
///  ⚠️ حدّ معروف بصدق:
///     - هذا **يكشف** التلاعب ولا يمنعه فيزيائياً (مستحيل تقنياً
///       في تطبيق محلي بدون سيرفر).
///     - الحل الجذري = تسجيل حساب (يُثبَّت التاريخ في Supabase).
///     - لذلك: من يتلاعب يُوجَّه بلطف نحو إنشاء حساب، لا يُعاقَب.
///     - منطقة زمنية مختلفة قد تُنتج فرقاً صغيراً → نتسامح حتى 6 ساعات.
/// ═══════════════════════════════════════════════════════════════
class ClockGuard {
  ClockGuard(this._prefs);

  final SharedPreferences _prefs;

  /// تسامح مع فرق المناطق الزمنية (6 ساعات)
  static const Duration _timezoneTolerance = Duration(hours: 6);

  /// ينشئ الحارس ويقرأ الحالة المحفوظة
  ///
  /// ⚠️ فشل تسجيل النبضة الأولى لا يوقف الإقلاع: `trustedNow()`
  ///    يرجع وقت الجهاز ببساطة، وتُستأنف الحماية في النبضة التالية.
  static Future<ClockGuard> create() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final ClockGuard guard = ClockGuard(prefs);
    try {
      await guard._recordTick();
    } on Exception catch (error) {
      debugPrint('⚠️ تعذّر تسجيل النبضة الزمنية الأولى: $error');
    }
    return guard;
  }

  /// أعلى طابع زمني شوهد (millisSinceEpoch)
  int get highestSeenMs => _prefs.getInt(AppConstants.keyHighestSeenTs) ?? 0;

  /// هل كُشف تلاعب بالساعة؟
  bool get isTampered => _prefs.getBool(AppConstants.keyClockTamperFlag) ?? false;

  /// الوقت الحالي «الموثوق»:
  /// - إن لم يُكشف تلاعب → `DateTime.now()`
  /// - إن كُشف تلاعب → أعلى طابع شوهد (لا نرجع للوراء أبداً)
  ///
  /// ⚠️ استعمل هذه الدالة **بدل `DateTime.now()` في كل منطق
  ///    يتعلق بالتجربة والاشتراك والفترات**. هذا هو مفتاح الحماية.
  DateTime trustedNow() {
    final DateTime real = DateTime.now();
    final DateTime highest = DateTime.fromMillisecondsSinceEpoch(highestSeenMs);
    if (isTampered && highest.isAfter(real)) return highest;
    return real;
  }

  /// يسجّل نبضة زمنية — تُستدعى عند كل تشغيل وعند كل عملية حساسة
  ///
  /// يُعيد `true` إن كُشف تلاعب جديد في هذه النبضة.
  Future<bool> tick() async => _recordTick();

  Future<bool> _recordTick() async {
    final DateTime real = DateTime.now();
    final int realMs = real.millisecondsSinceEpoch;
    final int stored = highestSeenMs;

    // أول تشغيل — نسجّل ونخرج
    if (stored == 0) {
      await _prefs.setInt(AppConstants.keyHighestSeenTs, realMs);
      return false;
    }

    // الوقت رجع للوراء بأكثر من سماح المناطق الزمنية → تلاعب
    final Duration regression = Duration(milliseconds: stored - realMs);
    if (regression > _timezoneTolerance) {
      if (!isTampered) {
        await _prefs.setBool(AppConstants.keyClockTamperFlag, true);
      }
      // لا نُنقص highestSeen أبداً
      return true;
    }

    // الوقت تقدّم بشكل طبيعي → نرفع السقف
    if (realMs > stored) {
      await _prefs.setInt(AppConstants.keyHighestSeenTs, realMs);
    }
    return false;
  }

  /// كم يوماً مرّت منذ لحظة معيّنة — بالوقت الموثوق
  ///
  /// يُعيد صفراً إن كانت [since] في المستقبل (لم يبدأ بعد)
  int daysSince(DateTime since) {
    final DateTime now = trustedNow();
    if (!now.isAfter(since)) return 0;
    return now.difference(since).inDays;
  }

  /// هل انتهت المهلة؟
  bool hasExpired(DateTime deadline) => trustedNow().isAfter(deadline);

  /// الأيام المتبقية حتى مهلة (0 إن انتهت)
  int daysUntil(DateTime deadline) {
    final DateTime now = trustedNow();
    if (!deadline.isAfter(now)) return 0;
    // نُقرّب للأعلى: بقي 0.5 يوم = «يوم واحد» (أصدق للمستخدم)
    final int hours = deadline.difference(now).inHours;
    if (hours <= 0) return 0;
    return (hours / 24).ceil();
  }

  /// يمسح علم التلاعب — ⚠️ يُستعمل فقط من Edge Function بعد
  /// التحقق من السيرفر (المرحلة 3)، لا من الواجهة.
  @visibleForTesting
  Future<void> clearTamperFlagForTesting() async {
    await _prefs.setBool(AppConstants.keyClockTamperFlag, false);
    await _prefs.setInt(AppConstants.keyHighestSeenTs, 0);
  }
}

/// ═══════════════════════════════════════════════════════════════
///  مزوّد حارس الساعة
///
///  🔴 يُتجاوَز في main.dart بعد التهيئة (overrideWithValue).
///     إن استُعمل بلا تجاوز يرمي خطأً واضحاً بدل أن يعيد وقتاً
///     خاطئاً بصمت — لأن الوقت الخاطئ الصامت يُفسد التجربة
///     المجانية والفترات المالية دون أي أثر يمكن تتبّعه.
///
///  ✅ القاعدة: كل منطق زمني (تجربة · فترة مالية · آجال ديون)
///     يأخذ الوقت من `ref.watch(clockGuardProvider).trustedNow()`
///     لا من `DateTime.now()`.
/// ═══════════════════════════════════════════════════════════════
final clockGuardProvider = Provider<ClockGuard>(
  (Ref ref) => throw StateError(
    'clockGuardProvider يجب تجاوزه في main.dart عبر overrideWithValue',
  ),
);
