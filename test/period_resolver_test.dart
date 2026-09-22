import 'package:falousna/core/utils/period_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

/// ═══════════════════════════════════════════════════════════════
///  اختبارات PeriodResolver — المصدر الوحيد لحساب الفترات
///
///  🔴 لماذا هذه الاختبارات حرجة؟
///     كل ميزانية وتنبيه وتقرير يعتمد على حدود الفترة. يوم واحد
///     خطأ = «تجاوزت ميزانيتك» كاذب أو مصاريف مخفية بين فترتين.
///
///  الحالات المغطاة:
///     - شهر مالي بيوم مرساة 1 و 25 و 28 (راتب ينزل آخر الشهر)
///     - أسبوع جزائري: السبت → الجمعة (النهاية حصرية)
///     - تقييد المرساة خارج النطاق (0 و 45)
///     - previous / next / offset (المقارنة بين الفترات ▲▼)
///     - الفترات داخل نطاق (تقارير سنوية)
/// ═══════════════════════════════════════════════════════════════
void main() {
  group('الفترة الشهرية — مرساة يوم 1', () {
    final PeriodResolution result = PeriodResolver.resolve(
      now: DateTime(2026, 3, 15, 10, 30),
      mode: BudgetMode.monthly,
      anchorDay: 1,
    );
    final FiscalPeriod period = result.primary;

    test('البداية أول الشهر والنهاية أول الشهر التالي (حصرية)', () {
      expect(period.start, DateTime(2026, 3, 1));
      expect(period.end, DateTime(2026, 4, 1));
    });

    test('طول الفترة = عدد أيام الشهر', () {
      expect(period.lengthDays, 31);
      expect(period.duration.inDays, 31);
    });

    test('الوضع والفهرس', () {
      expect(period.mode, BudgetMode.monthly);
      expect(period.anchorDay, 1);
      expect(period.index, 2026 * 12 + 2);
    });

    test('لا فترة مجمّعة في الوضع الشهري', () {
      expect(result.aggregate, isNull);
      expect(result.all.length, 1);
    });
  });

  group('الفترة الشهرية — مرساة يوم 25 (راتب آخر الشهر)', () {
    test('قبل يوم 25 → الفترة بدأت في الشهر الماضي', () {
      final FiscalPeriod period = PeriodResolver.resolve(
        now: DateTime(2026, 3, 10),
        mode: BudgetMode.monthly,
        anchorDay: 25,
      ).primary;

      expect(period.start, DateTime(2026, 2, 25));
      expect(period.end, DateTime(2026, 3, 25));
      // فبراير 2026 = 28 يوماً (ليست سنة كبيسة)
      expect(period.lengthDays, 28);
    });

    test('في يوم 25 نفسه → فترة جديدة تبدأ الآن', () {
      final FiscalPeriod period = PeriodResolver.resolve(
        now: DateTime(2026, 3, 25),
        mode: BudgetMode.monthly,
        anchorDay: 25,
      ).primary;

      expect(period.start, DateTime(2026, 3, 25));
      expect(period.end, DateTime(2026, 4, 25));
    });

    test('بعد يوم 25 → نفس الفترة', () {
      final FiscalPeriod period = PeriodResolver.resolve(
        now: DateTime(2026, 3, 26, 23, 59),
        mode: BudgetMode.monthly,
        anchorDay: 25,
      ).primary;

      expect(period.start, DateTime(2026, 3, 25));
      expect(period.lengthDays, 31);
    });
  });

  group('تقييد يوم المرساة (حماية من إعدادات تالفة)', () {
    test('0 يُرفع إلى 1', () {
      final FiscalPeriod period = PeriodResolver.resolve(
        now: DateTime(2026, 3, 15),
        mode: BudgetMode.monthly,
        anchorDay: 0,
      ).primary;
      expect(period.anchorDay, 1);
      expect(period.start, DateTime(2026, 3, 1));
    });

    test('45 يُخفض إلى 28 (لا 29/30/31 — غير موجودة في كل الشهور)', () {
      final FiscalPeriod period = PeriodResolver.resolve(
        now: DateTime(2026, 3, 15),
        mode: BudgetMode.monthly,
        anchorDay: 45,
      ).primary;
      expect(period.anchorDay, 28);
      expect(period.start, DateTime(2026, 2, 28));
      expect(period.end, DateTime(2026, 3, 28));
    });

    test('سالب يُرفع إلى 1', () {
      expect(
        PeriodResolver.resolve(
          now: DateTime(2026, 3, 15),
          mode: BudgetMode.monthly,
          anchorDay: -9,
        ).primary.anchorDay,
        1,
      );
    });
  });

  group('⭐ الفترة الأسبوعية — السبت إلى الجمعة', () {
    test('يوم السبت → بداية الأسبوع نفسه', () {
      final FiscalPeriod period = PeriodResolver.resolve(
        now: DateTime(2026, 9, 19, 8),
        mode: BudgetMode.weekly,
      ).primary;

      expect(period.start, DateTime(2026, 9, 19));
      expect(period.end, DateTime(2026, 9, 26));
      expect(period.lengthDays, 7);
      expect(period.start.weekday, DateTime.saturday);
    });

    test('يوم الأحد → يرجع يوماً واحداً', () {
      expect(
        PeriodResolver.resolve(
          now: DateTime(2026, 9, 20),
          mode: BudgetMode.weekly,
        ).primary.start,
        DateTime(2026, 9, 19),
      );
    });

    test('يوم الاثنين → يرجع يومين', () {
      expect(
        PeriodResolver.resolve(
          now: DateTime(2026, 9, 21),
          mode: BudgetMode.weekly,
        ).primary.start,
        DateTime(2026, 9, 19),
      );
    });

    test('يوم الجمعة → آخر يوم في الأسبوع (يرجع 6 أيام)', () {
      final FiscalPeriod period = PeriodResolver.resolve(
        now: DateTime(2026, 9, 25, 22),
        mode: BudgetMode.weekly,
      ).primary;

      expect(period.start, DateTime(2026, 9, 19));
      expect(period.end, DateTime(2026, 9, 26));
    });

    test('الوقت داخل اليوم لا يغيّر الحدود (تطبيع إلى منتصف الليل)', () {
      final FiscalPeriod morning = PeriodResolver.resolve(
        now: DateTime(2026, 9, 21, 0, 1),
        mode: BudgetMode.weekly,
      ).primary;
      final FiscalPeriod night = PeriodResolver.resolve(
        now: DateTime(2026, 9, 21, 23, 59),
        mode: BudgetMode.weekly,
      ).primary;

      expect(morning.start, night.start);
      expect(morning.end, night.end);
    });
  });

  group('الوضع المزدوج (أسبوعية + شهرية)', () {
    final PeriodResolution result = PeriodResolver.resolve(
      now: DateTime(2026, 9, 21),
      mode: BudgetMode.both,
      anchorDay: 1,
    );

    test('الأساسي أسبوعي والمجمَّع شهري', () {
      expect(result.primary.mode, BudgetMode.weekly);
      expect(result.aggregate?.mode, BudgetMode.monthly);
      expect(result.all.length, 2);
    });

    test('الفترة الشهرية صحيحة رغم الوضع المزدوج', () {
      expect(result.aggregate?.start, DateTime(2026, 9, 1));
      expect(result.aggregate?.end, DateTime(2026, 10, 1));
    });
  });

  group('الفترات المجاورة (للمقارنة ▲▼)', () {
    test('السابقة والتالية شهرياً', () {
      final DateTime now = DateTime(2026, 3, 15);

      final FiscalPeriod previous = PeriodResolver.previous(
        now: now,
        mode: BudgetMode.monthly,
      ).primary;
      final FiscalPeriod current = PeriodResolver.resolve(
        now: now,
        mode: BudgetMode.monthly,
      ).primary;
      final FiscalPeriod next = PeriodResolver.next(
        now: now,
        mode: BudgetMode.monthly,
      ).primary;

      expect(previous.start, DateTime(2026, 2, 1));
      expect(previous.end, current.start);
      expect(next.start, current.end);
      expect(next.end, DateTime(2026, 5, 1));
    });

    test('لا فجوة ولا تداخل بين الفترات المتتالية', () {
      final FiscalPeriod current = PeriodResolver.resolve(
        now: DateTime(2026, 9, 21),
        mode: BudgetMode.weekly,
      ).primary;
      final FiscalPeriod next = PeriodResolver.next(
        now: DateTime(2026, 9, 21),
        mode: BudgetMode.weekly,
      ).primary;

      expect(current.end, next.start);
      expect(next.end.difference(next.start).inDays, 7);
    });

    test('offset(-2) يرجع فترتين للوراء', () {
      final FiscalPeriod twoBack = PeriodResolver.offset(
        now: DateTime(2026, 3, 15),
        periods: -2,
        mode: BudgetMode.monthly,
      ).primary;

      expect(twoBack.start, DateTime(2026, 1, 1));
      expect(twoBack.end, DateTime(2026, 2, 1));
    });

    test('offset(0) = الفترة الحالية', () {
      final DateTime now = DateTime(2026, 3, 15);
      expect(
        PeriodResolver.offset(now: now, periods: 0).primary.start,
        PeriodResolver.resolve(now: now).primary.start,
      );
    });

    test('الفهرس يتزايد مع الزمن', () {
      final int previousIndex = PeriodResolver.previous(
        now: DateTime(2026, 3, 15),
      ).primary.index;
      final int currentIndex = PeriodResolver.resolve(
        now: DateTime(2026, 3, 15),
      ).primary.index;
      final int nextIndex = PeriodResolver.next(
        now: DateTime(2026, 3, 15),
      ).primary.index;

      expect(previousIndex, lessThan(currentIndex));
      expect(currentIndex, lessThan(nextIndex));
    });
  });

  group('الفترات داخل نطاق (تقارير)', () {
    test('ثلاثة أشهر بين يناير وأبريل', () {
      final List<FiscalPeriod> periods = PeriodResolver.monthlyPeriodsBetween(
        from: DateTime(2026, 1, 1),
        to: DateTime(2026, 4, 1),
      );

      expect(periods.length, 3);
      expect(periods.first.start, DateTime(2026, 1, 1));
      expect(periods.last.end, DateTime(2026, 4, 1));
      // فبراير 2026 = 28 يوماً
      expect(periods[1].lengthDays, 28);
    });

    test('أسبوعان متتاليان', () {
      final List<FiscalPeriod> periods = PeriodResolver.weeklyPeriodsBetween(
        from: DateTime(2026, 9, 19),
        to: DateTime(2026, 10, 3),
      );

      expect(periods.length, 2);
      expect(periods[0].start, DateTime(2026, 9, 19));
      expect(periods[1].start, DateTime(2026, 9, 26));
    });

    test('نطاق مقلوب لا يُنتج حلقة لا نهائية', () {
      final List<FiscalPeriod> periods = PeriodResolver.monthlyPeriodsBetween(
        from: DateTime(2026, 5, 1),
        to: DateTime(2026, 1, 1),
      );
      expect(periods, isEmpty);
    });

    test('مرساة 25 عبر نهاية السنة', () {
      final List<FiscalPeriod> periods = PeriodResolver.monthlyPeriodsBetween(
        from: DateTime(2026, 12, 10),
        to: DateTime(2027, 2, 1),
        anchorDay: 25,
      );

      expect(periods, isNotEmpty);
      expect(periods.first.start, DateTime(2026, 11, 25));
      for (final FiscalPeriod period in periods) {
        expect(period.start.day, 25);
        expect(period.end.day, 25);
      }
    });
  });

  group('أدوات FiscalPeriod', () {
    test('midpoint داخل الفترة', () {
      final FiscalPeriod period = PeriodResolver.resolve(
        now: DateTime(2026, 3, 15),
        mode: BudgetMode.monthly,
      ).primary;

      expect(period.midpoint.isAfter(period.start), isTrue);
      expect(period.midpoint.isBefore(period.end), isTrue);
    });

    test('من بداية الشهر المالي لا يرجع قبلها', () {
      final FiscalPeriod period = PeriodResolver.resolve(
        now: DateTime(2026, 9, 19),
        mode: BudgetMode.weekly,
      ).primary;

      expect(period.start.isAfter(DateTime(2026, 9, 12)), isTrue);
    });
  });
}
