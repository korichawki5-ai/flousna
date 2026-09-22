// ═══════════════════════════════════════════════════════════════
//  budget_limits_section.dart — قسم السقوف في شاشة الميزانية
//
//  ⭐ ما يراه المستخدم ويلمسه:
//     - بطاقة لكل سقف: أيقونة الفئة + الاسم + حالة ملوّنة
//       + شريط تقدّم + النسبة + الباقي أو مقدار التجاوز
//     - زر «إضافة سقف» يفتح نافذة: الفئة (أو السقف العام)
//       + المبلغ + نسبة التنبيه
//     - تعديل وحذف أي سقف (الحذف لا يمسّ أي حركة)
//
//  ✅ الحالات الخمس مطبَّقة: تحميل · بيانات · فارغ · خطأ · بلا إنترنت
//     (بلا إنترنت = نفس البيانات: كل شيء محلي، فلا شاشة مختلفة).
//  ✅ المبالغ كلها MoneyText: خط Mono + اتجاه LTR صحيح في العربية.
//  ✅ الحالة تُعبَّر عنها بأيقونة + نص + لون معاً (WCAG 1.4.1:
//     لا تعتمد على اللون وحده أبداً).
// ═══════════════════════════════════════════════════════════════
import 'package:falousna/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_error.dart';
import '../../core/errors/error_text.dart';
import '../../core/l10n/category_labels.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/seed_icons.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/money.dart';
import '../../core/utils/period_resolver.dart';
import '../../core/utils/result.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../core/widgets/money_text.dart';
import '../../core/widgets/screen_scaffold.dart';
import '../../data/db/db.dart';
import '../../data/seed/seed_categories.dart';

/// ألوان الحالات — دلالية وثابتة في الوضعين الفاتح والداكن
const Color _safeColor = Color(0xFF2E7D32); // أخضر الزمرد (هوية فلوسنا)
const Color _nearColor = Color(0xFFEF6C00); // برتقالي التحذير
const Color _overColor = Color(0xFFC62828); // أحمر التجاوز

class BudgetLimitsSection extends ConsumerWidget {
  const BudgetLimitsSection({required this.period, super.key});

  /// الفترة المالية المعروضة — السقوف تُحسب عليها
  final FiscalPeriod period;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ({int startMs, int endMs}) key = (
      startMs: period.start.millisecondsSinceEpoch,
      endMs: period.end.millisecondsSinceEpoch,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SectionHeader(
          title: l10n.budgetLimitLabel,
          subtitle: l10n.budgetPeriodNote,
          icon: Icons.speed_rounded,
        ),
        const SizedBox(height: AppTokens.spaceSm),
        ref.watch(budgetProgressProvider(key)).when(
              loading: () => const AppCard(
                padding: AppTokens.spaceLg,
                child: LoadingSkeleton(lineCount: 3),
              ),
              error: (Object e, _) => AppCard(
                padding: AppTokens.spaceLg,
                child: ErrorState(
                  error: e is AppError ? e : AppError.unknown(cause: e),
                  onRetry: () => ref.invalidate(budgetProgressProvider(key)),
                ),
              ),
              data: (List<BudgetProgress> items) {
                if (items.isEmpty) {
                  return AppCard(
                    padding: AppTokens.spaceSm,
                    child: EmptyState(
                      icon: Icons.pie_chart_outline_rounded,
                      title: l10n.budgetEmptyTitle,
                      message: l10n.budgetEmptyBody,
                      actionLabel: l10n.budgetEmptyAction,
                      onAction: () => _openDialog(context, ref),
                    ),
                  );
                }
                // خريطة الفئات: الأيقونة والاسم من مصدر واحد (مستودع الفئات)
                final Map<String, CategoryView> byId = <String, CategoryView>{
                  for (final CategoryView c in ref
                      .watch(categoriesProvider(SeedCategoryKind.expense))
                      .maybeWhen(
                        data: (List<CategoryView> list) => list,
                        orElse: () => const <CategoryView>[],
                      ))
                    c.id: c,
                };
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    for (final BudgetProgress p in items)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          bottom: AppTokens.spaceSm,
                        ),
                        child: _LimitCard(
                          progress: p,
                          category: p.budget.categoryId == null
                              ? null
                              : byId[p.budget.categoryId],
                          onEdit: () => _openDialog(context, ref, existing: p),
                          onDelete: () => _confirmDelete(context, ref, p),
                        ),
                      ),
                    const SizedBox(height: AppTokens.spaceXs),
                    AppButton(
                      label: l10n.budgetAddLimit,
                      icon: Icons.add_rounded,
                      onPressed: () => _openDialog(context, ref),
                      variant: AppButtonVariant.outlined,
                      expandWidth: true,
                      semanticLabel: l10n.budgetAddLimit,
                    ),
                    const SizedBox(height: AppTokens.spaceSm),
                    // ── الشفافية: المعادلة مكتوبة لا مخفية ──
                    Text(
                      l10n.budgetFormulaNote,
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                );
              },
            ),
      ],
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    BudgetProgress progress,
  ) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool confirmed = await ConfirmDialog.show(
      context,
      title: l10n.budgetDeleteTitle,
      message: l10n.budgetDeleteBody,
      confirmLabel: l10n.budgetDeleteAction,
    );
    if (!confirmed || !context.mounted) return;

    final Result<void, AppError> result =
        await ref.read(budgetRepositoryProvider).remove(progress.budget.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.isSuccess
              ? l10n.budgetDeletedSnack
              : ErrorText.of(l10n, result.errorOrNull!),
        ),
        duration: AppTokens.snackBarDuration,
      ),
    );
  }

  Future<void> _openDialog(
    BuildContext context,
    WidgetRef ref, {
    BudgetProgress? existing,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) => _LimitDialog(existing: existing),
    );
  }
}

/// بطاقة سقف واحد — الأرقام + الشريط + الحالة
class _LimitCard extends StatelessWidget {
  const _LimitCard({
    required this.progress,
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  final BudgetProgress progress;

  /// فئة السقف (null للسقف العام أو لفئة غير معروفة)
  final CategoryView? category;

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final (Color color, IconData icon, String label) = switch (progress.status) {
      BudgetStatus.safe => (_safeColor, Icons.check_circle_rounded, l10n.budgetStatusSafe),
      BudgetStatus.near => (_nearColor, Icons.warning_amber_rounded, l10n.budgetStatusNear),
      BudgetStatus.over => (_overColor, Icons.error_rounded, l10n.budgetStatusOver),
    };

    return AppCard(
      padding: AppTokens.spaceLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // ── رأس البطاقة: الفئة + الحالة + الإجراءات ──
          Row(
            children: <Widget>[
              Icon(
                progress.isOverall
                    ? Icons.donut_large_rounded
                    : SeedIcons.fromName(category?.icon),
                size: 20,
                color: color,
              ),
              const SizedBox(width: AppTokens.spaceSm),
              Expanded(
                child: Text(
                  progress.isOverall
                      ? l10n.budgetOverallLabel
                      : (category == null
                          ? l10n.budgetCategoryMissing
                          : CategoryLabels.of(l10n, category!.labelKey ?? '')),
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: scheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppTokens.spaceXs),
              AppIconButton(
                icon: Icons.edit_outlined,
                tooltip: l10n.budgetEditLimit,
                onPressed: onEdit,
              ),
              AppIconButton(
                icon: Icons.delete_outline_rounded,
                tooltip: l10n.budgetDeleteAction,
                color: _overColor,
                onPressed: onDelete,
              ),
            ],
          ),

          const SizedBox(height: AppTokens.spaceSm),

          // ── شريط التقدّم + النسبة ──
          Row(
            children: <Widget>[
              Expanded(
                child: Semantics(
                  label: l10n.budgetSpentOfLimit,
                  value: l10n.budgetUsedPercent(progress.usedPercent),
                  child: ClipRRect(
                    borderRadius: AppTokens.fieldRadius,
                    child: LinearProgressIndicator(
                      value: progress.ratio,
                      minHeight: 10,
                      backgroundColor: scheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      // بلا stopIndicator: النقطة تزحم شريطاً رقيقاً
                      stopIndicatorRadius: 0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTokens.spaceSm),
              Text(
                l10n.budgetUsedPercent(progress.usedPercent),
                style: AppTypography.monoLabel.copyWith(color: color),
              ),
            ],
          ),

          const SizedBox(height: AppTokens.spaceSm),

          // ── المصروف من السقف ──
          Row(
            children: <Widget>[
              Text(
                l10n.budgetSpentOfLimit,
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              MoneyText(
                amount: progress.spent,
                size: MoneyTextSize.small,
                color: color,
                withDecimals: false,
              ),
              Text(
                ' / ',
                style: AppTypography.monoSmall.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              MoneyText(
                amount: progress.limit,
                size: MoneyTextSize.small,
                color: scheme.onSurfaceVariant,
                withDecimals: false,
              ),
            ],
          ),

          const SizedBox(height: AppTokens.spaceSm),

          // ── الباقي / التجاوز + شارة الحالة ──
          Row(
            children: <Widget>[
              Icon(icon, size: 16, color: color),
              const SizedBox(width: AppTokens.spaceXs),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: color,
                  ),
                ),
              ),
              if (progress.status == BudgetStatus.over)
                _AmountPair(
                  label: progress.isExhausted
                      ? l10n.budgetExhausted
                      : l10n.budgetOverByLabel,
                  amount: progress.overBy,
                  color: color,
                  // عند بلوغ السقف بالضبط لا رقم تجاوز يُعرض
                  showAmount: !progress.isExhausted,
                )
              else
                _AmountPair(
                  label: l10n.budgetRemainingLabel,
                  amount: progress.remaining,
                  color: _safeColor,
                  showAmount: true,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// تسمية + مبلغ في سطر واحد (الباقي أو التجاوز)
class _AmountPair extends StatelessWidget {
  const _AmountPair({
    required this.label,
    required this.amount,
    required this.color,
    required this.showAmount,
  });

  final String label;
  final Money amount;
  final Color color;
  final bool showAmount;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label,
          style: AppTypography.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        if (showAmount) ...<Widget>[
          const SizedBox(width: AppTokens.spaceXs),
          MoneyText(
            amount: amount,
            size: MoneyTextSize.small,
            color: color,
            withDecimals: false,
          ),
        ],
      ],
    );
  }
}

/// نافذة إضافة/تعديل سقف — تحقق مزدوج قبل الكتابة في القاعدة
class _LimitDialog extends ConsumerStatefulWidget {
  const _LimitDialog({this.existing});

  final BudgetProgress? existing;

  @override
  ConsumerState<_LimitDialog> createState() => _LimitDialogState();
}

class _LimitDialogState extends ConsumerState<_LimitDialog> {
  final TextEditingController _amount = TextEditingController();
  String? _categoryId;
  int _alertPercent = 80;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final BudgetProgress? existing = widget.existing;
    if (existing != null) {
      _categoryId = existing.budget.categoryId;
      _alertPercent = existing.budget.alertPercent;
      // المبلغ الحالي يُعبَّأ بصيغة يفهمها المحلّل: `1500` أو `1500,50`
      // (بلا فواصل آلاف ولا رمز عملة — الحقل يقبل الرقم الخام فقط)
      final Money amount = existing.limit;
      _amount.text = amount.fraction == 0
          ? amount.whole.toString()
          : '${amount.whole},${amount.fraction.toString().padLeft(2, '0')}';
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Result<Money, AppError> parsed = Money.tryParse(_amount.text);
    final Money? amount = parsed.getOrNull();
    if (amount == null || !amount.isPositive) {
      // رسالة عربية صريحة — لا فشل صامت
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.validateAmountZero),
          duration: AppTokens.snackBarDuration,
        ),
      );
      return;
    }

    setState(() => _saving = true);
    final Result<void, AppError> result =
        await ref.read(budgetRepositoryProvider).setLimit(
              amount: amount,
              categoryId: _categoryId,
              alertPercent: _alertPercent,
            );
    if (!mounted) return;
    setState(() => _saving = false);

    if (result.isSuccess) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.budgetSavedSnack),
          duration: AppTokens.snackBarDuration,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ErrorText.of(l10n, result.errorOrNull!)),
        duration: AppTokens.snackBarDuration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool editing = widget.existing != null;
    final AsyncValue<List<CategoryView>> categories =
        ref.watch(categoriesProvider(SeedCategoryKind.expense));

    return AlertDialog(
      title: Text(editing ? l10n.budgetEditLimit : l10n.budgetNewLimit),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // ── الفئة ──
            Text(
              l10n.budgetPickCategory,
              style: AppTypography.textTheme.labelLarge,
            ),
            const SizedBox(height: AppTokens.spaceSm),
            DropdownButtonFormField<String?>(
              initialValue: _categoryId,
              isExpanded: true,
              decoration: const InputDecoration(),
              items: <DropdownMenuItem<String?>>[
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(l10n.budgetOverallLabel),
                ),
                ...categories.maybeWhen(
                  data: (List<CategoryView> list) => list
                      .map(
                        (CategoryView c) => DropdownMenuItem<String?>(
                          value: c.id,
                          child: Text(
                            // البذرة بلغتها، والمخصصة بالاسم المخزَّن
                            c.labelKey == null
                                ? (Localizations.localeOf(context)
                                            .languageCode ==
                                        'ar'
                                    ? (c.nameAr ?? '')
                                    : (c.nameFr ?? ''))
                                : CategoryLabels.of(l10n, c.labelKey!),
                          ),
                        ),
                      )
                      .toList(),
                  orElse: () => const <DropdownMenuItem<String?>>[],
                ),
              ],
              onChanged: (String? value) => setState(() => _categoryId = value),
            ),

            const SizedBox(height: AppTokens.spaceLg),

            // ── المبلغ ──
            AppTextField(
              label: l10n.budgetAmountLabel,
              controller: _amount,
              hint: l10n.budgetAmountHint,
              fieldType: AppFieldType.amount,
              validator: Validators.amount,
              autofocus: true,
              textInputAction: TextInputAction.done,
              semanticLabel: l10n.budgetAmountLabel,
            ),

            const SizedBox(height: AppTokens.spaceLg),

            // ── نسبة التنبيه ──
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    l10n.budgetAlertPercentLabel,
                    style: AppTypography.textTheme.labelLarge,
                  ),
                ),
                Text(
                  l10n.budgetAlertPercentValue(_alertPercent),
                  style: AppTypography.monoLabel.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            Slider(
              value: _alertPercent.toDouble(),
              min: 50,
              max: 100,
              divisions: 5,
              label: l10n.budgetAlertPercentValue(_alertPercent),
              onChanged: (double value) =>
                  setState(() => _alertPercent = value.round()),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        AppButton(
          label: l10n.actionCancel,
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          variant: AppButtonVariant.text,
          semanticLabel: l10n.actionCancel,
        ),
        AppButton(
          label: l10n.actionSave,
          icon: Icons.check_rounded,
          onPressed: _saving ? null : _save,
          variant: AppButtonVariant.filled,
          semanticLabel: l10n.actionSave,
        ),
      ],
    );
  }
}
