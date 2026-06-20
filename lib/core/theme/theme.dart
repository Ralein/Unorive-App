import 'package:flutter/material.dart';
import 'package:unorive/core/theme/colors.dart';
import 'package:unorive/core/theme/typography.dart';

/// Unorive Design System themes, prioritizing dark-mode-first.
class AppTheme {
  AppTheme._();

  /// Dark Theme Definition (Default / Primary App Mode)
  static ThemeData get darkTheme {
    final textTheme = AppTypography.createTextTheme(AppColors.darkTextPrimary);
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.darkPrimary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        secondary: AppColors.darkSecondary,
        surface: AppColors.darkSurface,
        error: AppColors.error,
        onSurface: AppColors.darkTextPrimary,
      ),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderDark),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        modalBackgroundColor: AppColors.darkSurface,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
      ),
      extensions: const [
        UnoriveColors(
          glassSurface: AppColors.darkSurfaceGlass,
          arrivalAccent: AppColors.darkAccent,
          textMuted: AppColors.darkTextMuted,
          border: AppColors.borderDark,
        ),
      ],
    );
  }

  /// Light Theme Definition (Optional Secondary App Mode)
  static ThemeData get lightTheme {
    final textTheme = AppTypography.createTextTheme(AppColors.lightTextPrimary);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.lightPrimary,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.lightPrimary,
        secondary: AppColors.lightSecondary,
        surface: AppColors.lightSurface,
        error: AppColors.error,
      ),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderLight),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface,
        modalBackgroundColor: AppColors.lightSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
      ),
      extensions: const [
        UnoriveColors(
          glassSurface: AppColors.lightSurfaceGlass,
          arrivalAccent: AppColors.lightAccent,
          textMuted: AppColors.lightTextMuted,
          border: AppColors.borderLight,
        ),
      ],
    );
  }
}
