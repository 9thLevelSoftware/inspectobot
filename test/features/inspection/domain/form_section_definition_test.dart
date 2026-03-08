import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/field_definition.dart';
import 'package:inspectobot/features/inspection/domain/field_type.dart';
import 'package:inspectobot/features/inspection/domain/form_section_definition.dart';

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
  });
}
