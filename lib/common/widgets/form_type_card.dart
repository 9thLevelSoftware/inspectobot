import 'package:flutter/material.dart';

import 'package:inspectobot/theme/theme.dart';

/// Visual card for selecting an inspection form type.
///
/// Displays the form label, a brief description, and a selection toggle.
/// The entire card is tappable to toggle selection state.
class FormTypeCard extends StatelessWidget {
  const FormTypeCard({
    super.key,
    required this.label,
    required this.description,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final String description;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final borderColor =
        selected ? colorScheme.primary : colorScheme.surfaceContainerHighest;
    final borderWidth = selected ? 2.0 : 1.0;

    return Card(
      elevation: AppElevation.level0,
      color: selected
          ? colorScheme.primaryContainer.withValues(alpha: 0.3)
          : colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.radiusMd),
        side: BorderSide(color: borderColor, width: borderWidth),
      ),
      child: InkWell(
        onTap: () => onChanged(!selected),
        borderRadius: BorderRadius.circular(AppRadii.radiusMd),
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(minHeight: AppSpacing.minTapTarget),
          child: Padding(
            padding: AppEdgeInsets.cardPaddingCompact,
            child: Row(
              children: [
                Checkbox(
                  value: selected,
                  onChanged: (value) => onChanged(value ?? false),
                  activeColor: colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spacingXxs),
                      Text(
                        description,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
