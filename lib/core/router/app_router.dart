import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/local/local_store.dart';
import '../../features/auth/auth_choose_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/legal/legal_screen.dart';
import '../../features/more/about_screen.dart';
import '../../features/more/more_screen.dart';
import '../../features/onboarding/consent_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/onboarding/setup_screen.dart';
import '../../features/settings/category_manager_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/transactions/add_transaction_screen.dart';
import '../../features/transactions/budget_screen.dart';
import '../../features/transactions/transactions_screen.dart';

/// ═══════════════════════════════════════════════════════════════
///  AppRouter — التنقل مع حراسات المسارات
///
///  ⚠️ قاعدة العمق ≤ 3 مستويات (المرحلة 3 — النقطة 6):
///     Bottom Nav (1) → الشاشة (2) → التفاصيل (3). لا متاهات.
///
///  ⭐ حراسات المسارات هي الحماية الحقيقية:
///     لا نعتمد على إخفاء زر في الواجهة — بل يمنع الراوتر نفسه
///     الوصول إلى أي شاشة بدون شرطها. (المرحلة 2 — النقطة 4)
///
///  ترتيب الحراسة:
///    1. الموافقة القانونية  ← إلزامية قبل أي شيء (القانون 18-07 م.7)
///    2. Onboarding          ← الشرح الأول
///    3. الجلسة              ← حساب أو وضع ضيف
///    4. الإعداد السريع      ← يمكن تخطّيه
///    5. الدور (admin)       ← المرحلة 4
/// ═══════════════════════════════════════════════════════════════

/// أسماء المسارات — تُستعمل بدل النصوص الخام
abstract final class RouteNames {
  static const String onboarding = 'onboarding';
  static const String consent = 'consent';
  static const String authChoose = 'authChoose';
  static const String setup = 'setup';

  static const String home = 'home';
  static const String transactions = 'transactions';
  static const String addTransaction = 'addTransaction';
  static const String budget = 'budget';
  static const String more = 'more';

  static const String settings = 'settings';
  static const String categories = 'categories';
  static const String legal = 'legal';
  static const String about = 'about';
}

/// مسارات التنقل — تُستعمل مع context.go / context.push
abstract final class RoutePaths {
  static const String onboarding = '/onboarding';
  static const String consent = '/consent';
  static const String authChoose = '/auth';
  static const String setup = '/setup';

  static const String home = '/home';
  static const String transactions = '/transactions';
  static const String addTransaction = '/add';
  static const String budget = '/budget';
  static const String more = '/more';

  static const String settings = '/more/settings';
  static const String categories = '/more/categories';
  static const String legal = '/more/legal';
  static const String about = '/more/about';
}

/// حالة التنقل — تُشتق من التخزين المحلي
class NavigationState {
  const NavigationState({
    required this.hasConsent,
    required this.onboardingDone,
    required this.setupDone,
    required this.hasSession,
    required this.isAdmin,
  });

  /// هل وافق المستخدم على السياسة والشروط؟ (القانون 18-07)
  final bool hasConsent;

  final bool onboardingDone;
  final bool setupDone;

  /// هل له جلسة؟ (حساب أو وضع ضيف)
  final bool hasSession;

  /// هل دوره admin؟
  ///
  /// 🔴 في المرحلة 4 تُقرأ من جدول `user_roles` في Supabase —
  ///    **لا من التخزين المحلي أبداً**، وإلا رقّى أي مستخدم نفسه.
  final bool isAdmin;
}

/// مزوّد حالة التنقل
final navigationStateProvider = Provider<NavigationState>((Ref ref) {
  final LocalStore store = ref.watch(localStorageProvider);

  // ⭐ الموافقة تُعتبر غير صالحة إن تغيّر إصدار السياسة
  final bool consentValid = store.isConsentCurrent;

  // الجلسة: وضع ضيف نشط، أو (المرحلة 3) حساب مسجّل
  final bool hasSession = store.isGuestMode;

  return NavigationState(
    hasConsent: consentValid,
    onboardingDone: store.onboardingDone,
    setupDone: store.setupDone,
    hasSession: hasSession,
    isAdmin: false,
  );
});

/// يحدّث حالة التنقل بعد تغيير في التخزين المحلي
///
/// تُستدعى بعد: منح الموافقة · إكمال Onboarding · الدخول كضيف ·
/// إكمال الإعداد · حذف البيانات.
///
/// ⚠️ المعامل `WidgetRef` وليس `Ref`: في Riverpod 3 لا علاقة وراثة
///    بين الاثنين عمداً (FAQ الرسمي). كل مستدعيات هذه الدالة شاشات
///    (ConsumerWidget / ConsumerState) فتملك WidgetRef.
///    إن احتاج مزوّد داخلي نفس العمل، يستعمل
///    `ref.invalidate(navigationStateProvider)` مباشرة.
void refreshNavigation(WidgetRef ref) =>
    ref.invalidate(navigationStateProvider);

/// مزوّد الراوتر
final appRouterProvider = Provider<GoRouter>((Ref ref) {
  final NavigationState nav = ref.watch(navigationStateProvider);

  return GoRouter(
    initialLocation: RoutePaths.onboarding,
    debugLogDiagnostics: _routerLoggingEnabled,
    redirect: (BuildContext context, GoRouterState state) =>
        _redirect(nav, state),
    routes: _buildRoutes(),
  );
});

/// ⭐ الحارس المركزي — كل التنقلات تمرّ من هنا.
/// معزول في دالة نقية حتى يُختبر بـ unit test (test/router_guard_test.dart).
///
/// الترتيب المعتمد: **Onboarding → الموافقة → الجلسة → الإعداد**
/// لأن الموافقة يجب أن تكون **مستنيرة** — يقرأ المستخدم القيمة أولاً
/// ثم يوافق. ولا يُجمع أي حرف عنه قبل الموافقة؛ العلم الوحيد المخزَّن
/// قبلها هو «هل رأى الشرح؟» وهو ضروري لتشغيل الخدمة نفسها.
String? _redirect(NavigationState nav, GoRouterState state) =>
    guardRedirect(nav: nav, location: state.matchedLocation);

/// منطق الحراسات كدالة نقية — ⭐ قابلة للاختبار بلا GoRouter
///
/// الترتيب مقصود وله سبب قانوني:
///   1. **Onboarding قبل الموافقة** — حتى تكون الموافقة *مستنيرة*:
///      المستخدم يفهم ما هو التطبيق قبل أن يُطلب منه الإقرار.
///      (البيانات الوحيدة المخزَّنة قبل الموافقة هي علم «شاهد
///      التعريف» — ضروري تقنياً ولا يشمل أي بيانات شخصية.)
///   2. **الموافقة حاجز مطلق** (القانون 18-07 المادة 7): لا جلسة،
///      لا إعداد، لا أي شاشة أخرى قبل الموافقة الصريحة.
///   3. **الجلسة**: حساب أو «وضع بدون حساب» (ضيف).
///   4. **الإعداد السريع** مرة واحدة، ولا يُفرض بعده أبداً.
///
/// يعيد `null` = «ابقَ حيث أنت»، وإلا المسار الواجب فتحه.
String? guardRedirect({
  required NavigationState nav,
  required String location,
}) {
  // 1) Onboarding أولاً — لا يتطلب أي موافقة ولا يجمع أي بيانات
  if (!nav.onboardingDone) {
    return location == RoutePaths.onboarding ? null : RoutePaths.onboarding;
  }

  // 2) 🔴 الموافقة القانونية — حاجز إلزامي (القانون 18-07 م.7)
  if (!nav.hasConsent) {
    return location == RoutePaths.consent ? null : RoutePaths.consent;
  }

  // من أنهى الخطوتين لا يبقى في شاشاتهما
  if (location == RoutePaths.onboarding || location == RoutePaths.consent) {
    return nav.hasSession ? RoutePaths.home : RoutePaths.authChoose;
  }

  // 3) الجلسة (حساب أو وضع ضيف)
  if (!nav.hasSession) {
    return location == RoutePaths.authChoose ? null : RoutePaths.authChoose;
  }

  // 4) الإعداد السريع — يوجَّه مرة واحدة فقط، ثم لا يُفرض
  if (!nav.setupDone && location != RoutePaths.setup) {
    return RoutePaths.setup;
  }

  return null;
}

/// تسجيل الراوتر في وضع التطوير فقط
const bool _routerLoggingEnabled = bool.fromEnvironment('dart.vm.product') == false;

/// قائمة المسارات
List<RouteBase> _buildRoutes() {
  return <RouteBase>[
    // ── ما قبل الجلسة ──
    GoRoute(
      path: RoutePaths.consent,
      name: RouteNames.consent,
      builder: (BuildContext context, GoRouterState state) =>
          const ConsentScreen(),
    ),
    GoRoute(
      path: RoutePaths.onboarding,
      name: RouteNames.onboarding,
      builder: (BuildContext context, GoRouterState state) =>
          const OnboardingScreen(),
    ),
    GoRoute(
      path: RoutePaths.authChoose,
      name: RouteNames.authChoose,
      builder: (BuildContext context, GoRouterState state) =>
          const AuthChooseScreen(),
    ),
    GoRoute(
      path: RoutePaths.setup,
      name: RouteNames.setup,
      builder: (BuildContext context, GoRouterState state) =>
          const SetupScreen(),
    ),

    // ── الهيكل الرئيسي: 4 فروع + زر إضافة عائم في الوسط ──
    //    ⭐ زر الإضافة ليس فرعاً في NavigationBar — لأنه **إجراء**
    //    لا **وجهة**. يبقى FAB عائماً في وسط الشريط (Thumb Zone).
    StatefulShellRoute.indexedStack(
      builder: (
        BuildContext context,
        GoRouterState state,
        StatefulNavigationShell navigationShell,
      ) =>
          AppShell(navigationShell: navigationShell),
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: RoutePaths.home,
              name: RouteNames.home,
              builder: (BuildContext context, GoRouterState state) =>
                  const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: RoutePaths.transactions,
              name: RouteNames.transactions,
              builder: (BuildContext context, GoRouterState state) =>
                  const TransactionsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: RoutePaths.budget,
              name: RouteNames.budget,
              builder: (BuildContext context, GoRouterState state) =>
                  const BudgetScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: RoutePaths.more,
              name: RouteNames.more,
              builder: (BuildContext context, GoRouterState state) =>
                  const MoreScreen(),
              routes: <RouteBase>[
                GoRoute(
                  path: 'settings',
                  name: RouteNames.settings,
                  builder: (BuildContext context, GoRouterState state) =>
                      const SettingsScreen(),
                ),
                GoRoute(
                  path: 'categories',
                  name: RouteNames.categories,
                  builder: (BuildContext context, GoRouterState state) =>
                      const CategoryManagerScreen(),
                ),
                GoRoute(
                  path: 'legal',
                  name: RouteNames.legal,
                  builder: (BuildContext context, GoRouterState state) =>
                      const LegalScreen(),
                ),
                GoRoute(
                  path: 'about',
                  name: RouteNames.about,
                  builder: (BuildContext context, GoRouterState state) =>
                      const AboutScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),

    // ── إضافة حركة: مسار كامل فوق الهيكل (لا فرع فيه) ──
    GoRoute(
      path: RoutePaths.addTransaction,
      name: RouteNames.addTransaction,
      builder: (BuildContext context, GoRouterState state) =>
          const AddTransactionScreen(),
    ),
  ];
}

/// ═══════════════════════════════════════════════════════════════
///  أدوات التنقل
/// ═══════════════════════════════════════════════════════════════

/// ينتقل إلى مسار مع تفريغ المكدس (بعد الدخول/الموافقة)
void navigateReplace(BuildContext context, String path) => context.go(path);

/// يدفع شاشة فوق الحالية (مع زر رجوع متوقع — قاعدة 6)
void navigatePush(BuildContext context, String path) => context.push(path);

/// يرجع خطوة — آمن حتى لو كان المكدس فارغاً
void navigateBack(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  }
}
