import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inspectobot/features/inspection/domain/mold_form_data.dart';
import 'package:inspectobot/features/inspection/presentation/sub_views/mold_type_location_step.dart';
import 'package:inspectobot/theme/app_theme.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(
      body: SizedBox(
        height: 800,
        width: 600,
        child: child,
      ),
    ),
  );
}

void main() {
  group('MoldTypeLocationStep', () {
    testWidgets('renders correctly with initial value', (tester) async {
      final data = MoldFormData.empty().copyWith(
        moldTypeLocation: 'Stachybotrys in basement',
      );

      await tester.pumpWidget(_wrap(
        MoldTypeLocationStep(
          formData: data,
          onChanged: (_) {},
        ),
      ));

      // Verify section header
      expect(find.text('Mold Type & Location'), findsAtLeastNWidgets(1));

      // Verify description text
      expect(
        find.textContaining('type(s) of mold'),
        findsOneWidget,
      );

      // Verify TextFormField with initial value
      expect(find.text('Stachybotrys in basement'), findsOneWidget);
    });

    testWidgets('renders empty TextFormField when no initial value', (tester) async {
      await tester.pumpWidget(_wrap(
        MoldTypeLocationStep(
          formData: MoldFormData.empty(),
          onChanged: (_) {},
        ),
      ));

      expect(find.byType(TextFormField), findsOneWidget);
      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.initialValue, '');
    });

    testWidgets('onChanged fires when text changes', (tester) async {
      MoldFormData? updated;

      await tester.pumpWidget(_wrap(
        MoldTypeLocationStep(
          formData: MoldFormData.empty(),
          onChanged: (data) => updated = data,
        ),
      ));

      await tester.enterText(
        find.byType(TextFormField),
        'Aspergillus in bathroom',
      );

      expect(updated, isNotNull);
      expect(updated!.moldTypeLocation, 'Aspergillus in bathroom');
    });

    testWidgets('TextFormField supports multiline input', (tester) async {
      await tester.pumpWidget(_wrap(
        MoldTypeLocationStep(
          formData: MoldFormData.empty(),
          onChanged: (_) {},
        ),
      ));

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.maxLines, isNull);
      expect(textField.minLines, 6);
      expect(textField.textInputAction, TextInputAction.newline);
    });

    testWidgets('has correct label text', (tester) async {
      await tester.pumpWidget(_wrap(
        MoldTypeLocationStep(
          formData: MoldFormData.empty(),
          onChanged: (_) {},
        ),
      ));

      expect(find.text('Mold Type & Location'), findsAtLeastNWidgets(1));
    });
  });
}
