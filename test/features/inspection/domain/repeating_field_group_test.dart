import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/field_definition.dart';
import 'package:inspectobot/features/inspection/domain/field_type.dart';
import 'package:inspectobot/features/inspection/domain/repeating_field_group.dart';

void main() {
  const template = [
    FieldDefinition(key: 'date', label: 'Date', type: FieldType.date),
    FieldDefinition(key: 'time', label: 'Time', type: FieldType.text),
    FieldDefinition(key: 'numberCalled', label: 'Number', type: FieldType.text),
    FieldDefinition(key: 'result', label: 'Result', type: FieldType.text),
  ];

  const rg = RepeatingFieldGroup(
    groupKey: 'attempt',
    label: 'Scheduling Attempts',
    repetitions: 4,
    fieldTemplate: template,
  );

  group('RepeatingFieldGroup', () {
    test('fieldKey generates 1-indexed keys', () {
      expect(rg.fieldKey(0, 'date'), 'attempt_1_date');
      expect(rg.fieldKey(1, 'time'), 'attempt_2_time');
      expect(rg.fieldKey(3, 'result'), 'attempt_4_result');
    });

    test('allFieldKeys returns complete set', () {
      final keys = rg.allFieldKeys;
      expect(keys, hasLength(16));
      expect(keys, contains('attempt_1_date'));
      expect(keys, contains('attempt_1_time'));
      expect(keys, contains('attempt_1_numberCalled'));
      expect(keys, contains('attempt_1_result'));
      expect(keys, contains('attempt_4_date'));
      expect(keys, contains('attempt_4_result'));
    });

    test('totalFieldCount', () {
      expect(rg.totalFieldCount, 16);
    });

    test('equality', () {
      const rg2 = RepeatingFieldGroup(
        groupKey: 'attempt',
        label: 'Scheduling Attempts',
        repetitions: 4,
        fieldTemplate: template,
      );
      expect(rg, equals(rg2));
      expect(rg.hashCode, equals(rg2.hashCode));
    });

    test('inequality on different groupKey', () {
      const different = RepeatingFieldGroup(
        groupKey: 'other',
        label: 'Scheduling Attempts',
        repetitions: 4,
        fieldTemplate: template,
      );
      expect(rg, isNot(equals(different)));
    });

    test('inequality on different repetitions', () {
      const different = RepeatingFieldGroup(
        groupKey: 'attempt',
        label: 'Scheduling Attempts',
        repetitions: 3,
        fieldTemplate: template,
      );
      expect(rg, isNot(equals(different)));
    });
  });
}
