import 'package:falousna/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../errors/app_error.dart';
import '../theme/design_tokens.dart';
import '../theme/typography.dart';
import 'app_button.dart';

/// ═══════════════════════════════════════════════════════════════
///  ErrorState — حالة الخطأ
///
///  ⚠️ إلزامي لكل شاشة. قاعدة المرحلة 3 (النقطة 3):
///     «خطأ مع زر إعادة محاولة».
///
///  ✅ القواعد المطبَّقة:
///     - رسالة عربية/فرنسية مفهومة، **بدون تفاصيل تقنية**
///     - زر «إعادة المحاولة» إن كان الخطأ قابلاً للاسترداد
///     - التفاصيل التقنية في logOnly فقط (لا تظهر للمستخدم)
///     - لا شاشة بيضاء ولا تحميل لا نهائي
/// ═══════════════════════════════════════════════════════════════
class ErrorState extends StatelessWidget {
  const ErrorState({
    required this.error,
    super.key,
    this.onRetry,
    this.onContactSupport,
    this.compact = false,
  });

  final AppError error;

  /// إجراء إعادة المحاولة — إن `null` لا يظهر الزر
  final VoidCallback? onRetry;

  /// إجراء التواصل مع الدعم
  final VoidCallback? onContactSupport;

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: compact ? AppTokens.spaceLg : AppTokens.spaceXxl,
          vertical: compact ? AppTokens.spaceXl : AppTokens.spaceXxxl,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: compact ? 72 : 96,
                height: compact ? 72 : 96,
                decoration: BoxDecoration(
                  color: scheme.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _icon,
                  size: compact ? 36 : 48,
                  color: scheme.onErrorContainer,
                ),
              ),

              SizedBox(height: compact ? AppTokens.spaceLg : AppTokens.spaceXl),

              Text(
                error.title(context),
                style: (compact
                        ? AppTypography.textTheme.titleMedium
                        : AppTypography.textTheme.titleLarge)
                    ?.copyWith(color: scheme.onSurface),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppTokens.spaceSm),

              Text(
                error.body(context),
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),

              // طمأنة للمستخدم عند أخطاء الشبكة/التخزين
              if (error.kind == AppErrorKind.network ||
                  error.kind == AppErrorKind.storage) ...<Widget>[
                const SizedBox(height: AppTokens.spaceMd),
                _ReassuranceChip(text: l10n.errorGenericBody),
              ],

              if (error.showsRetryButton && onRetry != null) ...<Widget>[
                SizedBox(height: compact ? AppTokens.spaceLg : AppTokens.spaceXl),
                AppButton(
                  label: l10n.actionRetry,
                  onPressed: onRetry!,
                  variant: AppButtonVariant.filled,
                  icon: Icons.refresh_rounded,
                ),
              ],

              if (onContactSupport != null) ...<Widget>[
                const SizedBox(height: AppTokens.spaceSm),
                AppButton(
                  label: l10n.errorContactSupport,
                  onPressed: onContactSupport!,
                  variant: AppButtonVariant.text,
                  icon: Icons.support_agent_rounded,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData get _icon => switch (error.kind) {
        AppErrorKind.network => Icons.wifi_off_rounded,
        AppErrorKind.timeout => Icons.timer_off_rounded,
        AppErrorKind.permission => Icons.lock_outline_rounded,
        AppErrorKind.featureLocked => Icons.lock_clock_rounded,
        AppErrorKind.syncConflict => Icons.sync_problem_rounded,
        AppErrorKind.storage => Icons.sd_card_alert_rounded,
        AppErrorKind.validation => Icons.error_outline_rounded,
        AppErrorKind.unknown => Icons.report_gmailerrorred_rounded,
      };
}

/// شريحة طمأنة — تُظهر أن البيانات لم تُفقد
class _ReassuranceChip extends StatelessWidget {
  const _ReassuranceChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppTokens.spaceMd,
        vertical: AppTokens.spaceSm,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: AppTokens.fieldRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.verified_user_rounded,
            size: 18,
            color: scheme.primary,
          ),
          const SizedBox(width: AppTokens.spaceSm),
          Flexible(
            child: Text(
              text,
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
