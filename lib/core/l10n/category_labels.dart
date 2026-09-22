import 'package:falousna/l10n/app_localizations.dart';

/// ═══════════════════════════════════════════════════════════════
///  CategoryLabels — جسر بين `labelKey` (في البذرة) والنص المترجم
///
///  ⭐ لماذا هذا الملف موجود؟
///     الترجمة المولَّدة (AppLocalizations) لا تسمح بالوصول إلى
///     مفتاح باسم متغيّر (`l10n[key]` غير ممكن). لذلك نربط كل
///     `labelKey` في `SeedCategories` بدالة صريحة هنا.
///
///  ⚠️ اختبار `seed_consistency_test.dart` يتحقق أن كل labelKey
///     في البذرة مغطّى هنا — فلا يظهر تصنيف بلا اسم أبداً.
/// ═══════════════════════════════════════════════════════════════
abstract final class CategoryLabels {
  /// يعيد الاسم المترجم للتصنيف
  ///
  /// [labelKey] مفتاح من `SeedCategory.labelKey`
  ///
  /// ⚠️ عند مفتاح غير معروف يعيد «مصروف آخر» بدل نص فارغ أو
  ///    استثناء — الشاشة تبقى قابلة للاستعمال.
  static String of(AppLocalizations l10n, String labelKey) => switch (labelKey) {
        // ── المصاريف ──
        'categoryFood' => l10n.categoryFood,
        'categoryTransport' => l10n.categoryTransport,
        'categoryHousing' => l10n.categoryHousing,
        'categoryUtilities' => l10n.categoryUtilities,
        'categoryWater' => l10n.categoryWater,
        'categoryInternet' => l10n.categoryInternet,
        'categoryHealth' => l10n.categoryHealth,
        'categoryEducation' => l10n.categoryEducation,
        'categoryClothing' => l10n.categoryClothing,
        'categoryFamilyAid' => l10n.categoryFamilyAid,
        'categoryCharity' => l10n.categoryCharity,
        'categoryGifts' => l10n.categoryGifts,
        'categoryCafe' => l10n.categoryCafe,
        'categoryLeisure' => l10n.categoryLeisure,
        'categoryMaintenance' => l10n.categoryMaintenance,
        'categorySubscriptions' => l10n.categorySubscriptions,
        'categoryDebtRepay' => l10n.categoryDebtRepay,
        'categoryOtherExpense' => l10n.categoryOtherExpense,

        // ── المداخيل ──
        'categorySalary' => l10n.categorySalary,
        'categoryDailyWage' => l10n.categoryDailyWage,
        'categoryFreelance' => l10n.categoryFreelance,
        'categoryTrade' => l10n.categoryTrade,
        'categoryBonus' => l10n.categoryBonus,
        'categoryPension' => l10n.categoryPension,
        'categoryDebtCollect' => l10n.categoryDebtCollect,
        'categoryOtherIncome' => l10n.categoryOtherIncome,

        // ── احتياطي ──
        _ => l10n.categoryOtherExpense,
      };

  /// كل المفاتيح المغطّاة — يستعملها الاختبار
  static const List<String> supportedKeys = <String>[
    'categoryFood',
    'categoryTransport',
    'categoryHousing',
    'categoryUtilities',
    'categoryWater',
    'categoryInternet',
    'categoryHealth',
    'categoryEducation',
    'categoryClothing',
    'categoryFamilyAid',
    'categoryCharity',
    'categoryGifts',
    'categoryCafe',
    'categoryLeisure',
    'categoryMaintenance',
    'categorySubscriptions',
    'categoryDebtRepay',
    'categoryOtherExpense',
    'categorySalary',
    'categoryDailyWage',
    'categoryFreelance',
    'categoryTrade',
    'categoryBonus',
    'categoryPension',
    'categoryDebtCollect',
    'categoryOtherIncome',
  ];
}
