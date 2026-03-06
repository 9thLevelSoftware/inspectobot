import 'package:flutter/material.dart';

/// Raw color constants for the InspectoBot dark theme.
///
/// Every value maps 1:1 to a Material 3 [ColorScheme] role (plus a few custom
/// semantic colors that live in the [AppTokens] ThemeExtension).
///
/// Usage: reference these from [app_theme.dart] when building the
/// [ColorScheme]. Widget code should read colors from the theme, not from
/// this class directly.
abstract final class Palette {
  // ---------------------------------------------------------------------------
  // Surface
  // ---------------------------------------------------------------------------
  static const background = Color(0xFF141418);
  static const surface = Color(0xFF1C1C22);
  static const surfaceVariant = Color(0xFF2A2A32);
  static const surfaceContainerLowest = Color(0xFF111114);
  static const surfaceContainerLow = Color(0xFF1A1A1F);
  static const surfaceContainer = Color(0xFF222228);
  static const surfaceContainerHigh = Color(0xFF2C2C34);
  static const surfaceContainerHighest = Color(0xFF363640);

  // ---------------------------------------------------------------------------
  // Primary (Orange)
  // ---------------------------------------------------------------------------
  static const primary = Color(0xFFF28C38);
  static const onPrimary = Color(0xFF1C1C22);
  static const primaryContainer = Color(0xFF3D2A14);
  static const onPrimaryContainer = Color(0xFFF5B06A);

  // ---------------------------------------------------------------------------
  // Secondary (Yellow/Amber)
  // ---------------------------------------------------------------------------
  static const secondary = Color(0xFFF2C744);
  static const onSecondary = Color(0xFF1C1C22);
  static const secondaryContainer = Color(0xFF3D3414);
  static const onSecondaryContainer = Color(0xFFF5D97A);

  // ---------------------------------------------------------------------------
  // Tertiary (Blue-Gray)
  // ---------------------------------------------------------------------------
  static const tertiary = Color(0xFF7AACBF);
  static const onTertiary = Color(0xFF141418);
  static const tertiaryContainer = Color(0xFF1A2E36);
  static const onTertiaryContainer = Color(0xFFA3C8D6);

  // ---------------------------------------------------------------------------
  // Error
  // ---------------------------------------------------------------------------
  static const error = Color(0xFFF2564B);
  static const onError = Color(0xFF1C1C22);
  static const errorContainer = Color(0xFF3D1410);
  static const onErrorContainer = Color(0xFFF5897F);

  // ---------------------------------------------------------------------------
  // Text & outline
  // ---------------------------------------------------------------------------
  static const onSurface = Color(0xFFE8E6E3);
  static const onSurfaceVariant = Color(0xFFA8A6A3);
  static const outline = Color(0xFF444450);
  static const outlineVariant = Color(0xFF2E2E38);

  // ---------------------------------------------------------------------------
  // Inverse & misc
  // ---------------------------------------------------------------------------
  static const shadow = Color(0xFF000000);
  static const scrim = Color(0xFF000000);
  static const inverseSurface = Color(0xFFE8E6E3);
  static const onInverseSurface = Color(0xFF1C1C22);
  static const inversePrimary = Color(0xFF8B5A1E);
  static const surfaceTint = Color(0xFFF28C38);

  // ---------------------------------------------------------------------------
  // Custom semantic (not in ColorScheme -- via ThemeExtension)
  // ---------------------------------------------------------------------------
  static const success = Color(0xFF4CAF6A);
  static const warning = Color(0xFFF2A83A);
  static const info = Color(0xFF5B9BD5);
  static const disabled = Color(0xFF6B6968);
}
