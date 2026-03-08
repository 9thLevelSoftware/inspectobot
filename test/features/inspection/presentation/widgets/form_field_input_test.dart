import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inspectobot/common/widgets/app_checkbox_tile.dart';
import 'package:inspectobot/common/widgets/app_date_picker.dart';
import 'package:inspectobot/common/widgets/app_multi_select_chips.dart';
import 'package:inspectobot/features/inspection/domain/field_definition.dart';
import 'package:inspectobot/features/inspection/domain/field_type.dart';
import 'package:inspectobot/features/inspection/presentation/widgets/form_field_input.dart';
import 'package:inspectobot/theme/app_theme.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  group('FormFieldInput', () {
    testWidgets('renders AppTextField for FieldType.text', (tester) async {
      await tester.pumpWidget(_wrap(
        FormFieldInput(
          field: const FieldDefinition(
            key: 'name',
            label: 'Name',
            type: FieldType.text,
          ),
          value: null,
          onChanged: (key, val) {},
        ),
      ));

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
    });

    testWidgets('renders multi-line for FieldType.textarea', (tester) async {
      await tester.pumpWidget(_wrap(
        FormFieldInput(
          field: const FieldDefinition(
            key: 'notes',
            label: 'Notes',
            type: FieldType.textarea,
            maxLines: 5,
          ),
          value: null,
          onChanged: (key, val) {},
        ),
      ));

      // Verify a TextFormField is rendered with the textarea label
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
    });

    testWidgets('renders CheckboxListTile for FieldType.checkbox',
        (tester) async {
      await tester.pumpWidget(_wrap(
        FormFieldInput(
          field: const FieldDefinition(
            key: 'agree',
            label: 'I Agree',
            type: FieldType.checkbox,
          ),
          value: false,
          onChanged: (key, val) {},
        ),
      ));

      expect(find.byType(AppCheckboxTile), findsOneWidget);
      expect(find.text('I Agree'), findsOneWidget);
    });

    testWidgets('renders DropdownButtonFormField for FieldType.dropdown',
        (tester) async {
      await tester.pumpWidget(_wrap(
        FormFieldInput(
          field: const FieldDefinition(
            key: 'color',
            label: 'Color',
            type: FieldType.dropdown,
            dropdownOptions: ['Red', 'Blue', 'Green'],
          ),
          value: null,
          onChanged: (key, val) {},
        ),
      ));

      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('renders date picker trigger for FieldType.date',
        (tester) async {
      await tester.pumpWidget(_wrap(
        FormFieldInput(
          field: const FieldDefinition(
            key: 'inspDate',
            label: 'Inspection Date',
            type: FieldType.date,
          ),
          value: null,
          onChanged: (key, val) {},
        ),
      ));

      expect(find.byType(AppDatePicker), findsOneWidget);
    });

    testWidgets('onChanged fires with correct key for text input',
        (tester) async {
      String? changedKey;
      dynamic changedValue;

      await tester.pumpWidget(_wrap(
        FormFieldInput(
          field: const FieldDefinition(
            key: 'address',
            label: 'Address',
            type: FieldType.text,
          ),
          value: null,
          onChanged: (k, v) {
            changedKey = k;
            changedValue = v;
          },
        ),
      ));

      await tester.enterText(find.byType(TextFormField), 'Main St');
      expect(changedKey, 'address');
      expect(changedValue, 'Main St');
    });

    testWidgets('onChanged fires for checkbox toggle', (tester) async {
      String? changedKey;
      dynamic changedValue;

      await tester.pumpWidget(_wrap(
        FormFieldInput(
          field: const FieldDefinition(
            key: 'confirmed',
            label: 'Confirmed',
            type: FieldType.checkbox,
          ),
          value: false,
          onChanged: (k, v) {
            changedKey = k;
            changedValue = v;
          },
        ),
      ));

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();

      expect(changedKey, 'confirmed');
      expect(changedValue, true);
    });

    testWidgets('renders AppMultiSelectChips for FieldType.multiSelect',
        (tester) async {
      String? changedKey;
      dynamic changedValue;

      await tester.pumpWidget(_wrap(
        FormFieldInput(
          field: const FieldDefinition(
            key: 'defects',
            label: 'Defects Found',
            type: FieldType.multiSelect,
            multiSelectOptions: ['Cracks', 'Rust', 'Leaks'],
          ),
          value: <String>['Rust'],
          onChanged: (k, v) {
            changedKey = k;
            changedValue = v;
          },
        ),
      ));

      expect(find.byType(AppMultiSelectChips), findsOneWidget);
      expect(find.text('Defects Found'), findsOneWidget);

      // Verify pre-selected chip
      final rustChip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Rust'),
      );
      expect(rustChip.selected, isTrue);

      // Tap an unselected chip to add it
      await tester.tap(find.widgetWithText(FilterChip, 'Cracks'));
      await tester.pump();

      expect(changedKey, 'defects');
      expect(changedValue, containsAll(['Rust', 'Cracks']));
    });

    testWidgets('handles null initial value for text', (tester) async {
      await tester.pumpWidget(_wrap(
        FormFieldInput(
          field: const FieldDefinition(
            key: 'field1',
            label: 'Field 1',
            type: FieldType.text,
          ),
          value: null,
          onChanged: (key, val) {},
        ),
      ));

      final textField =
          tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.controller?.text, '');
    });
  });
}
