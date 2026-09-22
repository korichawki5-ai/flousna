import 'package:falousna/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';
import '../theme/typography.dart';
import 'app_button.dart';

/// ═══════════════════════════════════════════════════════════════
///  showPhaseSheet — نافذة «هذه الميزة في مرحلة قادمة»
///
///  ⭐ قاعدة المنتج (وثيقة 05): **لا زر ميت ولا شاشة بيضاء**.
///     كل ميزة لم تُبنَ بعد تُفتح على نافذة موحّدة تقول:
///       - ما هي الميزة
///       - في أي مرحلة ستأتي
///       - ماذا يعني ذلك للمستخدم الآن
///
///  ⚠️ كل النصوص من .arb — لا نص مكتوب يدوياً (قاعدة الترجمة).
/// ═══════════════════════════════════════════════════════════════
Future<void> showPhaseSheet(
  BuildContext context, {
  required int phase,
  required String title,
  required IconData icon,
  String? body,
  String? note,
}) {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final ColorScheme scheme = Theme.of(context).colorScheme;

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (BuildContext sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppTokens.spaceXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 34, color: scheme.onPrimaryContainer),
              ),
            ),
            const SizedBox(height: AppTokens.spaceLg),
            Text(
              title,
              style: AppTypography.textTheme.titleLarge?.copyWith(
                color: scheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTokens.spaceSm),

            // شارة المرحلة
            Center(
              child: Container(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppTokens.spaceMd,
                  vertical: AppTokens.spaceXs,
                ),
                decoration: BoxDecoration(
                  color: scheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                ),
                child: Text(
                  l10n.placeholderPhaseLabel(phase),
                  style: AppTypography.monoLabel.copyWith(
                    color: scheme.onTertiaryContainer,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTokens.spaceLg),
            Text(
              body ?? l10n.placeholderBody('$phase'),
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.75,
              ),
              textAlign: TextAlign.center,
            ),
            if (note != null) ...<Widget>[
              const SizedBox(height: AppTokens.spaceLg),
              Container(
                padding: const EdgeInsetsDirectional.all(AppTokens.spaceMd),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: AppTokens.fieldRadius,
                ),
                child: Text(
                  note,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: AppTokens.spaceXl),
            AppButton(
              label: l10n.actionClose,
              onPressed: () => Navigator.of(sheetContext).pop(),
              variant: AppButtonVariant.filled,
              expandWidth: true,
            ),
            const SizedBox(height: AppTokens.spaceSm),
          ],
        ),
      ),
    ),
  );
}
