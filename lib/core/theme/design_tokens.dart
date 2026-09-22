import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════
///  Design Tokens — فلوسنا
///  نظام تصميم واحد مطبَّق على كل الشاشات بدون استثناء.
///
///  ⚠️ قاعدة إلزامية: لا تستخدم قيم ألوان/تباعد/زوايا خام في أي
///     شاشة. استعمل دائماً القيم من هذا الملف. أي شاشة تفت عن
///     النظام = خلل تصميمي.
/// ═══════════════════════════════════════════════════════════════
abstract final class AppTokens {
  // ─────────────────────────────────────────────────────────────
  //  الألوان — الوضع الفاتح (Material Design 3 Tonal Palette)
  //  Seed: #0F9D58 (أخضر زمردي)
  // ─────────────────────────────────────────────────────────────
  static const Color lightPrimary = Color(0xFF2E7D32); // P-40
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFFA5D6A7); // P-90
  static const Color lightOnPrimaryContainer = Color(0xFF0B3D13); // P-10

  /// ذهبي — لون الإنجاز والادخار (Secondary)
  static const Color lightSecondary = Color(0xFFB08900);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFFFFE082);
  static const Color lightOnSecondaryContainer = Color(0xFF3D2E00);

  /// فيروزي — للمخططات والتأكيد (Tertiary)
  static const Color lightTertiary = Color(0xFF00695C);
  static const Color lightOnTertiary = Color(0xFFFFFFFF);
  static const Color lightTertiaryContainer = Color(0xFF80CBC4);
  static const Color lightOnTertiaryContainer = Color(0xFF00251F);

  static const Color lightError = Color(0xFFB3261E);
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color lightErrorContainer = Color(0xFFF9DEDC);
  static const Color lightOnErrorContainer = Color(0xFF410E0B);

  /// أبيض دافئ — أقل إجهاداً للعين من الأبيض النقي
  static const Color lightBackground = Color(0xFFFAFAF7);
  static const Color lightOnBackground = Color(0xFF1A1C19);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF1A1C19);
  static const Color lightSurfaceVariant = Color(0xFFE7E0EC);
  static const Color lightOnSurfaceVariant = Color(0xFF49454F);
  static const Color lightOutline = Color(0xFF79747E);
  static const Color lightOutlineVariant = Color(0xFFCAC4D0);

  static const Color lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainerLow = Color(0xFFF5F3EF);
  static const Color lightSurfaceContainer = Color(0xFFEFEEE9);
  static const Color lightSurfaceContainerHigh = Color(0xFFE9E8E3);
  static const Color lightSurfaceContainerHighest = Color(0xFFE3E2DD);

  /// كهرماني — تحذير 80% من حد الميزانية
  static const Color lightWarning = Color(0xFFB26A00);
  static const Color lightOnWarning = Color(0xFFFFFFFF);
  static const Color lightWarningContainer = Color(0xFFFFE0B2);

  // ─────────────────────────────────────────────────────────────
  //  الألوان — الوضع الداكن
  // ─────────────────────────────────────────────────────────────
  static const Color darkPrimary = Color(0xFF7BD68A); // P-80
  static const Color darkOnPrimary = Color(0xFF00390F);
  static const Color darkPrimaryContainer = Color(0xFF1B5E20); // P-30
  static const Color darkOnPrimaryContainer = Color(0xFFC8E6C9); // P-90

  static const Color darkSecondary = Color(0xFFFFD54F);
  static const Color darkOnSecondary = Color(0xFF3D2E00);
  static const Color darkSecondaryContainer = Color(0xFF5C4600);
  static const Color darkOnSecondaryContainer = Color(0xFFFFE082);

  static const Color darkTertiary = Color(0xFF4DB6AC);
  static const Color darkOnTertiary = Color(0xFF00201B);
  static const Color darkTertiaryContainer = Color(0xFF004D40);
  static const Color darkOnTertiaryContainer = Color(0xFFB2DFDB);

  static const Color darkError = Color(0xFFF2B8B5);
  static const Color darkOnError = Color(0xFF601410);
  static const Color darkErrorContainer = Color(0xFF8C1D18);
  static const Color darkOnErrorContainer = Color(0xFFF9DEDC);

  static const Color darkBackground = Color(0xFF12130F);
  static const Color darkOnBackground = Color(0xFFE3E2DD);
  static const Color darkSurface = Color(0xFF12130F);
  static const Color darkOnSurface = Color(0xFFE3E2DD);
  static const Color darkSurfaceVariant = Color(0xFF49454F);
  static const Color darkOnSurfaceVariant = Color(0xFFCAC4D0);
  static const Color darkOutline = Color(0xFF938F99);
  static const Color darkOutlineVariant = Color(0xFF49454F);

  static const Color darkSurfaceContainerLowest = Color(0xFF0C0D0A);
  static const Color darkSurfaceContainerLow = Color(0xFF1A1C19);
  static const Color darkSurfaceContainer = Color(0xFF1E201D);
  static const Color darkSurfaceContainerHigh = Color(0xFF282A27);
  static const Color darkSurfaceContainerHighest = Color(0xFF333532);

  static const Color darkWarning = Color(0xFFFFB74D);
  static const Color darkOnWarning = Color(0xFF4A2C00);
  static const Color darkWarningContainer = Color(0xFF5C3A00);

  // ─────────────────────────────────────────────────────────────
  //  ألوان دلالية ثابتة (لا تتغير بين الفاتح والداكن في معناها)
  // ─────────────────────────────────────────────────────────────
  /// دخل / ربح / نجاح
  static const Color semanticIncome = Color(0xFF2E7D32);

  /// مصروف / خسارة / تجاوز
  static const Color semanticExpense = Color(0xFFC62828);

  /// ⚠️ قاعدة Accessibility إلزامية:
  /// التحذير لا يُعبَّر عنه باللون وحده أبداً — دائماً مع أيقونة + نص.
  /// (8% من الرجال مصابون بعمى الألوان)

  // ─────────────────────────────────────────────────────────────
  //  سلّم التباعد (Spacing Scale) — مضاعفات 4
  // ─────────────────────────────────────────────────────────────
  static const double spaceXxs = 2;
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 12;
  static const double spaceLg = 16; // ⭐ الحشو الأساسي — الأكثر استعمالاً
  static const double spaceXl = 24;
  static const double spaceXxl = 32;
  static const double spaceXxxl = 48;

  // ─────────────────────────────────────────────────────────────
  //  الزوايا (Border Radius)
  // ─────────────────────────────────────────────────────────────
  static const double radiusNone = 0;
  static const double radiusXs = 4; // Badge · Chip
  static const double radiusSm = 8; // أزرار صغيرة · حقول
  static const double radiusMd = 12; // ⭐ البطاقات (الافتراضي)
  static const double radiusLg = 16; // Bottom Sheets · Dialogs
  static const double radiusXl = 24; // العناصر البارزة
  static const double radiusFull = 9999; // دائري (FAB · Avatar)

  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius sheetRadius = BorderRadius.vertical(
    top: Radius.circular(radiusLg),
  );
  static const BorderRadius fieldRadius = BorderRadius.all(Radius.circular(radiusSm));

  // ─────────────────────────────────────────────────────────────
  //  الظلال (Elevation) — تُستبدل بـ Surface Tint في الداكن
  // ─────────────────────────────────────────────────────────────
  static const List<BoxShadow> elevation1 = <BoxShadow>[
    BoxShadow(color: Color(0x4D000000), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x26000000), blurRadius: 3, spreadRadius: 1, offset: Offset(0, 1)),
  ];
  static const List<BoxShadow> elevation2 = <BoxShadow>[
    BoxShadow(color: Color(0x4D000000), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x26000000), blurRadius: 6, spreadRadius: 2, offset: Offset(0, 2)),
  ];
  static const List<BoxShadow> elevation3 = <BoxShadow>[
    BoxShadow(color: Color(0x26000000), blurRadius: 8, spreadRadius: 3, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x4D000000), blurRadius: 3, offset: Offset(0, 1)),
  ];

  // ─────────────────────────────────────────────────────────────
  //  أبعاد اللمس — Thumb Zone + WCAG
  // ─────────────────────────────────────────────────────────────
  /// الحد الأدنى لأي عنصر قابل للنقر (قاعدة Material + WCAG 2.5.5)
  static const double minTouchTarget = 48;

  /// المسافة الدنيا بين عنصرين قابلين للنقر (منع الضغط الخاطئ)
  static const double minTouchGap = 8;

  /// ارتفاع الزر الرئيسي
  static const double buttonHeightLg = 52;

  /// ارتفاع الزر المتوسط
  static const double buttonHeightMd = 44;

  /// ارتفاع حقل الإدخال
  static const double fieldHeight = 56;

  /// ارتفاع شريط التنقل السفلي
  static const double bottomNavHeight = 80;

  /// حجم زر الإضافة العائم
  static const double fabSize = 56;

  // ─────────────────────────────────────────────────────────────
  //  الحركة (Motion) — تحترم prefers-reduced-motion
  // ─────────────────────────────────────────────────────────────
  static const Duration motionFast = Duration(milliseconds: 150);
  static const Duration motionMedium = Duration(milliseconds: 300);
  static const Duration motionSlow = Duration(milliseconds: 450);

  static const Curve curveStandard = Cubic(0.2, 0.0, 0.0, 1.0);
  static const Curve curveEmphasized = Cubic(0.2, 0.0, 0.0, 1.0);
  static const Curve curveEnter = Cubic(0.0, 0.0, 0.2, 1.0);
  static const Curve curveExit = Cubic(0.4, 0.0, 1.0, 1.0);

  /// مدة الـ Snackbar
  static const Duration snackBarDuration = Duration(seconds: 3);

  // ─────────────────────────────────────────────────────────────
  //  قيود المدخلات (تُطبَّق في الواجهة وفي السيرفر — تحقق مزدوج)
  // ─────────────────────────────────────────────────────────────
  static const int maxEmailLength = 254;
  static const int maxPasswordLength = 128;
  static const int minPasswordLength = 8;
  static const int maxDisplayNameLength = 40;
  static const int maxNoteLength = 500;
  static const int maxDebtNoteLength = 300;
  static const int maxCounterpartyLength = 60;
  static const int maxGoalTitleLength = 60;
  static const int maxCategoryNameLength = 40;

  /// أعلى مبلغ مسموح: 999,999,999.99 (يتسع في NUMERIC(14,2))
  static const int maxAmountWhole = 999999999;

  /// يوم بداية الشهر المالي: 1..28 فقط
  /// (29/30/31 غير مدعومة لأنها غير موجودة في بعض الشهور)
  static const int minFiscalAnchorDay = 1;
  static const int maxFiscalAnchorDay = 28;

  /// مدة التجربة المجانية
  static const int trialDays = 7;

  /// سماح الأوفلاين بعد انتهاء الاشتراك (بالساعات)
  static const int offlineGraceHours = 72;

  // ─────────────────────────────────────────────────────────────
  //  عائلات الخطوط (معرَّفة في pubspec.yaml)
  // ─────────────────────────────────────────────────────────────
  /// Cairo: عربي + لاتيني متناسق — مجاني (SIL Open Font License)
  static const String fontFamilyText = 'Cairo';

  /// IBM Plex Mono: للأرقام والمبالغ — قاعدة Laboratory Effect
  /// الأرقام بخط Mono تُصطفّ عمودياً فتُقارَن بصرياً في جزء من الثانية
  static const String fontFamilyMono = 'IBMPlexMono';

  // ─────────────────────────────────────────────────────────────
  //  الحدود القصوى للعرض (Responsive Breakpoints)
  // ─────────────────────────────────────────────────────────────
  static const double breakpointCompact = 600; // هاتف
  static const double breakpointMedium = 840; // جهاز لوحي
  static const double breakpointExpanded = 1200; // سطح مكتب

  /// أقصى عرض للمحتوى على الشاشات الكبيرة (نسخة Windows)
  static const double maxContentWidth = 720;

  /// حواف أفقية قياسية
  static const double pagePadding = spaceLg;
}
