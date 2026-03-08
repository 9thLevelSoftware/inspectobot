import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/field_definition.dart';
import 'package:inspectobot/features/inspection/domain/field_group.dart';
import 'package:inspectobot/features/inspection/domain/field_type.dart';

void main() {
  const trigger = FieldDefinition(
    key: 'ext1Depression',
    label: 'Depression / Settlement',
    type: FieldType.triState,
    isRequired: true,
  );
  const detail = FieldDefinition(
    key: 'ext1Detail',
    label: 'Describe Depression',
    type: FieldType.textarea,
    isRequired: true,
  );

  const fieldGroup = FieldGroup(
    groupKey: 'ext1',
    triggerField: trigger,
    dependentFields: [detail],
  );

  group('FieldGroup', () {
    test('allFields includes trigger and dependents', () {
      expect(fieldGroup.allFields, hasLength(2));
      expect(fieldGroup.allFields.first, same(trigger));
      expect(fieldGroup.allFields.last, same(detail));
    });

    test('visibleFields shows only trigger when value does not match', () {
      final visible = fieldGroup.visibleFields(const {});
      expect(visible, hasLength(1));
      expect(visible.first, same(trigger));
    });

    test('visibleFields shows only trigger when value is No', () {
      final visible = fieldGroup.visibleFields({'ext1Depression': 'No'});
      expect(visible, hasLength(1));
    });

    test('visibleFields shows only trigger when value is N/A', () {
      final visible = fieldGroup.visibleFields({'ext1Depression': 'N/A'});
      expect(visible, hasLength(1));
    });

    test('visibleFields shows all fields when trigger matches', () {
      final visible = fieldGroup.visibleFields({'ext1Depression': 'Yes'});
      expect(visible, hasLength(2));
    });

    test('trigger field is always visible regardless of value', () {
      for (final val in [null, 'Yes', 'No', 'N/A', '']) {
        final visible = fieldGroup.visibleFields(
          val == null ? const {} : {'ext1Depression': val},
        );
        expect(visible.first, same(trigger),
            reason: 'trigger should be visible when value=$val');
      }
    });

    test('countIncompleteFields counts missing required fields', () {
      // Trigger unanswered
      expect(fieldGroup.countIncompleteFields(const {}), 1);

      // Trigger answered Yes, detail missing
      expect(
        fieldGroup.countIncompleteFields({'ext1Depression': 'Yes'}),
        1,
      );

      // Both answered
      expect(
        fieldGroup.countIncompleteFields({
          'ext1Depression': 'Yes',
          'ext1Detail': 'Some description',
        }),
        0,
      );

      // Trigger answered No, detail hidden -> only trigger counted, it's filled
      expect(
        fieldGroup.countIncompleteFields({'ext1Depression': 'No'}),
        0,
      );
    });

    test('N/A counts as complete for required fields', () {
      expect(
        fieldGroup.countIncompleteFields({'ext1Depression': 'N/A'}),
        0,
      );
    });

    test('equality and hashCode', () {
      const group2 = FieldGroup(
        groupKey: 'ext1',
        triggerField: trigger,
        dependentFields: [detail],
      );

      expect(fieldGroup, equals(group2));
      expect(fieldGroup.hashCode, equals(group2.hashCode));

      const differentKey = FieldGroup(
        groupKey: 'ext2',
        triggerField: trigger,
        dependentFields: [detail],
      );
      expect(fieldGroup, isNot(equals(differentKey)));
    });
  });
}
