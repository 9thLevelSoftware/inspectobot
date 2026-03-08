import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/inspection_wizard_state.dart';
import 'package:inspectobot/features/inspection/domain/mold_form_data.dart';
import 'package:inspectobot/features/inspection/presentation/sub_views/mold_form_step.dart';
import 'package:inspectobot/features/inspection/presentation/sub_views/sinkhole_form_step.dart';
import 'package:inspectobot/features/inspection/presentation/sub_views/wdo_form_step.dart';
import 'package:inspectobot/features/inspection/presentation/sub_views/wizard_navigation_view.dart';
import 'package:inspectobot/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

InspectionWizardState _buildWizardState(Set<FormType> forms) {
  return InspectionWizardState(
    enabledForms: forms,
    snapshot: WizardProgressSnapshot.empty,
  );
}

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(body: child),
  );
}

/// Builds a [WizardNavigationView] pointing at the form step (index 1)
/// for the given [forms] set.
Widget _buildView({
  required Set<FormType> forms,
  MoldFormData? moldFormData,
  ValueChanged<MoldFormData>? onMoldChanged,
  Map<FormType, Map<String, dynamic>>? formData,
  void Function(FormType, String, dynamic)? onFieldChanged,
}) {
  final wizardState = _buildWizardState(forms);
  // Index 1 is the first form step (index 0 is Inspection Overview).
  return _wrap(
    WizardNavigationView(
      wizardState: wizardState,
      currentStepIndex: 1,
      snapshot: WizardProgressSnapshot.empty,
      isSavingProgress: false,
      onCapture: (_) {},
      onContinue: () {},
      onSetBranchFlag: (_, _) {},
      formData: formData,
      onFieldChanged: onFieldChanged,
      moldFormData: moldFormData,
      onMoldChanged: onMoldChanged,
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('WizardNavigationView — Mold routing', () {
    testWidgets('renders MoldFormStep for moldAssessment form type',
        (tester) async {
      await tester.pumpWidget(_buildView(
        forms: {FormType.moldAssessment},
        moldFormData: MoldFormData.empty(),
        onMoldChanged: (_) {},
      ));

      expect(find.byType(MoldFormStep), findsOneWidget);
      // Should NOT render WDO or Sinkhole form steps.
      expect(find.byType(WdoFormStep), findsNothing);
      expect(find.byType(SinkholeFormStep), findsNothing);
    });

    testWidgets('MoldFormStep receives MoldFormData from parent',
        (tester) async {
      final data = MoldFormData.empty().copyWith(
        scopeOfAssessment: 'Full property mold assessment',
      );

      await tester.pumpWidget(_buildView(
        forms: {FormType.moldAssessment},
        moldFormData: data,
        onMoldChanged: (_) {},
      ));

      // MoldFormStep should pass data down to MoldScopeStep which renders it.
      expect(find.text('Full property mold assessment'), findsOneWidget);
    });

    testWidgets('editing text fires onMoldChanged callback', (tester) async {
      MoldFormData? captured;

      await tester.pumpWidget(_buildView(
        forms: {FormType.moldAssessment},
        moldFormData: MoldFormData.empty(),
        onMoldChanged: (data) => captured = data,
      ));

      // The first tab (Scope) should show a TextFormField.
      final textField = find.byType(TextFormField);
      expect(textField, findsAtLeastNWidgets(1));

      await tester.enterText(textField.first, 'Kitchen inspection');

      expect(captured, isNotNull);
      expect(captured!.scopeOfAssessment, 'Kitchen inspection');
    });

    testWidgets('branch flag toggle updates controller state', (tester) async {
      MoldFormData? captured;

      await tester.pumpWidget(_buildView(
        forms: {FormType.moldAssessment},
        moldFormData: MoldFormData.empty(),
        onMoldChanged: (data) => captured = data,
      ));

      // Navigate to Remediation tab which has a SwitchListTile for
      // remediationRecommended.
      await tester.tap(find.descendant(
        of: find.byType(TabBar),
        matching: find.text('Remediation'),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SwitchListTile).first);
      await tester.pumpAndSettle();

      expect(captured, isNotNull);
      expect(captured!.remediationRecommended, isTrue);
    });
  });

  group('WizardNavigationView — regression checks', () {
    testWidgets('WDO routing still works', (tester) async {
      await tester.pumpWidget(_buildView(
        forms: {FormType.wdo},
        formData: {FormType.wdo: <String, dynamic>{}},
        onFieldChanged: (_, _, _) {},
      ));

      expect(find.byType(WdoFormStep), findsOneWidget);
      expect(find.byType(MoldFormStep), findsNothing);
    });

    testWidgets('Sinkhole routing still works', (tester) async {
      await tester.pumpWidget(_buildView(
        forms: {FormType.sinkholeInspection},
        formData: {FormType.sinkholeInspection: <String, dynamic>{}},
        onFieldChanged: (_, _, _) {},
      ));

      expect(find.byType(SinkholeFormStep), findsOneWidget);
      expect(find.byType(MoldFormStep), findsNothing);
    });
  });
}
