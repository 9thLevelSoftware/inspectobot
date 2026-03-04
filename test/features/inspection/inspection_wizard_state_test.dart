import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/form_requirements.dart';
import 'package:inspectobot/features/inspection/domain/inspection_wizard_state.dart';

void main() {
  test('branch-driven steps include only selected forms', () {
    final state = InspectionWizardState(
      enabledForms: {FormType.fourPoint, FormType.windMitigation},
      snapshot: WizardProgressSnapshot.empty,
    );

    expect(state.steps.map((step) => step.id), contains('form_four_point'));
    expect(state.steps.map((step) => step.id), contains('form_wind_mitigation'));
    expect(state.steps.map((step) => step.id), isNot(contains('form_roof_condition')));
  });

  test('linear progression blocks continue when current step incomplete', () {
    final state = InspectionWizardState(
      enabledForms: {FormType.fourPoint},
      snapshot: WizardProgressSnapshot.empty,
    );

    expect(state.canAdvanceFrom(1), isFalse);
    expect(state.resolveNextIncompleteStep(), 1);
  });

  test('resolveNextIncompleteStep returns first incomplete form step', () {
    final completion = <String, bool>{};
    for (final key in FormRequirements.requirementKeysForForm(FormType.fourPoint)) {
      completion[key] = true;
    }
    final state = InspectionWizardState(
      enabledForms: {FormType.fourPoint, FormType.roofCondition},
      snapshot: WizardProgressSnapshot(
        lastStepIndex: 0,
        completion: completion,
        branchContext: const <String, dynamic>{},
        status: WizardProgressStatus.inProgress,
      ),
    );

    expect(state.resolveNextIncompleteStep(), 2);
  });

  test('wizard is complete when all enabled form requirements are met', () {
    final completion = <String, bool>{};
    for (final key in FormRequirements.requirementKeysForForm(FormType.fourPoint)) {
      completion[key] = true;
    }
    final state = InspectionWizardState(
      enabledForms: {FormType.fourPoint},
      snapshot: WizardProgressSnapshot(
        lastStepIndex: 1,
        completion: completion,
        branchContext: const <String, dynamic>{},
        status: WizardProgressStatus.inProgress,
      ),
    );

    expect(state.isComplete, isTrue);
  });
}
