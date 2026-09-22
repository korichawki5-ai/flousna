import 'package:flutter/material.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/theme/typography.dart';

/// ═══════════════════════════════════════════════════════════════
///  PolicySheet — عارض الوثائق القانونية
///
///  ⭐ قابلية القراءة أولاً (قاعدة 1 في وثيقة 02):
///     - ورقة قابلة للسحب حتى 95% من الشاشة
///     - `SelectableText` → المستخدم يستطيع نسخ أي فقرة
///       (مطلوب عملياً عند مراسلة ANPDP أو المحامي)
///     - ارتفاع سطر 1.85 للنصوص الطويلة
///     - الإصدار معروض دائماً (دليل على أي نسخة وافق)
/// ═══════════════════════════════════════════════════════════════
class PolicySheet extends StatelessWidget {
  const PolicySheet({
    required this.controller,
    required this.title,
    required this.version,
    required this.body,
    super.key,
  });

  final ScrollController controller;
  final String title;
  final String version;
  final String body;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return ListView(
      controller: controller,
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppTokens.spaceXl,
      ),
      children: <Widget>[
        Text(
          title,
          style: AppTypography.textTheme.titleLarge?.copyWith(
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: AppTokens.spaceXs),
        Text(
          version,
          style: AppTypography.monoSmall.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppTokens.spaceLg),
        const Divider(),
        const SizedBox(height: AppTokens.spaceLg),
        SelectableText(
          body,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.85,
          ),
        ),
        const SizedBox(height: AppTokens.spaceXxl),
      ],
    );
  }
}

/// يفتح وثيقة قانونية في ورقة قابلة للتمرير
Future<void> showPolicySheet(
  BuildContext context, {
  required String title,
  required String version,
  required String body,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (BuildContext sheetContext) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (BuildContext context, ScrollController controller) => PolicySheet(
        controller: controller,
        title: title,
        version: version,
        body: body,
      ),
    ),
  );
}
