import 'package:flutter/material.dart';

import '../../theme/context_ext.dart';

/// A card that wraps a single repetition of a [RepeatingFieldGroup].
///
/// Displays a header with "{label} {index}" and renders [child] below a
/// subtle divider. Uses the app's card theming for consistent styling.
class RepeatingGroupCard extends StatelessWidget {
  const RepeatingGroupCard({
    super.key,
    required this.label,
    required this.index,
    required this.child,
  });

  /// The group label, e.g. "Attempt".
  final String label;

  /// 1-indexed repetition number displayed in the header.
  final int index;

  /// The content to render inside this card (typically form fields).
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label $index',
              style: tokens.sectionHeader,
            ),
            Divider(
              height: tokens.spacingLg,
              thickness: 1,
              color: colorScheme.outlineVariant,
            ),
            child,
          ],
        ),
      ),
    );
  }
}
