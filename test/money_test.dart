import 'package:falousna/core/errors/app_error.dart';
import 'package:falousna/core/utils/money.dart';
import 'package:falousna/core/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';

/// ═══════════════════════════════════════════════════════════════
///  اختبارات Money — المال يُحسب بأعداد صحيحة (سنتيمات) دائماً
///
///  🔴 أي فشل هنا = أرقام خاطئة أمام المستخدم، لذلك الاختبارات
///     تغطي: الإنشاء · العمليات · العملات المختلفة · الطفح ·
///     التحليل من النص الجزائري · التحويل بسعر صرف.
/// ═══════════════════════════════════════════════════════════════
void main() {
  group('Money — الإنشاء', () {
    test('fromCentimes يحفظ السنتيمات كما هي', () {
      const Money amount = Money.fromCentimes(125050);
      expect(amount.centimes, 125050);
      expect(amount.whole, 1250);
      expect(amount.fraction, 50);
      expect(amount.currency, 'DZD');
    });

    test('fromWhole يحوّل الدينار إلى سنتيمات', () {
      const Money amount = Money.fromWhole(1500);
      expect(amount.centimes, 150000);
      expect(amount.whole, 1500);
      expect(amount.fraction, 0);
    });

    test('zero وعلامات القيمة', () {
      const Money zero = Money.zero();
      expect(zero.isZero, isTrue);
      expect(zero.isPositive, isFalse);
      expect(zero.isNegative, isFalse);
      expect(zero.isBaseCurrency, isTrue);

      const Money positive = Money.fromCentimes(1);
      expect(positive.isPositive, isTrue);

      const Money negative = Money.fromCentimes(-1);
      expect(negative.isNegative, isTrue);
      // ⭐ القيمة المطلقة للسالب تحتفظ بالجزء العشري موجباً
      expect(negative.abs().fraction, 1);
    });

    test('عملة أجنبية ليست العملة الأساسية', () {
      const Money euro = Money.fromWhole(100, currency: 'EUR');
      expect(euro.isBaseCurrency, isFalse);
      expect(euro.currency, 'EUR');
    });
  });

  group('Money — العمليات الحسابية', () {
    test('لا خطأ طفح عائماً: 0.1 + 0.2 = 0.30 بالضبط', () {
      const Money a = Money.fromCentimes(10);
      const Money b = Money.fromCentimes(20);
      final Result<Money, AppError> sum = a.add(b);
      expect(sum.isSuccess, isTrue);
      expect(sum.requireValue.centimes, 30);
      expect(sum.requireValue.toDoubleForDisplayOnly, 0.30);
    });

    test('الجمع والطرح يعيدان Result', () {
      const Money income = Money.fromWhole(50000);
      const Money expense = Money.fromWhole(12500);

      final Money total = income.subtract(expense).requireValue;
      expect(total.whole, 37500);

      final Money back = total.add(expense).requireValue;
      expect(back, income);
    });

    test('الطرح ينتج سالباً عند تجاوز الدخل', () {
      const Money small = Money.fromWhole(100);
      const Money big = Money.fromWhole(250);
      final Money result = small.subtract(big).requireValue;
      expect(result.isNegative, isTrue);
      expect(result.whole, -150);
      expect(result.negate().whole, 150);
    });

    test('🔴 جمع عملتين مختلفتين يفشل — لا تحويل صامت', () {
      const Money dzd = Money.fromWhole(1000);
      const Money eur = Money.fromWhole(10, currency: 'EUR');

      final Result<Money, AppError> result = dzd.add(eur);
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull?.kind, AppErrorKind.validation);
    });

    test('الضرب في عدد صحيح وفي نسبة', () {
      const Money price = Money.fromCentimes(12500); // 125,00 دج
      expect(price.multiplyInt(3).requireValue.centimes, 37500);

      // 18% زيادة: 12500 × 1.18 = 14750
      expect(price.multiplyRatio(1.18).centimes, 14750);
    });

    test('القسمة على صفر تعيد صفراً بدل استثناء', () {
      const Money amount = Money.fromWhole(1000);
      expect(amount.divideInt(0).centimes, 0);
      expect(amount.divideInt(4).whole, 250);
    });

    test('sumAll تجمع قائمة وتفشل عند اختلاف العملة', () {
      final Result<Money, AppError> sum = Money.sumAll(<Money>[
        Money.fromWhole(100),
        Money.fromWhole(250),
        Money.fromCentimes(5050),
      ]);
      expect(sum.requireValue.centimes, 40050);

      final Result<Money, AppError> mixed = Money.sumAll(<Money>[
        Money.fromWhole(100),
        Money.fromWhole(10, currency: 'USD'),
      ]);
      expect(mixed.isFailure, isTrue);
    });

    test('القائمة الفارغة مجموعها صفر', () {
      final Result<Money, AppError> sum = Money.sumAll(<Money>[]);
      expect(sum.requireValue.isZero, isTrue);
    });

    test('🔴 الطفح يفشل بأناقة بدل رقم خاطئ', () {
      const Money huge = Money.fromCentimes(99999999999);
      final Result<Money, AppError> overflow = huge.add(huge);
      expect(overflow.isFailure, isTrue);
      expect(overflow.errorOrNull?.messageKey, 'validateAmountTooLarge');

      expect(huge.multiplyInt(1000).isFailure, isTrue);
    });
  });

  group('Money — التحليل من نص المستخدم', () {
    test('عدد صحيح بسيط', () {
      expect(Money.tryParse('1500').requireValue.centimes, 150000);
    });

    test('⭐ القاعدة الجزائرية: 1.250,50 = ألف ومئتان وخمسون ونصف', () {
      expect(Money.tryParse('1.250,50').requireValue.centimes, 125050);
    });

    test('الفاصلة الفرنسية والنقطة الإنجليزية كلتاهما مقبولتان', () {
      expect(Money.tryParse('0,50').requireValue.centimes, 50);
      expect(Money.tryParse('0.50').requireValue.centimes, 50);
      expect(Money.tryParse('0,5').requireValue.centimes, 50);
    });

    test('رمز العملة والمسافات تُتجاهل', () {
      expect(Money.tryParse('1500 دج').requireValue.centimes, 150000);
      expect(Money.tryParse('1 500').requireValue.centimes, 150000);
      expect(Money.tryParse('1500\u00A0DA').requireValue.centimes, 150000);
    });

    test('الإشارة السالبة في البداية أو النهاية', () {
      expect(Money.tryParse('-500').requireValue.centimes, -50000);
      expect(Money.tryParse('500-').requireValue.centimes, -50000);
    });

    test('أكثر من خانتين عشريتين → رفض', () {
      final Result<Money, AppError> result = Money.tryParse('1,234');
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull?.messageKey, 'validateAmountDecimals');
    });

    test('نص فارغ → رفض بمفتاح مطلوب', () {
      final Result<Money, AppError> result = Money.tryParse('   ');
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull?.messageKey, 'validateAmountRequired');
    });

    test('🔴 نص بلا أرقام ليس صفراً صامتاً بل رفض', () {
      final Result<Money, AppError> garbage = Money.tryParse('abc');
      expect(garbage.isFailure, isTrue);
      expect(garbage.errorOrNull?.messageKey, 'validateAmountRequired');

      expect(Money.tryParse('دج').isFailure, isTrue);
    });

    test('مبلغ أكبر من الحد الأقصى → رفض', () {
      expect(
        Money.tryParse('1000000000').errorOrNull?.messageKey,
        'validateAmountTooLarge',
      );
    });

    test('العملة تمرر إلى النتيجة', () {
      final Money euro = Money.tryParse('10', currency: 'EUR').requireValue;
      expect(euro.currency, 'EUR');
    });
  });

  group('Money — التحويل بسعر صرف (لقطة)', () {
    test('100 أورو بسعر 235 دج = 23.500 دج', () {
      const Money euro = Money.fromWhole(100, currency: 'EUR');
      final Result<Money, AppError> converted =
          euro.convertToBase(rateTenThousandths: 2350000);

      expect(converted.isSuccess, isTrue);
      expect(converted.requireValue.whole, 23500);
      expect(converted.requireValue.currency, 'DZD');
    });

    test('سعر صفر أو سالب → رفض', () {
      const Money euro = Money.fromWhole(10, currency: 'EUR');
      expect(euro.convertToBase(rateTenThousandths: 0).isFailure, isTrue);
      expect(euro.convertToBase(rateTenThousandths: -5).isFailure, isTrue);
    });

    test('نفس العملة تعيد نفس المبلغ بلا تغيير', () {
      const Money dzd = Money.fromWhole(500);
      final Money same = dzd.convertToBase(rateTenThousandths: 1).requireValue;
      expect(same, dzd);
    });
  });

  group('Money — المقارنة والمساواة', () {
    test('المقارنة بالسنتيمات', () {
      const Money a = Money.fromWhole(100);
      const Money b = Money.fromWhole(200);
      expect(a.isLessThan(b), isTrue);
      expect(b.isGreaterThan(a), isTrue);
      expect(a.isLessOrEqual(Money.fromWhole(100)), isTrue);
      expect(a.compareTo(b), lessThan(0));
    });

    test('🔴 مبلغان متساويان رقمياً بعملة مختلفة ليسا متساويين', () {
      const Money dzd = Money.fromWhole(100);
      const Money eur = Money.fromWhole(100, currency: 'EUR');
      expect(dzd == eur, isFalse);
      expect(dzd.hashCode == eur.hashCode, isFalse);
    });

    test('نفس القيمة والعملة → متساويان', () {
      expect(Money.fromCentimes(500), Money.fromCentimes(500));
    });
  });
}
