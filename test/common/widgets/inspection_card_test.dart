import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/common/widgets/app_button.dart';
import 'package:inspectobot/common/widgets/inspection_card.dart';
import 'package:inspectobot/features/inspection/domain/evidence_requirement.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/inspection_wizard_state.dart';
import 'package:inspectobot/theme/theme.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(body: child),
  );
}

void main() {
  group('InspectionCard', () {
    testWidgets('displays clientName as title', (tester) async {
      await tester.pumpWidget(_wrap(
        InspectionCard(
          clientName: 'Acme Corp',
          address: '123 Main St',
        ),
      ));

      expect(find.text('Acme Corp'), findsOneWidget);
    });

    testWidgets('displays address in subtitle', (tester) async {
      await tester.pumpWidget(_wrap(
        InspectionCard(
          clientName: 'Acme Corp',
          address: '123 Main St',
        ),
      ));

      expect(find.text('123 Main St'), findsOneWidget);
    });

    testWidgets('shows resume step text when resumeStep is provided',
        (tester) async {
      await tester.pumpWidget(_wrap(
        InspectionCard(
          clientName: 'Acme Corp',
          address: '123 Main St',
          resumeStep: 2,
        ),
      ));

      // Step is 1-indexed in the display: resumeStep 2 -> "step 3"
      expect(find.textContaining('Resume at step 3'), findsOneWidget);
    });

    testWidgets('shows resume button when onResume is provided',
        (tester) async {
      await tester.pumpWidget(_wrap(
        InspectionCard(
          clientName: 'Acme Corp',
          address: '123 Main St',
          onResume: () {},
        ),
      ));

      // AppButton with variant filled renders a FilledButton
      expect(find.byType(AppButton), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.text('Resume'), findsOneWidget);
    });

    testWidgets('resume button uses custom label when resumeLabel is provided',
        (tester) async {
      await tester.pumpWidget(_wrap(
        InspectionCard(
          clientName: 'Acme Corp',
          address: '123 Main St',
          resumeLabel: 'Continue',
          onResume: () {},
        ),
      ));

      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Resume'), findsNothing);
    });

    testWidgets('does not show resume button when onResume is null',
        (tester) async {
      await tester.pumpWidget(_wrap(
        InspectionCard(
          clientName: 'Acme Corp',
          address: '123 Main St',
        ),
      ));

      expect(find.byType(AppButton), findsNothing);
    });

    testWidgets('onTap callback fires when card is tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(_wrap(
        InspectionCard(
          clientName: 'Acme Corp',
          address: '123 Main St',
          onTap: () => tapped = true,
        ),
      ));

      await tester.tap(find.byType(ListTile));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('isThreeLine is true when resumeStep is provided',
        (tester) async {
      await tester.pumpWidget(_wrap(
        InspectionCard(
          clientName: 'Acme Corp',
          address: '123 Main St',
          resumeStep: 0,
        ),
      ));

      final listTile = tester.widget<ListTile>(find.byType(ListTile));
      expect(listTile.isThreeLine, isTrue);
    });

    testWidgets('isThreeLine is false when resumeStep is null',
        (tester) async {
      await tester.pumpWidget(_wrap(
        InspectionCard(
          clientName: 'Acme Corp',
          address: '123 Main St',
        ),
      ));

      final listTile = tester.widget<ListTile>(find.byType(ListTile));
      expect(listTile.isThreeLine, isFalse);
    });

    testWidgets('renders chips for 3 forms with correct percentages',
        (tester) async {
      final summaries = [
        const FormProgressSummary(
          form: FormType.fourPoint,
          missingRequirements: <EvidenceRequirement>[],
          totalRequirements: 10,
        ),
        FormProgressSummary(
          form: FormType.roofCondition,
          missingRequirements: [
            EvidenceRequirement(
              key: 'roof_photo',
              label: 'Roof photo',
              form: FormType.roofCondition,
              mediaType: EvidenceMediaType.photo,
              minimumCount: 1,
            ),
          ],
          totalRequirements: 10,
        ),
        FormProgressSummary(
          form: FormType.windMitigation,
          missingRequirements: List.generate(
            8,
            (i) => EvidenceRequirement(
              key: 'wind_$i',
              label: 'Wind $i',
              form: FormType.windMitigation,
              mediaType: EvidenceMediaType.photo,
              minimumCount: 1,
            ),
          ),
          totalRequirements: 10,
        ),
      ];

      await tester.pumpWidget(_wrap(
        InspectionCard(
          clientName: 'Acme Corp',
          address: '123 Main St',
          formSummaries: summaries,
        ),
      ));

      // 4PT: 100% (0 missing of 10)
      expect(find.text('4PT: 100%'), findsOneWidget);
      // ROOF: 90% (1 missing of 10)
      expect(find.text('ROOF: 90%'), findsOneWidget);
      // WIND: 20% (8 missing of 10)
      expect(find.text('WIND: 20%'), findsOneWidget);

      // FormProgressChips widget should be present
      expect(find.byType(FormProgressChips), findsOneWidget);
    });

    testWidgets('renders no chips when formSummaries is null',
        (tester) async {
      await tester.pumpWidget(_wrap(
        InspectionCard(
          clientName: 'Acme Corp',
          address: '123 Main St',
        ),
      ));

      // No FormProgressChips should be in the tree
      expect(find.byType(FormProgressChips), findsNothing);
    });
  });
}
