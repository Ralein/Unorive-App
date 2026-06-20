import 'package:flutter/material.dart';

/// Color tokens for the Unorive app, focusing on a dark-mode-first design system.
class AppColors {
  // Prevent instantiation
  AppColors._();

  // Dark Theme Palette (Hero Palette)
  static const Color darkBackground = Color(0xFF080912);
  static const Color darkSurface = Color(0xFF141625);
  static const Color darkSurfaceGlass = Color(0x99141625);
  static const Color darkPrimary = Color(0xFF6366F1); // Indigo Accent
  static const Color darkSecondary = Color(0xFF00E5FF); // Electric Cyan
  static const Color darkAccent = Color(0xFFFF9F0A); // Warm Orange for Arrival
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkTextMuted = Color(0xFF6B7280);

  // Light Theme Palette
  static const Color lightBackground = Color(0xFFF3F4F6);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceGlass = Color(0xCCFFFFFF);
  static const Color lightPrimary = Color(0xFF4F46E5);
  static const Color lightSecondary = Color(0xFF0891B2);
  static const Color lightAccent = Color(0xFFF59E0B);
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF4B5563);
  static const Color lightTextMuted = Color(0xFF9CA3AF);

  // Shared Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color borderDark = Color(0xFF2E3047);
  static const Color borderLight = Color(0xFFE5E7EB);
}

/// A Custom [ThemeExtension] to provide extra semantic color tokens
/// not covered by standard [ColorScheme].
class UnoriveColors extends ThemeExtension<UnoriveColors> {
  const UnoriveColors({
    required this.glassSurface,
    required this.arrivalAccent,
    required this.textMuted,
    required this.border,
  });

  final Color glassSurface;
  final Color arrivalAccent;
  final Color textMuted;
  final Color border;

  @override
  UnoriveColors copyWith({
    Color? glassSurface,
    Color? arrivalAccent,
    Color? textMuted,
    Color? border,
  }) {
    return UnoriveColors(
      glassSurface: glassSurface ?? this.glassSurface,
      arrivalAccent: arrivalAccent ?? this.arrivalAccent,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
    );
  }

  @override
  UnoriveColors lerp(ThemeExtension<UnoriveColors>? other, double t) {
    if (other is! UnoriveColors) return this;
    return UnoriveColors(
      glassSurface: Color.lerp(glassSurface, other.glassSurface, t)!,
      arrivalAccent: Color.lerp(arrivalAccent, other.arrivalAccent, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
    );
  }
}
