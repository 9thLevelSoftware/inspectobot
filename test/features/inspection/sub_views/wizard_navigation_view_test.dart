import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/common/widgets/widgets.dart';
import 'package:inspectobot/features/inspection/domain/evidence_requirement.dart';
import 'package:inspectobot/features/inspection/domain/form_requirements.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/inspection_wizard_state.dart';
import 'package:inspectobot/features/inspection/presentation/sub_views/wizard_navigation_view.dart';
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

  Widget buildSubject({
    required InspectionWizardState wizardState,
    int currentStepIndex = 0,
    WizardProgressSnapshot? snapshot,
    bool isSavingProgress = false,
    void Function(EvidenceRequirement)? onCapture,
    VoidCallback? onContinue,
    void Function(String, bool)? onSetBranchFlag,
  }) {
    return MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(
        body: SizedBox(
          height: 800,
          child: WizardNavigationView(
            wizardState: wizardState,
            currentStepIndex: currentStepIndex,
            snapshot: snapshot ??
                WizardProgressSnapshot(
                  lastStepIndex: 0,
                  completion: const {},
                  branchContext: const {},
                  status: WizardProgressStatus.inProgress,
                ),
            isSavingProgress: isSavingProgress,
            onCapture: onCapture ?? (_) {},
            onContinue: onContinue ?? () {},
            onSetBranchFlag: onSetBranchFlag ?? (_, __) {},
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tests
  // ---------------------------------------------------------------------------

  group('WizardNavigationView', () {
    testWidgets('displays correct step header', (tester) async {
      final state = buildState();

      await tester.pumpWidget(buildSubject(
        wizardState: state,
        currentStepIndex: 0,
      ));

      expect(
        find.text('Step 1 of ${state.steps.length}: ${state.steps[0].title}'),
        findsOneWidget,
      );
    });

    testWidgets('displays step header for second step', (tester) async {
      final state = buildState();

      await tester.pumpWidget(buildSubject(
        wizardState: state,
        currentStepIndex: 1,
      ));

      expect(
        find.text('Step 2 of ${state.steps.length}: ${state.steps[1].title}'),
        findsOneWidget,
      );
    });

    testWidgets('shows branch flag toggles for four-point form', (
      tester,
    ) async {
      final state = buildState(forms: {FormType.fourPoint});

      await tester.pumpWidget(buildSubject(
        wizardState: state,
        currentStepIndex: 1, // form step
      ));

      // hazard_present is the branch flag for four-point
      expect(find.text('Hazard present?'), findsOneWidget);
    });

    testWidgets('evidence requirement cards render with captured state', (
      tester,
    ) async {
      final requirements = FormRequirements.forFormRequirements(
        FormType.fourPoint,
      );
      final firstKey = requirements.first.key;
      final completion = <String, bool>{firstKey: true};
      final state = buildState(completion: completion);

      await tester.pumpWidget(buildSubject(
        wizardState: state,
        currentStepIndex: 1,
        snapshot: WizardProgressSnapshot(
          lastStepIndex: 0,
          completion: completion,
          branchContext: const {},
          status: WizardProgressStatus.inProgress,
        ),
      ));

      // At least one card should show 'Captured'
      expect(find.text('Captured'), findsAtLeastNWidgets(1));
      // Others should show 'Missing required item'
      expect(find.text('Missing required item'), findsWidgets);
    });

    testWidgets('Continue button is disabled when saving', (tester) async {
      final state = buildState();

      await tester.pumpWidget(buildSubject(
        wizardState: state,
        currentStepIndex: 0,
        isSavingProgress: true,
      ));

      // AppButton wraps the continue action
      final appButton = tester.widget<AppButton>(find.byType(AppButton));
      expect(appButton.onPressed, isNull);
      expect(appButton.isLoading, isTrue);
      expect(find.text('Saving...'), findsOneWidget);
    });

    testWidgets('shows "Finish Wizard" on last step', (tester) async {
      final state = buildState(forms: {FormType.fourPoint});
      final lastIndex = state.steps.length - 1;

      // Complete all requirements so the button text shows
      final requirements = FormRequirements.forFormRequirements(
        FormType.fourPoint,
      );
      final completion = <String, bool>{
        for (final r in requirements) r.key: true,
      };
      final completedState = buildState(completion: completion);

      await tester.pumpWidget(buildSubject(
        wizardState: completedState,
        currentStepIndex: lastIndex,
        snapshot: WizardProgressSnapshot(
          lastStepIndex: lastIndex,
          completion: completion,
          branchContext: const {},
          status: WizardProgressStatus.inProgress,
        ),
      ));

      expect(find.text('Finish Wizard'), findsOneWidget);
    });

    testWidgets('onCapture callback fires when capture button tapped', (
      tester,
    ) async {
      EvidenceRequirement? capturedRequirement;
      final state = buildState();

      await tester.pumpWidget(buildSubject(
        wizardState: state,
        currentStepIndex: 1, // form step with requirements
        onCapture: (r) => capturedRequirement = r,
      ));

      // Assert capture buttons exist -- do not silently skip
      final captureButtons = find.text('Capture');
      expect(
        captureButtons,
        findsAtLeastNWidgets(1),
        reason: 'Step 1 should have at least one Capture button',
      );
      await tester.tap(captureButtons.first);
      await tester.pump();
      expect(capturedRequirement, isNotNull);
    });

    testWidgets('onSetBranchFlag callback fires when toggle is tapped', (
      tester,
    ) async {
      String? flagKeyReceived;
      bool? flagValueReceived;
      final state = buildState(forms: {FormType.fourPoint});

      await tester.pumpWidget(buildSubject(
        wizardState: state,
        currentStepIndex: 1, // form step with branch flag
        onSetBranchFlag: (key, value) {
          flagKeyReceived = key;
          flagValueReceived = value;
        },
      ));

      // The hazard_present branch flag toggle should exist
      final toggle = find.byKey(const ValueKey('branch-flag-hazard_present'));
      expect(toggle, findsOneWidget);

      await tester.tap(toggle);
      await tester.pump();

      expect(flagKeyReceived, 'hazard_present');
      expect(flagValueReceived, isTrue);
    });

    testWidgets('onContinue callback fires when continue button tapped', (
      tester,
    ) async {
      var continueCalled = false;
      final state = buildState();

      await tester.pumpWidget(buildSubject(
        wizardState: state,
        currentStepIndex: 0, // overview step (no requirements = can advance)
        onContinue: () => continueCalled = true,
      ));

      await tester.tap(find.text('Continue to Next Step'));
      await tester.pump();
      expect(continueCalled, isTrue);
    });
  });
}
