import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inspectobot/features/inspection/domain/condition_rating.dart';
import 'package:inspectobot/features/inspection/domain/system_inspection_data.dart';
import 'package:inspectobot/features/inspection/presentation/sub_views/general_inspection_system_step.dart';
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
  group('GeneralInspectionSystemStep', () {
    testWidgets('renders system name in SectionHeader', (tester) async {
      final system = SystemInspectionData.structural();

      await tester.pumpWidget(_wrap(
        GeneralInspectionSystemStep(
          systemData: system,
          onChanged: (_) {},
        ),
      ));

      expect(find.text('Structural Components'), findsAtLeastNWidgets(1));
    });

    testWidgets('renders 4 rating segments', (tester) async {
      final system = SystemInspectionData.appliances();

      await tester.pumpWidget(_wrap(
        GeneralInspectionSystemStep(
          systemData: system,
          onChanged: (_) {},
        ),
      ));

      expect(find.text('Satisfactory'), findsAtLeastNWidgets(1));
      expect(find.text('Marginal'), findsAtLeastNWidgets(1));
      expect(find.text('Deficient'), findsAtLeastNWidgets(1));
      expect(find.text('N/A'), findsAtLeastNWidgets(1));
    });

    testWidgets('rating change calls onChanged with updated system',
        (tester) async {
      SystemInspectionData? updated;
      final system = SystemInspectionData.appliances();

      await tester.pumpWidget(_wrap(
        GeneralInspectionSystemStep(
          systemData: system,
          onChanged: (data) => updated = data,
        ),
      ));

      // Tap the Satisfactory segment
      await tester.tap(find.text('Satisfactory'));
      await tester.pumpAndSettle();

      expect(updated, isNotNull);
      expect(updated!.rating, ConditionRating.satisfactory);
    });

    testWidgets('findings text field renders with initial value',
        (tester) async {
      final system = SystemInspectionData(
        systemId: 'appliances',
        systemName: 'Built-in Appliances',
        findings: 'Dishwasher leaking',
      );

      await tester.pumpWidget(_wrap(
        GeneralInspectionSystemStep(
          systemData: system,
          onChanged: (_) {},
        ),
      ));

      expect(find.text('Dishwasher leaking'), findsOneWidget);
    });

    testWidgets('system with subsystems renders ExpansionTile per subsystem',
        (tester) async {
      final system = SystemInspectionData.structural();

      await tester.pumpWidget(_wrap(
        GeneralInspectionSystemStep(
          systemData: system,
          onChanged: (_) {},
        ),
      ));

      // Structural has 3 subsystems: Foundation, Framing, Roof Structure
      expect(find.byType(ExpansionTile), findsNWidgets(3));
      expect(find.text('Foundation'), findsOneWidget);
      expect(find.text('Framing'), findsOneWidget);
      expect(find.text('Roof Structure'), findsOneWidget);
    });

    testWidgets(
        'system with 0 subsystems (Appliances) does NOT render subsystem section',
        (tester) async {
      final system = SystemInspectionData.appliances();

      await tester.pumpWidget(_wrap(
        GeneralInspectionSystemStep(
          systemData: system,
          onChanged: (_) {},
        ),
      ));

      expect(find.byType(ExpansionTile), findsNothing);
      expect(find.text('Sub-components'), findsNothing);
    });

    testWidgets('subsystem rating change calls onChanged correctly',
        (tester) async {
      SystemInspectionData? updated;
      final system = SystemInspectionData.plumbing();

      await tester.pumpWidget(_wrap(
        GeneralInspectionSystemStep(
          systemData: system,
          onChanged: (data) => updated = data,
        ),
      ));

      // There are multiple 'Satisfactory' texts — one for system-level and one
      // per subsystem. Find all SegmentedButtons and tap on the second one's
      // Satisfactory segment (first subsystem).
      final segmentedButtons = find.byType(SegmentedButton<ConditionRating>);
      // First is system-level, 2nd+ are subsystem-level
      expect(segmentedButtons, findsAtLeastNWidgets(2));

      // Tap the 'Marginal' in the second SegmentedButton (first subsystem)
      final secondSegmented = segmentedButtons.at(1);
      final marginalInSubsystem = find.descendant(
        of: secondSegmented,
        matching: find.text('Marginal'),
      );
      await tester.tap(marginalInSubsystem);
      await tester.pumpAndSettle();

      expect(updated, isNotNull);
      // First subsystem (Supply) should now be marginal
      expect(updated!.subsystems[0].rating, ConditionRating.marginal);
      // Other subsystems unchanged
      expect(
        updated!.subsystems[1].rating,
        ConditionRating.notInspected,
      );
    });
  });
}
