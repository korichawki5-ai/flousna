// ═══════════════════════════════════════════════════════════════
//  migration_test.dart — صفر فقدان بيانات عند تحديث التطبيق
//
//  ❓ لماذا هذا الاختبار موجود؟
//     من ثبّت النسخة السابقة (م2.1) على جهازه عنده حركات حقيقية
//     في قاعدة SQLite. حين يُحدّث إلى م2.2 (إصدار مخطط 2) يفتح
//     drift قاعدة الإصدار 1 ويطلب ترقيتها. لو أخطأت الهجرة:
//     إما انهيار عند الفتح، أو — الأسوأ — فقدان صامت للحركات.
//
//  ✅ ما نُثبته: نبني قاعدة **بمخطط الإصدار 1 نفسه** (نفس SQL
//     الذي يولّده drift، منسوخ حرفياً من sqlite_master) مع حركة
//     فعلية، ثم نفتح FalousnaDatabase عليها ونطلب الإصدار 2:
//        1. لا استثناء ولا انهيار.
//        2. الحركة القديمة ما زالت موجودة بكل أرقامها.
//        3. جدول السقوف أُنشئ ويقبل الكتابة فوراً.
//        4. إصدار القاعدة صار 2 (الهجرة تُسجَّل، فلا تتكرر عبثاً).
// ═══════════════════════════════════════════════════════════════
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:falousna/core/utils/clock_guard.dart';
import 'package:falousna/core/utils/money.dart';
import 'package:falousna/data/db/budget_repository.dart';
import 'package:falousna/data/db/database.dart';
import 'package:falousna/data/db/transaction_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// مخطط الإصدار 1 حرفياً كما ولّده drift (م2.1: بلا جدول السقوف)
const String _ddlProfiles = 'CREATE TABLE "profiles" ("id" TEXT NOT NULL, '
    '"name" TEXT NOT NULL DEFAULT \'\', "role" TEXT NOT NULL DEFAULT \'owner\', '
    '"color_index" INTEGER NOT NULL DEFAULT 0, "created_at_ms" INTEGER NOT NULL, '
    '"archived" INTEGER NOT NULL DEFAULT 0 CHECK ("archived" IN (0, 1)), '
    'PRIMARY KEY ("id"))';

const String _ddlCustomCategories = 'CREATE TABLE "custom_categories" ('
    '"id" TEXT NOT NULL, "kind" TEXT NOT NULL, "name_ar" TEXT NOT NULL, '
    '"name_fr" TEXT NOT NULL, "icon" TEXT NOT NULL, "seasonal" INTEGER NOT NULL '
    'DEFAULT 0 CHECK ("seasonal" IN (0, 1)), "created_at_ms" INTEGER NOT NULL, '
    '"archived" INTEGER NOT NULL DEFAULT 0 CHECK ("archived" IN (0, 1)), '
    'PRIMARY KEY ("id"))';

const String _ddlTransactions = 'CREATE TABLE "transactions" ("id" TEXT NOT NULL, '
    '"profile_id" TEXT NOT NULL REFERENCES profiles (id), "kind" TEXT NOT NULL, '
    '"amount_centimes" INTEGER NOT NULL DEFAULT 0, "currency" TEXT NOT NULL '
    'DEFAULT \'DZD\', "category_id" TEXT NOT NULL, "note" TEXT NOT NULL DEFAULT \'\', '
    '"occurred_on" INTEGER NOT NULL, "created_at_ms" INTEGER NOT NULL, '
    '"updated_at_ms" INTEGER NOT NULL, "deleted_at_ms" INTEGER NULL, '
    'PRIMARY KEY ("id"))';

/// الجداول الثلاثة لإصدار 1 بالترتيب (profiles أولاً: المفاتيح الأجنبية)
const List<String> _v1Schema = <String>[
  _ddlProfiles,
  _ddlCustomCategories,
  _ddlTransactions,
];

void main() {
  late Directory tmp;
  late File dbFile;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    tmp = await Directory.systemTemp.createTemp('falousna_migration_');
    dbFile = File('${tmp.path}/falousna.sqlite');
  });

  tearDown(() async {
    // existsSync عمداً: نداء متزامن بلا كلفة جدولة على ملف مؤقّت
    if (tmp.existsSync()) {
      await tmp.delete(recursive: true);
    }
  });

  /// يبني قاعدة إصدار 1 بالحرف + حركة حقيقية واحدة.
  ///
  /// ⚠️ تفصيل حاسم: drift يخزّن `DateTime` كـ **ثوانٍ** منذ الحقبة
  /// (عدد صحيح)، لا ميلي ثانية. لذلك نكتب `occurred_on` بالثواني —
  /// تماماً كما كتبته نسخة م2.1 الحقيقية على جهاز المستخدم.
  /// (أعمدة `*_ms` تبقى ميلي ثانية لأنها IntColumn عادية.)
  Future<int> seedV1(int occurredOnMs) async {
    final QueryExecutor executor = NativeDatabase(dbFile);
    int result = 0;
    await executor.ensureOpen(_NoOpUser());
    for (final String ddl in _v1Schema) {
      await executor.runCustom(ddl, const <Object?>[]);
    }
    await executor.runCustom(
      'INSERT INTO profiles (id, name, role, color_index, created_at_ms, archived) '
      'VALUES (?, ?, ?, ?, ?, ?)',
      <Object?>['profile-default', 'أنا', 'owner', 0, occurredOnMs, 0],
    );
    await executor.runCustom(
      'INSERT INTO transactions (id, profile_id, kind, amount_centimes, currency, '
      'category_id, note, occurred_on, created_at_ms, updated_at_ms) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      <Object?>[
        'old-tx-1',
        'profile-default',
        'expense',
        123450,
        'DZD',
        'food',
        'حركة من النسخة القديمة',
        occurredOnMs ~/ 1000,
        occurredOnMs,
        occurredOnMs,
      ],
    );
    // إصدار المخطط: 1 — كما لو أن التطبيق القديم أنشأها
    await executor.runCustom('PRAGMA user_version = 1', const <Object?>[]);
    result = 1;
    await executor.close();
    return result;
  }

  test('⭐ قاعدة إصدار 1 بحركات حقيقية ← ترقية إلى 2 بلا فقدان ولا انهيار',
      () async {
    final ClockGuard clock = await ClockGuard.create();
    final int nowMs = clock.trustedNow().millisecondsSinceEpoch;

    await seedV1(nowMs);

    // ── نفتح التطبيق الجديد على نفس الملف (يفتح إصدار 2) ──
    final FalousnaDatabase db = FalousnaDatabase(NativeDatabase(dbFile));
    addTearDown(db.close);

    // 1. الاستعلام يعمل: الهجرة نجحت ولم تنهَر الفتحة
    final List<Transaction> rows = await db.select(db.transactions).get();
    expect(rows.length, 1, reason: 'فُقدت الحركة القديمة في الهجرة!');
    expect(rows.single.id, 'old-tx-1');
    expect(rows.single.amountCentimes, 123450);
    expect(rows.single.note, 'حركة من النسخة القديمة');
    expect(rows.single.categoryId, 'food');

    // 2. الإصدار صار 2 فعلاً (لا مجرد «فتح بلا خطأ»)
    final List<QueryRow> version = await db
        .customSelect('PRAGMA user_version')
        .get();
    expect(version.single.data.values.first, 2);

    // 3. جدول السقوف موجود ويقبل القراءة والكتابة مع الحركة القديمة
    final TransactionRepository txs = TransactionRepository(db, clock);
    final BudgetRepository budgets = BudgetRepository(db, clock);
    expect((await budgets.setLimit(amount: Money.fromWhole(5000), categoryId: 'food')).isSuccess,
        isTrue);
    // ⚠️ درس من هذا الاختبار: في Dart 3.13 صار `DateTime(123)` مُنشئ
    //    **سنة** لا ميلي ثانية (`DateTime(2026)` = سنة 2026). التحويل
    //    الصحيح من طابع زمني هو `DateTime.fromMillisecondsSinceEpoch`.
    final DateTime now = DateTime.fromMillisecondsSinceEpoch(nowMs);
    final List<BudgetProgress> progress = (await budgets.progress(
      startMs: now.subtract(const Duration(days: 400)).millisecondsSinceEpoch,
      endMs: now.add(const Duration(days: 400)).millisecondsSinceEpoch,
    ))
        .requireValue;
    expect(progress.single.spent.centimes, 123450,
        reason: 'السقف الجديد لا يرى الحركة القديمة');
    expect((await txs.recent(limit: 5)).requireValue.single.id, 'old-tx-1');
  });

  test('⭐ إعادة الفتح مرتين لا تُعيد الهجرة ولا تُفسد شيئاً', () async {
    final ClockGuard clock = await ClockGuard.create();
    await seedV1(clock.trustedNow().millisecondsSinceEpoch);

    final FalousnaDatabase first = FalousnaDatabase(NativeDatabase(dbFile));
    await first.select(first.transactions).get();
    await first.close();

    final FalousnaDatabase second = FalousnaDatabase(NativeDatabase(dbFile));
    addTearDown(second.close);
    final List<Transaction> rows = await second.select(second.transactions).get();
    expect(rows.length, 1);
    final List<QueryRow> version =
        await second.customSelect('PRAGMA user_version').get();
    expect(version.single.data.values.first, 2);
  });
}

/// مستعمل وهمي للفترة المباشرة قبل drift — يكفي للتهيئة
class _NoOpUser implements QueryExecutorUser {
  @override
  int get schemaVersion => 0;

  @override
  Future<void> beforeOpen(
    QueryExecutor executor,
    OpeningDetails details,
  ) async {}
}
