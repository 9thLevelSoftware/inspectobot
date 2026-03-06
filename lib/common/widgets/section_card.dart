import 'package:flutter/material.dart';

import 'package:inspectobot/theme/theme.dart';

/// A themed card that optionally displays a title above its [child].
///
/// Inherits all visual properties (color, elevation, shape, margin) from the
/// app's [CardTheme] so callers never need to set them manually.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    this.title,
    required this.child,
    this.padding,
  });

  /// Optional section title displayed above [child].
  final String? title;

  /// The main content of the card.
  final Widget child;

  /// Overrides the default [AppEdgeInsets.cardPadding] inside the card.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;

    return Card(
      child: Padding(
        padding: padding ?? AppEdgeInsets.cardPadding,
        child: title != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title!, style: tokens.sectionHeader),
                  SizedBox(height: tokens.spacingSm),
                  child,
                ],
              )
            : child,
      ),
    );
  }
}
