// ═══════════════════════════════════════════════════════════════
//  shell_navigation_test.dart — حارس شريط التنقل السفلي
//
//  🐞 عطل حقيقي (اكتُشف 22/09/2026 بواسطة اختبار السقوف):
//     مقعد زر الإضافة العائم مقعدٌ فاضٍ بلا فرع، لكن الشريط كان
//     يمرّر **رقم المقعد** إلى goBranch مباشرة. النتيجة:
//       «الميزانية» ← يفتح «المزيد»   ·   «المزيد» ← لا يفتح شيئاً
//     أي أن المستخدم يظن أن الميزانية عطلانة، وهي سليمة تماماً.
//
//  ⭐ هذا الاختبار يقيس ما يراه المستخدم فعلاً: أي شاشة تظهر عند
//     الضغط على كل مقعد — لا يقرأ الكود ولا يثق بالتعليقات.
// ═══════════════════════════════════════════════════════════════
import 'package:drift/native.dart';
import 'package:falousna/app.dart';
import 'package:falousna/core/config/constants.dart';
import 'package:falousna/core/l10n/locale_controller.dart';
import 'package:falousna/core/utils/clock_guard.dart';
import 'package:falousna/data/db/db.dart';
import 'package:falousna/data/local/local_store.dart';
import 'package:falousna/features/home/home_screen.dart';
import 'package:falousna/features/more/more_screen.dart';
import 'package:falousna/features/transactions/budget_screen.dart';
import 'package:falousna/features/transactions/transactions_screen.dart';
import 'package:falousna/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppLocalizations> _l10n() async =>
    AppLocalizations.delegate.load(kDefaultLocale);

Future<FalousnaDatabase> _boot(WidgetTester tester) async {
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
  return db;
}

/// مقعد داخل شريط التنقل وحده — الاسم قد يظهر أيضاً في عنوان الشاشة،
/// فيفشل `find.text` المجرّد بـ«وجدتُ أكثر من عنصر». هذا التقييد يمنعه.
Finder _navSeat(AppLocalizations l10n, String label) => find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text(label),
    );

void main() {
  testWidgets('⭐ كل مقعد في الشريط يفتح شاشته الصحيحة (لا إزاحة)', (
    WidgetTester tester,
  ) async {
    final FalousnaDatabase db = await _boot(tester);
    addTearDown(db.close);
    final AppLocalizations l10n = await _l10n();

    // نبدأ من الرئيسية
    expect(find.byType(HomeScreen), findsOneWidget);

    // ── «الحركات» → شاشة الحركات ──
    await tester.tap(_navSeat(l10n, l10n.navTransactions));
    await tester.pumpAndSettle();
    expect(find.byType(TransactionsScreen), findsOneWidget,
        reason: 'مقعد الحركات لا يفتح شاشة الحركات');
    // 🐞 كان هنا انهيار تخطيط (Expanded داخل تمرير بلا حدّ ارتفاع)
    expect(tester.takeException(), isNull,
        reason: 'شاشة الحركات تنهار تخطيطياً عند فتحها');

    // ── «الميزانية» → شاشة الميزانية (كان يفتح «المزيد») ──
    await tester.tap(_navSeat(l10n, l10n.navBudget));
    await tester.pumpAndSettle();
    expect(find.byType(BudgetScreen), findsOneWidget,
        reason: 'عطل الإزاحة رجع: الميزانية تفتح شاشة أخرى');
    expect(find.byType(MoreScreen), findsNothing);
    expect(tester.takeException(), isNull, reason: 'شاشة الميزانية تنهار تخطيطياً');

    // ── «المزيد» → شاشة المزيد (كانت لا تفتح شيئاً) ──
    await tester.tap(_navSeat(l10n, l10n.navMore));
    await tester.pumpAndSettle();
    expect(find.byType(MoreScreen), findsOneWidget,
        reason: 'مقعد المزيد لا يفتح شاشة المزيد');
    expect(tester.takeException(), isNull, reason: 'شاشة المزيد تنهار تخطيطياً');

    // ── والعودة إلى «الرئيسية» تعمل ──
    await tester.tap(_navSeat(l10n, l10n.navHome));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('⭐ ضغطة ثانية على المقعد النشط تُبقي الشاشة صحيحة (لا شاشة بيضاء)',
      (WidgetTester tester) async {
    final FalousnaDatabase db = await _boot(tester);
    addTearDown(db.close);
    final AppLocalizations l10n = await _l10n();

    await tester.tap(_navSeat(l10n, l10n.navBudget));
    await tester.pumpAndSettle();
    await tester.tap(_navSeat(l10n, l10n.navBudget));
    await tester.pumpAndSettle();
    expect(find.byType(BudgetScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('⭐ زر الإضافة العائم فوق كل التبويبات لا يتأثر بالإزاحة',
      (WidgetTester tester) async {
    final FalousnaDatabase db = await _boot(tester);
    addTearDown(db.close);
    final AppLocalizations l10n = await _l10n();

    for (final String seat in <String>[
      l10n.navTransactions,
      l10n.navBudget,
      l10n.navMore,
    ]) {
      await tester.tap(find.text(seat));
      await tester.pumpAndSettle();
      expect(find.byType(FloatingActionButton), findsOneWidget,
          reason: 'الزر العائم اختفى في تبويب $seat');
    }
  });
}
