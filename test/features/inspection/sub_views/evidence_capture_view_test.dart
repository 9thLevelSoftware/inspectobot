import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/common/widgets/widgets.dart';
import 'package:inspectobot/features/inspection/domain/form_requirements.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/inspection_wizard_state.dart';
import 'package:inspectobot/features/inspection/presentation/sub_views/evidence_capture_view.dart';
import 'package:inspectobot/theme/app_theme.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  InspectionWizardState buildState({
    Set<FormType> forms = const {FormType.fourPoint},
    Map<String, bool> completion = const {},
    Map<String, dynamic> branchContext = const {},
  }) {
    return InspectionWizardState(
      enabledForms: forms,
      snapshot: WizardProgressSnapshot(
        lastStepIndex: 0,
        completion: completion,
        branchContext: branchContext,
        status: WizardProgressStatus.inProgress,
      ),
    );
  }

  Widget buildSubject({required InspectionWizardState wizardState}) {
    return MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(
        body: SingleChildScrollView(
          child: EvidenceCaptureView(wizardState: wizardState),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tests
  // ---------------------------------------------------------------------------

  group('EvidenceCaptureView', () {
    testWidgets('renders form summary cards for each enabled form', (
      tester,
    ) async {
      final state = buildState(
        forms: {FormType.fourPoint, FormType.roofCondition},
      );

      await tester.pumpWidget(buildSubject(wizardState: state));

      expect(find.text('Evidence Summary'), findsOneWidget);
      expect(find.text(FormType.fourPoint.label), findsOneWidget);
      expect(find.text(FormType.roofCondition.label), findsOneWidget);
    });

    testWidgets('complete forms show Complete status badge', (tester) async {
      // Complete all four-point requirements
      final requirements = FormRequirements.forFormRequirements(
        FormType.fourPoint,
      );
      final completion = <String, bool>{
        for (final r in requirements) r.key: true,
      };
      final state = buildState(
        forms: {FormType.fourPoint},
        completion: completion,
      );

      await tester.pumpWidget(buildSubject(wizardState: state));

      expect(find.text('Complete'), findsOneWidget);
      expect(find.byType(StatusBadge), findsOneWidget);
    });

    testWidgets('incomplete forms show missing count badge', (tester) async {
      final state = buildState(forms: {FormType.fourPoint});

      await tester.pumpWidget(buildSubject(wizardState: state));

      expect(find.byType(StatusBadge), findsOneWidget);
      expect(find.textContaining('missing'), findsWidgets);
    });

    testWidgets('empty forms list renders info card', (tester) async {
      final state = buildState(forms: {});

      await tester.pumpWidget(buildSubject(wizardState: state));

      expect(find.text('Evidence Summary'), findsOneWidget);
      expect(find.text('No forms enabled'), findsOneWidget);
    });

    testWidgets('multiple forms show mixed completion states', (
      tester,
    ) async {
      // Complete four-point but not roof condition
      final fpRequirements = FormRequirements.forFormRequirements(
        FormType.fourPoint,
      );
      final completion = <String, bool>{
        for (final r in fpRequirements) r.key: true,
      };
      final state = buildState(
        forms: {FormType.fourPoint, FormType.roofCondition},
        completion: completion,
      );

      await tester.pumpWidget(buildSubject(wizardState: state));

      // Should have 2 StatusBadges (one Complete, one X missing)
      expect(find.byType(StatusBadge), findsNWidgets(2));
      expect(find.text('Complete'), findsOneWidget);
      expect(find.textContaining('missing'), findsOneWidget);
    });
  });
}
