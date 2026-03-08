import 'package:flutter/material.dart';

import '../../theme/context_ext.dart';

/// A labeled group of [FilterChip]s that supports multi-selection.
///
/// Renders a [Text] label followed by a [Wrap] of chips. Tapping a chip
/// toggles its selection and invokes [onChanged] with the updated list.
class AppMultiSelectChips extends StatelessWidget {
  const AppMultiSelectChips({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final List<String> options;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  void _toggle(String option) {
    final updated = List<String>.from(selected);
    if (updated.contains(option)) {
      updated.remove(option);
    } else {
      updated.add(option);
    }
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: tokens.fieldLabel),
        SizedBox(height: tokens.spacingXs),
        Wrap(
          spacing: tokens.spacingSm,
          runSpacing: tokens.spacingXs,
          children: options.map((option) {
            final isSelected = selected.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (_) => _toggle(option),
              selectedColor: colorScheme.primaryContainer,
              checkmarkColor: colorScheme.onPrimaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: tokens.radiusSm,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
