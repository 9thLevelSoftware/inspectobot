import 'package:flutter/material.dart';

import 'palette.dart';

/// Material 3 type scale for InspectoBot.
///
/// All sizes are bumped above Material 3 defaults for outdoor legibility.
/// Headlines use bold (w700) and titles use semi-bold (w600) for an
/// industrial/utilitarian feel. Minimum body text size is 14 sp.
///
/// Font family is null (system default: Roboto on Android, SF on iOS).
abstract final class AppTypography {
  static const String? _fontFamily = null; // system default

  static final TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 48,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      height: 1.2,
      color: Palette.onSurface,
    ),
    displayMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 40,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.0,
      height: 1.2,
      color: Palette.onSurface,
    ),
    displaySmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 32,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.0,
      height: 1.25,
      color: Palette.onSurface,
    ),
    headlineLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.0,
      height: 1.3,
      color: Palette.onSurface,
    ),
    headlineMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.0,
      height: 1.3,
      color: Palette.onSurface,
    ),
    headlineSmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.0,
      height: 1.35,
      color: Palette.onSurface,
    ),
    titleLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.0,
      height: 1.35,
      color: Palette.onSurface,
    ),
    titleMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      height: 1.4,
      color: Palette.onSurface,
    ),
    titleSmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      height: 1.4,
      color: Palette.onSurface,
    ),
    bodyLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.15,
      height: 1.5,
      color: Palette.onSurface,
    ),
    bodyMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.5,
      color: Palette.onSurface,
    ),
    bodySmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 1.5,
      color: Palette.onSurfaceVariant,
    ),
    labelLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      height: 1.4,
      color: Palette.onSurface,
    ),
    labelMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      height: 1.4,
      color: Palette.onSurface,
    ),
    labelSmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      height: 1.4,
      color: Palette.onSurfaceVariant,
    ),
  );

  // ---------------------------------------------------------------------------
  // Helper constants for InspectoBot-specific use cases
  // ---------------------------------------------------------------------------

  /// Section header style: titleMedium values with bold (w700) weight.
  static TextStyle get sectionHeader => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.15,
        height: 1.4,
        color: Palette.onSurface,
      );

  /// Field label style: bodyMedium values with onSurfaceVariant color.
  static TextStyle get fieldLabel => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.5,
        color: Palette.onSurfaceVariant,
      );

  /// Status badge style: labelMedium values with semi-bold (w600) weight.
  /// (labelMedium already uses w600 in this scale, so this is an alias with
  /// explicit semantics for badge contexts.)
  static TextStyle get statusBadge => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.4,
        color: Palette.onSurface,
      );

  /// Timestamp style: bodySmall values with onSurfaceVariant color.
  static TextStyle get timestamp => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.5,
        color: Palette.onSurfaceVariant,
      );

  /// Section title — highest visual weight in content areas (24sp bold).
  static TextStyle get sectionTitle => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.0,
        color: Palette.onSurface,
      );

  /// Subsection title — secondary grouping level (18sp semi-bold).
  static TextStyle get subsectionTitle => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: Palette.onSurface,
      );

  /// Field value — displayed data values, high contrast (16sp regular).
  static TextStyle get fieldValue => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        color: Palette.onSurface,
      );

  /// Required field label — orange accent for mandatory indicators (14sp bold).
  /// Contrast: 6.93:1 on surface — meets WCAG AA (4.5:1). Does not meet AAA Normal (7.0:1).
  /// Accepted as AA for this accent style per design review.
  static TextStyle get fieldLabelRequired => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.25,
        color: Palette.primary,
      );
}
