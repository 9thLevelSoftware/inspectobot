import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inspectobot/common/widgets/section_header.dart';
import 'package:inspectobot/features/inspection/domain/field_definition.dart';
import 'package:inspectobot/features/inspection/domain/field_type.dart';
import 'package:inspectobot/features/inspection/domain/form_section_definition.dart';
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
}
