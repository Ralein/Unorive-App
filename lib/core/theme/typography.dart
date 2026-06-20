import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography configuration for Unorive, using:
/// - Space Grotesk for display / headlines (geometric sans)
/// - Inter for body / labels (humanist sans)
class AppTypography {
  AppTypography._();

  /// Space Grotesk font family style
  static TextStyle get displayFont => GoogleFonts.spaceGrotesk();

  /// Inter font family style
  static TextStyle get bodyFont => GoogleFonts.inter();

  /// Build a complete [TextTheme] mapped to Unorive design system tokens.
  static TextTheme createTextTheme(Color textColor) {
    return TextTheme(
      // Display large for big distance numbers, ETAs
      displayLarge: displayFont.copyWith(
        fontSize: 56,
        fontWeight: FontWeight.bold,
        color: textColor,
        letterSpacing: -1.5,
      ),
      displayMedium: displayFont.copyWith(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: textColor,
        letterSpacing: -1.0,
      ),
      displaySmall: displayFont.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textColor,
        letterSpacing: -0.5,
      ),

      // Headlines for main title headers
      headlineLarge: displayFont.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      headlineMedium: displayFont.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineSmall: displayFont.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),

      // Titles for section headers, card titles
      titleLarge: bodyFont.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: bodyFont.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      titleSmall: bodyFont.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),

      // Body text
      bodyLarge: bodyFont.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      bodyMedium: bodyFont.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      bodySmall: bodyFont.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),

      // Labels for captions, pills, helper text
      labelLarge: bodyFont.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelMedium: bodyFont.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelSmall: bodyFont.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
    );
  }
}
