/// Spacing and layout tokens for the Unorive design system.
class AppSpacing {
  AppSpacing._();

  // Spacing / Margins / Paddings
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

/// Corner radius tokens for borders and clipping.
class AppRadius {
  AppRadius._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  
  /// Fully circular corner radius (e.g. for pills, avatars)
  static const double circular = 999;
}

/// Elevation and shadow tokens.
class AppElevation {
  AppElevation._();

  static const double none = 0;
  static const double low = 2;
  static const double medium = 4;
  static const double high = 8;
}
