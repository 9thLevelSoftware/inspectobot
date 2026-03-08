import 'package:flutter/foundation.dart';

import 'field_definition.dart';
import 'field_group.dart';
import 'repeating_field_group.dart';

/// Immutable definition of a form section containing field definitions,
/// branch flag keys, and evidence requirement keys.
///
/// Supports conditional visibility at the section level via [conditionalOn]
/// and [conditionalValue]. May also contain [fieldGroups] (composite
/// trigger+dependent groupings) and [repeatingFieldGroups] (fixed-repetition
/// field templates).
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
    this.fieldGroups = const <FieldGroup>[],
    this.repeatingFieldGroups = const <RepeatingFieldGroup>[],
  });

  final String id;
  final String title;
  final String? description;
  final List<String> branchFlagKeys;
  final List<FieldDefinition> fieldDefinitions;
  final List<String> evidenceRequirementKeys;
  final String? conditionalOn;
  final bool conditionalValue;
  final List<FieldGroup> fieldGroups;
  final List<RepeatingFieldGroup> repeatingFieldGroups;

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
  ///
  /// Includes fields from [fieldDefinitions], [fieldGroups] (all fields), and
  /// [repeatingFieldGroups] (template fields only -- concrete keys are
  /// generated at rendering time).
  List<FieldDefinition> visibleFields(Map<String, dynamic> branchContext) {
    final result = <FieldDefinition>[];

    // Standard field definitions
    for (final field in fieldDefinitions) {
      if (field.isVisible(branchContext)) {
        result.add(field);
      }
    }

    // FieldGroup: include all fields (trigger + dependents)
    for (final group in fieldGroups) {
      result.addAll(group.allFields);
    }

    // RepeatingFieldGroup: include template fields
    for (final rg in repeatingFieldGroups) {
      result.addAll(rg.fieldTemplate);
    }

    return result;
  }

  /// Counts the number of required visible fields that have null or empty
  /// values in [formValues], given the current [branchContext].
  int countIncomplete(
    Map<String, dynamic> formValues,
    Map<String, dynamic> branchContext,
  ) {
    int count = 0;

    // Standard field definitions
    for (final field in fieldDefinitions) {
      if (!field.isVisible(branchContext)) continue;
      if (!field.isRequired) continue;
      count += _isIncomplete(formValues[field.key]) ? 1 : 0;
    }

    // FieldGroups: delegate to group's visibility-aware counter
    for (final group in fieldGroups) {
      count += group.countIncompleteFields(formValues);
    }

    // RepeatingFieldGroups: check all concrete keys
    for (final rg in repeatingFieldGroups) {
      for (int i = 0; i < rg.repetitions; i++) {
        for (final field in rg.fieldTemplate) {
          if (!field.isRequired) continue;
          final key = rg.fieldKey(i, field.key);
          if (_isIncomplete(formValues[key])) {
            count++;
          }
        }
      }
    }

    return count;
  }

  static bool _isIncomplete(dynamic value) {
    if (value == null) return true;
    if (value is String && value.isEmpty) return true;
    if (value is List && value.isEmpty) return true;
    return false;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FormSectionDefinition &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          conditionalOn == other.conditionalOn &&
          conditionalValue == other.conditionalValue &&
          listEquals(branchFlagKeys, other.branchFlagKeys) &&
          listEquals(fieldDefinitions, other.fieldDefinitions) &&
          listEquals(evidenceRequirementKeys, other.evidenceRequirementKeys) &&
          listEquals(fieldGroups, other.fieldGroups) &&
          listEquals(repeatingFieldGroups, other.repeatingFieldGroups);

  @override
  int get hashCode => Object.hash(
        id,
        title,
        description,
        conditionalOn,
        conditionalValue,
        Object.hashAll(branchFlagKeys),
        Object.hashAll(fieldDefinitions),
        Object.hashAll(evidenceRequirementKeys),
        Object.hashAll(fieldGroups),
        Object.hashAll(repeatingFieldGroups),
      );
}
