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
  });

  final String label;
  final StatusBadgeType type;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final colorScheme = Theme.of(context).colorScheme;

    final (Color background, Color foreground) = switch (type) {
      StatusBadgeType.success => (
          tokens.success.withValues(alpha: 0.15),
          tokens.success,
        ),
      StatusBadgeType.warning => (
          tokens.warning.withValues(alpha: 0.15),
          tokens.warning,
        ),
      StatusBadgeType.error => (
          colorScheme.error.withValues(alpha: 0.15),
          colorScheme.error,
        ),
      StatusBadgeType.info => (
          tokens.info.withValues(alpha: 0.15),
          tokens.info,
        ),
      StatusBadgeType.neutral => (
          colorScheme.surfaceContainerHigh,
          colorScheme.onSurface,
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacingSm,
        vertical: tokens.spacingXxs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: tokens.radiusFull,
      ),
      child: Text(
        label,
        style: tokens.statusBadge.copyWith(color: foreground),
      ),
    );
  }
}
