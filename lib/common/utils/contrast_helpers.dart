import 'dart:math';
import 'dart:ui';

import 'package:inspectobot/theme/tokens.dart';

/// WCAG 2.1 contrast ratio utilities for accessibility verification.
abstract final class ContrastHelpers {
  /// Calculate relative luminance of a color per WCAG 2.1.
  ///
  /// See: https://www.w3.org/TR/WCAG21/#dfn-relative-luminance
  static double relativeLuminance(Color color) {
    double linearize(double srgb) {
      return srgb <= 0.03928
          ? srgb / 12.92
          : pow((srgb + 0.055) / 1.055, 2.4).toDouble();
    }

    final r = linearize(color.r);
    final g = linearize(color.g);
    final b = linearize(color.b);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Calculate contrast ratio between two colors per WCAG 2.1.
  ///
  /// Returns a value between 1.0 (identical) and 21.0 (black on white).
  static double contrastRatio(Color foreground, Color background) {
    final l1 = relativeLuminance(foreground);
    final l2 = relativeLuminance(background);
    final lighter = max(l1, l2);
    final darker = min(l1, l2);
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Check if a color pair meets WCAG AAA for normal text (7.0:1).
  static bool meetsAAANormal(Color foreground, Color background) =>
      contrastRatio(foreground, background) >= AppFieldUsability.wcagAAANormal;

  /// Check if a color pair meets WCAG AAA for large text (4.5:1).
  static bool meetsAAALarge(Color foreground, Color background) =>
      contrastRatio(foreground, background) >= AppFieldUsability.wcagAAALarge;

  /// Check if a color pair meets WCAG AA for normal text (4.5:1).
  static bool meetsAANormal(Color foreground, Color background) =>
      contrastRatio(foreground, background) >= AppFieldUsability.wcagAANormal;
}
