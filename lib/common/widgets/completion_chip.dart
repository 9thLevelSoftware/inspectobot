import 'package:flutter/material.dart';

import 'package:inspectobot/theme/theme.dart';

/// A chip that displays a completion fraction (e.g. "3/5") with color feedback.
///
/// Uses success color from [AppTokens] when fully complete, otherwise uses the
/// theme's primary color.
class CompletionChip extends StatelessWidget {
  const CompletionChip({
    super.key,
    required this.completed,
    required this.total,
    this.label,
  });

  final int completed;
  final int total;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final colorScheme = Theme.of(context).colorScheme;
    final isComplete = completed == total;

    final accentColor = isComplete ? tokens.success : colorScheme.primary;

    final text = label != null ? '$completed/$total $label' : '$completed/$total';

    return Chip(
      label: Text(text),
      backgroundColor: accentColor.withValues(alpha: 0.15),
      side: BorderSide(color: accentColor),
      labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: accentColor,
          ),
    );
  }
}
