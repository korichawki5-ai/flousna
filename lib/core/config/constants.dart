/// ═══════════════════════════════════════════════════════════════
///  ثوابت التطبيق العامة
/// ═══════════════════════════════════════════════════════════════
abstract final class AppConstants {
  // ── الهوية ──
  static const String appName = 'فلوسنا';
  static const String appNameLatin = 'Falousna';
  // ⚠️ اسم الحزمة المعتمد هويةً للتطبيق.
  //    `flutter create` يولّد افتراضياً `dz.falousna.falousna` في
  //    android/app/build.gradle.kts — نوحّده مع هذا الاسم في المرحلة 6 عند
  //    التوقيع والنشر (لا أثر له إطلاقاً على التشغيل التجريبي الآن).
  static const String packageId = 'dz.falousna.app';
  static const String tagline = 'اعرف فين راحت فلوسك';

  // ── الإصدار (يجب أن يطابق pubspec.yaml) ──
  static const String version = '1.0.0';
  static const int buildNumber = 100;

  // ── اللغات المدعومة ──
  static const String localeArabic = 'ar_DZ';
  static const String localeFrench = 'fr_DZ';
  static const List<String> supportedLocales = <String>[localeArabic, localeFrench];

  // ── العملات ──
  /// العملة الأساسية (كل التقارير تُجمع بها)
  static const String baseCurrency = 'DZD';

  /// العملات المدعومة (EUR و USD في الإصدار 1.x)
  static const List<String> supportedCurrencies = <String>['DZD', 'EUR', 'USD'];

  /// رمز العملة حسب اللغة — الرمز بعد الرقم في RTL
  static const Map<String, String> currencySymbols = <String, String>{
    'DZD': 'دج',
    'EUR': '€',
    'USD': r'$',
  };

  /// رمز العملة حسب اللغة الفرنسية
  static const Map<String, String> currencySymbolsFr = <String, String>{
    'DZD': 'DA',
    'EUR': '€',
    'USD': r'$',
  };

  // ── أنواع أسعار الصرف (السوقان في الجزائر) ──
  static const String rateOfficial = 'official';
  static const String rateParallel = 'parallel';

  // ── طرق الدفع — قيم محايدة تماماً، صفر أسماء مؤسسات ──
  static const String paymentCash = 'cash';
  static const String paymentBankTransfer = 'bank_transfer';
  static const String paymentPostalTransfer = 'postal_transfer';
  static const String paymentCard = 'card';
  static const String paymentEWallet = 'e_wallet';
  static const String paymentCredit = 'credit';
  static const String paymentOther = 'other';

  static const List<String> paymentMethods = <String>[
    paymentCash,
    paymentBankTransfer,
    paymentPostalTransfer,
    paymentCard,
    paymentEWallet,
    paymentCredit,
    paymentOther,
  ];

  // ── الباقات ──
  static const String planIndividual = 'individual';
  static const String planCouple = 'couple';
  static const String planFamily = 'family';

  /// الأسعار بالدينار الجزائري — تُقرأ من جدول plans في Supabase
  /// هذه قيم افتراضية للبداية فقط (تُحدَّث من لوحة الإدارة بلا تحديث التطبيق)
  static const Map<String, ({int monthly, int yearly})> defaultPricesDzd =
      <String, ({int monthly, int yearly})>{
    planIndividual: (monthly: 300, yearly: 2500),
    planCouple: (monthly: 450, yearly: 3900),
    planFamily: (monthly: 650, yearly: 5500),
  };

  // ── حالة الاشتراك ──
  static const String statusTrialing = 'trialing';
  static const String statusActive = 'active';
  static const String statusGrace = 'grace';
  static const String statusPastDue = 'past_due';
  static const String statusCanceled = 'canceled';

  // ── الأدوار ──
  static const String roleUser = 'user';
  static const String roleAdmin = 'admin';

  // ── أنواع الموافقات (القانون 18-07) ──
  /// ⚠️ ثلاث موافقات منفصلة — لا يجوز تجميعها في صندوق واحد
  static const String consentPrivacyTerms = 'privacy_terms';
  static const String consentCrossBorderSync = 'cross_border_sync';
  static const String consentMarketingEmail = 'marketing_email';

  /// إصدار السياسة الحالية — يُرفع عند كل تعديل جوهري
  static const String privacyPolicyVersion = '1.0.0';
  static const String termsVersion = '1.0.0';
  static const String subscriptionTermsVersion = '1.0.0';

  // ─────────────────────────────────────────────────────────────
  //  حدود التحقق والمدة التجريبية والمرساة المالية
  // ─────────────────────────────────────────────────────────────

  /// مدة التجربة الكاملة بالأيام (نموذج العمل: 7 أيام ثم اشتراك)
  static const int trialDays = 7;

  /// يوم المرساة المالية (بداية الشهر المالي): من 1 إلى 28 فقط —
  /// 29/30/31 غير موجودة في بعض الشهور فتُربك حساب الفترات
  static const int minFiscalAnchorDay = 1;
  static const int maxFiscalAnchorDay = 28;

  /// الحد الأقصى لطول البريد الإلكتروني (عملياً وفق RFC 5321)
  static const int maxEmailLength = 254;

  /// حدود كلمة المرور: 8 محارف كحد أدنى (رقم واحد على الأقل) و128 أقصى
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;

  /// الحد الأقصى لطول الاسم المعروض
  static const int maxDisplayNameLength = 60;

  /// أقصى طول لاسم فئة مخصصة (عربي أو فرنسي) — مصدر واحد
  static const int maxCategoryNameLength = 40;

  /// الحد الأقصى لطول ملاحظة العملية
  static const int maxNoteLength = 200;

  /// أقصى قيمة للجزء الصحيح من المبلغ — NUMERIC(14,2) تعني
  /// 12 خانة صحيحة كحد أقصى (999.999.999.999)
  static const int maxAmountWhole = 999999999999;

  // ── الحقوق الخمسة (القانون 18-07 المواد 32-37 + طوعي) ──
  static const String rightAccess = 'access';
  static const String rightRectification = 'rectification';
  static const String rightObjection = 'objection';
  static const String rightErasure = 'erasure';
  static const String rightPortability = 'portability';

  /// المدة القصوى للاستجابة لطلب حقوق المستخدم (بالساعات)
  static const int dataRequestResponseHours = 72;

  // ── الولايات الجزائرية (58) ──
  static const int wilayaCount = 58;

  // ── الدورة المالية ──
  /// بداية الأسبوع: السبت (المعيار الجزائري)
  static const int weekStartsOnWeekday = DateTime.saturday;

  // ── قيود الأمان ──
  /// الحد الأقصى لطلبات رمز التفعيل (منع البوتات)
  static const int activationCodeRateLimit = 3;
  static const Duration activationCodeRateWindow = Duration(hours: 1);

  /// طول رمز الطلب: FL-XXXX-XXXX
  static const int requestCodeLength = 8;
  static const String requestCodePrefix = 'FL-';

  // ── روابط خارجية ──
  static const String anpdpPortalUrl = 'https://portail.anpdp.dz';
  static const String anpdpComplaintUrl = 'https://plaintes.anpdp.dz';
  static const String anpdpSiteUrl = 'https://anpdp.dz';

  /// ⚠️ هذه قيم افتراضية — تُستبدل من .env عند الإعداد
  static const String fallbackDownloadSite = 'https://falousna.pages.dev';
  static const String fallbackDpoEmail = 'privacy@falousna.dz';
  static const String fallbackSupportEmail = 'support@falousna.dz';

  // ── التخزين المحلي (مفاتيح shared_preferences) ──
  static const String keyConsentGranted = 'consent_privacy_granted';
  static const String keyConsentGrantedAt = 'consent_privacy_granted_at';
  static const String keyConsentVersion = 'consent_privacy_version';
  static const String keyConsentHash = 'consent_privacy_hash';
  static const String keyOnboardingDone = 'onboarding_completed';
  static const String keySetupDone = 'setup_completed';
  static const String keyGuestMode = 'guest_mode_active';
  static const String keyTrialStartedAt = 'trial_started_at';
  static const String keyDeviceInstallId = 'device_install_id';
  static const String keyHighestSeenTs = 'highest_seen_timestamp';
  static const String keyClockTamperFlag = 'clock_tamper_flag';
  static const String keyLocale = 'preferred_locale';
  static const String keyThemeMode = 'theme_mode';
  static const String keyFiscalAnchorDay = 'fiscal_anchor_day';
  static const String keyBudgetMode = 'budget_mode';
  static const String keyBaseCurrency = 'base_currency';

  // ── التخزين الآمن (flutter_secure_storage) ──
  static const String secureSessionToken = 'session_token';
  static const String secureUserId = 'user_id';
}
