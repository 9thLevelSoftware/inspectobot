import 'package:flutter/material.dart';

import 'package:inspectobot/theme/theme.dart';

/// Visual severity for an [ErrorBanner].
enum ErrorBannerType {
  /// Critical error -- uses [ColorScheme.error].
  error,

  /// Positive confirmation -- uses [AppTokens.success].
  success,

  /// Neutral information -- uses [AppTokens.info].
  info,

  /// Non-blocking caution -- uses [AppTokens.warning].
  warning,
}

/// An inline feedback banner with a leading icon and message text.
///
/// Colors are derived from the current theme's semantic tokens so the banner
/// stays consistent with the rest of the UI.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({
    super.key,
    required this.message,
    this.type = ErrorBannerType.error,
  });

  /// The feedback message to display.
  final String message;

  /// Controls the icon and text color.
  final ErrorBannerType type;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final (IconData icon, Color color) = _resolve(context, tokens);

    return Padding(
      padding: EdgeInsets.only(top: tokens.spacingMd),
      child: Row(
        children: [
          Icon(icon, color: color),
          SizedBox(width: tokens.spacingSm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }

  (IconData, Color) _resolve(BuildContext context, AppTokens tokens) {
    return switch (type) {
      ErrorBannerType.error => (
          Icons.error_outline,
          Theme.of(context).colorScheme.error,
        ),
      ErrorBannerType.success => (
          Icons.check_circle_outline,
          tokens.success,
        ),
      ErrorBannerType.info => (
          Icons.info_outline,
          tokens.info,
        ),
      ErrorBannerType.warning => (
          Icons.warning_amber_outlined,
          tokens.warning,
        ),
    };
  }
}
