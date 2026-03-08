import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/field_definition.dart';
import 'package:inspectobot/features/inspection/domain/field_group.dart';
import 'package:inspectobot/features/inspection/domain/field_type.dart';
import 'package:inspectobot/features/inspection/domain/form_section_definition.dart';
import 'package:inspectobot/features/inspection/domain/repeating_field_group.dart';

void main() {
  group('FormSectionDefinition', () {
    group('applies', () {
      test('returns true when no conditionalOn is set', () {
        const section = FormSectionDefinition(
          id: 'general_info',
          title: 'General Info',
          fieldDefinitions: [],
        );

        expect(section.applies(const {}), isTrue);
        expect(section.applies({'some_flag': false}), isTrue);
      });

      test('returns true when conditional matches', () {
        const section = FormSectionDefinition(
          id: 'treatment_info',
          title: 'Treatment Info',
          fieldDefinitions: [],
          conditionalOn: 'wdo_previous_treatment',
          conditionalValue: true,
        );

        expect(
          section.applies({'wdo_previous_treatment': true}),
          isTrue,
        );
      });

      test('returns false when conditional does not match', () {
        const section = FormSectionDefinition(
          id: 'treatment_info',
          title: 'Treatment Info',
          fieldDefinitions: [],
          conditionalOn: 'wdo_previous_treatment',
          conditionalValue: true,
        );

        expect(
          section.applies({'wdo_previous_treatment': false}),
          isFalse,
        );
        expect(section.applies(const {}), isFalse);
      });
    });

    group('visibleFields', () {
      test('returns all fields when none are conditional', () {
        const section = FormSectionDefinition(
          id: 'sec1',
          title: 'Section 1',
          fieldDefinitions: [
            FieldDefinition(key: 'a', label: 'A', type: FieldType.text),
            FieldDefinition(key: 'b', label: 'B', type: FieldType.text),
          ],
        );

        final visible = section.visibleFields(const {});
        expect(visible.length, 2);
      });

      test('filters fields by branch context', () {
        const section = FormSectionDefinition(
          id: 'sec2',
          title: 'Section 2',
          fieldDefinitions: [
            FieldDefinition(key: 'always', label: 'Always', type: FieldType.text),
            FieldDefinition(
              key: 'conditional',
              label: 'Conditional',
              type: FieldType.textarea,
              conditionalOn: 'show_detail',
              conditionalValue: true,
            ),
          ],
        );

        final hidden = section.visibleFields({'show_detail': false});
        expect(hidden.length, 1);
        expect(hidden.first.key, 'always');

        final shown = section.visibleFields({'show_detail': true});
        expect(shown.length, 2);
      });
    });

    group('countIncomplete', () {
      final section = const FormSectionDefinition(
        id: 'findings',
        title: 'Findings',
        fieldDefinitions: [
          FieldDefinition(
            key: 'description',
            label: 'Description',
            type: FieldType.textarea,
            isRequired: true,
          ),
          FieldDefinition(
            key: 'notes',
            label: 'Notes',
            type: FieldType.text,
            isRequired: false,
          ),
          FieldDefinition(
            key: 'detail',
            label: 'Detail',
            type: FieldType.text,
            isRequired: true,
            conditionalOn: 'show_detail',
            conditionalValue: true,
          ),
        ],
      );

      test('counts missing required fields', () {
        final count = section.countIncomplete(
          const {},
          const {},
        );
        // 'description' is required + visible (no condition) -> missing
        // 'notes' is not required -> skipped
        // 'detail' is required but conditionalOn='show_detail' is not
        //   in context -> hidden -> skipped
        expect(count, 1);
      });

      test('counts empty string as incomplete', () {
        final count = section.countIncomplete(
          {'description': '', 'detail': 'ok'},
          {'show_detail': true},
        );
        // description is empty -> 1
        // detail is filled -> 0
        expect(count, 1);
      });

      test('returns 0 when all required visible fields are filled', () {
        final count = section.countIncomplete(
          {'description': 'Filled', 'detail': 'Also filled'},
          {'show_detail': true},
        );
        expect(count, 0);
      });

      test('counts empty List as incomplete', () {
        final listSection = const FormSectionDefinition(
          id: 'multi',
          title: 'Multi',
          fieldDefinitions: [
            FieldDefinition(
              key: 'tags',
              label: 'Tags',
              type: FieldType.multiSelect,
              isRequired: true,
            ),
          ],
        );

        expect(listSection.countIncomplete({'tags': <String>[]}, const {}), 1);
        expect(
          listSection.countIncomplete({'tags': ['a']}, const {}),
          0,
        );
      });

      test('excludes non-visible required fields from count', () {
        final count = section.countIncomplete(
          {'description': 'Filled'},
          {'show_detail': false},
        );
        // description is filled -> 0
        // detail is required but hidden -> skipped
        expect(count, 0);
      });
    });

    group('with FieldGroups', () {
      const trigger = FieldDefinition(
        key: 'ext1Depression',
        label: 'Depression',
        type: FieldType.triState,
        isRequired: true,
      );
      const detail = FieldDefinition(
        key: 'ext1Detail',
        label: 'Detail',
        type: FieldType.textarea,
        isRequired: true,
      );

      const sectionWithGroups = FormSectionDefinition(
        id: 'exterior',
        title: 'Exterior',
        fieldDefinitions: [],
        fieldGroups: [
          FieldGroup(
            groupKey: 'ext1',
            triggerField: trigger,
            dependentFields: [detail],
          ),
        ],
      );

      test('visibleFields includes FieldGroup allFields', () {
        final visible = sectionWithGroups.visibleFields(const {});
        expect(visible, hasLength(2));
      });

      test('countIncomplete delegates to FieldGroup', () {
        // Trigger unanswered: 1 incomplete
        expect(
          sectionWithGroups.countIncomplete(const {}, const {}),
          1,
        );

        // Trigger Yes, detail missing: 1 incomplete
        expect(
          sectionWithGroups.countIncomplete(
            {'ext1Depression': 'Yes'},
            const {},
          ),
          1,
        );

        // Both filled
        expect(
          sectionWithGroups.countIncomplete(
            {'ext1Depression': 'Yes', 'ext1Detail': 'desc'},
            const {},
          ),
          0,
        );

        // Trigger No, detail hidden
        expect(
          sectionWithGroups.countIncomplete(
            {'ext1Depression': 'No'},
            const {},
          ),
          0,
        );
      });
    });

    group('with RepeatingFieldGroups', () {
      const sectionWithRepeating = FormSectionDefinition(
        id: 'scheduling',
        title: 'Scheduling',
        fieldDefinitions: [],
        repeatingFieldGroups: [
          RepeatingFieldGroup(
            groupKey: 'attempt',
            label: 'Attempts',
            repetitions: 2,
            fieldTemplate: [
              FieldDefinition(
                key: 'date',
                label: 'Date',
                type: FieldType.date,
                isRequired: true,
              ),
              FieldDefinition(
                key: 'result',
                label: 'Result',
                type: FieldType.text,
                isRequired: false,
              ),
            ],
          ),
        ],
      );

      test('visibleFields includes template fields', () {
        final visible = sectionWithRepeating.visibleFields(const {});
        expect(visible, hasLength(2)); // template fields
      });

      test('countIncomplete checks all concrete keys', () {
        // 2 repetitions x 1 required field = 2 incomplete
        expect(
          sectionWithRepeating.countIncomplete(const {}, const {}),
          2,
        );

        // Fill one
        expect(
          sectionWithRepeating.countIncomplete(
            {'attempt_1_date': '2026-01-01'},
            const {},
          ),
          1,
        );

        // Fill both
        expect(
          sectionWithRepeating.countIncomplete(
            {
              'attempt_1_date': '2026-01-01',
              'attempt_2_date': '2026-01-02',
            },
            const {},
          ),
          0,
        );
      });
    });

    group('backward compatibility', () {
      test('section without groups works as before', () {
        const section = FormSectionDefinition(
          id: 'basic',
          title: 'Basic',
          fieldDefinitions: [
            FieldDefinition(key: 'a', label: 'A', type: FieldType.text),
          ],
        );

        expect(section.fieldGroups, isEmpty);
        expect(section.repeatingFieldGroups, isEmpty);
        expect(section.visibleFields(const {}), hasLength(1));
        expect(section.countIncomplete(const {}, const {}), 0);
      });
    });

    group('equality', () {
      test('equal sections', () {
        const a = FormSectionDefinition(
          id: 'test',
          title: 'Test',
          fieldDefinitions: [],
        );
        const b = FormSectionDefinition(
          id: 'test',
          title: 'Test',
          fieldDefinitions: [],
        );

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('different sections', () {
        const a = FormSectionDefinition(
          id: 'test',
          title: 'Test',
          fieldDefinitions: [],
        );
        const b = FormSectionDefinition(
          id: 'other',
          title: 'Other',
          fieldDefinitions: [],
        );

        expect(a, isNot(equals(b)));
      });
    });
  });
}
