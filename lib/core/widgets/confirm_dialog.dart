import 'dart:async';

import 'package:falousna/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';
import '../theme/typography.dart';
import 'app_button.dart';

/// ═══════════════════════════════════════════════════════════════
///  ConfirmDialog — حوار التأكيد
///
///  ✅ القواعد المطبَّقة:
///     - تأكيد قبل كل عملية مدمّرة (حذف، خروج، سحب موافقة)
///     - زرّا الإلغاء والتأكيد بنفس الحجم والوضوح (لا خداع بصري)
///     - ⭐ للحذف النهائي: مهلة عدّ تنازلي 10 ثوانٍ قبل تفعيل الزر
///       (يمنع الحذف العرضي — نمط Gmail الشهير)
///     - barrierDismissible = false للعمليات المدمّرة
/// ═══════════════════════════════════════════════════════════════
class ConfirmDialog extends StatefulWidget {
  const ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    super.key,
    this.cancelLabel,
    this.icon,
    this.destructive = false,
    this.requireCountdown = false,
    this.countdownSeconds = 10,
    this.extraContent,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String? cancelLabel;
  final IconData? icon;

  /// عملية مدمّرة → زر بلون الخطأ + لا إغلاق بالنقر خارج الحوار
  final bool destructive;

  /// ⭐ مهلة عدّ تنازلي قبل تفعيل زر التأكيد (للحذف النهائي)
  final bool requireCountdown;

  final int countdownSeconds;

  /// محتوى إضافي (قائمة ما سيُحذف مثلاً)
  final Widget? extraContent;

  /// يعرض الحوار ويُعيد `true` عند التأكيد
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    String? cancelLabel,
    IconData? icon,
    bool destructive = false,
    bool requireCountdown = false,
    int countdownSeconds = 10,
    Widget? extraContent,
  }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      // ⚠️ العمليات المدمّرة لا تُغلق بالنقر خارجها
      barrierDismissible: !destructive,
      builder: (BuildContext dialogContext) => ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        icon: icon,
        destructive: destructive,
        requireCountdown: requireCountdown,
        countdownSeconds: countdownSeconds,
        extraContent: extraContent,
      ),
    );
    return result ?? false;
  }

  @override
  State<ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<ConfirmDialog> {
  late int _remaining = widget.requireCountdown ? widget.countdownSeconds : 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.requireCountdown && _remaining > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          _remaining--;
          if (_remaining <= 0) timer.cancel();
        });
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _canConfirm => _remaining <= 0;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String cancelText = widget.cancelLabel ?? l10n.actionCancel;

    return AlertDialog(
      icon: widget.icon != null
          ? Icon(
              widget.icon,
              size: 32,
              color: widget.destructive ? scheme.error : scheme.primary,
            )
          : null,
      title: Text(
        widget.title,
        style: AppTypography.textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
        ),
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.message,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),
            if (widget.extraContent != null) ...<Widget>[
              const SizedBox(height: AppTokens.spaceLg),
              widget.extraContent!,
            ],
            if (widget.requireCountdown && !_canConfirm) ...<Widget>[
              const SizedBox(height: AppTokens.spaceLg),
              _CountdownNote(seconds: _remaining, note: l10n.countdownNote(_remaining)),
            ],
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsetsDirectional.only(
        start: AppTokens.spaceLg,
        end: AppTokens.spaceLg,
        bottom: AppTokens.spaceLg,
      ),
      actions: <Widget>[
        Column(
          children: <Widget>[
            AppButton(
              label: widget.confirmLabel +
                  (_canConfirm ? '' : ' ($_remaining)'),
              onPressed: _canConfirm ? () => Navigator.of(context).pop(true) : null,
              variant: widget.destructive
                  ? AppButtonVariant.danger
                  : AppButtonVariant.filled,
              enabled: _canConfirm,
            ),
            const SizedBox(height: AppTokens.spaceSm),
            AppButton(
              label: cancelText,
              onPressed: () => Navigator.of(context).pop(false),
              variant: AppButtonVariant.text,
            ),
          ],
        ),
      ],
    );
  }
}

/// ملاحظة العد التنازلي — النص يأتي من ملفات الترجمة
class _CountdownNote extends StatelessWidget {
  const _CountdownNote({required this.seconds, required this.note});

  final int seconds;
  final String note;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsetsDirectional.all(AppTokens.spaceMd),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: AppTokens.fieldRadius,
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.hourglass_bottom_rounded,
            size: 18,
            color: scheme.onErrorContainer,
          ),
          const SizedBox(width: AppTokens.spaceSm),
          Expanded(
            child: Text(
              note,
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: scheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// تأكيد الحذف القياسي (اختصار)
Future<bool> confirmDelete(BuildContext context) {
  final AppLocalizations l10n = AppLocalizations.of(context);
  return ConfirmDialog.show(
    context,
    title: l10n.confirmDeleteTitle,
    message: l10n.confirmDeleteBody,
    confirmLabel: l10n.actionDelete,
    icon: Icons.delete_outline_rounded,
    destructive: true,
  );
}
