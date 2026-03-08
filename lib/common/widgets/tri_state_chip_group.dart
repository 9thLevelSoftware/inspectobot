import 'package:flutter/material.dart';

import '../../theme/context_ext.dart';
import '../../theme/palette.dart';

/// A labeled group of three [ChoiceChip]s for tri-state selection:
/// "Yes", "No", and "N/A".
///
/// Tapping an already-selected chip deselects it (sets value to null).
/// Uses [Palette.primary] for selected state and the theme's surface
/// container for unselected state. All chips meet the 48dp minimum touch
/// target height.
class TriStateChipGroup extends StatelessWidget {
  const TriStateChipGroup({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.isRequired = false,
  });

  /// Display label rendered above the chips.
  final String label;

  /// Current selection: `'Yes'`, `'No'`, `'N/A'`, or `null` (none selected).
  final String? value;

  /// Called when the user taps a chip. Passes `null` when deselecting.
  final ValueChanged<String?> onChanged;

  /// Whether this field is required (appends * to label).
  final bool isRequired;

  static const _options = ['Yes', 'No', 'N/A'];

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isRequired ? '$label *' : label,
          style: tokens.fieldLabel,
        ),
        SizedBox(height: tokens.spacingXs),
        Wrap(
          spacing: tokens.spacingSm,
          runSpacing: tokens.spacingXs,
          children: _options.map((option) {
            final isSelected = value == option;
            return ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (_) {
                onChanged(isSelected ? null : option);
              },
              selectedColor: Palette.primary,
              backgroundColor: colorScheme.surfaceContainerHigh,
              labelStyle: TextStyle(
                color: isSelected ? Palette.onPrimary : colorScheme.onSurface,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: tokens.radiusSm,
              ),
              materialTapTargetSize: MaterialTapTargetSize.padded,
              visualDensity: const VisualDensity(
                horizontal: 0,
                vertical: 0,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
