import 'package:falousna/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/locale_controller.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/period_resolver.dart';
import '../../core/widgets/app_button.dart';
import '../../data/local/local_store.dart';

/// ═══════════════════════════════════════════════════════════════
///  SetupScreen — الإعداد الأولي السريع
///
///  ✅ القواعد المطبَّقة:
///     - **3 خطوات كحد أقصى** وكلها قابلة للتخطي (لا احتكاك)
///     - خطوة واحدة في كل شاشة (Hick's Law: خيارات قليلة)
///     - كل اختيار يُظهر **أثراً فورياً** («سنضبط ميزانيتك…»)
///       حتى يفهم المستخدم لماذا نسأله
///     - الاختيارات تُحفظ محلياً — تعمل بلا إنترنت وبلا حساب
///
///  الخطوات:
///    1. المظهر (فاتح/داكن/تلقائي) + اللغة
///    2. نوع الدخل  ← يحدد الدورة الأسبوعية أو الشهرية
///    3. تأكيد وملخص
/// ═══════════════════════════════════════════════════════════════
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  int _step = 0;
  bool _saving = false;

  /// نوع الدخل المختار — `null` يعني لم يختر بعد
  IncomeType? _incomeType;

  static const int _stepCount = 3;

  Future<void> _finish() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final LocalStore store = ref.read(localStorageProvider);

      // تطبيق الدورة حسب نوع الدخل
      if (_incomeType != null) {
        await store.setBudgetMode(_incomeType!.recommendedMode);
        // من دخله ثابت يبدأ شهره يوم 1 افتراضياً
        // ومن دخله يومي/متغير يبدأ أسبوعه السبت (مثبّت في PeriodResolver)
        if (_incomeType == IncomeType.fixed) {
          await store.setFiscalAnchorDay(1);
        }
      }

      await store.completeSetup();
      refreshNavigation(ref);

      if (!mounted) return;
      context.go(RoutePaths.home);
    } on Exception {
      if (!mounted) return;
      setState(() => _saving = false);
      final AppLocalizations l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorGenericBody),
          duration: AppTokens.snackBarDuration,
        ),
      );
    }
  }

  Future<void> _skipAll() async {
    try {
      final LocalStore store = ref.read(localStorageProvider);
      await store.completeSetup();
      refreshNavigation(ref);
      if (!mounted) return;
      context.go(RoutePaths.home);
    } on Exception {
      if (!mounted) return;
      final AppLocalizations l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorGenericBody),
          duration: AppTokens.snackBarDuration,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.setupTitle),
        // ⭐ زر تخطّي الكل — الإعداد اختياري دائماً
        actions: <Widget>[
          TextButton(
            onPressed: _saving ? null : _skipAll,
            child: Text(l10n.setupSkipAll),
          ),
          const SizedBox(width: AppTokens.spaceSm),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // ── شريط التقدم ──
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppTokens.spaceLg,
                vertical: AppTokens.spaceSm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                    child: LinearProgressIndicator(
                      value: (_step + 1) / _stepCount,
                      minHeight: 6,
                      backgroundColor: scheme.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: AppTokens.spaceSm),
                  Text(
                    l10n.setupStepOf(_step + 1, _stepCount),
                    style: AppTypography.monoSmall.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // ── محتوى الخطوة ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppTokens.spaceLg,
                ),
                child: switch (_step) {
                  0 => _buildAppearanceStep(l10n, scheme),
                  1 => _buildIncomeStep(l10n, scheme),
                  _ => _buildSummaryStep(l10n, scheme),
                },
              ),
            ),

            // ── أزرار التنقل ──
            Padding(
              padding: const EdgeInsetsDirectional.all(AppTokens.spaceLg),
              child: Row(
                children: <Widget>[
                  if (_step > 0)
                    Expanded(
                      child: AppButton(
                        label: l10n.actionBack,
                        onPressed: _saving
                            ? null
                            : () => setState(() => _step--),
                        variant: AppButtonVariant.outlined,
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: AppTokens.spaceMd),
                  Expanded(
                    flex: _step > 0 ? 2 : 1,
                    child: AppButton(
                      label: _step == _stepCount - 1
                          ? l10n.setupFinish
                          : l10n.actionNext,
                      onPressed: _saving
                          ? null
                          : () {
                              if (_step == _stepCount - 1) {
                                _finish();
                              } else {
                                setState(() => _step++);
                              }
                            },
                      isLoading: _saving,
                      variant: AppButtonVariant.filled,
                      trailingIcon: _step == _stepCount - 1
                          ? null
                          : Icons.arrow_forward_rounded,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  الخطوة 1: المظهر واللغة
  // ─────────────────────────────────────────────────────────────
  Widget _buildAppearanceStep(AppLocalizations l10n, ColorScheme scheme) {
    final ThemeMode themeMode = ref.watch(themeControllerProvider);
    final LocaleState localeState = ref.watch(localeControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: AppTokens.spaceLg),
        _StepHeader(
          icon: Icons.palette_outlined,
          title: l10n.settingsSectionAppearance,
          subtitle: l10n.setupSubtitle,
        ),
        const SizedBox(height: AppTokens.spaceXl),

        // ── المظهر ──
        Text(
          l10n.settingsTheme,
          style: AppTypography.textTheme.titleSmall?.copyWith(
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: AppTokens.spaceSm),
        _ChoiceRow(
          options: <_ChoiceOption<ThemeMode>>[
            _ChoiceOption<ThemeMode>(
              value: ThemeMode.system,
              label: l10n.settingsThemeSystem,
              icon: Icons.brightness_auto_rounded,
            ),
            _ChoiceOption<ThemeMode>(
              value: ThemeMode.light,
              label: l10n.settingsThemeLight,
              icon: Icons.light_mode_rounded,
            ),
            _ChoiceOption<ThemeMode>(
              value: ThemeMode.dark,
              label: l10n.settingsThemeDark,
              icon: Icons.dark_mode_rounded,
            ),
          ],
          selected: themeMode,
          onSelected: (ThemeMode mode) =>
              ref.read(themeControllerProvider.notifier).setMode(mode),
        ),

        const SizedBox(height: AppTokens.spaceXl),

        // ── اللغة ──
        Text(
          l10n.settingsLanguage,
          style: AppTypography.textTheme.titleSmall?.copyWith(
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: AppTokens.spaceSm),
        _ChoiceRow<String>(
          options: <_ChoiceOption<String>>[
            _ChoiceOption<String>(
              value: 'ar',
              label: l10n.setupLanguageArabic,
              icon: Icons.translate_rounded,
            ),
            _ChoiceOption<String>(
              value: 'fr',
              label: l10n.setupLanguageFrench,
              icon: Icons.translate_rounded,
            ),
          ],
          selected: localeState.effective.languageCode,
          onSelected: (String code) => ref
              .read(localeControllerProvider.notifier)
              .setLocale(Locale(code, 'DZ')),
        ),
        const SizedBox(height: AppTokens.spaceXxl),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  الخطوة 2: نوع الدخل
  // ─────────────────────────────────────────────────────────────
  Widget _buildIncomeStep(AppLocalizations l10n, ColorScheme scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: AppTokens.spaceLg),
        _StepHeader(
          icon: Icons.payments_outlined,
          title: l10n.setupStepIncome,
          subtitle: l10n.onb2Body,
        ),
        const SizedBox(height: AppTokens.spaceXl),

        _IncomeCard(
          icon: Icons.construction_rounded,
          title: l10n.setupIncomeDaily,
          hint: l10n.setupIncomeDailyHint,
          effect: l10n.setupIncomeDailyResult,
          selected: _incomeType == IncomeType.daily,
          onTap: () => setState(() => _incomeType = IncomeType.daily),
        ),
        const SizedBox(height: AppTokens.spaceMd),
        _IncomeCard(
          icon: Icons.trending_up_rounded,
          title: l10n.setupIncomeVariable,
          hint: l10n.setupIncomeVariableHint,
          effect: l10n.setupIncomeVariableResult,
          selected: _incomeType == IncomeType.variable,
          onTap: () => setState(() => _incomeType = IncomeType.variable),
        ),
        const SizedBox(height: AppTokens.spaceMd),
        _IncomeCard(
          icon: Icons.calendar_month_rounded,
          title: l10n.setupIncomeFixed,
          hint: l10n.setupIncomeFixedHint,
          effect: l10n.setupIncomeFixedResult,
          selected: _incomeType == IncomeType.fixed,
          onTap: () => setState(() => _incomeType = IncomeType.fixed),
        ),
        const SizedBox(height: AppTokens.spaceXxl),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  الخطوة 3: الملخص
  // ─────────────────────────────────────────────────────────────
  Widget _buildSummaryStep(AppLocalizations l10n, ColorScheme scheme) {
    final LocaleState localeState = ref.watch(localeControllerProvider);
    final ThemeMode themeMode = ref.watch(themeControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: AppTokens.spaceLg),
        _StepHeader(
          icon: Icons.verified_rounded,
          title: l10n.setupFinish,
          subtitle: l10n.setupSubtitle,
        ),
        const SizedBox(height: AppTokens.spaceXl),

        _SummaryTile(
          icon: Icons.translate_rounded,
          label: l10n.settingsLanguage,
          value: localeState.languageName,
        ),
        _SummaryTile(
          icon: Icons.palette_outlined,
          label: l10n.settingsTheme,
          value: switch (themeMode) {
            ThemeMode.light => l10n.settingsThemeLight,
            ThemeMode.dark => l10n.settingsThemeDark,
            ThemeMode.system => l10n.settingsThemeSystem,
          },
        ),
        _SummaryTile(
          icon: Icons.payments_outlined,
          label: l10n.settingsBudgetMode,
          value: switch (_incomeType) {
            IncomeType.daily => l10n.setupIncomeDaily,
            IncomeType.variable => l10n.setupIncomeVariable,
            IncomeType.fixed => l10n.setupIncomeFixed,
            null => l10n.settingsBudgetModeMonthly,
          },
        ),
        _SummaryTile(
          icon: Icons.currency_exchange_rounded,
          label: l10n.settingsCurrency,
          value: 'DZD · ${l10n.appName}',
        ),

        const SizedBox(height: AppTokens.spaceXl),

        Container(
          padding: const EdgeInsetsDirectional.all(AppTokens.spaceLg),
          decoration: BoxDecoration(
            color: scheme.secondaryContainer,
            borderRadius: AppTokens.cardRadius,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.tips_and_updates_outlined,
                size: 20,
                color: scheme.onSecondaryContainer,
              ),
              const SizedBox(width: AppTokens.spaceMd),
              Expanded(
                child: Text(
                  l10n.setupSubtitle,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: scheme.onSecondaryContainer,
                    height: 1.65,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.spaceXxl),
      ],
    );
  }
}

/// أنواع الدخل — كل نوع يقترح دورة ميزانية
enum IncomeType {
  /// دخل يومي → ميزانية أسبوعية
  daily,

  /// دخل متغيّر → أسبوعية + شهرية
  variable,

  /// راتب ثابت → شهرية
  fixed;

  BudgetMode get recommendedMode => switch (this) {
        IncomeType.daily => BudgetMode.weekly,
        IncomeType.variable => BudgetMode.both,
        IncomeType.fixed => BudgetMode.monthly,
      };
}

/// رأس الخطوة
class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: AppTokens.fieldRadius,
          ),
          child: Icon(icon, size: 26, color: scheme.onPrimaryContainer),
        ),
        const SizedBox(height: AppTokens.spaceLg),
        Text(
          title,
          style: AppTypography.textTheme.headlineSmall?.copyWith(
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: AppTokens.spaceSm),
        Text(
          subtitle,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.7,
          ),
        ),
      ],
    );
  }
}

/// خيار قابل للاختيار في صف
class _ChoiceOption<T> {
  const _ChoiceOption({
    required this.value,
    required this.label,
    required this.icon,
  });

  final T value;
  final String label;
  final IconData icon;
}

class _ChoiceRow<T> extends StatelessWidget {
  const _ChoiceRow({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<_ChoiceOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: AppTokens.spaceSm,
      runSpacing: AppTokens.spaceSm,
      children: options.map((_ChoiceOption<T> option) {
        final bool isSelected = option.value == selected;
        return Semantics(
          button: true,
          selected: isSelected,
          label: option.label,
          child: InkWell(
            onTap: () => onSelected(option.value),
            borderRadius: AppTokens.cardRadius,
            child: AnimatedContainer(
              duration: AppTokens.motionFast,
              curve: AppTokens.curveStandard,
              constraints: const BoxConstraints(
                minHeight: AppTokens.minTouchTarget,
              ),
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppTokens.spaceLg,
                vertical: AppTokens.spaceMd,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? scheme.primaryContainer
                    : scheme.surfaceContainerLow,
                borderRadius: AppTokens.cardRadius,
                border: Border.all(
                  color: isSelected ? scheme.primary : scheme.outlineVariant,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    option.icon,
                    size: 18,
                    color: isSelected
                        ? scheme.onPrimaryContainer
                        : scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppTokens.spaceSm),
                  Text(
                    option.label,
                    style: AppTypography.textTheme.labelLarge?.copyWith(
                      color: isSelected
                          ? scheme.onPrimaryContainer
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// بطاقة نوع الدخل — تُظهر الأثر الفوري للاختيار
class _IncomeCard extends StatelessWidget {
  const _IncomeCard({
    required this.icon,
    required this.title,
    required this.hint,
    required this.effect,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String hint;
  final String effect;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      selected: selected,
      label: '$title. $hint',
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTokens.cardRadius,
        child: AnimatedContainer(
          duration: AppTokens.motionFast,
          curve: AppTokens.curveStandard,
          padding: const EdgeInsetsDirectional.all(AppTokens.spaceLg),
          decoration: BoxDecoration(
            color: selected ? scheme.primaryContainer : scheme.surfaceContainerLow,
            borderRadius: AppTokens.cardRadius,
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    icon,
                    size: 24,
                    color: selected
                        ? scheme.onPrimaryContainer
                        : scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppTokens.spaceMd),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        color: selected
                            ? scheme.onPrimaryContainer
                            : scheme.onSurface,
                      ),
                    ),
                  ),
                  if (selected)
                    Icon(
                      Icons.check_circle_rounded,
                      size: 22,
                      color: scheme.onPrimaryContainer,
                    ),
                ],
              ),
              const SizedBox(height: AppTokens.spaceXs),
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 40),
                child: Text(
                  hint,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: selected
                        ? scheme.onPrimaryContainer
                        : scheme.onSurfaceVariant,
                  ),
                ),
              ),
              // ⭐ الأثر الفوري — يظهر فقط عند الاختيار
              if (selected) ...<Widget>[
                const SizedBox(height: AppTokens.spaceMd),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 40),
                  child: Container(
                    padding: const EdgeInsetsDirectional.all(AppTokens.spaceMd),
                    decoration: BoxDecoration(
                      color: scheme.surface.withValues(alpha: 0.5),
                      borderRadius: AppTokens.fieldRadius,
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 16,
                          color: scheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: AppTokens.spaceSm),
                        Expanded(
                          child: Text(
                            effect,
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: scheme.onPrimaryContainer,
                              height: 1.55,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// سطر في الملخص
class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsetsDirectional.only(bottom: AppTokens.spaceSm),
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppTokens.spaceLg,
        vertical: AppTokens.spaceMd,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: AppTokens.cardRadius,
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 20, color: scheme.primary),
          const SizedBox(width: AppTokens.spaceMd),
          Expanded(
            child: Text(
              label,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppTokens.spaceSm),
          Flexible(
            child: Text(
              value,
              style: AppTypography.textTheme.labelLarge?.copyWith(
                color: scheme.onSurface,
              ),
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
