import '../config/constants.dart';
import 'clock_guard.dart';

/// ═══════════════════════════════════════════════════════════════
///  PeriodResolver — الدورة المالية المرنة
///
///  ⭐ دالة موحّدة تُستدعى في كل مكان. **لا حساب فترات مكرر أبداً**
///     — التكرار هو مصدر الأخطاء الكلاسيكي في تطبيقات الميزانية.
///
///  الأوضاع:
///   • monthly : يوم بداية مخصص (1..28)
///   • weekly  : السبت → الجمعة (المعيار الجزائري)
///   • both    : ميزانية أسبوعية + نظرة شهرية مجمّعة
///
///  ⚠️ حدّ معروف: 29/30/31 غير مدعومة كمرساة شهرية لأنها غير
///     موجودة في بعض الشهور (فيفري). القيد 1..28.
/// ═══════════════════════════════════════════════════════════════

/// وضع دورة الميزانية
enum BudgetMode {
  monthly,
  weekly,
  both;

  static BudgetMode fromName(String? name) => BudgetMode.values.firstWhere(
        (BudgetMode m) => m.name == name,
        orElse: () => BudgetMode.monthly,
      );
}

/// فترة مالية محددة ببداية ونهاية
class FiscalPeriod {
  const FiscalPeriod({
    required this.start,
    required this.end,
    required this.mode,
    required this.anchorDay,
    required this.lengthDays,
    required this.index,
  });

  /// أول لحظة في الفترة (00:00:00.000)
  final DateTime start;

  /// أول لحظة بعد الفترة (حصرية) — أي `end` = بداية الفترة التالية
  final DateTime end;

  /// الوضع الذي أنتج هذه الفترة
  final BudgetMode mode;

  /// يوم المرساة المستعمل (للموثوقية والتدقيق)
  final int anchorDay;

  /// طول الفترة بالأيام — ⚠️ قد يكون 28/29/30/31
  final int lengthDays;

  /// رقم تسلسلي فريد للفترة (يُستعمل كمفتاح في قاعدة البيانات)
  ///
  /// شهري: `سنة × 12 + شهر` (معدل حسب المرساة)
  /// أسبوعي: عدد الأسابيع منذ مرجع ثابت
  final int index;

  /// هل [moment] تقع داخل هذه الفترة؟
  bool contains(DateTime moment) =>
      !moment.isBefore(start) && moment.isBefore(end);

  /// عدد الأيام في الفترة
  Duration get duration => end.difference(start);

  /// منتصف الفترة (لتقارير «حتى الآن»)
  DateTime get midpoint => start.add(Duration(milliseconds: duration.inMilliseconds ~/ 2));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FiscalPeriod &&
          other.start == start &&
          other.end == end &&
          other.mode == mode &&
          other.index == index);

  @override
  int get hashCode => Object.hash(start, end, mode, index);

  @override
  String toString() =>
      'FiscalPeriod(${start.toIso8601String()} → ${end.toIso8601String()}, ${mode.name}, $lengthDays days)';
}

/// نتيجة حلّ فترة: الأساسية + المجمّعة (في وضع both)
class PeriodResolution {
  const PeriodResolution({required this.primary, this.aggregate});

  /// الفترة الأساسية المعروضة للمستخدم
  final FiscalPeriod primary;

  /// الفترة المجمّعة (شهرية) — موجودة فقط في وضع [BudgetMode.both]
  final FiscalPeriod? aggregate;

  /// كل الفترات المعروضة (واحدة أو اثنتان)
  List<FiscalPeriod> get all => <FiscalPeriod>[
        primary,
        ?aggregate,
      ];
}

abstract final class PeriodResolver {
  /// مرجع ثابت لحساب فهارس الأسابيع (أول سبت من سنة 2000)
  static final DateTime _weekEpoch = _firstSaturdayOf(DateTime(2000, 1, 1));

  /// يحلّ الفترة الحالية حسب إعدادات المستخدم.
  ///
  /// [now] يُمرَّر من [ClockGuard.trustedNow] — ⚠️ لا `DateTime.now()`
  /// مباشرة، وإلا انكسرت حماية التلاعب بالساعة.
  static PeriodResolution resolve({
    required DateTime now,
    BudgetMode mode = BudgetMode.monthly,
    int anchorDay = 1,
  }) {
    final int safeAnchor = _clampAnchor(anchorDay);

    switch (mode) {
      case BudgetMode.weekly:
        final FiscalPeriod week = _weeklyPeriod(now);
        return PeriodResolution(primary: week);

      case BudgetMode.monthly:
        final FiscalPeriod month = _monthlyPeriod(now, safeAnchor);
        return PeriodResolution(primary: month);

      case BudgetMode.both:
        // الأساسي = الأسبوعي (لأن من يختار both عادة دخله متغيّر)
        final FiscalPeriod week = _weeklyPeriod(now);
        final FiscalPeriod month = _monthlyPeriod(now, safeAnchor);
        return PeriodResolution(primary: week, aggregate: month);
    }
  }

  /// يحلّ الفترة الحالية باستعمال حارس الساعة مباشرة (الأكثر أماناً)
  static PeriodResolution resolveTrusted(
    ClockGuard clock, {
    BudgetMode mode = BudgetMode.monthly,
    int anchorDay = 1,
  }) =>
      resolve(now: clock.trustedNow(), mode: mode, anchorDay: anchorDay);

  /// الفترة السابقة (للمقارنة ▲▼)
  static PeriodResolution previous({
    required DateTime now,
    BudgetMode mode = BudgetMode.monthly,
    int anchorDay = 1,
  }) {
    final FiscalPeriod current = resolve(now: now, mode: mode, anchorDay: anchorDay).primary;
    final DateTime before = current.start.subtract(const Duration(minutes: 1));
    return resolve(now: before, mode: mode, anchorDay: anchorDay);
  }

  /// الفترة التالية
  static PeriodResolution next({
    required DateTime now,
    BudgetMode mode = BudgetMode.monthly,
    int anchorDay = 1,
  }) {
    final FiscalPeriod current = resolve(now: now, mode: mode, anchorDay: anchorDay).primary;
    return resolve(now: current.end, mode: mode, anchorDay: anchorDay);
  }

  /// فترة محددة بإزاحة (0 = الحالية، -1 = السابقة، +2 = بعد فترتين)
  static PeriodResolution offset({
    required DateTime now,
    required int periods,
    BudgetMode mode = BudgetMode.monthly,
    int anchorDay = 1,
  }) {
    PeriodResolution result = resolve(now: now, mode: mode, anchorDay: anchorDay);
    if (periods == 0) return result;

    final bool backwards = periods < 0;
    int remaining = periods.abs();
    while (remaining > 0) {
      final FiscalPeriod current = result.primary;
      final DateTime pivot = backwards
          ? current.start.subtract(const Duration(minutes: 1))
          : current.end;
      result = resolve(now: pivot, mode: mode, anchorDay: anchorDay);
      remaining--;
    }
    return result;
  }

  // ─────────────────────────────────────────────────────────────
  //  الحساب الشهري
  // ─────────────────────────────────────────────────────────────

  static FiscalPeriod _monthlyPeriod(DateTime now, int anchorDay) {
    DateTime start;

    if (now.day >= anchorDay) {
      // نحن بعد يوم المرساة → الفترة بدأت هذا الشهر
      start = DateTime(now.year, now.month, anchorDay);
    } else {
      // قبل يوم المرساة → الفترة بدأت الشهر الماضي
      start = DateTime(now.year, now.month - 1, anchorDay);
    }

    // النهاية = نفس اليوم من الشهر التالي ( DateTime يتعامل مع التجاوز تلقائياً )
    final DateTime end = DateTime(start.year, start.month + 1, anchorDay);

    return FiscalPeriod(
      start: start,
      end: end,
      mode: BudgetMode.monthly,
      anchorDay: anchorDay,
      lengthDays: end.difference(start).inDays,
      index: start.year * 12 + (start.month - 1),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  الحساب الأسبوعي (السبت → الجمعة)
  // ─────────────────────────────────────────────────────────────

  static FiscalPeriod _weeklyPeriod(DateTime now) {
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime weekStart = _startOfWeekSaturday(today);
    final DateTime weekEnd = weekStart.add(const Duration(days: 7));

    return FiscalPeriod(
      start: weekStart,
      end: weekEnd,
      mode: BudgetMode.weekly,
      anchorDay: AppConstants.weekStartsOnWeekday,
      lengthDays: 7,
      index: weekStart.difference(_weekEpoch).inDays ~/ 7,
    );
  }

  /// أول سبت في أو قبل [date]
  ///
  /// Dart: Monday=1 … Saturday=6, Sunday=7
  static DateTime _startOfWeekSaturday(DateTime date) {
    final int weekday = date.weekday; // 1=الاثنين … 6=السبت … 7=الأحد
    // المسافة للرجوع إلى آخر سبت
    //   السبت (6) → 0 · الأحد (7) → 1 · الاثنين (1) → 2 · … · الجمعة (5) → 6
    final int daysBack = weekday == 6 ? 0 : (weekday == 7 ? 1 : weekday + 1);
    return DateTime(date.year, date.month, date.day - daysBack);
  }

  static DateTime _firstSaturdayOf(DateTime monthStart) {
    DateTime candidate = DateTime(monthStart.year, monthStart.month, 1);
    while (candidate.weekday != 6) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }

  // ─────────────────────────────────────────────────────────────
  //  أدوات
  // ─────────────────────────────────────────────────────────────

  /// يقيّد يوم المرساة في النطاق المسموح (1..28)
  static int _clampAnchor(int day) => day.clamp(
        AppConstants.minFiscalAnchorDay,
        AppConstants.maxFiscalAnchorDay,
      );

  /// كل الفترات الشهرية داخل نطاق زمني (لتقارير سنوية)
  static List<FiscalPeriod> monthlyPeriodsBetween({
    required DateTime from,
    required DateTime to,
    int anchorDay = 1,
  }) {
    final int safeAnchor = _clampAnchor(anchorDay);
    final List<FiscalPeriod> result = <FiscalPeriod>[];
    FiscalPeriod current = _monthlyPeriod(from, safeAnchor);

    // حماية من حلقة لا نهائية إن كان النطاق مقلوباً
    int guard = 0;
    while (current.start.isBefore(to) && guard < 600) {
      result.add(current);
      current = _monthlyPeriod(current.end, safeAnchor);
      guard++;
    }
    return result;
  }

  /// كل الفترات الأسبوعية داخل نطاق زمني
  static List<FiscalPeriod> weeklyPeriodsBetween({
    required DateTime from,
    required DateTime to,
  }) {
    final List<FiscalPeriod> result = <FiscalPeriod>[];
    FiscalPeriod current = _weeklyPeriod(from);

    int guard = 0;
    while (current.start.isBefore(to) && guard < 3000) {
      result.add(current);
      current = _weeklyPeriod(current.end);
      guard++;
    }
    return result;
  }
}
