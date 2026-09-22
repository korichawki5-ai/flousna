import 'package:falousna/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/widgets/app_button.dart';
import '../../data/local/local_store.dart';

/// ═══════════════════════════════════════════════════════════════
///  AuthChooseScreen — اختيار المسار
///
///  ⭐ القرار المعتمد: **التسجيل ليس إجبارياً**.
///     «جرّب بدون حساب» هو الخيار الأساسي والأبرز — لأنه يقلل
///     الاحتكاك بشكل كبير ويرفع معدل من يصلون إلى أول حركة مسجّلة.
///
///  ✅ Hick's Law: خياران اثنان فقط (لا قوائم ولا تبويبات).
///  ✅ Von Restorff: الخيار الأساسي بلون Primary مملوء.
///
///  🔒 الأثر القانوني الإيجابي: من يختار «بدون حساب» لا تُنقل
///     بياناته خارج جهازه إطلاقاً → المادة 44 (النقل خارج الوطن)
///     لا تنطبق عليه. هذه حجة امتثال قوية.
///
///  ⚠️ إنشاء الحساب والدخول الفعلي يُفعَّلان في **المرحلة 3**
///     (بعد ربط Supabase). الزرّان ظاهران لكنهما يعرضان رسالة
///     واضحة — لا زر ميت بلا تفسير.
/// ═══════════════════════════════════════════════════════════════
class AuthChooseScreen extends ConsumerStatefulWidget {
  const AuthChooseScreen({super.key});

  @override
  ConsumerState<AuthChooseScreen> createState() => _AuthChooseScreenState();
}

class _AuthChooseScreenState extends ConsumerState<AuthChooseScreen> {
  bool _enteringGuest = false;

  /// يدخل وضع الضيف ويبدأ التجربة المجانية
  Future<void> _enterGuestMode() async {
    if (_enteringGuest) return;
    setState(() => _enteringGuest = true);

    try {
      final LocalStore store = ref.read(localStorageProvider);
      await store.enterGuestMode();
      await store.startTrial();

      refreshNavigation(ref);
      if (!mounted) return;
      context.go(RoutePaths.setup);
    } on Exception {
      // 🔴 Error Handling حقيقي — لا انهيار صامت
      if (!mounted) return;
      setState(() => _enteringGuest = false);
      final AppLocalizations l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorGenericBody),
          duration: AppTokens.snackBarDuration,
        ),
      );
    }
  }

  /// يعرض رسالة واضحة بأن الحسابات تأتي في المرحلة 3
  void _showAccountsPending(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) => Padding(
        padding: const EdgeInsetsDirectional.all(AppTokens.spaceXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Icon(
              Icons.cloud_sync_rounded,
              size: 48,
              color: scheme.primary,
            ),
            const SizedBox(height: AppTokens.spaceLg),
            Text(
              l10n.authCreateAccount,
              style: AppTypography.textTheme.titleLarge?.copyWith(
                color: scheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTokens.spaceSm),
            Text(
              l10n.authComingSoonPhase3,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.7,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTokens.spaceLg),
            Text(
              l10n.authGuestLimitNote,
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTokens.spaceXl),
            AppButton(
              label: l10n.actionClose,
              onPressed: () => Navigator.of(sheetContext).pop(),
              variant: AppButtonVariant.filled,
            ),
            const SizedBox(height: AppTokens.spaceMd),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppTokens.spaceLg,
            vertical: AppTokens.spaceXl,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: AppTokens.spaceXxl),

                // ── الأيقونة ──
                Center(
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 44,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: AppTokens.spaceXl),

                // ── العنوان ──
                Text(
                  l10n.authChooseTitle,
                  style: AppTypography.textTheme.headlineMedium?.copyWith(
                    color: scheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTokens.spaceMd),

                Text(
                  l10n.authChooseSubtitle,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.75,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTokens.spaceXxl),

                // ── ⭐ الخيار الأساسي: بدون حساب ──
                AppButton(
                  label: l10n.authTryWithoutAccount,
                  onPressed: _enterGuestMode,
                  isLoading: _enteringGuest,
                  variant: AppButtonVariant.filled,
                  icon: Icons.bolt_rounded,
                  semanticLabel: l10n.authTryWithoutAccount,
                ),

                const SizedBox(height: AppTokens.spaceSm),

                // ── الخيار البديل: إنشاء حساب (المرحلة 3) ──
                AppButton(
                  label: l10n.authCreateAccount,
                  onPressed: () => _showAccountsPending(context),
                  variant: AppButtonVariant.outlined,
                  icon: Icons.person_add_alt_rounded,
                ),

                const SizedBox(height: AppTokens.spaceSm),

                AppButton(
                  label: l10n.authLogin,
                  onPressed: () => _showAccountsPending(context),
                  variant: AppButtonVariant.text,
                  icon: Icons.login_rounded,
                ),

                const SizedBox(height: AppTokens.spaceXl),

                // ── طمأنة قانونية ──
                Container(
                  padding: const EdgeInsetsDirectional.all(AppTokens.spaceLg),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLow,
                    borderRadius: AppTokens.cardRadius,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 20,
                        color: scheme.primary,
                      ),
                      const SizedBox(width: AppTokens.spaceMd),
                      Expanded(
                        child: Text(
                          l10n.authGuestLimitNote,
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.65,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.spaceXl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
