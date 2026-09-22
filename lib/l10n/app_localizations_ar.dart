// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'فلوسنا';

  @override
  String get appTagline => 'اعرف فين راحت فلوسك';

  @override
  String get actionContinue => 'متابعة';

  @override
  String get actionSkip => 'تخطّي';

  @override
  String get actionNext => 'التالي';

  @override
  String get actionBack => 'رجوع';

  @override
  String get actionSave => 'حفظ';

  @override
  String get actionCancel => 'إلغاء';

  @override
  String get actionDelete => 'حذف';

  @override
  String get actionEdit => 'تعديل';

  @override
  String get actionConfirm => 'تأكيد';

  @override
  String get actionRetry => 'إعادة المحاولة';

  @override
  String get actionClose => 'إغلاق';

  @override
  String get actionDone => 'تم';

  @override
  String get actionAdd => 'إضافة';

  @override
  String get actionSearch => 'بحث';

  @override
  String get actionFilter => 'تصفية';

  @override
  String get actionExport => 'تصدير';

  @override
  String get actionShare => 'مشاركة';

  @override
  String get actionSeeAll => 'عرض الكل';

  @override
  String get actionLearnMore => 'اعرف المزيد';

  @override
  String get actionTryAgain => 'حاول مرة أخرى';

  @override
  String get actionStartNow => 'ابدأ الآن';

  @override
  String get actionGetStarted => 'لنبدأ';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navTransactions => 'الحركات';

  @override
  String get navAdd => 'إضافة';

  @override
  String get navBudget => 'الميزانية';

  @override
  String get navMore => 'المزيد';

  @override
  String get onboardingSkip => 'تخطّي';

  @override
  String get onboardingNext => 'التالي';

  @override
  String get onboardingStart => 'لنبدأ';

  @override
  String onboardingPageOf(int current, int total) {
    return '$current من $total';
  }

  @override
  String get onb1Title => 'اعرف فين راحت فلوسك';

  @override
  String get onb1Body =>
      'سجّل دخلك ومصروفك في ثوانٍ، وشوف بوضوح وين تمشي فلوسك كل شهر.';

  @override
  String get onb2Title => 'ميزانية تناسب دخلك';

  @override
  String get onb2Body =>
      'دخل يومي أو متغيّر أو شهري؟ اختر دورة ميزانيتك بنفسك: أسبوعية أو شهرية أو الاثنتين معاً.';

  @override
  String get onb3Title => 'بياناتك في جهازك';

  @override
  String get onb3Body =>
      'لا تُرسل بياناتك إلى أي خادم إلا إذا طلبت أنت ذلك بنفسك. التطبيق يعمل كاملاً بدون إنترنت.';

  @override
  String get consentTitle => 'خصوصيتك أولاً';

  @override
  String get consentIntro =>
      'قبل أن تبدأ، اقرأ هذا جيداً. لن نجمع أي حرف عنك قبل موافقتك.';

  @override
  String get consentPoint1Title => 'بياناتك تبقى في جهازك';

  @override
  String get consentPoint1Body =>
      'كل حركاتك المالية تُحفظ في هاتفك أو حاسوبك. لا تغادره إلا إذا فعّلت المزامنة بنفسك.';

  @override
  String get consentPoint2Title => 'لا نبيع بياناتك — أبداً';

  @override
  String get consentPoint2Body =>
      'لا إعلانات، ولا متتبعات، ولا مشاركة مع أي جهة تجارية.';

  @override
  String get consentPoint3Title => 'أنت المتحكم بالكامل';

  @override
  String get consentPoint3Body =>
      'يمكنك تصدير كل بياناتك أو حذفها نهائياً في أي لحظة، من داخل التطبيق.';

  @override
  String get consentCheckboxLabel =>
      'قرأت وأوافق على سياسة الخصوصية وشروط الاستخدام';

  @override
  String get consentAccept => 'أوافق وأكمل';

  @override
  String get consentDecline => 'أرفض وأخرج';

  @override
  String get consentReadPrivacy => 'قراءة سياسة الخصوصية';

  @override
  String get consentReadTerms => 'قراءة شروط الاستخدام';

  @override
  String get consentMustAccept => 'يجب الموافقة على السياسة والشروط للمتابعة';

  @override
  String get consentDeclineTitle => 'هل أنت متأكد؟';

  @override
  String get consentDeclineBody =>
      'بدون موافقتك لا يمكننا تشغيل التطبيق، لأن القانون يمنعنا من معالجة أي بيانات دون إذنك. لن يُجمع أي شيء.';

  @override
  String get consentDeclineConfirm => 'نعم، أغلق التطبيق';

  @override
  String get consentDeclineCancel => 'لا، سأقرأ وأوافق';

  @override
  String consentVersionLabel(String version) {
    return 'الإصدار $version';
  }

  @override
  String get consentRecordedNote =>
      'تم تسجيل موافقتك بتاريخ ووقت محدّد، ويمكنك الاطلاع عليها في: الإعدادات ← القانوني والخصوصية ← سجل موافقاتي.';

  @override
  String get authChooseTitle => 'كيف تريد أن تبدأ؟';

  @override
  String get authChooseSubtitle =>
      'يمكنك استخدام التطبيق كاملاً بدون حساب. الحساب اختياري — وهو فقط لحفظ بياناتك في السحابة واستعمالها على أكثر من جهاز.';

  @override
  String get authTryWithoutAccount => 'جرّب بدون حساب';

  @override
  String get authCreateAccount => 'إنشاء حساب';

  @override
  String get authLogin => 'تسجيل الدخول';

  @override
  String get authLoginWithGoogle => 'المتابعة بحساب Google';

  @override
  String get authForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get authNoAccountYet => 'ليس لديك حساب؟';

  @override
  String get authHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get authEmailLabel => 'البريد الإلكتروني';

  @override
  String get authEmailHint => 'example@mail.com';

  @override
  String get authPasswordLabel => 'كلمة المرور';

  @override
  String get authPasswordHint => '٨ محارف على الأقل';

  @override
  String get authConfirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get authDisplayNameLabel => 'اسم العرض (اختياري)';

  @override
  String get authDisplayNameHint => 'كيف تحب أن نناديك؟';

  @override
  String get authResetPasswordTitle => 'استرجاع كلمة المرور';

  @override
  String get authResetPasswordBody =>
      'أدخل بريدك وسنرسل لك رابطاً لإعادة التعيين.';

  @override
  String get authResetPasswordSend => 'أرسل الرابط';

  @override
  String get authGuestBadge => 'وضع بدون حساب';

  @override
  String get authGuestLimitNote =>
      'أنت تستخدم التطبيق محلياً. بياناتك محفوظة في هذا الجهاز فقط — لا نسخ احتياطي ولا مزامنة.';

  @override
  String get authUpgradeToAccount => 'أنشئ حساباً لحفظ بياناتك';

  @override
  String get authComingSoonPhase3 =>
      'إنشاء الحساب متاح بعد إعداد الخادم (المرحلة 3)';

  @override
  String get setupTitle => 'إعداد سريع';

  @override
  String get setupSubtitle =>
      'ثلاث خطوات فقط — وكلها اختيارية. يمكنك تغييرها لاحقاً من الإعدادات.';

  @override
  String get setupStepLanguage => 'اللغة';

  @override
  String get setupStepIncome => 'نوع دخلك';

  @override
  String get setupStepCategories => 'الفئات';

  @override
  String get setupLanguageArabic => 'العربية';

  @override
  String get setupLanguageFrench => 'Français';

  @override
  String get setupIncomeDaily => 'دخل يومي';

  @override
  String get setupIncomeDailyHint => 'أشتغل بالأجرة اليومية أو بالمهمة';

  @override
  String get setupIncomeVariable => 'دخل متغيّر';

  @override
  String get setupIncomeVariableHint => 'فريلانس أو تجارة أو عمل حر';

  @override
  String get setupIncomeFixed => 'دخل شهري ثابت';

  @override
  String get setupIncomeFixedHint => 'راتب في نهاية الشهر أو في يوم محدد';

  @override
  String get setupIncomeDailyResult =>
      'سنضبط ميزانيتك أسبوعياً — لأنسب طريقة للدخل اليومي.';

  @override
  String get setupIncomeVariableResult =>
      'سنضبط ميزانيتك أسبوعياً مع نظرة شهرية مجمّعة.';

  @override
  String get setupIncomeFixedResult =>
      'سنضبط ميزانيتك شهرياً. يمكنك تحديد يوم بداية شهرك المالي.';

  @override
  String get setupCategoriesTitle => 'اختر الفئات التي تستعملها';

  @override
  String get setupCategoriesHint =>
      'سنرتّب لك الشاشة حسب اختيارك. يمكنك إضافة فئات مخصصة لاحقاً.';

  @override
  String get setupFinish => 'ابدأ استخدام فلوسنا';

  @override
  String get setupSkipAll => 'تخطّي الكل والبدء';

  @override
  String setupStepOf(int current, int total) {
    return 'الخطوة $current من $total';
  }

  @override
  String get homeGreeting => 'أهلاً بك 👋';

  @override
  String get homeEmptyTitle => 'لا توجد حركات بعد';

  @override
  String get homeEmptyBody =>
      'أضف أول مصروف أو دخل، وابدأ برؤية أين تذهب أموالك.';

  @override
  String get homeEmptyAction => 'أضف أول حركة';

  @override
  String get homeBalance => 'الرصيد الحالي';

  @override
  String get homeIncome => 'الدخل';

  @override
  String get homeExpenses => 'المصاريف';

  @override
  String get homeThisPeriod => 'هذه الفترة';

  @override
  String get homeRecentTransactions => 'آخر الحركات';

  @override
  String homeTrialBanner(String days) {
    return 'بقي $days من التجربة المجانية';
  }

  @override
  String homeOfflineBanner(int count) {
    return 'غير متصل — $count حركة بانتظار المزامنة';
  }

  @override
  String get placeholderTitle => 'هذه الشاشة قيد البناء';

  @override
  String placeholderBody(String phase) {
    return 'ستُبنى هذه الشاشة في المرحلة $phase. التطبيق الآن في مرحلة الأساس: التصميم والترجمة والتنقل والموافقات.';
  }

  @override
  String placeholderPhaseLabel(int phase) {
    return 'المرحلة $phase';
  }

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsSectionAppearance => 'المظهر واللغة';

  @override
  String get settingsSectionMoney => 'الأموال والفترات';

  @override
  String get settingsSectionData => 'البيانات والمزامنة';

  @override
  String get settingsSectionNotifications => 'التنبيهات';

  @override
  String get settingsSectionLegal => 'القانوني والخصوصية';

  @override
  String get settingsSectionAbout => 'حول التطبيق';

  @override
  String get settingsTheme => 'المظهر';

  @override
  String get settingsThemeLight => 'فاتح';

  @override
  String get settingsThemeDark => 'داكن';

  @override
  String get settingsThemeSystem => 'تلقائي (حسب الجهاز)';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsLanguageSystem => 'لغة الجهاز';

  @override
  String get settingsCurrency => 'العملة الأساسية';

  @override
  String get settingsExchangeRates => 'أسعار الصرف';

  @override
  String get settingsFiscalAnchor => 'يوم بداية الشهر المالي';

  @override
  String get settingsBudgetMode => 'دورة الميزانية';

  @override
  String get settingsBudgetModeMonthly => 'شهرية';

  @override
  String get settingsBudgetModeWeekly => 'أسبوعية';

  @override
  String get settingsBudgetModeBoth => 'الاثنتان معاً';

  @override
  String get settingsSync => 'المزامنة السحابية';

  @override
  String get settingsSyncOff => 'معطّلة — بياناتك في جهازك فقط';

  @override
  String get settingsSyncOn => 'مفعّلة';

  @override
  String get settingsSyncRequiresConsent =>
      'تتطلب موافقة صريحة منفصلة (نقل البيانات خارج الوطن)';

  @override
  String get settingsBackup => 'نسخة احتياطية محلية';

  @override
  String get settingsNotificationsDaily => 'تذكير يومي بالتسجيل';

  @override
  String get settingsNotificationsBudget => 'تنبيهات تجاوز الميزانية';

  @override
  String get settingsNotificationsDebts => 'تنبيه آجال الديون';

  @override
  String get legalTitle => 'القانوني والخصوصية';

  @override
  String get legalPrivacy => 'سياسة الخصوصية';

  @override
  String get legalTerms => 'شروط الاستخدام';

  @override
  String get legalSubscription => 'شروط الاشتراك والاسترداد';

  @override
  String get legalDisclaimer => 'إخلاء المسؤولية';

  @override
  String get legalExportData => 'تصدير كل بياناتي';

  @override
  String get legalExportDataNote =>
      'حق الاطلاع وحق النقل — نصدر لك ملفاً بكل ما نملكه عنك.';

  @override
  String get legalRectifyData => 'طلب تصحيح بياناتي';

  @override
  String get legalObjectData => 'الاعتراض على المعالجة';

  @override
  String get legalDeleteAccount => 'حذف حسابي وبياناتي نهائياً';

  @override
  String get legalDeleteAccountNote =>
      'حق المحو — لا يمكن التراجع بعد التنفيذ.';

  @override
  String get legalDpoContact => 'بريد مندوب حماية المعطيات';

  @override
  String get legalComplaintAnpdp => 'تقديم شكوى لدى السلطة الوطنية (ANPDP)';

  @override
  String get legalMyConsents => 'سجل موافقاتي';

  @override
  String get legalComingSoon => 'سيُفعَّل هذا الحق في المرحلة 4';

  @override
  String get aboutVersion => 'الإصدار';

  @override
  String get aboutBuild => 'رقم البناء';

  @override
  String get aboutLicenses => 'التراخيص مفتوحة المصدر';

  @override
  String get aboutCheckUpdate => 'التحقق من التحديثات';

  @override
  String get aboutRateApp => 'قيّم التطبيق';

  @override
  String get errorGenericTitle => 'حدث خطأ';

  @override
  String get errorGenericBody =>
      'لم نتمكن من إتمام العملية. بياناتك محفوظة ولم يُفقد شيء.';

  @override
  String get errorNetworkTitle => 'لا يوجد اتصال';

  @override
  String get errorNetworkBody =>
      'تحقق من اتصالك بالإنترنت ثم أعد المحاولة. يمكنك الاستمرار في استخدام التطبيق بدون إنترنت.';

  @override
  String get errorUnknownTitle => 'خطأ غير متوقع';

  @override
  String get errorUnknownBody =>
      'حدث أمر لم نتوقعه. أعد المحاولة، وإن تكرر فأخبرنا عبر الدعم.';

  @override
  String get errorValidationTitle => 'تحقق من المدخلات';

  @override
  String get errorPermissionTitle => 'لا تملك صلاحية';

  @override
  String get errorPermissionBody =>
      'هذه الشاشة مخصّصة لدور معيّن. تواصل مع الدعم إن كنت تعتقد أن هذا خطأ.';

  @override
  String get errorFeatureLockedTitle => 'هذه الميزة مقفلة';

  @override
  String get errorFeatureLockedBody =>
      'انتهت فترة التجربة المجانية. اختر باقتك لتكمل — بياناتك محفوظة ويمكنك عرضها وتصديرها دائماً.';

  @override
  String get errorContactSupport => 'تواصل مع الدعم';

  @override
  String get validateEmailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get validateEmailInvalid =>
      'صيغة البريد غير صحيحة. مثال: name@mail.com';

  @override
  String get validateEmailTooLong => 'البريد طويل جداً (الحد 254 محرفاً)';

  @override
  String get validatePasswordRequired => 'كلمة المرور مطلوبة';

  @override
  String get validatePasswordTooShort =>
      'كلمة المرور قصيرة — ٨ محارف على الأقل';

  @override
  String get validatePasswordNoDigit =>
      'أضف رقماً واحداً على الأقل لكلمة المرور';

  @override
  String get validatePasswordTooLong =>
      'كلمة المرور طويلة جداً (الحد 128 محرفاً)';

  @override
  String get validateConfirmMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get validateNameTooLong => 'الاسم طويل جداً (الحد 40 محرفاً)';

  @override
  String get validateAmountRequired => 'أدخل المبلغ';

  @override
  String get validateAmountZero => 'المبلغ يجب أن يكون أكبر من صفر';

  @override
  String get validateAmountTooLarge => 'المبلغ كبير جداً (الحد 999,999,999.99)';

  @override
  String get validateAmountDecimals => 'خانتان عشريتان كحد أقصى';

  @override
  String get validatePhoneAlgerian =>
      'رقم جزائري غير صالح. يجب أن يبدأ بـ 05 أو 06 أو 07 (مثال: 0555123456)';

  @override
  String get validateNoteTooLong => 'الملاحظة طويلة جداً (الحد 500 محرف)';

  @override
  String get stateLoading => 'جارٍ التحميل…';

  @override
  String get stateSaving => 'جارٍ الحفظ…';

  @override
  String get stateEmpty => 'لا يوجد شيء هنا بعد';

  @override
  String get stateOffline => 'أنت غير متصل — التطبيق يعمل بشكل طبيعي';

  @override
  String get stateSyncing => 'جارٍ المزامنة…';

  @override
  String get stateSyncDone => 'تمت المزامنة بنجاح';

  @override
  String get stateNoInternet => 'لا يوجد إنترنت';

  @override
  String get confirmDeleteTitle => 'تأكيد الحذف';

  @override
  String get confirmDeleteBody => 'سيُحذف هذا العنصر نهائياً. لا يمكن التراجع.';

  @override
  String get confirmExitTitle => 'الخروج من التطبيق';

  @override
  String get confirmExitBody => 'هل تريد إغلاق فلوسنا؟';

  @override
  String countdownNote(int seconds) {
    return 'يتفعّل الزر بعد $seconds ثانية — للتأكد من قصدك.';
  }

  @override
  String get fieldShowPassword => 'إظهار كلمة المرور';

  @override
  String get fieldHidePassword => 'إخفاء كلمة المرور';

  @override
  String get validateRequired => 'هذا الحقل مطلوب';

  @override
  String validateTooLong(int max) {
    return 'النص طويل جداً (الحد $max محرفاً)';
  }

  @override
  String get incomeKind => 'دخل';

  @override
  String get expenseKind => 'مصروف';

  @override
  String get categoryFood => 'الطعام والتموين';

  @override
  String get categoryTransport => 'النقل والتنقل';

  @override
  String get categoryHousing => 'السكن والإيجار';

  @override
  String get categoryUtilities => 'الكهرباء والغاز';

  @override
  String get categoryWater => 'المياه';

  @override
  String get categoryInternet => 'الإنترنت والهاتف';

  @override
  String get categoryHealth => 'الصحة والدواء';

  @override
  String get categoryEducation => 'التعليم والمدارس';

  @override
  String get categoryClothing => 'الملابس';

  @override
  String get categoryCharity => 'الزكاة والصدقة';

  @override
  String get categoryCafe => 'المقاهي والمشروبات';

  @override
  String get categoryGifts => 'الهدايا والمناسبات';

  @override
  String get categoryMaintenance => 'الصيانة والتصليح';

  @override
  String get categorySubscriptions => 'الاشتراكات';

  @override
  String get categoryDebtRepay => 'تسديد دين';

  @override
  String get categoryDebtCollect => 'استرجاع دين';

  @override
  String get categoryLeisure => 'الترفيه والسفر';

  @override
  String get categorySalary => 'راتب شهري';

  @override
  String get categoryDailyWage => 'أجرة يومية';

  @override
  String get categoryBonus => 'علاوة أو منحة';

  @override
  String get categoryFreelance => 'عمل حر';

  @override
  String get categoryTrade => 'تجارة وبيع';

  @override
  String get categoryPension => 'معاش أو تقاعد';

  @override
  String get categoryFamilyAid => 'مساعدة عائلية';

  @override
  String get categoryOtherIncome => 'دخل آخر';

  @override
  String get categoryOtherExpense => 'مصروف آخر';

  @override
  String get txEmptyTitle => 'لا حركات في هذه الفترة';

  @override
  String get txEmptyBody =>
      'سجّل أول حركة من زر الإضافة في الأسفل، وستظهر هنا مباشرة.';

  @override
  String get txSearchHint => 'ابحث في الحركات…';

  @override
  String get txFilterAll => 'الكل';

  @override
  String get txSortLabel => 'الأحدث أولاً';

  @override
  String get txTotalIncome => 'مجموع الدخل';

  @override
  String get txTotalExpense => 'مجموع المصاريف';

  @override
  String get budgetEmptyTitle => 'لم تُضبط ميزانية بعد';

  @override
  String get budgetEmptyBody =>
      'حدّد سقفاً لمصاريفك، وسننبهك قبل أن تتجاوزه — لا بعد فوات الأوان.';

  @override
  String get budgetEmptyAction => 'اضبط ميزانيتي';

  @override
  String get budgetSpent => 'المصروف';

  @override
  String get budgetRemaining => 'المتبقي';

  @override
  String get budgetLimitLabel => 'سقف الميزانية';

  @override
  String get budgetWeeklySection => 'الميزانية الأسبوعية';

  @override
  String get budgetMonthlySection => 'الميزانية الشهرية';

  @override
  String get addTitle => 'حركة جديدة';

  @override
  String get addKindLabel => 'نوع الحركة';

  @override
  String get addAmountLabel => 'المبلغ';

  @override
  String get addAmountHint => 'مثال: 1500';

  @override
  String get addCategoryLabel => 'التصنيف';

  @override
  String get addNoteLabel => 'ملاحظة (اختياري)';

  @override
  String get addNoteHint => 'مثال: خضرة السوق';

  @override
  String get addDateLabel => 'التاريخ';

  @override
  String get addPhase2Title => 'الحفظ الفعلي يبدأ في المرحلة 2';

  @override
  String get addPhase2Body =>
      'هذه الشاشة مكتملة: الحقول والتحقق والتصنيفات تعمل. حفظ الحركات في قاعدة بيانات الجهاز يأتي في المرحلة 2. لن يُحفظ شيء الآن، حتى لا تظن أن بياناتك محفوظة وهي ليست كذلك.';

  @override
  String get addFormValid => 'الحقول صحيحة — جاهزة للحفظ';

  @override
  String get moreSectionTools => 'أدوات';

  @override
  String get moreSectionInfo => 'معلومات';

  @override
  String get moreSectionAccount => 'الحساب';

  @override
  String get moreGoals => 'أهداف الادخار';

  @override
  String get moreDebts => 'الديون (عليك ولك)';

  @override
  String get moreRecurring => 'الحركات المتكررة';

  @override
  String get moreReports => 'التقارير والتصدير';

  @override
  String get moreSubscription => 'الاشتراك والباقة';

  @override
  String get settingsBudgetModeHint =>
      'تُضبط الدورة حسب نوع دخلك: يومي ← أسبوعية، راتب ← شهرية.';

  @override
  String get settingsFiscalAnchorHint =>
      'اليوم الذي يبدأ فيه شهرك المالي (من 1 إلى 28). مفيد إن كان راتبك ينزل يوم 25 مثلاً.';

  @override
  String get settingsCurrencyHint =>
      'العملة التي تُجمع بها كل التقارير. العملات الأخرى تُسجَّل بسعر صرف يدوي.';

  @override
  String get settingsEraseAll => 'حذف كل البيانات من هذا الجهاز';

  @override
  String get settingsEraseAllNote =>
      'يمسح الموافقات والإعدادات وكل ما خُزن محلياً. لا يمكن التراجع.';

  @override
  String get settingsEraseConfirmTitle => 'حذف كل البيانات؟';

  @override
  String get settingsEraseConfirmBody =>
      'سيُمسح كل شيء من هذا الجهاز نهائياً، وستعود إلى شاشة الترحيب وكأن التطبيق جديد.';

  @override
  String get settingsErased => 'حُذفت كل البيانات';

  @override
  String get settingsNotificationsNote =>
      'التنبيهات تعمل محلياً بلا إنترنت، وتُفعَّل في المرحلة 5.';

  @override
  String get settingsSyncNote =>
      'المزامنة اختيارية وتبدأ في المرحلة 3، وتتطلب موافقة صريحة منفصلة.';

  @override
  String get settingsSaved => 'حُفظ الإعداد';

  @override
  String get legalConsentRecorded => 'الموافقة المسجَّلة';

  @override
  String get legalConsentVersion => 'إصدار السياسة';

  @override
  String get legalConsentHash => 'بصمة الموافقة (SHA-256)';

  @override
  String get legalConsentDate => 'تاريخ الموافقة';

  @override
  String get legalNoConsentYet => 'لا توجد موافقة مسجَّلة بعد';

  @override
  String get legalRightsTitle => 'حقوقك الخمسة';

  @override
  String get legalRightsBody =>
      'الاطلاع · التصحيح · الاعتراض · الحذف · النقل. تمارسها من داخل التطبيق أو بمراسلة مندوب حماية المعطيات، ونرد خلال 72 ساعة كحد أقصى.';

  @override
  String get legalCantOpenLink => 'تعذّر فتح الرابط. انسخه وافتحه في المتصفح.';

  @override
  String get legalCopied => 'نُسخ إلى الحافظة';

  @override
  String get legalCopyAction => 'نسخ';

  @override
  String get legalDataOnDevice => 'بياناتك الآن على هذا الجهاز فقط';

  @override
  String get aboutTitle => 'حول التطبيق';

  @override
  String get aboutAppDescription =>
      'فلوسنا أداة تسجيل يدوي للدخل والمصاريف والميزانية. لا تربط بأي حساب بنكي أو بريدي، ولا تنفّذ أي دفع أو تحويل.';

  @override
  String get aboutNoBrandsNote =>
      'لا يذكُر التطبيق أسماء أي بنوك أو مؤسسات، ولا يطلب أرقام حسابات أو بطاقات.';

  @override
  String get aboutPhaseLabel => 'المرحلة الحالية: الأساس (1 من 6)';

  @override
  String get aboutDataLocalNote => 'كل ما تسجّله يبقى في جهازك';

  @override
  String dayCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count يوم',
      many: '$count يوماً',
      few: '$count أيام',
      two: 'يومان',
      one: 'يوم واحد',
    );
    return '$_temp0';
  }

  @override
  String get legalDisclaimerBody =>
      'فلوسنا أداة متابعة يدوية. التطبيق:\n• ليس مؤسسة دفع ولا يملك أي ترخيص بنكي؛\n• لا ينفّذ أي دفع أو تحويل أو سحب؛\n• لا يتصل بأي حساب بنكي أو بريدي أو محفظة دفع؛\n• لا يقدّم أي نصيحة استثمارية أو ضريبية أو قانونية؛\n• يعرض مبالغ أدخلها المستخدم بنفسه، دون تحقق من أي جهة خارجية.\n\nالأرقام المعروضة تعكس ما أدخلته أنت فقط. تبقى مسؤولاً عن إدارة أموالك وعن تصريحاتك الجبائية.';

  @override
  String get legalSubscriptionBody =>
      'التجربة المجانية: سبعة أيام بكل الميزات، بلا أي دفع.\n\nبعد التجربة يلزم اشتراك لمواصلة تسجيل البيانات. أما الاطلاع والتقارير والتصدير وحذف بياناتك فتبقى مجانية ومتاحة في كل وقت (قفل مرن لا يحبس بياناتك).\n\nالباقات: الفرد · زوجان · العائلة، بأسعار شهرية وسنوية تُعرض في شاشة الاشتراك وقد تُعدَّل دون تحديث التطبيق.\n\nطريقة التفعيل: تختار الباقة داخل التطبيق، فيُرسل طلب إلى الفريق، ثم يصلك رمز تفعيل بعد الدفع. تفاصيل الدفع تُبلَّغ داخل المحادثة، ولا توضع أبداً داخل التطبيق.\n\nالاسترداد: الرمز غير المفعَّل قابل للاسترداد. الرمز المفعَّل غير قابل له، إلا عند تقصير من طرفنا.';

  @override
  String get categorySeasonalBadge =>
      'تصنيف موسمي — يرتفع استعماله في مواسم معيّنة';

  @override
  String get creditDeveloper => 'تطوير: Shawqi Builds';

  @override
  String get socialSectionTitle => 'تابعنا';

  @override
  String get socialHint =>
      'قنواتنا الرسمية: جديد التطبيق، نصائح عملية، وإعلانات.';

  @override
  String get channelFacebook => 'فيسبوك';

  @override
  String get channelInstagram => 'إنستغرام';

  @override
  String get channelTiktok => 'تيك توك';

  @override
  String get channelX => 'إكس';

  @override
  String get channelYoutube => 'يوتيوب';

  @override
  String get channelTelegram => 'تيليغرام';

  @override
  String get channelWhatsapp => 'واتساب';

  @override
  String get catMgrTitle => 'إدارة الفئات';

  @override
  String get catMgrAdd => 'أضف فئة';

  @override
  String get catMgrNameAr => 'الاسم بالعربية';

  @override
  String get catMgrNameFr => 'الاسم بالفرنسية';

  @override
  String get catMgrIconLabel => 'الأيقونة';

  @override
  String get catMgrSeasonal => 'فئة موسمية (رمضان، دخول مدرسي…)';

  @override
  String get catMgrEmpty => 'لا فئات مخصصة بعد';

  @override
  String get catMgrEmptyBody => 'أضف فئتك الأولى لتناسب طريقة صرفك أنت';

  @override
  String get catMgrSaved => 'حُفظت الفئة ✅';

  @override
  String get catMgrArchived => 'مؤرشفة';

  @override
  String get catMgrArchive => 'أرشفة';

  @override
  String get catMgrRestore => 'استعادة';

  @override
  String get catMgrDuplicate => 'يوجد فئة بنفس الاسم بالفعل';

  @override
  String get txSavedSnack => 'سُجّلت الحركة ✅';

  @override
  String get txNoResults => 'لا نتائج مطابقة لبحثك';

  @override
  String get settingsCatMgr => 'إدارة الفئات المخصصة';

  @override
  String get settingsCatMgrNote => 'أضف أو عدّل أو أرشف فئات مخصصة';

  @override
  String get budgetOverallLabel => 'كل المصاريف (سقف عام)';

  @override
  String get budgetOverallShort => 'السقف العام';

  @override
  String get budgetAddLimit => 'إضافة سقف';

  @override
  String get budgetEditLimit => 'تعديل السقف';

  @override
  String get budgetNewLimit => 'سقف جديد';

  @override
  String get budgetPickCategory => 'الفئة';

  @override
  String get budgetAmountLabel => 'مبلغ السقف';

  @override
  String get budgetAmountHint => 'مثال: 20000';

  @override
  String get budgetAlertPercentLabel => 'نبّهني عند';

  @override
  String get budgetAlertRange => 'نسبة التنبيه بين 50٪ و100٪';

  @override
  String budgetAlertPercentValue(int percent) {
    return '$percent٪ من السقف';
  }

  @override
  String get budgetStatusSafe => 'داخل السقف';

  @override
  String get budgetStatusNear => 'قريب من السقف';

  @override
  String get budgetStatusOver => 'تجاوزت السقف';

  @override
  String budgetUsedPercent(int percent) {
    return '$percent٪';
  }

  @override
  String get budgetSpentOfLimit => 'المصروف من السقف';

  @override
  String get budgetRemainingLabel => 'الباقي لك';

  @override
  String get budgetOverByLabel => 'تجاوزت بـ';

  @override
  String get budgetExhausted => 'استهلكت السقف كاملاً — لا مساحة متبقية';

  @override
  String get budgetFormulaNote =>
      'الحساب: النسبة = المصروف ÷ السقف × 100. الحالة: آمن إن كانت أقل من نسبة التنبيه، قريب إن بلغتها، متجاوز إن تجاوزت 100٪.';

  @override
  String get budgetSavedSnack => 'تم حفظ السقف';

  @override
  String get budgetDeletedSnack => 'تم حذف السقف';

  @override
  String get budgetDeleteTitle => 'حذف هذا السقف؟';

  @override
  String get budgetDeleteBody =>
      'يُحذف السقف فقط — حركاتك المالية تبقى كما هي بلا أي تغيير.';

  @override
  String get budgetDeleteAction => 'احذف السقف';

  @override
  String get budgetNotFound => 'هذا السقف لم يعد موجوداً';

  @override
  String get budgetPeriodNote =>
      'السقوف تُحسب على الفترة الحالية المعروضة أعلاه.';

  @override
  String get budgetAlertsSection => 'تنبيهات السقوف';

  @override
  String budgetAlertOverTitle(String category) {
    return 'تجاوزت سقف «$category»';
  }

  @override
  String budgetAlertNearTitle(String category) {
    return 'اقتربت من سقف «$category»';
  }

  @override
  String budgetAlertOverBody(String spent, String limit) {
    return 'صرفتَ $spent من أصل $limit';
  }

  @override
  String budgetAlertNearBody(String spent, String limit, String remaining) {
    return 'صرفتَ $spent من أصل $limit — بقي $remaining';
  }

  @override
  String budgetAlertMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'و$count تنبيه آخر',
      many: 'و$count تنبيهاً آخر',
      few: 'و$count تنبيهات أخرى',
      two: 'وتنبيهان آخران',
      one: 'وتنبيه آخر',
      zero: 'لا تنبيهات أخرى',
    );
    return '$_temp0';
  }

  @override
  String get budgetAlertAction => 'راجع السقوف';

  @override
  String get budgetCategoryMissing => 'فئة غير معروفة';
}
