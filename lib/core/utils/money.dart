/// ═══════════════════════════════════════════════════════════════
///  Money — تمثيل آمن للمبالغ المالية
///
///  🔴 قاعدة إلزامية: لا تستخدم double للمبالغ المالية إطلاقاً.
///     double يعطي: 0.1 + 0.2 = 0.30000000000000004
///     في تطبيق مالي هذا خطأ بمقدار قابل للتضخّم عبر ملايين العمليات.
///
///  ✅ الحل: تمثيل المبلغ بعدد صحيح من السنتيمات (centimes).
///     1.250,50 دج  ←→  125050 سنتيم
///     كل العمليات الحسابية بأعداد صحيحة = دقة مطلقة بلا أخطاء.
///
///  ✅ في PostgreSQL يُخزَّن كـ NUMERIC(14,2) — لا FLOAT ولا DOUBLE.
/// ═══════════════════════════════════════════════════════════════
library;

import '../config/constants.dart';
import '../errors/app_error.dart';
import 'result.dart';

/// مبلغ مالي دقيق مبني على السنتيمات (أعداد صحيحة)
class Money implements Comparable<Money> {
  /// ينشئ مبلغاً من عدد صحيح من السنتيمات.
  ///
  /// مثال: `Money.fromCentimes(125050)` = 1.250,50
  const Money.fromCentimes(this.centimes, {this.currency = AppConstants.baseCurrency});

  /// ينشئ مبلغاً من عدد صحيح من الوحدات (دج كاملة، بلا سنتيمات).
  ///
  /// مثال: `Money.fromWhole(1250)` = 1.250,00
  const Money.fromWhole(int whole, {this.currency = AppConstants.baseCurrency})
      : centimes = whole * 100;

  /// ينشئ مبلغاً صفرياً.
  const Money.zero({this.currency = AppConstants.baseCurrency}) : centimes = 0;

  /// ⚠️ عدد السنتيمات — قيمة صحيحة، لا كسور ولا أخطاء تقريب.
  final int centimes;

  /// رمز العملة (ISO 4217)
  final String currency;

  /// الحد الأقصى المسموح: 999.999.999,99 دج — يتسع في NUMERIC(14,2)
  static const int _maxCentimes = 99999999999;

  /// هل المبلغ سالب؟
  bool get isNegative => centimes < 0;

  /// هل المبلغ موجب تماماً؟
  bool get isPositive => centimes > 0;

  /// هل المبلغ صفر؟
  bool get isZero => centimes == 0;

  /// الجزء الصحيح (الدنانير الكاملة)
  int get whole => centimes ~/ 100;

  /// الجزء العشري (السنتيمات، 0..99) — دائماً موجب للعرض
  int get fraction => (centimes % 100).abs();

  /// قيمة عشرية للعرض فقط — ⚠️ لا تستعملها في الحسابات
  double get toDoubleForDisplayOnly => centimes / 100;

  /// هل العملة هي العملة الأساسية (دج)؟
  bool get isBaseCurrency => currency == AppConstants.baseCurrency;

  // ─────────────────────────────────────────────────────────────
  //  العمليات الحسابية (تفشل بأناقة عند اختلاف العملة)
  // ─────────────────────────────────────────────────────────────

  /// الجمع — يفشل إن اختلفت العملة (لا تحويل صامت)
  Result<Money, AppError> add(Money other) {
    if (currency != other.currency) {
      return Result<Money, AppError>.failure(
        AppError.currencyMismatch(a: currency, b: other.currency),
      );
    }
    final int sum = centimes + other.centimes;
    if (!_withinBounds(sum)) {
      return Result<Money, AppError>.failure(AppError.amountOverflow());
    }
    return Result<Money, AppError>.success(
      Money.fromCentimes(sum, currency: currency),
    );
  }

  /// الطرح — يفشل إن اختلفت العملة
  Result<Money, AppError> subtract(Money other) {
    if (currency != other.currency) {
      return Result<Money, AppError>.failure(
        AppError.currencyMismatch(a: currency, b: other.currency),
      );
    }
    final int diff = centimes - other.centimes;
    if (!_withinBounds(diff)) {
      return Result<Money, AppError>.failure(AppError.amountOverflow());
    }
    return Result<Money, AppError>.success(
      Money.fromCentimes(diff, currency: currency),
    );
  }

  /// الضرب في عدد صحيح (مثلاً: كمية × سعر)
  Result<Money, AppError> multiplyInt(int factor) {
    final int product = centimes * factor;
    if (!_withinBounds(product)) {
      return Result<Money, AppError>.failure(AppError.amountOverflow());
    }
    return Result<Money, AppError>.success(
      Money.fromCentimes(product, currency: currency),
    );
  }

  /// الضرب في نسبة (مثلاً: 18% زيادة) — يُقرّب لأقرب سنتيم
  ///
  /// يستعمل `round` مصرفياً (نصف للأعلى) لأن التقريب التراجعي
  /// يسبب انحيازاً تراكمياً في التقارير.
  Money multiplyRatio(double ratio) {
    final int result = (centimes * ratio).round();
    return Money.fromCentimes(
      _withinBounds(result) ? result : (result.isNegative ? -_maxCentimes : _maxCentimes),
      currency: currency,
    );
  }

  /// القسمة على عدد صحيح (مثلاً: توزيع على أفراد) — يُقرّب لأقرب سنتيم
  Money divideInt(int divisor) {
    if (divisor == 0) return Money.zero(currency: currency);
    return Money.fromCentimes((centimes / divisor).round(), currency: currency);
  }

  /// القيمة المطلقة
  Money abs() => Money.fromCentimes(centimes.abs(), currency: currency);

  /// المعكوس (موجب ← سالب)
  Money negate() => Money.fromCentimes(-centimes, currency: currency);

  /// مجموع قائمة مبالغ — يتجاهل العملات المختلفة بأمان
  static Result<Money, AppError> sumAll(
    Iterable<Money> items, {
    String currency = AppConstants.baseCurrency,
  }) {
    int total = 0;
    for (final Money item in items) {
      if (item.currency != currency) {
        return Result<Money, AppError>.failure(
          AppError.currencyMismatch(a: currency, b: item.currency),
        );
      }
      total += item.centimes;
      if (!_withinBounds(total)) {
        return Result<Money, AppError>.failure(AppError.amountOverflow());
      }
    }
    return Result<Money, AppError>.success(
      Money.fromCentimes(total, currency: currency),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  التحليل من نص (لحقول الإدخال)
  // ─────────────────────────────────────────────────────────────

  /// يحوّل نصاً من المستخدم إلى Money.
  ///
  /// يقبل:
  /// - الفاصلة العشرية `,` (المعيار الجزائري والفرنسي)
  /// - النقطة العشرية `.` (التسامح مع من يكتب بالنمط الإنجليزي)
  /// - فواصل الآلاف `.` و `,` و المسافة و `٬`
  /// - المسافات العادية وغير القابلة للكسر
  ///
  /// ⚠️ عند وجود فاصلين مختلفين، يُعتبر الأخير هو العشري
  /// (القاعدة الجزائرية: 1.250,50 = ألف ومئتان وخمسون ونصف)
  static Result<Money, AppError> tryParse(
    String input, {
    String currency = AppConstants.baseCurrency,
  }) {
    String text = input.trim();
    if (text.isEmpty) {
      return Result<Money, AppError>.failure(AppError.validation('validateAmountRequired'));
    }

    // إزالة رموز العملة والمسافات غير القابلة للكسر
    text = text
        .replaceAll('\u00A0', '')
        .replaceAll('\u202F', '')
        .replaceAll('\u2009', '')
        .replaceAll(' ', '')
        .replaceAll('دج', '')
        .replaceAll('DA', '')
        .replaceAll('DZD', '')
        .replaceAll('€', '')
        .replaceAll(r'$', '')
        .trim();

    if (text.isEmpty) {
      return Result<Money, AppError>.failure(AppError.validation('validateAmountRequired'));
    }

    // إشارة سالبة في البداية أو النهاية
    final bool negative = text.startsWith('-') || text.endsWith('-');
    text = text.replaceAll('-', '').replaceAll('+', '').trim();

    if (text.isEmpty) {
      return Result<Money, AppError>.failure(AppError.validation('validateAmountRequired'));
    }

    // 🔴 نص بلا أي رقم ليس مبلغاً — لا نعيده صفراً بصمت
    //    («abc» أو «دج» وحدها ← فشل، لا Money.zero)
    if (!RegExp('[0-9]').hasMatch(text)) {
      return Result<Money, AppError>.failure(AppError.validation('validateAmountRequired'));
    }

    // تحديد الفاصل العشري: آخر ظهور لـ , أو .
    final int lastComma = text.lastIndexOf(',');
    final int lastDot = text.lastIndexOf('.');
    final int decimalIndex = lastComma > lastDot ? lastComma : lastDot;

    String wholePart;
    String fractionPart;

    if (decimalIndex == -1) {
      // لا فاصل — عدد صحيح
      wholePart = text;
      fractionPart = '';
    } else {
      wholePart = text.substring(0, decimalIndex);
      fractionPart = text.substring(decimalIndex + 1);
      // إزالة فواصل الآلاف من الجزء الصحيح
      wholePart = wholePart.replaceAll(',', '').replaceAll('.', '').replaceAll('٬', '');
    }

    // تنظيف الجزء العشري: أرقام فقط، وخانتان كحد أقصى
    fractionPart = fractionPart.replaceAll(RegExp('[^0-9]'), '');
    if (fractionPart.length > 2) {
      return Result<Money, AppError>.failure(AppError.validation('validateAmountDecimals'));
    }
    // تطبيع إلى خانتين: "5" → "50" · "" → "00"
    fractionPart = fractionPart.padRight(2, '0');

    // تنظيف الجزء الصحيح
    wholePart = wholePart.replaceAll(RegExp('[^0-9]'), '');
    if (wholePart.isEmpty) wholePart = '0';
    // إزالة الأصفار البادئة
    wholePart = wholePart.replaceFirst(RegExp(r'^0+(?=\d)'), '');

    // فحص الحد الأقصى
    if (wholePart.length > 9) {
      return Result<Money, AppError>.failure(AppError.validation('validateAmountTooLarge'));
    }

    final int? wholeValue = int.tryParse(wholePart);
    final int? fractionValue = int.tryParse(fractionPart);
    if (wholeValue == null || fractionValue == null) {
      return Result<Money, AppError>.failure(AppError.validation('validateAmountRequired'));
    }

    if (wholeValue > AppConstants.maxAmountWhole) {
      return Result<Money, AppError>.failure(AppError.validation('validateAmountTooLarge'));
    }

    int result = wholeValue * 100 + fractionValue;
    if (negative) result = -result;

    if (!_withinBounds(result)) {
      return Result<Money, AppError>.failure(AppError.amountOverflow());
    }

    return Result<Money, AppError>.success(
      Money.fromCentimes(result, currency: currency),
    );
  }

  /// تحويل إلى عملة أخرى بسعر صرف معطى (لقطة).
  ///
  /// ⚠️ السعر يُمرَّر كعدد صحيح من عشر آلاف (basis points × 100)
  /// لتفادي double: `235.0000` ←→ `2350000`
  ///
  /// مثال: 100 EUR بسعر 235.0000 دج/أورو
  ///   `Money.fromWhole(100, currency:'EUR').convertToBase(rateTenThousandths: 2350000)`
  ///   = 23.500,00 دج
  Result<Money, AppError> convertToBase({
    required int rateTenThousandths,
    String targetCurrency = AppConstants.baseCurrency,
  }) {
    if (rateTenThousandths <= 0) {
      return Result<Money, AppError>.failure(AppError.validation('validateAmountZero'));
    }
    if (currency == targetCurrency) {
      return Result<Money, AppError>.success(this);
    }
    // (centimes × rate) / 10000 — بترتيب يمنع الطفح حيث أمكن
    final int converted = (centimes * rateTenThousandths) ~/ 10000;
    if (!_withinBounds(converted)) {
      return Result<Money, AppError>.failure(AppError.amountOverflow());
    }
    return Result<Money, AppError>.success(
      Money.fromCentimes(converted, currency: targetCurrency),
    );
  }

  static bool _withinBounds(int value) =>
      value >= -_maxCentimes && value <= _maxCentimes;

  // ─────────────────────────────────────────────────────────────
  //  المقارنة
  // ─────────────────────────────────────────────────────────────

  @override
  int compareTo(Money other) => centimes.compareTo(other.centimes);

  bool isGreaterThan(Money other) => centimes > other.centimes;
  bool isLessThan(Money other) => centimes < other.centimes;
  bool isGreaterOrEqual(Money other) => centimes >= other.centimes;
  bool isLessOrEqual(Money other) => centimes <= other.centimes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Money && other.centimes == centimes && other.currency == currency);

  @override
  int get hashCode => Object.hash(centimes, currency);

  /// تمثيل نصي خام للتخزين/التصدير — لا للعرض
  /// مثال: `125050 DZD`
  @override
  String toString() => '$centimes $currency';

  /// قيمة عشرية كسلسلة بأمانة كاملة — للتصدير CSV والـ API
  /// مثال: `1250.50`
  String toDecimalString() {
    final bool neg = centimes < 0;
    final int abs = centimes.abs();
    final String w = (abs ~/ 100).toString();
    final String f = (abs % 100).toString().padLeft(2, '0');
    return '${neg ? '-' : ''}$w.$f';
  }
}
