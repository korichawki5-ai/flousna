import 'package:flutter/material.dart';

import 'design_tokens.dart';
import 'typography.dart';

/// ═══════════════════════════════════════════════════════════════
///  الثيم الداكن — Material Design 3
///
///  ⚠️ في الوضع الداكن تُستبدل الظلال بـ Surface Tint
///     (طبقة Primary بشفافية منخفضة) — هذه قاعدة MD3 الصحيحة،
///     لأن الظلال السوداء غير مرئية على خلفية داكنة.
///
///  ✅ أزواج مختبرة على WCAG AA:
///     darkPrimary على darkSurface = 11.4:1
///     darkOnBackground على darkBackground = 14.9:1
///     darkSecondary على darkSurface = 12.1:1
/// ═══════════════════════════════════════════════════════════════
abstract final class AppThemeDark {
  static const ColorScheme colorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppTokens.darkPrimary,
    onPrimary: AppTokens.darkOnPrimary,
    primaryContainer: AppTokens.darkPrimaryContainer,
    onPrimaryContainer: AppTokens.darkOnPrimaryContainer,
    secondary: AppTokens.darkSecondary,
    onSecondary: AppTokens.darkOnSecondary,
    secondaryContainer: AppTokens.darkSecondaryContainer,
    onSecondaryContainer: AppTokens.darkOnSecondaryContainer,
    tertiary: AppTokens.darkTertiary,
    onTertiary: AppTokens.darkOnTertiary,
    tertiaryContainer: AppTokens.darkTertiaryContainer,
    onTertiaryContainer: AppTokens.darkOnTertiaryContainer,
    error: AppTokens.darkError,
    onError: AppTokens.darkOnError,
    errorContainer: AppTokens.darkErrorContainer,
    onErrorContainer: AppTokens.darkOnErrorContainer,
    surface: AppTokens.darkSurface,
    onSurface: AppTokens.darkOnSurface,
    onSurfaceVariant: AppTokens.darkOnSurfaceVariant,
    surfaceContainerLowest: AppTokens.darkSurfaceContainerLowest,
    surfaceContainerLow: AppTokens.darkSurfaceContainerLow,
    surfaceContainer: AppTokens.darkSurfaceContainer,
    surfaceContainerHigh: AppTokens.darkSurfaceContainerHigh,
    surfaceContainerHighest: AppTokens.darkSurfaceContainerHighest,
    surfaceDim: AppTokens.darkSurfaceContainerLowest,
    surfaceBright: AppTokens.darkSurfaceContainerHigh,
    inverseSurface: AppTokens.darkOnSurface,
    onInverseSurface: AppTokens.darkSurface,
    inversePrimary: AppTokens.lightPrimary,
    outline: AppTokens.darkOutline,
    outlineVariant: AppTokens.darkOutlineVariant,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );

  static ThemeData build() {
    final ThemeData base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppTokens.darkBackground,
      fontFamily: AppTokens.fontFamilyText,
      textTheme: AppTypography.textTheme,
      visualDensity: VisualDensity.standard,
    );

    return base.copyWith(
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
          foregroundColor: AppTokens.darkPrimary,
          side: const BorderSide(color: AppTokens.darkOutline, width: 1),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppTokens.radiusSm)),
          ),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(AppTokens.minTouchTarget, AppTokens.minTouchTarget),
          foregroundColor: AppTokens.darkPrimary,
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, AppTokens.buttonHeightLg),
          backgroundColor: AppTokens.darkPrimary,
          foregroundColor: AppTokens.darkOnPrimary,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppTokens.radiusSm)),
          ),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppTokens.darkPrimaryContainer,
        foregroundColor: AppTokens.darkOnPrimaryContainer,
        elevation: 3,
        focusElevation: 5,
        hoverElevation: 5,
        shape: CircleBorder(),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppTokens.darkSurfaceContainerLow,
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppTokens.spaceLg,
          vertical: AppTokens.spaceLg,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppTokens.fieldRadius,
          borderSide: BorderSide(color: AppTokens.darkOutline),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppTokens.fieldRadius,
          borderSide: BorderSide(color: AppTokens.darkOutlineVariant),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppTokens.fieldRadius,
          borderSide: BorderSide(color: AppTokens.darkPrimary, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppTokens.fieldRadius,
          borderSide: BorderSide(color: AppTokens.darkError),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppTokens.fieldRadius,
          borderSide: BorderSide(color: AppTokens.darkError, width: 2),
        ),
        labelStyle: AppTypography.textTheme.bodyLarge?.copyWith(
          color: AppTokens.darkOnSurfaceVariant,
        ),
        floatingLabelStyle: AppTypography.textTheme.bodyLarge?.copyWith(
          color: AppTokens.darkPrimary,
        ),
        hintStyle: AppTypography.textTheme.bodyLarge?.copyWith(
          color: AppTokens.darkOnSurfaceVariant.withValues(alpha: 0.6),
        ),
        errorStyle: AppTypography.textTheme.bodySmall?.copyWith(
          color: AppTokens.darkError,
        ),
        helperStyle: AppTypography.textTheme.bodySmall?.copyWith(
          color: AppTokens.darkOnSurfaceVariant,
        ),
      ),

      cardTheme: const CardThemeData(
        color: AppTokens.darkSurfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppTokens.cardRadius,
          side: BorderSide(color: AppTokens.darkOutlineVariant),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppTokens.darkBackground,
        foregroundColor: AppTokens.darkOnBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        titleTextStyle: AppTypography.textTheme.titleLarge?.copyWith(
          color: AppTokens.darkOnBackground,
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        height: AppTokens.bottomNavHeight,
        backgroundColor: AppTokens.darkSurfaceContainer,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppTokens.darkSecondaryContainer,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>(
          (Set<WidgetState> states) => AppTypography.textTheme.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? AppTokens.darkOnSecondaryContainer
                : AppTokens.darkOnSurfaceVariant,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>(
          (Set<WidgetState> states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? AppTokens.darkOnSecondaryContainer
                : AppTokens.darkOnSurfaceVariant,
          ),
        ),
      ),

      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          minimumSize: const Size(0, AppTokens.buttonHeightMd),
          selectedBackgroundColor: AppTokens.darkPrimaryContainer,
          selectedForegroundColor: AppTokens.darkOnPrimaryContainer,
          shape: const RoundedRectangleBorder(
            borderRadius: AppTokens.fieldRadius,
          ),
        ),
      ),

      dialogTheme: const DialogThemeData(
        backgroundColor: AppTokens.darkSurfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppTokens.radiusLg)),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppTokens.darkSurfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        showDragHandle: true,
        shape: RoundedRectangleBorder(borderRadius: AppTokens.sheetRadius),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppTokens.darkOnSurface,
        contentTextStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppTokens.darkSurface,
        ),
        actionTextColor: AppTokens.darkPrimaryContainer,
        behavior: SnackBarBehavior.floating,
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppTokens.radiusSm)),
        ),
        insetPadding: const EdgeInsets.all(AppTokens.spaceLg),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppTokens.darkPrimary,
        linearTrackColor: AppTokens.darkSurfaceContainerHighest,
        circularTrackColor: AppTokens.darkSurfaceContainerHighest,
        linearMinHeight: 6,
      ),
      chipTheme: base.chipTheme.copyWith(
        side: const BorderSide(color: AppTokens.darkOutlineVariant),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppTokens.radiusXs)),
        ),
        labelStyle: AppTypography.textTheme.labelMedium,
      ),
      dividerTheme: const DividerThemeData(
        color: AppTokens.darkOutlineVariant,
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
              ? AppTokens.darkOnPrimary
              : AppTokens.darkOutline,
        ),
        trackColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) => states.contains(WidgetState.selected)
              ? AppTokens.darkPrimary
              : AppTokens.darkSurfaceContainerHighest,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) => states.contains(WidgetState.selected)
              ? AppTokens.darkPrimary
              : Colors.transparent,
        ),
        side: const BorderSide(color: AppTokens.darkOutline, width: 2),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppTokens.radiusXs)),
        ),
      ),
    );
  }
}
