import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inspectobot/features/inspection/domain/condition_rating.dart';
import 'package:inspectobot/features/inspection/domain/general_inspection_form_data.dart';
import 'package:inspectobot/features/inspection/domain/system_inspection_data.dart';
import 'package:inspectobot/features/inspection/presentation/sub_views/general_inspection_review_step.dart';
import 'package:inspectobot/theme/app_theme.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(
      body: SizedBox(
        height: 1200,
        width: 600,
        child: child,
      ),
    ),
  );
}

void main() {
  group('GeneralInspectionReviewStep', () {
    testWidgets('renders system completion checklist with 9 rows',
        (tester) async {
      final formData = GeneralInspectionFormData.empty();

      await tester.pumpWidget(_wrap(
        GeneralInspectionReviewStep(
          formData: formData,
          onChanged: (_) {},
        ),
      ));

      // 9 system ListTiles + 4 SwitchListTile (which contain ListTile) = 13
      // We verify the 9 system names are present instead of counting ListTile.
      expect(find.byType(ListTile), findsAtLeastNWidgets(9));
      expect(find.text('Structural Components'), findsOneWidget);
      expect(find.text('Exterior'), findsOneWidget);
      expect(find.text('Roofing'), findsOneWidget);
      expect(find.text('Plumbing'), findsOneWidget);
      expect(find.text('Electrical'), findsOneWidget);
      expect(find.text('HVAC'), findsOneWidget);
      expect(find.text('Insulation and Ventilation'), findsOneWidget);
      expect(find.text('Built-in Appliances'), findsOneWidget);
      expect(find.text('Life Safety'), findsOneWidget);
    });

    testWidgets('completed system shows check icon', (tester) async {
      final formData = GeneralInspectionFormData.empty().copyWith(
        structural: SystemInspectionData(
          systemId: 'structural',
          systemName: 'Structural Components',
          rating: ConditionRating.satisfactory,
          subsystems: SystemInspectionData.structural().subsystems,
        ),
      );

      await tester.pumpWidget(_wrap(
        GeneralInspectionReviewStep(
          formData: formData,
          onChanged: (_) {},
        ),
      ));

      // Find the ListTile for Structural
      final structuralTile = find.widgetWithText(ListTile, 'Structural Components');
      expect(structuralTile, findsOneWidget);

      // Find the check_circle icon within that tile
      final checkIcon = find.descendant(
        of: structuralTile,
        matching: find.byIcon(Icons.check_circle),
      );
      expect(checkIcon, findsOneWidget);
    });

    testWidgets('unrated system shows cancel icon', (tester) async {
      final formData = GeneralInspectionFormData.empty();

      await tester.pumpWidget(_wrap(
        GeneralInspectionReviewStep(
          formData: formData,
          onChanged: (_) {},
        ),
      ));

      // All 9 systems are unrated, so all should show cancel icon
      expect(find.byIcon(Icons.cancel), findsNWidgets(9));
    });

    testWidgets('general comments text field renders', (tester) async {
      final formData = GeneralInspectionFormData.empty();

      await tester.pumpWidget(_wrap(
        GeneralInspectionReviewStep(
          formData: formData,
          onChanged: (_) {},
        ),
      ));

      expect(
        find.widgetWithText(TextFormField, 'General Comments'),
        findsOneWidget,
      );
    });

    testWidgets('4 SwitchListTile widgets render', (tester) async {
      final formData = GeneralInspectionFormData.empty();

      await tester.pumpWidget(_wrap(
        GeneralInspectionReviewStep(
          formData: formData,
          onChanged: (_) {},
        ),
      ));

      expect(find.byType(SwitchListTile), findsNWidgets(4));
      expect(find.text('Safety Hazard Identified'), findsOneWidget);
      expect(find.text('Moisture/Mold Evidence'), findsOneWidget);
      expect(find.text('Pest Evidence'), findsOneWidget);
      expect(find.text('Structural Concern'), findsOneWidget);
    });

    testWidgets('toggling a branch flag calls onChanged', (tester) async {
      GeneralInspectionFormData? updated;
      final formData = GeneralInspectionFormData.empty();

      await tester.pumpWidget(_wrap(
        GeneralInspectionReviewStep(
          formData: formData,
          onChanged: (data) => updated = data,
        ),
      ));

      // Scroll to make the toggle visible, then tap it
      await tester.scrollUntilVisible(
        find.text('Safety Hazard Identified'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Safety Hazard Identified'));
      await tester.pumpAndSettle();

      expect(updated, isNotNull);
      expect(updated!.safetyHazard, isTrue);
    });

    testWidgets('compliance banner shows when validator finds issues',
        (tester) async {
      // Empty form with no license and no photos — lots of missing elements
      final formData = GeneralInspectionFormData.empty();

      await tester.pumpWidget(_wrap(
        GeneralInspectionReviewStep(
          formData: formData,
          onChanged: (_) {},
          hasInspectorLicense: false,
          photoCounts: const {},
        ),
      ));

      expect(find.text('Missing Required Elements'), findsOneWidget);
    });

    testWidgets('compliance banner hidden when form is compliant',
        (tester) async {
      // Build a fully compliant form
      final formData = GeneralInspectionFormData(
        scopeAndPurpose: 'Full inspection of residential property.',
        generalComments: 'Property is in good condition.',
        structural: SystemInspectionData(
          systemId: 'structural',
          systemName: 'Structural Components',
          rating: ConditionRating.satisfactory,
          subsystems: SystemInspectionData.structural().subsystems,
        ),
        exterior: SystemInspectionData(
          systemId: 'exterior',
          systemName: 'Exterior',
          rating: ConditionRating.satisfactory,
          subsystems: SystemInspectionData.exterior().subsystems,
        ),
        roofing: SystemInspectionData(
          systemId: 'roofing',
          systemName: 'Roofing',
          rating: ConditionRating.satisfactory,
          subsystems: SystemInspectionData.roofing().subsystems,
        ),
        plumbing: SystemInspectionData(
          systemId: 'plumbing',
          systemName: 'Plumbing',
          rating: ConditionRating.satisfactory,
          subsystems: SystemInspectionData.plumbing().subsystems,
        ),
        electrical: SystemInspectionData(
          systemId: 'electrical',
          systemName: 'Electrical',
          rating: ConditionRating.satisfactory,
          subsystems: SystemInspectionData.electrical().subsystems,
        ),
        hvac: SystemInspectionData(
          systemId: 'hvac',
          systemName: 'HVAC',
          rating: ConditionRating.satisfactory,
          subsystems: SystemInspectionData.hvac().subsystems,
        ),
        insulationVentilation: SystemInspectionData(
          systemId: 'insulation_ventilation',
          systemName: 'Insulation and Ventilation',
          rating: ConditionRating.satisfactory,
          subsystems:
              SystemInspectionData.insulationVentilation().subsystems,
        ),
        appliances: const SystemInspectionData(
          systemId: 'appliances',
          systemName: 'Built-in Appliances',
          rating: ConditionRating.satisfactory,
        ),
        lifeSafety: SystemInspectionData(
          systemId: 'life_safety',
          systemName: 'Life Safety',
          rating: ConditionRating.satisfactory,
          subsystems: SystemInspectionData.lifeSafety().subsystems,
        ),
      );

      final photoCounts = <String, int>{
        'structural_photos': 1,
        'exterior_photos': 1,
        'roofing_photos': 1,
        'plumbing_photos': 1,
        'electrical_photos': 1,
        'hvac_photos': 1,
        'insulation_ventilation_photos': 1,
        'appliances_photos': 1,
        'life_safety_photos': 1,
      };

      await tester.pumpWidget(_wrap(
        GeneralInspectionReviewStep(
          formData: formData,
          onChanged: (_) {},
          hasInspectorLicense: true,
          photoCounts: photoCounts,
        ),
      ));

      expect(find.text('Missing Required Elements'), findsNothing);
    });
  });
}
