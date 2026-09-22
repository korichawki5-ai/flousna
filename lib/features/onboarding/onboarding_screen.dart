import 'package:falousna/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/locale_controller.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/widgets/app_button.dart';
import '../../data/local/local_store.dart';

/// ═══════════════════════════════════════════════════════════════
///  OnboardingScreen — أول تشغيل
///
///  ✅ قواعد مطبَّقة (المرحلة 3 — النقطة 10):
///     - ≤ 3 شاشات سريعة
///     - قابلة للتخطي دائماً (زر «تخطّي» ظاهر من الصفحة الأولى)
///     - كل شاشة: قيمة واحدة فقط (Hick's Law)
///     - الصفحة الثالثة تبني **الثقة القانونية** قبل شاشة الموافقة
///
///  ⚠️ لا نجمع أي بيانات هنا — ولا حتى device_id.
///     الجمع يبدأ فقط بعد الموافقة (القانون 18-07 م.7).
/// ═══════════════════════════════════════════════════════════════
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController = PageController();
  int _currentPage = 0;

  static const int _pageCount = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    if (index < 0 || index >= _pageCount) return;

    // ⭐ احترام prefers-reduced-motion: بلا حركة عند تعطيلها
    final bool reduceMotion = WidgetsBinding
        .instance.platformDispatcher.accessibilityFeatures.disableAnimations;

    if (reduceMotion) {
      _pageController.jumpToPage(index);
    } else {
      _pageController.animateToPage(
        index,
        duration: AppTokens.motionMedium,
        curve: AppTokens.curveStandard,
      );
    }
    setState(() => _currentPage = index);
  }

  /// التخطّي أو «لنبدأ» — كلاهما يُكمل الـ Onboarding
  Future<void> _complete() async {
    final LocalStore store = ref.read(localStorageProvider);
    await store.completeOnboarding();
    refreshNavigation(ref);
    if (!mounted) return;
    context.go(RoutePaths.consent);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LocaleState localeState = ref.watch(localeControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // ── الشريط العلوي: مبدّل اللغة + تخطّي ──
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppTokens.spaceSm,
                vertical: AppTokens.spaceSm,
              ),
              child: Row(
                children: <Widget>[
                  // مبدّل لغة سريع — مهم لأن المستخدم قد يفتح
                  // التطبيق بلغة جهاز خاطئة
                  _LanguageToggle(currentLocale: localeState.effective),
                  const Spacer(),
                  TextButton(
                    onPressed: _complete,
                    child: Text(l10n.onboardingSkip),
                  ),
                ],
              ),
            ),

            // ── الصفحات ──
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int index) =>
                    setState(() => _currentPage = index),
                children: <Widget>[
                  _OnboardingPage(
                    icon: Icons.pie_chart_rounded,
                    iconBackground: const Color(0xFFA5D6A7),
                    iconColor: const Color(0xFF0B3D13),
                    title: l10n.onb1Title,
                    body: l10n.onb1Body,
                  ),
                  _OnboardingPage(
                    icon: Icons.calendar_month_rounded,
                    iconBackground: const Color(0xFFFFE082),
                    iconColor: const Color(0xFF3D2E00),
                    title: l10n.onb2Title,
                    body: l10n.onb2Body,
                  ),
                  _OnboardingPage(
                    icon: Icons.privacy_tip_rounded,
                    iconBackground: const Color(0xFF80CBC4),
                    iconColor: const Color(0xFF00251F),
                    title: l10n.onb3Title,
                    body: l10n.onb3Body,
                  ),
                ],
              ),
            ),

            // ── المؤشرات + الزر ──
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppTokens.spaceLg,
              ),
              child: Column(
                children: <Widget>[
                  _PageIndicator(
                    count: _pageCount,
                    current: _currentPage,
                    onTap: _goToPage,
                  ),
                  const SizedBox(height: AppTokens.spaceSm),
                  Text(
                    l10n.onboardingPageOf(_currentPage + 1, _pageCount),
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppTokens.spaceLg),
                  AppButton(
                    label: _currentPage == _pageCount - 1
                        ? l10n.onboardingStart
                        : l10n.onboardingNext,
                    onPressed: () {
                      if (_currentPage == _pageCount - 1) {
                        _complete();
                      } else {
                        _goToPage(_currentPage + 1);
                      }
                    },
                    variant: AppButtonVariant.filled,
                    trailingIcon: _currentPage == _pageCount - 1
                        ? null
                        : Icons.arrow_forward_rounded,
                  ),
                  const SizedBox(height: AppTokens.spaceLg),
                  // ── اعتماد الاستوديو المطوّر (أول شاشة يراها المستخدم) ──
                  Text(
                    l10n.creditDeveloper,
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// صفحة واحدة من الـ Onboarding — قيمة واحدة فقط
class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppTokens.spaceXxl,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // ── الرسم التوضيحي ──
          Container(
            width: 168,
            height: 168,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 84, color: iconColor),
          ),
          const SizedBox(height: AppTokens.spaceXxl),

          // ── العنوان ──
          Text(
            title,
            style: AppTypography.textTheme.headlineMedium?.copyWith(
              color: scheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTokens.spaceLg),

          // ── الوصف ──
          Text(
            body,
            style: AppTypography.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.75,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// مؤشرات الصفحات — قابلة للنقر (هدف لمس ≥ 48dp)
class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.count,
    required this.current,
    required this.onTap,
  });

  final int count;
  final int current;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(count, (int index) {
        final bool isActive = index == current;
        return Semantics(
          button: true,
          selected: isActive,
          label: '${index + 1}',
          child: GestureDetector(
            onTap: () => onTap(index),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              // ⭐ هدف لمس ≥ 48dp حتى لو كان المؤشر بصرياً صغيراً
              width: AppTokens.minTouchTarget / 2,
              height: AppTokens.minTouchTarget / 2,
              child: Center(
                child: AnimatedContainer(
                  duration: AppTokens.motionFast,
                  curve: AppTokens.curveStandard,
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? scheme.primary : scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// مبدّل لغة سريع في الـ Onboarding
class _LanguageToggle extends ConsumerWidget {
  const _LanguageToggle({required this.currentLocale});

  final Locale currentLocale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isArabic = currentLocale.languageCode == 'ar';

    return SegmentedButton<String>(
      segments: const <ButtonSegment<String>>[
        ButtonSegment<String>(value: 'ar', label: Text('العربية')),
        ButtonSegment<String>(value: 'fr', label: Text('Français')),
      ],
      selected: <String>{isArabic ? 'ar' : 'fr'},
      showSelectedIcon: false,
      onSelectionChanged: (Set<String> selection) {
        final String code = selection.first;
        ref.read(localeControllerProvider.notifier).setLocale(
              Locale(code, 'DZ'),
            );
      },
    );
  }
}
