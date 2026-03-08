import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/field_definition.dart';
import 'package:inspectobot/features/inspection/domain/field_type.dart';

void main() {
  group('FieldType', () {
    test('has exactly 7 values', () {
      expect(FieldType.values.length, 7);
    });

    test('contains expected values', () {
      expect(FieldType.values, containsAll([
        FieldType.text,
        FieldType.checkbox,
        FieldType.dropdown,
        FieldType.date,
        FieldType.textarea,
        FieldType.multiSelect,
        FieldType.triState,
      ]));
    });
  });

  group('FieldDefinition', () {
    group('isVisible', () {
      test('returns true when conditionalOn is null', () {
        const field = FieldDefinition(
          key: 'test_field',
          label: 'Test',
          type: FieldType.text,
        );

        expect(field.isVisible(const {}), isTrue);
        expect(field.isVisible({'some_flag': true}), isTrue);
        expect(field.isVisible({'some_flag': false}), isTrue);
      });

      test('returns true when conditionalOn matches conditionalValue', () {
        const field = FieldDefinition(
          key: 'damage_notes',
          label: 'Damage Notes',
          type: FieldType.textarea,
          conditionalOn: 'wdo_damage_by_wdo',
          conditionalValue: true,
        );

        expect(field.isVisible({'wdo_damage_by_wdo': true}), isTrue);
      });

      test('returns false when conditionalOn does not match', () {
        const field = FieldDefinition(
          key: 'damage_notes',
          label: 'Damage Notes',
          type: FieldType.textarea,
          conditionalOn: 'wdo_damage_by_wdo',
          conditionalValue: true,
        );

        expect(field.isVisible({'wdo_damage_by_wdo': false}), isFalse);
        expect(field.isVisible(const {}), isFalse);
      });

      test('returns true when conditionalValue is false and flag is false', () {
        const field = FieldDefinition(
          key: 'no_damage_reason',
          label: 'Reason No Damage',
          type: FieldType.text,
          conditionalOn: 'wdo_damage_by_wdo',
          conditionalValue: false,
        );

        expect(field.isVisible({'wdo_damage_by_wdo': false}), isTrue);
        expect(field.isVisible({'wdo_damage_by_wdo': true}), isFalse);
      });
    });

    test('default values are correct', () {
      const field = FieldDefinition(
        key: 'k',
        label: 'L',
        type: FieldType.text,
      );

      expect(field.isRequired, isFalse);
      expect(field.conditionalOn, isNull);
      expect(field.conditionalValue, isTrue);
      expect(field.dropdownOptions, isNull);
      expect(field.multiSelectOptions, isNull);
      expect(field.hint, isNull);
      expect(field.maxLines, isNull);
      expect(field.keyboardType, isNull);
    });
  });
}
