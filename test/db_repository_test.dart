// ═══════════════════════════════════════════════════════════════
//  db_repository_test.dart — المرحلة 2.1: قاعدة البيانات الحقيقية
//
//  ✅ NativeDatabase.memory(): اختبارات بلا قرص وبلا تلويث جهاز.
//  ✅ تغطي: الحفظ، الملخص، الفترات الحصريّة، الحذف الناعم، البحث،
//     الفئات المخصصة (تكرار/أرشفة/استعمال)، وحدود التحقق.
// ═══════════════════════════════════════════════════════════════
import 'package:drift/native.dart';
import 'package:falousna/core/errors/app_error.dart';
import 'package:falousna/core/utils/clock_guard.dart';
import 'package:falousna/core/utils/money.dart';
import 'package:falousna/core/utils/result.dart';
import 'package:falousna/data/db/category_repository.dart';
import 'package:falousna/data/db/database.dart';
import 'package:falousna/data/db/transaction_repository.dart';
import 'package:falousna/data/seed/seed_categories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late FalousnaDatabase db;
  late ClockGuard clock;
  late TransactionRepository txs;
  late CategoryRepository cats;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    db = FalousnaDatabase.forTesting(NativeDatabase.memory());
    clock = await ClockGuard.create();
    txs = TransactionRepository(db, clock);
    cats = CategoryRepository(db, clock);
  });

  tearDown(() async {
    await db.close();
  });

  DateTime today() {
    final DateTime now = clock.trustedNow();
    return DateTime(now.year, now.month, now.day);
  }

  int monthStartMs() {
    final DateTime d = today();
    return DateTime(d.year, d.month, 1).millisecondsSinceEpoch;
  }

  int monthEndMs() {
    final DateTime d = today();
    return DateTime(d.year, d.month + 1, 1).millisecondsSinceEpoch;
  }

  group('الحركات', () {
    test('حفظ دخل ومصروف ثم ملخص صحيح (دخل − مصروف = متبقٍ)', () async {
      final Result<Transaction, AppError> income = await txs.add(
        kind: SeedCategoryKind.income,
        amount: Money.fromWhole(1000),
        categoryId: 'salary',
      );
      expect(income.isSuccess, isTrue, reason: '${income.errorOrNull}');

      final Result<Transaction, AppError> expense = await txs.add(
        kind: SeedCategoryKind.expense,
        amount: Money.fromCentimes(25050),
        categoryId: 'food',
        note: 'سوق الأسبوع',
      );
      expect(expense.isSuccess, isTrue);

      final Result<PeriodSummary, AppError> summary =
          await txs.summary(monthStartMs(), monthEndMs());
      final PeriodSummary s = summary.requireValue;
      expect(s.count, 2);
      expect(s.income.centimes, 100000);
      expect(s.expenses.centimes, 25050);
      expect(s.remaining.centimes, 74950);
      expect(s.topExpenseCategoryId, 'food');
    });

    test('⭐ مبلغ صفر أو سالب مرفوض (التحقق الثاني)', () async {
      final Result<Transaction, AppError> zero = await txs.add(
        kind: SeedCategoryKind.expense,
        amount: Money.zero(),
        categoryId: 'food',
      );
      expect(zero.isFailure, isTrue);
      expect(zero.errorOrNull?.messageKey, 'validateAmountZero');
    });

    test('ملاحظة أطول من الحد مرفوضة', () async {
      final Result<Transaction, AppError> long = await txs.add(
        kind: SeedCategoryKind.expense,
        amount: Money.fromWhole(10),
        categoryId: 'food',
        note: 'م' * 201,
      );
      expect(long.isFailure, isTrue);
      expect(long.errorOrNull?.messageKey, 'validateNoteTooLong');
    });

    test('الحذف الناعم يُخرج الحركة من الملخص والاستعلام', () async {
      final Transaction saved = (await txs.add(
        kind: SeedCategoryKind.expense,
        amount: Money.fromWhole(50),
        categoryId: 'transport',
      ))
          .requireValue;

      final Result<void, AppError> deleted = await txs.softDelete(saved.id);
      expect(deleted.isSuccess, isTrue);

      final PeriodSummary s =
          (await txs.summary(monthStartMs(), monthEndMs())).requireValue;
      expect(s.count, 0);
      expect(s.isEmpty, isTrue);
    });

    test('فلتر النوع والملاحظة ومعرّفات الفئات', () async {
      await txs.add(
        kind: SeedCategoryKind.expense,
        amount: Money.fromWhole(10),
        categoryId: 'food',
        note: 'خبز وحليب',
      );
      await txs.add(
        kind: SeedCategoryKind.expense,
        amount: Money.fromWhole(20),
        categoryId: 'transport',
        note: 'طاكسي',
      );
      await txs.add(
        kind: SeedCategoryKind.income,
        amount: Money.fromWhole(30),
        categoryId: 'salary',
      );

      final Result<List<Transaction>, AppError> byNote = await txs.query(
        (
          startMs: monthStartMs(),
          endMs: monthEndMs(),
          kindName: null,
          noteQuery: 'طاكسي',
          categoryIds: null,
          limit: null,
        ),
      );
      expect(byNote.requireValue.length, 1);

      final Result<List<Transaction>, AppError> byKind = await txs.query(
        (
          startMs: monthStartMs(),
          endMs: monthEndMs(),
          kindName: SeedCategoryKind.expense.name,
          noteQuery: null,
          categoryIds: null,
          limit: null,
        ),
      );
      expect(byKind.requireValue.length, 2);

      final Result<List<Transaction>, AppError> byCat = await txs.query(
        (
          startMs: monthStartMs(),
          endMs: monthEndMs(),
          kindName: null,
          noteQuery: null,
          categoryIds: <String>['food'],
          limit: null,
        ),
      );
      expect(byCat.requireValue.length, 1);
    });

    test('⭐ نهاية الفترة حصريّة: حركة اليوم الأول من الشهر التالي خارجة', () async {
      final DateTime firstOfNext = DateTime(today().year, today().month + 1, 1);
      await txs.add(
        kind: SeedCategoryKind.expense,
        amount: Money.fromWhole(99),
        categoryId: 'food',
        occurredOn: firstOfNext,
      );
      final PeriodSummary s =
          (await txs.summary(monthStartMs(), monthEndMs())).requireValue;
      expect(s.count, 0);
    });

    test('recent يحترم الحد والترتيب الأحدث أولاً', () async {
      await txs.add(
        kind: SeedCategoryKind.expense,
        amount: Money.fromWhole(1),
        categoryId: 'food',
        occurredOn: today().subtract(const Duration(days: 2)),
      );
      await txs.add(
        kind: SeedCategoryKind.expense,
        amount: Money.fromWhole(2),
        categoryId: 'food',
      );
      final List<Transaction> recent =
          (await txs.recent(limit: 1)).requireValue;
      expect(recent.length, 1);
      expect(recent.first.amountCentimes, 200);
    });
  });

  group('الفئات المخصصة', () {
    test('تُدمج مع البذرة في العرض', () async {
      final int seedCount =
          SeedCategories.catalog.ofKind(SeedCategoryKind.expense).length;
      final Result<CategoryView, AppError> added = await cats.addCustom(
        kind: SeedCategoryKind.expense,
        nameAr: 'دروس خصوصية',
        nameFr: 'Cours particuliers',
        icon: 'school',
      );
      expect(added.isSuccess, isTrue, reason: '${added.errorOrNull}');

      final List<CategoryView> all =
          (await cats.all(SeedCategoryKind.expense)).requireValue;
      expect(all.length, seedCount + 1);
      expect(all.last.custom, isTrue);
    });

    test('⭐ التكرار بنفس الاسم العربي مرفوض', () async {
      await cats.addCustom(
        kind: SeedCategoryKind.expense,
        nameAr: 'حلاقة',
        nameFr: 'Coiffure',
        icon: 'checkroom',
      );
      final Result<CategoryView, AppError> dup = await cats.addCustom(
        kind: SeedCategoryKind.expense,
        nameAr: 'حلاقة',
        nameFr: 'Salon',
        icon: 'checkroom',
      );
      expect(dup.isFailure, isTrue);
      expect(dup.errorOrNull?.messageKey, 'catMgrDuplicate');
    });

    test('أيقونة خارج القائمة المغلقة مرفوضة', () async {
      final Result<CategoryView, AppError> bad = await cats.addCustom(
        kind: SeedCategoryKind.expense,
        nameAr: 'تجربة',
        nameFr: 'Test',
        icon: 'not_an_icon',
      );
      expect(bad.isFailure, isTrue);
    });

    test('الأرشفة تُخفي من العرض وisInUse ترى الحركات', () async {
      final CategoryView view = (await cats.addCustom(
        kind: SeedCategoryKind.expense,
        nameAr: 'اشتراك نادي',
        nameFr: 'Abonnement club',
        icon: 'workspace_premium',
      ))
          .requireValue;

      await txs.add(
        kind: SeedCategoryKind.expense,
        amount: Money.fromWhole(30),
        categoryId: view.id,
      );

      expect((await cats.isInUse(view.id)).requireValue, isTrue);

      final Result<void, AppError> archived =
          await cats.setArchived(view.id, archived: true);
      expect(archived.isSuccess, isTrue);
      final List<CategoryView> visible =
          (await cats.all(SeedCategoryKind.expense)).requireValue;
      expect(visible.any((CategoryView c) => c.id == view.id), isFalse);

      final List<CategoryView> withArchived =
          (await cats.all(SeedCategoryKind.expense, includeArchived: true))
              .requireValue;
      expect(withArchived.any((CategoryView c) => c.id == view.id), isTrue);
    });

    test('البحث بالاسم المخزن بلغته', () async {
      await cats.addCustom(
        kind: SeedCategoryKind.expense,
        nameAr: 'صيدلية',
        nameFr: 'Pharmacie',
        icon: 'medical_services',
      );
      final List<String> ar =
          (await cats.customIdsMatching('صيد', arabic: true)).requireValue;
      expect(ar.length, 1);
      final List<String> fr =
          (await cats.customIdsMatching('pharm', arabic: false)).requireValue;
      expect(fr.length, 1);
      final List<String> none =
          (await cats.customIdsMatching('لاشيء', arabic: true)).requireValue;
      expect(none, isEmpty);
    });
  });
}
