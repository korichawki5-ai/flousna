// ═══════════════════════════════════════════════════════════════
//  add_screen_layout_test — حارس تخطيط شاشة الإضافة
//
//  وُلد من حادثة 22/09/2026: Align داخل bottomNavigationBar تمدّد
//  فالتهم ارتفاع الشاشة وسحق الجسم إلى صفر (نافذة بيضاء + زر عائم).
//  هذا الاختبار يقيس المستطيلات الحقيقية ويمنع عودة الحادثة للأبد.
// ═══════════════════════════════════════════════════════════════
import 'package:falousna/core/l10n/locale_controller.dart';
import 'package:falousna/core/utils/clock_guard.dart';
import 'package:falousna/core/widgets/app_button.dart';
import 'package:falousna/data/local/local_store.dart';
import 'package:falousna/features/transactions/add_transaction_screen.dart';
import 'package:falousna/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpAdd(WidgetTester tester, {required Size logical}) async {
  tester.view.physicalSize = logical;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final LocalStore store = await LocalStore.init();
  final ClockGuard clock = await ClockGuard.create();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        localStorageProvider.overrideWithValue(store),
        clockGuardProvider.overrideWithValue(clock),
      ],
      child: MaterialApp(
        locale: kDefaultLocale,
        supportedLocales: kSupportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const AddTransactionScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('⭐ نافذة Windows: النموذج مرئي وزر الحفظ في الأسفل', (WidgetTester tester) async {
    await _pumpAdd(tester, logical: const Size(1280, 768));

    // الجسم لا يُسحق: منطقة التمرير تأخذ معظم الارتفاع المتبقي
    final Rect scroll = tester.getRect(find.byType(SingleChildScrollView).first);
    expect(scroll.height, greaterThan(400), reason: 'جسم النموذج انسحق — عدوى حادثة 22/09');

    // حقول النموذج داخل منطقة الرؤية فعلاً
    final Rect amount = tester.getRect(find.byType(TextField).first);
    expect(amount.top, greaterThanOrEqualTo(scroll.top - 1));
    expect(amount.bottom, lessThanOrEqualTo(scroll.bottom + 1));

    // زر الحفظ في الشريط السفلي لا فوق AppBar
    final Rect save = tester.getRect(find.byType(AppButton).first);
    expect(save.top, greaterThan(600), reason: 'زر الحفظ طافٍ في الأعلى — حادثة 22/09');
    expect(save.bottom, lessThanOrEqualTo(768));

    // AppBar في مكانه
    expect(tester.getRect(find.byType(AppBar)).topLeft, Offset.zero);
    expect(tester.takeException(), isNull);
  });

  testWidgets('هاتف صغير: نفس الضمانات', (WidgetTester tester) async {
    await _pumpAdd(tester, logical: const Size(360, 740));
    final Rect scroll = tester.getRect(find.byType(SingleChildScrollView).first);
    expect(scroll.height, greaterThan(300));
    final Rect save = tester.getRect(find.byType(AppButton).first);
    expect(save.top, greaterThan(560));
    expect(tester.takeException(), isNull);
  });
}
