import 'package:flutter/foundation.dart';

import 'field_definition.dart';

/// A group of fields that repeats a fixed number of times, e.g. scheduling
/// attempts (4 attempts x 4 fields = 16 fields).
///
/// Field keys are generated using the pattern:
/// `{groupKey}_{index+1}_{templateKey}` (1-indexed).
@immutable
class RepeatingFieldGroup {
  const RepeatingFieldGroup({
    required this.groupKey,
    required this.label,
    required this.repetitions,
    required this.fieldTemplate,
    this.repetitionLabel,
  });

  /// Unique identifier for this repeating group.
  final String groupKey;

  /// Display label for the group.
  final String label;

  /// Number of repetitions (e.g. 4 for scheduling attempts).
  final int repetitions;

  /// Template fields that repeat for each iteration.
  final List<FieldDefinition> fieldTemplate;

  /// Optional function that returns a label for each repetition.
  /// Receives the 1-indexed repetition number.
  final String Function(int)? repetitionLabel;

  /// Returns the concrete field key for a given repetition index and template key.
  ///
  /// [index] is 0-based but the generated key is 1-indexed:
  /// `{groupKey}_{index+1}_{templateKey}`
  String fieldKey(int index, String templateKey) {
    return '${groupKey}_${index + 1}_$templateKey';
  }

  /// Returns all concrete field keys across all repetitions.
  List<String> get allFieldKeys {
    final keys = <String>[];
    for (int i = 0; i < repetitions; i++) {
      for (final field in fieldTemplate) {
        keys.add(fieldKey(i, field.key));
      }
    }
    return keys;
  }

  /// Returns the total number of concrete fields across all repetitions.
  int get totalFieldCount => repetitions * fieldTemplate.length;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepeatingFieldGroup &&
          runtimeType == other.runtimeType &&
          groupKey == other.groupKey &&
          label == other.label &&
          repetitions == other.repetitions &&
          listEquals(fieldTemplate, other.fieldTemplate);

  @override
  int get hashCode => Object.hash(
        groupKey,
        label,
        repetitions,
        Object.hashAll(fieldTemplate),
      );
}
