// ═══════════════════════════════════════════════════════════════
//  transaction_repository.dart — البوابة الوحيدة لقراءة/كتابة الحركات
//
//  ✅ كل دالة تُعيد Result: لا استثناءات طائرة نحو الواجهات أبداً.
//  ✅ كل زمن كتابة من ClockGuard.trustedNow (لا DateTime.now خام).
//  ✅ المبلغ يدخل Money مُتحقَّقاً منه مسبقاً (سنتيم صحيح موجب).
//  ✅ الحذف ناعم: deletedAtMs — كل الاستعلامات تستبعده تلقائياً.
// ═══════════════════════════════════════════════════════════════
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/config/constants.dart';
import '../../core/errors/app_error.dart';
import '../../core/utils/clock_guard.dart';
import '../../core/utils/money.dart';
import '../../core/utils/result.dart';
import '../../data/seed/seed_categories.dart';
import 'database.dart';
import 'db_revision.dart';
import 'tables.dart';

/// ملخص فترة مالية — أرقام حقيقية من القاعدة لا عروض تجريبية
class PeriodSummary {
  const PeriodSummary({
    required this.income,
    required this.expenses,
    required this.remaining,
    required this.count,
    this.topExpenseCategoryId,
  });

  final Money income;
  final Money expenses;
  final Money remaining;
  final int count;

  /// أكثر فئة التهمت المال في الفترة — لتقرير م5 وبطاقة م2.1
  final String? topExpenseCategoryId;

  bool get isEmpty => count == 0;
}

/// معاملات استعلام موحّدة (سجلّ قياسي = مفتاح family صالح للمقارنة)
typedef TxQuery = ({
  int startMs,
  int endMs,
  String? kindName,
  String? noteQuery,
  List<String>? categoryIds,
  int? limit,
});

class TransactionRepository {
  TransactionRepository(this._db, this._clock);

  final FalousnaDatabase _db;
  final ClockGuard _clock;
  static const Uuid _uuid = Uuid();

  /// ➕ تسجيل حركة — التحقق الثاني بعد تحقق الواجهة
  Future<Result<TransactionsCompanion, AppError>> validateNew({
    required SeedCategoryKind kind,
    required Money amount,
    required String categoryId,
    String note = '',
  }) async {
    if (amount.centimes <= 0) {
      return Result<TransactionsCompanion, AppError>.failure(
        AppError.validation('validateAmountZero'),
      );
    }
    if (categoryId.trim().isEmpty) {
      return Result<TransactionsCompanion, AppError>.failure(
        AppError.validation('validateRequired'),
      );
    }
    if (note.trim().length > AppConstants.maxNoteLength) {
      return Result<TransactionsCompanion, AppError>.failure(
        AppError.validation('validateNoteTooLong'),
      );
    }
    return Result<TransactionsCompanion, AppError>.success(
      TransactionsCompanion(
        kind: Value<String>(kind.name),
        amountCentimes: Value<int>(amount.centimes),
        currency: Value<String>(amount.currency),
        categoryId: Value<String>(categoryId.trim()),
        note: Value<String>(note.trim()),
      ),
    );
  }

  /// ➕ حفظ حركة كاملة (تحقق ثم إدخال) — تُعيد الصف المحفوظ
  Future<Result<Transaction, AppError>> add({
    required SeedCategoryKind kind,
    required Money amount,
    required String categoryId,
    String note = '',
    DateTime? occurredOn,
    String profileId = kDefaultProfileId,
  }) async {
    final Result<TransactionsCompanion, AppError> checked = await validateNew(
      kind: kind,
      amount: amount,
      categoryId: categoryId,
      note: note,
    );
    final TransactionsCompanion? base = checked.getOrNull();
    if (base == null) {
      return Result<Transaction, AppError>.failure(checked.errorOrNull!);
    }
    try {
      final DateTime now = _clock.trustedNow();
      final DateTime day = DateTime(
        (occurredOn ?? now).year,
        (occurredOn ?? now).month,
        (occurredOn ?? now).day,
      );
      final TransactionsCompanion companion = base.copyWith(
        id: Value<String>(_uuid.v4()),
        profileId: Value<String>(profileId),
        occurredOn: Value<DateTime>(day),
        createdAtMs: Value<int>(now.millisecondsSinceEpoch),
        updatedAtMs: Value<int>(now.millisecondsSinceEpoch),
      );
      await _db.into(_db.transactions).insert(companion);
      final Transaction? saved = await (_db.select(_db.transactions)
            ..where((Transactions t) => t.id.equals(companion.id.value)))
          .getSingleOrNull();
      return Result<Transaction, AppError>.success(saved!);
    } on Object catch (error) {
      return Result<Transaction, AppError>.failure(
        AppError.storage(logOnly: 'add: $error'),
      );
    }
  }

  /// 🗑 حذف ناعم — يُبقى السطر للمزامنة والتراجع
  Future<Result<void, AppError>> softDelete(String id) async {
    try {
      final DateTime now = _clock.trustedNow();
      await (_db.update(_db.transactions)
            ..where((Transactions t) => t.id.equals(id)))
          .write(
        TransactionsCompanion(
          deletedAtMs: Value<int?>(now.millisecondsSinceEpoch),
          updatedAtMs: Value<int>(now.millisecondsSinceEpoch),
        ),
      );
      return Result<void, AppError>.success(null);
    } on Object catch (error) {
      return Result<void, AppError>.failure(
        AppError.storage(logOnly: 'softDelete: $error'),
      );
    }
  }

  /// 🔎 حركات فترة [start, end) — end حصري دائماً (قاعدة الفترات)
  Future<Result<List<Transaction>, AppError>> query(TxQuery q) async {
    try {
      final String? note = q.noteQuery?.trim().toLowerCase();
      final select = _db.select(_db.transactions)
        ..where(
          (Transactions t) =>
              t.deletedAtMs.isNull() &
              t.occurredOn.isBiggerOrEqualValue(
                DateTime.fromMillisecondsSinceEpoch(q.startMs),
              ) &
              t.occurredOn.isSmallerThanValue(
                DateTime.fromMillisecondsSinceEpoch(q.endMs),
              ),
        );
      List<Transaction> rows = await select.get();
      if (q.kindName != null) {
        rows = rows.where((Transaction t) => t.kind == q.kindName).toList();
      }
      if (q.categoryIds != null) {
        rows = rows.where((Transaction t) => q.categoryIds!.contains(t.categoryId)).toList();
      }
      if (note != null && note.isNotEmpty) {
        rows = rows
            .where((Transaction t) => t.note.toLowerCase().contains(note))
            .toList();
      }
      rows.sort(
        (Transaction a, Transaction b) => b.occurredOn.compareTo(a.occurredOn),
      );
      if (q.limit != null && rows.length > q.limit!) {
        rows = rows.sublist(0, q.limit!);
      }
      return Result<List<Transaction>, AppError>.success(rows);
    } on Object catch (error) {
      return Result<List<Transaction>, AppError>.failure(
        AppError.storage(logOnly: 'query: $error'),
      );
    }
  }

  /// 📊 ملخص فترة: دخل − مصروف = متبقٍ + أكبر فئة مصروفاً
  Future<Result<PeriodSummary, AppError>> summary(int startMs, int endMs) async {
    try {
      final Result<List<Transaction>, AppError> rows = await query(
        (startMs: startMs, endMs: endMs, kindName: null, noteQuery: null, categoryIds: null, limit: null),
      );
      final List<Transaction>? txs = rows.getOrNull();
      if (txs == null) {
        return Result<PeriodSummary, AppError>.failure(rows.errorOrNull!);
      }
      int income = 0;
      int expense = 0;
      final Map<String, int> perCategory = <String, int>{};
      for (final Transaction t in txs) {
        if (t.kind == SeedCategoryKind.income.name) {
          income += t.amountCentimes;
        } else {
          expense += t.amountCentimes;
          perCategory[t.categoryId] =
              (perCategory[t.categoryId] ?? 0) + t.amountCentimes;
        }
      }
      String? top;
      int topValue = 0;
      perCategory.forEach((String id, int value) {
        if (value > topValue) {
          top = id;
          topValue = value;
        }
      });
      final Money incomeMoney = Money.fromCentimes(income);
      final Money expenseMoney = Money.fromCentimes(expense);
      final Result<Money, AppError> remaining =
          incomeMoney.subtract(expenseMoney);
      return Result<PeriodSummary, AppError>.success(
        PeriodSummary(
          income: incomeMoney,
          expenses: expenseMoney,
          remaining: remaining.getOrElse(Money.zero()),
          count: txs.length,
          topExpenseCategoryId: top,
        ),
      );
    } on Object catch (error) {
      return Result<PeriodSummary, AppError>.failure(
        AppError.storage(logOnly: 'summary: $error'),
      );
    }
  }

  /// 🔎 بحث شامل: الملاحظة تحتوي الاستعلام **أو** الفئة ضمن المطابقات
  /// (الواجهة تحسب معرّفات الفئات المطابقة للاسم بلغتها ثم تمررها هنا)
  Future<Result<List<Transaction>, AppError>> search({
    required int startMs,
    required int endMs,
    required String term,
    String? kindName,
    List<String> matchedCategoryIds = const <String>[],
  }) async {
    final String q = term.trim();
    if (q.isEmpty) {
      return query(
        (startMs: startMs, endMs: endMs, kindName: kindName, noteQuery: null, categoryIds: null, limit: null),
      );
    }
    final Result<List<Transaction>, AppError> byNote = await query(
      (startMs: startMs, endMs: endMs, kindName: kindName, noteQuery: q, categoryIds: null, limit: null),
    );
    final List<Transaction>? noteRows = byNote.getOrNull();
    if (noteRows == null) {
      return byNote;
    }
    if (matchedCategoryIds.isEmpty) {
      return byNote;
    }
    final Result<List<Transaction>, AppError> byCat = await query(
      (startMs: startMs, endMs: endMs, kindName: kindName, noteQuery: null, categoryIds: matchedCategoryIds, limit: null),
    );
    final List<Transaction>? catRows = byCat.getOrNull();
    if (catRows == null) {
      return byCat;
    }
    final Map<String, Transaction> merged = <String, Transaction>{
      for (final Transaction t in noteRows) t.id: t,
      for (final Transaction t in catRows) t.id: t,
    };
    final List<Transaction> rows = merged.values.toList()
      ..sort((Transaction a, Transaction b) => b.occurredOn.compareTo(a.occurredOn));
    return Result<List<Transaction>, AppError>.success(rows);
  }

  /// ⏱ آخر الحركات للشاشة الرئيسية
  Future<Result<List<Transaction>, AppError>> recent({int limit = 5}) async {
    try {
      final List<Transaction> rows = await (_db.select(_db.transactions)
            ..where((Transactions t) => t.deletedAtMs.isNull())
            ..orderBy(<OrderClauseGenerator<Transactions>>[
              (Transactions t) => OrderingTerm.desc(t.occurredOn),
              (Transactions t) => OrderingTerm.desc(t.createdAtMs),
            ])
            ..limit(limit))
          .get();
      return Result<List<Transaction>, AppError>.success(rows);
    } on Object catch (error) {
      return Result<List<Transaction>, AppError>.failure(
        AppError.storage(logOnly: 'recent: $error'),
      );
    }
  }
}

/// مزوّد المستودع — يُحقن في الاختبارات بقاعدة ذاكرة
final Provider<TransactionRepository> transactionRepositoryProvider =
    Provider<TransactionRepository>(
  (Ref ref) => TransactionRepository(
    ref.watch(falousnaDatabaseProvider),
    ref.watch(clockGuardProvider),
  ),
);

/// حركات فترة — مفتاحها سجلّ قياسي (family آمن)
final transactionsProvider =
    FutureProvider.autoDispose.family<List<Transaction>, TxQuery>(
  (Ref ref, TxQuery q) async {
    // نبض الكتابة: أي إضافة/حذف تُعيد هذه القراءة تلقائياً
    ref.watch(dbRevisionProvider);
    final Result<List<Transaction>, AppError> result =
        await ref.watch(transactionRepositoryProvider).query(q);
    final rows = result.getOrNull();
    if (rows == null) {
      throw result.errorOrNull!;
    }
    return rows;
  },
);

/// آخر الحركات — مفتاحه الحد الأقصى
final recentProvider =
    FutureProvider.autoDispose.family<List<Transaction>, int>(
  (Ref ref, int limit) async {
    ref.watch(dbRevisionProvider);
    final Result<List<Transaction>, AppError> result =
        await ref.watch(transactionRepositoryProvider).recent(limit: limit);
    final rows = result.getOrNull();
    if (rows == null) {
      throw result.errorOrNull!;
    }
    return rows;
  },
);

/// بحث الفترة — مفتاحه سجلّ قياسي (حدود + نوع + استعلام + فئات مطابقة)
final searchProvider = FutureProvider.autoDispose.family<
    List<Transaction>,
    ({int startMs, int endMs, String? kindName, String term, List<String> matched})>(
  (Ref ref, ({int startMs, int endMs, String? kindName, String term, List<String> matched}) p) async {
    ref.watch(dbRevisionProvider);
    final Result<List<Transaction>, AppError> result =
        await ref.watch(transactionRepositoryProvider).search(
              startMs: p.startMs,
              endMs: p.endMs,
              term: p.term,
              kindName: p.kindName,
              matchedCategoryIds: p.matched,
            );
    final rows = result.getOrNull();
    if (rows == null) {
      throw result.errorOrNull!;
    }
    return rows;
  },
);

/// ملخص فترة — مفتاحه (بداية، نهاية)
final periodSummaryProvider =
    FutureProvider.autoDispose.family<PeriodSummary, ({int startMs, int endMs})>(
  (Ref ref, ({int startMs, int endMs}) p) async {
    ref.watch(dbRevisionProvider);
    final Result<PeriodSummary, AppError> result =
        await ref.watch(transactionRepositoryProvider).summary(p.startMs, p.endMs);
    final summary = result.getOrNull();
    if (summary == null) {
      throw result.errorOrNull!;
    }
    return summary;
  },
);
