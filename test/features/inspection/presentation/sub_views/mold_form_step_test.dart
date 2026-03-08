import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inspectobot/features/inspection/domain/mold_form_data.dart';
import 'package:inspectobot/features/inspection/presentation/sub_views/mold_form_step.dart';
import 'package:inspectobot/features/inspection/presentation/sub_views/mold_moisture_step.dart';
import 'package:inspectobot/features/inspection/presentation/sub_views/mold_observations_step.dart';
import 'package:inspectobot/features/inspection/presentation/sub_views/mold_remediation_step.dart';
import 'package:inspectobot/features/inspection/presentation/sub_views/mold_scope_step.dart';
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
  group('MoldFormStep', () {
    testWidgets('renders all 5 tabs', (tester) async {
      await tester.pumpWidget(_wrap(
        MoldFormStep(
          formData: MoldFormData.empty(),
          onChanged: (_) {},
        ),
      ));

      final tabs = tester.widgetList<Tab>(find.byType(Tab)).toList();
      expect(tabs.length, 5);
      expect(find.text('Scope'), findsOneWidget);
      expect(find.text('Observations'), findsOneWidget);
      expect(find.text('Moisture'), findsOneWidget);
      expect(find.text('Type/Location'), findsOneWidget);
      expect(find.text('Remediation'), findsOneWidget);
    });

    testWidgets('tab switching shows correct step content', (tester) async {
      await tester.pumpWidget(_wrap(
        MoldFormStep(
          formData: MoldFormData.empty(),
          onChanged: (_) {},
        ),
      ));

      // Initially on Scope tab
      expect(find.text('Scope of Assessment'), findsAtLeastNWidgets(1));

      // Tap Observations tab
      await tester.tap(find.descendant(
        of: find.byType(TabBar),
        matching: find.text('Observations'),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Visual Observations'), findsAtLeastNWidgets(1));

      // Tap Moisture tab
      await tester.tap(find.descendant(
        of: find.byType(TabBar),
        matching: find.text('Moisture'),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Moisture Sources'), findsAtLeastNWidgets(1));

      // Tap Type/Location tab
      await tester.tap(find.descendant(
        of: find.byType(TabBar),
        matching: find.text('Type/Location'),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Mold Type & Location'), findsAtLeastNWidgets(1));

      // Tap Remediation tab
      await tester.tap(find.descendant(
        of: find.byType(TabBar),
        matching: find.text('Remediation'),
      ));
      await tester.pumpAndSettle();
      expect(
        find.text('Remediation Recommendations'),
        findsAtLeastNWidgets(1),
      );
    });
  });

  group('MoldScopeStep', () {
    testWidgets('renders TextFormField with initial value from formData',
        (tester) async {
      final data = MoldFormData.empty().copyWith(
        scopeOfAssessment: 'Kitchen and bathrooms inspected',
      );

      await tester.pumpWidget(_wrap(
        MoldScopeStep(formData: data, onChanged: (_) {}),
      ));

      expect(
        find.text('Kitchen and bathrooms inspected'),
        findsOneWidget,
      );
    });

    testWidgets('onChanged fires with updated formData when text changes',
        (tester) async {
      MoldFormData? updated;

      await tester.pumpWidget(_wrap(
        MoldScopeStep(
          formData: MoldFormData.empty(),
          onChanged: (data) => updated = data,
        ),
      ));

      await tester.enterText(find.byType(TextFormField), 'Full scope');
      expect(updated, isNotNull);
      expect(updated!.scopeOfAssessment, 'Full scope');
    });
  });

  group('MoldObservationsStep', () {
    testWidgets('renders TextFormField with initial value', (tester) async {
      final data = MoldFormData.empty().copyWith(
        visualObservations: 'Black spots on ceiling',
      );

      await tester.pumpWidget(_wrap(
        MoldObservationsStep(formData: data, onChanged: (_) {}),
      ));

      expect(find.text('Black spots on ceiling'), findsOneWidget);
    });
  });

  group('MoldMoistureStep', () {
    testWidgets('renders airSamplesTaken toggle', (tester) async {
      await tester.pumpWidget(_wrap(
        MoldMoistureStep(
          formData: MoldFormData.empty(),
          onChanged: (_) {},
        ),
      ));

      expect(
        find.text('Air samples were collected during this assessment'),
        findsOneWidget,
      );
      expect(find.byType(SwitchListTile), findsOneWidget);
    });

    testWidgets('toggle fires onChanged with updated flag', (tester) async {
      MoldFormData? updated;

      await tester.pumpWidget(_wrap(
        MoldMoistureStep(
          formData: MoldFormData.empty(),
          onChanged: (data) => updated = data,
        ),
      ));

      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      expect(updated, isNotNull);
      expect(updated!.airSamplesTaken, isTrue);
    });
  });

  group('MoldTypeLocationStep', () {
    testWidgets('renders TextFormField with initial value', (tester) async {
      final data = MoldFormData.empty().copyWith(
        moldTypeLocation: 'Aspergillus in bathroom',
      );

      await tester.pumpWidget(_wrap(
        MoldTypeLocationStep(formData: data, onChanged: (_) {}),
      ));

      expect(find.text('Aspergillus in bathroom'), findsOneWidget);
    });
  });

  group('MoldRemediationStep', () {
    testWidgets('hides remediation TextFormField when remediationRecommended is false',
        (tester) async {
      await tester.pumpWidget(_wrap(
        MoldRemediationStep(
          formData: MoldFormData.empty(),
          onChanged: (_) {},
        ),
      ));

      // Should show the additional findings field but NOT the remediation
      // recommendations field. Both are TextFormField, so we check by label.
      expect(
        find.widgetWithText(TextFormField, 'Remediation Recommendations'),
        findsNothing,
      );
      expect(
        find.widgetWithText(TextFormField, 'Additional Findings (Optional)'),
        findsOneWidget,
      );
    });

    testWidgets('shows remediation TextFormField when remediationRecommended is true',
        (tester) async {
      final data = MoldFormData.empty().copyWith(
        remediationRecommended: true,
      );

      await tester.pumpWidget(_wrap(
        MoldRemediationStep(formData: data, onChanged: (_) {}),
      ));

      expect(
        find.widgetWithText(TextFormField, 'Remediation Recommendations'),
        findsOneWidget,
      );
    });

    testWidgets('toggle fires onChanged with updated flag', (tester) async {
      MoldFormData? updated;

      await tester.pumpWidget(_wrap(
        MoldRemediationStep(
          formData: MoldFormData.empty(),
          onChanged: (data) => updated = data,
        ),
      ));

      // Tap the remediation recommended switch
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      expect(updated, isNotNull);
      expect(updated!.remediationRecommended, isTrue);
    });

    testWidgets('renders additionalFindings field', (tester) async {
      await tester.pumpWidget(_wrap(
        MoldRemediationStep(
          formData: MoldFormData.empty(),
          onChanged: (_) {},
        ),
      ));

      expect(
        find.widgetWithText(TextFormField, 'Additional Findings (Optional)'),
        findsOneWidget,
      );
    });
  });
}
