import 'package:falousna/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/constants.dart';
import '../../core/l10n/locale_controller.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/period_resolver.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/phase_sheet.dart';
import '../../core/widgets/screen_scaffold.dart';
import '../../data/local/local_store.dart';

/// ═══════════════════════════════════════════════════════════════
///  SettingsScreen — الإعدادات
///
///  ✅ ما يعمل ويُحفَز فعلاً في المرحلة 1:
///     المظهر · اللغة · دورة الميزانية · يوم بداية الشهر المالي ·
///     حذف كل البيانات (مع عدّ تنازلي).
///
///  🟡 معطَّل بصدق (لا مفاتيح وهمية):
///     التنبيهات (المرحلة 5) · المزامنة (المرحلة 3) · النسخة
///     الاحتياطية (المرحلة 2) · أسعار الصرف (المرحلة 2).
///     كل عنصر معطَّل يعرض سبب التعطيل ورقم المرحلة.
/// ═══════════════════════════════════════════════════════════════
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _setTheme(WidgetRef ref, ThemeMode mode) =>
      ref.read(themeControllerProvider.notifier).setMode(mode);

  Future<void> _setLanguage(WidgetRef ref, String? code) async {
    final LocaleController controller =
        ref.read(localeControllerProvider.notifier);
    if (code == null) {
      await controller.followSystem();
      return;
    }
    await controller.setLocale(Locale(code, 'DZ'));
  }

  Future<void> _setBudgetMode(
    BuildContext context,
    WidgetRef ref,
    BudgetMode mode,
  ) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    await ref.read(localStorageProvider).setBudgetMode(mode);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.settingsSaved),
        duration: AppTokens.snackBarDuration,
      ),
    );
  }

  Future<void> _setAnchorDay(WidgetRef ref, int day) async {
    if (!Validators.isValidFiscalAnchorDay(day)) return;
    await ref.read(localStorageProvider).setFiscalAnchorDay(day);
  }

  /// 🔴 حذف كل البيانات — إجراء مدمّر بعدّ تنازلي
  Future<void> _eraseEverything(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final bool confirmed = await ConfirmDialog.show(
      context,
      title: l10n.settingsEraseConfirmTitle,
      message: l10n.settingsEraseConfirmBody,
      confirmLabel: l10n.actionDelete,
      icon: Icons.delete_forever_rounded,
      destructive: true,
      requireCountdown: true,
      countdownSeconds: 10,
    );
    if (!confirmed || !context.mounted) return;

    try {
      await ref.read(localStorageProvider).eraseEverything();
      refreshNavigation(ref);
      if (!context.mounted) return;
      // بعد المسح يعود التطبيق إلى نقطة الصفر
      context.go(RoutePaths.onboarding);
    } on Exception catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorGenericBody),
          duration: AppTokens.snackBarDuration,
        ),
      );
      debugPrint('⚠️ فشل مسح البيانات: $error');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final LocalStore store = ref.watch(localStorageProvider);
    final ThemeMode themeMode = ref.watch(themeControllerProvider);
    final LocaleState localeState = ref.watch(localeControllerProvider);
    final BudgetMode budgetMode = store.budgetMode;

    return ScreenScaffold(
      title: l10n.settingsTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // ═══ المظهر واللغة ═══
          SectionHeader(
            title: l10n.settingsSectionAppearance,
            icon: Icons.palette_outlined,
          ),
          _SettingLabel(text: l10n.settingsTheme),
          SegmentedButton<ThemeMode>(
            segments: <ButtonSegment<ThemeMode>>[
              ButtonSegment<ThemeMode>(
                value: ThemeMode.system,
                label: Text(l10n.settingsThemeSystem),
                icon: const Icon(Icons.brightness_auto_rounded, size: 16),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.light,
                label: Text(l10n.settingsThemeLight),
                icon: const Icon(Icons.light_mode_rounded, size: 16),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.dark,
                label: Text(l10n.settingsThemeDark),
                icon: const Icon(Icons.dark_mode_rounded, size: 16),
              ),
            ],
            selected: <ThemeMode>{themeMode},
            onSelectionChanged: (Set<ThemeMode> selection) =>
                _setTheme(ref, selection.first),
            showSelectedIcon: false,
            style: const ButtonStyle(
              minimumSize: WidgetStatePropertyAll<Size>(
                Size(0, AppTokens.minTouchTarget),
              ),
            ),
          ),
          const SizedBox(height: AppTokens.spaceLg),
          _SettingLabel(text: l10n.settingsLanguage),
          SegmentedButton<String>(
            segments: <ButtonSegment<String>>[
              ButtonSegment<String>(
                value: 'system',
                label: Text(l10n.settingsLanguageSystem),
              ),
              // ⭐ أسماء اللغات تُكتب بلغتها هي (عرف عالمي) — لا تُترجم
              ButtonSegment<String>(value: 'ar', label: const Text('العربية')),
              ButtonSegment<String>(value: 'fr', label: const Text('Français')),
            ],
            selected: <String>{
              localeState.followsSystem
                  ? 'system'
                  : localeState.effective.languageCode,
            },
            onSelectionChanged: (Set<String> selection) => _setLanguage(
              ref,
              selection.first == 'system' ? null : selection.first,
            ),
            showSelectedIcon: false,
            style: const ButtonStyle(
              minimumSize: WidgetStatePropertyAll<Size>(
                Size(0, AppTokens.minTouchTarget),
              ),
            ),
          ),

          // ═══ الأموال والفترات ═══
          SectionHeader(
            title: l10n.settingsSectionMoney,
            icon: Icons.payments_outlined,
          ),
          _SettingLabel(
            text: l10n.settingsBudgetMode,
            hint: l10n.settingsBudgetModeHint,
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
            selected: <BudgetMode>{budgetMode},
            onSelectionChanged: (Set<BudgetMode> selection) =>
                _setBudgetMode(context, ref, selection.first),
            showSelectedIcon: false,
            style: const ButtonStyle(
              minimumSize: WidgetStatePropertyAll<Size>(
                Size(0, AppTokens.minTouchTarget),
              ),
            ),
          ),
          if (budgetMode != BudgetMode.weekly) ...<Widget>[
            const SizedBox(height: AppTokens.spaceLg),
            _SettingLabel(
              text: l10n.settingsFiscalAnchor,
              hint: l10n.settingsFiscalAnchorHint,
            ),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${store.fiscalAnchorDay}',
                    style: AppTypography.monoLarge.copyWith(
                      color: scheme.primary,
                    ),
                  ),
                  Slider(
                    value: store.fiscalAnchorDay.toDouble().clamp(
                          AppConstants.minFiscalAnchorDay.toDouble(),
                          AppConstants.maxFiscalAnchorDay.toDouble(),
                        ),
                    min: AppConstants.minFiscalAnchorDay.toDouble(),
                    max: AppConstants.maxFiscalAnchorDay.toDouble(),
                    divisions: AppConstants.maxFiscalAnchorDay -
                        AppConstants.minFiscalAnchorDay,
                    label: '${store.fiscalAnchorDay}',
                    onChanged: (double value) =>
                        _setAnchorDay(ref, value.round()),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppTokens.spaceMd),
          _SettingTile(
            icon: Icons.currency_exchange_rounded,
            title: l10n.settingsCurrency,
            subtitle: '${l10n.settingsCurrencyHint} · ${store.baseCurrency}',
            onTap: () => showPhaseSheet(
              context,
              phase: 2,
              title: l10n.settingsCurrency,
              icon: Icons.currency_exchange_rounded,
              note: l10n.settingsCurrencyHint,
            ),
          ),
          _SettingTile(
            icon: Icons.show_chart_rounded,
            title: l10n.settingsExchangeRates,
            subtitle: l10n.placeholderBody('2'),
            onTap: () => showPhaseSheet(
              context,
              phase: 2,
              title: l10n.settingsExchangeRates,
              icon: Icons.show_chart_rounded,
            ),
          ),

          // ═══ التنبيهات (معطّلة بصدق) ═══
          SectionHeader(
            title: l10n.settingsSectionNotifications,
            icon: Icons.notifications_outlined,
          ),
          InfoBanner(
            icon: Icons.schedule_rounded,
            message: l10n.settingsNotificationsNote,
            tone: InfoBannerTone.neutral,
          ),
          const SizedBox(height: AppTokens.spaceSm),
          _DisabledSwitchTile(
            title: l10n.settingsNotificationsDaily,
            icon: Icons.edit_notifications_outlined,
          ),
          _DisabledSwitchTile(
            title: l10n.settingsNotificationsBudget,
            icon: Icons.warning_amber_rounded,
          ),
          _DisabledSwitchTile(
            title: l10n.settingsNotificationsDebts,
            icon: Icons.event_busy_rounded,
          ),

          // ═══ البيانات والمزامنة ═══
          SectionHeader(
            title: l10n.settingsSectionData,
            icon: Icons.storage_outlined,
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.cloud_off_rounded,
                      size: 20,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppTokens.spaceMd),
                    Expanded(
                      child: Text(
                        l10n.settingsSync,
                        style: AppTypography.textTheme.titleSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.spaceSm),
                Text(
                  l10n.settingsSyncOff,
                  style: AppTypography.monoSmall.copyWith(
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: AppTokens.spaceXs),
                Text(
                  '${l10n.settingsSyncRequiresConsent}\n${l10n.settingsSyncNote}',
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.spaceMd),
          _SettingTile(
            icon: Icons.backup_outlined,
            title: l10n.settingsBackup,
            subtitle: l10n.placeholderBody('2'),
            onTap: () => showPhaseSheet(
              context,
              phase: 2,
              title: l10n.settingsBackup,
              icon: Icons.backup_outlined,
            ),
          ),
          _SettingTile(
            icon: Icons.delete_forever_rounded,
            title: l10n.settingsEraseAll,
            subtitle: l10n.settingsEraseAllNote,
            destructive: true,
            onTap: () => _eraseEverything(context, ref),
          ),

          // ═══ الفئات ═══
          SectionHeader(
            title: l10n.catMgrTitle,
            icon: Icons.category_outlined,
          ),
          _SettingTile(
            icon: Icons.edit_note_rounded,
            title: l10n.settingsCatMgr,
            subtitle: l10n.settingsCatMgrNote,
            onTap: () => context.push(RoutePaths.categories),
          ),

          // ═══ القانوني ═══
          SectionHeader(
            title: l10n.settingsSectionLegal,
            icon: Icons.gavel_rounded,
          ),
          _SettingTile(
            icon: Icons.privacy_tip_outlined,
            title: l10n.legalTitle,
            subtitle: l10n.legalRightsTitle,
            onTap: () => context.push(RoutePaths.legal),
          ),

          // ═══ حول التطبيق ═══
          SectionHeader(
            title: l10n.settingsSectionAbout,
            icon: Icons.info_outline_rounded,
          ),
          _SettingTile(
            icon: Icons.info_outline_rounded,
            title: l10n.aboutTitle,
            subtitle: '${l10n.aboutVersion} ${AppConstants.version}',
            onTap: () => context.push(RoutePaths.about),
          ),

          const SizedBox(height: AppTokens.spaceXxl),
          AppButton(
            label: l10n.actionClose,
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(RoutePaths.more);
              }
            },
            variant: AppButtonVariant.outlined,
            expandWidth: true,
          ),
          const SizedBox(height: AppTokens.spaceXxl),
        ],
      ),
    );
  }
}

/// عنوان إعداد صغير
class _SettingLabel extends StatelessWidget {
  const _SettingLabel({required this.text, this.hint});

  final String text;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppTokens.spaceSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            text,
            style: AppTypography.textTheme.titleSmall?.copyWith(
              color: scheme.onSurface,
            ),
          ),
          if (hint != null) ...<Widget>[
            const SizedBox(height: 2),
            Text(
              hint!,
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.55,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// سطر إعداد قابل للنقر
class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color accent = destructive ? scheme.error : scheme.primary;

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppTokens.spaceSm),
      child: Material(
        color: scheme.surfaceContainerLow,
        borderRadius: AppTokens.cardRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppTokens.cardRadius,
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppTokens.spaceLg,
              vertical: AppTokens.spaceMd,
            ),
            child: Row(
              children: <Widget>[
                Icon(icon, size: 22, color: accent),
                const SizedBox(width: AppTokens.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: AppTypography.textTheme.titleSmall?.copyWith(
                          color: destructive ? scheme.error : scheme.onSurface,
                        ),
                      ),
                      if (subtitle != null) ...<Widget>[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// سطر بمفتاح معطّل — ⚠️ لا يوحي بأن الميزة تعمل
class _DisabledSwitchTile extends StatelessWidget {
  const _DisabledSwitchTile({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppTokens.spaceSm),
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppTokens.spaceLg,
          vertical: AppTokens.spaceSm,
        ),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow.withValues(alpha: 0.6),
          borderRadius: AppTokens.cardRadius,
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 20, color: scheme.onSurfaceVariant),
            const SizedBox(width: AppTokens.spaceMd),
            Expanded(
              child: Text(
                title,
                style: AppTypography.textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            Semantics(
              label: title,
              enabled: false,
              toggled: false,
              child: Switch(
                value: false,
                onChanged: null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
