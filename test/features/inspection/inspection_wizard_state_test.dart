import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/evidence_requirement.dart';
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
    for (final requirement in FormRequirements.forFormRequirements(FormType.fourPoint)) {
      completion[requirement.key] = true;
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
    for (final requirement in FormRequirements.forFormRequirements(FormType.fourPoint)) {
      completion[requirement.key] = true;
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

  test('roof defect requirement appears only when branch context enables it', () {
    final withoutDefect = InspectionWizardState(
      enabledForms: {FormType.roofCondition},
      snapshot: WizardProgressSnapshot.empty,
    );
    final withDefect = InspectionWizardState(
      enabledForms: {FormType.roofCondition},
      snapshot: WizardProgressSnapshot(
        lastStepIndex: 0,
        completion: const <String, bool>{},
        branchContext: const <String, dynamic>{
          FormRequirements.roofDefectPresentBranchFlag: true,
        },
        status: WizardProgressStatus.inProgress,
      ),
    );

    final roofStepWithout = withoutDefect.steps.firstWhere((step) => step.form == FormType.roofCondition);
    final roofStepWith = withDefect.steps.firstWhere((step) => step.form == FormType.roofCondition);

    expect(
      roofStepWithout.requirements.any((requirement) => requirement.key == 'photo:roof_defect'),
      isFalse,
    );
    expect(
      roofStepWith.requirements.any((requirement) => requirement.key == 'photo:roof_defect'),
      isTrue,
    );
  });

  test('wind mitigation step includes document requirements when triggered', () {
    final state = InspectionWizardState(
      enabledForms: {FormType.windMitigation},
      snapshot: WizardProgressSnapshot(
        lastStepIndex: 0,
        completion: const <String, bool>{},
        branchContext: const <String, dynamic>{
          FormRequirements.windRoofDeckDocumentRequiredBranchFlag: true,
          FormRequirements.windOpeningDocumentRequiredBranchFlag: true,
          FormRequirements.windPermitDocumentRequiredBranchFlag: true,
        },
        status: WizardProgressStatus.inProgress,
      ),
    );

    final windStep = state.steps.firstWhere((step) => step.form == FormType.windMitigation);
    final docs = windStep.requirements
        .where((requirement) => requirement.mediaType == EvidenceMediaType.document)
        .map((requirement) => requirement.key)
        .toSet();

    expect(docs, contains('document:wind_roof_deck'));
    expect(docs, contains('document:wind_opening_protection'));
    expect(docs, contains('document:wind_permit_year'));
  });

  test('form summaries keep conditional wind docs after resume', () {
    final resumed = InspectionWizardState(
      enabledForms: {FormType.windMitigation},
      snapshot: WizardProgressSnapshot(
        lastStepIndex: 1,
        completion: const <String, bool>{
          'photo:wind_roof_deck': true,
        },
        branchContext: const <String, dynamic>{
          FormRequirements.windRoofDeckDocumentRequiredBranchFlag: true,
          FormRequirements.windOpeningDocumentRequiredBranchFlag: true,
        },
        status: WizardProgressStatus.inProgress,
      ),
    );

    final summary = resumed.buildFormSummaries().single;
    final missingKeys = summary.missingRequirements
        .map((requirement) => requirement.key)
        .toSet();

    expect(missingKeys, contains('document:wind_roof_deck'));
    expect(missingKeys, contains('document:wind_opening_protection'));
  });
}
