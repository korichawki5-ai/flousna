import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';
import '../theme/typography.dart';
import 'app_button.dart';

/// ═══════════════════════════════════════════════════════════════
///  EmptyState — الحالة الفارغة
///
///  ⚠️ إلزامي لكل شاشة قائمة. قاعدة المرحلة 3 (النقطة 3):
///     «ممنوع شاشة بيضاء». الحالة الفارغة = رسمة + رسالة + توجيه.
///
///  البنية: أيقونة كبيرة دائرية → عنوان → وصف → CTA واضح
/// ═══════════════════════════════════════════════════════════════
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.accentColor,
    this.compact = false,
  });

  /// الأيقونة التوضيحية
  final IconData icon;

  /// عنوان قصير (جملة واحدة)
  final String title;

  /// رسالة دافئة تشرح الوضع **وتوجّه للحل**
  final String message;

  /// نص الزر الرئيسي — إن تُرك `null` لا يظهر زر
  final String? actionLabel;

  /// إجراء الزر الرئيسي
  final VoidCallback? onAction;

  /// نص زر ثانوي (اختياري)
  final String? secondaryActionLabel;

  final VoidCallback? onSecondaryAction;

  /// لون مميز — افتراضياً لون الحاوية الأولية
  final Color? accentColor;

  /// نسخة مضغوطة للقوائم الصغيرة
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color accent = accentColor ?? scheme.primary;

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
              // ── الأيقونة داخل دائرة ملوّنة ──
              Container(
                width: compact ? 72 : 96,
                height: compact ? 72 : 96,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: compact ? 36 : 48,
                  color: accent,
                ),
              ),

              SizedBox(height: compact ? AppTokens.spaceLg : AppTokens.spaceXl),

              // ── العنوان ──
              Text(
                title,
                style: (compact
                        ? AppTypography.textTheme.titleMedium
                        : AppTypography.textTheme.titleLarge)
                    ?.copyWith(color: scheme.onSurface),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppTokens.spaceSm),

              // ── الرسالة التوجيهية ──
              Text(
                message,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),

              // ── الأزرار ──
              if (actionLabel != null && onAction != null) ...<Widget>[
                SizedBox(height: compact ? AppTokens.spaceLg : AppTokens.spaceXl),
                AppButton(
                  label: actionLabel!,
                  onPressed: onAction!,
                  variant: AppButtonVariant.filled,
                  icon: Icons.add_rounded,
                ),
              ],
              if (secondaryActionLabel != null && onSecondaryAction != null) ...<Widget>[
                const SizedBox(height: AppTokens.spaceSm),
                AppButton(
                  label: secondaryActionLabel!,
                  onPressed: onSecondaryAction!,
                  variant: AppButtonVariant.text,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
