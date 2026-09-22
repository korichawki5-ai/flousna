import 'package:flutter/material.dart';

import 'design_tokens.dart';

/// ═══════════════════════════════════════════════════════════════
///  Typography — نظام الخطوط
///
///  ▸ Cairo: عربي + لاتيني متناسق (SIL Open Font License — مجاني تجارياً)
///  ▸ IBM Plex Mono: للأرقام والمبالغ (Laboratory Effect)
///
///  ⚠️ كل الأحجام بـ sp (لا px) → تتكبر مع إعداد النظام
///     بدون كسر التصميم. مختبرة عند تكبير 200%.
///
///  ⚠️ Body Large = 17sp (يتجاوز الحد الأدنى 16px) لمنع zoom
///     التلقائي في نسخة الويب.
/// ═══════════════════════════════════════════════════════════════
abstract final class AppTypography {
  /// النص الافتراضي للتطبيق كله
  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: AppTokens.fontFamilyText,
      fontSize: 36,
      height: 44 / 36,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
    ),
    displayMedium: TextStyle(
      fontFamily: AppTokens.fontFamilyText,
      fontSize: 32,
      height: 40 / 32,
      fontWeight: FontWeight.w400,
    ),
    displaySmall: TextStyle(
      fontFamily: AppTokens.fontFamilyText,
      fontSize: 28,
      height: 36 / 28,
      fontWeight: FontWeight.w400,
    ),

    headlineLarge: TextStyle(
      fontFamily: AppTokens.fontFamilyText,
      fontSize: 28,
      height: 36 / 28,
      fontWeight: FontWeight.w600,
    ),
    headlineMedium: TextStyle(
      fontFamily: AppTokens.fontFamilyText,
      fontSize: 26,
      height: 32 / 26,
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: TextStyle(
      fontFamily: AppTokens.fontFamilyText,
      fontSize: 24,
      height: 32 / 24,
      fontWeight: FontWeight.w600,
    ),

    titleLarge: TextStyle(
      fontFamily: AppTokens.fontFamilyText,
      fontSize: 22,
      height: 28 / 22,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: TextStyle(
      fontFamily: AppTokens.fontFamilyText,
      fontSize: 18,
      height: 24 / 18,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
    ),
    titleSmall: TextStyle(
      fontFamily: AppTokens.fontFamilyText,
      fontSize: 16,
      height: 22 / 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    ),

    // ⭐ 17sp وليس 16 — يمنع zoom في الويب ويريح العين بالعربية
    bodyLarge: TextStyle(
      fontFamily: AppTokens.fontFamilyText,
      fontSize: 17,
      height: 26 / 17,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.15,
    ),
    bodyMedium: TextStyle(
      fontFamily: AppTokens.fontFamilyText,
      fontSize: 15,
      height: 22 / 15,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.2,
    ),
    bodySmall: TextStyle(
      fontFamily: AppTokens.fontFamilyText,
      fontSize: 13,
      height: 18 / 13,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.3,
    ),

    labelLarge: TextStyle(
      fontFamily: AppTokens.fontFamilyText,
      fontSize: 15,
      height: 20 / 15,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontFamily: AppTokens.fontFamilyText,
      fontSize: 13,
      height: 16 / 13,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontFamily: AppTokens.fontFamilyText,
      fontSize: 12,
      height: 16 / 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
  );

  // ─────────────────────────────────────────────────────────────
  //  أنماط الأرقام (Mono) — Laboratory Effect
  //  تُستخدم لكل مبلغ مالي وإحصائية ورقم في جدول
  // ─────────────────────────────────────────────────────────────

  /// المبالغ الكبيرة (الرصيد في الرئيسية)
  static const TextStyle monoLarge = TextStyle(
    fontFamily: AppTokens.fontFamilyMono,
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.5,
    // ⭐ الأرقام تبقى LTR حتى داخل نص RTL
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  /// المبالغ الضخمة (شاشة إضافة حركة)
  static const TextStyle monoDisplay = TextStyle(
    fontFamily: AppTokens.fontFamilyMono,
    fontSize: 40,
    height: 48 / 40,
    fontWeight: FontWeight.w600,
    letterSpacing: -1,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  /// المبالغ في القوائم
  static const TextStyle monoMedium = TextStyle(
    fontFamily: AppTokens.fontFamilyMono,
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w500,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  /// المبالغ الثانوية والإحصاءات
  static const TextStyle monoSmall = TextStyle(
    fontFamily: AppTokens.fontFamilyMono,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  /// تسميات الأرقام (نسب مئوية، عدّادات)
  static const TextStyle monoLabel = TextStyle(
    fontFamily: AppTokens.fontFamilyMono,
    fontSize: 13,
    height: 16 / 13,
    fontWeight: FontWeight.w600,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );
}
