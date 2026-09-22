import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../config/constants.dart';
import 'money.dart';

/// ═══════════════════════════════════════════════════════════════
///  تنسيق الأرقام — لاتينية + ذكية حسب اللغة
///
///  🇩🇿 العربية:  1.250,50 دج   (فاصل آلاف «.» · عشرية «,» · الرمز بعد الرقم)
///  🇫🇷 الفرنسية: 1 250,50 DA  (فاصل آلاف مسافة · عشرية «,» · الرمز بعد الرقم)
///
///  ⚠️ قاعدة إلزامية: لا تنسيق يدوي أبداً — Intl فقط.
///     التنسيق اليدوي مصدر أخطاء مالية (قراءة 1,250.50 كنمط أمريكي
///     في سياق جزائري = خطأ بمقدار 1000 ضعف).
///
///  ⚠️ الأرقام تبقى LTR حتى داخل نص RTL — تُعالَج في
///     core/widgets/money_text.dart عبر Directionality.
/// ═══════════════════════════════════════════════════════════════
abstract final class AppNumberFormat {
  /// هل اللغة الحالية عربية؟
  static bool isArabic(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ar';

  /// رمز اللغة الكامل (ar_DZ أو fr_DZ)
  static String localeTag(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    return '${locale.languageCode}_${locale.countryCode ?? 'DZ'}';
  }

  // ─────────────────────────────────────────────────────────────
  //  رمز العملة
  // ─────────────────────────────────────────────────────────────

  /// رمز العملة حسب لغة الواجهة
  ///
  /// عربية → «دج» · فرنسية → «DA»
  /// في التقارير الرسمية وCSV يُستعمل DZD (انظر [isoCode])
  static String symbolFor(BuildContext context, String currency) {
    final Map<String, String> table = isArabic(context)
        ? AppConstants.currencySymbols
        : AppConstants.currencySymbolsFr;
    return table[currency] ?? currency;
  }

  /// الرمز الدولي (ISO 4217) — للتقارير الرسمية والتصدير
  static String isoCode(String currency) => currency;

  // ─────────────────────────────────────────────────────────────
  //  تنسيق المبالغ
  // ─────────────────────────────────────────────────────────────

  /// ينسّق مبلغاً كاملاً مع رمز العملة.
  ///
  /// [withSymbol] = false يُعيد الرقم فقط (لحقول الإدخال)
  /// [withDecimals] = false يُخفي السنتيمات عندما تكون صفراً (أنظف بصرياً)
  static String formatMoney(
    BuildContext context,
    Money amount, {
    bool withSymbol = true,
    bool withDecimals = true,
    bool showSign = false,
  }) {
    final String tag = localeTag(context);

    final NumberFormat formatter = withDecimals
        ? NumberFormat.decimalPattern(tag)
        : NumberFormat.decimalPatternDigits(locale: tag, decimalDigits: 0);

    // نُمرّر القيمة العشرية للعرض فقط — الحساب تم بأعداد صحيحة في Money
    final double displayValue = amount.toDoubleForDisplayOnly;
    String numberText = formatter.format(displayValue);

    if (!withDecimals) {
      numberText = formatter.format(amount.whole);
    }

    final StringBuffer buffer = StringBuffer();
    if (showSign && amount.isPositive) buffer.write('+');
    buffer.write(numberText);
    if (withSymbol) {
      // ⚠️ مسافة غير قابلة للكسر بين الرقم والرمز — لا ينفصلان عند الالتفاف
      // (cascade عمداً: قاعدة cascade_invocations — نداءان متتاليان على نفس الهدف)
      buffer
        ..write('\u00A0')
        ..write(symbolFor(context, amount.currency));
    }
    return buffer.toString();
  }

  /// ينسّق سنتيمات خام (من قاعدة البيانات) مباشرة
  static String formatCentimes(
    BuildContext context,
    int centimes, {
    String currency = AppConstants.baseCurrency,
    bool withSymbol = true,
    bool withDecimals = true,
  }) =>
      formatMoney(
        context,
        Money.fromCentimes(centimes, currency: currency),
        withSymbol: withSymbol,
        withDecimals: withDecimals,
      );

  /// تنسيق مختصر للأرقام الكبيرة (للمخططات والمحاور الضيقة)
  ///
  /// 1.250 → «1,3 أ» · 15.000 → «15 أ» · 2.400.000 → «2,4 م»
  static String formatCompact(BuildContext context, Money amount) {
    final String tag = localeTag(context);
    final NumberFormat compact = NumberFormat.compact(locale: tag);
    final String numberText = compact.format(amount.toDoubleForDisplayOnly);
    return '$numberText\u00A0${symbolFor(context, amount.currency)}';
  }

  // ─────────────────────────────────────────────────────────────
  //  تنسيق الأعداد والنِسب
  // ─────────────────────────────────────────────────────────────

  /// عدد صحيح مع فواصل الآلاف (عدّادات، إحصاءات)
  static String formatInt(BuildContext context, int value) =>
      NumberFormat.decimalPattern(localeTag(context)).format(value);

  /// نسبة مئوية: 0.184 → «18%»
  static String formatPercent(BuildContext context, double ratio, {int decimals = 0}) =>
      NumberFormat.decimalPercentPattern(
        locale: localeTag(context),
        decimalDigits: decimals,
      ).format(ratio);

  /// نسبة مع إشارة: +18% أو -5%
  static String formatSignedPercent(BuildContext context, double ratio) {
    final String formatted = formatPercent(context, ratio.abs());
    if (ratio > 0) return '+$formatted';
    if (ratio < 0) return '-$formatted';
    return formatted;
  }

  /// عدد عشري بخانة أو خانتين (أسعار الصرف)
  static String formatRate(BuildContext context, double rate, {int decimals = 2}) =>
      NumberFormat.decimalPatternDigits(locale: localeTag(context), decimalDigits: decimals).format(rate);

  // ─────────────────────────────────────────────────────────────
  //  تنسيق التواريخ
  // ─────────────────────────────────────────────────────────────

  /// تاريخ كامل: «21 سبتمبر 2026» / «21 septembre 2026»
  static String formatDate(BuildContext context, DateTime date) =>
      DateFormat.yMMMMd(localeTag(context)).format(date);

  /// تاريخ مختصر: «21/09/2026»
  static String formatDateShort(BuildContext context, DateTime date) =>
      DateFormat('dd/MM/yyyy', localeTag(context)).format(date);

  /// يوم واسم اليوم: «الأحد 21»
  static String formatDayWithWeekday(BuildContext context, DateTime date) =>
      DateFormat.MMMEd(localeTag(context)).format(date);

  /// شهر وسنة: «سبتمبر 2026»
  static String formatMonthYear(BuildContext context, DateTime date) =>
      DateFormat.yMMMM(localeTag(context)).format(date);

  /// وقت: «14:35»
  static String formatTime(BuildContext context, DateTime date) =>
      DateFormat.Hm(localeTag(context)).format(date);

  /// تاريخ ووقت: «21 سبتمبر 2026، 14:35»
  static String formatDateTime(BuildContext context, DateTime date) =>
      DateFormat.yMMMMd(localeTag(context)).add_Hm().format(date);

  /// نطاق تاريخ: «25 أوت → 24 سبتمبر»
  static String formatDateRange(BuildContext context, DateTime start, DateTime end) {
    final DateFormat dayMonth = DateFormat.MMMd(localeTag(context));
    return '${dayMonth.format(start)} ← ${formatDate(context, end)}';
  }

  // ─────────────────────────────────────────────────────────────
  //  إدخال الأرقام (لوحات المفاتيح)
  // ─────────────────────────────────────────────────────────────

  /// الفاصل العشري المتوقع حسب اللغة — للتحقق أثناء الكتابة
  static String decimalSeparator(BuildContext context) => isArabic(context) ? ',' : ',';

  /// فاصل الآلاف المتوقع حسب اللغة — لعرضه أثناء الكتابة
  static String groupSeparator(BuildContext context) => isArabic(context) ? '.' : '\u00A0';

  /// ينسّق نصاً جارياً كتابته في حقل مبلغ — يُظهر فواصل الآلاف مباشرة
  ///
  /// يحافظ على موضع المؤشر منطقياً ويُبقي الفاصل العشري الذي كتبه المستخدم.
  static String formatWhileTyping(BuildContext context, String raw) {
    if (raw.trim().isEmpty) return '';

    // فصل الإشارة
    final bool negative = raw.trim().startsWith('-');
    String body = raw.replaceAll('-', '').trim();

    // إيجاد الفاصل العشري (آخر , أو .)
    final int lastComma = body.lastIndexOf(',');
    final int lastDot = body.lastIndexOf('.');
    final int decimalIndex = lastComma > lastDot ? lastComma : lastDot;

    String wholePart = decimalIndex == -1 ? body : body.substring(0, decimalIndex);
    final String fractionPart = decimalIndex == -1 ? '' : body.substring(decimalIndex + 1);

    // إزالة كل الفواصل من الجزء الصحيح
    wholePart = wholePart.replaceAll(RegExp(r'[.,\s\u066C\u00A0]'), '');
    if (wholePart.isEmpty) wholePart = '0';
    wholePart = wholePart.replaceFirst(RegExp(r'^0+(?=\d)'), '');

    // تنسيق الجزء الصحيح بفواصل الآلاف حسب اللغة
    final int? wholeValue = int.tryParse(wholePart);
    if (wholeValue == null) return raw;

    final String formattedWhole =
        NumberFormat.decimalPatternDigits(locale: localeTag(context), decimalDigits: 0).format(wholeValue);

    final StringBuffer buffer = StringBuffer();
    if (negative) buffer.write('-');
    buffer.write(formattedWhole);

    // إن كتب المستخدم فاصلاً عشرياً، نبقيه ونلحق ما كتبه (خانتان كحد أقصى)
    if (decimalIndex != -1) {
      buffer.write(groupSeparator(context) == '.' ? '.' : ',');
      final String limitedFraction =
          fractionPart.replaceAll(RegExp('[^0-9]'), '').substring(
                0,
                fractionPart.replaceAll(RegExp('[^0-9]'), '').length > 2
                    ? 2
                    : fractionPart.replaceAll(RegExp('[^0-9]'), '').length,
              );
      buffer.write(limitedFraction);
    }
    return buffer.toString();
  }
}
