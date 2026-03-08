import 'field_type.dart';

/// Immutable definition of a single form field within a section.
///
/// Supports conditional visibility via [conditionalOn] / [conditionalValue],
/// which gate field display based on branch context flags.
class FieldDefinition {
  const FieldDefinition({
    required this.key,
    required this.label,
    required this.type,
    this.isRequired = false,
    this.conditionalOn,
    this.conditionalValue = true,
    this.dropdownOptions,
    this.multiSelectOptions,
    this.hint,
    this.maxLines,
    this.keyboardType,
  });

  final String key;
  final String label;
  final FieldType type;
  final bool isRequired;
  final String? conditionalOn;
  final bool conditionalValue;
  final List<String>? dropdownOptions;
  final List<String>? multiSelectOptions;
  final String? hint;
  final int? maxLines;
  final String? keyboardType;

  /// Returns whether this field should be visible given the current
  /// [branchContext].
  ///
  /// If [conditionalOn] is null, the field is always visible. Otherwise, it is
  /// visible only when `branchContext[conditionalOn] == conditionalValue`.
  bool isVisible(Map<String, dynamic> branchContext) {
    if (conditionalOn == null) return true;
    return branchContext[conditionalOn] == conditionalValue;
  }
}
