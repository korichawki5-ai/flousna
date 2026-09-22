import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';
import '../theme/typography.dart';

/// ═══════════════════════════════════════════════════════════════
///  AppButton — الزر الموحّد
///
///  ينفّذ قواعد إلزامية:
///   ✅ ارتفاع ≥ 48dp (Material + WCAG 2.5.5)
///   ✅ Ripple / press state فوري (Feedback — قاعدة 4)
///   ✅ حالة تحميل واضحة (لا نقرات مكررة)
///   ✅ الأيقونة تنقلب تلقائياً مع RTL
///   ✅ semantic label لقارئ الشاشة
///   ✅ CTA واحد رئيسي بارز لكل شاشة (Von Restorff — قاعدة 2)
/// ═══════════════════════════════════════════════════════════════
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = AppButtonVariant.filled,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.expandWidth = true,
    this.size = AppButtonSize.large,
    this.semanticLabel,
    this.enabled = true,
  });

  /// نص الزر
  final String label;

  /// الإجراء — `null` يعطّل الزر
  final VoidCallback? onPressed;

  /// النمط البصري
  final AppButtonVariant variant;

  /// أيقونة قبل النص (تنقلب مع RTL تلقائياً)
  final IconData? icon;

  /// أيقونة بعد النص
  final IconData? trailingIcon;

  /// حالة تحميل — تمنع النقر المكرر
  final bool isLoading;

  /// يملأ العرض المتاح (الافتراضي للأزرار الرئيسية)
  final bool expandWidth;

  final AppButtonSize size;

  /// تسمية لقارئ الشاشة — افتراضياً نص الزر
  final String? semanticLabel;

  /// تعطيل صريح (بخلاف onPressed == null)
  final bool enabled;

  bool get _effectiveEnabled => enabled && onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final double height = size == AppButtonSize.large
        ? AppTokens.buttonHeightLg
        : AppTokens.buttonHeightMd;

    final Widget child = Semantics(
      button: true,
      enabled: _effectiveEnabled,
      label: semanticLabel ?? label,
      child: SizedBox(
        height: height,
        width: expandWidth ? double.infinity : null,
        child: _buildButton(scheme, height),
      ),
    );

    return child;
  }

  Widget _buildButton(ColorScheme scheme, double height) {
    final Widget content = _buildContent(scheme);

    switch (variant) {
      case AppButtonVariant.filled:
        return FilledButton(
          onPressed: _effectiveEnabled ? onPressed : null,
          style: FilledButton.styleFrom(
            minimumSize: Size(expandWidth ? double.infinity : 0, height),
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppTokens.spaceXl,
            ),
          ),
          child: content,
        );

      case AppButtonVariant.tonal:
        return FilledButton(
          onPressed: _effectiveEnabled ? onPressed : null,
          style: FilledButton.styleFrom(
            backgroundColor: scheme.secondaryContainer,
            foregroundColor: scheme.onSecondaryContainer,
            minimumSize: Size(expandWidth ? double.infinity : 0, height),
          ),
          child: content,
        );

      case AppButtonVariant.outlined:
        return OutlinedButton(
          onPressed: _effectiveEnabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            minimumSize: Size(expandWidth ? double.infinity : 0, height),
          ),
          child: content,
        );

      case AppButtonVariant.text:
        return TextButton(
          onPressed: _effectiveEnabled ? onPressed : null,
          style: TextButton.styleFrom(
            minimumSize: Size(
              expandWidth ? double.infinity : AppTokens.minTouchTarget,
              height,
            ),
          ),
          child: content,
        );

      case AppButtonVariant.danger:
        return FilledButton(
          onPressed: _effectiveEnabled ? onPressed : null,
          style: FilledButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
            minimumSize: Size(expandWidth ? double.infinity : 0, height),
          ),
          child: content,
        );
    }
  }

  Widget _buildContent(ColorScheme scheme) {
    if (isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(_foreground(scheme)),
            ),
          ),
          const SizedBox(width: AppTokens.spaceMd),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _textStyle(scheme),
            ),
          ),
        ],
      );
    }

    final List<Widget> children = <Widget>[];

    if (icon != null) {
      // ⭐ DirectionalIcon: الأيقونة السهمية تنقلب مع RTL
      // (cascade عمداً: قاعدة cascade_invocations)
      children
        ..add(Icon(icon, size: _iconSize))
        ..add(const SizedBox(width: AppTokens.spaceSm));
    }

    children.add(
      Flexible(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: _textStyle(scheme),
        ),
      ),
    );

    if (trailingIcon != null) {
      // (cascade عمداً: قاعدة cascade_invocations)
      children
        ..add(const SizedBox(width: AppTokens.spaceSm))
        ..add(Icon(trailingIcon, size: _iconSize));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  double get _iconSize => size == AppButtonSize.large ? 20 : 18;

  TextStyle _textStyle(ColorScheme scheme) =>
      (size == AppButtonSize.large
              ? AppTypography.textTheme.labelLarge
              : AppTypography.textTheme.labelMedium)
          ?.copyWith(color: _effectiveEnabled ? _foreground(scheme) : null) ??
      TextStyle(color: _foreground(scheme));

  Color _foreground(ColorScheme scheme) => switch (variant) {
        AppButtonVariant.filled => scheme.onPrimary,
        AppButtonVariant.tonal => scheme.onSecondaryContainer,
        AppButtonVariant.outlined => scheme.primary,
        AppButtonVariant.text => scheme.primary,
        AppButtonVariant.danger => scheme.onError,
      };
}

/// أنماط الزر
enum AppButtonVariant {
  /// الزر الرئيسي — CTA واحد بارز لكل شاشة (Von Restorff)
  filled,

  /// ثانوي بلون حاوية
  tonal,

  /// إجراء بديل بحدود
  outlined,

  /// إجراء خفيف
  text,

  /// إجراء مدمّر (حذف)
  danger,
}

/// أحجام الزر — كلاهما ≥ 44dp، والافتراضي ≥ 48dp
enum AppButtonSize { large, medium }

/// زر أيقوني دائري — يلتزم بحد 48×48dp
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    super.key,
    this.color,
    this.filled = false,
  });

  final IconData icon;

  /// ⚠️ إلزامي — أزرار الأيقونات بلا نص تحتاج tooltip لقارئ الشاشة
  final String tooltip;

  final VoidCallback? onPressed;
  final Color? color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: AppTokens.minTouchTarget,
        height: AppTokens.minTouchTarget,
        child: filled
            ? FilledButton(
                onPressed: onPressed,
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(
                    AppTokens.minTouchTarget,
                    AppTokens.minTouchTarget,
                  ),
                  shape: const CircleBorder(),
                ),
                child: Icon(icon, color: color ?? scheme.onPrimary),
              )
            : IconButton(
                onPressed: onPressed,
                icon: Icon(icon, color: color ?? scheme.onSurfaceVariant),
                tooltip: tooltip,
              ),
      ),
    );
  }
}
