import 'package:falousna/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_config.dart';
import '../../core/config/constants.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/external_launcher.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/screen_scaffold.dart';
import '../../core/widgets/social_links_section.dart';

/// ═══════════════════════════════════════════════════════════════
///  AboutScreen — حول التطبيق
///
///  ⭐ تعرض حالة البناء الحقيقية (draft/live) حتى يعرف المالك أثناء
///     الاختبار إن كان التطبيق يجمع بيانات أم لا — شفافية داخلية
///     قبل الشفافية الخارجية.
/// ═══════════════════════════════════════════════════════════════
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  void _showLicenses(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: '${AppConstants.appName} — ${AppConstants.appNameLatin}',
      applicationVersion:
          '${AppConstants.version} (${AppConstants.buildNumber})',
    );
  }

  Future<void> _checkUpdate(BuildContext context) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LaunchOutcome outcome =
        await ExternalLauncher.openOrCopy(AppConfig.downloadSiteUri);
    if (!context.mounted || outcome == LaunchOutcome.opened) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          outcome == LaunchOutcome.copied
              ? l10n.legalCopied
              : l10n.legalCantOpenLink,
        ),
        duration: AppTokens.snackBarDuration,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return ScreenScaffold(
      title: l10n.aboutTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: AppTokens.spaceLg),

          // ── الهوية ──
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: AppTokens.cardRadius,
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                size: 44,
                color: scheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: AppTokens.spaceLg),
          Text(
            '${AppConstants.appName} · ${AppConstants.appNameLatin}',
            style: AppTypography.textTheme.headlineSmall?.copyWith(
              color: scheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTokens.spaceXs),
          Text(
            l10n.appTagline,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTokens.spaceXs),
          // ── اعتماد الاستوديو المطوّر ──
          Text(
            l10n.creditDeveloper,
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppTokens.spaceXl),

          InfoBanner(
            icon: Icons.smartphone_rounded,
            message: l10n.aboutDataLocalNote,
            tone: InfoBannerTone.success,
          ),
          const SizedBox(height: AppTokens.spaceMd),
          InfoBanner(
            icon: Icons.block_rounded,
            message: l10n.aboutNoBrandsNote,
            tone: InfoBannerTone.info,
          ),
          const SizedBox(height: AppTokens.spaceMd),
          // ── قنوات التواصل الرسمية (تختفي إن لم تُعدّ) ──
          const SocialLinksSection(),

          // ── ماذا يفعل التطبيق ──
          SectionHeader(
            title: l10n.legalDisclaimer,
            icon: Icons.info_outline_rounded,
          ),
          AppCard(
            child: Text(
              l10n.aboutAppDescription,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.75,
              ),
            ),
          ),

          // ── الإصدار وحالة البناء ──
          SectionHeader(
            title: l10n.aboutVersion,
            icon: Icons.numbers_rounded,
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _InfoRow(label: l10n.aboutVersion, value: AppConstants.version),
                _InfoRow(
                  label: l10n.aboutBuild,
                  value: '${AppConstants.buildNumber}',
                ),
                _InfoRow(label: 'ID', value: AppConstants.packageId),
                _InfoRow(
                  label: l10n.aboutPhaseLabel,
                  value: AppConfig.releaseState,
                ),
                const Divider(height: AppTokens.spaceXl),
                // حالة البناء التقنية — للمالك أثناء الاختبار
                ...AppConfig.debugSummary().entries.map(
                      (MapEntry<String, String> entry) => _InfoRow(
                        label: entry.key,
                        value: entry.value,
                        mono: true,
                      ),
                    ),
              ],
            ),
          ),

          const SizedBox(height: AppTokens.spaceXl),

          AppButton(
            label: l10n.aboutLicenses,
            icon: Icons.source_outlined,
            onPressed: () => _showLicenses(context),
            variant: AppButtonVariant.outlined,
            expandWidth: true,
          ),
          const SizedBox(height: AppTokens.spaceMd),
          AppButton(
            label: l10n.aboutCheckUpdate,
            icon: Icons.system_update_alt_rounded,
            onPressed: () => _checkUpdate(context),
            variant: AppButtonVariant.tonal,
            expandWidth: true,
          ),
          const SizedBox(height: AppTokens.spaceMd),
          AppButton(
            label: l10n.legalTitle,
            icon: Icons.gavel_rounded,
            onPressed: () => context.push(RoutePaths.legal),
            variant: AppButtonVariant.text,
            expandWidth: true,
          ),

          const SizedBox(height: AppTokens.spaceXxl),
        ],
      ),
    );
  }
}

/// سطر معلومة (اسم: قيمة)
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.mono = false,
  });

  final String label;
  final String value;

  /// القيم التقنية بخط Mono لاتينية الاتجاه
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppTokens.spaceSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppTokens.spaceSm),
          Flexible(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                value,
                style: (mono ? AppTypography.monoSmall : AppTypography.monoLabel)
                    .copyWith(color: scheme.onSurface),
                textAlign: TextAlign.end,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
