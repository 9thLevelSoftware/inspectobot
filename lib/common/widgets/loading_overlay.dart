import 'package:flutter/material.dart';

import 'package:inspectobot/theme/theme.dart';

/// Overlays a semi-transparent scrim and spinner on top of [child] while
/// [isLoading] is true.
///
/// Touch events on [child] are blocked during loading via [IgnorePointer].
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  /// When true the overlay scrim and progress indicator are shown.
  final bool isLoading;

  /// The content beneath the overlay.
  final Widget child;

  /// Optional status message displayed below the spinner.
  final String? message;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;

    return Stack(
      children: [
        IgnorePointer(
          ignoring: isLoading,
          child: child,
        ),
        if (isLoading)
          Positioned.fill(
            child: ColoredBox(
              color: Theme.of(context)
                  .colorScheme
                  .scrim
                  .withValues(alpha: 0.5),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    if (message != null) ...[
                      SizedBox(height: tokens.spacingLg),
                      Text(
                        message!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
