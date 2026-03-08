import 'field_definition.dart';

/// Immutable definition of a form section containing field definitions,
/// branch flag keys, and evidence requirement keys.
///
/// Supports conditional visibility at the section level via [conditionalOn]
/// and [conditionalValue].
class FormSectionDefinition {
  const FormSectionDefinition({
    required this.id,
    required this.title,
    this.description,
    this.branchFlagKeys = const <String>[],
    required this.fieldDefinitions,
    this.evidenceRequirementKeys = const <String>[],
    this.conditionalOn,
    this.conditionalValue = true,
  });

  final String id;
  final String title;
  final String? description;
  final List<String> branchFlagKeys;
  final List<FieldDefinition> fieldDefinitions;
  final List<String> evidenceRequirementKeys;
  final String? conditionalOn;
  final bool conditionalValue;

  /// Returns whether this section applies given the current [branchContext].
  ///
  /// If [conditionalOn] is null, the section always applies. Otherwise, it
  /// applies only when `branchContext[conditionalOn] == conditionalValue`.
  bool applies(Map<String, dynamic> branchContext) {
    if (conditionalOn == null) return true;
    return branchContext[conditionalOn] == conditionalValue;
  }

  /// Returns only the [FieldDefinition]s that are visible given the current
  /// [branchContext].
  List<FieldDefinition> visibleFields(Map<String, dynamic> branchContext) {
    return fieldDefinitions
        .where((field) => field.isVisible(branchContext))
        .toList(growable: false);
  }

  /// Counts the number of required visible fields that have null or empty
  /// values in [formValues], given the current [branchContext].
  int countIncomplete(
    Map<String, dynamic> formValues,
    Map<String, dynamic> branchContext,
  ) {
    int count = 0;
    for (final field in visibleFields(branchContext)) {
      if (!field.isRequired) continue;
      final value = formValues[field.key];
      if (value == null) {
        count++;
      } else if (value is String && value.isEmpty) {
        count++;
      }
    }
    return count;
  }
}
