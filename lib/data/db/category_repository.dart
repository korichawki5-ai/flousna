// ═══════════════════════════════════════════════════════════════
//  category_repository.dart — الفئات: بذرة جزائرية + فئات المستخدم
//
//  ✅ البذرة ثابتة ولا تُكتب في القاعدة (ترجمتها مفاتيح لغات).
//  ✅ فئات المستخدم تُدمج معها في عرض موحّد CategoryView.
//  ✅ الأرشفة لا الحذف: فئة مستعملة في حركات تبقى قابلة للقراءة.
// ═══════════════════════════════════════════════════════════════
import 'package:drift/drift.dart';
import 'package:falousna/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/config/constants.dart';
import '../../core/errors/app_error.dart';
import '../../core/l10n/category_labels.dart';
import '../../core/theme/seed_icons.dart';
import '../../core/utils/clock_guard.dart';
import '../../core/utils/result.dart';
import '../../data/seed/seed_categories.dart';
import 'database.dart';
import 'db_revision.dart';
import 'tables.dart';

/// عرض موحّد لفئة — بذرة كانت أم مخصصة
class CategoryView {
  const CategoryView({
    required this.id,
    required this.kind,
    required this.icon,
    required this.custom,
    this.seasonal = false,
    this.labelKey,
    this.nameAr,
    this.nameFr,
    this.archived = false,
  });

  factory CategoryView.fromSeed(SeedCategory seed) => CategoryView(
        id: seed.id,
        kind: seed.kind,
        icon: seed.icon,
        seasonal: seed.seasonal,
        custom: false,
        labelKey: seed.labelKey,
      );

  factory CategoryView.fromRow(CustomCategory row) => CategoryView(
        id: row.id,
        kind: SeedCategoryKind.values.byName(row.kind),
        icon: row.icon,
        seasonal: row.seasonal,
        custom: true,
        nameAr: row.nameAr,
        nameFr: row.nameFr,
        archived: row.archived,
      );

  final String id;
  final SeedCategoryKind kind;
  final String icon;
  final bool custom;
  final bool seasonal;
  final bool archived;

  /// للبذرة: مفتاح ترجمة. للمخصصة: null
  final String? labelKey;
  final String? nameAr;
  final String? nameFr;

  /// الاسم المعروض — البذرة عبر الجسر، والمخصصة بلغتها المخزنة
  String displayName(AppLocalizations l10n, {required bool arabic}) {
    if (!custom) {
      return CategoryLabels.of(l10n, labelKey ?? '');
    }
    return arabic ? (nameAr ?? '') : (nameFr ?? '');
  }


}

class CategoryRepository {
  CategoryRepository(this._db, this._clock);

  final FalousnaDatabase _db;
  final ClockGuard _clock;
  static const Uuid _uuid = Uuid();

  /// كل فئات نوع ما: بذرة + مخصصات غير المؤرشفة (المخصّصة أخيراً)
  Future<Result<List<CategoryView>, AppError>> all(
    SeedCategoryKind kind, {
    bool includeArchived = false,
  }) async {
    try {
      final List<SeedCategory> seeds = SeedCategories.catalog.ofKind(kind);
      var select = _db.select(_db.customCategories)
        ..where((CustomCategories c) => c.kind.equals(kind.name));
      if (!includeArchived) {
        select = select..where((CustomCategories c) => c.archived.equals(false));
      }
      final List<CustomCategory> customs = await select.get();
      customs.sort((CustomCategory a, CustomCategory b) =>
          a.createdAtMs.compareTo(b.createdAtMs));
      return Result<List<CategoryView>, AppError>.success(<CategoryView>[
        ...seeds.map(CategoryView.fromSeed),
        ...customs.map(CategoryView.fromRow),
      ]);
    } on Object catch (error) {
      return Result<List<CategoryView>, AppError>.failure(
        AppError.storage(logOnly: 'categories.all: $error'),
      );
    }
  }

  /// المخصصات فقط (لشاشة الإدارة) — المؤرشفة اختيارية
  Future<Result<List<CategoryView>, AppError>> customOnly({
    bool includeArchived = true,
  }) async {
    try {
      var select = _db.select(_db.customCategories);
      if (!includeArchived) {
        select = select..where((CustomCategories c) => c.archived.equals(false));
      }
      final List<CustomCategory> rows = await select.get();
      rows.sort((CustomCategory a, CustomCategory b) =>
          a.createdAtMs.compareTo(b.createdAtMs));
      return Result<List<CategoryView>, AppError>.success(
        rows.map(CategoryView.fromRow).toList(),
      );
    } on Object catch (error) {
      return Result<List<CategoryView>, AppError>.failure(
        AppError.storage(logOnly: 'categories.customOnly: $error'),
      );
    }
  }

  /// ➕ فئة مخصصة جديدة — تحقق مزدوج: أسماء وأيقونة وتكرار
  Future<Result<CategoryView, AppError>> addCustom({
    required SeedCategoryKind kind,
    required String nameAr,
    required String nameFr,
    required String icon,
    bool seasonal = false,
  }) async {
    final String ar = nameAr.trim();
    final String fr = nameFr.trim();
    if (ar.isEmpty || fr.isEmpty) {
      return Result<CategoryView, AppError>.failure(
        AppError.validation('validateRequired'),
      );
    }
    if (ar.length > AppConstants.maxCategoryNameLength ||
        fr.length > AppConstants.maxCategoryNameLength) {
      return Result<CategoryView, AppError>.failure(
        AppError.validation('validateTooLong'),
      );
    }
    if (!SeedIcons.knownNames.contains(icon)) {
      return Result<CategoryView, AppError>.failure(
        AppError.validation('validateRequired'),
      );
    }
    try {
      final List<CustomCategory> existing = await (_db.select(_db.customCategories)
            ..where((CustomCategories c) => c.kind.equals(kind.name)))
          .get();
      final bool duplicate = existing.any(
        (CustomCategory c) =>
            !c.archived &&
            (c.nameAr.trim().toLowerCase() == ar.toLowerCase() ||
                c.nameFr.trim().toLowerCase() == fr.toLowerCase()),
      );
      if (duplicate) {
        return Result<CategoryView, AppError>.failure(
          AppError.validation('catMgrDuplicate'),
        );
      }
      final DateTime now = _clock.trustedNow();
      final String id = 'cc-${_uuid.v4()}';
      await _db.into(_db.customCategories).insert(
            CustomCategoriesCompanion.insert(
              id: id,
              kind: kind.name,
              nameAr: ar,
              nameFr: fr,
              icon: icon,
              seasonal: Value<bool>(seasonal),
              createdAtMs: now.millisecondsSinceEpoch,
            ),
          );
      return Result<CategoryView, AppError>.success(
        CategoryView(
          id: id,
          kind: kind,
          icon: icon,
          seasonal: seasonal,
          custom: true,
          nameAr: ar,
          nameFr: fr,
        ),
      );
    } on Object catch (error) {
      return Result<CategoryView, AppError>.failure(
        AppError.storage(logOnly: 'categories.add: $error'),
      );
    }
  }

  /// أرشفة / استعادة — لا حذف قاطع أبداً
  Future<Result<void, AppError>> setArchived(String id, {required bool archived}) async {
    try {
      await (_db.update(_db.customCategories)
            ..where((CustomCategories c) => c.id.equals(id)))
          .write(CustomCategoriesCompanion(archived: Value<bool>(archived)));
      return Result<void, AppError>.success(null);
    } on Object catch (error) {
      return Result<void, AppError>.failure(
        AppError.storage(logOnly: 'categories.archive: $error'),
      );
    }
  }

  /// هل للفئة حركات؟ (لتقرير المصير: أرشفة فقط أم إلغاء كامل)
  Future<Result<bool, AppError>> isInUse(String id) async {
    try {
      final int count = await (_db.select(_db.transactions)
            ..where(
              (Transactions t) =>
                  t.categoryId.equals(id) & t.deletedAtMs.isNull(),
            )
            ..limit(1))
          .get()
          .then((List<Transaction> rows) => rows.length);
      return Result<bool, AppError>.success(count > 0);
    } on Object catch (error) {
      return Result<bool, AppError>.failure(
        AppError.storage(logOnly: 'categories.inUse: $error'),
      );
    }
  }

  /// معرّفات الفئات المخصصة المطابقة لبحث المستخدم (بالاسم المخزن)
  Future<Result<List<String>, AppError>> customIdsMatching(
    String query, {
    required bool arabic,
  }) async {
    try {
      final String q = query.trim().toLowerCase();
      if (q.isEmpty) {
        return Result<List<String>, AppError>.success(const <String>[]);
      }
      final List<CustomCategory> rows =
          await _db.select(_db.customCategories).get();
      return Result<List<String>, AppError>.success(
        rows
            .where(
              (CustomCategory c) =>
                  (arabic ? c.nameAr : c.nameFr).toLowerCase().contains(q),
            )
            .map((CustomCategory c) => c.id)
            .toList(),
      );
    } on Object catch (error) {
      return Result<List<String>, AppError>.failure(
        AppError.storage(logOnly: 'categories.match: $error'),
      );
    }
  }
}

/// مزوّد مستودع الفئات
final Provider<CategoryRepository> categoryRepositoryProvider =
    Provider<CategoryRepository>(
  (Ref ref) => CategoryRepository(
    ref.watch(falousnaDatabaseProvider),
    ref.watch(clockGuardProvider),
  ),
);

/// فئات نوع ما للعرض — عائلة بمفتاح النوع
final categoriesProvider =
    FutureProvider.autoDispose.family<List<CategoryView>, SeedCategoryKind>(
  (Ref ref, SeedCategoryKind kind) async {
    ref.watch(dbRevisionProvider);
    final Result<List<CategoryView>, AppError> result =
        await ref.watch(categoryRepositoryProvider).all(kind);
    final views = result.getOrNull();
    if (views == null) {
      throw result.errorOrNull!;
    }
    return views;
  },
);
