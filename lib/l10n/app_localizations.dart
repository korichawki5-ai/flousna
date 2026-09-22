import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('fr'),
  ];

  /// اسم التطبيق — لا يُترجم حرفياً بل يبقى الهوية
  ///
  /// In ar, this message translates to:
  /// **'فلوسنا'**
  String get appName;

  /// السطر التسويقي الرئيسي
  ///
  /// In ar, this message translates to:
  /// **'اعرف فين راحت فلوسك'**
  String get appTagline;

  /// No description provided for @actionContinue.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get actionContinue;

  /// No description provided for @actionSkip.
  ///
  /// In ar, this message translates to:
  /// **'تخطّي'**
  String get actionSkip;

  /// No description provided for @actionNext.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get actionNext;

  /// No description provided for @actionBack.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get actionBack;

  /// No description provided for @actionSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get actionCancel;

  /// No description provided for @actionDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get actionDelete;

  /// No description provided for @actionEdit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get actionEdit;

  /// No description provided for @actionConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get actionConfirm;

  /// No description provided for @actionRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get actionRetry;

  /// No description provided for @actionClose.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get actionClose;

  /// No description provided for @actionDone.
  ///
  /// In ar, this message translates to:
  /// **'تم'**
  String get actionDone;

  /// No description provided for @actionAdd.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get actionAdd;

  /// No description provided for @actionSearch.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get actionSearch;

  /// No description provided for @actionFilter.
  ///
  /// In ar, this message translates to:
  /// **'تصفية'**
  String get actionFilter;

  /// No description provided for @actionExport.
  ///
  /// In ar, this message translates to:
  /// **'تصدير'**
  String get actionExport;

  /// No description provided for @actionShare.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة'**
  String get actionShare;

  /// No description provided for @actionSeeAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get actionSeeAll;

  /// No description provided for @actionLearnMore.
  ///
  /// In ar, this message translates to:
  /// **'اعرف المزيد'**
  String get actionLearnMore;

  /// No description provided for @actionTryAgain.
  ///
  /// In ar, this message translates to:
  /// **'حاول مرة أخرى'**
  String get actionTryAgain;

  /// No description provided for @actionStartNow.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الآن'**
  String get actionStartNow;

  /// No description provided for @actionGetStarted.
  ///
  /// In ar, this message translates to:
  /// **'لنبدأ'**
  String get actionGetStarted;

  /// Bottom Navigation — العنصر 1
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// No description provided for @navTransactions.
  ///
  /// In ar, this message translates to:
  /// **'الحركات'**
  String get navTransactions;

  /// No description provided for @navAdd.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get navAdd;

  /// No description provided for @navBudget.
  ///
  /// In ar, this message translates to:
  /// **'الميزانية'**
  String get navBudget;

  /// No description provided for @navMore.
  ///
  /// In ar, this message translates to:
  /// **'المزيد'**
  String get navMore;

  /// No description provided for @onboardingSkip.
  ///
  /// In ar, this message translates to:
  /// **'تخطّي'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In ar, this message translates to:
  /// **'لنبدأ'**
  String get onboardingStart;

  /// No description provided for @onboardingPageOf.
  ///
  /// In ar, this message translates to:
  /// **'{current} من {total}'**
  String onboardingPageOf(int current, int total);

  /// No description provided for @onb1Title.
  ///
  /// In ar, this message translates to:
  /// **'اعرف فين راحت فلوسك'**
  String get onb1Title;

  /// No description provided for @onb1Body.
  ///
  /// In ar, this message translates to:
  /// **'سجّل دخلك ومصروفك في ثوانٍ، وشوف بوضوح وين تمشي فلوسك كل شهر.'**
  String get onb1Body;

  /// No description provided for @onb2Title.
  ///
  /// In ar, this message translates to:
  /// **'ميزانية تناسب دخلك'**
  String get onb2Title;

  /// No description provided for @onb2Body.
  ///
  /// In ar, this message translates to:
  /// **'دخل يومي أو متغيّر أو شهري؟ اختر دورة ميزانيتك بنفسك: أسبوعية أو شهرية أو الاثنتين معاً.'**
  String get onb2Body;

  /// No description provided for @onb3Title.
  ///
  /// In ar, this message translates to:
  /// **'بياناتك في جهازك'**
  String get onb3Title;

  /// No description provided for @onb3Body.
  ///
  /// In ar, this message translates to:
  /// **'لا تُرسل بياناتك إلى أي خادم إلا إذا طلبت أنت ذلك بنفسك. التطبيق يعمل كاملاً بدون إنترنت.'**
  String get onb3Body;

  /// No description provided for @consentTitle.
  ///
  /// In ar, this message translates to:
  /// **'خصوصيتك أولاً'**
  String get consentTitle;

  /// No description provided for @consentIntro.
  ///
  /// In ar, this message translates to:
  /// **'قبل أن تبدأ، اقرأ هذا جيداً. لن نجمع أي حرف عنك قبل موافقتك.'**
  String get consentIntro;

  /// No description provided for @consentPoint1Title.
  ///
  /// In ar, this message translates to:
  /// **'بياناتك تبقى في جهازك'**
  String get consentPoint1Title;

  /// No description provided for @consentPoint1Body.
  ///
  /// In ar, this message translates to:
  /// **'كل حركاتك المالية تُحفظ في هاتفك أو حاسوبك. لا تغادره إلا إذا فعّلت المزامنة بنفسك.'**
  String get consentPoint1Body;

  /// No description provided for @consentPoint2Title.
  ///
  /// In ar, this message translates to:
  /// **'لا نبيع بياناتك — أبداً'**
  String get consentPoint2Title;

  /// No description provided for @consentPoint2Body.
  ///
  /// In ar, this message translates to:
  /// **'لا إعلانات، ولا متتبعات، ولا مشاركة مع أي جهة تجارية.'**
  String get consentPoint2Body;

  /// No description provided for @consentPoint3Title.
  ///
  /// In ar, this message translates to:
  /// **'أنت المتحكم بالكامل'**
  String get consentPoint3Title;

  /// No description provided for @consentPoint3Body.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك تصدير كل بياناتك أو حذفها نهائياً في أي لحظة، من داخل التطبيق.'**
  String get consentPoint3Body;

  /// No description provided for @consentCheckboxLabel.
  ///
  /// In ar, this message translates to:
  /// **'قرأت وأوافق على سياسة الخصوصية وشروط الاستخدام'**
  String get consentCheckboxLabel;

  /// No description provided for @consentAccept.
  ///
  /// In ar, this message translates to:
  /// **'أوافق وأكمل'**
  String get consentAccept;

  /// No description provided for @consentDecline.
  ///
  /// In ar, this message translates to:
  /// **'أرفض وأخرج'**
  String get consentDecline;

  /// No description provided for @consentReadPrivacy.
  ///
  /// In ar, this message translates to:
  /// **'قراءة سياسة الخصوصية'**
  String get consentReadPrivacy;

  /// No description provided for @consentReadTerms.
  ///
  /// In ar, this message translates to:
  /// **'قراءة شروط الاستخدام'**
  String get consentReadTerms;

  /// No description provided for @consentMustAccept.
  ///
  /// In ar, this message translates to:
  /// **'يجب الموافقة على السياسة والشروط للمتابعة'**
  String get consentMustAccept;

  /// No description provided for @consentDeclineTitle.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد؟'**
  String get consentDeclineTitle;

  /// No description provided for @consentDeclineBody.
  ///
  /// In ar, this message translates to:
  /// **'بدون موافقتك لا يمكننا تشغيل التطبيق، لأن القانون يمنعنا من معالجة أي بيانات دون إذنك. لن يُجمع أي شيء.'**
  String get consentDeclineBody;

  /// No description provided for @consentDeclineConfirm.
  ///
  /// In ar, this message translates to:
  /// **'نعم، أغلق التطبيق'**
  String get consentDeclineConfirm;

  /// No description provided for @consentDeclineCancel.
  ///
  /// In ar, this message translates to:
  /// **'لا، سأقرأ وأوافق'**
  String get consentDeclineCancel;

  /// No description provided for @consentVersionLabel.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار {version}'**
  String consentVersionLabel(String version);

  /// No description provided for @consentRecordedNote.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل موافقتك بتاريخ ووقت محدّد، ويمكنك الاطلاع عليها في: الإعدادات ← القانوني والخصوصية ← سجل موافقاتي.'**
  String get consentRecordedNote;

  /// No description provided for @authChooseTitle.
  ///
  /// In ar, this message translates to:
  /// **'كيف تريد أن تبدأ؟'**
  String get authChooseTitle;

  /// No description provided for @authChooseSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك استخدام التطبيق كاملاً بدون حساب. الحساب اختياري — وهو فقط لحفظ بياناتك في السحابة واستعمالها على أكثر من جهاز.'**
  String get authChooseSubtitle;

  /// الخيار الأساسي — يقلل الاحتكاك
  ///
  /// In ar, this message translates to:
  /// **'جرّب بدون حساب'**
  String get authTryWithoutAccount;

  /// No description provided for @authCreateAccount.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get authCreateAccount;

  /// No description provided for @authLogin.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get authLogin;

  /// No description provided for @authLoginWithGoogle.
  ///
  /// In ar, this message translates to:
  /// **'المتابعة بحساب Google'**
  String get authLoginWithGoogle;

  /// No description provided for @authForgotPassword.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get authForgotPassword;

  /// No description provided for @authNoAccountYet.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟'**
  String get authNoAccountYet;

  /// No description provided for @authHaveAccount.
  ///
  /// In ar, this message translates to:
  /// **'لديك حساب بالفعل؟'**
  String get authHaveAccount;

  /// No description provided for @authEmailLabel.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get authEmailLabel;

  /// No description provided for @authEmailHint.
  ///
  /// In ar, this message translates to:
  /// **'example@mail.com'**
  String get authEmailHint;

  /// No description provided for @authPasswordLabel.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get authPasswordLabel;

  /// No description provided for @authPasswordHint.
  ///
  /// In ar, this message translates to:
  /// **'٨ محارف على الأقل'**
  String get authPasswordHint;

  /// No description provided for @authConfirmPasswordLabel.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get authConfirmPasswordLabel;

  /// No description provided for @authDisplayNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم العرض (اختياري)'**
  String get authDisplayNameLabel;

  /// No description provided for @authDisplayNameHint.
  ///
  /// In ar, this message translates to:
  /// **'كيف تحب أن نناديك؟'**
  String get authDisplayNameHint;

  /// No description provided for @authResetPasswordTitle.
  ///
  /// In ar, this message translates to:
  /// **'استرجاع كلمة المرور'**
  String get authResetPasswordTitle;

  /// No description provided for @authResetPasswordBody.
  ///
  /// In ar, this message translates to:
  /// **'أدخل بريدك وسنرسل لك رابطاً لإعادة التعيين.'**
  String get authResetPasswordBody;

  /// No description provided for @authResetPasswordSend.
  ///
  /// In ar, this message translates to:
  /// **'أرسل الرابط'**
  String get authResetPasswordSend;

  /// No description provided for @authGuestBadge.
  ///
  /// In ar, this message translates to:
  /// **'وضع بدون حساب'**
  String get authGuestBadge;

  /// No description provided for @authGuestLimitNote.
  ///
  /// In ar, this message translates to:
  /// **'أنت تستخدم التطبيق محلياً. بياناتك محفوظة في هذا الجهاز فقط — لا نسخ احتياطي ولا مزامنة.'**
  String get authGuestLimitNote;

  /// No description provided for @authUpgradeToAccount.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ حساباً لحفظ بياناتك'**
  String get authUpgradeToAccount;

  /// No description provided for @authComingSoonPhase3.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء الحساب متاح بعد إعداد الخادم (المرحلة 3)'**
  String get authComingSoonPhase3;

  /// No description provided for @setupTitle.
  ///
  /// In ar, this message translates to:
  /// **'إعداد سريع'**
  String get setupTitle;

  /// No description provided for @setupSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'ثلاث خطوات فقط — وكلها اختيارية. يمكنك تغييرها لاحقاً من الإعدادات.'**
  String get setupSubtitle;

  /// No description provided for @setupStepLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get setupStepLanguage;

  /// No description provided for @setupStepIncome.
  ///
  /// In ar, this message translates to:
  /// **'نوع دخلك'**
  String get setupStepIncome;

  /// No description provided for @setupStepCategories.
  ///
  /// In ar, this message translates to:
  /// **'الفئات'**
  String get setupStepCategories;

  /// No description provided for @setupLanguageArabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get setupLanguageArabic;

  /// No description provided for @setupLanguageFrench.
  ///
  /// In ar, this message translates to:
  /// **'Français'**
  String get setupLanguageFrench;

  /// No description provided for @setupIncomeDaily.
  ///
  /// In ar, this message translates to:
  /// **'دخل يومي'**
  String get setupIncomeDaily;

  /// No description provided for @setupIncomeDailyHint.
  ///
  /// In ar, this message translates to:
  /// **'أشتغل بالأجرة اليومية أو بالمهمة'**
  String get setupIncomeDailyHint;

  /// No description provided for @setupIncomeVariable.
  ///
  /// In ar, this message translates to:
  /// **'دخل متغيّر'**
  String get setupIncomeVariable;

  /// No description provided for @setupIncomeVariableHint.
  ///
  /// In ar, this message translates to:
  /// **'فريلانس أو تجارة أو عمل حر'**
  String get setupIncomeVariableHint;

  /// No description provided for @setupIncomeFixed.
  ///
  /// In ar, this message translates to:
  /// **'دخل شهري ثابت'**
  String get setupIncomeFixed;

  /// No description provided for @setupIncomeFixedHint.
  ///
  /// In ar, this message translates to:
  /// **'راتب في نهاية الشهر أو في يوم محدد'**
  String get setupIncomeFixedHint;

  /// No description provided for @setupIncomeDailyResult.
  ///
  /// In ar, this message translates to:
  /// **'سنضبط ميزانيتك أسبوعياً — لأنسب طريقة للدخل اليومي.'**
  String get setupIncomeDailyResult;

  /// No description provided for @setupIncomeVariableResult.
  ///
  /// In ar, this message translates to:
  /// **'سنضبط ميزانيتك أسبوعياً مع نظرة شهرية مجمّعة.'**
  String get setupIncomeVariableResult;

  /// No description provided for @setupIncomeFixedResult.
  ///
  /// In ar, this message translates to:
  /// **'سنضبط ميزانيتك شهرياً. يمكنك تحديد يوم بداية شهرك المالي.'**
  String get setupIncomeFixedResult;

  /// No description provided for @setupCategoriesTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر الفئات التي تستعملها'**
  String get setupCategoriesTitle;

  /// No description provided for @setupCategoriesHint.
  ///
  /// In ar, this message translates to:
  /// **'سنرتّب لك الشاشة حسب اختيارك. يمكنك إضافة فئات مخصصة لاحقاً.'**
  String get setupCategoriesHint;

  /// No description provided for @setupFinish.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ استخدام فلوسنا'**
  String get setupFinish;

  /// No description provided for @setupSkipAll.
  ///
  /// In ar, this message translates to:
  /// **'تخطّي الكل والبدء'**
  String get setupSkipAll;

  /// No description provided for @setupStepOf.
  ///
  /// In ar, this message translates to:
  /// **'الخطوة {current} من {total}'**
  String setupStepOf(int current, int total);

  /// No description provided for @homeGreeting.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً بك 👋'**
  String get homeGreeting;

  /// No description provided for @homeEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد حركات بعد'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'أضف أول مصروف أو دخل، وابدأ برؤية أين تذهب أموالك.'**
  String get homeEmptyBody;

  /// No description provided for @homeEmptyAction.
  ///
  /// In ar, this message translates to:
  /// **'أضف أول حركة'**
  String get homeEmptyAction;

  /// No description provided for @homeBalance.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد الحالي'**
  String get homeBalance;

  /// No description provided for @homeIncome.
  ///
  /// In ar, this message translates to:
  /// **'الدخل'**
  String get homeIncome;

  /// No description provided for @homeExpenses.
  ///
  /// In ar, this message translates to:
  /// **'المصاريف'**
  String get homeExpenses;

  /// No description provided for @homeThisPeriod.
  ///
  /// In ar, this message translates to:
  /// **'هذه الفترة'**
  String get homeThisPeriod;

  /// No description provided for @homeRecentTransactions.
  ///
  /// In ar, this message translates to:
  /// **'آخر الحركات'**
  String get homeRecentTransactions;

  /// No description provided for @homeTrialBanner.
  ///
  /// In ar, this message translates to:
  /// **'بقي {days} من التجربة المجانية'**
  String homeTrialBanner(String days);

  /// No description provided for @homeOfflineBanner.
  ///
  /// In ar, this message translates to:
  /// **'غير متصل — {count} حركة بانتظار المزامنة'**
  String homeOfflineBanner(int count);

  /// No description provided for @placeholderTitle.
  ///
  /// In ar, this message translates to:
  /// **'هذه الشاشة قيد البناء'**
  String get placeholderTitle;

  /// No description provided for @placeholderBody.
  ///
  /// In ar, this message translates to:
  /// **'ستُبنى هذه الشاشة في المرحلة {phase}. التطبيق الآن في مرحلة الأساس: التصميم والترجمة والتنقل والموافقات.'**
  String placeholderBody(String phase);

  /// No description provided for @placeholderPhaseLabel.
  ///
  /// In ar, this message translates to:
  /// **'المرحلة {phase}'**
  String placeholderPhaseLabel(int phase);

  /// No description provided for @settingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsTitle;

  /// No description provided for @settingsSectionAppearance.
  ///
  /// In ar, this message translates to:
  /// **'المظهر واللغة'**
  String get settingsSectionAppearance;

  /// No description provided for @settingsSectionMoney.
  ///
  /// In ar, this message translates to:
  /// **'الأموال والفترات'**
  String get settingsSectionMoney;

  /// No description provided for @settingsSectionData.
  ///
  /// In ar, this message translates to:
  /// **'البيانات والمزامنة'**
  String get settingsSectionData;

  /// No description provided for @settingsSectionNotifications.
  ///
  /// In ar, this message translates to:
  /// **'التنبيهات'**
  String get settingsSectionNotifications;

  /// No description provided for @settingsSectionLegal.
  ///
  /// In ar, this message translates to:
  /// **'القانوني والخصوصية'**
  String get settingsSectionLegal;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In ar, this message translates to:
  /// **'حول التطبيق'**
  String get settingsSectionAbout;

  /// No description provided for @settingsTheme.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get settingsTheme;

  /// No description provided for @settingsThemeLight.
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In ar, this message translates to:
  /// **'داكن'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In ar, this message translates to:
  /// **'تلقائي (حسب الجهاز)'**
  String get settingsThemeSystem;

  /// No description provided for @settingsLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In ar, this message translates to:
  /// **'لغة الجهاز'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsCurrency.
  ///
  /// In ar, this message translates to:
  /// **'العملة الأساسية'**
  String get settingsCurrency;

  /// No description provided for @settingsExchangeRates.
  ///
  /// In ar, this message translates to:
  /// **'أسعار الصرف'**
  String get settingsExchangeRates;

  /// No description provided for @settingsFiscalAnchor.
  ///
  /// In ar, this message translates to:
  /// **'يوم بداية الشهر المالي'**
  String get settingsFiscalAnchor;

  /// No description provided for @settingsBudgetMode.
  ///
  /// In ar, this message translates to:
  /// **'دورة الميزانية'**
  String get settingsBudgetMode;

  /// No description provided for @settingsBudgetModeMonthly.
  ///
  /// In ar, this message translates to:
  /// **'شهرية'**
  String get settingsBudgetModeMonthly;

  /// No description provided for @settingsBudgetModeWeekly.
  ///
  /// In ar, this message translates to:
  /// **'أسبوعية'**
  String get settingsBudgetModeWeekly;

  /// No description provided for @settingsBudgetModeBoth.
  ///
  /// In ar, this message translates to:
  /// **'الاثنتان معاً'**
  String get settingsBudgetModeBoth;

  /// No description provided for @settingsSync.
  ///
  /// In ar, this message translates to:
  /// **'المزامنة السحابية'**
  String get settingsSync;

  /// No description provided for @settingsSyncOff.
  ///
  /// In ar, this message translates to:
  /// **'معطّلة — بياناتك في جهازك فقط'**
  String get settingsSyncOff;

  /// No description provided for @settingsSyncOn.
  ///
  /// In ar, this message translates to:
  /// **'مفعّلة'**
  String get settingsSyncOn;

  /// No description provided for @settingsSyncRequiresConsent.
  ///
  /// In ar, this message translates to:
  /// **'تتطلب موافقة صريحة منفصلة (نقل البيانات خارج الوطن)'**
  String get settingsSyncRequiresConsent;

  /// No description provided for @settingsBackup.
  ///
  /// In ar, this message translates to:
  /// **'نسخة احتياطية محلية'**
  String get settingsBackup;

  /// No description provided for @settingsNotificationsDaily.
  ///
  /// In ar, this message translates to:
  /// **'تذكير يومي بالتسجيل'**
  String get settingsNotificationsDaily;

  /// No description provided for @settingsNotificationsBudget.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات تجاوز الميزانية'**
  String get settingsNotificationsBudget;

  /// No description provided for @settingsNotificationsDebts.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه آجال الديون'**
  String get settingsNotificationsDebts;

  /// No description provided for @legalTitle.
  ///
  /// In ar, this message translates to:
  /// **'القانوني والخصوصية'**
  String get legalTitle;

  /// No description provided for @legalPrivacy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get legalPrivacy;

  /// No description provided for @legalTerms.
  ///
  /// In ar, this message translates to:
  /// **'شروط الاستخدام'**
  String get legalTerms;

  /// No description provided for @legalSubscription.
  ///
  /// In ar, this message translates to:
  /// **'شروط الاشتراك والاسترداد'**
  String get legalSubscription;

  /// No description provided for @legalDisclaimer.
  ///
  /// In ar, this message translates to:
  /// **'إخلاء المسؤولية'**
  String get legalDisclaimer;

  /// No description provided for @legalExportData.
  ///
  /// In ar, this message translates to:
  /// **'تصدير كل بياناتي'**
  String get legalExportData;

  /// No description provided for @legalExportDataNote.
  ///
  /// In ar, this message translates to:
  /// **'حق الاطلاع وحق النقل — نصدر لك ملفاً بكل ما نملكه عنك.'**
  String get legalExportDataNote;

  /// No description provided for @legalRectifyData.
  ///
  /// In ar, this message translates to:
  /// **'طلب تصحيح بياناتي'**
  String get legalRectifyData;

  /// No description provided for @legalObjectData.
  ///
  /// In ar, this message translates to:
  /// **'الاعتراض على المعالجة'**
  String get legalObjectData;

  /// No description provided for @legalDeleteAccount.
  ///
  /// In ar, this message translates to:
  /// **'حذف حسابي وبياناتي نهائياً'**
  String get legalDeleteAccount;

  /// No description provided for @legalDeleteAccountNote.
  ///
  /// In ar, this message translates to:
  /// **'حق المحو — لا يمكن التراجع بعد التنفيذ.'**
  String get legalDeleteAccountNote;

  /// No description provided for @legalDpoContact.
  ///
  /// In ar, this message translates to:
  /// **'بريد مندوب حماية المعطيات'**
  String get legalDpoContact;

  /// No description provided for @legalComplaintAnpdp.
  ///
  /// In ar, this message translates to:
  /// **'تقديم شكوى لدى السلطة الوطنية (ANPDP)'**
  String get legalComplaintAnpdp;

  /// No description provided for @legalMyConsents.
  ///
  /// In ar, this message translates to:
  /// **'سجل موافقاتي'**
  String get legalMyConsents;

  /// No description provided for @legalComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'سيُفعَّل هذا الحق في المرحلة 4'**
  String get legalComingSoon;

  /// No description provided for @aboutVersion.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار'**
  String get aboutVersion;

  /// No description provided for @aboutBuild.
  ///
  /// In ar, this message translates to:
  /// **'رقم البناء'**
  String get aboutBuild;

  /// No description provided for @aboutLicenses.
  ///
  /// In ar, this message translates to:
  /// **'التراخيص مفتوحة المصدر'**
  String get aboutLicenses;

  /// No description provided for @aboutCheckUpdate.
  ///
  /// In ar, this message translates to:
  /// **'التحقق من التحديثات'**
  String get aboutCheckUpdate;

  /// No description provided for @aboutRateApp.
  ///
  /// In ar, this message translates to:
  /// **'قيّم التطبيق'**
  String get aboutRateApp;

  /// No description provided for @errorGenericTitle.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ'**
  String get errorGenericTitle;

  /// No description provided for @errorGenericBody.
  ///
  /// In ar, this message translates to:
  /// **'لم نتمكن من إتمام العملية. بياناتك محفوظة ولم يُفقد شيء.'**
  String get errorGenericBody;

  /// No description provided for @errorNetworkTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اتصال'**
  String get errorNetworkTitle;

  /// No description provided for @errorNetworkBody.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من اتصالك بالإنترنت ثم أعد المحاولة. يمكنك الاستمرار في استخدام التطبيق بدون إنترنت.'**
  String get errorNetworkBody;

  /// No description provided for @errorUnknownTitle.
  ///
  /// In ar, this message translates to:
  /// **'خطأ غير متوقع'**
  String get errorUnknownTitle;

  /// No description provided for @errorUnknownBody.
  ///
  /// In ar, this message translates to:
  /// **'حدث أمر لم نتوقعه. أعد المحاولة، وإن تكرر فأخبرنا عبر الدعم.'**
  String get errorUnknownBody;

  /// No description provided for @errorValidationTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من المدخلات'**
  String get errorValidationTitle;

  /// No description provided for @errorPermissionTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا تملك صلاحية'**
  String get errorPermissionTitle;

  /// No description provided for @errorPermissionBody.
  ///
  /// In ar, this message translates to:
  /// **'هذه الشاشة مخصّصة لدور معيّن. تواصل مع الدعم إن كنت تعتقد أن هذا خطأ.'**
  String get errorPermissionBody;

  /// No description provided for @errorFeatureLockedTitle.
  ///
  /// In ar, this message translates to:
  /// **'هذه الميزة مقفلة'**
  String get errorFeatureLockedTitle;

  /// No description provided for @errorFeatureLockedBody.
  ///
  /// In ar, this message translates to:
  /// **'انتهت فترة التجربة المجانية. اختر باقتك لتكمل — بياناتك محفوظة ويمكنك عرضها وتصديرها دائماً.'**
  String get errorFeatureLockedBody;

  /// No description provided for @errorContactSupport.
  ///
  /// In ar, this message translates to:
  /// **'تواصل مع الدعم'**
  String get errorContactSupport;

  /// No description provided for @validateEmailRequired.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني مطلوب'**
  String get validateEmailRequired;

  /// No description provided for @validateEmailInvalid.
  ///
  /// In ar, this message translates to:
  /// **'صيغة البريد غير صحيحة. مثال: name@mail.com'**
  String get validateEmailInvalid;

  /// No description provided for @validateEmailTooLong.
  ///
  /// In ar, this message translates to:
  /// **'البريد طويل جداً (الحد 254 محرفاً)'**
  String get validateEmailTooLong;

  /// No description provided for @validatePasswordRequired.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور مطلوبة'**
  String get validatePasswordRequired;

  /// No description provided for @validatePasswordTooShort.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور قصيرة — ٨ محارف على الأقل'**
  String get validatePasswordTooShort;

  /// No description provided for @validatePasswordNoDigit.
  ///
  /// In ar, this message translates to:
  /// **'أضف رقماً واحداً على الأقل لكلمة المرور'**
  String get validatePasswordNoDigit;

  /// No description provided for @validatePasswordTooLong.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور طويلة جداً (الحد 128 محرفاً)'**
  String get validatePasswordTooLong;

  /// No description provided for @validateConfirmMismatch.
  ///
  /// In ar, this message translates to:
  /// **'كلمتا المرور غير متطابقتين'**
  String get validateConfirmMismatch;

  /// No description provided for @validateNameTooLong.
  ///
  /// In ar, this message translates to:
  /// **'الاسم طويل جداً (الحد 40 محرفاً)'**
  String get validateNameTooLong;

  /// No description provided for @validateAmountRequired.
  ///
  /// In ar, this message translates to:
  /// **'أدخل المبلغ'**
  String get validateAmountRequired;

  /// No description provided for @validateAmountZero.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ يجب أن يكون أكبر من صفر'**
  String get validateAmountZero;

  /// No description provided for @validateAmountTooLarge.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ كبير جداً (الحد 999,999,999.99)'**
  String get validateAmountTooLarge;

  /// No description provided for @validateAmountDecimals.
  ///
  /// In ar, this message translates to:
  /// **'خانتان عشريتان كحد أقصى'**
  String get validateAmountDecimals;

  /// No description provided for @validatePhoneAlgerian.
  ///
  /// In ar, this message translates to:
  /// **'رقم جزائري غير صالح. يجب أن يبدأ بـ 05 أو 06 أو 07 (مثال: 0555123456)'**
  String get validatePhoneAlgerian;

  /// No description provided for @validateNoteTooLong.
  ///
  /// In ar, this message translates to:
  /// **'الملاحظة طويلة جداً (الحد 500 محرف)'**
  String get validateNoteTooLong;

  /// No description provided for @stateLoading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التحميل…'**
  String get stateLoading;

  /// No description provided for @stateSaving.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ الحفظ…'**
  String get stateSaving;

  /// No description provided for @stateEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد شيء هنا بعد'**
  String get stateEmpty;

  /// No description provided for @stateOffline.
  ///
  /// In ar, this message translates to:
  /// **'أنت غير متصل — التطبيق يعمل بشكل طبيعي'**
  String get stateOffline;

  /// No description provided for @stateSyncing.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ المزامنة…'**
  String get stateSyncing;

  /// No description provided for @stateSyncDone.
  ///
  /// In ar, this message translates to:
  /// **'تمت المزامنة بنجاح'**
  String get stateSyncDone;

  /// No description provided for @stateNoInternet.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد إنترنت'**
  String get stateNoInternet;

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الحذف'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeleteBody.
  ///
  /// In ar, this message translates to:
  /// **'سيُحذف هذا العنصر نهائياً. لا يمكن التراجع.'**
  String get confirmDeleteBody;

  /// No description provided for @confirmExitTitle.
  ///
  /// In ar, this message translates to:
  /// **'الخروج من التطبيق'**
  String get confirmExitTitle;

  /// No description provided for @confirmExitBody.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد إغلاق فلوسنا؟'**
  String get confirmExitBody;

  /// No description provided for @countdownNote.
  ///
  /// In ar, this message translates to:
  /// **'يتفعّل الزر بعد {seconds} ثانية — للتأكد من قصدك.'**
  String countdownNote(int seconds);

  /// No description provided for @fieldShowPassword.
  ///
  /// In ar, this message translates to:
  /// **'إظهار كلمة المرور'**
  String get fieldShowPassword;

  /// No description provided for @fieldHidePassword.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء كلمة المرور'**
  String get fieldHidePassword;

  /// No description provided for @validateRequired.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحقل مطلوب'**
  String get validateRequired;

  /// No description provided for @validateTooLong.
  ///
  /// In ar, this message translates to:
  /// **'النص طويل جداً (الحد {max} محرفاً)'**
  String validateTooLong(int max);

  /// No description provided for @incomeKind.
  ///
  /// In ar, this message translates to:
  /// **'دخل'**
  String get incomeKind;

  /// No description provided for @expenseKind.
  ///
  /// In ar, this message translates to:
  /// **'مصروف'**
  String get expenseKind;

  /// No description provided for @categoryFood.
  ///
  /// In ar, this message translates to:
  /// **'الطعام والتموين'**
  String get categoryFood;

  /// No description provided for @categoryTransport.
  ///
  /// In ar, this message translates to:
  /// **'النقل والتنقل'**
  String get categoryTransport;

  /// No description provided for @categoryHousing.
  ///
  /// In ar, this message translates to:
  /// **'السكن والإيجار'**
  String get categoryHousing;

  /// No description provided for @categoryUtilities.
  ///
  /// In ar, this message translates to:
  /// **'الكهرباء والغاز'**
  String get categoryUtilities;

  /// No description provided for @categoryWater.
  ///
  /// In ar, this message translates to:
  /// **'المياه'**
  String get categoryWater;

  /// No description provided for @categoryInternet.
  ///
  /// In ar, this message translates to:
  /// **'الإنترنت والهاتف'**
  String get categoryInternet;

  /// No description provided for @categoryHealth.
  ///
  /// In ar, this message translates to:
  /// **'الصحة والدواء'**
  String get categoryHealth;

  /// No description provided for @categoryEducation.
  ///
  /// In ar, this message translates to:
  /// **'التعليم والمدارس'**
  String get categoryEducation;

  /// No description provided for @categoryClothing.
  ///
  /// In ar, this message translates to:
  /// **'الملابس'**
  String get categoryClothing;

  /// No description provided for @categoryCharity.
  ///
  /// In ar, this message translates to:
  /// **'الزكاة والصدقة'**
  String get categoryCharity;

  /// No description provided for @categoryCafe.
  ///
  /// In ar, this message translates to:
  /// **'المقاهي والمشروبات'**
  String get categoryCafe;

  /// No description provided for @categoryGifts.
  ///
  /// In ar, this message translates to:
  /// **'الهدايا والمناسبات'**
  String get categoryGifts;

  /// No description provided for @categoryMaintenance.
  ///
  /// In ar, this message translates to:
  /// **'الصيانة والتصليح'**
  String get categoryMaintenance;

  /// No description provided for @categorySubscriptions.
  ///
  /// In ar, this message translates to:
  /// **'الاشتراكات'**
  String get categorySubscriptions;

  /// No description provided for @categoryDebtRepay.
  ///
  /// In ar, this message translates to:
  /// **'تسديد دين'**
  String get categoryDebtRepay;

  /// No description provided for @categoryDebtCollect.
  ///
  /// In ar, this message translates to:
  /// **'استرجاع دين'**
  String get categoryDebtCollect;

  /// No description provided for @categoryLeisure.
  ///
  /// In ar, this message translates to:
  /// **'الترفيه والسفر'**
  String get categoryLeisure;

  /// No description provided for @categorySalary.
  ///
  /// In ar, this message translates to:
  /// **'راتب شهري'**
  String get categorySalary;

  /// No description provided for @categoryDailyWage.
  ///
  /// In ar, this message translates to:
  /// **'أجرة يومية'**
  String get categoryDailyWage;

  /// No description provided for @categoryBonus.
  ///
  /// In ar, this message translates to:
  /// **'علاوة أو منحة'**
  String get categoryBonus;

  /// No description provided for @categoryFreelance.
  ///
  /// In ar, this message translates to:
  /// **'عمل حر'**
  String get categoryFreelance;

  /// No description provided for @categoryTrade.
  ///
  /// In ar, this message translates to:
  /// **'تجارة وبيع'**
  String get categoryTrade;

  /// No description provided for @categoryPension.
  ///
  /// In ar, this message translates to:
  /// **'معاش أو تقاعد'**
  String get categoryPension;

  /// No description provided for @categoryFamilyAid.
  ///
  /// In ar, this message translates to:
  /// **'مساعدة عائلية'**
  String get categoryFamilyAid;

  /// No description provided for @categoryOtherIncome.
  ///
  /// In ar, this message translates to:
  /// **'دخل آخر'**
  String get categoryOtherIncome;

  /// No description provided for @categoryOtherExpense.
  ///
  /// In ar, this message translates to:
  /// **'مصروف آخر'**
  String get categoryOtherExpense;

  /// No description provided for @txEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا حركات في هذه الفترة'**
  String get txEmptyTitle;

  /// No description provided for @txEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'سجّل أول حركة من زر الإضافة في الأسفل، وستظهر هنا مباشرة.'**
  String get txEmptyBody;

  /// No description provided for @txSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في الحركات…'**
  String get txSearchHint;

  /// No description provided for @txFilterAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get txFilterAll;

  /// No description provided for @txSortLabel.
  ///
  /// In ar, this message translates to:
  /// **'الأحدث أولاً'**
  String get txSortLabel;

  /// No description provided for @txTotalIncome.
  ///
  /// In ar, this message translates to:
  /// **'مجموع الدخل'**
  String get txTotalIncome;

  /// No description provided for @txTotalExpense.
  ///
  /// In ar, this message translates to:
  /// **'مجموع المصاريف'**
  String get txTotalExpense;

  /// No description provided for @budgetEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لم تُضبط ميزانية بعد'**
  String get budgetEmptyTitle;

  /// No description provided for @budgetEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'حدّد سقفاً لمصاريفك، وسننبهك قبل أن تتجاوزه — لا بعد فوات الأوان.'**
  String get budgetEmptyBody;

  /// No description provided for @budgetEmptyAction.
  ///
  /// In ar, this message translates to:
  /// **'اضبط ميزانيتي'**
  String get budgetEmptyAction;

  /// No description provided for @budgetSpent.
  ///
  /// In ar, this message translates to:
  /// **'المصروف'**
  String get budgetSpent;

  /// No description provided for @budgetRemaining.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي'**
  String get budgetRemaining;

  /// No description provided for @budgetLimitLabel.
  ///
  /// In ar, this message translates to:
  /// **'سقف الميزانية'**
  String get budgetLimitLabel;

  /// No description provided for @budgetWeeklySection.
  ///
  /// In ar, this message translates to:
  /// **'الميزانية الأسبوعية'**
  String get budgetWeeklySection;

  /// No description provided for @budgetMonthlySection.
  ///
  /// In ar, this message translates to:
  /// **'الميزانية الشهرية'**
  String get budgetMonthlySection;

  /// No description provided for @addTitle.
  ///
  /// In ar, this message translates to:
  /// **'حركة جديدة'**
  String get addTitle;

  /// No description provided for @addKindLabel.
  ///
  /// In ar, this message translates to:
  /// **'نوع الحركة'**
  String get addKindLabel;

  /// No description provided for @addAmountLabel.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ'**
  String get addAmountLabel;

  /// No description provided for @addAmountHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: 1500'**
  String get addAmountHint;

  /// No description provided for @addCategoryLabel.
  ///
  /// In ar, this message translates to:
  /// **'التصنيف'**
  String get addCategoryLabel;

  /// No description provided for @addNoteLabel.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة (اختياري)'**
  String get addNoteLabel;

  /// No description provided for @addNoteHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: خضرة السوق'**
  String get addNoteHint;

  /// No description provided for @addDateLabel.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get addDateLabel;

  /// No description provided for @addPhase2Title.
  ///
  /// In ar, this message translates to:
  /// **'الحفظ الفعلي يبدأ في المرحلة 2'**
  String get addPhase2Title;

  /// No description provided for @addPhase2Body.
  ///
  /// In ar, this message translates to:
  /// **'هذه الشاشة مكتملة: الحقول والتحقق والتصنيفات تعمل. حفظ الحركات في قاعدة بيانات الجهاز يأتي في المرحلة 2. لن يُحفظ شيء الآن، حتى لا تظن أن بياناتك محفوظة وهي ليست كذلك.'**
  String get addPhase2Body;

  /// No description provided for @addFormValid.
  ///
  /// In ar, this message translates to:
  /// **'الحقول صحيحة — جاهزة للحفظ'**
  String get addFormValid;

  /// No description provided for @moreSectionTools.
  ///
  /// In ar, this message translates to:
  /// **'أدوات'**
  String get moreSectionTools;

  /// No description provided for @moreSectionInfo.
  ///
  /// In ar, this message translates to:
  /// **'معلومات'**
  String get moreSectionInfo;

  /// No description provided for @moreSectionAccount.
  ///
  /// In ar, this message translates to:
  /// **'الحساب'**
  String get moreSectionAccount;

  /// No description provided for @moreGoals.
  ///
  /// In ar, this message translates to:
  /// **'أهداف الادخار'**
  String get moreGoals;

  /// No description provided for @moreDebts.
  ///
  /// In ar, this message translates to:
  /// **'الديون (عليك ولك)'**
  String get moreDebts;

  /// No description provided for @moreRecurring.
  ///
  /// In ar, this message translates to:
  /// **'الحركات المتكررة'**
  String get moreRecurring;

  /// No description provided for @moreReports.
  ///
  /// In ar, this message translates to:
  /// **'التقارير والتصدير'**
  String get moreReports;

  /// No description provided for @moreSubscription.
  ///
  /// In ar, this message translates to:
  /// **'الاشتراك والباقة'**
  String get moreSubscription;

  /// No description provided for @settingsBudgetModeHint.
  ///
  /// In ar, this message translates to:
  /// **'تُضبط الدورة حسب نوع دخلك: يومي ← أسبوعية، راتب ← شهرية.'**
  String get settingsBudgetModeHint;

  /// No description provided for @settingsFiscalAnchorHint.
  ///
  /// In ar, this message translates to:
  /// **'اليوم الذي يبدأ فيه شهرك المالي (من 1 إلى 28). مفيد إن كان راتبك ينزل يوم 25 مثلاً.'**
  String get settingsFiscalAnchorHint;

  /// No description provided for @settingsCurrencyHint.
  ///
  /// In ar, this message translates to:
  /// **'العملة التي تُجمع بها كل التقارير. العملات الأخرى تُسجَّل بسعر صرف يدوي.'**
  String get settingsCurrencyHint;

  /// No description provided for @settingsEraseAll.
  ///
  /// In ar, this message translates to:
  /// **'حذف كل البيانات من هذا الجهاز'**
  String get settingsEraseAll;

  /// No description provided for @settingsEraseAllNote.
  ///
  /// In ar, this message translates to:
  /// **'يمسح الموافقات والإعدادات وكل ما خُزن محلياً. لا يمكن التراجع.'**
  String get settingsEraseAllNote;

  /// No description provided for @settingsEraseConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف كل البيانات؟'**
  String get settingsEraseConfirmTitle;

  /// No description provided for @settingsEraseConfirmBody.
  ///
  /// In ar, this message translates to:
  /// **'سيُمسح كل شيء من هذا الجهاز نهائياً، وستعود إلى شاشة الترحيب وكأن التطبيق جديد.'**
  String get settingsEraseConfirmBody;

  /// No description provided for @settingsErased.
  ///
  /// In ar, this message translates to:
  /// **'حُذفت كل البيانات'**
  String get settingsErased;

  /// No description provided for @settingsNotificationsNote.
  ///
  /// In ar, this message translates to:
  /// **'التنبيهات تعمل محلياً بلا إنترنت، وتُفعَّل في المرحلة 5.'**
  String get settingsNotificationsNote;

  /// No description provided for @settingsSyncNote.
  ///
  /// In ar, this message translates to:
  /// **'المزامنة اختيارية وتبدأ في المرحلة 3، وتتطلب موافقة صريحة منفصلة.'**
  String get settingsSyncNote;

  /// No description provided for @settingsSaved.
  ///
  /// In ar, this message translates to:
  /// **'حُفظ الإعداد'**
  String get settingsSaved;

  /// No description provided for @legalConsentRecorded.
  ///
  /// In ar, this message translates to:
  /// **'الموافقة المسجَّلة'**
  String get legalConsentRecorded;

  /// No description provided for @legalConsentVersion.
  ///
  /// In ar, this message translates to:
  /// **'إصدار السياسة'**
  String get legalConsentVersion;

  /// No description provided for @legalConsentHash.
  ///
  /// In ar, this message translates to:
  /// **'بصمة الموافقة (SHA-256)'**
  String get legalConsentHash;

  /// No description provided for @legalConsentDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الموافقة'**
  String get legalConsentDate;

  /// No description provided for @legalNoConsentYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد موافقة مسجَّلة بعد'**
  String get legalNoConsentYet;

  /// No description provided for @legalRightsTitle.
  ///
  /// In ar, this message translates to:
  /// **'حقوقك الخمسة'**
  String get legalRightsTitle;

  /// No description provided for @legalRightsBody.
  ///
  /// In ar, this message translates to:
  /// **'الاطلاع · التصحيح · الاعتراض · الحذف · النقل. تمارسها من داخل التطبيق أو بمراسلة مندوب حماية المعطيات، ونرد خلال 72 ساعة كحد أقصى.'**
  String get legalRightsBody;

  /// No description provided for @legalCantOpenLink.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر فتح الرابط. انسخه وافتحه في المتصفح.'**
  String get legalCantOpenLink;

  /// No description provided for @legalCopied.
  ///
  /// In ar, this message translates to:
  /// **'نُسخ إلى الحافظة'**
  String get legalCopied;

  /// No description provided for @legalCopyAction.
  ///
  /// In ar, this message translates to:
  /// **'نسخ'**
  String get legalCopyAction;

  /// No description provided for @legalDataOnDevice.
  ///
  /// In ar, this message translates to:
  /// **'بياناتك الآن على هذا الجهاز فقط'**
  String get legalDataOnDevice;

  /// No description provided for @aboutTitle.
  ///
  /// In ar, this message translates to:
  /// **'حول التطبيق'**
  String get aboutTitle;

  /// No description provided for @aboutAppDescription.
  ///
  /// In ar, this message translates to:
  /// **'فلوسنا أداة تسجيل يدوي للدخل والمصاريف والميزانية. لا تربط بأي حساب بنكي أو بريدي، ولا تنفّذ أي دفع أو تحويل.'**
  String get aboutAppDescription;

  /// No description provided for @aboutNoBrandsNote.
  ///
  /// In ar, this message translates to:
  /// **'لا يذكُر التطبيق أسماء أي بنوك أو مؤسسات، ولا يطلب أرقام حسابات أو بطاقات.'**
  String get aboutNoBrandsNote;

  /// No description provided for @aboutPhaseLabel.
  ///
  /// In ar, this message translates to:
  /// **'المرحلة الحالية: الأساس (1 من 6)'**
  String get aboutPhaseLabel;

  /// No description provided for @aboutDataLocalNote.
  ///
  /// In ar, this message translates to:
  /// **'كل ما تسجّله يبقى في جهازك'**
  String get aboutDataLocalNote;

  /// عدد الأيام — صيغة الجمع تُدار آلياً حسب اللغة (ICU plural)
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{يوم واحد} =2{يومان} few{{count} أيام} many{{count} يوماً} other{{count} يوم}}'**
  String dayCountLabel(int count);

  /// إخلاء المسؤولية — طبيعة الأداة (حماية قانونية: ليست خدمة دفع)
  ///
  /// In ar, this message translates to:
  /// **'فلوسنا أداة متابعة يدوية. التطبيق:\n• ليس مؤسسة دفع ولا يملك أي ترخيص بنكي؛\n• لا ينفّذ أي دفع أو تحويل أو سحب؛\n• لا يتصل بأي حساب بنكي أو بريدي أو محفظة دفع؛\n• لا يقدّم أي نصيحة استثمارية أو ضريبية أو قانونية؛\n• يعرض مبالغ أدخلها المستخدم بنفسه، دون تحقق من أي جهة خارجية.\n\nالأرقام المعروضة تعكس ما أدخلته أنت فقط. تبقى مسؤولاً عن إدارة أموالك وعن تصريحاتك الجبائية.'**
  String get legalDisclaimerBody;

  /// شروط الاشتراك والاسترداد — بلا أسماء وسائل دفع ولا أرقام حسابات
  ///
  /// In ar, this message translates to:
  /// **'التجربة المجانية: سبعة أيام بكل الميزات، بلا أي دفع.\n\nبعد التجربة يلزم اشتراك لمواصلة تسجيل البيانات. أما الاطلاع والتقارير والتصدير وحذف بياناتك فتبقى مجانية ومتاحة في كل وقت (قفل مرن لا يحبس بياناتك).\n\nالباقات: الفرد · زوجان · العائلة، بأسعار شهرية وسنوية تُعرض في شاشة الاشتراك وقد تُعدَّل دون تحديث التطبيق.\n\nطريقة التفعيل: تختار الباقة داخل التطبيق، فيُرسل طلب إلى الفريق، ثم يصلك رمز تفعيل بعد الدفع. تفاصيل الدفع تُبلَّغ داخل المحادثة، ولا توضع أبداً داخل التطبيق.\n\nالاسترداد: الرمز غير المفعَّل قابل للاسترداد. الرمز المفعَّل غير قابل له، إلا عند تقصير من طرفنا.'**
  String get legalSubscriptionBody;

  /// وصف لقارئ الشاشة لشارة الموسم
  ///
  /// In ar, this message translates to:
  /// **'تصنيف موسمي — يرتفع استعماله في مواسم معيّنة'**
  String get categorySeasonalBadge;

  /// No description provided for @creditDeveloper.
  ///
  /// In ar, this message translates to:
  /// **'تطوير: Shawqi Builds'**
  String get creditDeveloper;

  /// No description provided for @socialSectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'تابعنا'**
  String get socialSectionTitle;

  /// No description provided for @socialHint.
  ///
  /// In ar, this message translates to:
  /// **'قنواتنا الرسمية: جديد التطبيق، نصائح عملية، وإعلانات.'**
  String get socialHint;

  /// No description provided for @channelFacebook.
  ///
  /// In ar, this message translates to:
  /// **'فيسبوك'**
  String get channelFacebook;

  /// No description provided for @channelInstagram.
  ///
  /// In ar, this message translates to:
  /// **'إنستغرام'**
  String get channelInstagram;

  /// No description provided for @channelTiktok.
  ///
  /// In ar, this message translates to:
  /// **'تيك توك'**
  String get channelTiktok;

  /// No description provided for @channelX.
  ///
  /// In ar, this message translates to:
  /// **'إكس'**
  String get channelX;

  /// No description provided for @channelYoutube.
  ///
  /// In ar, this message translates to:
  /// **'يوتيوب'**
  String get channelYoutube;

  /// No description provided for @channelTelegram.
  ///
  /// In ar, this message translates to:
  /// **'تيليغرام'**
  String get channelTelegram;

  /// No description provided for @channelWhatsapp.
  ///
  /// In ar, this message translates to:
  /// **'واتساب'**
  String get channelWhatsapp;

  /// No description provided for @catMgrTitle.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الفئات'**
  String get catMgrTitle;

  /// No description provided for @catMgrAdd.
  ///
  /// In ar, this message translates to:
  /// **'أضف فئة'**
  String get catMgrAdd;

  /// No description provided for @catMgrNameAr.
  ///
  /// In ar, this message translates to:
  /// **'الاسم بالعربية'**
  String get catMgrNameAr;

  /// No description provided for @catMgrNameFr.
  ///
  /// In ar, this message translates to:
  /// **'الاسم بالفرنسية'**
  String get catMgrNameFr;

  /// No description provided for @catMgrIconLabel.
  ///
  /// In ar, this message translates to:
  /// **'الأيقونة'**
  String get catMgrIconLabel;

  /// No description provided for @catMgrSeasonal.
  ///
  /// In ar, this message translates to:
  /// **'فئة موسمية (رمضان، دخول مدرسي…)'**
  String get catMgrSeasonal;

  /// No description provided for @catMgrEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا فئات مخصصة بعد'**
  String get catMgrEmpty;

  /// No description provided for @catMgrEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'أضف فئتك الأولى لتناسب طريقة صرفك أنت'**
  String get catMgrEmptyBody;

  /// No description provided for @catMgrSaved.
  ///
  /// In ar, this message translates to:
  /// **'حُفظت الفئة ✅'**
  String get catMgrSaved;

  /// No description provided for @catMgrArchived.
  ///
  /// In ar, this message translates to:
  /// **'مؤرشفة'**
  String get catMgrArchived;

  /// No description provided for @catMgrArchive.
  ///
  /// In ar, this message translates to:
  /// **'أرشفة'**
  String get catMgrArchive;

  /// No description provided for @catMgrRestore.
  ///
  /// In ar, this message translates to:
  /// **'استعادة'**
  String get catMgrRestore;

  /// No description provided for @catMgrDuplicate.
  ///
  /// In ar, this message translates to:
  /// **'يوجد فئة بنفس الاسم بالفعل'**
  String get catMgrDuplicate;

  /// No description provided for @txSavedSnack.
  ///
  /// In ar, this message translates to:
  /// **'سُجّلت الحركة ✅'**
  String get txSavedSnack;

  /// No description provided for @txNoResults.
  ///
  /// In ar, this message translates to:
  /// **'لا نتائج مطابقة لبحثك'**
  String get txNoResults;

  /// No description provided for @settingsCatMgr.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الفئات المخصصة'**
  String get settingsCatMgr;

  /// No description provided for @settingsCatMgrNote.
  ///
  /// In ar, this message translates to:
  /// **'أضف أو عدّل أو أرشف فئات مخصصة'**
  String get settingsCatMgrNote;

  /// No description provided for @budgetOverallLabel.
  ///
  /// In ar, this message translates to:
  /// **'كل المصاريف (سقف عام)'**
  String get budgetOverallLabel;

  /// No description provided for @budgetOverallShort.
  ///
  /// In ar, this message translates to:
  /// **'السقف العام'**
  String get budgetOverallShort;

  /// No description provided for @budgetAddLimit.
  ///
  /// In ar, this message translates to:
  /// **'إضافة سقف'**
  String get budgetAddLimit;

  /// No description provided for @budgetEditLimit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل السقف'**
  String get budgetEditLimit;

  /// No description provided for @budgetNewLimit.
  ///
  /// In ar, this message translates to:
  /// **'سقف جديد'**
  String get budgetNewLimit;

  /// No description provided for @budgetPickCategory.
  ///
  /// In ar, this message translates to:
  /// **'الفئة'**
  String get budgetPickCategory;

  /// No description provided for @budgetAmountLabel.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ السقف'**
  String get budgetAmountLabel;

  /// No description provided for @budgetAmountHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: 20000'**
  String get budgetAmountHint;

  /// No description provided for @budgetAlertPercentLabel.
  ///
  /// In ar, this message translates to:
  /// **'نبّهني عند'**
  String get budgetAlertPercentLabel;

  /// No description provided for @budgetAlertRange.
  ///
  /// In ar, this message translates to:
  /// **'نسبة التنبيه بين 50٪ و100٪'**
  String get budgetAlertRange;

  /// نسبة التنبيه من السقف
  ///
  /// In ar, this message translates to:
  /// **'{percent}٪ من السقف'**
  String budgetAlertPercentValue(int percent);

  /// No description provided for @budgetStatusSafe.
  ///
  /// In ar, this message translates to:
  /// **'داخل السقف'**
  String get budgetStatusSafe;

  /// No description provided for @budgetStatusNear.
  ///
  /// In ar, this message translates to:
  /// **'قريب من السقف'**
  String get budgetStatusNear;

  /// No description provided for @budgetStatusOver.
  ///
  /// In ar, this message translates to:
  /// **'تجاوزت السقف'**
  String get budgetStatusOver;

  /// النسبة المئوية المستهلكة
  ///
  /// In ar, this message translates to:
  /// **'{percent}٪'**
  String budgetUsedPercent(int percent);

  /// No description provided for @budgetSpentOfLimit.
  ///
  /// In ar, this message translates to:
  /// **'المصروف من السقف'**
  String get budgetSpentOfLimit;

  /// No description provided for @budgetRemainingLabel.
  ///
  /// In ar, this message translates to:
  /// **'الباقي لك'**
  String get budgetRemainingLabel;

  /// No description provided for @budgetOverByLabel.
  ///
  /// In ar, this message translates to:
  /// **'تجاوزت بـ'**
  String get budgetOverByLabel;

  /// No description provided for @budgetExhausted.
  ///
  /// In ar, this message translates to:
  /// **'استهلكت السقف كاملاً — لا مساحة متبقية'**
  String get budgetExhausted;

  /// No description provided for @budgetFormulaNote.
  ///
  /// In ar, this message translates to:
  /// **'الحساب: النسبة = المصروف ÷ السقف × 100. الحالة: آمن إن كانت أقل من نسبة التنبيه، قريب إن بلغتها، متجاوز إن تجاوزت 100٪.'**
  String get budgetFormulaNote;

  /// No description provided for @budgetSavedSnack.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ السقف'**
  String get budgetSavedSnack;

  /// No description provided for @budgetDeletedSnack.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف السقف'**
  String get budgetDeletedSnack;

  /// No description provided for @budgetDeleteTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف هذا السقف؟'**
  String get budgetDeleteTitle;

  /// No description provided for @budgetDeleteBody.
  ///
  /// In ar, this message translates to:
  /// **'يُحذف السقف فقط — حركاتك المالية تبقى كما هي بلا أي تغيير.'**
  String get budgetDeleteBody;

  /// No description provided for @budgetDeleteAction.
  ///
  /// In ar, this message translates to:
  /// **'احذف السقف'**
  String get budgetDeleteAction;

  /// No description provided for @budgetNotFound.
  ///
  /// In ar, this message translates to:
  /// **'هذا السقف لم يعد موجوداً'**
  String get budgetNotFound;

  /// No description provided for @budgetPeriodNote.
  ///
  /// In ar, this message translates to:
  /// **'السقوف تُحسب على الفترة الحالية المعروضة أعلاه.'**
  String get budgetPeriodNote;

  /// No description provided for @budgetAlertsSection.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات السقوف'**
  String get budgetAlertsSection;

  /// عنوان تنبيه التجاوز — اسم الفئة
  ///
  /// In ar, this message translates to:
  /// **'تجاوزت سقف «{category}»'**
  String budgetAlertOverTitle(String category);

  /// عنوان تنبيه الاقتراب — اسم الفئة
  ///
  /// In ar, this message translates to:
  /// **'اقتربت من سقف «{category}»'**
  String budgetAlertNearTitle(String category);

  /// تفصيل التجاوز — مبالغ مُنسَّقة
  ///
  /// In ar, this message translates to:
  /// **'صرفتَ {spent} من أصل {limit}'**
  String budgetAlertOverBody(String spent, String limit);

  /// تفصيل الاقتراب — مبالغ مُنسَّقة
  ///
  /// In ar, this message translates to:
  /// **'صرفتَ {spent} من أصل {limit} — بقي {remaining}'**
  String budgetAlertNearBody(String spent, String limit, String remaining);

  /// عدد التنبيهات الإضافية — صيغة الجمع تُدار آلياً (ICU plural)
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لا تنبيهات أخرى} =1{وتنبيه آخر} =2{وتنبيهان آخران} few{و{count} تنبيهات أخرى} many{و{count} تنبيهاً آخر} other{و{count} تنبيه آخر}}'**
  String budgetAlertMore(int count);

  /// No description provided for @budgetAlertAction.
  ///
  /// In ar, this message translates to:
  /// **'راجع السقوف'**
  String get budgetAlertAction;

  /// No description provided for @budgetCategoryMissing.
  ///
  /// In ar, this message translates to:
  /// **'فئة غير معروفة'**
  String get budgetCategoryMissing;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
