import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/form_requirements.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/inspection_wizard_state.dart';

/// Wizard lifecycle integration tests exercising step construction,
/// progression, completion tracking, and form readiness across all 7
/// form types.
void main() {
  // ---------------------------------------------------------------------------
  // Per-form-type wizard lifecycle
  // ---------------------------------------------------------------------------

  group('fourPoint wizard lifecycle', () {
    test('constructs correct steps for fourPoint', () {
      final state = InspectionWizardState(
        enabledForms: {FormType.fourPoint},
        snapshot: WizardProgressSnapshot.empty,
      );

      expect(state.steps.length, 2); // overview + form step
      expect(state.steps[0].id, 'inspection_overview');
      expect(state.steps[1].id, 'form_four_point');
      expect(state.steps[1].form, FormType.fourPoint);
    });

    test('completes when all fourPoint requirements met', () {
      final requirements = FormRequirements.forFormRequirements(FormType.fourPoint);
      final completion = <String, bool>{
        for (final req in requirements) req.key: true,
      };

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

    test('includes hazard photo when branch flag set', () {
      final state = InspectionWizardState(
        enabledForms: {FormType.fourPoint},
        snapshot: WizardProgressSnapshot(
          lastStepIndex: 0,
          completion: const <String, bool>{},
          branchContext: const <String, dynamic>{
            'hazard_present': true,
          },
          status: WizardProgressStatus.inProgress,
        ),
      );

      final formStep = state.steps.firstWhere(
        (s) => s.form == FormType.fourPoint,
      );
      expect(
        formStep.requirements.any((r) => r.key == 'photo:hazard_photo'),
        isTrue,
      );
    });

    test('excludes hazard photo when branch flag not set', () {
      final state = InspectionWizardState(
        enabledForms: {FormType.fourPoint},
        snapshot: WizardProgressSnapshot.empty,
      );

      final formStep = state.steps.firstWhere(
        (s) => s.form == FormType.fourPoint,
      );
      expect(
        formStep.requirements.any((r) => r.key == 'photo:hazard_photo'),
        isFalse,
      );
    });
  });

  group('roofCondition wizard lifecycle', () {
    test('constructs correct steps', () {
      final state = InspectionWizardState(
        enabledForms: {FormType.roofCondition},
        snapshot: WizardProgressSnapshot.empty,
      );

      expect(state.steps.length, 2);
      expect(state.steps[1].id, 'form_roof_condition');
    });

    test('completes with all base requirements', () {
      final requirements = FormRequirements.forFormRequirements(
        FormType.roofCondition,
      );
      final completion = <String, bool>{
        for (final req in requirements) req.key: true,
      };

      final state = InspectionWizardState(
        enabledForms: {FormType.roofCondition},
        snapshot: WizardProgressSnapshot(
          lastStepIndex: 1,
          completion: completion,
          branchContext: const <String, dynamic>{},
          status: WizardProgressStatus.inProgress,
        ),
      );

      expect(state.isComplete, isTrue);
    });

    test('includes defect photo when branch flag set', () {
      final state = InspectionWizardState(
        enabledForms: {FormType.roofCondition},
        snapshot: WizardProgressSnapshot(
          lastStepIndex: 0,
          completion: const <String, bool>{},
          branchContext: const <String, dynamic>{
            'roof_defect_present': true,
          },
          status: WizardProgressStatus.inProgress,
        ),
      );

      final formStep = state.steps.firstWhere(
        (s) => s.form == FormType.roofCondition,
      );
      expect(
        formStep.requirements.any((r) => r.key == 'photo:roof_defect'),
        isTrue,
      );
    });
  });

  group('windMitigation wizard lifecycle', () {
    test('constructs correct steps', () {
      final state = InspectionWizardState(
        enabledForms: {FormType.windMitigation},
        snapshot: WizardProgressSnapshot.empty,
      );

      expect(state.steps.length, 2);
      expect(state.steps[1].id, 'form_wind_mitigation');
    });

    test('includes all 3 document requirements when all branch flags set', () {
      final state = InspectionWizardState(
        enabledForms: {FormType.windMitigation},
        snapshot: WizardProgressSnapshot(
          lastStepIndex: 0,
          completion: const <String, bool>{},
          branchContext: const <String, dynamic>{
            'wind_roof_deck_document_required': true,
            'wind_opening_document_required': true,
            'wind_permit_document_required': true,
          },
          status: WizardProgressStatus.inProgress,
        ),
      );

      final formStep = state.steps.firstWhere(
        (s) => s.form == FormType.windMitigation,
      );
      final docKeys = formStep.requirements
          .where((r) => r.key.startsWith('document:'))
          .map((r) => r.key)
          .toSet();

      expect(docKeys, contains('document:wind_roof_deck'));
      expect(docKeys, contains('document:wind_opening_protection'));
      expect(docKeys, contains('document:wind_permit_year'));
    });

    test('excludes document requirements without branch flags', () {
      final state = InspectionWizardState(
        enabledForms: {FormType.windMitigation},
        snapshot: WizardProgressSnapshot.empty,
      );

      final formStep = state.steps.firstWhere(
        (s) => s.form == FormType.windMitigation,
      );
      final docKeys = formStep.requirements
          .where((r) => r.key.startsWith('document:'))
          .map((r) => r.key)
          .toSet();

      expect(docKeys, isEmpty);
    });
  });

  group('wdo wizard lifecycle', () {
    test('constructs correct steps', () {
      final state = InspectionWizardState(
        enabledForms: {FormType.wdo},
        snapshot: WizardProgressSnapshot.empty,
      );

      expect(state.steps.length, 2);
      expect(state.steps[1].id, 'form_wdo');
    });

    test('includes conditional photos when branch flags set', () {
      final state = InspectionWizardState(
        enabledForms: {FormType.wdo},
        snapshot: WizardProgressSnapshot(
          lastStepIndex: 0,
          completion: const <String, bool>{},
          branchContext: const <String, dynamic>{
            'wdo_visible_evidence': true,
            'wdo_damage_by_wdo': true,
            'wdo_attic_inaccessible': true,
          },
          status: WizardProgressStatus.inProgress,
        ),
      );

      final formStep = state.steps.firstWhere(
        (s) => s.form == FormType.wdo,
      );
      final keys = formStep.requirements.map((r) => r.key).toSet();

      expect(keys, contains('photo:wdo_infestation_evidence'));
      expect(keys, contains('photo:wdo_damage_area'));
      expect(keys, contains('photo:wdo_inaccessible_area'));
    });

    test('base-only requirements when no branch flags', () {
      final state = InspectionWizardState(
        enabledForms: {FormType.wdo},
        snapshot: WizardProgressSnapshot.empty,
      );

      final formStep = state.steps.firstWhere(
        (s) => s.form == FormType.wdo,
      );
      final keys = formStep.requirements.map((r) => r.key).toSet();

      expect(keys, contains('photo:wdo_property_exterior'));
      expect(keys, contains('photo:wdo_notice_posting'));
      expect(keys, isNot(contains('photo:wdo_infestation_evidence')));
      expect(keys, isNot(contains('photo:wdo_damage_area')));
      expect(keys, isNot(contains('photo:wdo_inaccessible_area')));
    });

    test('completes when all WDO requirements met with branches', () {
      final branchContext = <String, dynamic>{
        'wdo_visible_evidence': true,
        'wdo_damage_by_wdo': true,
        'wdo_attic_inaccessible': true,
      };
      final requirements = FormRequirements.forFormRequirements(
        FormType.wdo,
        branchContext: branchContext,
      );
      final completion = <String, bool>{
        for (final req in requirements) req.key: true,
      };

      final state = InspectionWizardState(
        enabledForms: {FormType.wdo},
        snapshot: WizardProgressSnapshot(
          lastStepIndex: 1,
          completion: completion,
          branchContext: branchContext,
          status: WizardProgressStatus.inProgress,
        ),
      );

      expect(state.isComplete, isTrue);
    });
  });

  group('sinkholeInspection wizard lifecycle', () {
    test('constructs correct steps', () {
      final state = InspectionWizardState(
        enabledForms: {FormType.sinkholeInspection},
        snapshot: WizardProgressSnapshot.empty,
      );

      expect(state.steps.length, 2);
      expect(state.steps[1].id, 'form_sinkhole_inspection');
    });

    test('includes checklist and conditional photos when flags set', () {
      final state = InspectionWizardState(
        enabledForms: {FormType.sinkholeInspection},
        snapshot: WizardProgressSnapshot(
          lastStepIndex: 0,
          completion: const <String, bool>{},
          branchContext: const <String, dynamic>{
            'sinkhole_any_exterior_yes': true,
            'sinkhole_any_garage_yes': true,
            'sinkhole_townhouse': true,
          },
          status: WizardProgressStatus.inProgress,
        ),
      );

      final formStep = state.steps.firstWhere(
        (s) => s.form == FormType.sinkholeInspection,
      );
      final keys = formStep.requirements.map((r) => r.key).toSet();

      expect(keys, contains('photo:sinkhole_front_elevation'));
      expect(keys, contains('photo:sinkhole_rear_elevation'));
      expect(keys, contains('photo:sinkhole_checklist_item'));
      expect(keys, contains('photo:sinkhole_garage_crack'));
      expect(keys, contains('photo:sinkhole_adjacent_structure'));
    });

    test('base-only requirements when no branch flags', () {
      final state = InspectionWizardState(
        enabledForms: {FormType.sinkholeInspection},
        snapshot: WizardProgressSnapshot.empty,
      );

      final formStep = state.steps.firstWhere(
        (s) => s.form == FormType.sinkholeInspection,
      );
      final keys = formStep.requirements.map((r) => r.key).toSet();

      expect(keys, contains('photo:sinkhole_front_elevation'));
      expect(keys, contains('photo:sinkhole_rear_elevation'));
      // Conditional photos absent
      expect(keys, isNot(contains('photo:sinkhole_checklist_item')));
      expect(keys, isNot(contains('photo:sinkhole_garage_crack')));
      expect(keys, isNot(contains('photo:sinkhole_adjacent_structure')));
    });
  });

  group('moldAssessment wizard lifecycle', () {
    test('constructs correct steps', () {
      final state = InspectionWizardState(
        enabledForms: {FormType.moldAssessment},
        snapshot: WizardProgressSnapshot.empty,
      );

      expect(state.steps.length, 2);
      expect(state.steps[1].id, 'form_mold_assessment');
    });

    test('includes moisture source and lab report when flags set', () {
      final state = InspectionWizardState(
        enabledForms: {FormType.moldAssessment},
        snapshot: WizardProgressSnapshot(
          lastStepIndex: 0,
          completion: const <String, bool>{},
          branchContext: const <String, dynamic>{
            'mold_moisture_source_found': true,
            'mold_samples_taken': true,
          },
          status: WizardProgressStatus.inProgress,
        ),
      );

      final formStep = state.steps.firstWhere(
        (s) => s.form == FormType.moldAssessment,
      );
      final keys = formStep.requirements.map((r) => r.key).toSet();

      expect(keys, contains('photo:mold_moisture_source'));
      expect(keys, contains('document:mold_lab_report'));
    });

    test('base-only requirements when no branch flags', () {
      final state = InspectionWizardState(
        enabledForms: {FormType.moldAssessment},
        snapshot: WizardProgressSnapshot.empty,
      );

      final formStep = state.steps.firstWhere(
        (s) => s.form == FormType.moldAssessment,
      );
      final keys = formStep.requirements.map((r) => r.key).toSet();

      expect(keys, contains('photo:mold_moisture_reading'));
      expect(keys, contains('photo:mold_growth_evidence'));
      expect(keys, contains('photo:mold_affected_area'));
      expect(keys, isNot(contains('photo:mold_moisture_source')));
      expect(keys, isNot(contains('document:mold_lab_report')));
    });
  });

  group('generalInspection wizard lifecycle', () {
    test('constructs correct steps', () {
      final state = InspectionWizardState(
        enabledForms: {FormType.generalInspection},
        snapshot: WizardProgressSnapshot.empty,
      );

      expect(state.steps.length, 2);
      expect(state.steps[1].id, 'form_general_inspection');
    });

    test('includes deficiency photo when safety hazard flag set', () {
      final state = InspectionWizardState(
        enabledForms: {FormType.generalInspection},
        snapshot: WizardProgressSnapshot(
          lastStepIndex: 0,
          completion: const <String, bool>{},
          branchContext: const <String, dynamic>{
            'general_safety_hazard': true,
          },
          status: WizardProgressStatus.inProgress,
        ),
      );

      final formStep = state.steps.firstWhere(
        (s) => s.form == FormType.generalInspection,
      );
      expect(
        formStep.requirements.any((r) => r.key == 'photo:general_deficiency'),
        isTrue,
      );
    });

    test('excludes deficiency photo without safety hazard flag', () {
      final state = InspectionWizardState(
        enabledForms: {FormType.generalInspection},
        snapshot: WizardProgressSnapshot.empty,
      );

      final formStep = state.steps.firstWhere(
        (s) => s.form == FormType.generalInspection,
      );
      expect(
        formStep.requirements.any((r) => r.key == 'photo:general_deficiency'),
        isFalse,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Wizard progression and readiness
  // ---------------------------------------------------------------------------

  group('wizard progression', () {
    test('resolveNextIncompleteStep returns first incomplete form step', () {
      final state = InspectionWizardState(
        enabledForms: {FormType.fourPoint, FormType.roofCondition},
        snapshot: WizardProgressSnapshot.empty,
      );

      // Overview step is always complete (no requirements)
      expect(state.resolveNextIncompleteStep(), 1);
    });

    test('canAdvanceFrom returns false for incomplete step', () {
      final state = InspectionWizardState(
        enabledForms: {FormType.fourPoint},
        snapshot: WizardProgressSnapshot.empty,
      );

      // Form step 1 is incomplete
      expect(state.canAdvanceFrom(1), isFalse);
    });

    test('canAdvanceFrom returns true for overview step (empty requirements)',
        () {
      final state = InspectionWizardState(
        enabledForms: {FormType.fourPoint},
        snapshot: WizardProgressSnapshot.empty,
      );

      // Overview step has no requirements
      expect(state.canAdvanceFrom(0), isTrue);
    });

    test('form summaries show correct completion percentage', () {
      final requirements = FormRequirements.forFormRequirements(FormType.fourPoint);
      // Complete half the requirements
      final halfCompletion = <String, bool>{};
      final half = requirements.length ~/ 2;
      for (var i = 0; i < half; i++) {
        halfCompletion[requirements[i].key] = true;
      }

      final state = InspectionWizardState(
        enabledForms: {FormType.fourPoint},
        snapshot: WizardProgressSnapshot(
          lastStepIndex: 1,
          completion: halfCompletion,
          branchContext: const <String, dynamic>{},
          status: WizardProgressStatus.inProgress,
        ),
      );

      final summaries = state.buildFormSummaries();
      expect(summaries.length, 1);
      expect(summaries.first.form, FormType.fourPoint);
      expect(summaries.first.percentComplete, greaterThan(0));
      expect(summaries.first.percentComplete, lessThan(100));
      expect(summaries.first.isComplete, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // Mixed-form wizard (all 7 forms enabled)
  // ---------------------------------------------------------------------------

  group('mixed-form wizard (all 7 forms)', () {
    test('constructs steps for all 7 forms in enum order', () {
      final state = InspectionWizardState(
        enabledForms: FormType.values.toSet(),
        snapshot: WizardProgressSnapshot.empty,
      );

      // 1 overview + 7 form steps = 8
      expect(state.steps.length, 8);
      expect(state.steps[0].id, 'inspection_overview');
      expect(state.steps[1].id, 'form_four_point');
      expect(state.steps[2].id, 'form_roof_condition');
      expect(state.steps[3].id, 'form_wind_mitigation');
      expect(state.steps[4].id, 'form_wdo');
      expect(state.steps[5].id, 'form_sinkhole_inspection');
      expect(state.steps[6].id, 'form_mold_assessment');
      expect(state.steps[7].id, 'form_general_inspection');
    });

    test('buildFormSummaries returns 7 summaries in order', () {
      final state = InspectionWizardState(
        enabledForms: FormType.values.toSet(),
        snapshot: WizardProgressSnapshot.empty,
      );

      final summaries = state.buildFormSummaries();
      expect(summaries.length, 7);
      expect(summaries[0].form, FormType.fourPoint);
      expect(summaries[1].form, FormType.roofCondition);
      expect(summaries[2].form, FormType.windMitigation);
      expect(summaries[3].form, FormType.wdo);
      expect(summaries[4].form, FormType.sinkholeInspection);
      expect(summaries[5].form, FormType.moldAssessment);
      expect(summaries[6].form, FormType.generalInspection);
    });

    test('completes non-sequentially (complete form 3 then form 1)', () {
      // Complete windMitigation base requirements first
      final windReqs = FormRequirements.forFormRequirements(FormType.windMitigation);
      final completion = <String, bool>{
        for (final req in windReqs) req.key: true,
      };

      final state = InspectionWizardState(
        enabledForms: {FormType.fourPoint, FormType.windMitigation},
        snapshot: WizardProgressSnapshot(
          lastStepIndex: 2,
          completion: completion,
          branchContext: const <String, dynamic>{},
          status: WizardProgressStatus.inProgress,
        ),
      );

      final summaries = state.buildFormSummaries();
      final windSummary = summaries.firstWhere(
        (s) => s.form == FormType.windMitigation,
      );
      final fourPointSummary = summaries.firstWhere(
        (s) => s.form == FormType.fourPoint,
      );

      expect(windSummary.isComplete, isTrue);
      expect(fourPointSummary.isComplete, isFalse);
      expect(state.isComplete, isFalse);
    });

    test('isComplete true when all 7 forms are completed', () {
      // Complete ALL forms (no branch flags → base requirements only)
      final completion = <String, bool>{};
      for (final form in FormType.values) {
        final reqs = FormRequirements.forFormRequirements(form);
        for (final req in reqs) {
          if (req.key == 'photo:general_data_plate') {
            // minimumCount: 2 — need two entries
            completion['photo:general_data_plate'] = true;
            completion['photo:general_data_plate#2'] = true;
          } else {
            completion[req.key] = true;
          }
        }
      }

      final state = InspectionWizardState(
        enabledForms: FormType.values.toSet(),
        snapshot: WizardProgressSnapshot(
          lastStepIndex: 7,
          completion: completion,
          branchContext: const <String, dynamic>{},
          status: WizardProgressStatus.inProgress,
        ),
      );

      expect(state.isComplete, isTrue);
      final summaries = state.buildFormSummaries();
      for (final summary in summaries) {
        expect(
          summary.isComplete,
          isTrue,
          reason: '${summary.form.code} should be complete',
        );
      }
    });
  });

  // ---------------------------------------------------------------------------
  // Edge cases
  // ---------------------------------------------------------------------------

  group('edge cases', () {
    test('empty enabledForms is always complete', () {
      final state = InspectionWizardState(
        enabledForms: const {},
        snapshot: WizardProgressSnapshot.empty,
      );

      expect(state.isComplete, isTrue);
      expect(state.steps.length, 1); // overview only
    });

    test('safeLastStepIndex clamps to valid range', () {
      final state = InspectionWizardState(
        enabledForms: {FormType.fourPoint},
        snapshot: WizardProgressSnapshot(
          lastStepIndex: 999,
          completion: const <String, bool>{},
          branchContext: const <String, dynamic>{},
          status: WizardProgressStatus.inProgress,
        ),
      );

      expect(state.safeLastStepIndex, 1); // max valid index
    });

    test('canVisitStep returns false for out-of-range index', () {
      final state = InspectionWizardState(
        enabledForms: {FormType.fourPoint},
        snapshot: WizardProgressSnapshot.empty,
      );

      expect(state.canVisitStep(-1), isFalse);
      expect(state.canVisitStep(100), isFalse);
    });
  });
}
