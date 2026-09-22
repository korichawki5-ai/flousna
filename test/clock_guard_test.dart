import 'package:falousna/core/config/constants.dart';
import 'package:falousna/core/utils/clock_guard.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ═══════════════════════════════════════════════════════════════
///  اختبارات ClockGuard — حماية التجربة المجانية من تلاعب الساعة
///
///  🔴 السيناريو الذي نمنعه: مستخدم يأخذ تجربة 7 أيام، ثم يعيد
///     ساعة جهازه شهراً إلى الوراء في كل مرة → تجربة أبدية.
///
///  الآلية: نخزّن **أعلى طابع زمني شوهد**. الوقت الحقيقي لا يرجع،
///     فإن رجع بأكثر من تسامح المناطق الزمنية (6 ساعات) → تلاعب.
///
///  ⚠️ صدق في التوثيق: هذه الآلية **تكشف** التلاعب ولا تمنعه
///     فيزيائياً (مستحيل في تطبيق محلي بلا سيرفر). الحل الجذري
///     هو الحساب السحابي في المرحلة 3.
/// ═══════════════════════════════════════════════════════════════
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ClockGuard> guardWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return ClockGuard(prefs);
  }

  group('أول تشغيل', () {
    test('لا سجل سابقاً → نبضة أولى بلا إنذار', () async {
      final ClockGuard guard = await guardWith(<String, Object>{});
      expect(guard.highestSeenMs, 0);
      expect(guard.isTampered, isFalse);

      final bool tamperDetected = await guard.tick();

      expect(tamperDetected, isFalse);
      expect(guard.highestSeenMs, greaterThan(0));
      expect(guard.isTampered, isFalse);
    });

    test('create() يسجّل النبضة الأولى', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final ClockGuard guard = await ClockGuard.create();

      expect(guard.highestSeenMs, greaterThan(0));
      expect(guard.isTampered, isFalse);
    });
  });

  group('🔴 كشف التلاعب بالساعة', () {
    test('إرجاع الساعة شهراً → يُكشف ويُسجَّل', () async {
      final int future =
          DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch;
      final ClockGuard guard = await guardWith(<String, Object>{
        AppConstants.keyHighestSeenTs: future,
      });

      expect(guard.isTampered, isFalse, reason: 'لم يُكشف بعد قبل النبضة');

      final bool detected = await guard.tick();

      expect(detected, isTrue);
      expect(guard.isTampered, isTrue);
    });

    test('السقف لا يُنقَص أبداً بعد كشف التلاعب', () async {
      final int future =
          DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch;
      final ClockGuard guard = await guardWith(<String, Object>{
        AppConstants.keyHighestSeenTs: future,
      });

      await guard.tick();

      expect(guard.highestSeenMs, future);
      // نبضة ثانية لا تغيّر السقف ولا تلغي العلم
      await guard.tick();
      expect(guard.highestSeenMs, future);
      expect(guard.isTampered, isTrue);
    });

    test('trustedNow يرجع السقف لا الساعة المُعادة', () async {
      final DateTime future = DateTime.now().add(const Duration(days: 30));
      final ClockGuard guard = await guardWith(<String, Object>{
        AppConstants.keyHighestSeenTs: future.millisecondsSinceEpoch,
        AppConstants.keyClockTamperFlag: true,
      });

      expect(guard.trustedNow().isAfter(DateTime.now()), isTrue);
      expect(
        guard.trustedNow().difference(future).inMinutes.abs(),
        lessThan(2),
      );
    });

    test('⭐ فرق منطقة زمنية (≤6 ساعات) ليس تلاعباً', () async {
      final int slightlyAhead =
          DateTime.now().add(const Duration(hours: 3)).millisecondsSinceEpoch;
      final ClockGuard guard = await guardWith(<String, Object>{
        AppConstants.keyHighestSeenTs: slightlyAhead,
      });

      final bool detected = await guard.tick();

      expect(detected, isFalse);
      expect(guard.isTampered, isFalse);
    });

    test('تقدّم الوقت طبيعياً يرفع السقف', () async {
      final int past =
          DateTime.now().subtract(const Duration(days: 2)).millisecondsSinceEpoch;
      final ClockGuard guard = await guardWith(<String, Object>{
        AppConstants.keyHighestSeenTs: past,
      });

      final bool detected = await guard.tick();

      expect(detected, isFalse);
      expect(guard.highestSeenMs, greaterThan(past));
    });
  });

  group('حساب المدد (التجربة والاشتراك)', () {
    test('daysSince — مضت 3 أيام', () async {
      final ClockGuard guard = await guardWith(<String, Object>{});
      await guard.tick();

      final DateTime threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      expect(guard.daysSince(threeDaysAgo), 3);
    });

    test('daysSince — موعد في المستقبل يعيد صفراً', () async {
      final ClockGuard guard = await guardWith(<String, Object>{});
      await guard.tick();

      final DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
      expect(guard.daysSince(tomorrow), 0);
    });

    test('daysUntil — التقريب للأعلى (نصف يوم = يوم واحد)', () async {
      final ClockGuard guard = await guardWith(<String, Object>{});
      await guard.tick();

      final DateTime inTwelveHours = DateTime.now().add(const Duration(hours: 12));
      expect(guard.daysUntil(inTwelveHours), 1);

      final DateTime inThreeDays = DateTime.now().add(const Duration(days: 3));
      expect(guard.daysUntil(inThreeDays), 3);
    });

    test('daysUntil — مهلة منتهية تعيد صفراً', () async {
      final ClockGuard guard = await guardWith(<String, Object>{});
      await guard.tick();

      expect(guard.daysUntil(DateTime.now().subtract(const Duration(days: 1))), 0);
    });

    test('hasExpired', () async {
      final ClockGuard guard = await guardWith(<String, Object>{});
      await guard.tick();

      expect(guard.hasExpired(DateTime.now().subtract(const Duration(hours: 1))), isTrue);
      expect(guard.hasExpired(DateTime.now().add(const Duration(hours: 1))), isFalse);
    });

    test('🔴 إرجاع الساعة لا يمدّد التجربة — بل يُنهيها بالوقت الموثوق', () async {
      final DateTime trialStart = DateTime.now().subtract(const Duration(days: 3));
      final DateTime trialEnd = trialStart.add(const Duration(days: 7));

      // مستخدم رأى وقتاً أحدث (سجّلناه)، ثم أعاد الساعة 30 يوماً للوراء
      final int highest =
          DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch;
      final ClockGuard guard = await guardWith(<String, Object>{
        AppConstants.keyHighestSeenTs: highest,
      });
      await guard.tick();

      // ⭐ النتيجة المطلوبة: لا تعود التجربة إلى «بقي 4 أيام» وكأن شيئاً
      //    لم يكن، بل يُحسب الوقت من أعلى طابع شوهد → التجربة منتهية.
      //    هذا يردع التلاعب بدون عقاب جماعي (من لم يتلاعب لا يتأثر).
      expect(guard.isTampered, isTrue);
      expect(guard.daysUntil(trialEnd), 0);
      expect(guard.hasExpired(trialEnd), isTrue);

      // وبالساعة الحقيقية وحدها كانت ستبقى 4 أيام — الفرق هو الحماية
      expect(trialEnd.isAfter(DateTime.now()), isTrue);
    });
  });

  group('أدوات الاختبار', () {
    test('clearTamperFlagForTesting يمسح العلم والسقف', () async {
      final int future =
          DateTime.now().add(const Duration(days: 10)).millisecondsSinceEpoch;
      final ClockGuard guard = await guardWith(<String, Object>{
        AppConstants.keyHighestSeenTs: future,
        AppConstants.keyClockTamperFlag: true,
      });

      await guard.clearTamperFlagForTesting();

      expect(guard.isTampered, isFalse);
      expect(guard.highestSeenMs, 0);
    });
  });
}
