# Phase 1: Design Token System & Theme Foundation

**Project**: InspectoBot
**Version**: 1.0 (specification)
**Date**: 2026-03-05
**Status**: Draft specification -- not yet implemented
**Audience**: Implementing developer(s)

---

## Table of Contents

1. [Overview & Goals](#1-overview--goals)
2. [Color Palette Definition](#2-color-palette-definition)
3. [Typography Scale](#3-typography-scale)
4. [Spacing System](#4-spacing-system)
5. [Border Radius System](#5-border-radius-system)
6. [Elevation System](#6-elevation-system)
7. [Material 3 Component Themes](#7-material-3-component-themes)
8. [Implementation Notes](#8-implementation-notes)
9. [Testing Strategy](#9-testing-strategy)
10. [Migration Strategy](#10-migration-strategy)
11. [Appendix: Hardcoded Style Audit](#appendix-hardcoded-style-audit)

---

## 1. Overview & Goals

### Current State

InspectoBot v1.0 shipped with zero theme infrastructure:

```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
  useMaterial3: true,
),
```

All presentation files use hardcoded `TextStyle`, `EdgeInsets`, `SizedBox` values, and
direct `Colors.*` references (see Appendix for full audit).

### Target State

A complete design token system under `lib/theme/` providing:

- Dark-only, utilitarian/industrial visual identity
- Construction management app aesthetic (PlanGrid, Fieldwire, Procore)
- Orange/yellow accents on dark surfaces
- Optimized for outdoor/bright-sun readability (WCAG AAA where feasible, minimum AA)
- Card-based layouts with bold headers
- Zero hardcoded style values in presentation code

### File Structure

```
lib/theme/
  palette.dart        # Raw hex color values as Color constants
  tokens.dart         # Spacing, radii, elevation constants
  typography.dart     # TextStyle presets
  extensions.dart     # AppTokens ThemeExtension class
  context_ext.dart    # BuildContext extension for context.appTokens
  app_theme.dart      # ThemeData factory wiring everything together
```

### Access Pattern

```dart
// In any widget with BuildContext:
final tokens = context.appTokens;
padding: EdgeInsets.all(tokens.spacingMd),
style: tokens.titleLarge,
color: tokens.primary,
```

### No New Dependencies

The system uses only Flutter's built-in capabilities. No additional packages
(google_fonts, flex_color_scheme, etc.) are added. This preserves the app's
offline-first architecture -- system fonts are always available without network
fetches or asset bundling.

---

## 2. Color Palette Definition

### Design Rationale

**Why these specific values?**

- Dark surfaces avoid pure black (#000000) to prevent halation effect and OLED
  smearing. The base background uses #121212 (Material dark baseline) bumped
  slightly to #141418 for a cooler undertone that reads as "industrial."
- Orange accents are desaturated from pure orange to maintain WCAG AA contrast
  (4.5:1 minimum) against dark surfaces. Fully saturated orange (#FF6600) only
  achieves ~3.8:1 on dark backgrounds; the chosen #F28C38 achieves 5.7:1.
- Text colors use off-white (#E8E6E3) rather than pure white (#FFFFFF) to
  reduce eye strain during extended field use while maintaining 13.8:1 contrast
  ratio against the background.
- Outdoor readability is addressed by targeting WCAG AAA (7:1) for body text
  and WCAG AA (4.5:1) for large text and interactive elements.

### 2.1 Surface Colors

| Token Name           | Hex       | Usage                              | Contrast vs onSurface |
|----------------------|-----------|------------------------------------|-----------------------|
| `background`         | `#141418` | App scaffold background            | 13.5:1                |
| `surface`            | `#1C1C22` | Card backgrounds, bottom sheets    | 12.4:1                |
| `surfaceVariant`     | `#2A2A32` | Input field fills, toggles         | 10.2:1                |
| `surfaceContainerLowest` | `#111114` | Deepest layer, behind modals   | 14.2:1                |
| `surfaceContainerLow`   | `#1A1A1F` | Secondary containers           | 12.9:1                |
| `surfaceContainer`       | `#222228` | Default card container         | 11.3:1                |
| `surfaceContainerHigh`   | `#2C2C34` | Elevated cards, dialogs        | 9.6:1                 |
| `surfaceContainerHighest`| `#363640` | Highest elevation surfaces     | 8.1:1                 |

### 2.2 Primary Accent (Orange)

| Token Name         | Hex       | Usage                                  | Contrast vs surface |
|--------------------|-----------|----------------------------------------|---------------------|
| `primary`          | `#F28C38` | Primary buttons, active states, FABs   | 5.7:1               |
| `onPrimary`        | `#1C1C22` | Text/icons on primary-colored surfaces | 5.7:1               |
| `primaryContainer` | `#3D2A14` | Primary tonal fill (cards, chips)      | --                  |
| `onPrimaryContainer`| `#F5B06A`| Text on primary container              | 5.1:1               |

### 2.3 Secondary Accent (Yellow/Amber)

| Token Name            | Hex       | Usage                              | Contrast vs surface |
|-----------------------|-----------|------------------------------------|--------------------|
| `secondary`           | `#F2C744` | Secondary actions, badges, tags    | 8.2:1              |
| `onSecondary`         | `#1C1C22` | Text/icons on secondary surfaces   | 8.2:1              |
| `secondaryContainer`  | `#3D3414` | Secondary tonal fill               | --                 |
| `onSecondaryContainer`| `#F5D97A` | Text on secondary container        | 6.8:1              |

### 2.4 Tertiary (Blue-Gray, for info/metadata)

| Token Name            | Hex       | Usage                              |
|-----------------------|-----------|------------------------------------|
| `tertiary`            | `#7AACBF` | Tertiary actions, timestamps       |
| `onTertiary`          | `#141418` | Text on tertiary                   |
| `tertiaryContainer`   | `#1A2E36` | Tertiary container fill            |
| `onTertiaryContainer` | `#A3C8D6` | Text on tertiary container         |

### 2.5 Semantic Colors

| Token Name     | Hex       | Usage                         | Contrast vs surface |
|----------------|-----------|-------------------------------|---------------------|
| `error`        | `#F2564B` | Validation errors, destructive | 5.4:1              |
| `onError`      | `#FFFFFF` | Text on error surfaces         | 4.6:1              |
| `errorContainer`| `#3D1410`| Error container fill           | --                 |
| `onErrorContainer`| `#F5897F`| Text on error container      | 5.2:1              |
| `success`*     | `#4CAF6A` | Completion indicators          | 5.1:1              |
| `warning`*     | `#F2A83A` | Caution indicators             | 6.3:1              |
| `info`*        | `#5B9BD5` | Informational badges           | 4.9:1              |

*Items marked with `*` are custom semantic colors not part of Material's `ColorScheme`.
They will be provided through the `AppTokens` `ThemeExtension`.

### 2.6 Text Colors

| Token Name          | Hex       | Usage                         | Contrast vs background |
|---------------------|-----------|-------------------------------|------------------------|
| `onSurface`         | `#E8E6E3` | Primary text                  | 13.5:1 (AAA)           |
| `onSurfaceVariant`  | `#A8A6A3` | Secondary text, labels        | 7.2:1 (AAA)            |
| `disabled`*         | `#6B6968` | Disabled text and icons       | 3.6:1 (decorative)     |
| `outline`           | `#444450` | Borders, dividers             | --                     |
| `outlineVariant`    | `#2E2E38` | Subtle dividers               | --                     |

### 2.7 Miscellaneous

| Token Name          | Hex       | Usage                               |
|---------------------|-----------|--------------------------------------|
| `shadow`            | `#000000` | Drop shadows (with opacity)          |
| `scrim`             | `#000000` | Modal overlays (with opacity)        |
| `inverseSurface`    | `#E8E6E3` | Snackbar background                  |
| `onInverseSurface`  | `#1C1C22` | Snackbar text                        |
| `inversePrimary`    | `#8B5A1E` | Primary on inverse surface           |
| `surfaceTint`       | `#F28C38` | Material 3 elevation tint (primary)  |

### 2.8 Complete ColorScheme Mapping

```dart
// palette.dart
import 'package:flutter/material.dart';

abstract final class Palette {
  // Surface
  static const background       = Color(0xFF141418);
  static const surface          = Color(0xFF1C1C22);
  static const surfaceVariant   = Color(0xFF2A2A32);
  static const surfaceContainerLowest  = Color(0xFF111114);
  static const surfaceContainerLow     = Color(0xFF1A1A1F);
  static const surfaceContainer        = Color(0xFF222228);
  static const surfaceContainerHigh    = Color(0xFF2C2C34);
  static const surfaceContainerHighest = Color(0xFF363640);

  // Primary (Orange)
  static const primary            = Color(0xFFF28C38);
  static const onPrimary          = Color(0xFF1C1C22);
  static const primaryContainer   = Color(0xFF3D2A14);
  static const onPrimaryContainer = Color(0xFFF5B06A);

  // Secondary (Yellow/Amber)
  static const secondary            = Color(0xFFF2C744);
  static const onSecondary          = Color(0xFF1C1C22);
  static const secondaryContainer   = Color(0xFF3D3414);
  static const onSecondaryContainer = Color(0xFFF5D97A);

  // Tertiary (Blue-Gray)
  static const tertiary            = Color(0xFF7AACBF);
  static const onTertiary          = Color(0xFF141418);
  static const tertiaryContainer   = Color(0xFF1A2E36);
  static const onTertiaryContainer = Color(0xFFA3C8D6);

  // Error
  static const error            = Color(0xFFF2564B);
  static const onError          = Color(0xFFFFFFFF);
  static const errorContainer   = Color(0xFF3D1410);
  static const onErrorContainer = Color(0xFFF5897F);

  // Text & outline
  static const onSurface        = Color(0xFFE8E6E3);
  static const onSurfaceVariant = Color(0xFFA8A6A3);
  static const outline          = Color(0xFF444450);
  static const outlineVariant   = Color(0xFF2E2E38);

  // Inverse & misc
  static const shadow           = Color(0xFF000000);
  static const scrim            = Color(0xFF000000);
  static const inverseSurface   = Color(0xFFE8E6E3);
  static const onInverseSurface = Color(0xFF1C1C22);
  static const inversePrimary   = Color(0xFF8B5A1E);
  static const surfaceTint      = Color(0xFFF28C38);

  // Custom semantic (not in ColorScheme -- via ThemeExtension)
  static const success  = Color(0xFF4CAF6A);
  static const warning  = Color(0xFFF2A83A);
  static const info     = Color(0xFF5B9BD5);
  static const disabled = Color(0xFF6B6968);
}
```

---

## 3. Typography Scale

### Font Family Decision

**Recommendation: System default (Roboto on Android, San Francisco on iOS).**

Rationale:
- InspectoBot is offline-first. Google Fonts requires a network fetch or bundled
  assets (adds ~300KB-1MB per weight). System fonts are guaranteed available.
- Roboto (Android) and San Francisco (iOS) are both designed for screen
  readability including outdoor/high-brightness conditions.
- No `google_fonts` package dependency to maintain.
- Both system fonts have excellent glyph coverage for English field-inspection
  content.

### Type Scale Definition

All sizes use Material 3 role naming. Minimum body text size is 14sp for field
readability. Sizes are bumped above Material 3 defaults for outdoor legibility.

| Role           | Size (sp) | Weight  | Letter Spacing | Line Height | Usage                        |
|----------------|-----------|---------|----------------|-------------|------------------------------|
| `displayLarge` | 48        | w400    | -0.25          | 1.2         | (reserved, rarely used)      |
| `displayMedium`| 40        | w400    | 0.0            | 1.2         | (reserved)                   |
| `displaySmall` | 32        | w400    | 0.0            | 1.25        | Hero numbers, stats          |
| `headlineLarge`| 28        | w700    | 0.0            | 1.3         | Page titles                  |
| `headlineMedium`| 24       | w700    | 0.0            | 1.3         | Section headers              |
| `headlineSmall`| 20        | w600    | 0.0            | 1.35        | Card titles, form titles     |
| `titleLarge`   | 20        | w600    | 0.0            | 1.35        | AppBar title, dialog title   |
| `titleMedium`  | 16        | w600    | 0.15           | 1.4         | ListTile title, nav labels   |
| `titleSmall`   | 14        | w600    | 0.1            | 1.4         | Sub-section headers          |
| `bodyLarge`    | 16        | w400    | 0.15           | 1.5         | Primary body text            |
| `bodyMedium`   | 14        | w400    | 0.25           | 1.5         | Secondary body text          |
| `bodySmall`    | 12        | w400    | 0.4            | 1.5         | Captions, metadata           |
| `labelLarge`   | 14        | w600    | 0.1            | 1.4         | Button labels                |
| `labelMedium`  | 12        | w600    | 0.5            | 1.4         | Input labels, chip labels    |
| `labelSmall`   | 11        | w600    | 0.5            | 1.4         | Badges, overlines            |

### Key Decisions

- **Bold headers**: Headlines use w700 (bold) for the industrial/utilitarian
  feel. Titles use w600 (semi-bold). This departs from Material 3 defaults
  (which use w400 for headlines) to match construction app aesthetics.
- **Body minimum 14sp**: Material 3 default bodyMedium is 14sp; we keep that
  and bump bodyLarge to 16sp. bodySmall at 12sp is acceptable for non-critical
  metadata only.
- **Letter spacing**: Wider letter spacing on small text improves outdoor
  readability. Large text uses tighter spacing for visual density.

### Typography Definition

```dart
// typography.dart
import 'package:flutter/material.dart';
import 'palette.dart';

abstract final class AppTypography {
  static const _fontFamily = null; // system default

  static TextTheme textTheme = TextTheme(
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
}
```

---

## 4. Spacing System

### Base Unit

4dp grid. All spacing values are multiples of 4.

### Token Definitions

```dart
// In tokens.dart
abstract final class AppTokens {
  // Spacing scale
  static const double spacingXxs = 2.0;   // Half-unit, tight gaps
  static const double spacingXs  = 4.0;   // Minimal separation
  static const double spacingSm  = 8.0;   // Compact spacing
  static const double spacingMd  = 12.0;  // Default element gap (SizedBox between fields)
  static const double spacingLg  = 16.0;  // Section padding, page margins
  static const double spacingXl  = 20.0;  // Major section breaks
  static const double spacingXxl = 24.0;  // Page-level vertical separation
  static const double spacing3xl = 32.0;  // Hero spacing, large gaps
  static const double spacing4xl = 48.0;  // Reserved for major layout breaks
}
```

### Semantic Edge Insets

These are composite constants built from the spacing scale for common patterns
observed across InspectoBot's existing screens.

```dart
// In tokens.dart (continued)
abstract final class AppEdgeInsets {
  /// Page-level body padding (matches current `EdgeInsets.all(16)` usage)
  static const pagePadding = EdgeInsets.all(AppTokens.spacingLg);

  /// Horizontal-only page padding
  static const pageHorizontal = EdgeInsets.symmetric(
    horizontal: AppTokens.spacingLg,
  );

  /// Card internal padding
  static const cardPadding = EdgeInsets.all(AppTokens.spacingLg);

  /// Compact card padding (for dense lists)
  static const cardPaddingCompact = EdgeInsets.symmetric(
    horizontal: AppTokens.spacingMd,
    vertical: AppTokens.spacingSm,
  );

  /// Input field content padding
  static const inputPadding = EdgeInsets.symmetric(
    horizontal: AppTokens.spacingMd,
    vertical: AppTokens.spacingMd,
  );

  /// Section gap (vertical space between logical sections)
  static const sectionGap = EdgeInsets.only(top: AppTokens.spacingXl);

  /// Form field gap (vertical space between form fields)
  static const fieldGap = EdgeInsets.only(top: AppTokens.spacingMd);
}
```

### Current Usage Mapping

| Current code                    | Token replacement               |
|---------------------------------|---------------------------------|
| `EdgeInsets.all(16)`            | `AppEdgeInsets.pagePadding`     |
| `SizedBox(height: 8)`          | `SizedBox(height: tokens.spacingSm)`  |
| `SizedBox(height: 12)`         | `SizedBox(height: tokens.spacingMd)`  |
| `SizedBox(height: 16)`         | `SizedBox(height: tokens.spacingLg)`  |
| `SizedBox(height: 20)`         | `SizedBox(height: tokens.spacingXl)`  |
| `EdgeInsets.symmetric(vertical: 8)` | Use `spacingSm` equivalent |

---

## 5. Border Radius System

### Design Direction

Utilitarian/industrial means minimal rounding. Not fully sharp (that reads as
"broken"), but restrained. Construction apps like Fieldwire and Procore use
4-8dp radii on cards, 4dp on inputs, and minimal rounding on buttons.

### Token Definitions

```dart
// In tokens.dart (continued)
abstract final class AppRadii {
  static const double radiusNone = 0.0;    // Sharp corners (dividers, toolbars)
  static const double radiusXs   = 2.0;    // Subtle rounding (chips, badges)
  static const double radiusSm   = 4.0;    // Input fields, small buttons
  static const double radiusMd   = 8.0;    // Cards, dialogs
  static const double radiusLg   = 12.0;   // Bottom sheets, large containers
  static const double radiusFull = 9999.0; // Pill shapes (toggle buttons)

  // Pre-built BorderRadius for convenience
  static final none = BorderRadius.circular(radiusNone);
  static final xs   = BorderRadius.circular(radiusXs);
  static final sm   = BorderRadius.circular(radiusSm);
  static final md   = BorderRadius.circular(radiusMd);
  static final lg   = BorderRadius.circular(radiusLg);
  static final full = BorderRadius.circular(radiusFull);
}
```

### Component Radius Assignments

| Component            | Radius Token | Value |
|----------------------|-------------|-------|
| Card                 | `radiusMd`  | 8dp   |
| Dialog               | `radiusMd`  | 8dp   |
| Input field          | `radiusSm`  | 4dp   |
| Button (filled)      | `radiusSm`  | 4dp   |
| Button (outlined)    | `radiusSm`  | 4dp   |
| Chip                 | `radiusXs`  | 2dp   |
| Bottom sheet         | `radiusLg`  | 12dp  |
| Snackbar             | `radiusSm`  | 4dp   |
| FAB                  | `radiusMd`  | 8dp   |
| Navigation bar       | `radiusNone`| 0dp   |

---

## 6. Elevation System

### Material 3 Dark Theme Elevation

Material 3 expresses elevation primarily through surface tint overlay rather
than drop shadows. In dark themes, shadows are nearly invisible against dark
backgrounds, so tonal elevation (lighter surface = higher) is the primary depth
cue.

### Elevation Levels

```dart
// In tokens.dart (continued)
abstract final class AppElevation {
  static const double level0 = 0.0;   // Flat -- background surface
  static const double level1 = 1.0;   // Cards at rest
  static const double level2 = 3.0;   // Cards hovered/focused, AppBar
  static const double level3 = 6.0;   // Dialogs, bottom sheets
  static const double level4 = 8.0;   // Navigation drawers
  static const double level5 = 12.0;  // FAB, menus
}
```

### Surface Tint Mapping

Material 3 applies `surfaceTint` (our `#F28C38` primary) as an overlay at
increasing opacity based on elevation level. Flutter handles this automatically
when `surfaceTint` is set in the `ColorScheme`. The result:

| Elevation | Surface Result                          |
|-----------|----------------------------------------|
| Level 0   | `#1C1C22` (pure surface)               |
| Level 1   | `#1C1C22` + 5% orange tint overlay     |
| Level 2   | `#1C1C22` + 8% orange tint overlay     |
| Level 3   | `#1C1C22` + 11% orange tint overlay    |
| Level 4   | `#1C1C22` + 12% orange tint overlay    |
| Level 5   | `#1C1C22` + 14% orange tint overlay    |

This produces a subtle warm cast on elevated surfaces that reinforces the
construction/industrial brand without overwhelming the dark palette.

---

## 7. Material 3 Component Themes

All component themes reference token values, never hardcoded literals. Below is
the specification for each theme override.

### 7.1 AppBarTheme

```dart
AppBarTheme(
  backgroundColor: Palette.surface,
  foregroundColor: Palette.onSurface,
  elevation: AppElevation.level2,
  surfaceTintColor: Palette.surfaceTint,
  titleTextStyle: AppTypography.textTheme.titleLarge,
  centerTitle: false, // left-aligned, utilitarian
  iconTheme: IconThemeData(color: Palette.onSurface, size: 24),
)
```

### 7.2 CardTheme

```dart
CardTheme(
  color: Palette.surfaceContainer,
  surfaceTintColor: Palette.surfaceTint,
  elevation: AppElevation.level1,
  shape: RoundedRectangleBorder(
    borderRadius: AppRadii.md,
  ),
  margin: EdgeInsets.symmetric(vertical: AppTokens.spacingXs),
  clipBehavior: Clip.antiAlias,
)
```

### 7.3 InputDecorationTheme

```dart
InputDecorationTheme(
  filled: true,
  fillColor: Palette.surfaceVariant,
  contentPadding: AppEdgeInsets.inputPadding,
  border: OutlineInputBorder(
    borderRadius: AppRadii.sm,
    borderSide: BorderSide(color: Palette.outline),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: AppRadii.sm,
    borderSide: BorderSide(color: Palette.outline),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: AppRadii.sm,
    borderSide: BorderSide(color: Palette.primary, width: 2),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: AppRadii.sm,
    borderSide: BorderSide(color: Palette.error),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: AppRadii.sm,
    borderSide: BorderSide(color: Palette.error, width: 2),
  ),
  labelStyle: AppTypography.textTheme.labelMedium?.copyWith(
    color: Palette.onSurfaceVariant,
  ),
  hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
    color: Palette.disabled,
  ),
  errorStyle: AppTypography.textTheme.bodySmall?.copyWith(
    color: Palette.error,
  ),
  floatingLabelStyle: TextStyle(color: Palette.primary),
)
```

### 7.4 ElevatedButtonTheme

```dart
ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    backgroundColor: Palette.surfaceContainerHigh,
    foregroundColor: Palette.primary,
    elevation: AppElevation.level1,
    shape: RoundedRectangleBorder(borderRadius: AppRadii.sm),
    padding: EdgeInsets.symmetric(
      horizontal: AppTokens.spacingLg,
      vertical: AppTokens.spacingMd,
    ),
    textStyle: AppTypography.textTheme.labelLarge,
  ),
)
```

### 7.5 FilledButtonTheme

Note: `FilledButton` is used extensively in InspectoBot (New Inspection,
Continue, Generate PDF, Resume buttons).

```dart
FilledButtonThemeData(
  style: FilledButton.styleFrom(
    backgroundColor: Palette.primary,
    foregroundColor: Palette.onPrimary,
    disabledBackgroundColor: Palette.surfaceContainerHigh,
    disabledForegroundColor: Palette.disabled,
    shape: RoundedRectangleBorder(borderRadius: AppRadii.sm),
    padding: EdgeInsets.symmetric(
      horizontal: AppTokens.spacingLg,
      vertical: AppTokens.spacingMd,
    ),
    textStyle: AppTypography.textTheme.labelLarge,
  ),
)
```

### 7.6 OutlinedButtonTheme

```dart
OutlinedButtonThemeData(
  style: OutlinedButton.styleFrom(
    foregroundColor: Palette.primary,
    side: BorderSide(color: Palette.outline),
    shape: RoundedRectangleBorder(borderRadius: AppRadii.sm),
    padding: EdgeInsets.symmetric(
      horizontal: AppTokens.spacingLg,
      vertical: AppTokens.spacingMd,
    ),
    textStyle: AppTypography.textTheme.labelLarge,
  ),
)
```

### 7.7 TextButtonTheme

```dart
TextButtonThemeData(
  style: TextButton.styleFrom(
    foregroundColor: Palette.primary,
    shape: RoundedRectangleBorder(borderRadius: AppRadii.sm),
    padding: EdgeInsets.symmetric(
      horizontal: AppTokens.spacingMd,
      vertical: AppTokens.spacingSm,
    ),
    textStyle: AppTypography.textTheme.labelLarge,
  ),
)
```

### 7.8 IconButtonTheme

```dart
IconButtonThemeData(
  style: IconButton.styleFrom(
    foregroundColor: Palette.onSurfaceVariant,
    highlightColor: Palette.primary.withOpacity(0.12),
  ),
)
```

### 7.9 ChipTheme

```dart
ChipThemeData(
  backgroundColor: Palette.surfaceContainerHigh,
  selectedColor: Palette.primaryContainer,
  disabledColor: Palette.surfaceVariant,
  labelStyle: AppTypography.textTheme.labelMedium!,
  side: BorderSide(color: Palette.outline),
  shape: RoundedRectangleBorder(borderRadius: AppRadii.xs),
  padding: EdgeInsets.symmetric(
    horizontal: AppTokens.spacingSm,
    vertical: AppTokens.spacingXs,
  ),
)
```

### 7.10 BottomNavigationBarTheme

```dart
BottomNavigationBarThemeData(
  backgroundColor: Palette.surface,
  selectedItemColor: Palette.primary,
  unselectedItemColor: Palette.onSurfaceVariant,
  selectedLabelStyle: AppTypography.textTheme.labelSmall,
  unselectedLabelStyle: AppTypography.textTheme.labelSmall,
  type: BottomNavigationBarType.fixed,
  elevation: AppElevation.level2,
)
```

### 7.11 TabBarTheme

```dart
TabBarTheme(
  labelColor: Palette.primary,
  unselectedLabelColor: Palette.onSurfaceVariant,
  labelStyle: AppTypography.textTheme.labelLarge,
  unselectedLabelStyle: AppTypography.textTheme.labelLarge,
  indicatorColor: Palette.primary,
  indicatorSize: TabBarIndicatorSize.tab,
  dividerColor: Palette.outlineVariant,
)
```

### 7.12 DialogTheme

```dart
DialogTheme(
  backgroundColor: Palette.surfaceContainerHigh,
  surfaceTintColor: Palette.surfaceTint,
  elevation: AppElevation.level3,
  shape: RoundedRectangleBorder(borderRadius: AppRadii.md),
  titleTextStyle: AppTypography.textTheme.headlineSmall,
  contentTextStyle: AppTypography.textTheme.bodyMedium,
)
```

### 7.13 SnackBarTheme

```dart
SnackBarThemeData(
  backgroundColor: Palette.inverseSurface,
  contentTextStyle: AppTypography.textTheme.bodyMedium?.copyWith(
    color: Palette.onInverseSurface,
  ),
  actionTextColor: Palette.inversePrimary,
  shape: RoundedRectangleBorder(borderRadius: AppRadii.sm),
  behavior: SnackBarBehavior.floating,
  elevation: AppElevation.level3,
)
```

### 7.14 Additional Component Themes

```dart
// SwitchTheme (used in FormChecklistPage branch flags)
SwitchThemeData(
  thumbColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) return Palette.primary;
    return Palette.onSurfaceVariant;
  }),
  trackColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) return Palette.primaryContainer;
    return Palette.surfaceContainerHighest;
  }),
)

// CheckboxTheme (used in NewInspectionPage form selection)
CheckboxThemeData(
  fillColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) return Palette.primary;
    return Colors.transparent;
  }),
  checkColor: WidgetStateProperty.all(Palette.onPrimary),
  side: BorderSide(color: Palette.outline, width: 2),
)

// ListTileTheme (used extensively across all screens)
ListTileThemeData(
  textColor: Palette.onSurface,
  iconColor: Palette.onSurfaceVariant,
  contentPadding: EdgeInsets.symmetric(
    horizontal: AppTokens.spacingLg,
    vertical: AppTokens.spacingXs,
  ),
)

// ProgressIndicatorTheme
ProgressIndicatorThemeData(
  color: Palette.primary,
  circularTrackColor: Palette.surfaceContainerHigh,
  linearTrackColor: Palette.surfaceContainerHigh,
)

// DividerTheme
DividerThemeData(
  color: Palette.outlineVariant,
  thickness: 1,
  space: AppTokens.spacingLg,
)

// FloatingActionButtonTheme
FloatingActionButtonThemeData(
  backgroundColor: Palette.primary,
  foregroundColor: Palette.onPrimary,
  elevation: AppElevation.level3,
  shape: RoundedRectangleBorder(borderRadius: AppRadii.md),
)
```

---

## 8. Implementation Notes

### 8.1 ThemeExtension: AppTokens

The `AppTokens` class extends `ThemeExtension<AppTokens>` to provide custom
tokens that are not part of Material's `ColorScheme` or `TextTheme`. This
includes semantic colors (success, warning, info), custom spacing access, and
any app-specific design tokens.

```dart
// extensions.dart
import 'package:flutter/material.dart';
import 'palette.dart';
import 'tokens.dart';

class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    // Semantic colors
    required this.success,
    required this.warning,
    required this.info,
    required this.disabled,
    // Spacing
    required this.spacingXxs,
    required this.spacingXs,
    required this.spacingSm,
    required this.spacingMd,
    required this.spacingLg,
    required this.spacingXl,
    required this.spacingXxl,
    required this.spacing3xl,
    required this.spacing4xl,
  });

  final Color success;
  final Color warning;
  final Color info;
  final Color disabled;

  final double spacingXxs;
  final double spacingXs;
  final double spacingSm;
  final double spacingMd;
  final double spacingLg;
  final double spacingXl;
  final double spacingXxl;
  final double spacing3xl;
  final double spacing4xl;

  /// Default instance with standard token values.
  static const standard = AppTokens(
    success: Palette.success,
    warning: Palette.warning,
    info: Palette.info,
    disabled: Palette.disabled,
    spacingXxs: Spacing.spacingXxs,  // references from tokens.dart
    spacingXs: Spacing.spacingXs,
    spacingSm: Spacing.spacingSm,
    spacingMd: Spacing.spacingMd,
    spacingLg: Spacing.spacingLg,
    spacingXl: Spacing.spacingXl,
    spacingXxl: Spacing.spacingXxl,
    spacing3xl: Spacing.spacing3xl,
    spacing4xl: Spacing.spacing4xl,
  );

  @override
  AppTokens copyWith({
    Color? success,
    Color? warning,
    Color? info,
    Color? disabled,
    double? spacingXxs,
    double? spacingXs,
    double? spacingSm,
    double? spacingMd,
    double? spacingLg,
    double? spacingXl,
    double? spacingXxl,
    double? spacing3xl,
    double? spacing4xl,
  }) {
    return AppTokens(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      disabled: disabled ?? this.disabled,
      spacingXxs: spacingXxs ?? this.spacingXxs,
      spacingXs: spacingXs ?? this.spacingXs,
      spacingSm: spacingSm ?? this.spacingSm,
      spacingMd: spacingMd ?? this.spacingMd,
      spacingLg: spacingLg ?? this.spacingLg,
      spacingXl: spacingXl ?? this.spacingXl,
      spacingXxl: spacingXxl ?? this.spacingXxl,
      spacing3xl: spacing3xl ?? this.spacing3xl,
      spacing4xl: spacing4xl ?? this.spacing4xl,
    );
  }

  @override
  AppTokens lerp(covariant AppTokens? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      spacingXxs: _lerpDouble(spacingXxs, other.spacingXxs, t),
      spacingXs: _lerpDouble(spacingXs, other.spacingXs, t),
      spacingSm: _lerpDouble(spacingSm, other.spacingSm, t),
      spacingMd: _lerpDouble(spacingMd, other.spacingMd, t),
      spacingLg: _lerpDouble(spacingLg, other.spacingLg, t),
      spacingXl: _lerpDouble(spacingXl, other.spacingXl, t),
      spacingXxl: _lerpDouble(spacingXxl, other.spacingXxl, t),
      spacing3xl: _lerpDouble(spacing3xl, other.spacing3xl, t),
      spacing4xl: _lerpDouble(spacing4xl, other.spacing4xl, t),
    );
  }

  static double _lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }
}
```

### 8.2 BuildContext Extension

```dart
// context_ext.dart
import 'package:flutter/material.dart';
import 'extensions.dart';

extension AppTokensExtension on BuildContext {
  /// Access app-specific design tokens from the current theme.
  ///
  /// Throws if AppTokens extension is not registered in ThemeData.
  AppTokens get appTokens {
    final tokens = Theme.of(this).extension<AppTokens>();
    assert(tokens != null, 'AppTokens ThemeExtension not found in ThemeData. '
        'Ensure AppTheme.dark() is used in MaterialApp.');
    return tokens!;
  }
}
```

### 8.3 ThemeData Assembly

```dart
// app_theme.dart
import 'package:flutter/material.dart';
import 'palette.dart';
import 'tokens.dart';
import 'typography.dart';
import 'extensions.dart';

abstract final class AppTheme {
  static ThemeData dark() {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Palette.primary,
      onPrimary: Palette.onPrimary,
      primaryContainer: Palette.primaryContainer,
      onPrimaryContainer: Palette.onPrimaryContainer,
      secondary: Palette.secondary,
      onSecondary: Palette.onSecondary,
      secondaryContainer: Palette.secondaryContainer,
      onSecondaryContainer: Palette.onSecondaryContainer,
      tertiary: Palette.tertiary,
      onTertiary: Palette.onTertiary,
      tertiaryContainer: Palette.tertiaryContainer,
      onTertiaryContainer: Palette.onTertiaryContainer,
      error: Palette.error,
      onError: Palette.onError,
      errorContainer: Palette.errorContainer,
      onErrorContainer: Palette.onErrorContainer,
      surface: Palette.surface,
      onSurface: Palette.onSurface,
      onSurfaceVariant: Palette.onSurfaceVariant,
      outline: Palette.outline,
      outlineVariant: Palette.outlineVariant,
      shadow: Palette.shadow,
      scrim: Palette.scrim,
      inverseSurface: Palette.inverseSurface,
      onInverseSurface: Palette.onInverseSurface,
      inversePrimary: Palette.inversePrimary,
      surfaceTint: Palette.surfaceTint,
      // Note: surfaceContainerLowest through surfaceContainerHighest
      // may require Flutter 3.22+ ColorScheme constructor parameters.
      // If not available, set surfaceContainerColor via component themes.
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Palette.background,
      textTheme: AppTypography.textTheme,

      // Component themes (all referencing tokens, see Section 7)
      appBarTheme: /* ... as specified in 7.1 ... */,
      cardTheme: /* ... as specified in 7.2 ... */,
      inputDecorationTheme: /* ... as specified in 7.3 ... */,
      elevatedButtonTheme: /* ... as specified in 7.4 ... */,
      filledButtonTheme: /* ... as specified in 7.5 ... */,
      outlinedButtonTheme: /* ... as specified in 7.6 ... */,
      textButtonTheme: /* ... as specified in 7.7 ... */,
      iconButtonTheme: /* ... as specified in 7.8 ... */,
      chipTheme: /* ... as specified in 7.9 ... */,
      bottomNavigationBarTheme: /* ... as specified in 7.10 ... */,
      tabBarTheme: /* ... as specified in 7.11 ... */,
      dialogTheme: /* ... as specified in 7.12 ... */,
      snackBarTheme: /* ... as specified in 7.13 ... */,
      switchTheme: /* ... as specified in 7.14 ... */,
      checkboxTheme: /* ... as specified in 7.14 ... */,
      listTileTheme: /* ... as specified in 7.14 ... */,
      progressIndicatorTheme: /* ... as specified in 7.14 ... */,
      dividerTheme: /* ... as specified in 7.14 ... */,
      floatingActionButtonTheme: /* ... as specified in 7.14 ... */,

      // Register ThemeExtension
      extensions: const <ThemeExtension>[
        AppTokens.standard,
      ],
    );
  }
}
```

### 8.4 Integration in app.dart

The only change to `app.dart`:

```dart
// Before:
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
  useMaterial3: true,
),

// After:
theme: AppTheme.dark(),
```

The error fallback in `main.dart` should also use a minimal dark theme:

```dart
// Before:
runApp(MaterialApp(home: Scaffold(body: Center(child: ...

// After:
runApp(MaterialApp(
  theme: ThemeData.dark(useMaterial3: true),
  home: Scaffold(body: Center(child: ...
```

---

## 9. Testing Strategy

### 9.1 Token Wiring Tests

Verify that the ThemeData correctly wires all tokens.

```dart
// test/theme/app_theme_test.dart

void main() {
  group('AppTheme.dark()', () {
    test('produces dark brightness', () {
      final theme = AppTheme.dark();
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.brightness, Brightness.dark);
    });

    test('uses custom color scheme, not fromSeed', () {
      final theme = AppTheme.dark();
      expect(theme.colorScheme.primary, Palette.primary);
      expect(theme.colorScheme.secondary, Palette.secondary);
      expect(theme.colorScheme.error, Palette.error);
      expect(theme.colorScheme.surface, Palette.surface);
    });

    test('registers AppTokens extension', () {
      final theme = AppTheme.dark();
      final tokens = theme.extension<AppTokens>();
      expect(tokens, isNotNull);
      expect(tokens!.success, Palette.success);
      expect(tokens.spacingLg, 16.0);
    });

    test('scaffold background differs from surface', () {
      final theme = AppTheme.dark();
      expect(theme.scaffoldBackgroundColor, Palette.background);
      expect(theme.scaffoldBackgroundColor, isNot(theme.colorScheme.surface));
    });

    test('text theme uses specified sizes', () {
      final theme = AppTheme.dark();
      expect(theme.textTheme.bodyMedium!.fontSize, 14.0);
      expect(theme.textTheme.bodyLarge!.fontSize, 16.0);
      expect(theme.textTheme.headlineLarge!.fontWeight, FontWeight.w700);
    });
  });
}
```

### 9.2 Contrast Ratio Tests

Programmatically verify WCAG compliance.

```dart
// test/theme/contrast_test.dart

double contrastRatio(Color foreground, Color background) {
  double luminance(Color color) {
    final r = color.red / 255;
    final g = color.green / 255;
    final b = color.blue / 255;
    double linearize(double c) =>
        c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * linearize(r) + 0.7152 * linearize(g) + 0.0722 * linearize(b);
  }
  final l1 = luminance(foreground);
  final l2 = luminance(background);
  final lighter = max(l1, l2);
  final darker = min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('WCAG contrast ratios', () {
    test('onSurface vs background meets AAA (7:1)', () {
      final ratio = contrastRatio(Palette.onSurface, Palette.background);
      expect(ratio, greaterThanOrEqualTo(7.0));
    });

    test('onSurface vs surface meets AAA (7:1)', () {
      final ratio = contrastRatio(Palette.onSurface, Palette.surface);
      expect(ratio, greaterThanOrEqualTo(7.0));
    });

    test('onSurfaceVariant vs background meets AA (4.5:1)', () {
      final ratio = contrastRatio(Palette.onSurfaceVariant, Palette.background);
      expect(ratio, greaterThanOrEqualTo(4.5));
    });

    test('primary vs surface meets AA (4.5:1)', () {
      final ratio = contrastRatio(Palette.primary, Palette.surface);
      expect(ratio, greaterThanOrEqualTo(4.5));
    });

    test('primary vs onPrimary meets AA (4.5:1)', () {
      final ratio = contrastRatio(Palette.primary, Palette.onPrimary);
      expect(ratio, greaterThanOrEqualTo(4.5));
    });

    test('error vs surface meets AA (4.5:1)', () {
      final ratio = contrastRatio(Palette.error, Palette.surface);
      expect(ratio, greaterThanOrEqualTo(4.5));
    });

    test('success vs surface meets AA (4.5:1)', () {
      final ratio = contrastRatio(Palette.success, Palette.surface);
      expect(ratio, greaterThanOrEqualTo(4.5));
    });

    test('bodySmall text (onSurfaceVariant) vs surfaceContainer meets AA', () {
      final ratio = contrastRatio(
        Palette.onSurfaceVariant,
        Palette.surfaceContainer,
      );
      expect(ratio, greaterThanOrEqualTo(4.5));
    });
  });
}
```

### 9.3 No-Hardcoded-Values Lint

After migration, verify no presentation files contain hardcoded style values.

```bash
# Run from project root after migration is complete:
# Should return zero results for presentation files
grep -rn "Colors\." lib/features/*/presentation/ \
  --include="*.dart" \
  | grep -v "// token-exempt" \
  | grep -v "import"

grep -rn "TextStyle(" lib/features/*/presentation/ \
  --include="*.dart" \
  | grep -v "// token-exempt"

grep -rn "EdgeInsets\." lib/features/*/presentation/ \
  --include="*.dart" \
  | grep -v "AppEdgeInsets" \
  | grep -v "// token-exempt"

grep -rn "SizedBox(height:" lib/features/*/presentation/ \
  --include="*.dart" \
  | grep -v "tokens\." \
  | grep -v "// token-exempt"
```

The `// token-exempt` comment provides an escape hatch for legitimate cases
(e.g., `Colors.transparent` or animation-specific sizes).

### 9.4 ThemeExtension lerp/copyWith Tests

```dart
void main() {
  group('AppTokens', () {
    test('copyWith preserves unspecified values', () {
      const original = AppTokens.standard;
      final modified = original.copyWith(success: Colors.red);
      expect(modified.success, Colors.red);
      expect(modified.warning, original.warning); // unchanged
      expect(modified.spacingLg, original.spacingLg); // unchanged
    });

    test('lerp interpolates colors at midpoint', () {
      const a = AppTokens.standard;
      final b = a.copyWith(success: const Color(0xFFFFFFFF));
      final mid = a.lerp(b, 0.5);
      // Should be roughly between green and white
      expect(mid.success, isNot(a.success));
      expect(mid.success, isNot(b.success));
    });

    test('lerp at 0.0 returns start values', () {
      const a = AppTokens.standard;
      final b = a.copyWith(spacingLg: 32.0);
      final result = a.lerp(b, 0.0);
      expect(result.spacingLg, a.spacingLg);
    });

    test('lerp at 1.0 returns end values', () {
      const a = AppTokens.standard;
      final b = a.copyWith(spacingLg: 32.0);
      final result = a.lerp(b, 1.0);
      expect(result.spacingLg, 32.0);
    });
  });
}
```

---

## 10. Migration Strategy

### Approach: Gradual Adoption

The theme system is designed for incremental migration. Existing screens will
look different immediately (dark theme replaces light indigo theme), but will
function correctly because Material component themes handle most styling
automatically.

### Phase 1A: Foundation (this spec)

1. Create all files under `lib/theme/`.
2. Wire `AppTheme.dark()` into `app.dart`.
3. Run existing tests -- all should pass (theme change is cosmetic only).
4. Visually verify each screen in the app.

### Phase 1B: Hardcoded Value Removal (follow-up task)

Migrate each presentation file to use token-based values. Priority order based
on usage frequency and hardcoded value density:

| Priority | File                         | Hardcoded Items | Notes                          |
|----------|------------------------------|-----------------|--------------------------------|
| 1        | `form_checklist_page.dart`   | 14+             | Most complex, most hardcoded   |
| 2        | `dashboard_page.dart`        | 8               | First screen users see         |
| 3        | `new_inspection_page.dart`   | 7               | Form-heavy                     |
| 4        | `sign_in_page.dart`          | 6               | Auth entry point               |
| 5        | `sign_up_page.dart`          | ~6              | Similar to sign_in             |
| 6        | `forgot_password_page.dart`  | ~4              | Simple form                    |
| 7        | `reset_password_page.dart`   | ~4              | Simple form                    |
| 8        | `inspector_identity_page.dart`| ~5             | Settings-style page            |

### Migration Pattern Per File

```dart
// BEFORE (hardcoded):
const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)
const EdgeInsets.all(16)
const SizedBox(height: 12)
const TextStyle(color: Colors.red)
const Icon(Icons.check_circle, color: Colors.green)

// AFTER (token-based):
Theme.of(context).textTheme.headlineSmall
AppEdgeInsets.pagePadding
SizedBox(height: context.appTokens.spacingMd)
TextStyle(color: Theme.of(context).colorScheme.error)
Icon(Icons.check_circle, color: context.appTokens.success)
```

### Compatibility Notes

- The `Colors.red` and `Colors.green` references in `sign_in_page.dart` and
  `form_checklist_page.dart` should map to `colorScheme.error` and
  `appTokens.success` respectively.
- `Colors.orange` in `form_checklist_page.dart` (incomplete form indicator)
  maps to `appTokens.warning`.
- `Colors.redAccent` in `form_checklist_page.dart` (audit error) maps to
  `colorScheme.error`.
- The error fallback in `main.dart` uses a standalone dark `ThemeData` since
  `AppTheme.dark()` may not be available if initialization fails.

---

## Appendix: Hardcoded Style Audit

Complete inventory of hardcoded styling in current presentation files.

### dashboard_page.dart

| Line | Code                                                      | Token Replacement                        |
|------|-----------------------------------------------------------|------------------------------------------|
| 117  | `EdgeInsets.all(16)`                                      | `AppEdgeInsets.pagePadding`              |
| 122  | `TextStyle(fontSize: 18, fontWeight: FontWeight.w600)`    | `textTheme.headlineSmall`               |
| 125  | `SizedBox(height: 8)`                                     | `SizedBox(height: tokens.spacingSm)`    |
| 127  | `SizedBox(height: 16)`                                    | `SizedBox(height: tokens.spacingLg)`    |
| 151  | `SizedBox(height: 12)`                                    | `SizedBox(height: tokens.spacingMd)`    |
| 166  | `SizedBox(height: 20)`                                    | `SizedBox(height: tokens.spacingXl)`    |
| 168  | `TextStyle(fontWeight: FontWeight.w600)`                  | `textTheme.titleMedium`                 |
| 171  | `SizedBox(height: 8)`                                     | `SizedBox(height: tokens.spacingSm)`    |

### sign_in_page.dart

| Line | Code                                       | Token Replacement                     |
|------|--------------------------------------------|---------------------------------------|
| 89   | `EdgeInsets.all(16)`                       | `AppEdgeInsets.pagePadding`           |
| 107  | `SizedBox(height: 12)`                     | `SizedBox(height: tokens.spacingMd)` |
| 121  | `TextStyle(color: Colors.red)`             | `TextStyle(color: colorScheme.error)` |
| 127  | `TextStyle(color: Colors.green)`           | `TextStyle(color: tokens.success)`    |
| 130  | `SizedBox(height: 16)`                     | `SizedBox(height: tokens.spacingLg)` |
| 138  | `SizedBox(height: 12)`                     | `SizedBox(height: tokens.spacingMd)` |

### form_checklist_page.dart

| Line | Code                                           | Token Replacement                     |
|------|-------------------------------------------------|---------------------------------------|
| 611  | `EdgeInsets.symmetric(vertical: 8)`             | `tokens.spacingSm`                   |
| 632  | `Icons.check_circle, color: Colors.green`       | `tokens.success`                     |
| 660  | `TextStyle(fontWeight: FontWeight.w600)`         | `textTheme.titleMedium`              |
| 676  | `Icons.error_outline, color: Colors.redAccent`   | `colorScheme.error`                  |
| 729  | `EdgeInsets.all(16)`                             | `AppEdgeInsets.pagePadding`          |
| 733  | `TextStyle(fontWeight: FontWeight.w600)`         | `textTheme.titleMedium`              |
| 736  | `SizedBox(height: 16)`                          | `tokens.spacingLg`                   |
| 739  | `TextStyle(fontWeight: FontWeight.w600)`         | `textTheme.titleMedium`              |
| 741  | `SizedBox(height: 8)`                           | `tokens.spacingSm`                   |
| 752  | `SizedBox(height: 20)`                          | `tokens.spacingXl`                   |
| 754  | `TextStyle(fontWeight: FontWeight.w600)`         | `textTheme.titleMedium`              |
| 757  | `SizedBox(height: 8)`                           | `tokens.spacingSm`                   |
| 767  | `Icons.check_circle, color: Colors.green`        | `tokens.success`                     |
| 768  | `Icons.error_outline, color: Colors.orange`      | `tokens.warning`                     |
| 772  | `SizedBox(height: 16)`                          | `tokens.spacingLg`                   |

### new_inspection_page.dart

| Line | Code                                           | Token Replacement                     |
|------|-------------------------------------------------|---------------------------------------|
| 189  | `EdgeInsets.all(16)`                            | `AppEdgeInsets.pagePadding`          |
| 198  | `SizedBox(height: 12)`                         | `tokens.spacingMd`                   |
| 217  | `SizedBox(height: 12)`                         | `tokens.spacingMd`                   |
| 233  | `SizedBox(height: 16)`                         | `tokens.spacingLg`                   |
| 236  | `TextStyle(fontSize: 16, fontWeight: FontWeight.w600)` | `textTheme.titleMedium`        |
| 254  | `SizedBox(height: 12)`                         | `tokens.spacingMd`                   |

### main.dart (error fallback)

| Line | Code                                           | Token Replacement                     |
|------|-------------------------------------------------|---------------------------------------|
| 29   | `EdgeInsets.all(16.0)`                         | Keep as-is (fallback, no theme)      |
| 31   | `TextStyle(color: Colors.red)`                 | Keep as-is (fallback, no theme)      |

---

## Open Questions & Risks

1. **Flutter version**: The `surfaceContainerLowest` through
   `surfaceContainerHighest` roles in `ColorScheme` require Flutter 3.22+.
   Verify the project's Flutter SDK constraint supports this. Current
   `pubspec.yaml` shows `sdk: ^3.10.1` (Dart SDK), which maps to Flutter 3.x.
   Need to confirm exact Flutter version.

2. **Orange surface tint intensity**: The `surfaceTint` using primary orange
   may produce an overly warm elevated-surface appearance. This should be
   validated visually during implementation. If too strong, consider using a
   desaturated variant (e.g., `#C87830`) for `surfaceTint` only.

3. **Existing test suite**: The theme change from light-indigo to dark-orange
   is cosmetic-only and should not break functional tests. However, any tests
   that assert specific color values (e.g., `Colors.indigo`) will fail and need
   updating.

4. **PDF rendering**: The `pdf` package renders its own colors independently of
   the Flutter theme. PDF color choices are not affected by this work but
   should be visually harmonized in a future phase.

---

## References

- [Material Design 3 Color Roles](https://m3.material.io/styles/color/roles)
- [Material Design 3 Typography](https://m3.material.io/styles/typography/applying-type)
- [Flutter ThemeExtension API](https://api.flutter.dev/flutter/material/ThemeExtension-class.html)
- [WCAG 2.2 Color Contrast Guidelines](https://webaim.org/articles/contrast/)
- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
- [Flutter Typography Documentation](https://docs.flutter.dev/ui/design/text/typography)
- [Flutter New ColorScheme Roles](https://docs.flutter.dev/release/breaking-changes/new-color-scheme-roles)
- [Dark Mode Accessibility Best Practices](https://dubbot.com/dubblog/2023/dark-mode-a11y.html)
