import 'package:falousna/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/constants.dart';
import '../../core/errors/app_error.dart';
import '../../core/l10n/category_labels.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/seed_icons.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/clock_guard.dart';
import '../../core/utils/money.dart';
import '../../core/utils/number_format.dart';
import '../../core/utils/result.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/money_text.dart';
import '../../data/db/db.dart';
import '../../data/seed/seed_categories.dart';

/// ═══════════════════════════════════════════════════════════════
///  AddTransactionScreen — تسجيل حركة (دخل أو مصروف)
///
///  ✅ هدف السرعة (وثيقة 05): **أقل من 5 ثوانٍ** لتسجيل حركة
///     - نوع الحركة في الأعلى (مفتاح واحد)
///     - المبلغ أولاً (لوحة أرقام مباشرة)
///     - التصنيفات أزرار كبيرة (لا قائمة منسدلة)
///     - الملاحظة والتاريخ اختياريان
///
///  ✅ التحقق الفوري أثناء الكتابة (قاعدة 2: تحقق مزدوج)
///  ✅ معاينة حيّة للمبلغ بخط Mono — يرى المستخدم ما سيسجَّل
///
///  🔴 صدق مع المستخدم: الحفظ في قاعدة البيانات يبدأ في المرحلة 2.
///     لذلك عند الضغط على «حفظ» تظهر نافذة تشرح ذلك بوضوح بدل
///     رسالة «تم الحفظ» كاذبة. لا بيانات تُفقد ولا ثقة تُخدش.
/// ═══════════════════════════════════════════════════════════════
class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  SeedCategoryKind _kind = SeedCategoryKind.expense;
  bool _saving = false;
  String? _selectedCategoryId;

  /// التاريخ الافتراضي — يُضبط في initState من الوقت الموثوق
  /// ⭐ لا `DateTime.now()`: حارس الساعة يمنع تسجيل حركة بتاريخ
  ///    يرجع للوراء بعد التلاعب بساعة الجهاز.
  late DateTime _date;

  /// آخر مبلغ تم تحليله بنجاح — للمعاينة الحيّة
  Money? _previewAmount;

  @override
  void initState() {
    super.initState();
    // اختيار أول تصنيف افتراضياً = حركة أسرع
    _selectedCategoryId = SeedCategories.catalog.expense.first.id;
    _date = ref.read(clockGuardProvider).trustedNow();
    _amountController.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _amountController
      ..removeListener(_onAmountChanged)
      ..dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    final Result<Money, AppError> parsed = Money.tryParse(_amountController.text);
    final Money? value = parsed.getOrNull();
    if (value == _previewAmount) return;
    setState(() => _previewAmount = value);
  }

  void _changeKind(SeedCategoryKind kind) {
    if (kind == _kind) return;
    setState(() {
      _kind = kind;
      // نبدّل التصنيف المختار لأن القوائم مختلفة
      _selectedCategoryId = SeedCategories.catalog.ofKind(kind).first.id;
    });
  }

  Future<void> _pickDate() async {
    // ⭐ حدود المنتقي بالوقت الموثوق — لا يمكن اختيار تاريخ مستحيل
    final DateTime trustedNow = ref.read(clockGuardProvider).trustedNow();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: trustedNow.subtract(const Duration(days: 3650)),
      lastDate: trustedNow.add(const Duration(days: 365)),
      helpText: AppLocalizations.of(context).addDateLabel,
    );
    if (picked == null || !mounted) return;
    setState(() => _date = picked);
  }

  Future<void> _submit() async {
    final AppLocalizations l10n = AppLocalizations.of(context);

    // 1) التحقق من النموذج كاملاً
    final bool formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid) {
      HapticFeedback.mediumImpact();
      return;
    }

    // 2) التحقق الصارم من المبلغ (Money.tryParse = التحقق الثاني)
    final Result<Money, AppError> amount = Money.tryParse(_amountController.text);
    if (amount.isFailure) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(amount.errorOrNull!.body(context)),
          duration: AppTokens.snackBarDuration,
        ),
      );
      return;
    }

    // 3) التحقق من وجود التصنيف
    final String? categoryId = _selectedCategoryId;
    if (categoryId == null) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.validateRequired),
          duration: AppTokens.snackBarDuration,
        ),
      );
      return;
    }

    // 4) الحفظ الحقيقي في القاعدة
    setState(() => _saving = true);
    final Result<Transaction, AppError> result =
        await ref.read(transactionRepositoryProvider).add(
              kind: _kind,
              amount: amount.requireValue,
              categoryId: categoryId,
              note: _noteController.text.trim(),
              occurredOn: _date,
            );
    if (!mounted) return;
    setState(() => _saving = false);

    if (result.isFailure) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorOrNull!.body(context)),
          duration: AppTokens.snackBarDuration,
        ),
      );
      return;
    }

    // ✅ نجاح — الرجوع للشاشة السابقة + تأكيد فوري
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.txSavedSnack),
        duration: AppTokens.snackBarDuration,
      ),
    );
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(true);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _amountController.clear();
    _noteController.clear();
    setState(() {
      _previewAmount = null;
      _date = ref.read(clockGuardProvider).trustedNow();
      _selectedCategoryId = SeedCategories.catalog.ofKind(_kind).first.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final List<SeedCategory> categories = SeedCategories.catalog.ofKind(_kind);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addTitle),
        actions: <Widget>[
          AppIconButton(
            icon: Icons.refresh_rounded,
            tooltip: l10n.actionCancel,
            onPressed: _resetForm,
          ),
          const SizedBox(width: AppTokens.spaceSm),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.all(AppTokens.spaceLg),
            child: Align(
              alignment: AlignmentDirectional.topCenter,
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(maxWidth: AppTokens.maxContentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // ── 1. نوع الحركة ──
                    _KindSelector(
                      kind: _kind,
                      onChanged: _changeKind,
                    ),
                    const SizedBox(height: AppTokens.spaceXl),

                    // ── 2. المبلغ + المعاينة الحيّة ──
                    // (التسمية يعرضها الحقل نفسه — لا تكرار بصري)
                    AppTextField(
                      label: l10n.addAmountLabel,
                      controller: _amountController,
                      hint: l10n.addAmountHint,
                      fieldType: AppFieldType.amount,
                      validator: Validators.amount,
                      validateOnChanged: true,
                      autofocus: true,
                      textInputAction: TextInputAction.next,
                      semanticLabel: l10n.addAmountLabel,
                    ),
                    const SizedBox(height: AppTokens.spaceMd),
                    _AmountPreview(amount: _previewAmount, kind: _kind),

                    const SizedBox(height: AppTokens.spaceXl),

                    // ── 3. التصنيف ──
                    Text(
                      l10n.addCategoryLabel,
                      style: AppTypography.textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppTokens.spaceSm),
                    Wrap(
                      spacing: AppTokens.spaceSm,
                      runSpacing: AppTokens.spaceSm,
                      children: categories
                          .map(
                            (SeedCategory category) => _CategoryChip(
                              category: category,
                              label: CategoryLabels.of(l10n, category.labelKey),
                              selected: category.id == _selectedCategoryId,
                              onTap: () => setState(
                                () => _selectedCategoryId = category.id,
                              ),
                            ),
                          )
                          .toList(),
                    ),

                    const SizedBox(height: AppTokens.spaceXl),

                    // ── 4. التاريخ ──
                    _DateField(
                      label: l10n.addDateLabel,
                      value: AppNumberFormat.formatDayWithWeekday(context, _date),
                      onTap: _pickDate,
                    ),

                    const SizedBox(height: AppTokens.spaceLg),

                    // ── 5. الملاحظة (اختياري) ──
                    AppTextField(
                      label: l10n.addNoteLabel,
                      controller: _noteController,
                      hint: l10n.addNoteHint,
                      fieldType: AppFieldType.multiline,
                      validator: (String? value) => Validators.note(
                        value,
                        maxLength: AppConstants.maxNoteLength,
                      ),
                      maxLength: AppConstants.maxNoteLength,
                      semanticLabel: l10n.addNoteLabel,
                    ),

                    const SizedBox(height: AppTokens.spaceXxl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.all(AppTokens.spaceLg),
          // ⚠️ لا تستعمل Align/Center هنا: في فتحة bottomNavigationBar
        //    (قيود ارتفاع محدودة) تتمددان فتلتهمان ارتفاع الشاشة كاملاً
        //    وتسحقان الجسم إلى صفر — حادثة 22/09. UnconstrainedBox
        //    يترك الطفل بحجمه الطبيعي ويوسّطه أفقياً فقط.
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints slot) => UnconstrainedBox(
            alignment: AlignmentDirectional.topCenter,
            child: ConstrainedBox(
              // الأقصر بين حد التصميم والعرض المتاح — لا فيضان على هاتف ضيق
              constraints: BoxConstraints(
                maxWidth: slot.maxWidth < AppTokens.maxContentWidth
                    ? slot.maxWidth
                    : AppTokens.maxContentWidth,
              ),
              child: AppButton(
                label: l10n.actionSave,
                icon: Icons.check_rounded,
                onPressed: _saving ? null : _submit,
                variant: AppButtonVariant.filled,
                expandWidth: true,
                semanticLabel: l10n.actionSave,
              ),
            ),
          ),
          ),
        ),
      ),
      // لون شريط النظام يتبع نوع الحركة — إشارة بصرية إضافية
      backgroundColor: scheme.surface,
    );
  }
}

/// مُبدّل نوع الحركة — زران كبيران بدل قائمة
class _KindSelector extends StatelessWidget {
  const _KindSelector({required this.kind, required this.onChanged});

  final SeedCategoryKind kind;
  final ValueChanged<SeedCategoryKind> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return SegmentedButton<SeedCategoryKind>(
      segments: <ButtonSegment<SeedCategoryKind>>[
        ButtonSegment<SeedCategoryKind>(
          value: SeedCategoryKind.expense,
          label: Text(l10n.expenseKind),
          icon: const Icon(Icons.trending_down_rounded),
        ),
        ButtonSegment<SeedCategoryKind>(
          value: SeedCategoryKind.income,
          label: Text(l10n.incomeKind),
          icon: const Icon(Icons.trending_up_rounded),
        ),
      ],
      selected: <SeedCategoryKind>{kind},
      onSelectionChanged: (Set<SeedCategoryKind> selection) =>
          onChanged(selection.first),
      showSelectedIcon: false,
      style: ButtonStyle(
        minimumSize: WidgetStatePropertyAll<Size>(
          const Size(0, AppTokens.minTouchTarget),
        ),
        foregroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) => states.contains(WidgetState.selected)
              ? (kind == SeedCategoryKind.expense
                  ? AppTokens.semanticExpense
                  : AppTokens.semanticIncome)
              : scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// معاينة حيّة للمبلغ — بخط Mono وباتجاه LTR داخل RTL
class _AmountPreview extends StatelessWidget {
  const _AmountPreview({required this.amount, required this.kind});

  final Money? amount;
  final SeedCategoryKind kind;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color accent = kind == SeedCategoryKind.expense
        ? AppTokens.semanticExpense
        : AppTokens.semanticIncome;

    return AnimatedContainer(
      duration: AppTokens.motionFast,
      curve: AppTokens.curveStandard,
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppTokens.spaceLg,
        vertical: AppTokens.spaceMd,
      ),
      decoration: BoxDecoration(
        color: amount == null
            ? scheme.surfaceContainerLow
            : accent.withValues(alpha: 0.08),
        borderRadius: AppTokens.cardRadius,
        border: Border.all(
          color: amount == null ? scheme.outlineVariant : accent,
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            amount == null
                ? Icons.help_outline_rounded
                : (kind == SeedCategoryKind.expense
                    ? Icons.south_west_rounded
                    : Icons.north_east_rounded),
            size: 20,
            color: amount == null ? scheme.onSurfaceVariant : accent,
          ),
          const SizedBox(width: AppTokens.spaceMd),
          Expanded(
            child: amount == null
                ? Text(
                    AppLocalizations.of(context).addAmountHint,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  )
                : MoneyText(
                    amount: amount!,
                    size: MoneyTextSize.large,
                    color: accent,
                    showSign: true,
                  ),
          ),
        ],
      ),
    );
  }
}

/// زر تصنيف — كبير (≥48dp) ومع أيقونة ونص
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final SeedCategory category;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: AppTokens.cardRadius,
        child: AnimatedContainer(
          duration: AppTokens.motionFast,
          curve: AppTokens.curveStandard,
          constraints: const BoxConstraints(minHeight: AppTokens.minTouchTarget),
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppTokens.spaceMd,
            vertical: AppTokens.spaceSm,
          ),
          decoration: BoxDecoration(
            color: selected ? scheme.primaryContainer : scheme.surfaceContainerLow,
            borderRadius: AppTokens.cardRadius,
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                SeedIcons.fromName(category.icon),
                size: 18,
                color: selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppTokens.spaceSm),
              Flexible(
                child: Text(
                  label,
                  style: AppTypography.textTheme.labelLarge?.copyWith(
                    color: selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (category.seasonal) ...<Widget>[
                const SizedBox(width: AppTokens.spaceXs),
                // ⭐ علامة الموسم — أيقونة + Semantics (لا اللون وحده)
                Semantics(
                  label: AppLocalizations.of(context).categorySeasonalBadge,
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    size: 13,
                    color: selected
                        ? scheme.onPrimaryContainer
                        : scheme.onSurfaceVariant,
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

/// حقل التاريخ — يفتح منتقي التاريخ المحلي
class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: AppTokens.fieldRadius,
      child: Container(
        constraints: const BoxConstraints(minHeight: AppTokens.fieldHeight),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppTokens.spaceLg,
          vertical: AppTokens.spaceMd,
        ),
        decoration: BoxDecoration(
          borderRadius: AppTokens.fieldRadius,
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          children: <Widget>[
            Icon(Icons.calendar_today_rounded, size: 18, color: scheme.primary),
            const SizedBox(width: AppTokens.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    label,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: AppTypography.textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down_rounded, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
