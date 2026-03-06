import 'package:flutter/material.dart';

import 'package:inspectobot/theme/theme.dart';

/// A centered placeholder shown when a list or screen has no content.
///
/// Optionally displays a large [icon] and an action [FilledButton].
class EmptyState extends StatelessWidget {
  static const double _iconSize = 64;

  const EmptyState({
    super.key,
    required this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  /// Descriptive text explaining why the screen is empty.
  final String message;

  /// Optional large icon displayed above the [message].
  final IconData? icon;

  /// Label for the optional action button.
  final String? actionLabel;

  /// Called when the action button is pressed.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;

    return Padding(
      padding: AppEdgeInsets.pagePadding,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon!,
                size: _iconSize,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              SizedBox(height: tokens.spacingLg),
            ],
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: tokens.spacingLg),
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
