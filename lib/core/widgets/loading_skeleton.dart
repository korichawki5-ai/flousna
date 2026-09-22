import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// ═══════════════════════════════════════════════════════════════
///  LoadingSkeleton — حالة التحميل
///
///  ⚠️ إلزامي لكل شاشة قائمة (قاعدة المرحلة 3 — النقطة 3).
///     Skeleton بدل Spinner لأن Skeleton **يطابق شكل المحتوى
///     الحقيقي** فيقلل الإحساس بالانتظار (Nielsen Norman).
///
///  ✅ يحترم prefers-reduced-motion: عند تعطيل الحركة في النظام
///     يتوقف اللمعان ويبقى لون ثابت.
/// ═══════════════════════════════════════════════════════════════
class LoadingSkeleton extends StatefulWidget {
  const LoadingSkeleton({
    super.key,
    this.lineCount = 3,
    this.showAvatar = true,
    this.padding = AppTokens.spaceLg,
  });

  /// عدد الأسطر الوهمية
  final int lineCount;

  /// إظهار دائرة وهمية (مكان الأيقونة/الصورة)
  final bool showAvatar;

  final double padding;

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  @override
  void initState() {
    super.initState();
    // ⭐ احترام prefers-reduced-motion (WCAG 2.3.3)
    final bool reduceMotion = WidgetsBinding
        .instance.platformDispatcher.accessibilityFeatures.disableAnimations;
    if (!reduceMotion) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color base = scheme.surfaceContainerHigh;
    final Color highlight = scheme.surfaceContainerHighest;

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (Rect bounds) {
            final double t = _controller.value;
            return LinearGradient(
              begin: Alignment(-1.0 + (t * 2), 0),
              end: Alignment(-0.3 + (t * 2), 0),
              colors: <Color>[
                base,
                highlight,
                base,
              ],
              stops: const <double>[0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: Padding(
        padding: EdgeInsetsDirectional.all(widget.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List<Widget>.generate(widget.lineCount, (int index) {
            return Padding(
              padding: const EdgeInsetsDirectional.only(
                bottom: AppTokens.spaceMd,
              ),
              child: Row(
                children: <Widget>[
                  if (widget.showAvatar) ...<Widget>[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: base,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppTokens.spaceMd),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _bar(height: 14, widthFactor: 0.7 - (index * 0.08), color: base),
                        const SizedBox(height: AppTokens.spaceSm),
                        _bar(height: 10, widthFactor: 0.45, color: base),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppTokens.spaceMd),
                  _bar(height: 16, width: 70, color: base),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _bar({
    required double height,
    required Color color,
    double? widthFactor,
    double? width,
  }) =>
      Container(
        height: height,
        width: width,
        constraints: BoxConstraints(
          minWidth: width ?? 40,
          maxWidth: double.infinity,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppTokens.radiusXs),
        ),
        child: widthFactor != null
            ? FractionallySizedBox(
                alignment: AlignmentDirectional.centerStart,
                widthFactor: widthFactor.clamp(0.1, 1.0),
                child: const SizedBox.expand(),
              )
            : null,
      );
}

/// هيكل عظمي لبطاقة مبلغ (الرئيسية)
class MoneyCardSkeleton extends StatelessWidget {
  const MoneyCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color base = scheme.surfaceContainerHigh;

    return Container(
      height: 160,
      padding: const EdgeInsetsDirectional.all(AppTokens.spaceLg),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: AppTokens.cardRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 12,
            width: 90,
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(AppTokens.radiusXs),
            ),
          ),
          const SizedBox(height: AppTokens.spaceMd),
          Container(
            height: 32,
            width: 180,
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(AppTokens.radiusXs),
            ),
          ),
          const Spacer(),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: base,
                    borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                  ),
                ),
              ),
              const SizedBox(width: AppTokens.spaceMd),
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: base,
                    borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// مؤشر تحميل دائري مع رسالة — للعمليات الطويلة
class LoadingMessage extends StatelessWidget {
  const LoadingMessage({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppTokens.spaceXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: AppTokens.spaceLg),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
