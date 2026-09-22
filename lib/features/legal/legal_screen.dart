import 'package:falousna/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_config.dart';
import '../../core/config/constants.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/external_launcher.dart';
import '../../core/utils/number_format.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/phase_sheet.dart';
import '../../core/widgets/screen_scaffold.dart';
import '../../data/local/local_store.dart';
import 'legal_texts.dart';
import 'policy_sheet.dart';

/// ═══════════════════════════════════════════════════════════════
///  LegalScreen — القانوني والخصوصية
///
///  ⭐ هذه الشاشة جزء من الحماية القانونية (وثيقة 04):
///     1. تعرض **دليل الموافقة**: الإصدار + التاريخ + بصمة SHA-256
///        (ما وافق عليه المستخدم بالضبط، ومتى)
///     2. تعرض الوثائق كاملة، قابلة للنسخ (SelectableText)
///     3. تتيح ممارسة الحقوق الخمسة (المواد 32–37 من القانون 18-07)
///     4. توصل المستخدم بـ ANPDP إن أراد تقديم شكوى
///
///  🔴 لا شيء هنا يعد بما لا يستطيع التطبيق فعله: كل حق غير مفعَّل
///     بعد يعلن مرحلته بوضوح.
/// ═══════════════════════════════════════════════════════════════
class LegalScreen extends ConsumerWidget {
  const LegalScreen({super.key});

  Future<void> _copy(BuildContext context, String value) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool copied =
        (await ExternalLauncher.copyToClipboard(value)).isSuccess;
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(copied ? l10n.legalCopied : l10n.legalCantOpenLink),
        duration: AppTokens.snackBarDuration,
      ),
    );
  }

  Future<void> _openExternal(BuildContext context, Uri uri) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LaunchOutcome outcome = await ExternalLauncher.openOrCopy(uri);
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

  /// 🔴 حق المحو — في وضع الضيف يعني مسح كل ما في الجهاز
  Future<void> _exerciseErasure(BuildContext context, WidgetRef ref) async {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final bool confirmed = await ConfirmDialog.show(
      context,
      title: l10n.settingsEraseConfirmTitle,
      message: '${l10n.legalDeleteAccountNote}\n\n${l10n.settingsEraseConfirmBody}',
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
      context.go(RoutePaths.onboarding);
    } on Exception catch (error) {
      if (!context.mounted) return;
      debugPrint('⚠️ فشل تنفيذ حق المحو: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorGenericBody),
          duration: AppTokens.snackBarDuration,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final LocalStore store = ref.watch(localStorageProvider);

    return ScreenScaffold(
      title: l10n.legalTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // ═══ دليل الموافقة ═══
          SectionHeader(
            title: l10n.legalMyConsents,
            subtitle: l10n.legalConsentRecorded,
            icon: Icons.verified_user_outlined,
          ),
          if (store.hasPrivacyConsent)
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _RecordRow(
                    label: l10n.legalConsentVersion,
                    value: store.consentPolicyVersion ??
                        AppConstants.privacyPolicyVersion,
                    current: store.isConsentCurrent,
                  ),
                  _RecordRow(
                    label: l10n.legalConsentDate,
                    value: store.consentGrantedAt == null
                        ? '—'
                        : AppNumberFormat.formatDateTime(
                            context,
                            store.consentGrantedAt!,
                          ),
                  ),
                  const SizedBox(height: AppTokens.spaceSm),
                  Text(
                    l10n.legalConsentHash,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppTokens.spaceXs),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: SelectableText(
                          store.consentHash ?? '—',
                          style: AppTypography.monoSmall.copyWith(
                            color: scheme.onSurface,
                            height: 1.5,
                          ),
                        ),
                      ),
                      if (store.consentHash != null)
                        AppIconButtonSmall(
                          icon: Icons.copy_rounded,
                          tooltip: l10n.legalCopyAction,
                          onPressed: () => _copy(context, store.consentHash!),
                        ),
                    ],
                  ),
                  if (!store.isConsentCurrent) ...<Widget>[
                    const SizedBox(height: AppTokens.spaceMd),
                    InfoBanner(
                      icon: Icons.gpp_maybe_outlined,
                      message: l10n.consentMustAccept,
                      tone: InfoBannerTone.warning,
                    ),
                  ],
                ],
              ),
            )
          else
            InfoBanner(
              icon: Icons.gpp_maybe_outlined,
              message: l10n.legalNoConsentYet,
              tone: InfoBannerTone.warning,
            ),

          const SizedBox(height: AppTokens.spaceMd),
          InfoBanner(
            icon: Icons.smartphone_rounded,
            message: l10n.legalDataOnDevice,
            tone: InfoBannerTone.success,
          ),

          // ═══ الوثائق ═══
          SectionHeader(
            title: l10n.settingsSectionLegal,
            icon: Icons.description_outlined,
          ),
          _DocTile(
            icon: Icons.privacy_tip_outlined,
            title: l10n.legalPrivacy,
            version: l10n.consentVersionLabel(AppConstants.privacyPolicyVersion),
            onTap: () => showPolicySheet(
              context,
              title: l10n.legalPrivacy,
              version:
                  l10n.consentVersionLabel(AppConstants.privacyPolicyVersion),
              body: LegalTexts.privacy(l10n),
            ),
          ),
          _DocTile(
            icon: Icons.description_outlined,
            title: l10n.legalTerms,
            version: l10n.consentVersionLabel(AppConstants.termsVersion),
            onTap: () => showPolicySheet(
              context,
              title: l10n.legalTerms,
              version: l10n.consentVersionLabel(AppConstants.termsVersion),
              body: LegalTexts.terms(l10n),
            ),
          ),
          _DocTile(
            icon: Icons.warning_amber_rounded,
            title: l10n.legalDisclaimer,
            version: l10n.consentVersionLabel(AppConstants.termsVersion),
            onTap: () => showPolicySheet(
              context,
              title: l10n.legalDisclaimer,
              version: l10n.consentVersionLabel(AppConstants.termsVersion),
              body: LegalTexts.disclaimer(l10n),
            ),
          ),
          _DocTile(
            icon: Icons.workspace_premium_outlined,
            title: l10n.legalSubscription,
            version: l10n.consentVersionLabel(
              AppConstants.subscriptionTermsVersion,
            ),
            onTap: () => showPolicySheet(
              context,
              title: l10n.legalSubscription,
              version: l10n.consentVersionLabel(
                AppConstants.subscriptionTermsVersion,
              ),
              body: LegalTexts.subscription(l10n),
            ),
          ),

          // ═══ الحقوق الخمسة ═══
          SectionHeader(
            title: l10n.legalRightsTitle,
            subtitle: l10n.legalRightsBody,
            icon: Icons.balance_rounded,
          ),
          _RightTile(
            icon: Icons.file_download_outlined,
            title: l10n.legalExportData,
            note: l10n.legalExportDataNote,
            onTap: () => showPhaseSheet(
              context,
              phase: 2,
              title: l10n.legalExportData,
              icon: Icons.file_download_outlined,
              note: l10n.legalExportDataNote,
            ),
          ),
          _RightTile(
            icon: Icons.edit_note_rounded,
            title: l10n.legalRectifyData,
            note: l10n.legalComingSoon,
            onTap: () => showPhaseSheet(
              context,
              phase: 4,
              title: l10n.legalRectifyData,
              icon: Icons.edit_note_rounded,
              body: l10n.legalComingSoon,
              note: l10n.legalDpoContact,
            ),
          ),
          _RightTile(
            icon: Icons.block_rounded,
            title: l10n.legalObjectData,
            note: l10n.settingsSyncRequiresConsent,
            onTap: () => showPhaseSheet(
              context,
              phase: 4,
              title: l10n.legalObjectData,
              icon: Icons.block_rounded,
              body: l10n.legalComingSoon,
              note: l10n.settingsSyncRequiresConsent,
            ),
          ),
          _RightTile(
            icon: Icons.delete_forever_rounded,
            title: l10n.legalDeleteAccount,
            note: l10n.legalDeleteAccountNote,
            destructive: true,
            onTap: () => _exerciseErasure(context, ref),
          ),

          // ═══ الاتصال والجهة الرقابية ═══
          SectionHeader(
            title: l10n.legalDpoContact,
            icon: Icons.mail_outline_rounded,
          ),
          _LinkTile(
            icon: Icons.mail_outline_rounded,
            title: AppConfig.dpoEmail,
            subtitle: l10n.legalDpoContact,
            onTap: () => _openExternal(
              context,
              AppConfig.dpoMailtoUri(
                subject: l10n.legalRightsTitle,
              ),
            ),
            onCopy: () => _copy(context, AppConfig.dpoEmail),
          ),
          _LinkTile(
            icon: Icons.gavel_rounded,
            title: l10n.legalComplaintAnpdp,
            subtitle: AppConstants.anpdpComplaintUrl,
            onTap: () => _openExternal(context, AppConfig.anpdpComplaintUri),
            onCopy: () => _copy(context, AppConstants.anpdpComplaintUrl),
          ),

          const SizedBox(height: AppTokens.spaceXxl),
        ],
      ),
    );
  }
}

/// سطر في بطاقة دليل الموافقة
class _RecordRow extends StatelessWidget {
  const _RecordRow({
    required this.label,
    required this.value,
    this.current = true,
  });

  final String label;
  final String value;

  /// هل الإصدار هو الجاري الآن؟ (إن لا → تظهر علامة تنبيه)
  final bool current;

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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                value,
                style: AppTypography.monoSmall.copyWith(
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(width: AppTokens.spaceXs),
              Icon(
                current ? Icons.check_circle_rounded : Icons.error_rounded,
                size: 16,
                color: current ? scheme.primary : scheme.error,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// زر أيقوني صغير (32dp داخل هدف لمس 48dp)
class AppIconButtonSmall extends StatelessWidget {
  const AppIconButtonSmall({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onPressed();
          },
          borderRadius: AppTokens.fieldRadius,
          child: SizedBox(
            width: AppTokens.minTouchTarget,
            height: 40,
            child: Icon(icon, size: 18, color: scheme.primary),
          ),
        ),
      ),
    );
  }
}

/// سطر وثيقة قانونية
class _DocTile extends StatelessWidget {
  const _DocTile({
    required this.icon,
    required this.title,
    required this.version,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String version;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
                Icon(icon, size: 20, color: scheme.primary),
                const SizedBox(width: AppTokens.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(title, style: AppTypography.textTheme.titleSmall),
                      const SizedBox(height: 2),
                      Text(
                        version,
                        style: AppTypography.monoLabel.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.open_in_new_rounded,
                  size: 16,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// سطر حق من حقوق المستخدم
class _RightTile extends StatelessWidget {
  const _RightTile({
    required this.icon,
    required this.title,
    required this.note,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String note;
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
            padding: const EdgeInsetsDirectional.all(AppTokens.spaceLg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(icon, size: 20, color: accent),
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
                      const SizedBox(height: 2),
                      Text(
                        note,
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.55,
                        ),
                      ),
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

/// سطر رابط خارجي (بريد أو موقع) مع زر نسخ
class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.onCopy,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
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
                Icon(icon, size: 20, color: scheme.primary),
                const SizedBox(width: AppTokens.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(title, style: AppTypography.textTheme.titleSmall),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTypography.monoLabel.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                AppIconButtonSmall(
                  icon: Icons.copy_rounded,
                  tooltip: AppLocalizations.of(context).legalCopyAction,
                  onPressed: onCopy,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
