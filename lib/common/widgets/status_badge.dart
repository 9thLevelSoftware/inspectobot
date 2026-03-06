import 'package:flutter/material.dart';

import 'package:inspectobot/theme/theme.dart';

/// Visual type for [StatusBadge].
enum StatusBadgeType { success, warning, error, info, neutral }

/// A pill-shaped badge that displays a status label with a semantic color.
///
/// Colors are sourced from [AppTokens] semantic colors and the theme's
/// [ColorScheme] -- no hardcoded values.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.type = StatusBadgeType.neutral,
    this.highContrast = false,
  });

  final String label;
  final StatusBadgeType type;

  /// When `true`, uses fully opaque semantic colors with a border for outdoor
  /// visibility. Text foreground is chosen for maximum contrast.
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final colorScheme = Theme.of(context).colorScheme;

    final (Color background, Color foreground, Color? borderColor) =
        highContrast
            ? _highContrastColors(tokens, colorScheme)
            : _defaultColors(tokens, colorScheme);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacingSm,
        vertical: tokens.spacingXxs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: tokens.radiusFull,
        border: borderColor != null
            ? Border.all(color: borderColor)
            : null,
      ),
      child: Text(
        label,
        style: tokens.statusBadge.copyWith(color: foreground),
      ),
    );
  }

  (Color background, Color foreground, Color? borderColor) _defaultColors(
    AppTokens tokens,
    ColorScheme colorScheme,
  ) {
    return switch (type) {
      StatusBadgeType.success => (
          tokens.success.withValues(alpha: 0.15),
          tokens.success,
          null,
        ),
      StatusBadgeType.warning => (
          tokens.warning.withValues(alpha: 0.15),
          tokens.warning,
          null,
        ),
      StatusBadgeType.error => (
          colorScheme.error.withValues(alpha: 0.15),
          colorScheme.error,
          null,
        ),
      StatusBadgeType.info => (
          tokens.info.withValues(alpha: 0.15),
          tokens.info,
          null,
        ),
      StatusBadgeType.neutral => (
          colorScheme.surfaceContainerHigh,
          colorScheme.onSurface,
          null,
        ),
    };
  }

  (Color background, Color foreground, Color borderColor) _highContrastColors(
    AppTokens tokens,
    ColorScheme colorScheme,
  ) {
    final Color semanticColor = switch (type) {
      StatusBadgeType.success => tokens.success,
      StatusBadgeType.warning => tokens.warning,
      StatusBadgeType.error => colorScheme.error,
      StatusBadgeType.info => tokens.info,
      StatusBadgeType.neutral => colorScheme.surfaceContainerHigh,
    };
    final Color fg = switch (type) {
      StatusBadgeType.neutral => colorScheme.onSurface,
      _ => Palette.onPrimary,
    };
    return (
      semanticColor,
      fg,
      semanticColor.withValues(alpha: 0.8),
    );
  }
}
