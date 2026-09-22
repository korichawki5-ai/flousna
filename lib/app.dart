import 'package:falousna/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/l10n/locale_controller.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme_dark.dart';
import 'core/theme/app_theme_light.dart';
import 'core/theme/design_tokens.dart';
import 'core/theme/theme_controller.dart';

/// ═══════════════════════════════════════════════════════════════
///  FalousnaApp — جذر التطبيق
///
///  ⭐ القرار المعماري الأهم هنا:
///     `Directionality` يقود **كل** الشجرة. لا توجد أي قيمة اتجاه
///     ثابتة (left/right) في أي شاشة — كلها start/end عبر
///     EdgeInsetsDirectional و AlignmentDirectional.
///
///  النتيجة: تبديل اللغة بين العربية (RTL) والفرنسية (LTR) يقلب
///  التطبيق كاملاً — القوائم، الأيقونات السهمية، التمرير، أشرطة
///  التقدم، والمحاذاة.
///
///  ⚠️ ملاحظة: لا نستخدم `Localizations.localeOf(context)` هنا لأن
///     جذر MaterialApp ليس له سلف Localizations — نقرأ لغة الجهاز
///     من `PlatformDispatcher.instance.locale` مباشرة.
/// ═══════════════════════════════════════════════════════════════
class FalousnaApp extends ConsumerWidget {
  const FalousnaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // حالة اللغة (watch — يُعيد البناء عند تغيير المستخدم لها)
    final LocaleState localeState = ref.watch(localeControllerProvider);

    // وضع المظهر (فاتح / داكن / تلقائي)
    final ThemeMode themeMode = ref.watch(themeControllerProvider);

    // الراوتر مع حراسات المسارات
    final GoRouter router = ref.watch(appRouterProvider);

    // ⭐ لغة الجهاز من PlatformDispatcher — يعمل في الجذر بلا سلف
    final Locale platformLocale =
        PlatformDispatcher.instance.locale;

    // حلّ اللغة الفعلية: اختيار المستخدم ← لغة الجهاز ← الافتراضية
    final Locale effectiveLocale = _resolveLocale(localeState, platformLocale);

    // ⭐ الاتجاه يُشتق من اللغة — لا يُضبط يدوياً أبداً
    final TextDirection direction = effectiveLocale.languageCode == 'ar'
        ? TextDirection.rtl
        : TextDirection.ltr;

    return MaterialApp.router(
      onGenerateTitle: (BuildContext titleContext) =>
          AppLocalizations.of(titleContext).appName,
      debugShowCheckedModeBanner: false,

      // ── الثيم: نظام واحد عبر Design Tokens ──
      theme: AppThemeLight.build(),
      darkTheme: AppThemeDark.build(),
      themeMode: themeMode,

      // ── الترجمة ──
      locale: effectiveLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: kSupportedLocales,

      // ── الراوتر ──
      routerConfig: router,

      // ── حماية من تسرّب اتجاه خاطئ من أي مكتبة خارجية ──
      builder: (BuildContext builderContext, Widget? child) => Directionality(
        textDirection: direction,
        child: _ResponsiveWidth(child: child ?? const SizedBox.shrink()),
      ),
    );
  }

  /// يطابق لغة الجهاز مع اللغات المدعومة على رمز اللغة فقط،
  /// فتعمل ar_EG و ar_MA و ar_TN كلها كـ ar_DZ.
  Locale _resolveLocale(LocaleState state, Locale platformLocale) {
    if (!state.followsSystem && state.choice != null) {
      return state.choice!;
    }
    for (final Locale supported in kSupportedLocales) {
      if (supported.languageCode == platformLocale.languageCode) {
        return supported;
      }
    }
    return kDefaultLocale;
  }
}

/// ═══════════════════════════════════════════════════════════════
///  ResponsiveWidth — تقييد العرض على الشاشات الكبيرة
///
///  على نسخة Windows (شاشة عريضة) لا نمدّ المحتوى إلى 1920px —
///  يصبح غير قابل للقراءة. نقيّده بـ 720px ونوسّطه.
///  على الهاتف لا تغيير إطلاقاً.
/// ═══════════════════════════════════════════════════════════════
class _ResponsiveWidth extends StatelessWidget {
  const _ResponsiveWidth({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.linux);

    if (!isDesktop && !kIsWeb) return child;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth > AppTokens.breakpointExpanded) {
          return ColoredBox(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppTokens.maxContentWidth,
                ),
                child: child,
              ),
            ),
          );
        }
        return child;
      },
    );
  }
}
