import 'package:falousna/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/design_tokens.dart';
import '../theme/typography.dart';

/// ═══════════════════════════════════════════════════════════════
///  AppTextField — حقل الإدخال الموحّد
///
///  ✅ القواعد المطبَّقة (المرحلة 3 — النقطة 5):
///     - label واضح + helper text
///     - تحقق فوري أثناء الكتابة برسائل عربية/فرنسية لطيفة
///     - لوحة المفاتيح المناسبة لكل حقل (رقمية للمبلغ والهاتف)
///     - خط ≥ 16px لمنع zoom التلقائي في نسخة الويب
///     - ارتفاع ≥ 56dp · هدف لمس ≥ 48dp
///     - رسائل الخطأ من ملفات الترجمة (مفاتيح، لا نصوص خام)
///     - semantic label لقارئ الشاشة
///     - لا لصق للمبالغ من مصادر خارجية بلا تنظيف
/// ═══════════════════════════════════════════════════════════════
class AppTextField extends StatefulWidget {
  const AppTextField({
    required this.label,
    super.key,
    this.controller,
    this.hint,
    this.helper,
    this.fieldType = AppFieldType.text,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.autofocus = false,
    this.maxLength,
    this.prefixIcon,
    this.suffix,
    this.obscure = false,
    this.textInputAction,
    this.counterText,
    this.semanticLabel,
    this.validateOnChanged = true,
  });

  /// التسمية الظاهرة (label)
  final String label;

  final TextEditingController? controller;

  /// نص إرشادي خفيف داخل الحقل
  final String? hint;

  /// نص مساعدة دائم أسفل الحقل
  final String? helper;

  /// نوع الحقل — يحدد لوحة المفاتيح والمنقّح
  final AppFieldType fieldType;

  /// دالة تحقق تُعيد **مفتاح ترجمة** أو `null`
  final String? Function(String?)? validator;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  final bool enabled;
  final bool autofocus;
  final int? maxLength;
  final IconData? prefixIcon;
  final Widget? suffix;

  /// إخفاء النص (كلمة المرور)
  final bool obscure;

  final TextInputAction? textInputAction;

  /// نص العدّاد — `''` لإخفائه
  final String? counterText;

  final String? semanticLabel;

  /// التحقق أثناء الكتابة (تجربة أفضل) أم عند الإرسال فقط
  final bool validateOnChanged;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  final GlobalKey<FormFieldState<String>> _fieldKey = GlobalKey<FormFieldState<String>>();

  bool _obscured = true;
  bool _touched = false;

  @override
  void dispose() {
    // لا نتحكم في lifecycle إلا إذا أنشأناه نحن
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  /// يترجم مفتاح الخطأ إلى نص — آمن: مفتاح غير معروف يعيد نصاً عاماً
  String _translateKey(String key) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return switch (key) {
      'validateRequired' => l10n.validateRequired,
      'validateEmailRequired' => l10n.validateEmailRequired,
      'validateEmailInvalid' => l10n.validateEmailInvalid,
      'validateEmailTooLong' => l10n.validateEmailTooLong,
      'validatePasswordRequired' => l10n.validatePasswordRequired,
      'validatePasswordTooShort' => l10n.validatePasswordTooShort,
      'validatePasswordNoDigit' => l10n.validatePasswordNoDigit,
      'validatePasswordTooLong' => l10n.validatePasswordTooLong,
      'validateConfirmMismatch' => l10n.validateConfirmMismatch,
      'validateNameTooLong' => l10n.validateNameTooLong,
      'validateAmountRequired' => l10n.validateAmountRequired,
      'validateAmountZero' => l10n.validateAmountZero,
      'validateAmountTooLarge' => l10n.validateAmountTooLarge,
      'validateAmountDecimals' => l10n.validateAmountDecimals,
      'validatePhoneAlgerian' => l10n.validatePhoneAlgerian,
      'validateNoteTooLong' => l10n.validateNoteTooLong,
      'validateTooLong' => l10n.validateTooLong(widget.maxLength ?? AppTokens.maxNoteLength),
      _ => l10n.validateRequired,
    };
  }

  /// منقّح الإدخال حسب نوع الحقل
  TextInputFormatter? _formatter() => switch (widget.fieldType) {
        // ⭐ لوحة أرقام + فواصل فقط، وخانتان عشريتان كحد أقصى
        AppFieldType.amount => TextInputFormatter.withFunction(
            (TextEditingValue oldValue, TextEditingValue newValue) {
              final String filtered = newValue.text
                  .replaceAll(RegExp(r'[^0-9.,\-]'), '');
              // إشارة سالبة واحدة في البداية فقط
              final bool negative = filtered.startsWith('-');
              final String digits = filtered.replaceAll('-', '');
              final int lastComma = digits.lastIndexOf(',');
              final int lastDot = digits.lastIndexOf('.');
              final int decIndex = lastComma > lastDot ? lastComma : lastDot;

              String whole = decIndex == -1 ? digits : digits.substring(0, decIndex);
              String fraction = decIndex == -1 ? '' : digits.substring(decIndex + 1);
              whole = whole.replaceAll(RegExp('[.,]'), '');
              fraction = fraction.replaceAll(RegExp('[.,]'), '');
              if (whole.length > 9) whole = whole.substring(0, 9);
              if (fraction.length > 2) fraction = fraction.substring(0, 2);

              final String rebuilt = '${negative ? '-' : ''}$whole'
                  '${decIndex == -1 ? '' : ','}$fraction';
              return TextEditingValue(
                text: rebuilt,
                selection: TextSelection.collapsed(offset: rebuilt.length),
              );
            },
          ),
        // ⭐ لوحة رقمية للهاتف مع السماح بـ + في البداية
        AppFieldType.phone => TextInputFormatter.withFunction(
            (TextEditingValue oldValue, TextEditingValue newValue) {
              String text = newValue.text;
              final bool hadPlus = text.startsWith('+');
              text = text.replaceAll(RegExp('[^0-9]'), '');
              if (text.length > 13) text = text.substring(0, 13);
              final String rebuilt = '${hadPlus ? '+' : ''}$text';
              return TextEditingValue(
                text: rebuilt,
                selection: TextSelection.collapsed(offset: rebuilt.length),
              );
            },
          ),
        AppFieldType.digitsOnly => FilteringTextInputFormatter.digitsOnly,
        AppFieldType.email ||
        AppFieldType.password ||
        AppFieldType.text ||
        AppFieldType.multiline => null,
      };

  TextInputType _keyboard() => switch (widget.fieldType) {
        AppFieldType.amount => const TextInputType.numberWithOptions(
            signed: true,
            decimal: true,
          ),
        AppFieldType.digitsOnly => TextInputType.number,
        AppFieldType.phone => TextInputType.phone,
        AppFieldType.email => TextInputType.emailAddress,
        AppFieldType.password => TextInputType.visiblePassword,
        AppFieldType.multiline => TextInputType.multiline,
        AppFieldType.text => TextInputType.text,
      };

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Semantics(
      textField: true,
      label: widget.semanticLabel ?? widget.label,
      child: TextFormField(
        key: _fieldKey,
        controller: _controller,
        enabled: widget.enabled,
        autofocus: widget.autofocus,
        obscureText: widget.obscure && _obscured,
        keyboardType: _keyboard(),
        textInputAction: widget.textInputAction ??
            (widget.fieldType == AppFieldType.multiline
                ? TextInputAction.newline
                : TextInputAction.next),
        inputFormatters: <TextInputFormatter>[
          if (_formatter() != null) _formatter()!,
          if (widget.maxLength != null)
            LengthLimitingTextInputFormatter(widget.maxLength),
        ],
        maxLines: widget.obscure || widget.fieldType != AppFieldType.multiline
            ? 1
            : 4,
        minLines: widget.fieldType == AppFieldType.multiline ? 2 : 1,
        maxLength: widget.fieldType == AppFieldType.multiline ? widget.maxLength : null,
        style: AppTypography.textTheme.bodyLarge?.copyWith(
          color: scheme.onSurface,
        ),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          helperText: widget.helper,
          counterText: widget.counterText,
          prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
          suffixIcon: _buildSuffix(scheme),
        ),
        validator: (String? value) {
          final String? key = widget.validator?.call(value);
          return key == null ? null : _translateKey(key);
        },
        onChanged: (String value) {
          // نُعلّم الحقل «ملموساً» عند أول تغيير، ثم نتحقق فورياً بعده.
          // ⭐ setState ضروري هنا حتى لا تبقى رسالة الخطأ ظاهرة
          //   بعد أن يصحّح المستخدم (قاعدة: تحقق فوري أثناء الكتابة).
          if (!_touched) {
            setState(() => _touched = true);
          } else if (widget.validateOnChanged) {
            _fieldKey.currentState?.validate();
          }
          widget.onChanged?.call(value);
        },
        onFieldSubmitted: widget.onSubmitted,
      ),
    );
  }

  Widget? _buildSuffix(ColorScheme scheme) {
    if (widget.obscure) {
      final AppLocalizations l10n = AppLocalizations.of(context);
      return IconButton(
        onPressed: () => setState(() => _obscured = !_obscured),
        icon: Icon(
          _obscured
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
        ),
        // ⚠️ النص من ملفات الترجمة — لا نصوص مكتوبة يدوياً أبداً
        tooltip: _obscured ? l10n.fieldShowPassword : l10n.fieldHidePassword,
        iconSize: 22,
        // هدف لمس ≥ 48dp
        constraints: const BoxConstraints(
          minWidth: AppTokens.minTouchTarget,
          minHeight: AppTokens.minTouchTarget,
        ),
      );
    }
    return widget.suffix;
  }
}

/// أنواع الحقول — تحدد لوحة المفاتيح والمنقّح
enum AppFieldType {
  /// نص عادي
  text,

  /// عدة أسطر (ملاحظة)
  multiline,

  /// بريد إلكتروني — لوحة @
  email,

  /// كلمة مرور — إخفاء + زر إظهار
  password,

  /// ⭐ مبلغ مالي — لوحة أرقام مع فاصلة عشرية وإشارة
  amount,

  /// ⭐ رقم هاتف — لوحة هاتف، يقبل + في البداية
  phone,

  /// أرقام فقط (يوم المرساة، سنة)
  digitsOnly,
}
