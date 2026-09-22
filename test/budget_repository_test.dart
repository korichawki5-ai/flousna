// ═══════════════════════════════════════════════════════════════
//  budget_repository_test.dart — م2.2: سقوف الصرف
//
//  ما نُثبته هنا (لا نثق بأي رقم لم يُختبَر):
//    1. السقف يُحفظ ويُقرأ، والفئة نفسها تُحدَّث لا تُكرَّر.
//    2. المعادلة: النسبة = المصروف ÷ السقف × 100 — بالحدود.
//    3. حدود الفترة **حصريّة**: حركة آخر يوم داخل، وأول يوم خارج
//       لا تدخل (نفس قاعدة الفترات في كل التطبيق).
//    4. الحركة المحذوفة ناعماً لا تُحسب، والدخل لا يُحسب.
//    5. السقف العام يجمع كل المصاريف، وسقف الفئة يحسب فئته فقط.
//    6. الحالات: آمن · قريب (عند نسبة التنبيه بالضبط) · متجاوز.
//    7. بلوغ السقف بالضبط ← حالة حرجة بلا مبلغ تجاوز («استهلكت السقف
//       كاملاً»)، وتجاوزه ← «تجاوزت بـ X». لا «تجاوزت بـ 0 دج» أبداً.
//    8. حذف السقف ناعم: يختفي من العرض، وdeletedAtMs يُكتب،
//       و**حركاته لا تُمسّ إطلاقاً**.
//    9. التحقق المزدوج: مبلغ صفري أو نسبة تنبيه خارج 50..100 مرفوضان.
// ═══════════════════════════════════════════════════════════════
import 'package:drift/native.dart';
import 'package:falousna/core/errors/app_error.dart';
import 'package:falousna/core/utils/clock_guard.dart';
import 'package:falousna/core/utils/money.dart';
import 'package:falousna/core/utils/result.dart';
import 'package:falousna/data/db/budget_repository.dart';
import 'package:falousna/data/db/database.dart';
import 'package:falousna/data/db/transaction_repository.dart';
import 'package:falousna/data/seed/seed_categories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late FalousnaDatabase db;
  late ClockGuard clock;
  late TransactionRepository txs;
  late BudgetRepository budgets;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    db = FalousnaDatabase.forTesting(NativeDatabase.memory());
    clock = await ClockGuard.create();
    txs = TransactionRepository(db, clock);
    budgets = BudgetRepository(db, clock);
  });

  tearDown(() async {
    await db.close();
  });

  /// أول الشهر الحالي — الفترة المستعملة في معظم الاختبارات
  DateTime monthStart() {
    final DateTime now = clock.trustedNow();
    return DateTime(now.year, now.month, 1);
  }

  DateTime monthEnd() {
    final DateTime now = clock.trustedNow();
    return DateTime(now.year, now.month + 1, 1);
  }

  Future<void> addExpense(String categoryId, int centimes, {DateTime? on}) async {
    final Result<Transaction, AppError> result = await txs.add(
      kind: SeedCategoryKind.expense,
      amount: Money.fromCentimes(centimes),
      categoryId: categoryId,
      occurredOn: on,
    );
    expect(result.isSuccess, isTrue, reason: '${result.errorOrNull}');
  }

  Future<void> addIncome(String categoryId, int centimes) async {
    final Result<Transaction, AppError> result = await txs.add(
      kind: SeedCategoryKind.income,
      amount: Money.fromCentimes(centimes),
      categoryId: categoryId,
    );
    expect(result.isSuccess, isTrue, reason: '${result.errorOrNull}');
  }

  Future<List<BudgetProgress>> progress() async {
    final Result<List<BudgetProgress>, AppError> result = await budgets.progress(
      startMs: monthStart().millisecondsSinceEpoch,
      endMs: monthEnd().millisecondsSinceEpoch,
    );
    return result.requireValue;
  }

  group('حفظ السقف', () {
    test('سقف فئة يُحفظ ويُقرأ كاملاً بلا فقدان صفة', () async {
      final Result<void, AppError> saved = await budgets.setLimit(
        amount: Money.fromWhole(20000),
        categoryId: 'food',
        alertPercent: 75,
      );
      expect(saved.isSuccess, isTrue, reason: '${saved.errorOrNull}');

      final List<Budget> all = (await budgets.all()).requireValue;
      expect(all.length, 1);
      expect(all.single.categoryId, 'food');
      expect(all.single.amountCentimes, 2000000);
      expect(all.single.alertPercent, 75);
      expect(all.single.deletedAtMs, isNull);
      expect(all.single.profileId, kDefaultProfileId);
    });

    test('⭐ إضافة سقف ثانٍ لنفس الفئة تُحدّث الأول ولا تُكرّره', () async {
      await budgets.setLimit(amount: Money.fromWhole(10000), categoryId: 'food');
      await budgets.setLimit(
        amount: Money.fromWhole(15000),
        categoryId: 'food',
        alertPercent: 60,
      );

      final List<Budget> all = (await budgets.all()).requireValue;
      expect(all.length, 1, reason: 'تكرّر سقفان على نفس الفئة!');
      expect(all.single.amountCentimes, 1500000);
      expect(all.single.alertPercent, 60);
    });

    test('السقف العام (بلا فئة) منفصل عن سقوف الفئات', () async {
      await budgets.setLimit(amount: Money.fromWhole(50000));
      await budgets.setLimit(amount: Money.fromWhole(10000), categoryId: 'food');

      final List<Budget> all = (await budgets.all()).requireValue;
      expect(all.length, 2);
      // العام أولاً — ثابت مهما تغيّر ترتيب الإدخال
      expect(all.first.categoryId, isNull);
    });

    test('⭐ مبلغ صفري أو سالب مرفوض (التحقق الثاني قبل الكتابة)', () async {
      final Result<void, AppError> zero =
          await budgets.setLimit(amount: Money.zero(), categoryId: 'food');
      expect(zero.isSuccess, isFalse);
      expect(zero.errorOrNull!.messageKey, 'validateAmountZero');

      final Result<void, AppError> negative = await budgets.setLimit(
        amount: Money.fromCentimes(-500),
        categoryId: 'food',
      );
      expect(negative.isSuccess, isFalse);
      expect((await budgets.all()).requireValue, isEmpty);
    });

    test('نسبة تنبيه خارج 50..100 مرفوضة', () async {
      final Result<void, AppError> low = await budgets.setLimit(
        amount: Money.fromWhole(1000),
        categoryId: 'food',
        alertPercent: 10,
      );
      expect(low.isSuccess, isFalse);
      expect(low.errorOrNull!.messageKey, 'budgetAlertRange');

      final Result<void, AppError> high = await budgets.setLimit(
        amount: Money.fromWhole(1000),
        categoryId: 'food',
        alertPercent: 150,
      );
      expect(high.isSuccess, isFalse);
    });
  });

  group('التقدّم والمعادلة', () {
    test('المصروف والنسبة والباقي تُحسب صحيحة', () async {
      await budgets.setLimit(amount: Money.fromWhole(1000), categoryId: 'food');
      await addExpense('food', 25050); // 250,50 دج

      final BudgetProgress p = (await progress()).single;
      expect(p.spent.centimes, 25050);
      expect(p.limit.centimes, 100000);
      expect(p.usedPercent, 25); // 25050 ÷ 100000 × 100 = 25,05 → 25
      expect(p.remaining.centimes, 74950);
      expect(p.overBy.centimes, 0);
      expect(p.status, BudgetStatus.safe);
      expect(p.ratio, closeTo(0.2505, 0.0001));
    });

    test('⭐ حدود الفترة حصرية: حركة اليوم الأول داخل والأخير لا يخرج', () async {
      await budgets.setLimit(amount: Money.fromWhole(1000), categoryId: 'food');
      await addExpense('food', 10000, on: monthStart()); // أول لحظة: داخل
      await addExpense('food', 999999, on: monthEnd()); // أول لحظة بعد الفترة

      final BudgetProgress p = (await progress()).single;
      expect(p.spent.centimes, 10000,
          reason: 'حركة خارج الفترة تسرّبت إلى السقف!');
    });

    test('الحركة المحذوفة ناعماً لا تُحسب، والدخل لا يُحسب', () async {
      await budgets.setLimit(amount: Money.fromWhole(1000), categoryId: 'food');
      final Result<Transaction, AppError> kept =
          await txs.add(kind: SeedCategoryKind.expense, amount: Money.fromWhole(300), categoryId: 'food');
      await txs.add(kind: SeedCategoryKind.expense, amount: Money.fromWhole(700), categoryId: 'food');
      await addIncome('salary', 500000);

      final Result<void, AppError> removed = await txs.softDelete(kept.requireValue.id);
      expect(removed.isSuccess, isTrue);

      final BudgetProgress p = (await progress()).single;
      expect(p.spent.centimes, 70000, reason: 'دخل أو حركة محذوفة حُسبت في السقف!');
    });

    test('سقف الفئة يحسب فئته فقط، والسقف العام يجمع الكل', () async {
      await budgets.setLimit(amount: Money.fromWhole(1000), categoryId: 'food');
      await budgets.setLimit(amount: Money.fromWhole(5000));
      await addExpense('food', 40000);
      await addExpense('transport', 15000);

      final List<BudgetProgress> all = await progress();
      final BudgetProgress food =
          all.firstWhere((BudgetProgress p) => p.budget.categoryId == 'food');
      final BudgetProgress overall =
          all.firstWhere((BudgetProgress p) => p.budget.categoryId == null);

      expect(food.spent.centimes, 40000);
      expect(overall.spent.centimes, 55000);
      expect(overall.usedPercent, 11); // 55000 ÷ 500000 × 100 = 11
    });

    test('فئة بلا مصاريف تُعرض بصفر لا تُخفى (المستخدم يعرف أنه لم يصرف)',
        () async {
      await budgets.setLimit(amount: Money.fromWhole(3000), categoryId: 'health');

      final BudgetProgress p = (await progress()).single;
      expect(p.spent.centimes, 0);
      expect(p.usedPercent, 0);
      expect(p.status, BudgetStatus.safe);
      expect(p.remaining.centimes, p.limit.centimes);
    });
  });

  group('الحالات الثلاث', () {
    test('⭐ عند نسبة التنبيه بالضبط (80٪) ← «قريب» لا «آمن»', () async {
      await budgets.setLimit(
        amount: Money.fromWhole(1000),
        categoryId: 'food',
        alertPercent: 80,
      );
      await addExpense('food', 80000); // 80٪ بالضبط

      final BudgetProgress p = (await progress()).single;
      expect(p.usedPercent, 80);
      expect(p.status, BudgetStatus.near);
    });

    test('⭐ بلوغ السقف بالضبط: حالة حرجة بلا مبلغ تجاوز (ليس «قريباً»)', () async {
      await budgets.setLimit(amount: Money.fromWhole(1000), categoryId: 'food');
      await addExpense('food', 100000);

      final BudgetProgress p = (await progress()).single;
      expect(p.usedPercent, 100);
      expect(p.status, BudgetStatus.over,
          reason: 'لا مساحة متبقية — يجب أن تُرى حالة حرجة لا «قريب»');
      expect(p.isExhausted, isTrue,
          reason: 'الرسالة هنا «استهلكت السقف كاملاً» لا «تجاوزت بـ 0 دج»');
      expect(p.overBy.centimes, 0);
      expect(p.remaining.centimes, 0);
    });

    test('التجاوز يُحسب كما هو والمتبقي لا يصير سالباً', () async {
      await budgets.setLimit(amount: Money.fromWhole(1000), categoryId: 'food');
      await addExpense('food', 125000);

      final BudgetProgress p = (await progress()).single;
      expect(p.status, BudgetStatus.over);
      expect(p.overBy.centimes, 25000);
      expect(p.remaining.centimes, 0);
      expect(p.isExhausted, isFalse);
      expect(p.ratio, 1.0, reason: 'الشريط لا يتجاوز حده مهما زاد الصرف');
    });

    test('الترتيب: المتجاوز أولاً ثم الأقرب للسقف (عين المستخدم على المشكلة)',
        () async {
      await budgets.setLimit(amount: Money.fromWhole(1000), categoryId: 'food');
      await budgets.setLimit(amount: Money.fromWhole(1000), categoryId: 'transport');
      await budgets.setLimit(amount: Money.fromWhole(1000), categoryId: 'health');
      await addExpense('food', 90000); // 90٪ — قريب
      await addExpense('transport', 120000); // 120٪ — متجاوز
      await addExpense('health', 10000); // 10٪ — آمن

      final List<BudgetProgress> all = await progress();
      expect(all.first.budget.categoryId, 'transport');
      expect(all.first.status, BudgetStatus.over);
      expect(all.last.budget.categoryId, 'health');

      final List<BudgetProgress> alerts = budgetAlertsOf(all);
      expect(alerts.length, 2);
      expect(alerts.first.budget.categoryId, 'transport');
      expect(alerts.last.budget.categoryId, 'food');
    });
  });

  group('الحذف الناعم', () {
    test('⭐ حذف السقف يخفي السقف ولا يمسّ أي حركة', () async {
      await budgets.setLimit(amount: Money.fromWhole(1000), categoryId: 'food');
      await addExpense('food', 30000);
      final Budget budget = (await budgets.all()).requireValue.single;

      final Result<void, AppError> removed = await budgets.remove(budget.id);
      expect(removed.isSuccess, isTrue);

      expect((await budgets.all()).requireValue, isEmpty);
      expect(await progress(), isEmpty);

      // الحركة ما زالت في القاعدة وتظهر في ملخص الفترة — لا فقدان
      final Result<PeriodSummary, AppError> summary = await txs.summary(
        monthStart().millisecondsSinceEpoch,
        monthEnd().millisecondsSinceEpoch,
      );
      expect(summary.requireValue.expenses.centimes, 30000);

      // الصف نفسه ما زال موجوداً ومعلَّماً فقط
      final List<Budget> rows = await db.select(db.budgets).get();
      expect(rows.length, 1);
      expect(rows.single.deletedAtMs, isNotNull);
    });

    test('حذف سقف محذوف مسبقاً يُعيد نتيجة واضحة لا استثناء', () async {
      await budgets.setLimit(amount: Money.fromWhole(1000), categoryId: 'food');
      final String id = (await budgets.all()).requireValue.single.id;

      expect((await budgets.remove(id)).isSuccess, isTrue);
      final Result<void, AppError> again = await budgets.remove(id);
      expect(again.isSuccess, isFalse);
      expect(again.errorOrNull!.messageKey, 'budgetNotFound');
    });

    test('بعد الحذف يمكن وضع سقف جديد لنفس الفئة', () async {
      await budgets.setLimit(amount: Money.fromWhole(1000), categoryId: 'food');
      final String id = (await budgets.all()).requireValue.single.id;
      await budgets.remove(id);
      await budgets.setLimit(amount: Money.fromWhole(2000), categoryId: 'food');

      final List<Budget> all = (await budgets.all()).requireValue;
      expect(all.length, 1);
      expect(all.single.amountCentimes, 200000);
    });
  });

  group('حدود الاستعمال', () {
    test('بلا سقوف: التقدّم قائمة فارغة بلا أي خطأ', () async {
      expect(await progress(), isEmpty);
      expect(budgetAlertsOf(const <BudgetProgress>[]), isEmpty);
    });

    test('فترة مقلوبة (نهاية قبل بداية) مرفوضة بلا كتابة', () async {
      final Result<List<BudgetProgress>, AppError> bad = await budgets.progress(
        startMs: monthEnd().millisecondsSinceEpoch,
        endMs: monthStart().millisecondsSinceEpoch,
      );
      expect(bad.isSuccess, isFalse);
    });

    test('⭐ كل السقوف آمنة ← صفر تنبيهات (الشاشة تبقى هادئة)', () async {
      await budgets.setLimit(amount: Money.fromWhole(1000), categoryId: 'food');
      await addExpense('food', 10000); // 10٪

      final List<BudgetProgress> all = await progress();
      expect(all.single.status, BudgetStatus.safe);
      expect(budgetAlertsOf(all), isEmpty);
    });
  });
}
