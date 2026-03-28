import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inspectobot/features/inspection/domain/mold_form_data.dart';
import 'package:inspectobot/features/inspection/presentation/sub_views/mold_remediation_step.dart';
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
  group('MoldRemediationStep', () {
    testWidgets('renders correctly with remediationRecommended false', (tester) async {
      final data = MoldFormData.empty().copyWith(
        remediationRecommended: false,
        additionalFindings: 'Some additional notes',
      );

      await tester.pumpWidget(_wrap(
        MoldRemediationStep(
          formData: data,
          onChanged: (_) {},
        ),
      ));

      // Verify section header
      expect(find.text('Remediation Recommendations'), findsAtLeastNWidgets(1));

      // Verify description text
      expect(
        find.textContaining('remediation protocol'),
        findsOneWidget,
      );

      // Verify SwitchListTile is present
      expect(
        find.text('Remediation is recommended'),
        findsOneWidget,
      );
      expect(find.byType(SwitchListTile), findsOneWidget);

      // Remediation recommendations field should be hidden
      expect(
        find.widgetWithText(TextFormField, 'Remediation Recommendations'),
        findsNothing,
      );

      // Additional Findings field should always be visible
      expect(
        find.widgetWithText(TextFormField, 'Additional Findings (Optional)'),
        findsOneWidget,
      );

      // Verify additional findings initial value
      expect(find.text('Some additional notes'), findsOneWidget);
    });

    testWidgets('shows remediation TextFormField when remediationRecommended is true', (tester) async {
      final data = MoldFormData.empty().copyWith(
        remediationRecommended: true,
        remediationRecommendations: 'Remove and replace drywall',
      );

      await tester.pumpWidget(_wrap(
        MoldRemediationStep(
          formData: data,
          onChanged: (_) {},
        ),
      ));

      expect(
        find.widgetWithText(TextFormField, 'Remediation Recommendations'),
        findsOneWidget,
      );
      expect(find.text('Remove and replace drywall'), findsOneWidget);
    });

    testWidgets('toggle remediationRecommended shows/hides recommendations field', (tester) async {
      MoldFormData? updated;

      await tester.pumpWidget(_wrap(
        MoldRemediationStep(
          formData: MoldFormData.empty().copyWith(remediationRecommended: false),
          onChanged: (data) => updated = data,
        ),
      ));

      // Initially hidden
      expect(
        find.widgetWithText(TextFormField, 'Remediation Recommendations'),
        findsNothing,
      );

      // Toggle on
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      expect(updated, isNotNull);
      expect(updated!.remediationRecommended, isTrue);

      // Now visible in the new build with updated data
      await tester.pumpWidget(_wrap(
        MoldRemediationStep(
          formData: updated!,
          onChanged: (_) {},
        ),
      ));

      expect(
        find.widgetWithText(TextFormField, 'Remediation Recommendations'),
        findsOneWidget,
      );
    });

    testWidgets('onChanged fires when remediationRecommendations changes', (tester) async {
      MoldFormData? updated;

      await tester.pumpWidget(_wrap(
        MoldRemediationStep(
          formData: MoldFormData.empty().copyWith(remediationRecommended: true),
          onChanged: (data) => updated = data,
        ),
      ));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Remediation Recommendations'),
        'Install dehumidifiers',
      );

      expect(updated, isNotNull);
      expect(updated!.remediationRecommendations, 'Install dehumidifiers');
    });

    testWidgets('onChanged fires when additionalFindings changes', (tester) async {
      MoldFormData? updated;

      await tester.pumpWidget(_wrap(
        MoldRemediationStep(
          formData: MoldFormData.empty(),
          onChanged: (data) => updated = data,
        ),
      ));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Additional Findings (Optional)'),
        'Found additional mold in closet',
      );

      expect(updated, isNotNull);
      expect(updated!.additionalFindings, 'Found additional mold in closet');
    });

    testWidgets('remediation TextFormField supports multiline with minLines 4', (tester) async {
      await tester.pumpWidget(_wrap(
        MoldRemediationStep(
          formData: MoldFormData.empty().copyWith(remediationRecommended: true),
          onChanged: (_) {},
        ),
      ));

      final remediationField = find.widgetWithText(TextFormField, 'Remediation Recommendations');
      final textField = tester.widget<TextFormField>(remediationField);
      expect(textField.maxLines, isNull);
      expect(textField.minLines, 4);
    });

    testWidgets('additional findings TextFormField supports multiline with minLines 4', (tester) async {
      await tester.pumpWidget(_wrap(
        MoldRemediationStep(
          formData: MoldFormData.empty(),
          onChanged: (_) {},
        ),
      ));

      final additionalField = find.widgetWithText(TextFormField, 'Additional Findings (Optional)');
      final textField = tester.widget<TextFormField>(additionalField);
      expect(textField.maxLines, isNull);
      expect(textField.minLines, 4);
    });

    testWidgets('toggle off hides remediation recommendations field', (tester) async {
      MoldFormData? updated;

      await tester.pumpWidget(_wrap(
        MoldRemediationStep(
          formData: MoldFormData.empty().copyWith(remediationRecommended: true),
          onChanged: (data) => updated = data,
        ),
      ));

      // Initially visible
      expect(
        find.widgetWithText(TextFormField, 'Remediation Recommendations'),
        findsOneWidget,
      );

      // Toggle off
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      expect(updated, isNotNull);
      expect(updated!.remediationRecommended, isFalse);
    });
  });
}
