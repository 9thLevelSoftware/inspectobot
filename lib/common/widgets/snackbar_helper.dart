import 'package:flutter/material.dart';

import 'package:inspectobot/theme/theme.dart';

/// Visual severity for snack-bar messages.
enum AppSnackBarType {
  /// Critical error.
  error,

  /// Positive confirmation.
  success,

  /// Neutral information.
  info,

  /// Non-blocking caution.
  warning,
}

/// Convenience helper for showing themed [SnackBar]s.
///
/// Inherits visual properties (background, shape, behavior, elevation) from the
/// app's [SnackBarTheme]. Adds a leading icon whose color matches the message
/// severity.
abstract final class AppSnackBar {
  /// Shows a themed [SnackBar] with a leading icon.
  static void show(
    BuildContext context,
    String message, {
    AppSnackBarType type = AppSnackBarType.info,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tokens = theme.extension<AppTokens>()!;
    final iconColor = _iconColorFor(type, colorScheme, tokens);
    final icon = _iconFor(type);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 4),
          content: Row(
            children: [
              Icon(icon, color: iconColor),
              SizedBox(width: AppSpacing.spacingSm),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: colorScheme.onInverseSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  /// Shows an error snack bar.
  static void error(BuildContext context, String message) =>
      show(context, message, type: AppSnackBarType.error);

  /// Shows a success snack bar.
  static void success(BuildContext context, String message) =>
      show(context, message, type: AppSnackBarType.success);

  /// Shows an informational snack bar.
  static void info(BuildContext context, String message) =>
      show(context, message, type: AppSnackBarType.info);

  /// Shows a warning snack bar.
  static void warning(BuildContext context, String message) =>
      show(context, message, type: AppSnackBarType.warning);

  static Color _iconColorFor(
    AppSnackBarType type,
    ColorScheme colorScheme,
    AppTokens tokens,
  ) {
    return switch (type) {
      AppSnackBarType.error => colorScheme.error,
      AppSnackBarType.success => tokens.success,
      AppSnackBarType.info => tokens.info,
      AppSnackBarType.warning => tokens.warning,
    };
  }

  static IconData _iconFor(AppSnackBarType type) {
    return switch (type) {
      AppSnackBarType.error => Icons.error_outline,
      AppSnackBarType.success => Icons.check_circle_outline,
      AppSnackBarType.info => Icons.info_outline,
      AppSnackBarType.warning => Icons.warning_amber_outlined,
    };
  }
}
