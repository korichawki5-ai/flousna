import '../config/constants.dart';

/// ═══════════════════════════════════════════════════════════════
///  Validators — التحقق من المدخلات في الواجهة (UX)
///
///  ⚠️ قاعدة إلزامية: هذا التحقق **للواجهة فقط** (تجربة المستخدم).
///     التحقق الأمني الحقيقي في السيرفر عبر RLS + CHECK constraints.
///     (المرحلة 2 — قاعدة 3 من الأمان: تحقق مزدوج)
///
///  ✅ كل دالة تُعيد `null` عند الصحة، أو **مفتاح ترجمة** عند الخطأ.
///     المفاتيح تُترجم في widgets/app_text_field.dart — حتى تعمل
///     بالعربية والفرنسية معاً.
/// ═══════════════════════════════════════════════════════════════
abstract final class Validators {
  /// بريد إلكتروني — نمط عملي متسامح (لا regex أكاديمي معقّد)
  ///
  /// يقبل: name@mail.com · name+tag@sub.domain.co
  /// يرفض: بلا @ · بلا نقطة بعد @ · مسافات
  static final RegExp _emailPattern = RegExp(
    r'^[a-zA-Z0-9.!#$%&''*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?'
    r'(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$',
  );

  /// رقم هاتف جزائري: 05/06/07 (10 أرقام) أو +213 (5|6|7)XXXXXXXX
  ///
  /// ⚠️ لن يُطلب في التسجيل (تقليل البيانات — القانون 18-07)
  /// يُستعمل في حقل «الطرف» داخل شاشة الديون وفي معلومات الاتصال الاختيارية
  static final RegExp _algerianPhoneLocal = RegExp(r'^(0)(5|6|7)[0-9]{8}$');
  static final RegExp _algerianPhoneIntl = RegExp(r'^\+213(5|6|7)[0-9]{8}$');
  static final RegExp _digitsOnly = RegExp(r'^[0-9]+$');

  /// كلمة مرور قوية بما يكفي — 8 محارف على الأقل مع رقم واحد
  ///
  /// ⚠️ لا نطلب رموزاً خاصة: في الجزائر ذلك يقلل التسجيل أكثر مما يحمي.
  ///     الحماية الحقيقية = طول + رقم + bcrypt على السيرفر.
  static final RegExp _hasDigit = RegExp('[0-9]');

  // ─────────────────────────────────────────────────────────────
  //  البريد الإلكتروني
  // ─────────────────────────────────────────────────────────────

  /// يُعيد مفتاح الترجمة للخطأ، أو `null` إن كان البريد صالحاً
  static String? email(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) return 'validateEmailRequired';
    if (text.length > AppConstants.maxEmailLength) return 'validateEmailTooLong';
    if (!_emailPattern.hasMatch(text)) return 'validateEmailInvalid';
    return null;
  }

  // ─────────────────────────────────────────────────────────────
  //  كلمة المرور
  // ─────────────────────────────────────────────────────────────

  static String? password(String? value) {
    final String text = value ?? '';
    if (text.isEmpty) return 'validatePasswordRequired';
    if (text.length < AppConstants.minPasswordLength) return 'validatePasswordTooShort';
    if (text.length > AppConstants.maxPasswordLength) return 'validatePasswordTooLong';
    if (!_hasDigit.hasMatch(text)) return 'validatePasswordNoDigit';
    return null;
  }

  /// تأكيد كلمة المرور — يُمرَّر الأصل للتطابق
  static String? confirmPassword(String? value, String original) {
    final String text = value ?? '';
    if (text.isEmpty) return 'validatePasswordRequired';
    if (text != original) return 'validateConfirmMismatch';
    return null;
  }

  // ─────────────────────────────────────────────────────────────
  //  الاسم والعرض
  // ─────────────────────────────────────────────────────────────

  /// اسم عرض اختياري — الطول فقط (لا نطلب اسماً حقيقياً)
  static String? displayName(String? value) {
    final String text = (value ?? '').trim();
    if (text.length > AppConstants.maxDisplayNameLength) return 'validateNameTooLong';
    return null;
  }

  /// اسم مطلوب (فئة مخصصة، هدف، طرف دين)
  static String? requiredName(String? value, {int maxLength = 60}) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) return 'validateRequired';
    if (text.length > maxLength) return 'validateTooLong';
    return null;
  }

  // ─────────────────────────────────────────────────────────────
  //  المبالغ
  // ─────────────────────────────────────────────────────────────

  /// مبلغ مالي — يتحقق من الصيغة والحدود
  ///
  /// ⚠️ التحقق الدقيق في Money.tryParse (بأعداد صحيحة).
  ///     هنا فحص سريع أثناء الكتابة لتجربة مستخدم فورية.
  static String? amount(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) return 'validateAmountRequired';

    // إزالة رموز العملة والمسافات
    final String cleaned = text
        .replaceAll('\u00A0', '')
        .replaceAll(' ', '')
        .replaceAll('دج', '')
        .replaceAll('DA', '')
        .replaceAll('DZD', '')
        .replaceAll('€', '')
        .replaceAll(r'$', '')
        .trim();

    if (cleaned.isEmpty) return 'validateAmountRequired';

    // محارف مسموحة: أرقام، فواصل، إشارة سالبة واحدة في البداية
    final RegExp allowed = RegExp(r'^-?[0-9.,\s]+$');
    if (!allowed.hasMatch(cleaned)) return 'validateAmountRequired';

    // خانتان عشريتان كحد أقصى
    final int lastComma = cleaned.lastIndexOf(',');
    final int lastDot = cleaned.lastIndexOf('.');
    final int decimalIndex = lastComma > lastDot ? lastComma : lastDot;
    if (decimalIndex != -1) {
      final String fraction = cleaned.substring(decimalIndex + 1);
      final String digitsOnly = fraction.replaceAll(RegExp('[^0-9]'), '');
      if (digitsOnly.length > 2) return 'validateAmountDecimals';
    }

    // القيمة يجب أن تكون أكبر من صفر
    final String withoutSeparators =
        decimalIndex == -1 ? cleaned : cleaned.substring(0, decimalIndex);
    final String wholeDigits = withoutSeparators.replaceAll(RegExp('[^0-9]'), '');
    if (wholeDigits.isEmpty || !_digitsOnly.hasMatch(wholeDigits)) {
      return 'validateAmountRequired';
    }
    if (wholeDigits.length > 9) return 'validateAmountTooLarge';

    final int wholeValue = int.tryParse(wholeDigits) ?? 0;
    if (wholeValue == 0 && decimalIndex == -1) return 'validateAmountZero';

    return null;
  }

  // ─────────────────────────────────────────────────────────────
  //  رقم الهاتف الجزائري
  // ─────────────────────────────────────────────────────────────

  /// رقم هاتف جزائري — يقبل الصيغتين المحلية والدولية
  ///
  /// ✅ صالح: 0555123456 · 0661234567 · 0770123456 · +213555123456
  /// ❌ غير صالح: 055512345 (9 أرقام) · 0412345678 (يبدأ بـ04) · 555123456
  static String? algerianPhone(String? value) {
    final String text = (value ?? '').trim().replaceAll(RegExp(r'[\s\-()]'), '');
    if (text.isEmpty) return null; // اختياري افتراضياً
    if (_algerianPhoneLocal.hasMatch(text)) return null;
    if (_algerianPhoneIntl.hasMatch(text)) return null;
    return 'validatePhoneAlgerian';
  }

  /// تطبيع رقم الهاتف الجزائري إلى الصيغة الدولية
  ///
  /// 0555123456 ←→ +213555123456
  /// يُعيد `null` إن كان الرقم غير صالح
  static String? normalizeAlgerianPhone(String? value) {
    final String text = (value ?? '').trim().replaceAll(RegExp(r'[\s\-()]'), '');
    if (text.isEmpty) return null;
    if (_algerianPhoneLocal.hasMatch(text)) {
      // 0555123456 → +213555123456 (حذف الصفر البادئ وإضافة 213)
      return '+213${text.substring(1)}';
    }
    if (_algerianPhoneIntl.hasMatch(text)) return text;
    return null;
  }

  // ─────────────────────────────────────────────────────────────
  //  الملاحظات والنصوص الطويلة
  // ─────────────────────────────────────────────────────────────

  static String? note(String? value, {int maxLength = AppConstants.maxNoteLength}) {
    final String text = value ?? '';
    if (text.length > maxLength) return 'validateNoteTooLong';
    return null;
  }

  /// حقل اختياري بطول أقصى
  static String? optionalMaxLength(String? value, int maxLength, String errorKey) {
    final String text = value ?? '';
    if (text.length > maxLength) return errorKey;
    return null;
  }

  // ─────────────────────────────────────────────────────────────
  //  يوم بداية الشهر المالي
  // ─────────────────────────────────────────────────────────────

  /// يتحقق من يوم المرساة: 1..28 فقط
  ///
  /// ⚠️ 29/30/31 غير مدعومة لأنها غير موجودة في بعض الشهور،
  ///     وهذا يُربك حساب الفترات ويُنتج مقارنات غير عادلة.
  static bool isValidFiscalAnchorDay(int day) =>
      day >= AppConstants.minFiscalAnchorDay && day <= AppConstants.maxFiscalAnchorDay;

  // ─────────────────────────────────────────────────────────────
  //  أداة عامة: دمج عدة قواعد
  // ─────────────────────────────────────────────────────────────

  /// يطبّق عدة قواعد بالترتيب ويُعيد أول خطأ
  ///
  /// ```dart
  /// validator: Validators.compose([Validators.email, Validators.notBanned])
  /// ```
  static String? Function(String?) compose(List<String? Function(String?)> rules) {
    return (String? value) {
      for (final String? Function(String?) rule in rules) {
        final String? error = rule(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
