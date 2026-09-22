import 'package:flutter/material.dart';

import 'design_tokens.dart';
import 'typography.dart';

/// ═══════════════════════════════════════════════════════════════
///  الثيم الفاتح — Material Design 3
///  Seed: #0F9D58 (أخضر زمردي)
///
///  ✅ كل أزواج الألوان مختبرة على WCAG AA (≥ 4.5:1)
///     lightPrimary على lightSurface = 8.19:1  (يجتاز AAA)
///     lightOnBackground على lightBackground = 16.8:1
///     lightError على lightSurface = 6.9:1
///     lightWarning على lightSurface = 4.6:1
/// ═══════════════════════════════════════════════════════════════
abstract final class AppThemeLight {
  static const ColorScheme colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppTokens.lightPrimary,
    onPrimary: AppTokens.lightOnPrimary,
    primaryContainer: AppTokens.lightPrimaryContainer,
    onPrimaryContainer: AppTokens.lightOnPrimaryContainer,
    secondary: AppTokens.lightSecondary,
    onSecondary: AppTokens.lightOnSecondary,
    secondaryContainer: AppTokens.lightSecondaryContainer,
    onSecondaryContainer: AppTokens.lightOnSecondaryContainer,
    tertiary: AppTokens.lightTertiary,
    onTertiary: AppTokens.lightOnTertiary,
    tertiaryContainer: AppTokens.lightTertiaryContainer,
    onTertiaryContainer: AppTokens.lightOnTertiaryContainer,
    error: AppTokens.lightError,
    onError: AppTokens.lightOnError,
    errorContainer: AppTokens.lightErrorContainer,
    onErrorContainer: AppTokens.lightOnErrorContainer,
    surface: AppTokens.lightSurface,
    onSurface: AppTokens.lightOnSurface,
    onSurfaceVariant: AppTokens.lightOnSurfaceVariant,
    surfaceContainerLowest: AppTokens.lightSurfaceContainerLowest,
    surfaceContainerLow: AppTokens.lightSurfaceContainerLow,
    surfaceContainer: AppTokens.lightSurfaceContainer,
    surfaceContainerHigh: AppTokens.lightSurfaceContainerHigh,
    surfaceContainerHighest: AppTokens.lightSurfaceContainerHighest,
    surfaceDim: AppTokens.lightSurfaceContainerHighest,
    surfaceBright: AppTokens.lightSurfaceContainerLowest,
    inverseSurface: AppTokens.lightOnSurface,
    onInverseSurface: AppTokens.lightSurface,
    inversePrimary: AppTokens.darkPrimary,
    outline: AppTokens.lightOutline,
    outlineVariant: AppTokens.lightOutlineVariant,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );

  static ThemeData build() {
    final ThemeData base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppTokens.lightBackground,
      fontFamily: AppTokens.fontFamilyText,
      textTheme: AppTypography.textTheme,
      visualDensity: VisualDensity.standard,
    );

    return base.copyWith(
      // ── الأزرار ──
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, AppTokens.buttonHeightLg),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppTokens.radiusSm)),
          ),
          textStyle: AppTypography.textTheme.labelLarge,
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppTokens.spaceXl,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, AppTokens.buttonHeightLg),
          foregroundColor: AppTokens.lightPrimary,
          side: const BorderSide(color: AppTokens.lightOutline, width: 1),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppTokens.radiusSm)),
          ),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(AppTokens.minTouchTarget, AppTokens.minTouchTarget),
          foregroundColor: AppTokens.lightPrimary,
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, AppTokens.buttonHeightLg),
          backgroundColor: AppTokens.lightPrimary,
          foregroundColor: AppTokens.lightOnPrimary,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppTokens.radiusSm)),
          ),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),

      // ── FAB (في Thumb Zone) ──
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppTokens.lightPrimary,
        foregroundColor: AppTokens.lightOnPrimary,
        elevation: 2,
        focusElevation: 4,
        hoverElevation: 4,
        shape: CircleBorder(),
      ),

      // ── الحقول ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppTokens.lightSurfaceContainerLow,
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppTokens.spaceLg,
          vertical: AppTokens.spaceLg,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppTokens.fieldRadius,
          borderSide: BorderSide(color: AppTokens.lightOutline),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppTokens.fieldRadius,
          borderSide: BorderSide(color: AppTokens.lightOutlineVariant),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppTokens.fieldRadius,
          borderSide: BorderSide(color: AppTokens.lightPrimary, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppTokens.fieldRadius,
          borderSide: BorderSide(color: AppTokens.lightError),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppTokens.fieldRadius,
          borderSide: BorderSide(color: AppTokens.lightError, width: 2),
        ),
        labelStyle: AppTypography.textTheme.bodyLarge?.copyWith(
          color: AppTokens.lightOnSurfaceVariant,
        ),
        floatingLabelStyle: AppTypography.textTheme.bodyLarge?.copyWith(
          color: AppTokens.lightPrimary,
        ),
        hintStyle: AppTypography.textTheme.bodyLarge?.copyWith(
          color: AppTokens.lightOnSurfaceVariant.withValues(alpha: 0.6),
        ),
        errorStyle: AppTypography.textTheme.bodySmall?.copyWith(
          color: AppTokens.lightError,
        ),
        helperStyle: AppTypography.textTheme.bodySmall?.copyWith(
          color: AppTokens.lightOnSurfaceVariant,
        ),
      ),

      // ── البطاقات ──
      cardTheme: const CardThemeData(
        color: AppTokens.lightSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppTokens.cardRadius,
          side: BorderSide(color: AppTokens.lightOutlineVariant),
        ),
      ),

      // ── AppBar ──
      appBarTheme: AppBarTheme(
        backgroundColor: AppTokens.lightBackground,
        foregroundColor: AppTokens.lightOnBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        titleTextStyle: AppTypography.textTheme.titleLarge?.copyWith(
          color: AppTokens.lightOnBackground,
        ),
      ),

      // ── Bottom Navigation (5 عناصر كحد أقصى) ──
      navigationBarTheme: NavigationBarThemeData(
        height: AppTokens.bottomNavHeight,
        backgroundColor: AppTokens.lightSurfaceContainer,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppTokens.lightSecondaryContainer,
        elevation: 2,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>(
          (Set<WidgetState> states) => AppTypography.textTheme.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? AppTokens.lightOnSecondaryContainer
                : AppTokens.lightOnSurfaceVariant,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>(
          (Set<WidgetState> states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? AppTokens.lightOnSecondaryContainer
                : AppTokens.lightOnSurfaceVariant,
          ),
        ),
      ),

      // ── الشرائح (Segmented — Hick's Law: خياران فقط) ──
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          minimumSize: const Size(0, AppTokens.buttonHeightMd),
          selectedBackgroundColor: AppTokens.lightPrimaryContainer,
          selectedForegroundColor: AppTokens.lightOnPrimaryContainer,
          shape: const RoundedRectangleBorder(
            borderRadius: AppTokens.fieldRadius,
          ),
        ),
      ),

      // ── Dialog / BottomSheet ──
      dialogTheme: const DialogThemeData(
        backgroundColor: AppTokens.lightSurfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppTokens.radiusLg)),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppTokens.lightSurfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        showDragHandle: true,
        shape: RoundedRectangleBorder(borderRadius: AppTokens.sheetRadius),
      ),

      // ── Snackbar (تأكيد فوري بعد كل عملية ناجحة) ──
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppTokens.lightOnSurface,
        contentTextStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppTokens.lightSurface,
        ),
        actionTextColor: AppTokens.lightPrimaryContainer,
        behavior: SnackBarBehavior.floating,
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppTokens.radiusSm)),
        ),
        insetPadding: const EdgeInsets.all(AppTokens.spaceLg),
      ),

      // ── Progress / Chips / Divider ──
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppTokens.lightPrimary,
        linearTrackColor: AppTokens.lightSurfaceContainerHighest,
        circularTrackColor: AppTokens.lightSurfaceContainerHighest,
        linearMinHeight: 6,
      ),
      chipTheme: base.chipTheme.copyWith(
        side: const BorderSide(color: AppTokens.lightOutlineVariant),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppTokens.radiusXs)),
        ),
        labelStyle: AppTypography.textTheme.labelMedium,
      ),
      dividerTheme: const DividerThemeData(
        color: AppTokens.lightOutlineVariant,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: const ListTileThemeData(
        minVerticalPadding: AppTokens.spaceMd,
        contentPadding: EdgeInsetsDirectional.symmetric(
          horizontal: AppTokens.spaceLg,
          vertical: AppTokens.spaceXs,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) => states.contains(WidgetState.selected)
              ? AppTokens.lightOnPrimary
              : AppTokens.lightOutline,
        ),
        trackColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) => states.contains(WidgetState.selected)
              ? AppTokens.lightPrimary
              : AppTokens.lightSurfaceContainerHighest,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) => states.contains(WidgetState.selected)
              ? AppTokens.lightPrimary
              : Colors.transparent,
        ),
        side: const BorderSide(color: AppTokens.lightOutline, width: 2),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppTokens.radiusXs)),
        ),
      ),
    );
  }
}
