import 'package:falousna/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/seed_icons.dart';
import '../../core/theme/typography.dart';
import '../../core/widgets/phase_sheet.dart';
import '../../core/widgets/screen_scaffold.dart';
import '../../core/widgets/social_links_section.dart';
import '../../data/local/local_store.dart';

/// ═══════════════════════════════════════════════════════════════
///  MoreScreen — تبويب «المزيد»
///
///  ⭐ مبدأ الصدق: كل عنصر معطَّل يفتح نافذة تقول في أي مرحلة
///     سيأتي — لا زر ميت ولا ميزة تتظاهر بالعمل.
///
///  العناصر الحقيقية العاملة الآن: الإعدادات · القانوني · حول التطبيق.
/// ═══════════════════════════════════════════════════════════════
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final LocalStore store = ref.watch(localStorageProvider);

    return ScreenScaffold(
      title: l10n.navMore,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // ── حالة الحساب ──
          AppCard(
            child: Row(
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    store.isGuestMode
                        ? Icons.person_outline_rounded
                        : Icons.cloud_done_rounded,
                    color: scheme.onPrimaryContainer,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppTokens.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        store.isGuestMode
                            ? l10n.authGuestBadge
                            : l10n.authUpgradeToAccount,
                        style: AppTypography.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.authGuestLimitNote,
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ═══ تابعنا (تسويق) ═══
          // 🔴 تختفي تلقائياً إن لم تُعدّ أي قناة — صفر روابط ميتة
          const SocialLinksSection(),

          // ═══ أدوات ════
          SectionHeader(
            title: l10n.moreSectionTools,
            icon: Icons.build_outlined,
          ),
          _MoreTile(
            icon: SeedIcons.fromName('goal'),
            title: l10n.moreGoals,
            phase: 2,
            onTap: () => showPhaseSheet(
              context,
              phase: 2,
              title: l10n.moreGoals,
              icon: SeedIcons.fromName('goal'),
            ),
          ),
          _MoreTile(
            icon: SeedIcons.fromName('debt'),
            title: l10n.moreDebts,
            phase: 2,
            onTap: () => showPhaseSheet(
              context,
              phase: 2,
              title: l10n.moreDebts,
              icon: SeedIcons.fromName('debt'),
            ),
          ),
          _MoreTile(
            icon: SeedIcons.fromName('repeat'),
            title: l10n.moreRecurring,
            phase: 2,
            onTap: () => showPhaseSheet(
              context,
              phase: 2,
              title: l10n.moreRecurring,
              icon: SeedIcons.fromName('repeat'),
            ),
          ),
          _MoreTile(
            icon: SeedIcons.fromName('report'),
            title: l10n.moreReports,
            phase: 5,
            onTap: () => showPhaseSheet(
              context,
              phase: 5,
              title: l10n.moreReports,
              icon: SeedIcons.fromName('report'),
            ),
          ),

          // ═══ الحساب ═══
          SectionHeader(
            title: l10n.moreSectionAccount,
            icon: Icons.account_circle_outlined,
          ),
          _MoreTile(
            icon: Icons.workspace_premium_outlined,
            title: l10n.moreSubscription,
            phase: 4,
            onTap: () => showPhaseSheet(
              context,
              phase: 4,
              title: l10n.moreSubscription,
              icon: Icons.workspace_premium_outlined,
              note: l10n.legalSubscriptionBody,
            ),
          ),
          _MoreTile(
            icon: Icons.cloud_sync_rounded,
            title: l10n.authUpgradeToAccount,
            phase: 3,
            onTap: () => showPhaseSheet(
              context,
              phase: 3,
              title: l10n.authCreateAccount,
              icon: Icons.cloud_sync_rounded,
              body: l10n.authComingSoonPhase3,
              note: l10n.settingsSyncRequiresConsent,
            ),
          ),

          // ═══ معلومات ═══
          SectionHeader(
            title: l10n.moreSectionInfo,
            icon: Icons.info_outline_rounded,
          ),
          _MoreTile(
            icon: Icons.settings_outlined,
            title: l10n.settingsTitle,
            onTap: () => context.push(RoutePaths.settings),
          ),
          _MoreTile(
            icon: Icons.gavel_rounded,
            title: l10n.legalTitle,
            onTap: () => context.push(RoutePaths.legal),
          ),
          _MoreTile(
            icon: Icons.info_outline_rounded,
            title: l10n.aboutTitle,
            subtitle: l10n.aboutPhaseLabel,
            onTap: () => context.push(RoutePaths.about),
          ),

          const SizedBox(height: AppTokens.spaceXxl),
        ],
      ),
    );
  }
}

/// عنصر في قائمة «المزيد»
class _MoreTile extends StatelessWidget {
  const _MoreTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.phase,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  /// إن وُجد، تظهر شارة «المرحلة N» — صدق مع المستخدم
  final int? phase;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;

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
                Icon(
                  icon,
                  size: 22,
                  color: phase == null ? scheme.primary : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppTokens.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: AppTypography.textTheme.titleSmall?.copyWith(
                          color: phase == null
                              ? scheme.onSurface
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                      if (subtitle != null) ...<Widget>[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (phase != null)
                  Container(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: AppTokens.spaceSm,
                      vertical: AppTokens.spaceXxs,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius:
                          BorderRadius.circular(AppTokens.radiusFull),
                    ),
                    child: Text(
                      l10n.placeholderPhaseLabel(phase!),
                      style: AppTypography.monoLabel.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
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
