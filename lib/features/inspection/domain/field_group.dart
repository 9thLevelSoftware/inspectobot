import 'package:flutter/foundation.dart';

import 'field_definition.dart';

/// A composite of a trigger field (typically tri-state) and its dependent
/// detail fields. The trigger field is always visible; dependent fields are
/// visible only when `formValues[triggerField.key] == triggerValue`.
///
/// IMPORTANT: FieldGroup owns ALL intra-group visibility. Dependent fields
/// must have `conditionalOn = null`; visibility is determined solely by the
/// trigger field's value in [formValues].
@immutable
class FieldGroup {
  const FieldGroup({
    required this.groupKey,
    required this.triggerField,
    required this.dependentFields,
    this.triggerValue = 'Yes',
  });

  /// Unique identifier for this group within its section.
  final String groupKey;

  /// The field whose value gates visibility of [dependentFields].
  final FieldDefinition triggerField;

  /// Fields that become visible when the trigger matches [triggerValue].
  final List<FieldDefinition> dependentFields;

  /// The value of [triggerField] that makes [dependentFields] visible.
  /// Defaults to `'Yes'` for tri-state fields.
  final String triggerValue;

  /// Returns all fields in this group (trigger + dependents).
  List<FieldDefinition> get allFields =>
      [triggerField, ...dependentFields];

  /// Returns only the fields that are visible given the current [formValues].
  ///
  /// The trigger field is always visible. Dependent fields are visible only
  /// when `formValues[triggerField.key] == triggerValue`.
  List<FieldDefinition> visibleFields(Map<String, dynamic> formValues) {
    if (formValues[triggerField.key] == triggerValue) {
      return allFields;
    }
    return [triggerField];
  }

  /// Counts the number of required visible fields that have null, empty, or
  /// unanswered values in [formValues].
  ///
  /// For tri-state fields, `'N/A'` counts as complete.
  int countIncompleteFields(Map<String, dynamic> formValues) {
    int count = 0;
    for (final field in visibleFields(formValues)) {
      if (!field.isRequired) continue;
      final value = formValues[field.key];
      if (value == null) {
        count++;
      } else if (value is String && value.isEmpty) {
        count++;
      } else if (value is List && value.isEmpty) {
        count++;
      }
    }
    return count;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FieldGroup &&
          runtimeType == other.runtimeType &&
          groupKey == other.groupKey &&
          triggerField == other.triggerField &&
          triggerValue == other.triggerValue &&
          listEquals(dependentFields, other.dependentFields);

  @override
  int get hashCode => Object.hash(
        groupKey,
        triggerField,
        triggerValue,
        Object.hashAll(dependentFields),
      );
}
