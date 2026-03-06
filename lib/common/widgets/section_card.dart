import 'package:flutter/material.dart';

import 'package:inspectobot/theme/theme.dart';

/// Density levels for [SectionCard] padding.
enum SectionCardDensity { compact, normal, spacious }

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
    this.density = SectionCardDensity.normal,
    this.leadingBadge,
  });

  /// Optional section title displayed above [child].
  final String? title;

  /// The main content of the card.
  final Widget child;

  /// Overrides the default density-based padding inside the card.
  final EdgeInsetsGeometry? padding;

  /// Controls the internal padding density of the card.
  final SectionCardDensity density;

  /// Optional widget displayed before the title in the header row.
  final Widget? leadingBadge;

  EdgeInsetsGeometry get _densityPadding => switch (density) {
        SectionCardDensity.compact => AppEdgeInsets.cardPaddingCompact,
        SectionCardDensity.normal => AppEdgeInsets.cardPadding,
        SectionCardDensity.spacious =>
          const EdgeInsets.all(AppSpacing.spacingXxl),
      };

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;

    Widget? titleWidget;
    if (title != null) {
      final titleText = Text(title!, style: tokens.sectionHeader);
      titleWidget = leadingBadge != null
          ? Row(
              children: [
                leadingBadge!,
                const SizedBox(width: AppSpacing.spacingSm),
                Expanded(child: titleText),
              ],
            )
          : titleText;
    }

    return Card(
      child: Padding(
        padding: padding ?? _densityPadding,
        child: titleWidget != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  titleWidget,
                  SizedBox(height: tokens.spacingSm),
                  child,
                ],
              )
            : child,
      ),
    );
  }
}
