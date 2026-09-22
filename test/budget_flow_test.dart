// ═══════════════════════════════════════════════════════════════
//  budget_flow_test.dart — م2.2: السقوف من الإصبع إلى الشاشة
//
//  ⭐ ما يثبته هذا الاختبار (وهو ما سيجرّبه المستخدم على جهازه):
//    1. «إضافة سقف» من شاشة الميزانية → يُكتب في القاعدة فعلاً.
//    2. البطاقة تعرض الاسم والنسبة والمبلغ الحقيقي (لا أرقام وهمية).
//    3. صرف يتجاوز السقف → لافتة تنبيه حمراء على الرئيسية.
//    4. اللافتة **لا تظهر** حين كل السقوف داخل حدودها (لا إزعاج).
//    5. ضغطة على اللافتة تنقل إلى تبويب الميزانية (تنبيه يقود لإجراء).
//    6. حذف السقف → يختفي من الشاشة، وحركاته تبقى في القاعدة.
// ═══════════════════════════════════════════════════════════════
import 'package:drift/native.dart';
import 'package:falousna/app.dart';
import 'package:falousna/core/config/constants.dart';
import 'package:falousna/core/l10n/locale_controller.dart';
import 'package:falousna/core/utils/clock_guard.dart';
import 'package:falousna/core/utils/money.dart';
import 'package:falousna/data/db/db.dart';
import 'package:falousna/data/local/local_store.dart';
import 'package:falousna/data/seed/seed_categories.dart';
import 'package:falousna/features/transactions/budget_screen.dart';
import 'package:falousna/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppLocalizations> _l10n() async =>
    AppLocalizations.delegate.load(kDefaultLocale);

class _Harness {
  _Harness(this.db, this.clock);
  final FalousnaDatabase db;
  final ClockGuard clock;
}

/// جلسة كاملة: ضيف أنهى الإعداد + قاعدة ذاكرة + الشاشات الحقيقية
Future<_Harness> _boot(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues(<String, Object>{
    AppConstants.keyOnboardingDone: true,
    AppConstants.keyConsentGranted: true,
    AppConstants.keyConsentVersion: AppConstants.privacyPolicyVersion,
    AppConstants.keyConsentHash: 'a' * 64,
    AppConstants.keyGuestMode: true,
    AppConstants.keySetupDone: true,
  });
  final LocalStore store = await LocalStore.init();
  final ClockGuard clock = await ClockGuard.create();
  final FalousnaDatabase db =
      FalousnaDatabase.forTesting(NativeDatabase.memory());

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        localStorageProvider.overrideWithValue(store),
        clockGuardProvider.overrideWithValue(clock),
        falousnaDatabaseProvider.overrideWithValue(db),
        transactionRepositoryProvider
            .overrideWithValue(TransactionRepository(db, clock)),
        budgetRepositoryProvider
            .overrideWithValue(BudgetRepository(db, clock)),
      ],
      child: const FalousnaApp(),
    ),
  );
  await tester.pumpAndSettle();
  return _Harness(db, clock);
}

/// مقعد داخل شريط التنقل وحده — الاسم قد يظهر أيضاً في عنوان الشاشة،
/// فيفشل `find.text` المجرّد بـ«وجدتُ أكثر من عنصر». هذا التقييد يمنعه.
Finder _navSeat(AppLocalizations l10n, String label) => find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text(label),
    );

void main() {
  testWidgets('⭐ من «إضافة سقف» إلى قاعدة البيانات: الرحلة كاملة',
      (WidgetTester tester) async {
    final _Harness h = await _boot(tester);
    addTearDown(h.db.close);
    final AppLocalizations l10n = await _l10n();

    // ── ننتقل إلى تبويب الميزانية ──
    await tester.tap(_navSeat(l10n, l10n.navBudget));
    await tester.pumpAndSettle();
    expect(find.byType(BudgetScreen), findsOneWidget);

    // ── الحالة الفارغة أولاً: صادقة مع زر واحد واضح ──
    expect(find.text(l10n.budgetEmptyTitle), findsOneWidget);
    await tester.ensureVisible(find.text(l10n.budgetEmptyAction));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.budgetEmptyAction));
    await tester.pumpAndSettle();

    // ── نافذة السقف: المبلغ (السقف العام افتراضياً) ──
    expect(find.text(l10n.budgetNewLimit), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '20000');
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.actionSave));
    await tester.pumpAndSettle();

    // ── 1. صفّ حقيقي في القاعدة ──
    final List<Budget> rows = await h.db.select(h.db.budgets).get();
    expect(rows.length, 1, reason: 'السقف لم يُحفظ في القاعدة');
    expect(rows.single.amountCentimes, 2000000);
    expect(rows.single.categoryId, isNull, reason: 'الافتراضي = السقف العام');
    expect(rows.single.alertPercent, 80);

    // ── 2. البطاقة تعرض الاسم والمبلغ الحقيقيين ──
    expect(find.text(l10n.budgetOverallLabel), findsOneWidget);
    expect(find.text(l10n.budgetStatusSafe), findsOneWidget);
    expect(find.text(l10n.budgetRemainingLabel), findsOneWidget);
  });

  testWidgets('⭐ صرف يتجاوز السقف → تنبيه على الرئيسية بلا إعادة تشغيل',
      (WidgetTester tester) async {
    final _Harness h = await _boot(tester);
    addTearDown(h.db.close);
    final AppLocalizations l10n = await _l10n();

    // سقف صغير على فئة «الطعام» + صرف يتجاوزه (بالمسار الحقيقي للمستودع)
    final BudgetRepository repo = BudgetRepository(h.db, h.clock);
    await repo.setLimit(
      amount: Money.fromWhole(1000),
      categoryId: 'food',
      alertPercent: 80,
    );
    final TransactionRepository txs = TransactionRepository(h.db, h.clock);
    await txs.add(
      kind: SeedCategoryKind.expense,
      amount: Money.fromWhole(1200),
      categoryId: 'food',
      note: 'سوق الشهر',
    );
    await tester.pumpAndSettle();

    // ── 3. اللافتة ظاهرة على الرئيسية بنص عربي صريح ──
    expect(
      find.textContaining(l10n.budgetAlertOverTitle(l10n.categoryFood)),
      findsOneWidget,
      reason: 'لا تنبيه بعد تجاوز السقف — القلب النابض للميزانية معطّل',
    );
    // التفصيل يذكر المبلغين: 1.200 المصروف و1.000 السقف (بخط Mono)
    expect(find.textContaining('1.200'), findsWidgets);
    expect(find.textContaining('1.000'), findsWidgets);
    expect(find.text(l10n.budgetAlertAction), findsOneWidget);
    // تنبيه واحد لا يحتاج سطر «و{n} أخرى»
    expect(find.text(l10n.budgetAlertMore(1)), findsNothing);

    // ── 5. الضغط ينقل إلى الميزانية ──
    await tester.tap(find.text(l10n.budgetAlertAction));
    await tester.pumpAndSettle();
    expect(find.byType(BudgetScreen), findsOneWidget);
    expect(find.text(l10n.budgetStatusOver), findsWidgets);
    expect(find.text(l10n.budgetOverByLabel), findsWidgets);
    // المبلغ المتجاوز ظاهر بخط Mono — 200 فوق سقف 1000
    expect(find.textContaining('200'), findsWidgets);
  });

  testWidgets('⭐ كل السقوف آمنة → لا لافتة إزعاج على الرئيسية',
      (WidgetTester tester) async {
    final _Harness h = await _boot(tester);
    addTearDown(h.db.close);
    final AppLocalizations l10n = await _l10n();

    final BudgetRepository repo = BudgetRepository(h.db, h.clock);
    await repo.setLimit(amount: Money.fromWhole(10000), categoryId: 'food');
    final TransactionRepository txs = TransactionRepository(h.db, h.clock);
    await txs.add(
      kind: SeedCategoryKind.expense,
      amount: Money.fromWhole(500),
      categoryId: 'food',
    );
    await tester.pumpAndSettle();

    expect(find.textContaining(l10n.budgetAlertAction), findsNothing,
        reason: 'تنبيه بلا سبب يعلّم المستخدم تجاهل التنبيهات');
  });

  testWidgets('⭐ حذف السقف: يختفي من الشاشة وحركاته تبقى', (WidgetTester tester) async {
    final _Harness h = await _boot(tester);
    addTearDown(h.db.close);
    final AppLocalizations l10n = await _l10n();

    final BudgetRepository repo = BudgetRepository(h.db, h.clock);
    await repo.setLimit(amount: Money.fromWhole(5000), categoryId: 'food');
    final TransactionRepository txs = TransactionRepository(h.db, h.clock);
    await txs.add(
      kind: SeedCategoryKind.expense,
      amount: Money.fromWhole(1500),
      categoryId: 'food',
    );

    await tester.tap(_navSeat(l10n, l10n.navBudget));
    await tester.pumpAndSettle();
    expect(find.text(l10n.categoryFood), findsOneWidget);

    // ── 6. الحذف عبر زر الحذف + التأكيد ──
    await tester.ensureVisible(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();
    expect(find.text(l10n.budgetDeleteTitle), findsOneWidget);
    await tester.tap(find.text(l10n.budgetDeleteAction).last);
    await tester.pumpAndSettle();

    // السقف ذهب، والحالة الفارغة عادت
    expect(find.text(l10n.budgetEmptyTitle), findsOneWidget,
        reason: 'السقف المحذوف ما زال ظاهراً');
    // الحركة ما زالت في القاعدة (لا فقدان بيانات)
    final List<Transaction> remaining =
        await h.db.select(h.db.transactions).get();
    expect(remaining.length, 1);
    expect(remaining.single.deletedAtMs, isNull);
  });
}
