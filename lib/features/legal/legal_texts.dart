import 'package:falousna/l10n/app_localizations.dart';

import '../../core/config/app_config.dart';
import '../../core/config/constants.dart';

/// ═══════════════════════════════════════════════════════════════
///  LegalTexts — النصوص القانونية المعروضة داخل التطبيق
///
///  ⭐ مصدر واحد: نفس النصوص تُعرض في شاشة الموافقة (قبل الدخول)
///     وفي شاشة «القانوني والخصوصية» (بعد الدخول) — لا تكرار ولا
///     اختلاف بين النسختين.
///
///  ⚠️ كل جملة تأتي من ملفات .arb (لا نص مكتوب يدوياً هنا)، فتعمل
///     العربية والفرنسية من نفس المصدر. القيم الوحيدة المضافة هي
///     بيانات الاتصال من `AppConfig` (بريد DPO ورابط الشكاوى).
///
///  🟡 في المرحلة 5 تُستبدل بالوثائق القانونية الكاملة المراجَعة
///     من محامٍ، وتُقرأ من `assets/legal/` مع رفع إصدار السياسة —
///     رفع الإصدار يُبطل الموافقات القديمة ويطلب موافقة جديدة،
///     وهذا مطلوب عند أي تعديل جوهري (القانون 18-07).
/// ═══════════════════════════════════════════════════════════════
abstract final class LegalTexts {
  /// سياسة الخصوصية — النص الكامل المعروض
  static String privacy(AppLocalizations l10n) => '''
${l10n.legalPrivacy} — ${l10n.consentVersionLabel(AppConstants.privacyPolicyVersion)}

${l10n.consentPoint1Title}
${l10n.consentPoint1Body}

${l10n.consentPoint2Title}
${l10n.consentPoint2Body}

${l10n.consentPoint3Title}
${l10n.consentPoint3Body}

${l10n.legalRightsTitle}
${l10n.legalRightsBody}

${l10n.consentRecordedNote}

─────────────────────────────

${l10n.legalExportData}
${l10n.legalExportDataNote}

${l10n.legalDeleteAccount}
${l10n.legalDeleteAccountNote}

${l10n.legalDpoContact}: ${AppConfig.dpoEmail}
${l10n.legalComplaintAnpdp}: ${AppConstants.anpdpComplaintUrl}
''';

  /// شروط الاستخدام — النص الكامل المعروض
  static String terms(AppLocalizations l10n) => '''
${l10n.legalTerms} — ${l10n.consentVersionLabel(AppConstants.termsVersion)}

${l10n.aboutAppDescription}

${l10n.aboutNoBrandsNote}

${l10n.authGuestLimitNote}

${l10n.errorFeatureLockedBody}
''';

  /// إخلاء المسؤولية — طبيعة الأداة وحدودها
  ///
  /// 🔴 جوهر الحماية القانونية: التطبيق أداة تسجيل يدوي، ليس بنكاً
  ///    ولا محفظة ولا خدمة دفع، ولا يقدّم نصيحة مالية.
  static String disclaimer(AppLocalizations l10n) => '''
${l10n.legalDisclaimer}

${l10n.legalDisclaimerBody}
''';

  /// شروط الاشتراك والاسترداد — نموذج العمل المعتمد
  ///
  /// 🔴 لا تُذكر أي وسيلة دفع بالاسم ولا أي رقم حساب: تفاصيل الدفع
  ///    تُرسَل يدوياً داخل محادثة واتساب (قرار المالك).
  static String subscription(AppLocalizations l10n) => '''
${l10n.legalSubscription} — ${l10n.consentVersionLabel(AppConstants.subscriptionTermsVersion)}

${l10n.legalSubscriptionBody}
''';
}
