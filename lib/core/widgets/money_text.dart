import 'package:flutter/material.dart';

import '../theme/typography.dart';
import '../utils/money.dart';
import '../utils/number_format.dart';

/// ═══════════════════════════════════════════════════════════════
///  MoneyText — عرض المبالغ المالية بشكل صحيح
///
///  ينفّذ قاعدتين إلزاميتين:
///
///  1️⃣ Laboratory Effect: خط Mono (IBM Plex Mono) + أرقام جدولية
///     → المبالغ تُصطفّ عمودياً فتُقارَن بصرياً في جزء من الثانية.
///
///  2️⃣ RTL صحيح: الرقم يبقى LTR داخل النص العربي.
///     `1.250,50 دج` تُقرأ «ألف ومئتان وخمسون ونصف دينار» —
///     لا تنقلب. نغلّف بـ Directionality.ltr لتحقيق ذلك.
///
///  ⚠️ لا تعرض مبلغاً بـ Text() عادي أبداً — استعمل هذا الويدجت.
/// ═══════════════════════════════════════════════════════════════
class MoneyText extends StatelessWidget {
  const MoneyText({
    required this.amount,
    super.key,
    this.size = MoneyTextSize.medium,
    this.color,
    this.withSymbol = true,
    this.withDecimals = true,
    this.showSign = false,
    this.colorizeBySign = false,
    this.maxLines = 1,
    this.shrinkOnOverflow = true,
    this.textAlign,
  });

  /// المبلغ
  final Money amount;

  /// الحجم (يحدد نمط الخط)
  final MoneyTextSize size;

  /// لون مخصص — إن تُرك `null` يُشتق من السياق أو من الإشارة
  final Color? color;

  /// إظهار رمز العملة (دج / DA)
  final bool withSymbol;

  /// إظهار السنتيمات
  final bool withDecimals;

  /// إظهار إشارة + للمبالغ الموجبة
  final bool showSign;

  /// تلوين تلقائي: أخضر للموجب/الدخل، أحمر للسالب/المصروف
  ///
  /// ⚠️ Accessibility: اللون وحده لا يكفي — استعمل [showSign]
  /// أو أضف أيقونة ▲▼ بجانبه.
  final bool colorizeBySign;

  final int maxLines;

  /// يصغّر الخط تلقائياً بدل القصّ عند التكبير 200%
  final bool shrinkOnOverflow;

  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    final Color effectiveColor = color ??
        (colorizeBySign
            ? (amount.isNegative
                ? scheme.error
                : (amount.isPositive ? _incomeColor(scheme) : scheme.onSurface))
            : scheme.onSurface);

    final String text = AppNumberFormat.formatMoney(
      context,
      amount,
      withSymbol: withSymbol,
      withDecimals: withDecimals,
      showSign: showSign,
    );

    final Widget textWidget = Text(
      text,
      // ⭐ الأرقام والرمز يُقرأان LTR — صحيح في السياق العربي
      textDirection: TextDirection.ltr,
      style: _styleFor(scheme).copyWith(color: effectiveColor),
      maxLines: maxLines,
      overflow: shrinkOnOverflow ? TextOverflow.visible : TextOverflow.ellipsis,
      textAlign: textAlign,
      semanticsLabel: text,
    );

    // ⭐ Directionality.ltr يثبّت الترتيب البصري: [الرقم][مسافة][الرمز]
    // حتى داخل شجرة RTL — بدونه قد ينتقل الرمز قبل الرقم.
    final Widget directional = Directionality(
      textDirection: TextDirection.ltr,
      child: textWidget,
    );

    if (!shrinkOnOverflow) return directional;

    // عند تكبير النظام 200% نصغّر بدل أن يُقصّ الرقم (WCAG)
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerStart,
      child: directional,
    );
  }

  TextStyle _styleFor(ColorScheme scheme) => switch (size) {
        MoneyTextSize.display => AppTypography.monoDisplay,
        MoneyTextSize.large => AppTypography.monoLarge,
        MoneyTextSize.medium => AppTypography.monoMedium,
        MoneyTextSize.small => AppTypography.monoSmall,
        MoneyTextSize.label => AppTypography.monoLabel,
      };

  /// لون الدخل — يشتق من الحاوية الثانوية في الداكن والفاتح
  Color _incomeColor(ColorScheme scheme) =>
      scheme.brightness == Brightness.dark
          ? const Color(0xFF7BD68A)
          : const Color(0xFF2E7D32);
}

/// أحجام عرض المبالغ
enum MoneyTextSize {
  /// شاشة إضافة حركة — 40sp
  display,

  /// الرصيد في الرئيسية — 24sp
  large,

  /// القوائم والبطاقات — 18sp
  medium,

  /// الإحصاءات الثانوية — 14sp
  small,

  /// النسب والعدّادات — 13sp
  label,
}

/// مبلغ مع أيقونة اتجاه (▲▼) — للالتزام بقاعدة
/// «لا تعتمد على اللون وحده» (WCAG 1.4.1)
class MoneyTextWithDirection extends StatelessWidget {
  const MoneyTextWithDirection({
    required this.amount,
    super.key,
    this.size = MoneyTextSize.medium,
    this.withSymbol = true,
    this.withDecimals = true,
  });

  final Money amount;
  final MoneyTextSize size;
  final bool withSymbol;
  final bool withDecimals;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    final IconData icon;
    final Color iconColor;
    if (amount.isNegative) {
      icon = Icons.arrow_downward_rounded;
      iconColor = scheme.error;
    } else if (amount.isPositive) {
      icon = Icons.arrow_upward_rounded;
      iconColor = const Color(0xFF2E7D32);
    } else {
      icon = Icons.remove_rounded;
      iconColor = scheme.onSurfaceVariant;
    }

    final double iconSize = switch (size) {
      MoneyTextSize.display => 28,
      MoneyTextSize.large => 22,
      MoneyTextSize.medium => 18,
      MoneyTextSize.small => 14,
      MoneyTextSize.label => 13,
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: iconSize, color: iconColor),
        const SizedBox(width: 4),
        Flexible(
          child: MoneyText(
            amount: amount.abs(),
            size: size,
            withSymbol: withSymbol,
            withDecimals: withDecimals,
            color: iconColor,
          ),
        ),
      ],
    );
  }
}
