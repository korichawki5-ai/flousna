import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';
import '../theme/typography.dart';

/// ═══════════════════════════════════════════════════════════════
///  ScreenScaffold — هيكل موحّد لكل الشاشات
///
///  ⭐ قاعدة المرحلة 3 (النقطة 13): «نظام تصميم واحد مطبّق على
///     كل الشاشات بدون استثناء — لا شاشة تفت عن الستايل.»
///
///  يوفّر: حشواً قياسياً · قيود عرض للشاشات الكبيرة · منطقة آمنة
///  لعناصر النظام · وعنواناً موحّداً.
/// ═══════════════════════════════════════════════════════════════
class ScreenScaffold extends StatelessWidget {
  const ScreenScaffold({
    required this.body,
    super.key,
    this.title,
    this.showBackButton = false,
    this.actions,
    this.floatingActionButton,
    this.padding = AppTokens.spaceLg,
    this.scrollable = true,
    this.bottomBar,
    this.header,
  });

  /// المحتوى
  final Widget body;

  /// عنوان الشاشة — إن تُرك `null` لا يظهر AppBar
  final String? title;

  /// ⭐ زر رجوع متوقع دائماً (قاعدة المرحلة 3 — النقطة 6)
  final bool showBackButton;

  final List<Widget>? actions;

  final Widget? floatingActionButton;

  final double padding;

  /// false لشاشات القوائم التي تدير تمريرها بنفسها (lazy loading)
  final bool scrollable;

  /// شريط سفلي ثابت (أزرار الحفظ)
  final Widget? bottomBar;

  /// محتوى يوضع فوق الجسم ولا يتمرّر (شريط حالة، لافتة)
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title == null
          ? null
          : AppBar(
              title: Text(title!),
              automaticallyImplyLeading: showBackButton,
              actions: actions,
            ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomBar,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            ?header,
            Expanded(
              child: scrollable
                  ? SingleChildScrollView(
                      padding: EdgeInsetsDirectional.all(padding),
                      child: _constrained(context, body),
                    )
                  : _constrained(context, body),
            ),
          ],
        ),
      ),
    );
  }

  /// يقيّد العرض على الشاشات الكبيرة (نسخة Windows)
  Widget _constrained(BuildContext context, Widget child) {
    return Align(
      alignment: AlignmentDirectional.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppTokens.maxContentWidth),
        child: child,
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════
///  SectionHeader — عنوان قسم داخل شاشة
/// ═══════════════════════════════════════════════════════════════
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    super.key,
    this.subtitle,
    this.action,
    this.icon,
  });

  final String title;
  final String? subtitle;

  /// إجراء صغير في نهاية السطر («عرض الكل»)
  final Widget? action;

  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: AppTokens.spaceXl,
        bottom: AppTokens.spaceMd,
      ),
      child: Row(
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 20, color: scheme.primary),
            const SizedBox(width: AppTokens.spaceSm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
                if (subtitle != null) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════
///  InfoBanner — لافتة معلوماتية (حالة التجربة، الأوفلاين، تنبيه)
///
///  ⚠️ Accessibility: لا تعتمد على اللون وحده — أيقونة + نص دائماً.
/// ═══════════════════════════════════════════════════════════════
class InfoBanner extends StatelessWidget {
  const InfoBanner({
    required this.message,
    required this.icon,
    super.key,
    this.tone = InfoBannerTone.info,
    this.onTap,
    this.actionLabel,
  });

  final String message;
  final IconData icon;
  final InfoBannerTone tone;
  final VoidCallback? onTap;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    final (Color background, Color foreground) = switch (tone) {
      InfoBannerTone.info => (scheme.primaryContainer, scheme.onPrimaryContainer),
      InfoBannerTone.warning => (scheme.errorContainer, scheme.onErrorContainer),
      InfoBannerTone.success => (scheme.secondaryContainer, scheme.onSecondaryContainer),
      InfoBannerTone.neutral => (scheme.surfaceContainerHigh, scheme.onSurface),
    };

    return Material(
      color: background,
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
              Icon(icon, size: 20, color: foreground),
              const SizedBox(width: AppTokens.spaceMd),
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: foreground,
                    height: 1.55,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (actionLabel != null) ...<Widget>[
                const SizedBox(width: AppTokens.spaceSm),
                Text(
                  actionLabel!,
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: foreground,
                    decoration: TextDecoration.underline,
                    decorationColor: foreground,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// نبرة اللافتة
enum InfoBannerTone { info, warning, success, neutral }

/// ═══════════════════════════════════════════════════════════════
///  بطاقة عامة موحّدة — تستعملها كل الشاشات
/// ═══════════════════════════════════════════════════════════════
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    super.key,
    this.padding = AppTokens.spaceLg,
    this.onTap,
    this.highlighted = false,
  });

  final Widget child;
  final double padding;
  final VoidCallback? onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    final BoxDecoration decoration = BoxDecoration(
      color: highlighted ? scheme.primaryContainer : scheme.surfaceContainerLow,
      borderRadius: AppTokens.cardRadius,
      border: Border.all(
        color: highlighted ? scheme.primary : scheme.outlineVariant,
        width: highlighted ? 1.5 : 1,
      ),
    );

    if (onTap == null) {
      return Container(
        padding: EdgeInsetsDirectional.all(padding),
        decoration: decoration,
        child: child,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTokens.cardRadius,
        child: Container(
          padding: EdgeInsetsDirectional.all(padding),
          decoration: decoration,
          child: child,
        ),
      ),
    );
  }
}
