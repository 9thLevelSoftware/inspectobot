import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/evidence_requirement.dart';
import 'package:inspectobot/features/inspection/domain/form_requirements.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/inspection_wizard_state.dart';


/// Tests verifying FormRequirements and WizardProgressSnapshot backward
/// compatibility after the Phase 3-9 form type expansion.
void main() {
  group('FormRequirements — original 3 form types unchanged', () {
    test('fourPoint has expected baseline evidence rules', () {
      final reqs = FormRequirements.forFormRequirements(FormType.fourPoint);
      final keys = reqs.map((r) => r.key).toSet();

      // Unconditional photo requirements for 4-Point
      expect(keys, contains('photo:exterior_front'));
      expect(keys, contains('photo:exterior_rear'));
      expect(keys, contains('photo:exterior_left'));
      expect(keys, contains('photo:exterior_right'));
      expect(keys, contains('photo:roof_slope_main'));
      expect(keys, contains('photo:roof_slope_secondary'));
      expect(keys, contains('photo:water_heater_tpr_valve'));
      expect(keys, contains('photo:plumbing_under_sink'));
      expect(keys, contains('photo:electrical_panel_label'));
      expect(keys, contains('photo:electrical_panel_open'));
      expect(keys, contains('photo:hvac_data_plate'));

      // Conditional hazard photo should NOT appear without flag
      expect(keys, isNot(contains('photo:hazard_photo')));
    });

    test('fourPoint hazard_photo appears when hazard_present is true', () {
      final reqs = FormRequirements.forFormRequirements(
        FormType.fourPoint,
        branchContext: const {'hazard_present': true},
      );
      final keys = reqs.map((r) => r.key).toSet();

      expect(keys, contains('photo:hazard_photo'));
    });

    test('roofCondition has expected baseline evidence rules', () {
      final reqs = FormRequirements.forFormRequirements(FormType.roofCondition);
      final keys = reqs.map((r) => r.key).toSet();

      expect(keys, contains('photo:roof_condition_main_slope'));
      expect(keys, contains('photo:roof_condition_secondary_slope'));
      // Conditional
      expect(keys, isNot(contains('photo:roof_defect')));
    });

    test('roofCondition roof_defect appears when flag is true', () {
      final reqs = FormRequirements.forFormRequirements(
        FormType.roofCondition,
        branchContext: const {'roof_defect_present': true},
      );
      final keys = reqs.map((r) => r.key).toSet();
      expect(keys, contains('photo:roof_defect'));
    });

    test('windMitigation has expected baseline evidence rules', () {
      final reqs =
          FormRequirements.forFormRequirements(FormType.windMitigation);
      final keys = reqs.map((r) => r.key).toSet();

      expect(keys, contains('photo:wind_roof_deck'));
      expect(keys, contains('photo:wind_roof_to_wall'));
      expect(keys, contains('photo:wind_roof_shape'));
      expect(keys, contains('photo:wind_secondary_water_resistance'));
      expect(keys, contains('photo:wind_opening_protection'));
      expect(keys, contains('photo:wind_opening_type'));
      expect(keys, contains('photo:wind_permit_year'));

      // Conditional documents should NOT appear without flags
      expect(keys, isNot(contains('document:wind_roof_deck')));
      expect(keys, isNot(contains('document:wind_opening_protection')));
      expect(keys, isNot(contains('document:wind_permit_year')));
    });

    test('windMitigation conditional documents appear with flags', () {
      final reqs = FormRequirements.forFormRequirements(
        FormType.windMitigation,
        branchContext: const {
          'wind_roof_deck_document_required': true,
          'wind_opening_document_required': true,
          'wind_permit_document_required': true,
        },
      );
      final keys = reqs.map((r) => r.key).toSet();

      expect(keys, contains('document:wind_roof_deck'));
      expect(keys, contains('document:wind_opening_protection'));
      expect(keys, contains('document:wind_permit_year'));
    });
  });

  group('FormRequirements — new 4 form types are well-formed', () {
    test('every FormType has a non-empty requirement list', () {
      for (final form in FormType.values) {
        final reqs = FormRequirements.forFormRequirements(form);
        expect(
          reqs,
          isNotEmpty,
          reason: '${form.code} should have at least 1 requirement',
        );
      }
    });

    test('every requirement has a non-empty key and label', () {
      for (final form in FormType.values) {
        final reqs = FormRequirements.forFormRequirements(form);
        for (final req in reqs) {
          expect(req.key, isNotEmpty,
              reason: '${form.code} requirement key should be non-empty');
          expect(req.label, isNotEmpty,
              reason: '${form.code} requirement label should be non-empty');
        }
      }
    });

    test('every requirement key is unique within its form', () {
      for (final form in FormType.values) {
        final reqs = FormRequirements.forFormRequirements(form);
        final keys = <String>{};
        for (final req in reqs) {
          expect(keys.add(req.key), isTrue,
              reason:
                  'Duplicate key ${req.key} in ${form.code}');
        }
      }
    });

    test('every photo requirement has a non-null category', () {
      for (final form in FormType.values) {
        final reqs = FormRequirements.forFormRequirements(form);
        for (final req in reqs) {
          if (req.mediaType == EvidenceMediaType.photo) {
            expect(req.category, isNotNull,
                reason:
                    '${form.code}/${req.key} photo should have a category');
          }
        }
      }
    });

    test('wdo has baseline unconditional requirements', () {
      final reqs = FormRequirements.forFormRequirements(FormType.wdo);
      final keys = reqs.map((r) => r.key).toSet();
      expect(keys, contains('photo:wdo_property_exterior'));
      expect(keys, contains('photo:wdo_notice_posting'));
    });

    test('sinkholeInspection has baseline unconditional requirements', () {
      final reqs = FormRequirements.forFormRequirements(
          FormType.sinkholeInspection);
      final keys = reqs.map((r) => r.key).toSet();
      expect(keys, contains('photo:sinkhole_front_elevation'));
      expect(keys, contains('photo:sinkhole_rear_elevation'));
    });

    test('moldAssessment has baseline unconditional requirements', () {
      final reqs =
          FormRequirements.forFormRequirements(FormType.moldAssessment);
      final keys = reqs.map((r) => r.key).toSet();
      expect(keys, contains('photo:mold_moisture_reading'));
      expect(keys, contains('photo:mold_growth_evidence'));
      expect(keys, contains('photo:mold_affected_area'));
    });

    test('generalInspection has baseline unconditional requirements', () {
      final reqs =
          FormRequirements.forFormRequirements(FormType.generalInspection);
      final keys = reqs.map((r) => r.key).toSet();
      expect(keys, contains('photo:general_front_elevation'));
      expect(keys, contains('photo:general_electrical_panel'));
      expect(keys, contains('photo:general_data_plate'));
      expect(keys, contains('photo:general_pressure_test'));
      expect(keys, contains('photo:general_room_photo'));
    });
  });

  group('FormRequirements — new form types conditional requirements', () {
    test('wdo conditional photos appear with their branch flags', () {
      final reqs = FormRequirements.forFormRequirements(
        FormType.wdo,
        branchContext: const {
          'wdo_visible_evidence': true,
          'wdo_damage_by_wdo': true,
        },
      );
      final keys = reqs.map((r) => r.key).toSet();
      expect(keys, contains('photo:wdo_infestation_evidence'));
      expect(keys, contains('photo:wdo_damage_area'));
    });

    test('wdo inaccessible area photo appears when any area is inaccessible', () {
      // Test compound predicate: any of 5 inaccessible flags triggers it
      for (final flag in [
        'wdo_attic_inaccessible',
        'wdo_interior_inaccessible',
        'wdo_exterior_inaccessible',
        'wdo_crawlspace_inaccessible',
        'wdo_other_inaccessible',
      ]) {
        final reqs = FormRequirements.forFormRequirements(
          FormType.wdo,
          branchContext: {flag: true},
        );
        final keys = reqs.map((r) => r.key).toSet();
        expect(keys, contains('photo:wdo_inaccessible_area'),
            reason: 'Flag $flag should trigger inaccessible area photo');
      }
    });

    test('wdo inaccessible area photo does NOT appear when no flags set', () {
      final reqs = FormRequirements.forFormRequirements(FormType.wdo);
      final keys = reqs.map((r) => r.key).toSet();
      expect(keys, isNot(contains('photo:wdo_inaccessible_area')));
    });

    test('sinkhole checklist photos appear when any section has indicators', () {
      // anySinkholeYes requires any of 4 section flags
      for (final flag in [
        'sinkhole_any_exterior_yes',
        'sinkhole_any_interior_yes',
        'sinkhole_any_garage_yes',
        'sinkhole_any_appurtenant_yes',
      ]) {
        final reqs = FormRequirements.forFormRequirements(
          FormType.sinkholeInspection,
          branchContext: {flag: true},
        );
        final keys = reqs.map((r) => r.key).toSet();
        expect(keys, contains('photo:sinkhole_checklist_item'),
            reason: 'Flag $flag should trigger sinkhole checklist photo');
      }
    });

    test('sinkhole checklist item requires minimumCount of 2', () {
      final reqs = FormRequirements.forFormRequirements(
        FormType.sinkholeInspection,
        branchContext: const {'sinkhole_any_exterior_yes': true},
      );
      final checklistReq = reqs.firstWhere((r) => r.key == 'photo:sinkhole_checklist_item');
      expect(checklistReq.minimumCount, 2);
    });

    test('sinkhole garage crack appears only with garage flag', () {
      final reqs = FormRequirements.forFormRequirements(
        FormType.sinkholeInspection,
        branchContext: const {'sinkhole_any_garage_yes': true},
      );
      final keys = reqs.map((r) => r.key).toSet();
      expect(keys, contains('photo:sinkhole_garage_crack'));
    });

    test('sinkhole adjacent structure appears only with townhouse flag', () {
      final reqs = FormRequirements.forFormRequirements(
        FormType.sinkholeInspection,
        branchContext: const {'sinkhole_townhouse': true},
      );
      final keys = reqs.map((r) => r.key).toSet();
      expect(keys, contains('photo:sinkhole_adjacent_structure'));
    });

    test('mold moisture source photo appears with moisture_source_found flag', () {
      final reqs = FormRequirements.forFormRequirements(
        FormType.moldAssessment,
        branchContext: const {'mold_moisture_source_found': true},
      );
      final keys = reqs.map((r) => r.key).toSet();
      expect(keys, contains('photo:mold_moisture_source'));
    });

    test('mold lab report document appears with samples_taken flag', () {
      final reqs = FormRequirements.forFormRequirements(
        FormType.moldAssessment,
        branchContext: const {'mold_samples_taken': true},
      );
      final keys = reqs.map((r) => r.key).toSet();
      expect(keys, contains('document:mold_lab_report'));
    });

    test('mold conditional requirements do NOT appear without flags', () {
      final reqs = FormRequirements.forFormRequirements(FormType.moldAssessment);
      final keys = reqs.map((r) => r.key).toSet();
      expect(keys, isNot(contains('photo:mold_moisture_source')));
      expect(keys, isNot(contains('document:mold_lab_report')));
    });

    test('general deficiency photo appears with safety_hazard flag', () {
      final reqs = FormRequirements.forFormRequirements(
        FormType.generalInspection,
        branchContext: const {'general_safety_hazard': true},
      );
      final keys = reqs.map((r) => r.key).toSet();
      expect(keys, contains('photo:general_deficiency'));
    });

    test('general deficiency photo does NOT appear without flag', () {
      final reqs = FormRequirements.forFormRequirements(FormType.generalInspection);
      final keys = reqs.map((r) => r.key).toSet();
      expect(keys, isNot(contains('photo:general_deficiency')));
    });

    test('general data_plate requires minimumCount of 2', () {
      final reqs = FormRequirements.forFormRequirements(FormType.generalInspection);
      final dataPlateReq = reqs.firstWhere((r) => r.key == 'photo:general_data_plate');
      expect(dataPlateReq.minimumCount, 2);
    });
  });

  group('FormRequirements — canonical source keys', () {
    test('canonicalSourceKeysForForm returns keys for each form type', () {
      for (final form in FormType.values) {
        final keys = FormRequirements.canonicalSourceKeysForForm(form);
        expect(keys, isNotEmpty,
            reason: '${form.code} should have canonical source keys');
      }
    });

    test('canonicalSourceKeys returns all keys across all forms', () {
      final allKeys = FormRequirements.canonicalSourceKeys();
      // Should include keys from every form
      expect(allKeys, contains('photo:exterior_front')); // fourPoint
      expect(allKeys, contains('photo:wdo_property_exterior')); // wdo
      expect(allKeys, contains('photo:sinkhole_front_elevation')); // sinkhole
      expect(allKeys, contains('photo:mold_moisture_reading')); // mold
      expect(allKeys, contains('photo:general_front_elevation')); // general
      // Should also include conditional ones
      expect(allKeys, contains('photo:hazard_photo'));
      expect(allKeys, contains('document:mold_lab_report'));
    });

    test('canonicalSourceKeysForForm includes conditional requirements', () {
      final wdoKeys = FormRequirements.canonicalSourceKeysForForm(FormType.wdo);
      // These are conditional but should still be in the canonical set
      expect(wdoKeys, contains('photo:wdo_infestation_evidence'));
      expect(wdoKeys, contains('photo:wdo_damage_area'));
      expect(wdoKeys, contains('photo:wdo_inaccessible_area'));
    });
  });

  group('FormRequirements — branch flags', () {
    test('all 7 form types have entries in branchFlagsByForm', () {
      for (final form in FormType.values) {
        expect(
          FormRequirements.branchFlagsByForm.containsKey(form),
          isTrue,
          reason: '${form.code} should be in branchFlagsByForm',
        );
      }
    });

    test('all branch flags have labels', () {
      for (final flag in FormRequirements.canonicalBranchFlags) {
        expect(
          FormRequirements.branchFlagLabels.containsKey(flag),
          isTrue,
          reason: 'Branch flag "$flag" should have a label',
        );
      }
    });

    test('original 3 form branch flags still present', () {
      final fourPointFlags =
          FormRequirements.branchFlagsByForm[FormType.fourPoint]!;
      expect(fourPointFlags, contains('hazard_present'));

      final roofFlags =
          FormRequirements.branchFlagsByForm[FormType.roofCondition]!;
      expect(roofFlags, contains('roof_defect_present'));

      final windFlags =
          FormRequirements.branchFlagsByForm[FormType.windMitigation]!;
      expect(windFlags, contains('wind_roof_deck_document_required'));
      expect(windFlags, contains('wind_opening_document_required'));
      expect(windFlags, contains('wind_permit_document_required'));
    });
  });

  group('FormRequirements — evaluate cross-form', () {
    test('evaluate with original 3 forms returns merged results', () {
      final reqs = FormRequirements.evaluate({
        FormType.fourPoint,
        FormType.roofCondition,
        FormType.windMitigation,
      });

      expect(reqs, isNotEmpty);
      final keys = reqs.map((r) => r.key).toSet();
      // Should contain requirements from all 3 forms
      expect(keys, contains('photo:exterior_front'));
      expect(keys, contains('photo:roof_condition_main_slope'));
      expect(keys, contains('photo:wind_roof_deck'));
    });

    test('evaluate with mixed old+new forms merges correctly', () {
      final reqs = FormRequirements.evaluate({
        FormType.fourPoint,
        FormType.wdo,
        FormType.generalInspection,
      });

      expect(reqs, isNotEmpty);
      final keys = reqs.map((r) => r.key).toSet();
      expect(keys, contains('photo:exterior_front'));
      expect(keys, contains('photo:wdo_property_exterior'));
      expect(keys, contains('photo:general_front_elevation'));
    });

    test('evaluate with all 7 forms returns all unconditional requirements',
        () {
      final reqs = FormRequirements.evaluate(FormType.values.toSet());
      expect(reqs.length, greaterThanOrEqualTo(7),
          reason: 'Should have at least 1 req per form');

      // Spot-check one requirement per form
      final keys = reqs.map((r) => r.key).toSet();
      expect(keys, contains('photo:exterior_front'));
      expect(keys, contains('photo:roof_condition_main_slope'));
      expect(keys, contains('photo:wind_roof_deck'));
      expect(keys, contains('photo:wdo_property_exterior'));
      expect(keys, contains('photo:sinkhole_front_elevation'));
      expect(keys, contains('photo:mold_moisture_reading'));
      expect(keys, contains('photo:general_front_elevation'));
    });
  });

  group('WizardProgressSnapshot compatibility', () {
    test('original step keys are valid for InspectionWizardState', () {
      final snapshot = const WizardProgressSnapshot(
        lastStepIndex: 1,
        completion: {
          'photo:exterior_front': true,
          'photo:exterior_rear': true,
        },
        branchContext: {'hazard_present': false},
        status: WizardProgressStatus.inProgress,
      );

      final state = InspectionWizardState(
        enabledForms: {FormType.fourPoint},
        snapshot: snapshot,
      );

      // Step 0 is overview, step 1 is four_point
      expect(state.steps.length, 2);
      expect(state.steps[1].id, 'form_four_point');
    });

    test('new form type step keys resolve correctly', () {
      final snapshot = WizardProgressSnapshot.empty;
      final state = InspectionWizardState(
        enabledForms: {FormType.wdo, FormType.moldAssessment},
        snapshot: snapshot,
      );

      final formStepIds = state.steps.skip(1).map((s) => s.id).toList();
      expect(formStepIds, contains('form_wdo'));
      expect(formStepIds, contains('form_mold_assessment'));
    });

    test('step definitions have requirements matching their form', () {
      final state = InspectionWizardState(
        enabledForms: FormType.values.toSet(),
        snapshot: WizardProgressSnapshot.empty,
      );

      for (final step in state.steps.skip(1)) {
        expect(step.form, isNotNull,
            reason: 'Form step ${step.id} should have a form');
        expect(step.requirements, isNotEmpty,
            reason: 'Form step ${step.id} should have requirements');
        for (final req in step.requirements) {
          expect(req.form, step.form,
              reason:
                  'Requirement ${req.key} should belong to ${step.form!.code}');
        }
      }
    });

    test('overview step has no requirements and no form', () {
      final state = InspectionWizardState(
        enabledForms: {FormType.fourPoint},
        snapshot: WizardProgressSnapshot.empty,
      );

      expect(state.steps[0].id, 'inspection_overview');
      expect(state.steps[0].form, isNull);
      expect(state.steps[0].requirements, isEmpty);
    });

    test('multi-form wizard: step ordering follows FormType.index', () {
      final state = InspectionWizardState(
        enabledForms: {
          FormType.generalInspection, // index 6
          FormType.fourPoint, // index 0
          FormType.wdo, // index 3
        },
        snapshot: WizardProgressSnapshot.empty,
      );

      // Steps should be: overview, fourPoint, wdo, generalInspection
      expect(state.steps[0].id, 'inspection_overview');
      expect(state.steps[1].id, 'form_four_point');
      expect(state.steps[2].id, 'form_wdo');
      expect(state.steps[3].id, 'form_general_inspection');
    });

    test('isComplete returns false when requirements not met', () {
      final state = InspectionWizardState(
        enabledForms: {FormType.fourPoint},
        snapshot: WizardProgressSnapshot.empty,
      );
      expect(state.isComplete, isFalse);
    });

    test('resolveNextIncompleteStep returns 0 for empty snapshot', () {
      final state = InspectionWizardState(
        enabledForms: {FormType.fourPoint},
        snapshot: WizardProgressSnapshot.empty,
      );
      // Overview step is empty (no requirements), so first incomplete is form step
      expect(state.resolveNextIncompleteStep(), 1);
    });

    test('branchContext canonicalization only preserves known flags', () {
      final snapshot = const WizardProgressSnapshot(
        lastStepIndex: 0,
        completion: {},
        branchContext: {
          'hazard_present': true,
          'unknown_custom_flag': true,
          'some_number': 42,
        },
        status: WizardProgressStatus.inProgress,
      );

      final state = InspectionWizardState(
        enabledForms: {FormType.fourPoint},
        snapshot: snapshot,
      );

      // The four_point step should include hazard_photo since hazard_present is
      // in the canonical branch context.
      final fourPointStep = state.steps[1];
      final keys = fourPointStep.requirements.map((r) => r.key).toSet();
      expect(keys, contains('photo:hazard_photo'));
    });

    test('FormProgressSummary tracks missing requirements correctly', () {
      final snapshot = const WizardProgressSnapshot(
        lastStepIndex: 0,
        completion: {
          'photo:exterior_front': true,
          'photo:exterior_rear': true,
        },
        branchContext: {},
        status: WizardProgressStatus.inProgress,
      );

      final state = InspectionWizardState(
        enabledForms: {FormType.fourPoint},
        snapshot: snapshot,
      );

      final summaries = state.buildFormSummaries();
      expect(summaries.length, 1);

      final fourPointSummary = summaries.first;
      expect(fourPointSummary.form, FormType.fourPoint);
      expect(fourPointSummary.isComplete, isFalse);
      // 11 unconditional requirements, 2 completed = 9 missing
      expect(fourPointSummary.missingRequirements.length, 9);
      expect(fourPointSummary.totalRequirements, 11);
      expect(fourPointSummary.abbreviation, '4PT');
    });

    test('FormProgressSummary works for new form types', () {
      final snapshot = WizardProgressSnapshot.empty;
      final state = InspectionWizardState(
        enabledForms: {FormType.wdo, FormType.moldAssessment},
        snapshot: snapshot,
      );

      final summaries = state.buildFormSummaries();
      expect(summaries.length, 2);
      expect(summaries[0].form, FormType.wdo);
      expect(summaries[1].form, FormType.moldAssessment);
      expect(summaries[0].abbreviation, 'WDO');
      expect(summaries[1].abbreviation, 'MOLD');
      // Both should be incomplete since no photos captured
      expect(summaries[0].isComplete, isFalse);
      expect(summaries[1].isComplete, isFalse);
    });
  });

  group('FormType code round-trip', () {
    test('all FormType values round-trip through code', () {
      for (final form in FormType.values) {
        final code = form.code;
        final restored = FormType.fromCode(code);
        expect(restored, form,
            reason: '${form.code} should round-trip through fromCode');
      }
    });

    test('fromCode throws for unknown codes', () {
      expect(
        () => FormType.fromCode('nonexistent_form'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('fromCodes parses multiple codes', () {
      final forms = FormType.fromCodes(
          ['four_point', 'roof_condition', 'wind_mitigation']);
      expect(forms, {
        FormType.fourPoint,
        FormType.roofCondition,
        FormType.windMitigation,
      });
    });

    test('all 7 form types have unique codes', () {
      final codes = FormType.values.map((f) => f.code).toSet();
      expect(codes.length, 7);
    });

    test('all 7 form types have unique abbreviations', () {
      final abbreviations = FormType.values.map((f) => f.abbreviation).toSet();
      expect(abbreviations.length, 7);
    });
  });
}
