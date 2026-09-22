import '../../core/errors/app_error.dart';
import '../../core/utils/result.dart';

/// ═══════════════════════════════════════════════════════════════
///  SeedCategories — الكتالوج المرجعي للتصنيفات الجزائرية
///
///  ⭐ هذا الملف هو **مصدر الحقيقة** للتصنيفات:
///     - نفس المحتوى مكتوب في `assets/seed/categories.json`
///       (يُستعمل لملء قاعدة البيانات في المرحلة 2)
///     - اختبار `seed_consistency_test.dart` يتحقق أن الاثنين
///       متطابقان تماماً → لا يمكن أن يتباعدا
///
///  🔴 قاعدة صارمة: **صفر أسماء مؤسسات** (لا بنوك، لا بريد،
///     لا مشغّلو هاتف، لا شركات). القيم محايدة تماماً:
///     «تحويل بريدي» ← تصنيف عام، «الكهرباء والغاز» ← خدمات.
///
///  النصوص لا تُخزَّن هنا: كل تصنيف يحمل `labelKey` يشير إلى مفتاح
///  في ملفات .arb، فتعمل العربية والفرنسية من نفس المصدر.
/// ═══════════════════════════════════════════════════════════════

/// نوع التصنيف
enum SeedCategoryKind {
  /// مصروف (مال يخرج)
  expense,

  /// دخل (مال يدخل)
  income;

  /// من نص في JSON — يعيد `null` إن كانت القيمة غير معروفة
  static SeedCategoryKind? fromName(String? name) => switch (name) {
        'expense' => SeedCategoryKind.expense,
        'income' => SeedCategoryKind.income,
        _ => null,
      };
}

/// تصنيف واحد
class SeedCategory {
  const SeedCategory({
    required this.id,
    required this.kind,
    required this.labelKey,
    required this.icon,
    required this.sortOrder,
    this.seasonal = false,
  });

  /// معرّف ثابت لا يتغير أبداً (يُستعمل مفتاحاً في قاعدة البيانات)
  final String id;

  final SeedCategoryKind kind;

  /// مفتاح الترجمة في ar.arb / fr.arb — ⚠️ ليس نصاً
  final String labelKey;

  /// اسم الأيقونة (يُحوَّل إلى IconData في `seed_icons.dart`)
  /// ⭐ الاسم نص وليس IconData حتى يبقى هذا الملف Dart خالصاً
  ///   وقابلاً للاختبار بلا Flutter binding.
  final String icon;

  /// ترتيب العرض داخل النوع
  final int sortOrder;

  /// هل يرتفع استعماله في مواسم معيّنة؟ (رمضان، الأعياد، الصيف…)
  final bool seasonal;

  /// تحويل من JSON مع تحقق كامل
  static Result<SeedCategory, AppError> fromJson(Object? raw) {
    if (raw is! Map<String, dynamic>) {
      return Result<SeedCategory, AppError>.failure(
        AppError.validation('errorGenericBody', details: 'category is not an object'),
      );
    }

    final String? id = raw['id'] as String?;
    final String? labelKey = raw['labelKey'] as String?;
    final String? icon = raw['icon'] as String?;
    final Object? sortRaw = raw['sortOrder'];
    final SeedCategoryKind? kind = SeedCategoryKind.fromName(raw['kind'] as String?);

    if (id == null || id.isEmpty) {
      return Result<SeedCategory, AppError>.failure(
        AppError.validation('errorGenericBody', details: 'category.id missing'),
      );
    }
    if (kind == null) {
      return Result<SeedCategory, AppError>.failure(
        AppError.validation('errorGenericBody', details: 'category[$id].kind invalid'),
      );
    }
    if (labelKey == null || labelKey.isEmpty) {
      return Result<SeedCategory, AppError>.failure(
        AppError.validation('errorGenericBody', details: 'category[$id].labelKey missing'),
      );
    }
    if (icon == null || icon.isEmpty) {
      return Result<SeedCategory, AppError>.failure(
        AppError.validation('errorGenericBody', details: 'category[$id].icon missing'),
      );
    }
    final int sortOrder = sortRaw is int ? sortRaw : (int.tryParse('$sortRaw') ?? -1);
    if (sortOrder < 0) {
      return Result<SeedCategory, AppError>.failure(
        AppError.validation('errorGenericBody', details: 'category[$id].sortOrder invalid'),
      );
    }

    return Result<SeedCategory, AppError>.success(
      SeedCategory(
        id: id,
        kind: kind,
        labelKey: labelKey,
        icon: icon,
        sortOrder: sortOrder,
        seasonal: raw['seasonal'] == true,
      ),
    );
  }

  @override
  String toString() => 'SeedCategory($id, ${kind.name}, sort: $sortOrder)';
}

/// الكتالوج الكامل — مصروفات + مداخيل
class CategoryCatalog {
  const CategoryCatalog({
    required this.version,
    required this.expense,
    required this.income,
  });

  final int version;
  final List<SeedCategory> expense;
  final List<SeedCategory> income;

  List<SeedCategory> get all => <SeedCategory>[...expense, ...income];

  List<SeedCategory> ofKind(SeedCategoryKind kind) =>
      kind == SeedCategoryKind.expense ? expense : income;

  SeedCategory? byId(String id) {
    for (final SeedCategory category in all) {
      if (category.id == id) return category;
    }
    return null;
  }

  /// تحليل الملف الكامل مع تحقق صارم
  ///
  /// ⚠️ يفشل إن: البنية خاطئة · id مكرر · ترتيب مكرر داخل النوع
  /// · قائمة فارغة (تجربة المستخدم تتطلب تصنيفات جاهزة)
  static Result<CategoryCatalog, AppError> fromJson(Object? raw) {
    if (raw is! Map<String, dynamic>) {
      return Result<CategoryCatalog, AppError>.failure(
        AppError.validation('errorGenericBody', details: 'seed root is not an object'),
      );
    }

    final Object? versionRaw = raw['version'];
    final int version =
        versionRaw is int ? versionRaw : (int.tryParse('$versionRaw') ?? 0);
    if (version <= 0) {
      return Result<CategoryCatalog, AppError>.failure(
        AppError.validation('errorGenericBody', details: 'seed version invalid'),
      );
    }

    final Result<List<SeedCategory>, AppError> expense =
        _parseList(raw['expense'], SeedCategoryKind.expense);
    if (expense.isFailure) {
      return Result<CategoryCatalog, AppError>.failure(expense.errorOrNull!);
    }

    final Result<List<SeedCategory>, AppError> income =
        _parseList(raw['income'], SeedCategoryKind.income);
    if (income.isFailure) {
      return Result<CategoryCatalog, AppError>.failure(income.errorOrNull!);
    }

    final List<SeedCategory> expenseList = expense.requireValue;
    final List<SeedCategory> incomeList = income.requireValue;

    if (expenseList.isEmpty || incomeList.isEmpty) {
      return Result<CategoryCatalog, AppError>.failure(
        AppError.validation('errorGenericBody', details: 'seed lists must not be empty'),
      );
    }

    return Result<CategoryCatalog, AppError>.success(
      CategoryCatalog(
        version: version,
        expense: expenseList,
        income: incomeList,
      ),
    );
  }

  static Result<List<SeedCategory>, AppError> _parseList(
    Object? raw,
    SeedCategoryKind expectedKind,
  ) {
    if (raw is! List<dynamic>) {
      return Result<List<SeedCategory>, AppError>.failure(
        AppError.validation(
          'errorGenericBody',
          details: 'seed ${expectedKind.name} is not a list',
        ),
      );
    }

    final List<SeedCategory> result = <SeedCategory>[];
    final Set<String> ids = <String>{};
    final Set<int> orders = <int>{};

    for (final Object? item in raw) {
      final Result<SeedCategory, AppError> parsed = SeedCategory.fromJson(item);
      if (parsed.isFailure) {
        return Result<List<SeedCategory>, AppError>.failure(parsed.errorOrNull!);
      }
      final SeedCategory category = parsed.requireValue;

      if (category.kind != expectedKind) {
        return Result<List<SeedCategory>, AppError>.failure(
          AppError.validation(
            'errorGenericBody',
            details: 'category[${category.id}] in wrong list',
          ),
        );
      }
      if (!ids.add(category.id)) {
        return Result<List<SeedCategory>, AppError>.failure(
          AppError.validation(
            'errorGenericBody',
            details: 'duplicate category id: ${category.id}',
          ),
        );
      }
      if (!orders.add(category.sortOrder)) {
        return Result<List<SeedCategory>, AppError>.failure(
          AppError.validation(
            'errorGenericBody',
            details: 'duplicate sortOrder in ${expectedKind.name}: ${category.sortOrder}',
          ),
        );
      }
      result.add(category);
    }

    result.sort((SeedCategory a, SeedCategory b) => a.sortOrder.compareTo(b.sortOrder));
    return Result<List<SeedCategory>, AppError>.success(result);
  }
}

/// الكتالوج المضمّن — نفس محتوى `assets/seed/categories.json`
abstract final class SeedCategories {
  /// إصدار البذرة — يُرفع عند أي تغيير في القائمة
  static const int version = 1;

  /// ─────────── المصاريف ───────────
  static const List<SeedCategory> expense = <SeedCategory>[
    SeedCategory(
      id: 'food',
      kind: SeedCategoryKind.expense,
      labelKey: 'categoryFood',
      icon: 'restaurant',
      sortOrder: 1,
      seasonal: true,
    ),
    SeedCategory(
      id: 'transport',
      kind: SeedCategoryKind.expense,
      labelKey: 'categoryTransport',
      icon: 'directions_bus',
      sortOrder: 2,
    ),
    SeedCategory(
      id: 'housing',
      kind: SeedCategoryKind.expense,
      labelKey: 'categoryHousing',
      icon: 'home',
      sortOrder: 3,
    ),
    SeedCategory(
      id: 'utilities',
      kind: SeedCategoryKind.expense,
      labelKey: 'categoryUtilities',
      icon: 'bolt',
      sortOrder: 4,
    ),
    SeedCategory(
      id: 'water',
      kind: SeedCategoryKind.expense,
      labelKey: 'categoryWater',
      icon: 'water_drop',
      sortOrder: 5,
    ),
    SeedCategory(
      id: 'internet_phone',
      kind: SeedCategoryKind.expense,
      labelKey: 'categoryInternet',
      icon: 'wifi',
      sortOrder: 6,
    ),
    SeedCategory(
      id: 'health',
      kind: SeedCategoryKind.expense,
      labelKey: 'categoryHealth',
      icon: 'medical_services',
      sortOrder: 7,
    ),
    SeedCategory(
      id: 'education',
      kind: SeedCategoryKind.expense,
      labelKey: 'categoryEducation',
      icon: 'school',
      sortOrder: 8,
      seasonal: true,
    ),
    SeedCategory(
      id: 'clothing',
      kind: SeedCategoryKind.expense,
      labelKey: 'categoryClothing',
      icon: 'checkroom',
      sortOrder: 9,
      seasonal: true,
    ),
    SeedCategory(
      id: 'family_aid',
      kind: SeedCategoryKind.expense,
      labelKey: 'categoryFamilyAid',
      icon: 'family_restroom',
      sortOrder: 10,
    ),
    SeedCategory(
      id: 'zakat_charity',
      kind: SeedCategoryKind.expense,
      labelKey: 'categoryCharity',
      icon: 'volunteer_activism',
      sortOrder: 11,
      seasonal: true,
    ),
    SeedCategory(
      id: 'gifts_events',
      kind: SeedCategoryKind.expense,
      labelKey: 'categoryGifts',
      icon: 'card_giftcard',
      sortOrder: 12,
      seasonal: true,
    ),
    SeedCategory(
      id: 'cafe_drinks',
      kind: SeedCategoryKind.expense,
      labelKey: 'categoryCafe',
      icon: 'local_cafe',
      sortOrder: 13,
    ),
    SeedCategory(
      id: 'leisure_travel',
      kind: SeedCategoryKind.expense,
      labelKey: 'categoryLeisure',
      icon: 'flight',
      sortOrder: 14,
      seasonal: true,
    ),
    SeedCategory(
      id: 'maintenance',
      kind: SeedCategoryKind.expense,
      labelKey: 'categoryMaintenance',
      icon: 'handyman',
      sortOrder: 15,
    ),
    SeedCategory(
      id: 'subscriptions',
      kind: SeedCategoryKind.expense,
      labelKey: 'categorySubscriptions',
      icon: 'subscriptions',
      sortOrder: 16,
    ),
    SeedCategory(
      id: 'debt_repay',
      kind: SeedCategoryKind.expense,
      labelKey: 'categoryDebtRepay',
      icon: 'currency_exchange',
      sortOrder: 17,
    ),
    SeedCategory(
      id: 'other_expense',
      kind: SeedCategoryKind.expense,
      labelKey: 'categoryOtherExpense',
      icon: 'more_horiz',
      sortOrder: 18,
    ),
  ];

  /// ─────────── المداخيل ───────────
  static const List<SeedCategory> income = <SeedCategory>[
    SeedCategory(
      id: 'salary',
      kind: SeedCategoryKind.income,
      labelKey: 'categorySalary',
      icon: 'payments',
      sortOrder: 1,
    ),
    SeedCategory(
      id: 'daily_wage',
      kind: SeedCategoryKind.income,
      labelKey: 'categoryDailyWage',
      icon: 'construction',
      sortOrder: 2,
    ),
    SeedCategory(
      id: 'freelance',
      kind: SeedCategoryKind.income,
      labelKey: 'categoryFreelance',
      icon: 'laptop_mac',
      sortOrder: 3,
    ),
    SeedCategory(
      id: 'trade_sales',
      kind: SeedCategoryKind.income,
      labelKey: 'categoryTrade',
      icon: 'storefront',
      sortOrder: 4,
    ),
    SeedCategory(
      id: 'bonus_grant',
      kind: SeedCategoryKind.income,
      labelKey: 'categoryBonus',
      icon: 'workspace_premium',
      sortOrder: 5,
    ),
    SeedCategory(
      id: 'pension',
      kind: SeedCategoryKind.income,
      labelKey: 'categoryPension',
      icon: 'elderly',
      sortOrder: 6,
    ),
    SeedCategory(
      id: 'debt_collect',
      kind: SeedCategoryKind.income,
      labelKey: 'categoryDebtCollect',
      icon: 'handshake',
      sortOrder: 7,
    ),
    SeedCategory(
      id: 'other_income',
      kind: SeedCategoryKind.income,
      labelKey: 'categoryOtherIncome',
      icon: 'more_horiz',
      sortOrder: 8,
    ),
  ];

  /// الكتالوج الجاهز للاستعمال في الواجهة
  static const CategoryCatalog catalog = CategoryCatalog(
    version: version,
    expense: expense,
    income: income,
  );

  /// كل مفاتيح الترجمة المستعملة — يستعملها اختبار الترجمة
  static List<String> get allLabelKeys =>
      catalog.all.map((SeedCategory category) => category.labelKey).toList();

  /// كل أسماء الأيقونات المستعملة — يستعملها اختبار الأيقونات
  static List<String> get allIconNames =>
      catalog.all.map((SeedCategory category) => category.icon).toList();

  /// كل المعرّفات — يستعملها اختبار بذرة المناسبات
  static List<String> get allIds =>
      catalog.all.map((SeedCategory category) => category.id).toList();
}
