import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../../theme/typography.dart';

/// Groups related content with an optional title and consistent spacing.
///
/// Children are separated by dividers (or plain gaps when [showDividers] is
/// false). The default gap uses [AppSpacing.minTapTargetSpacing] to keep
/// interactive elements safely separated.
class SectionGroup extends StatelessWidget {
  const SectionGroup({
    super.key,
    this.title,
    required this.children,
    this.showDividers = true,
    this.spacing,
    this.padding,
  });

  /// Optional section title displayed above children.
  final String? title;

  /// The list of child widgets to display in the group.
  final List<Widget> children;

  /// Whether to show dividers between children. Defaults to true.
  final bool showDividers;

  /// Gap between children. Defaults to [AppSpacing.minTapTargetSpacing].
  final double? spacing;

  /// Outer padding around the entire group. Defaults to [EdgeInsets.zero].
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final gap = spacing ?? AppSpacing.minTapTargetSpacing;

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Text(title!, style: AppTypography.sectionTitle),
            SizedBox(height: AppSpacing.spacingSm),
          ],
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) ...[
              if (showDividers)
                Divider(
                  height: gap * 2,
                  color: Theme.of(context).colorScheme.outlineVariant,
                )
              else
                SizedBox(height: gap),
            ],
          ],
        ],
      ),
    );
  }
}
