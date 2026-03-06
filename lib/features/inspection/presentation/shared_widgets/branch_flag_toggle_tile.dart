import 'package:flutter/material.dart';

/// A reusable toggle tile for branch context flags (e.g. "Hazard present?",
/// "Roof defect present?").
///
/// Renders a [SwitchListTile] with a deterministic `ValueKey` for testing.
class BranchFlagToggleTile extends StatelessWidget {
  const BranchFlagToggleTile({
    super.key,
    required this.flagKey,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  /// The branch flag identifier (e.g. `hazard_present`).
  final String flagKey;

  /// Human-readable label displayed as the tile title.
  final String label;

  /// Current toggle state.
  final bool value;

  /// Called when the user toggles the switch.
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      key: ValueKey('branch-flag-$flagKey'),
      title: Text(label),
      value: value,
      onChanged: onChanged,
    );
  }
}
