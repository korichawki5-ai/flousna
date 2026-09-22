import 'package:drift/native.dart';
import 'package:falousna/app.dart';
import 'package:falousna/core/config/constants.dart';
import 'package:falousna/core/utils/clock_guard.dart';
import 'package:falousna/data/db/database.dart';
import 'package:falousna/data/db/transaction_repository.dart';
import 'package:falousna/data/local/local_store.dart';
import 'package:falousna/features/auth/auth_choose_screen.dart';
import 'package:falousna/features/home/home_screen.dart';
import 'package:falousna/features/onboarding/consent_screen.dart';
import 'package:falousna/features/onboarding/onboarding_screen.dart';
import 'package:falousna/features/onboarding/setup_screen.dart';
import 'package:falousna/features/shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ═══════════════════════════════════════════════════════════════
///  اختبار الإقلاع — هل يفتح التطبيق فعلاً على الشاشة الصحيحة؟
///
///  ⭐ هذا أهم اختبار للمستخدم غير التقني: يثبت أن التسلسل القانوني
///     يعمل على جهازه قبل أن يلمس أي شيء:
///       تثبيت جديد ← التعريف ← الموافقة ← اختيار البدء ← الإعداد ← الرئيسية
///
///  نفحص **أنواع الشاشات** لا النصوص، حتى لا يتأثر الاختبار
///  بتغيير صياغة ترجمة.
/// ═══════════════════════════════════════════════════════════════

Future<void> _pumpApp(
  WidgetTester tester,
  Map<String, Object> saved,
) async {
  SharedPreferences.setMockInitialValues(saved);
  final LocalStore store = await LocalStore.init();
  final ClockGuard clock = await ClockGuard.create();

  final FalousnaDatabase db = FalousnaDatabase.forTesting(NativeDatabase.memory());
  final TransactionRepository txRepo = TransactionRepository(db, clock);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        localStorageProvider.overrideWithValue(store),
        clockGuardProvider.overrideWithValue(clock),
        falousnaDatabaseProvider.overrideWithValue(db),
        transactionRepositoryProvider.overrideWithValue(txRepo),
      ],
      child: const FalousnaApp(),
    ),
  );
  await tester.pumpAndSettle();
}

/// الموافقة الصالحة = علم + إصدار السياسة الحالي
Map<String, Object> _consented() => <String, Object>{
      AppConstants.keyConsentGranted: true,
      AppConstants.keyConsentVersion: AppConstants.privacyPolicyVersion,
      AppConstants.keyConsentHash: 'a' * 64,
    };

void main() {
  testWidgets('تثبيت جديد → شاشة التعريف أولاً', (WidgetTester tester) async {
    await _pumpApp(tester, <String, Object>{});

    expect(find.byType(OnboardingScreen), findsOneWidget);
    // 🔴 لا تُعرض شاشة الموافقة قبل التعريف (موافقة مستنيرة)
    expect(find.byType(ConsentScreen), findsNothing);
    expect(find.byType(HomeScreen), findsNothing);
  });

  testWidgets('أنهى التعريف بلا موافقة → حاجز الموافقة',
      (WidgetTester tester) async {
    await _pumpApp(tester, <String, Object>{
      AppConstants.keyOnboardingDone: true,
    });

    expect(find.byType(ConsentScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
  });

  testWidgets('🔴 إصدار سياسة أقدم → الموافقة تُطلب من جديد',
      (WidgetTester tester) async {
    await _pumpApp(tester, <String, Object>{
      AppConstants.keyOnboardingDone: true,
      AppConstants.keyConsentGranted: true,
      AppConstants.keyConsentVersion: '0.0.1', // إصدار قديم
      AppConstants.keyGuestMode: true,
      AppConstants.keySetupDone: true,
    });

    expect(find.byType(ConsentScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
  });

  testWidgets('وافق بلا جلسة → اختيار طريقة البدء',
      (WidgetTester tester) async {
    await _pumpApp(tester, <String, Object>{
      AppConstants.keyOnboardingDone: true,
      ..._consented(),
    });

    expect(find.byType(AuthChooseScreen), findsOneWidget);
  });

  testWidgets('ضيف بلا إعداد → الإعداد السريع', (WidgetTester tester) async {
    await _pumpApp(tester, <String, Object>{
      AppConstants.keyOnboardingDone: true,
      ..._consented(),
      AppConstants.keyGuestMode: true,
    });

    expect(find.byType(SetupScreen), findsOneWidget);
  });

  testWidgets('ضيف أنهى الإعداد → الرئيسية داخل الهيكل',
      (WidgetTester tester) async {
    await _pumpApp(tester, <String, Object>{
      AppConstants.keyOnboardingDone: true,
      ..._consented(),
      AppConstants.keyGuestMode: true,
      AppConstants.keySetupDone: true,
    });

    expect(find.byType(AppShell), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);
    // شريط التنقل السفلي + زر الإضافة العائم
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('⭐ الواجهة العربية في اتجاه RTL', (WidgetTester tester) async {
    await _pumpApp(tester, <String, Object>{
      AppConstants.keyOnboardingDone: true,
      ..._consented(),
      AppConstants.keyGuestMode: true,
      AppConstants.keySetupDone: true,
    });

    final BuildContext context = tester.element(find.byType(AppShell));
    expect(Directionality.of(context), TextDirection.rtl);
  });

  testWidgets('اختيار الفرنسية يقلب الاتجاه إلى LTR',
      (WidgetTester tester) async {
    await _pumpApp(tester, <String, Object>{
      AppConstants.keyOnboardingDone: true,
      ..._consented(),
      AppConstants.keyGuestMode: true,
      AppConstants.keySetupDone: true,
      AppConstants.keyLocale: 'fr_DZ',
    });

    final BuildContext context = tester.element(find.byType(AppShell));
    expect(Directionality.of(context), TextDirection.ltr);
  });
}
