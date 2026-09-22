import 'constants.dart';

/// ═══════════════════════════════════════════════════════════════
///  AppConfig — إعدادات البناء (تُحقن وقت الترجمة)
///
///  ⭐ لماذا `String.fromEnvironment` بدل قراءة ملف .env؟
///     1. لا حزمة إضافية (ولا تسريب مفاتيح في الـ APK)
///     2. القيم تُثبَّت في البناء → لا يمكن تعديلها على جهاز المستخدم
///     3. نفس الأسماء المذكورة في `.env.example` تُمرَّر بأمر البناء:
///
///        flutter build apk --release \
///          --dart-define=RELEASE_STATE=live \
///          --dart-define=DPO_EMAIL=privacy@falousna.dz \
///          --dart-define=WHATSAPP_BUSINESS_NUMBER=213XXXXXXXXX
///
///  🔴 القاعدة القانونية الحاكمة (وثيقة 04):
///     ما دام RELEASE_STATE على قيمة draft التطبيق **لا يجمع ولا يرسل أي
///     بيانات** — لأن التصريح لدى ANPDP لم يُودَع بعد (المادة 12).
///     لذلك كل ميزة سحابية تفحص `AppConfig.canProcessPersonalData`
///     قبل أي إرسال، وترفض بصمتٍ آمن إن كانت false.
/// ═══════════════════════════════════════════════════════════════
abstract final class AppConfig {
  // ─────────────────────────────────────────────────────────────
  //  متغيرات البناء
  // ─────────────────────────────────────────────────────────────

  /// حالة النشر: `draft` (افتراضي آمن) أو `live`
  static const String releaseState = String.fromEnvironment(
    'RELEASE_STATE',
    defaultValue: 'draft',
  );

  /// بيئة التشغيل: `development` أو `production`
  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  /// بريد مندوب حماية المعطيات (القانون 25-11)
  static const String dpoEmail = String.fromEnvironment(
    'DPO_EMAIL',
    defaultValue: AppConstants.fallbackDpoEmail,
  );

  /// بريد الدعم العام
  static const String supportEmail = String.fromEnvironment(
    'SUPPORT_EMAIL',
    defaultValue: AppConstants.fallbackSupportEmail,
  );

  /// رقم واتساب التجاري — بالصيغة الدولية بلا + (213XXXXXXXXX)
  static const String whatsappBusinessNumber = String.fromEnvironment(
    'WHATSAPP_BUSINESS_NUMBER',
    defaultValue: '213000000000',
  );

  // ── قنوات التواصل الرسمية (تسويق) ──
  // 🔴 الفارغ = قناة مخفية تماماً في الواجهة (قاعدة صفر روابط ميتة).
  // ⏸️ من المرحلة 4: تُدار هذه القيم من لوحة الإدارة **بدون كود** عبر
  //    إعداد بعيد فوق المزامنة (المرحلة 3) — نفس المزوّد، بلا تغيير شاشة.
  static const String socialFacebookUrl =
      String.fromEnvironment('SOCIAL_FACEBOOK_URL');
  static const String socialInstagramUrl =
      String.fromEnvironment('SOCIAL_INSTAGRAM_URL');
  static const String socialTiktokUrl =
      String.fromEnvironment('SOCIAL_TIKTOK_URL');
  static const String socialXUrl = String.fromEnvironment('SOCIAL_X_URL');
  static const String socialYoutubeUrl =
      String.fromEnvironment('SOCIAL_YOUTUBE_URL');
  static const String socialTelegramUrl =
      String.fromEnvironment('SOCIAL_TELEGRAM_URL');
  static const String socialWhatsappUrl =
      String.fromEnvironment('SOCIAL_WHATSAPP_URL');

  /// موقع التحميل (APK + مُثبّت Windows)
  static const String downloadSiteUrl = String.fromEnvironment(
    'DOWNLOAD_SITE_URL',
    defaultValue: AppConstants.fallbackDownloadSite,
  );

  /// ملف الإصدار للتحديثات خارج المتجر
  static const String versionJsonUrl = String.fromEnvironment(
    'VERSION_JSON_URL',
    defaultValue: '${AppConstants.fallbackDownloadSite}/version.json',
  );

  /// عنوان Supabase (فارغ = لا مزامنة في هذا البناء)
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  /// مفتاح anon — ⚠️ آمن داخل التطبيق لأن RLS هي الحماية الفعلية.
  /// 🔴 مفتاح service_role لا يُحقن هنا أبداً (Edge Functions فقط).
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  /// رقم التصريح المودَع لدى ANPDP — دليل قانوني
  static const String anpdpDeclarationNumber = String.fromEnvironment(
    'ANPDP_DECLARATION_NUMBER',
  );

  // ─────────────────────────────────────────────────────────────
  //  بوابات قانونية وتشغيلية
  // ─────────────────────────────────────────────────────────────

  /// هل البناء في حالة «مسودة» (غير منشور)؟
  static bool get isDraft => releaseState != 'live';

  /// هل هو بناء إنتاج؟
  static bool get isProduction => appEnv == 'production';

  /// 🔴 هل يجوز معالجة/إرسال بيانات شخصية في هذا البناء؟
  ///
  /// تتطلب معاً:
  ///   1. `RELEASE_STATE=live`
  ///   2. رقم تصريح ANPDP موجود (المادة 12 من القانون 18-07)
  ///
  /// ما دام الجواب «لا»، كل الشبكات تُعطَّل ويُمنع النقل خارج الوطن
  /// (المادة 44) — وهذا هو الوضع الافتراضي الآمن.
  static bool get canProcessPersonalData =>
      !isDraft && anpdpDeclarationNumber.trim().isNotEmpty;

  /// هل المزامنة السحابية ممكنة في هذا البناء؟
  static bool get isSyncConfigured =>
      canProcessPersonalData &&
      supabaseUrl.trim().isNotEmpty &&
      supabaseAnonKey.trim().isNotEmpty;

  /// هل رقم واتساب مضبوط (ليس القيمة الافتراضية)؟
  static bool get hasRealWhatsappNumber =>
      whatsappBusinessNumber.trim().isNotEmpty &&
      whatsappBusinessNumber != '213000000000';

  // ─────────────────────────────────────────────────────────────
  //  روابط واتساب (نموذج الأعمال: طلب رمز تفعيل)
  // ─────────────────────────────────────────────────────────────

  /// رابط واتساب برسالة جاهزة لطلب رمز التفعيل
  ///
  /// 🔴 الرسالة **لا تحتوي أي بيانات دفع** ولا أرقام حسابات
  ///    (تُرسَل يدوياً في المحادثة من طرف صاحب التطبيق).
  ///
  /// ⚠️ نص الرسالة يأتي من ملفات الترجمة: شاشة الاشتراك (المرحلة 4)
  ///    تبنيه من مفاتيح .arb ثم تمرّره هنا — لا نص مكتوب يدوياً في
  ///    هذا الملف، فتعمل العربية والفرنسية من مصدر واحد.
  static Uri whatsappActivationUri({required String message}) => Uri(
        scheme: 'https',
        host: 'wa.me',
        path: '/${_digitsOnly(whatsappBusinessNumber)}',
        queryParameters: <String, String>{'text': message},
      );

  /// بريد مندوب حماية المعطيات كرابط mailto
  static Uri dpoMailtoUri({String? subject, String? body}) => Uri(
        scheme: 'mailto',
        path: dpoEmail,
        queryParameters: <String, String>{
          if (subject != null && subject.isNotEmpty) 'subject': subject,
          if (body != null && body.isNotEmpty) 'body': body,
        },
      );

  /// رابط بوابة ANPDP
  static Uri get anpdpPortalUri => Uri.parse(AppConstants.anpdpPortalUrl);

  /// رابط تقديم شكوى لدى ANPDP
  static Uri get anpdpComplaintUri => Uri.parse(AppConstants.anpdpComplaintUrl);

  /// رابط موقع التحميل
  static Uri get downloadSiteUri => Uri.parse(downloadSiteUrl);

  /// ملخص الإعداد للعرض في شاشة «حول التطبيق» (تشخيص آمن)
  ///
  /// ⚠️ لا يعرض أي مفتاح سري — فقط حالات (مضبوط/غير مضبوط).
  static Map<String, String> debugSummary() => <String, String>{
        'releaseState': releaseState,
        'appEnv': appEnv,
        'canProcessPersonalData': canProcessPersonalData.toString(),
        'syncConfigured': isSyncConfigured.toString(),
        'whatsappConfigured': hasRealWhatsappNumber.toString(),
        'anpdpDeclaration':
            anpdpDeclarationNumber.isEmpty ? 'missing' : 'present',
        'dpoEmail': dpoEmail,
      };

  /// يحذف كل ما ليس رقماً (لأن wa.me يرفض + وأصفاراً بادئة)
  static String _digitsOnly(String value) =>
      value.replaceAll(RegExp('[^0-9]'), '');
}
