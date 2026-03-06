import 'package:flutter/material.dart';

/// Spacing scale based on a 4dp grid.
///
/// All layout spacing in InspectoBot should reference these tokens rather than
/// hardcoded numeric literals.
abstract final class AppSpacing {
  static const double spacingXxs = 2.0;
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 20.0;
  static const double spacingXxl = 24.0;
  static const double spacing3xl = 32.0;
  static const double spacing4xl = 48.0;
}

/// Semantic [EdgeInsets] constants built from the spacing scale.
///
/// These cover common padding patterns observed across InspectoBot's screens.
abstract final class AppEdgeInsets {
  /// Page-level body padding.
  static const pagePadding = EdgeInsets.all(AppSpacing.spacingLg);

  /// Horizontal-only page padding.
  static const pageHorizontal = EdgeInsets.symmetric(
    horizontal: AppSpacing.spacingLg,
  );

  /// Card internal padding.
  static const cardPadding = EdgeInsets.all(AppSpacing.spacingLg);

  /// Compact card padding (for dense lists).
  static const cardPaddingCompact = EdgeInsets.symmetric(
    horizontal: AppSpacing.spacingMd,
    vertical: AppSpacing.spacingSm,
  );

  /// Input field content padding.
  static const inputPadding = EdgeInsets.symmetric(
    horizontal: AppSpacing.spacingMd,
    vertical: AppSpacing.spacingMd,
  );

  /// Section gap (vertical space between logical sections).
  static const sectionGap = EdgeInsets.only(top: AppSpacing.spacingXl);

  /// Form field gap (vertical space between form fields).
  static const fieldGap = EdgeInsets.only(top: AppSpacing.spacingMd);
}

/// Border radius tokens.
///
/// Utilitarian/industrial aesthetic: restrained rounding (4-8dp on most
/// components), never fully rounded except pill-shaped toggle buttons.
abstract final class AppRadii {
  // Raw double values for use with ShapeBorder, etc.
  static const double radiusNone = 0.0;
  static const double radiusXs = 2.0;
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusFull = 9999.0;

  // Pre-built BorderRadius for convenience.
  static final none = BorderRadius.circular(radiusNone);
  static final xs = BorderRadius.circular(radiusXs);
  static final sm = BorderRadius.circular(radiusSm);
  static final md = BorderRadius.circular(radiusMd);
  static final lg = BorderRadius.circular(radiusLg);
  static final full = BorderRadius.circular(radiusFull);
}

/// Material 3 elevation levels.
///
/// In dark themes, elevation is expressed primarily through surface tint
/// overlays rather than drop shadows.
abstract final class AppElevation {
  static const double level0 = 0.0;
  static const double level1 = 1.0;
  static const double level2 = 3.0;
  static const double level3 = 6.0;
  static const double level4 = 8.0;
  static const double level5 = 12.0;
}
