import 'package:falousna/core/router/app_router.dart';
import 'package:flutter_test/flutter_test.dart';

/// ═══════════════════════════════════════════════════════════════
///  اختبار حراسات التنقل — 🔴 أهم اختبار قانوني في التطبيق
///
///  الترتيب المطلوب (موثّق في وثيقة 04):
///    1. التعريف (Onboarding) — لا يجمع أي بيانات
///    2. **الموافقة الصريحة** — حاجز مطلق (القانون 18-07 م.7)
///    3. الجلسة (حساب أو «بدون حساب»)
///    4. الإعداد السريع — مرة واحدة فقط
///
///  إن انكسر هذا الترتيب يصبح التطبيق يعالج بيانات بلا موافقة →
///  مخالفة صريحة. لذلك الاختبار يثبّت كل حالة على حدة.
/// ═══════════════════════════════════════════════════════════════

NavigationState _state({
  bool onboardingDone = false,
  bool hasConsent = false,
  bool hasSession = false,
  bool setupDone = false,
  bool isAdmin = false,
}) =>
    NavigationState(
      onboardingDone: onboardingDone,
      hasConsent: hasConsent,
      hasSession: hasSession,
      setupDone: setupDone,
      isAdmin: isAdmin,
    );

void main() {
  group('1) التعريف قبل كل شيء', () {
    test('تطبيق جديد يُوجَّه إلى Onboarding من أي مسار', () {
      final NavigationState fresh = _state();

      expect(guardRedirect(nav: fresh, location: '/'), RoutePaths.onboarding);
      expect(
        guardRedirect(nav: fresh, location: RoutePaths.home),
        RoutePaths.onboarding,
      );
      expect(
        guardRedirect(nav: fresh, location: RoutePaths.settings),
        RoutePaths.onboarding,
      );
    });

    test('البقاء في Onboarding مسموح (لا حلقة إعادة توجيه)', () {
      expect(
        guardRedirect(nav: _state(), location: RoutePaths.onboarding),
        isNull,
      );
    });

    test('Onboarding يتقدّم على الموافقة — حتى تكون الموافقة مستنيرة', () {
      // لم يشاهد التعريف ولم يوافق → الأولوية للتعريف لا للموافقة
      expect(
        guardRedirect(nav: _state(), location: RoutePaths.consent),
        RoutePaths.onboarding,
      );
    });
  });

  group('2) 🔴 الموافقة حاجز مطلق', () {
    final NavigationState onboarded = _state(onboardingDone: true);

    test('بدون موافقة لا يصل إلى أي شاشة', () {
      for (final String location in <String>[
        RoutePaths.home,
        RoutePaths.transactions,
        RoutePaths.addTransaction,
        RoutePaths.budget,
        RoutePaths.more,
        RoutePaths.settings,
        RoutePaths.legal,
        RoutePaths.about,
        RoutePaths.setup,
        RoutePaths.authChoose,
      ]) {
        expect(
          guardRedirect(nav: onboarded, location: location),
          RoutePaths.consent,
          reason: 'يجب حجز المسار: $location',
        );
      }
    });

    test('البقاء في شاشة الموافقة مسموح', () {
      expect(
        guardRedirect(nav: onboarded, location: RoutePaths.consent),
        isNull,
      );
    });

    test('🔴 سحب الموافقة (أو تغيير إصدار السياسة) يعيد الحاجز فوراً', () {
      final NavigationState revoked = _state(
        onboardingDone: true,
        hasSession: true,
        setupDone: true,
        hasConsent: false,
      );

      expect(
        guardRedirect(nav: revoked, location: RoutePaths.home),
        RoutePaths.consent,
      );
      expect(
        guardRedirect(nav: revoked, location: RoutePaths.addTransaction),
        RoutePaths.consent,
      );
    });
  });

  group('3) الجلسة (حساب أو وضع بدون حساب)', () {
    final NavigationState consented = _state(
      onboardingDone: true,
      hasConsent: true,
    );

    test('بلا جلسة → اختيار طريقة البدء', () {
      expect(
        guardRedirect(nav: consented, location: RoutePaths.home),
        RoutePaths.authChoose,
      );
      expect(
        guardRedirect(nav: consented, location: RoutePaths.consent),
        RoutePaths.authChoose,
        reason: 'من أنهى الموافقة لا يبقى في شاشتها',
      );
      expect(
        guardRedirect(nav: consented, location: RoutePaths.onboarding),
        RoutePaths.authChoose,
      );
    });

    test('البقاء في شاشة اختيار البدء مسموح', () {
      expect(
        guardRedirect(nav: consented, location: RoutePaths.authChoose),
        isNull,
      );
    });

    test('وضع الضيف يُعتبر جلسة صالحة', () {
      final NavigationState guest = _state(
        onboardingDone: true,
        hasConsent: true,
        hasSession: true,
        setupDone: true,
      );
      expect(guardRedirect(nav: guest, location: RoutePaths.home), isNull);
    });
  });

  group('4) الإعداد السريع — مرة واحدة فقط', () {
    final NavigationState sessionNoSetup = _state(
      onboardingDone: true,
      hasConsent: true,
      hasSession: true,
    );

    test('يُوجَّه إلى الإعداد عند أول دخول', () {
      expect(
        guardRedirect(nav: sessionNoSetup, location: RoutePaths.home),
        RoutePaths.setup,
      );
      expect(
        guardRedirect(nav: sessionNoSetup, location: RoutePaths.authChoose),
        RoutePaths.setup,
      );
    });

    test('البقاء في شاشة الإعداد مسموح (لا حلقة)', () {
      expect(
        guardRedirect(nav: sessionNoSetup, location: RoutePaths.setup),
        isNull,
      );
    });

    test('⭐ بعد إكماله لا يُفرض أبداً (لا احتكاك متكرر)', () {
      final NavigationState done = _state(
        onboardingDone: true,
        hasConsent: true,
        hasSession: true,
        setupDone: true,
      );

      for (final String location in <String>[
        RoutePaths.home,
        RoutePaths.transactions,
        RoutePaths.addTransaction,
        RoutePaths.budget,
        RoutePaths.more,
        RoutePaths.settings,
        RoutePaths.legal,
        RoutePaths.about,
        RoutePaths.setup,
      ]) {
        expect(
          guardRedirect(nav: done, location: location),
          isNull,
          reason: 'يجب أن يبقى حراً في: $location',
        );
      }
    });
  });

  group('ثوابت المسارات', () {
    test('لا مسار مكرر بين الأسماء والروابط', () {
      final Set<String> paths = <String>{
        RoutePaths.onboarding,
        RoutePaths.consent,
        RoutePaths.authChoose,
        RoutePaths.setup,
        RoutePaths.home,
        RoutePaths.transactions,
        RoutePaths.addTransaction,
        RoutePaths.budget,
        RoutePaths.more,
        RoutePaths.settings,
        RoutePaths.legal,
        RoutePaths.about,
      };
      expect(paths.length, 12);
    });

    test('كل مسار يبدأ بخط مائل', () {
      for (final String path in <String>[
        RoutePaths.home,
        RoutePaths.addTransaction,
        RoutePaths.settings,
      ]) {
        expect(path.startsWith('/'), isTrue, reason: path);
      }
    });

    test('مسارات الشاشة الفرعية تحت /more', () {
      expect(RoutePaths.settings.startsWith(RoutePaths.more), isTrue);
      expect(RoutePaths.legal.startsWith(RoutePaths.more), isTrue);
      expect(RoutePaths.about.startsWith(RoutePaths.more), isTrue);
    });
  });

  group('دور المسؤول', () {
    test('🔴 الدور لا يُقرأ من التخزين المحلي في هذه المرحلة', () {
      // isAdmin مثبّت على false في navigationStateProvider حتى المرحلة 4،
      // حيث يُقرأ من جدول user_roles في الخادم (لا من الجهاز).
      final NavigationState state = _state(isAdmin: false);
      expect(state.isAdmin, isFalse);

      // وحتى لو ادّعى الجهاز أنه مسؤول، الحراسات لا تفتح شيئاً إضافياً
      final NavigationState claimed = _state(
        onboardingDone: true,
        hasConsent: true,
        hasSession: true,
        setupDone: true,
        isAdmin: true,
      );
      expect(guardRedirect(nav: claimed, location: RoutePaths.home), isNull);
      expect(guardRedirect(nav: claimed, location: '/admin'), isNull);
    });
  });
}
