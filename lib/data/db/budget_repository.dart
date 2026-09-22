// ═══════════════════════════════════════════════════════════════
//  budget_repository.dart — البوابة الوحيدة لسقوف الصرف
//
//  ⭐ الشفافية أولاً (مبدأ ميثاق الميزات رقم 2): كل رقم هنا له
//     معادلة مكتوبة بالعربية يراها المستخدم في الشاشة:
//
//       المصروف      = مجموع مصاريف الفترة للفئة (بلا المحذوف ناعماً)
//       النسبة       = المصروف ÷ السقف × 100  (مقرّبة لعدد صحيح)
//       الباقي       = السقف − المصروف        (لا ينزل تحت الصفر)
//       التجاوز      = المصروف − السقف        (صفر حتى يتحقق التجاوز)
//       الحالة       :  آمن  → النسبة < نسبة التنبيه
//                      قريب → نسبة التنبيه ≤ النسبة < 100
//                      بلغ السقف/تجاوزه → النسبة ≥ 100
//                                     (وهي حالة واحدة حرجة: لا مساحة
//                                      متبقية؛ الرسالة تفرّق بين
//                                      «استهلكت السقف كاملاً» و«تجاوزت بـ X»)
//
//  ✅ كل دالة تُعيد Result: لا استثناءات طائرة نحو الواجهات.
//  ✅ كل زمن كتابة من ClockGuard.trustedNow.
//  ✅ الحذف ناعم (deletedAtMs) — «حذف السقف» لا يمسّ أي حركة.
//  ✅ سقف واحد فعّال لكل فئة: الإضافة الثانية تُحدّث الأولى بدل
//     أن تصنع سقفين متزاحمين على نفس الفئة (منع تناقض الأرقام).
// ═══════════════════════════════════════════════════════════════
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/errors/app_error.dart';
import '../../core/utils/clock_guard.dart';
import '../../core/utils/money.dart';
import '../../core/utils/result.dart';
import 'database.dart';
import 'db_revision.dart';
import 'tables.dart';

/// حالة السقف — ثلاث حالات يفهمها المستخدم بلا شرح طويل
enum BudgetStatus {
  /// داخل السقف بمساحة مريحة
  safe,

  /// وصل نسبة التنبيه التي اختارها المستخدم
  near,

  /// بلغ السقف أو تجاوزه
  over,
}

/// سقف + تقدّم الصرف فيه — كل ما تحتاجه الشاشة في كائن واحد
class BudgetProgress {
  const BudgetProgress({
    required this.budget,
    required this.limit,
    required this.spent,
  });

  final Budget budget;
  final Money limit;
  final Money spent;

  /// هل هذا السقف العام (كل المصاريف)؟
  bool get isOverall => budget.categoryId == null;

  /// النسبة المئوية للاستهلاك (مقرّبة لعدد صحيح)
  int get usedPercent {
    if (limit.centimes <= 0) return 0;
    return ((spent.centimes * 100) / limit.centimes).round();
  }

  /// الباقي قبل بلوغ السقف — لا ينزل تحت الصفر (لا «باقي سالب»)
  Money get remaining => Money.fromCentimes(
        limit.centimes - spent.centimes > 0 ? limit.centimes - spent.centimes : 0,
      );

  /// مقدار التجاوز — صفر حتى يتحقق التجاوز فعلاً
  Money get overBy => Money.fromCentimes(
        spent.centimes - limit.centimes > 0 ? spent.centimes - limit.centimes : 0,
      );

  /// بلغ السقف بالضبط (لا زيادة ولا نقصان) — رسالة مختلفة عن التجاوز
  bool get isExhausted => spent.centimes == limit.centimes;

  /// الحالة حسب المعادلة أعلاه.
  ///
  /// ⚠️ بلوغ السقف بالضبط يُعامل معاملة التجاوز: لا مساحة متبقية
  /// للصرف، فإخفاؤه في «قريب» يعطي إحساساً زائفاً بالأمان.
  BudgetStatus get status {
    if (spent.centimes >= limit.centimes) return BudgetStatus.over;
    if (usedPercent >= budget.alertPercent) return BudgetStatus.near;
    return BudgetStatus.safe;
  }

  /// نسبة الشريط (0..1) — مشدودة عند 1 حتى لا يتمدد الشريط خارج حدّه
  double get ratio => limit.centimes <= 0
      ? 0
      : (spent.centimes / limit.centimes).clamp(0.0, 1.0).toDouble();
}

/// ملخص صرف فئة واحدة داخل فترة (نتيجة استعلام تجميعي واحد)
typedef _CategorySpend = ({String categoryId, int centimes});

class BudgetRepository {
  BudgetRepository(this._db, this._clock);

  final FalousnaDatabase _db;
  final ClockGuard _clock;
  static const Uuid _uuid = Uuid();

  /// السقوف الفعّالة للملف الافتراضي (بلا المحذوف ناعماً)
  Future<Result<List<Budget>, AppError>> all() async {
    try {
      final List<Budget> rows = await (_db.select(_db.budgets)
            ..where((Budgets t) =>
                t.profileId.equals(kDefaultProfileId) & t.deletedAtMs.isNull())
            ..orderBy(<OrderClauseGenerator<$BudgetsTable>>[
              // العام أولاً ثم الأحدث — ترتيب ثابت لا يتغيّر بين الفتحات
              (Budgets t) => OrderingTerm(
                    expression: t.categoryId.isNull(),
                    mode: OrderingMode.desc,
                  ),
              (Budgets t) => OrderingTerm.desc(t.createdAtMs),
            ]))
          .get();
      return Result<List<Budget>, AppError>.success(rows);
    } on Object catch (error) {
      return Result<List<Budget>, AppError>.failure(
        AppError.storage(logOnly: 'budgets.all: $error'),
      );
    }
  }

  /// يثبّت سقفاً لفئة (أو سقفاً عاماً عند `categoryId = null`).
  ///
  /// إن كان هناك سقف فعّال لنفس الفئة ← **يُحدَّث** (استبدال)؛
  /// فلا ينشأ أبداً سقفان يتنازعان على نفس أرقام الفئة.
  Future<Result<void, AppError>> setLimit({
    required Money amount,
    String? categoryId,
    int alertPercent = 80,
  }) async {
    // ── تحقق مزدوج: لا نكتب قيمة فاسدة في القاعدة أبداً ──
    if (!amount.isPositive) {
      return Result<void, AppError>.failure(
        AppError.validation('validateAmountZero'),
      );
    }
    if (alertPercent < 50 || alertPercent > 100) {
      return Result<void, AppError>.failure(
        AppError.validation('budgetAlertRange'),
      );
    }
    if (categoryId != null && categoryId.trim().isEmpty) {
      return Result<void, AppError>.failure(
        AppError.validation('validateRequired'),
      );
    }

    final int nowMs = _clock.trustedNow().millisecondsSinceEpoch;
    try {
      final List<Budget> existing = await (_db.select(_db.budgets)
            ..where((Budgets t) =>
                t.profileId.equals(kDefaultProfileId) &
                t.deletedAtMs.isNull() &
                (categoryId == null
                    ? t.categoryId.isNull()
                    : t.categoryId.equals(categoryId))))
          .get();

      if (existing.isEmpty) {
        await _db.into(_db.budgets).insert(
              BudgetsCompanion.insert(
                id: _uuid.v4(),
                profileId: kDefaultProfileId,
                categoryId: Value<String?>(categoryId),
                amountCentimes: Value<int>(amount.centimes),
                alertPercent: Value<int>(alertPercent),
                createdAtMs: nowMs,
                updatedAtMs: nowMs,
              ),
            );
      } else {
        await (_db.update(_db.budgets)
              ..where((Budgets t) => t.id.equals(existing.first.id)))
            .write(
          BudgetsCompanion(
            amountCentimes: Value<int>(amount.centimes),
            alertPercent: Value<int>(alertPercent),
            updatedAtMs: Value<int>(nowMs),
          ),
        );
      }
      return const Result<void, AppError>.success(null);
    } on Object catch (error) {
      return Result<void, AppError>.failure(
        AppError.storage(logOnly: 'budgets.setLimit: $error'),
      );
    }
  }

  /// حذف ناعم للسقف — الحركات لا تُمسّ إطلاقاً
  Future<Result<void, AppError>> remove(String id) async {
    final int nowMs = _clock.trustedNow().millisecondsSinceEpoch;
    try {
      final int updated = await (_db.update(_db.budgets)
            ..where((Budgets t) => t.id.equals(id) & t.deletedAtMs.isNull()))
          .write(
        BudgetsCompanion(
          deletedAtMs: Value<int>(nowMs),
          updatedAtMs: Value<int>(nowMs),
        ),
      );
      if (updated == 0) {
        // السقف غير موجود أو محذوف مسبقاً — ليست كارثة بل نتيجة واضحة
        return Result<void, AppError>.failure(
          AppError.validation('budgetNotFound'),
        );
      }
      return const Result<void, AppError>.success(null);
    } on Object catch (error) {
      return Result<void, AppError>.failure(
        AppError.storage(logOnly: 'budgets.remove: $error'),
      );
    }
  }

  /// تقدّم كل سقف داخل الفترة [startMs, endMs) — نهاية حصرية.
  ///
  /// استعلام واحد تجميعي يجمع مصاريف الفترة حسب الفئة (لا استعلام
  /// لكل سقف): يبقى سريعاً مهما كثرت الفئات والسقوف.
  Future<Result<List<BudgetProgress>, AppError>> progress({
    required int startMs,
    required int endMs,
  }) async {
    if (endMs <= startMs) {
      return Result<List<BudgetProgress>, AppError>.failure(
        AppError.validation('validateRequired'),
      );
    }
    try {
      final List<Budget> limits = (await all()).getOrNull() ?? <Budget>[];
      if (limits.isEmpty) {
        return const Result<List<BudgetProgress>, AppError>.success(
          <BudgetProgress>[],
        );
      }

      final DateTime start = DateTime.fromMillisecondsSinceEpoch(startMs);
      final DateTime end = DateTime.fromMillisecondsSinceEpoch(endMs);

      final List<_CategorySpend> spends = await _spendsBetween(start, end);
      final Map<String, int> perCategory = <String, int>{
        for (final _CategorySpend s in spends) s.categoryId: s.centimes,
      };
      final int totalExpense =
          spends.fold<int>(0, (int sum, _CategorySpend s) => sum + s.centimes);

      final List<BudgetProgress> result = <BudgetProgress>[];
      for (final Budget b in limits) {
        final int spent = b.categoryId == null
            ? totalExpense
            : perCategory[b.categoryId!] ?? 0;
        result.add(
          BudgetProgress(
            budget: b,
            limit: Money.fromCentimes(b.amountCentimes),
            spent: Money.fromCentimes(spent),
          ),
        );
      }
      // الأولوية للخطر: الأعلى استهلاكاً نسبياً أولاً — عين المستخدم
      // تقع على المشكلة فوراً بدل أن تبحث عنها.
      result.sort((BudgetProgress a, BudgetProgress b) {
        if (a.status != b.status) {
          return b.status.index.compareTo(a.status.index);
        }
        return b.usedPercent.compareTo(a.usedPercent);
      });
      return Result<List<BudgetProgress>, AppError>.success(result);
    } on Object catch (error) {
      return Result<List<BudgetProgress>, AppError>.failure(
        AppError.storage(logOnly: 'budgets.progress: $error'),
      );
    }
  }

  /// مصاريف الفترة مجمّعة حسب الفئة — صف واحد لكل فئة
  Future<List<_CategorySpend>> _spendsBetween(
    DateTime start,
    DateTime end,
  ) async {
    final Expression<int> total =
        _db.transactions.amountCentimes.sum();
    final rows = await (_db.selectOnly(_db.transactions)
          ..addColumns(<Expression<Object>>[
            _db.transactions.categoryId,
            total,
          ])
          ..where(
            _db.transactions.kind.equals('expense') &
                _db.transactions.deletedAtMs.isNull() &
                _db.transactions.occurredOn.isBiggerOrEqualValue(start) &
                _db.transactions.occurredOn.isSmallerThanValue(end),
          )
          ..groupBy(<Expression<Object>>[_db.transactions.categoryId]))
        .get();

    return <_CategorySpend>[
      for (final row in rows)
        (
          categoryId: row.read<String>(_db.transactions.categoryId)!,
          centimes: row.read<int>(total) ?? 0,
        ),
    ];
  }
}

/// مزوّد المستودع — يُحقن في الاختبارات بقاعدة ذاكرة
final Provider<BudgetRepository> budgetRepositoryProvider =
    Provider<BudgetRepository>(
  (Ref ref) => BudgetRepository(
    ref.watch(falousnaDatabaseProvider),
    ref.watch(clockGuardProvider),
  ),
);

/// السقوف الفعّالة — تتحدّث تلقائياً بعد أي كتابة (نبض dbRevision)
final FutureProvider<List<Budget>> budgetsProvider =
    FutureProvider<List<Budget>>((Ref ref) async {
  ref.watch(dbRevisionProvider);
  final Result<List<Budget>, AppError> result =
      await ref.watch(budgetRepositoryProvider).all();
  final rows = result.getOrNull();
  if (rows == null) {
    throw result.errorOrNull!;
  }
  return rows;
});

/// تقدّم السقوف في فترة — مفتاحه (بداية، نهاية)
final budgetProgressProvider = FutureProvider.autoDispose
    .family<List<BudgetProgress>, ({int startMs, int endMs})>(
  (Ref ref, ({int startMs, int endMs}) p) async {
    ref.watch(dbRevisionProvider);
    final Result<List<BudgetProgress>, AppError> result =
        await ref.watch(budgetRepositoryProvider).progress(
              startMs: p.startMs,
              endMs: p.endMs,
            );
    final rows = result.getOrNull();
    if (rows == null) {
      throw result.errorOrNull!;
    }
    return rows;
  },
);

/// السقوف التي تستحق تنبيهاً — الحالات غير الآمنة فقط، الأشدّ أولاً.
///
/// دالة نقية (بلا حالة): نفس المدخل ← نفس المخرج دائماً، فتُختبَر وحدها.
List<BudgetProgress> budgetAlertsOf(List<BudgetProgress> all) {
  final List<BudgetProgress> alerts = all
      .where((BudgetProgress p) => p.status != BudgetStatus.safe)
      .toList()
    ..sort((BudgetProgress a, BudgetProgress b) {
    if (a.status != b.status) {
      return b.status.index.compareTo(a.status.index);
    }
      return b.usedPercent.compareTo(a.usedPercent);
    });
  return alerts;
}
