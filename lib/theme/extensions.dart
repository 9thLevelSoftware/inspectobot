import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'palette.dart';
import 'tokens.dart';
import 'typography.dart';

/// App-specific design tokens exposed as a [ThemeExtension].
///
/// Provides semantic colors, spacing, edge insets, border radii, elevation, and
/// typography helpers that are not covered by Material's [ColorScheme] or
/// [TextTheme].
///
/// Register via `ThemeData.extensions` and access with `context.appTokens`
/// (see `context_ext.dart`).
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
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
    // Edge insets
    required this.pagePadding,
    required this.cardPadding,
    required this.sectionGap,
    required this.inputPadding,
    // Border radii
    required this.radiusNone,
    required this.radiusXs,
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.radiusFull,
    // Elevation
    required this.elevation0,
    required this.elevation1,
    required this.elevation2,
    required this.elevation3,
    required this.elevation4,
    required this.elevation5,
    // Semantic colors
    required this.success,
    required this.warning,
    required this.info,
    required this.disabled,
    // Typography helpers
    required this.sectionHeader,
    required this.fieldLabel,
    required this.statusBadge,
    required this.timestamp,
  });

  // ---------------------------------------------------------------------------
  // Spacing
  // ---------------------------------------------------------------------------
  final double spacingXxs;
  final double spacingXs;
  final double spacingSm;
  final double spacingMd;
  final double spacingLg;
  final double spacingXl;
  final double spacingXxl;
  final double spacing3xl;
  final double spacing4xl;

  // ---------------------------------------------------------------------------
  // Edge insets
  // ---------------------------------------------------------------------------
  final EdgeInsets pagePadding;
  final EdgeInsets cardPadding;
  final EdgeInsets sectionGap;
  final EdgeInsets inputPadding;

  // ---------------------------------------------------------------------------
  // Border radii
  // ---------------------------------------------------------------------------
  final BorderRadius radiusNone;
  final BorderRadius radiusXs;
  final BorderRadius radiusSm;
  final BorderRadius radiusMd;
  final BorderRadius radiusLg;
  final BorderRadius radiusFull;

  // ---------------------------------------------------------------------------
  // Elevation
  // ---------------------------------------------------------------------------
  final double elevation0;
  final double elevation1;
  final double elevation2;
  final double elevation3;
  final double elevation4;
  final double elevation5;

  // ---------------------------------------------------------------------------
  // Semantic colors
  // ---------------------------------------------------------------------------
  final Color success;
  final Color warning;
  final Color info;
  final Color disabled;

  // ---------------------------------------------------------------------------
  // Typography helpers
  // ---------------------------------------------------------------------------
  final TextStyle sectionHeader;
  final TextStyle fieldLabel;
  final TextStyle statusBadge;
  final TextStyle timestamp;

  // ---------------------------------------------------------------------------
  // Factory
  // ---------------------------------------------------------------------------

  /// Dark theme token set. All values sourced from [Palette], [AppSpacing],
  /// [AppEdgeInsets], [AppRadii], [AppElevation], and [AppTypography].
  factory AppTokens.dark() {
    return AppTokens(
      // Spacing
      spacingXxs: AppSpacing.spacingXxs,
      spacingXs: AppSpacing.spacingXs,
      spacingSm: AppSpacing.spacingSm,
      spacingMd: AppSpacing.spacingMd,
      spacingLg: AppSpacing.spacingLg,
      spacingXl: AppSpacing.spacingXl,
      spacingXxl: AppSpacing.spacingXxl,
      spacing3xl: AppSpacing.spacing3xl,
      spacing4xl: AppSpacing.spacing4xl,
      // Edge insets
      pagePadding: AppEdgeInsets.pagePadding,
      cardPadding: AppEdgeInsets.cardPadding,
      sectionGap: AppEdgeInsets.sectionGap,
      inputPadding: AppEdgeInsets.inputPadding,
      // Border radii
      radiusNone: AppRadii.none,
      radiusXs: AppRadii.xs,
      radiusSm: AppRadii.sm,
      radiusMd: AppRadii.md,
      radiusLg: AppRadii.lg,
      radiusFull: AppRadii.full,
      // Elevation
      elevation0: AppElevation.level0,
      elevation1: AppElevation.level1,
      elevation2: AppElevation.level2,
      elevation3: AppElevation.level3,
      elevation4: AppElevation.level4,
      elevation5: AppElevation.level5,
      // Semantic colors
      success: Palette.success,
      warning: Palette.warning,
      info: Palette.info,
      disabled: Palette.disabled,
      // Typography helpers
      sectionHeader: AppTypography.sectionHeader,
      fieldLabel: AppTypography.fieldLabel,
      statusBadge: AppTypography.statusBadge,
      timestamp: AppTypography.timestamp,
    );
  }

  // ---------------------------------------------------------------------------
  // ThemeExtension overrides
  // ---------------------------------------------------------------------------

  @override
  AppTokens copyWith({
    // Spacing
    double? spacingXxs,
    double? spacingXs,
    double? spacingSm,
    double? spacingMd,
    double? spacingLg,
    double? spacingXl,
    double? spacingXxl,
    double? spacing3xl,
    double? spacing4xl,
    // Edge insets
    EdgeInsets? pagePadding,
    EdgeInsets? cardPadding,
    EdgeInsets? sectionGap,
    EdgeInsets? inputPadding,
    // Border radii
    BorderRadius? radiusNone,
    BorderRadius? radiusXs,
    BorderRadius? radiusSm,
    BorderRadius? radiusMd,
    BorderRadius? radiusLg,
    BorderRadius? radiusFull,
    // Elevation
    double? elevation0,
    double? elevation1,
    double? elevation2,
    double? elevation3,
    double? elevation4,
    double? elevation5,
    // Semantic colors
    Color? success,
    Color? warning,
    Color? info,
    Color? disabled,
    // Typography helpers
    TextStyle? sectionHeader,
    TextStyle? fieldLabel,
    TextStyle? statusBadge,
    TextStyle? timestamp,
  }) {
    return AppTokens(
      spacingXxs: spacingXxs ?? this.spacingXxs,
      spacingXs: spacingXs ?? this.spacingXs,
      spacingSm: spacingSm ?? this.spacingSm,
      spacingMd: spacingMd ?? this.spacingMd,
      spacingLg: spacingLg ?? this.spacingLg,
      spacingXl: spacingXl ?? this.spacingXl,
      spacingXxl: spacingXxl ?? this.spacingXxl,
      spacing3xl: spacing3xl ?? this.spacing3xl,
      spacing4xl: spacing4xl ?? this.spacing4xl,
      pagePadding: pagePadding ?? this.pagePadding,
      cardPadding: cardPadding ?? this.cardPadding,
      sectionGap: sectionGap ?? this.sectionGap,
      inputPadding: inputPadding ?? this.inputPadding,
      radiusNone: radiusNone ?? this.radiusNone,
      radiusXs: radiusXs ?? this.radiusXs,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      radiusFull: radiusFull ?? this.radiusFull,
      elevation0: elevation0 ?? this.elevation0,
      elevation1: elevation1 ?? this.elevation1,
      elevation2: elevation2 ?? this.elevation2,
      elevation3: elevation3 ?? this.elevation3,
      elevation4: elevation4 ?? this.elevation4,
      elevation5: elevation5 ?? this.elevation5,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      disabled: disabled ?? this.disabled,
      sectionHeader: sectionHeader ?? this.sectionHeader,
      fieldLabel: fieldLabel ?? this.fieldLabel,
      statusBadge: statusBadge ?? this.statusBadge,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  AppTokens lerp(covariant AppTokens? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      // Spacing
      spacingXxs: lerpDouble(spacingXxs, other.spacingXxs, t)!,
      spacingXs: lerpDouble(spacingXs, other.spacingXs, t)!,
      spacingSm: lerpDouble(spacingSm, other.spacingSm, t)!,
      spacingMd: lerpDouble(spacingMd, other.spacingMd, t)!,
      spacingLg: lerpDouble(spacingLg, other.spacingLg, t)!,
      spacingXl: lerpDouble(spacingXl, other.spacingXl, t)!,
      spacingXxl: lerpDouble(spacingXxl, other.spacingXxl, t)!,
      spacing3xl: lerpDouble(spacing3xl, other.spacing3xl, t)!,
      spacing4xl: lerpDouble(spacing4xl, other.spacing4xl, t)!,
      // Edge insets
      pagePadding: EdgeInsets.lerp(pagePadding, other.pagePadding, t)!,
      cardPadding: EdgeInsets.lerp(cardPadding, other.cardPadding, t)!,
      sectionGap: EdgeInsets.lerp(sectionGap, other.sectionGap, t)!,
      inputPadding: EdgeInsets.lerp(inputPadding, other.inputPadding, t)!,
      // Border radii
      radiusNone: BorderRadius.lerp(radiusNone, other.radiusNone, t)!,
      radiusXs: BorderRadius.lerp(radiusXs, other.radiusXs, t)!,
      radiusSm: BorderRadius.lerp(radiusSm, other.radiusSm, t)!,
      radiusMd: BorderRadius.lerp(radiusMd, other.radiusMd, t)!,
      radiusLg: BorderRadius.lerp(radiusLg, other.radiusLg, t)!,
      radiusFull: BorderRadius.lerp(radiusFull, other.radiusFull, t)!,
      // Elevation
      elevation0: lerpDouble(elevation0, other.elevation0, t)!,
      elevation1: lerpDouble(elevation1, other.elevation1, t)!,
      elevation2: lerpDouble(elevation2, other.elevation2, t)!,
      elevation3: lerpDouble(elevation3, other.elevation3, t)!,
      elevation4: lerpDouble(elevation4, other.elevation4, t)!,
      elevation5: lerpDouble(elevation5, other.elevation5, t)!,
      // Semantic colors
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      // Typography helpers
      sectionHeader: TextStyle.lerp(sectionHeader, other.sectionHeader, t)!,
      fieldLabel: TextStyle.lerp(fieldLabel, other.fieldLabel, t)!,
      statusBadge: TextStyle.lerp(statusBadge, other.statusBadge, t)!,
      timestamp: TextStyle.lerp(timestamp, other.timestamp, t)!,
    );
  }
}
