import 'package:falousna/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/constants.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/clock_guard.dart';
import '../../core/utils/period_resolver.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/screen_scaffold.dart';
import '../../data/local/local_store.dart';
import 'budget_limits_section.dart';

/// ═══════════════════════════════════════════════════════════════
///  BudgetScreen — الميزانية
///
///  ✅ ما يعمل فعلاً في المرحلة 1 (ويُحفَظ في الجهاز):
///     - دورة الميزانية: أسبوعية / شهرية / الاثنتان
///     - يوم بداية الشهر المالي (1–28) — لموظف يقبض يوم 25 مثلاً
///     - الفترة الحالية تُحسب عبر `PeriodResolver` (مصدر واحد)
///
///  ⭐ م2.2 (يعمل الآن): السقوف الفعلية لكل تصنيف + سقف عام،
///     نسبة الاستهلاك، الباقي/التجاوز، وتنبيه عند نسبة يختارها
///     المستخدم — كلها من قاعدة البيانات وتُحدَّث فوراً.
/// ═══════════════════════════════════════════════════════════════
class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  Future<void> _setMode(
    BuildContext context,
    WidgetRef ref,
    BudgetMode mode,
  ) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LocalStore store = ref.read(localStorageProvider);
    await store.setBudgetMode(mode);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.settingsSaved),
        duration: AppTokens.snackBarDuration,
      ),
    );
  }

  Future<void> _setAnchorDay(
    BuildContext context,
    WidgetRef ref,
    int day,
  ) async {
    // ⚠️ تحقق مزدوج: لا نكتب قيمة خارج النطاق أبداً
    if (!Validators.isValidFiscalAnchorDay(day)) return;
    final LocalStore store = ref.read(localStorageProvider);
    await store.setFiscalAnchorDay(day);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final LocalStore store = ref.watch(localStorageProvider);

    final BudgetMode mode = store.budgetMode;
    final int anchorDay = store.fiscalAnchorDay;
    // ⭐ الوقت من حارس الساعة (مقاومة التلاعب)
    final PeriodResolution period = PeriodResolver.resolve(
      now: ref.watch(clockGuardProvider).trustedNow(),
      mode: mode,
      anchorDay: anchorDay,
    );

    return ScreenScaffold(
      title: l10n.navBudget,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // ── الفترة الحالية ──
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.homeThisPeriod,
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppTokens.spaceSm),
                ...period.all.map(
                  (FiscalPeriod item) => Padding(
                    padding: const EdgeInsetsDirectional.only(
                      bottom: AppTokens.spaceXs,
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          item.mode == BudgetMode.weekly
                              ? Icons.date_range_rounded
                              : Icons.calendar_month_rounded,
                          size: 16,
                          color: scheme.primary,
                        ),
                        const SizedBox(width: AppTokens.spaceSm),
                        Expanded(
                          child: Text(
                            _periodLabel(context, item),
                            style: AppTypography.monoSmall.copyWith(
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                        Text(
                          l10n.dayCountLabel(item.lengthDays),
                          style: AppTypography.monoLabel.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── دورة الميزانية ──
          SectionHeader(
            title: l10n.settingsBudgetMode,
            subtitle: l10n.settingsBudgetModeHint,
            icon: Icons.autorenew_rounded,
          ),
          SegmentedButton<BudgetMode>(
            segments: <ButtonSegment<BudgetMode>>[
              ButtonSegment<BudgetMode>(
                value: BudgetMode.weekly,
                label: Text(l10n.settingsBudgetModeWeekly),
              ),
              ButtonSegment<BudgetMode>(
                value: BudgetMode.monthly,
                label: Text(l10n.settingsBudgetModeMonthly),
              ),
              ButtonSegment<BudgetMode>(
                value: BudgetMode.both,
                label: Text(l10n.settingsBudgetModeBoth),
              ),
            ],
            selected: <BudgetMode>{mode},
            onSelectionChanged: (Set<BudgetMode> selection) =>
                _setMode(context, ref, selection.first),
            showSelectedIcon: false,
            style: const ButtonStyle(
              minimumSize: WidgetStatePropertyAll<Size>(
                Size(0, AppTokens.minTouchTarget),
              ),
            ),
          ),

          // ── يوم بداية الشهر المالي ──
          if (mode != BudgetMode.weekly) ...<Widget>[
            SectionHeader(
              title: l10n.settingsFiscalAnchor,
              subtitle: l10n.settingsFiscalAnchorHint,
              icon: Icons.event_rounded,
            ),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '$anchorDay',
                        style: AppTypography.monoDisplay.copyWith(
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(width: AppTokens.spaceSm),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          bottom: AppTokens.spaceSm,
                        ),
                        child: Text(
                          l10n.settingsFiscalAnchor,
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: anchorDay.toDouble().clamp(
                          AppConstants.minFiscalAnchorDay.toDouble(),
                          AppConstants.maxFiscalAnchorDay.toDouble(),
                        ),
                    min: AppConstants.minFiscalAnchorDay.toDouble(),
                    max: AppConstants.maxFiscalAnchorDay.toDouble(),
                    divisions: AppConstants.maxFiscalAnchorDay -
                        AppConstants.minFiscalAnchorDay,
                    label: '$anchorDay',
                    onChanged: (double value) =>
                        _setAnchorDay(context, ref, value.round()),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        '${AppConstants.minFiscalAnchorDay}',
                        style: AppTypography.monoLabel.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${AppConstants.maxFiscalAnchorDay}',
                        style: AppTypography.monoLabel.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          // ── السقوف: بيانات حقيقية من قاعدة البيانات (م2.2) ──
          BudgetLimitsSection(period: period.primary),

          const SizedBox(height: AppTokens.spaceXxl),
          const SizedBox(height: AppTokens.fabSize),
        ],
      ),
    );
  }

  String _periodLabel(BuildContext context, FiscalPeriod item) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String modeName = switch (item.mode) {
      BudgetMode.weekly => l10n.settingsBudgetModeWeekly,
      BudgetMode.monthly => l10n.settingsBudgetModeMonthly,
      BudgetMode.both => l10n.settingsBudgetModeBoth,
    };
    return '$modeName · ${item.start.day}/${item.start.month} — '
        '${item.end.day}/${item.end.month}';
  }

}
