import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inspectobot/common/widgets/repeating_group_card.dart';
import 'package:inspectobot/common/widgets/section_header.dart';
import 'package:inspectobot/common/widgets/tri_state_chip_group.dart';
import 'package:inspectobot/features/inspection/domain/field_definition.dart';
import 'package:inspectobot/features/inspection/domain/field_group.dart';
import 'package:inspectobot/features/inspection/domain/field_type.dart';
import 'package:inspectobot/features/inspection/domain/form_section_definition.dart';
import 'package:inspectobot/features/inspection/domain/repeating_field_group.dart';
import 'package:inspectobot/features/inspection/presentation/widgets/form_field_input.dart';
import 'package:inspectobot/features/inspection/presentation/widgets/form_section_ui.dart';
import 'package:inspectobot/theme/app_theme.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(body: child),
  );
}

const _sectionWithBranch = FormSectionDefinition(
  id: 'sec1',
  title: 'Electrical',
  description: 'Electrical system details',
  branchFlagKeys: ['has_generator'],
  fieldDefinitions: [
    FieldDefinition(key: 'panel_type', label: 'Panel Type', type: FieldType.text),
    FieldDefinition(
      key: 'generator_make',
      label: 'Generator Make',
      type: FieldType.text,
      conditionalOn: 'has_generator',
    ),
  ],
);

const _sectionNoBranch = FormSectionDefinition(
  id: 'sec2',
  title: 'Plumbing',
  fieldDefinitions: [
    FieldDefinition(key: 'pipe_material', label: 'Pipe Material', type: FieldType.text),
  ],
);

void main() {
  group('FormSectionUI', () {
    testWidgets('renders SectionHeader with section title', (tester) async {
      await tester.pumpWidget(_wrap(
        FormSectionUI(
          section: _sectionNoBranch,
          formValues: const {},
          branchContext: const {},
          onFieldChanged: (key, val) {},
          onBranchFlagChanged: (key, val) {},
        ),
      ));

      expect(find.byType(SectionHeader), findsOneWidget);
      expect(find.text('Plumbing'), findsOneWidget);
    });

    testWidgets('renders branch flag toggles when branchFlagKeys non-empty',
        (tester) async {
      await tester.pumpWidget(_wrap(
        FormSectionUI(
          section: _sectionWithBranch,
          formValues: const {},
          branchContext: const {'has_generator': false},
          onFieldChanged: (key, val) {},
          onBranchFlagChanged: (key, val) {},
        ),
      ));

      expect(find.byType(SwitchListTile), findsOneWidget);
      expect(find.text('Has Generator'), findsOneWidget);
    });

    testWidgets('does NOT render toggles when branchFlagKeys empty',
        (tester) async {
      await tester.pumpWidget(_wrap(
        FormSectionUI(
          section: _sectionNoBranch,
          formValues: const {},
          branchContext: const {},
          onFieldChanged: (key, val) {},
          onBranchFlagChanged: (key, val) {},
        ),
      ));

      expect(find.byType(SwitchListTile), findsNothing);
    });

    testWidgets('renders visible fields based on branch context',
        (tester) async {
      await tester.pumpWidget(_wrap(
        FormSectionUI(
          section: _sectionWithBranch,
          formValues: const {},
          branchContext: const {'has_generator': false},
          onFieldChanged: (key, val) {},
          onBranchFlagChanged: (key, val) {},
        ),
      ));

      // Panel Type is always visible
      expect(find.text('Panel Type'), findsOneWidget);
      // Generator Make is conditional on has_generator=true, so hidden
      expect(find.text('Generator Make'), findsNothing);
    });

    testWidgets('hides conditional fields when flag is false', (tester) async {
      await tester.pumpWidget(_wrap(
        FormSectionUI(
          section: _sectionWithBranch,
          formValues: const {},
          branchContext: const {'has_generator': false},
          onFieldChanged: (key, val) {},
          onBranchFlagChanged: (key, val) {},
        ),
      ));

      // Only 1 FormFieldInput (Panel Type), Generator Make is hidden
      expect(find.byType(FormFieldInput), findsOneWidget);
    });

    testWidgets('shows conditional fields when flag becomes true',
        (tester) async {
      await tester.pumpWidget(_wrap(
        FormSectionUI(
          section: _sectionWithBranch,
          formValues: const {},
          branchContext: const {'has_generator': true},
          onFieldChanged: (key, val) {},
          onBranchFlagChanged: (key, val) {},
        ),
      ));

      // Both fields visible
      expect(find.byType(FormFieldInput), findsNWidgets(2));
      expect(find.text('Panel Type'), findsOneWidget);
      expect(find.text('Generator Make'), findsOneWidget);
    });

    testWidgets('onFieldChanged callback propagates', (tester) async {
      String? changedKey;
      dynamic changedValue;

      await tester.pumpWidget(_wrap(
        FormSectionUI(
          section: _sectionNoBranch,
          formValues: const {},
          branchContext: const {},
          onFieldChanged: (k, v) {
            changedKey = k;
            changedValue = v;
          },
          onBranchFlagChanged: (key, val) {},
        ),
      ));

      await tester.enterText(find.byType(TextFormField), 'Copper');

      expect(changedKey, 'pipe_material');
      expect(changedValue, 'Copper');
    });

    testWidgets('onBranchFlagChanged fires on toggle tap', (tester) async {
      String? flagKey;
      bool? flagValue;

      await tester.pumpWidget(_wrap(
        FormSectionUI(
          section: _sectionWithBranch,
          formValues: const {},
          branchContext: const {'has_generator': false},
          onFieldChanged: (key, val) {},
          onBranchFlagChanged: (k, v) {
            flagKey = k;
            flagValue = v;
          },
        ),
      ));

      await tester.tap(find.byType(SwitchListTile));
      await tester.pump();

      expect(flagKey, 'has_generator');
      expect(flagValue, true);
    });
  });

  group('FormSectionUI — FieldGroup', () {
    const sectionWithFieldGroup = FormSectionDefinition(
      id: 'exterior',
      title: 'Exterior',
      fieldDefinitions: [],
      fieldGroups: [
        FieldGroup(
          groupKey: 'cracks',
          triggerField: FieldDefinition(
            key: 'sk_cracks',
            label: 'Cracks Found',
            type: FieldType.triState,
          ),
          dependentFields: [
            FieldDefinition(
              key: 'sk_cracks_detail',
              label: 'Crack Details',
              type: FieldType.text,
            ),
          ],
          triggerValue: 'Yes',
        ),
      ],
    );

    testWidgets('renders FieldGroup trigger field', (tester) async {
      await tester.pumpWidget(_wrap(
        FormSectionUI(
          section: sectionWithFieldGroup,
          formValues: const {},
          branchContext: const {},
          onFieldChanged: (key, val) {},
          onBranchFlagChanged: (key, val) {},
        ),
      ));

      // Trigger field (triState) should always be visible
      expect(find.byType(TriStateChipGroup), findsOneWidget);
      expect(find.text('Cracks Found'), findsOneWidget);
    });

    testWidgets('hides dependent fields when trigger value does not match',
        (tester) async {
      await tester.pumpWidget(_wrap(
        FormSectionUI(
          section: sectionWithFieldGroup,
          formValues: const {'sk_cracks': 'No'},
          branchContext: const {},
          onFieldChanged: (key, val) {},
          onBranchFlagChanged: (key, val) {},
        ),
      ));

      // Trigger is visible, but dependent "Crack Details" is hidden
      expect(find.text('Cracks Found'), findsOneWidget);
      expect(find.text('Crack Details'), findsNothing);
    });

    testWidgets('shows dependent fields when trigger value matches',
        (tester) async {
      await tester.pumpWidget(_wrap(
        FormSectionUI(
          section: sectionWithFieldGroup,
          formValues: const {'sk_cracks': 'Yes'},
          branchContext: const {},
          onFieldChanged: (key, val) {},
          onBranchFlagChanged: (key, val) {},
        ),
      ));

      // Both trigger and dependent fields are visible
      expect(find.text('Cracks Found'), findsOneWidget);
      expect(find.text('Crack Details'), findsOneWidget);
    });
  });

  group('FormSectionUI — RepeatingFieldGroup', () {
    const sectionWithRepeating = FormSectionDefinition(
      id: 'scheduling',
      title: 'Scheduling',
      fieldDefinitions: [],
      repeatingFieldGroups: [
        RepeatingFieldGroup(
          groupKey: 'attempt',
          label: 'Attempt',
          repetitions: 3,
          fieldTemplate: [
            FieldDefinition(
              key: 'date',
              label: 'Date',
              type: FieldType.text,
            ),
            FieldDefinition(
              key: 'result',
              label: 'Result',
              type: FieldType.text,
            ),
          ],
        ),
      ],
    );

    testWidgets('renders RepeatingFieldGroup with correct iteration count',
        (tester) async {
      await tester.pumpWidget(_wrap(
        FormSectionUI(
          section: sectionWithRepeating,
          formValues: const {},
          branchContext: const {},
          onFieldChanged: (key, val) {},
          onBranchFlagChanged: (key, val) {},
        ),
      ));

      // 3 RepeatingGroupCards
      expect(find.byType(RepeatingGroupCard), findsNWidgets(3));
      expect(find.text('Attempt 1'), findsOneWidget);
      expect(find.text('Attempt 2'), findsOneWidget);
      expect(find.text('Attempt 3'), findsOneWidget);
    });

    testWidgets('repeating group field keys are correctly indexed',
        (tester) async {
      String? changedKey;
      dynamic changedValue;

      await tester.pumpWidget(_wrap(
        FormSectionUI(
          section: sectionWithRepeating,
          formValues: const {},
          branchContext: const {},
          onFieldChanged: (k, v) {
            changedKey = k;
            changedValue = v;
          },
          onBranchFlagChanged: (key, val) {},
        ),
      ));

      // Find all text form fields — 3 repetitions x 2 fields = 6
      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(6));

      // Type into the first field (attempt_1_date)
      await tester.enterText(textFields.first, '2025-01-01');

      expect(changedKey, 'attempt_1_date');
      expect(changedValue, '2025-01-01');
    });

    testWidgets('renders values from formValues with indexed keys',
        (tester) async {
      await tester.pumpWidget(_wrap(
        FormSectionUI(
          section: sectionWithRepeating,
          formValues: const {
            'attempt_2_result': 'No answer',
          },
          branchContext: const {},
          onFieldChanged: (key, val) {},
          onBranchFlagChanged: (key, val) {},
        ),
      ));

      // The text controller for attempt_2_result should have the value
      final textFields = find.byType(TextFormField);
      // Fields order: attempt_1_date, attempt_1_result, attempt_2_date, attempt_2_result, ...
      // attempt_2_result is index 3 (0-based)
      final field = tester.widget<TextFormField>(textFields.at(3));
      expect(field.controller?.text, 'No answer');
    });
  });

  group('FormSectionUI — backward compatibility', () {
    testWidgets('existing section without groups still renders correctly',
        (tester) async {
      await tester.pumpWidget(_wrap(
        FormSectionUI(
          section: _sectionNoBranch,
          formValues: const {},
          branchContext: const {},
          onFieldChanged: (key, val) {},
          onBranchFlagChanged: (key, val) {},
        ),
      ));

      expect(find.byType(SectionHeader), findsOneWidget);
      expect(find.text('Plumbing'), findsOneWidget);
      expect(find.byType(FormFieldInput), findsOneWidget);
      expect(find.byType(RepeatingGroupCard), findsNothing);
    });
  });
}
