import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inspectobot/features/inspection/domain/mold_form_data.dart';
import 'package:inspectobot/features/inspection/presentation/sub_views/mold_scope_step.dart';
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
  group('MoldScopeStep', () {
    testWidgets('renders correctly with initial value', (tester) async {
      final data = MoldFormData.empty().copyWith(
        scopeOfAssessment: 'Kitchen and bathrooms inspected',
      );

      await tester.pumpWidget(_wrap(
        MoldScopeStep(
          formData: data,
          onChanged: (_) {},
        ),
      ));

      // Verify section header
      expect(find.text('Scope of Assessment'), findsAtLeastNWidgets(1));

      // Verify description text
      expect(
        find.textContaining('scope and limitations'),
        findsOneWidget,
      );

      // Verify TextFormField with initial value
      expect(find.text('Kitchen and bathrooms inspected'), findsOneWidget);
    });

    testWidgets('renders empty TextFormField when no initial value', (tester) async {
      await tester.pumpWidget(_wrap(
        MoldScopeStep(
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
        MoldScopeStep(
          formData: MoldFormData.empty(),
          onChanged: (data) => updated = data,
        ),
      ));

      await tester.enterText(
        find.byType(TextFormField),
        'Full property inspection including attic',
      );

      expect(updated, isNotNull);
      expect(updated!.scopeOfAssessment, 'Full property inspection including attic');
    });

    testWidgets('TextFormField supports multiline input', (tester) async {
      await tester.pumpWidget(_wrap(
        MoldScopeStep(
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
        MoldScopeStep(
          formData: MoldFormData.empty(),
          onChanged: (_) {},
        ),
      ));

      expect(find.text('Scope of Assessment'), findsAtLeastNWidgets(1));
    });

    testWidgets('description mentions inspection methodology', (tester) async {
      await tester.pumpWidget(_wrap(
        MoldScopeStep(
          formData: MoldFormData.empty(),
          onChanged: (_) {},
        ),
      ));

      expect(
        find.textContaining('inspection methodology'),
        findsOneWidget,
      );
    });

    testWidgets('onChanged preserves other form data fields', (tester) async {
      MoldFormData? updated;

      final initialData = MoldFormData.empty().copyWith(
        visualObservations: 'Some observations',
        airSamplesTaken: true,
      );

      await tester.pumpWidget(_wrap(
        MoldScopeStep(
          formData: initialData,
          onChanged: (data) => updated = data,
        ),
      ));

      await tester.enterText(
        find.byType(TextFormField),
        'New scope',
      );

      expect(updated, isNotNull);
      expect(updated!.scopeOfAssessment, 'New scope');
      // Other fields should be preserved (we can't verify without checking all fields)
      expect(updated!.visualObservations, 'Some observations');
      expect(updated!.airSamplesTaken, true);
    });
  });
}
