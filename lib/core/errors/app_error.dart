import 'package:falousna/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

import '../theme/design_tokens.dart';

/// ═══════════════════════════════════════════════════════════════
///  AppError — أنواع الأخطاء في التطبيق
///
///  ⚠️ قاعدة إلزامية: المستخدم يرى رسالة عربية/فرنسية مفهومة.
///     التفاصيل التقنية (stack trace، رسائل السيرفر الخام) تُسجَّل
///     في log_only ولا تظهر للمستخدم أبداً.
/// ═══════════════════════════════════════════════════════════════

/// تصنيف الخطأ — يحدد الأيقونة واللون والسلوك
enum AppErrorKind {
  /// تحقق من مدخلات المستخدم
  validation,

  /// شبكة / إنترنت
  network,

  /// انتهاء مهلة
  timeout,

  /// صلاحية / دور
  permission,

  /// ميزة مقفلة (انتهاء التجربة)
  featureLocked,

  /// تعارض مزامنة
  syncConflict,

  /// تخزين محلي
  storage,

  /// غير متوقع
  unknown,
}

/// خطأ التطبيق — يحمل مفتاح ترجمة لا نصاً جاهزاً
/// (حتى يعمل بالعربية والفرنسية معاً)
class AppError implements Exception {
  const AppError({
    required this.kind,
    required this.messageKey,
    this.titleKey,
    this.details,
    this.logOnly,
    this.recoverable = true,
  });

  // ─────────────────────────────────────────────────────────────
  //  بُناة الأخطاء الشائعة
  // ─────────────────────────────────────────────────────────────

  /// خطأ تحقق من المدخلات — [messageKey] مفتاح في ملفات .arb
  factory AppError.validation(String messageKey, {String? details}) => AppError(
        kind: AppErrorKind.validation,
        messageKey: messageKey,
        titleKey: 'errorValidationTitle',
        details: details,
      );

  /// لا يوجد اتصال بالإنترنت
  factory AppError.network({String? logOnly}) => AppError(
        kind: AppErrorKind.network,
        messageKey: 'errorNetworkBody',
        titleKey: 'errorNetworkTitle',
        logOnly: logOnly,
        recoverable: true,
      );

  /// انتهت المهلة
  factory AppError.timeout() => const AppError(
        kind: AppErrorKind.timeout,
        messageKey: 'errorNetworkBody',
        titleKey: 'errorNetworkTitle',
      );

  /// لا يملك الصلاحية (دور خاطئ)
  factory AppError.permission() => const AppError(
        kind: AppErrorKind.permission,
        messageKey: 'errorPermissionBody',
        titleKey: 'errorPermissionTitle',
        recoverable: false,
      );

  /// الميزة مقفلة (انتهت التجربة المجانية)
  factory AppError.featureLocked() => const AppError(
        kind: AppErrorKind.featureLocked,
        messageKey: 'errorFeatureLockedBody',
        titleKey: 'errorFeatureLockedTitle',
        recoverable: false,
      );

  /// تعارض في المزامنة
  factory AppError.syncConflict({String? details}) => AppError(
        kind: AppErrorKind.syncConflict,
        messageKey: 'errorGenericBody',
        titleKey: 'errorGenericTitle',
        details: details,
      );

  /// فشل في التخزين المحلي
  factory AppError.storage({String? logOnly}) => AppError(
        kind: AppErrorKind.storage,
        messageKey: 'errorGenericBody',
        titleKey: 'errorGenericTitle',
        logOnly: logOnly,
      );

  /// خطأ غير متوقع — يُلتقط من أي Exception غريب
  factory AppError.unknown({Object? cause, StackTrace? stackTrace}) => AppError(
        kind: AppErrorKind.unknown,
        messageKey: 'errorUnknownBody',
        titleKey: 'errorUnknownTitle',
        logOnly: stackTrace == null ? '$cause' : '$cause\n$stackTrace',
        recoverable: true,
      );

  /// عملتان بعملتين مختلفتين (مثلاً جمع EUR + DZD)
  factory AppError.currencyMismatch({required String a, required String b}) => AppError(
        kind: AppErrorKind.validation,
        messageKey: 'errorGenericBody',
        titleKey: 'errorGenericTitle',
        details: 'currency mismatch: $a vs $b',
        logOnly: 'Cannot operate on $a and $b without an exchange rate',
      );

  /// المبلغ تجاوز الحد الأقصى المسموح
  factory AppError.amountOverflow() => const AppError(
        kind: AppErrorKind.validation,
        messageKey: 'validateAmountTooLarge',
        titleKey: 'errorValidationTitle',
      );

  // ─────────────────────────────────────────────────────────────
  //  الحقول
  // ─────────────────────────────────────────────────────────────

  /// تصنيف الخطأ
  final AppErrorKind kind;

  /// مفتاح رسالة الجسم في ملفات .arb — ⚠️ مفتاح لا نص
  final String messageKey;

  /// مفتاح رسالة العنوان في ملفات .arb
  final String? titleKey;

  /// تفاصيل تقنية موجزة — تُسجَّل، ولا تُعرض للمستخدم
  final String? details;

  /// معلومات للسجل فقط (رسالة السيرفر الخام، stack trace موجز)
  /// 🔴 لا تعرضها للمستخدم أبداً
  final String? logOnly;

  /// هل يمكن للمستخدم المحاولة مرة أخرى؟
  final bool recoverable;

  // ─────────────────────────────────────────────────────────────
  //  العرض للمستخدم
  // ─────────────────────────────────────────────────────────────

  /// نص الجسم مترجماً — آمن: إن لم يوجد المفتاح يعيد نصاً عاماً
  String body(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return switch (messageKey) {
      'errorGenericBody' => l10n.errorGenericBody,
      'errorNetworkBody' => l10n.errorNetworkBody,
      'errorUnknownBody' => l10n.errorUnknownBody,
      'errorPermissionBody' => l10n.errorPermissionBody,
      'errorFeatureLockedBody' => l10n.errorFeatureLockedBody,
      'validateRequired' => l10n.validateRequired,
      'validateTooLong' => l10n.validateTooLong(AppTokens.maxCategoryNameLength),
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
      _ => l10n.errorGenericBody,
    };
  }

  /// نص العنوان مترجماً
  String title(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return switch (titleKey) {
      'errorGenericTitle' => l10n.errorGenericTitle,
      'errorNetworkTitle' => l10n.errorNetworkTitle,
      'errorUnknownTitle' => l10n.errorUnknownTitle,
      'errorValidationTitle' => l10n.errorValidationTitle,
      'errorPermissionTitle' => l10n.errorPermissionTitle,
      'errorFeatureLockedTitle' => l10n.errorFeatureLockedTitle,
      _ => l10n.errorGenericTitle,
    };
  }

  /// هل يجب إظهار زر «إعادة المحاولة»؟
  bool get showsRetryButton => recoverable && kind != AppErrorKind.featureLocked;

  /// اسم أيقونة مناسب (يُقرأ في error_state.dart)
  String get iconName => switch (kind) {
        AppErrorKind.network => 'wifi_off',
        AppErrorKind.timeout => 'timer_off',
        AppErrorKind.permission => 'lock',
        AppErrorKind.featureLocked => 'lock_clock',
        AppErrorKind.syncConflict => 'sync_problem',
        AppErrorKind.storage => 'sd_card_alert',
        AppErrorKind.validation => 'error',
        AppErrorKind.unknown => 'report',
      };

  @override
  String toString() =>
      'AppError(kind: ${kind.name}, messageKey: $messageKey, details: $details)';
}

/// يلتقط أي استثناء ويحوّله إلى AppError آمن للعرض
///
/// ⚠️ استعمله في كل عملية قد تفشل (قاعدة 3: Error Handling حقيقي)
AppError captureError(Object error, [StackTrace? stackTrace]) {
  if (error is AppError) return error;
  return AppError.unknown(cause: error, stackTrace: stackTrace);
}
