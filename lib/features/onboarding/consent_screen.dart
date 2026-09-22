import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:falousna/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/constants.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../data/local/local_store.dart';
import '../legal/legal_texts.dart';
import '../legal/policy_sheet.dart';

/// ═══════════════════════════════════════════════════════════════
///  ConsentScreen — الموافقة القانونية (القانون 18-07 م.7)
///
///  🔴 هذه أهم شاشة قانونياً في التطبيق كله.
///
///  ✅ القواعد المطبَّقة (راجع docs/04-خطة-الحماية-القانونية.md):
///     1. حاجز حقيقي — barrierDismissible = false، لا زر رجوع
///     2. الصندوق **غير مُعلَّم مسبقاً** (pre-checked = موافقة باطلة)
///     3. ملخص 3 نقاط **قبل** النص الكامل (شفافية فعلية لا شكلية)
///     4. زر «أرفض وأخرج» واضح ومساوٍ بصرياً — الرفض سهل كالقبول
///     5. ⭐ تسجيل بصمة SHA-256 لنص السياسة لحظة الموافقة
///        (consent_hash) — هذا **دليلك المادي** في أي نزاع
///     6. تسجيل التاريخ والوقت والإصدار — يُزامَن لـ consent_logs
///        في المرحلة 3
///     7. **لا يُجمع أي حرف قبل الموافقة** — ولا حتى device_id
///
///  ⚠️ الموافقة على «النقل خارج الوطن» (المزامنة السحابية)
///     **ليست هنا** — بل موافقة منفصلة في الإعدادات (المرحلة 3).
///     تجميع الموافقات في صندوق واحد = موافقة باطلة قانوناً.
/// ═══════════════════════════════════════════════════════════════
class ConsentScreen extends ConsumerStatefulWidget {
  const ConsentScreen({super.key});

  @override
  ConsumerState<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends ConsumerState<ConsentScreen> {
  bool _accepted = false;
  bool _saving = false;

  /// نص السياسة المُجزَّم — تُحسب بصمته ليُثبَّت ما وافق عليه المستخدم
  ///
  /// ⚠️ عند تعديل أي كلمة في السياسة: ارفع `privacyPolicyVersion`
  ///    في constants.dart، وسيلزم إعادة الموافقة من كل المستخدمين.
  String _buildPolicyDigest(AppLocalizations l10n) {
    return <String>[
      'APP=${AppConstants.appNameLatin}',
      'POLICY_VERSION=${AppConstants.privacyPolicyVersion}',
      'TERMS_VERSION=${AppConstants.termsVersion}',
      'TITLE=${l10n.consentTitle}',
      'P1T=${l10n.consentPoint1Title}',
      'P1B=${l10n.consentPoint1Body}',
      'P2T=${l10n.consentPoint2Title}',
      'P2B=${l10n.consentPoint2Body}',
      'P3T=${l10n.consentPoint3Title}',
      'P3B=${l10n.consentPoint3Body}',
      'CHECKBOX=${l10n.consentCheckboxLabel}',
      'NOTE=${l10n.consentRecordedNote}',
    ].join('|');
  }

  /// يحسب بصمة SHA-256 سداسية عشرية (64 محرفاً)
  String _sha256Of(String text) {
    final List<int> bytes = utf8.encode(text);
    return sha256.convert(bytes).toString();
  }

  Future<void> _accept() async {
    if (!_accepted || _saving) return;

    setState(() => _saving = true);
    try {
      final AppLocalizations l10n = AppLocalizations.of(context);
      final String digest = _buildPolicyDigest(l10n);
      final String hash = _sha256Of(digest);

      final LocalStore store = ref.read(localStorageProvider);
      await store.grantPrivacyConsent(policyHash: hash);

      refreshNavigation(ref);
      if (!mounted) return;
      context.go(RoutePaths.authChoose);
    } on Exception {
      // 🔴 فشل الحفظ = لا ننتقل. نوضح للمستخدم بلطف.
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

  Future<void> _decline() async {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final bool confirmed = await ConfirmDialog.show(
      context,
      title: l10n.consentDeclineTitle,
      message: l10n.consentDeclineBody,
      confirmLabel: l10n.consentDeclineConfirm,
      cancelLabel: l10n.consentDeclineCancel,
      icon: Icons.logout_rounded,
      destructive: true,
    );

    if (!confirmed || !mounted) return;

    // إغلاق التطبيق — لا نجمع أي بيانات عن الرفض
    await SystemNavigator.pop();
  }

  /// يعرض نص السياسة كاملاً في ورقة قابلة للقراءة والتمرير
  ///
  /// ⭐ النصوص موحّدة مع شاشة «القانوني والخصوصية» عبر `LegalTexts`
  ///    → لا يمكن أن يختلف ما وافق عليه المستخدم عمّا يقرؤه لاحقاً.
  Future<void> _showFullPolicy({required bool isPrivacy}) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return showPolicySheet(
      context,
      title: isPrivacy ? l10n.legalPrivacy : l10n.legalTerms,
      version: l10n.consentVersionLabel(
        isPrivacy
            ? AppConstants.privacyPolicyVersion
            : AppConstants.termsVersion,
      ),
      body: isPrivacy ? LegalTexts.privacy(l10n) : LegalTexts.terms(l10n),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return PopScope(
      // 🔴 حاجز حقيقي: لا رجوع بالنظام ولا بإيماءة الحواف
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppTokens.spaceLg,
              vertical: AppTokens.spaceXl,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // ── الأيقونة ──
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.privacy_tip_rounded,
                        size: 38,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTokens.spaceXl),

                  // ── العنوان ──
                  Text(
                    l10n.consentTitle,
                    style: AppTypography.textTheme.headlineMedium?.copyWith(
                      color: scheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTokens.spaceSm),

                  Text(
                    l10n.consentIntro,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.7,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTokens.spaceXl),

                  // ── النقاط الثلاث ──
                  _ConsentPoint(
                    icon: Icons.smartphone_rounded,
                    title: l10n.consentPoint1Title,
                    body: l10n.consentPoint1Body,
                  ),
                  const SizedBox(height: AppTokens.spaceMd),
                  _ConsentPoint(
                    icon: Icons.block_rounded,
                    title: l10n.consentPoint2Title,
                    body: l10n.consentPoint2Body,
                  ),
                  const SizedBox(height: AppTokens.spaceMd),
                  _ConsentPoint(
                    icon: Icons.manage_accounts_rounded,
                    title: l10n.consentPoint3Title,
                    body: l10n.consentPoint3Body,
                  ),

                  const SizedBox(height: AppTokens.spaceXl),

                  // ── روابط النص الكامل ──
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () => _showFullPolicy(isPrivacy: true),
                          icon: const Icon(Icons.privacy_tip_outlined, size: 18),
                          label: Text(
                            l10n.consentReadPrivacy,
                            style: AppTypography.textTheme.labelMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () => _showFullPolicy(isPrivacy: false),
                          icon: const Icon(Icons.description_outlined, size: 18),
                          label: Text(
                            l10n.consentReadTerms,
                            style: AppTypography.textTheme.labelMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppTokens.spaceMd),

                  // ── ⭐ صندوق الموافقة: غير مُعلَّم مسبقاً أبداً ──
                  Container(
                    padding: const EdgeInsetsDirectional.all(AppTokens.spaceMd),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLow,
                      borderRadius: AppTokens.cardRadius,
                      border: Border.all(
                        color: _accepted
                            ? scheme.primary
                            : scheme.outlineVariant,
                        width: _accepted ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Checkbox(
                          // 🔴 القيمة الأولية false دائماً — لا تُعلَّم مسبقاً
                          value: _accepted,
                          onChanged: (bool? value) =>
                              setState(() => _accepted = value ?? false),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _accepted = !_accepted),
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsetsDirectional.only(
                                top: AppTokens.spaceMd,
                                bottom: AppTokens.spaceMd,
                              ),
                              child: Text(
                                l10n.consentCheckboxLabel,
                                style:
                                    AppTypography.textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurface,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppTokens.spaceSm),

                  // ── الإصدار والتوثيق ──
                  Text(
                    '${l10n.consentVersionLabel(AppConstants.privacyPolicyVersion)} · '
                    '${AppConstants.appNameLatin}',
                    style: AppTypography.monoSmall.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppTokens.spaceXl),

                  // ── الأزرار: القبول والرفض بنفس الوضوح ──
                  AppButton(
                    label: l10n.consentAccept,
                    onPressed: _accepted ? _accept : null,
                    isLoading: _saving,
                    variant: AppButtonVariant.filled,
                    icon: Icons.check_circle_outline_rounded,
                    semanticLabel: l10n.consentAccept,
                  ),
                  const SizedBox(height: AppTokens.spaceSm),
                  AppButton(
                    label: l10n.consentDecline,
                    onPressed: _saving ? null : _decline,
                    variant: AppButtonVariant.outlined,
                    icon: Icons.close_rounded,
                    semanticLabel: l10n.consentDecline,
                  ),

                  const SizedBox(height: AppTokens.spaceLg),

                  Text(
                    l10n.consentRecordedNote,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTokens.spaceLg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// نقطة واحدة في ملخص الموافقة
class _ConsentPoint extends StatelessWidget {
  const _ConsentPoint({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: AppTokens.fieldRadius,
          ),
          child: Icon(icon, size: 22, color: scheme.onPrimaryContainer),
        ),
        const SizedBox(width: AppTokens.spaceMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: AppTokens.spaceXs),
              Text(
                body,
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.65,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// صفحة النص الكامل داخل Bottom Sheet
