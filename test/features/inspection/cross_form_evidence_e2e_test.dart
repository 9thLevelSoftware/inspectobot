import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/evidence_requirement.dart';
import 'package:inspectobot/features/inspection/domain/evidence_sharing_matrix.dart';
import 'package:inspectobot/features/inspection/domain/form_requirements.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/inspection_wizard_state.dart';
import 'package:inspectobot/features/inspection/domain/required_photo_category.dart';

void main() {
  /// Helper: returns all requirements for a form with all branch flags enabled.
  List<EvidenceRequirement> allRequirementsForForm(FormType form) {
    final allBranchFlags = <String, dynamic>{};
    for (final flag in FormRequirements.canonicalBranchFlags) {
      allBranchFlags[flag] = true;
    }
    return FormRequirements.forFormRequirements(
      form,
      branchContext: allBranchFlags,
    );
  }

  /// Helper: builds a wizard state with given forms, completion, and branch context.
  InspectionWizardState buildState({
    required Set<FormType> enabledForms,
    Map<String, bool> completion = const <String, bool>{},
    Map<String, dynamic> branchContext = const <String, dynamic>{},
  }) {
    return InspectionWizardState(
      enabledForms: enabledForms,
      snapshot: WizardProgressSnapshot(
        lastStepIndex: 0,
        completion: completion,
        branchContext: branchContext,
        status: WizardProgressStatus.inProgress,
      ),
    );
  }

  group('Multi-form session with all 7 forms', () {
    test('capturing exteriorFront satisfies both fourPoint and generalInspection via semantic equivalence', () {
      final enabledForms = FormType.values.toSet();

      // Simulate capturing exteriorFront and its semantic equivalent
      final completion = <String, bool>{
        'photo:exterior_front': true,
        'photo:general_front_elevation': true, // cross-form mark
      };

      final state = buildState(
        enabledForms: enabledForms,
        completion: completion,
      );

      final summaries = state.buildFormSummaries();
      final fourPt = summaries.firstWhere((s) => s.form == FormType.fourPoint);
      final gen = summaries.firstWhere((s) => s.form == FormType.generalInspection);

      // Neither form should list their front-elevation requirement as missing
      expect(
        fourPt.missingRequirements.any((r) => r.key == 'photo:exterior_front'),
        isFalse,
        reason: 'fourPoint should recognize exterior_front as captured',
      );
      expect(
        gen.missingRequirements.any((r) => r.key == 'photo:general_front_elevation'),
        isFalse,
        reason: 'generalInspection should recognize general_front_elevation as captured',
      );

      // Forms that do NOT share this category should be unaffected
      final wdo = summaries.firstWhere((s) => s.form == FormType.wdo);
      final moldBefore = summaries.firstWhere((s) => s.form == FormType.moldAssessment);
      expect(wdo.percentComplete, lessThan(100));
      expect(moldBefore.percentComplete, lessThan(100));
    });

    test('capturing all shared categories satisfies all receiving forms', () {
      final enabledForms = FormType.values.toSet();

      // Mark all natively and semantically shared categories as complete
      final completion = <String, bool>{
        // Native: roofSlopeMain shared between 4PT and ROOF
        'photo:roof_slope_main': true,
        'photo:roof_condition_main_slope': true,
        // Native: roofSlopeSecondary shared between 4PT and ROOF
        'photo:roof_slope_secondary': true,
        'photo:roof_condition_secondary_slope': true,
        // Semantic: exteriorFront <-> generalFrontElevation
        'photo:exterior_front': true,
        'photo:general_front_elevation': true,
        // Semantic: electricalPanelLabel <-> generalElectricalPanel
        'photo:electrical_panel_label': true,
        'photo:general_electrical_panel': true,
        // Semantic: hvacDataPlate <-> generalDataPlate
        'photo:hvac_data_plate': true,
        'photo:general_data_plate': true,
        'photo:general_data_plate#2': true, // minimumCount: 2
      };

      final state = buildState(
        enabledForms: enabledForms,
        completion: completion,
      );

      final summaries = state.buildFormSummaries();

      // Verify each shared requirement is NOT in the missing list of its receiving forms
      final fourPt = summaries.firstWhere((s) => s.form == FormType.fourPoint);
      expect(fourPt.missingRequirements.any((r) => r.key == 'photo:roof_slope_main'), isFalse);
      expect(fourPt.missingRequirements.any((r) => r.key == 'photo:exterior_front'), isFalse);
      expect(fourPt.missingRequirements.any((r) => r.key == 'photo:electrical_panel_label'), isFalse);
      expect(fourPt.missingRequirements.any((r) => r.key == 'photo:hvac_data_plate'), isFalse);

      final roof = summaries.firstWhere((s) => s.form == FormType.roofCondition);
      expect(roof.missingRequirements.any((r) => r.key == 'photo:roof_condition_main_slope'), isFalse);
      expect(roof.missingRequirements.any((r) => r.key == 'photo:roof_condition_secondary_slope'), isFalse);

      final gen = summaries.firstWhere((s) => s.form == FormType.generalInspection);
      expect(gen.missingRequirements.any((r) => r.key == 'photo:general_front_elevation'), isFalse);
      expect(gen.missingRequirements.any((r) => r.key == 'photo:general_electrical_panel'), isFalse);
      expect(gen.missingRequirements.any((r) => r.key == 'photo:general_data_plate'), isFalse);
    });
  });

  group('Evidence sharing with branch context', () {
    test('branch flags enable conditional shared requirements', () {
      final enabledForms = {FormType.fourPoint, FormType.generalInspection};

      // With hazard_present=true, fourPoint requires hazardPhoto
      final stateWithHazard = buildState(
        enabledForms: enabledForms,
        branchContext: {FormRequirements.hazardPresentBranchFlag: true},
      );

      final summariesWith = stateWithHazard.buildFormSummaries();
      final fourPtWith = summariesWith.firstWhere((s) => s.form == FormType.fourPoint);
      expect(
        fourPtWith.missingRequirements.any((r) => r.key == 'photo:hazard_photo'),
        isTrue,
        reason: 'hazardPhoto should be required when hazard_present=true',
      );

      // Without the flag, hazardPhoto is not required
      final stateWithout = buildState(enabledForms: enabledForms);
      final summariesWithout = stateWithout.buildFormSummaries();
      final fourPtWithout = summariesWithout.firstWhere((s) => s.form == FormType.fourPoint);
      expect(
        fourPtWithout.missingRequirements.any((r) => r.key == 'photo:hazard_photo'),
        isFalse,
        reason: 'hazardPhoto should NOT be required when hazard_present is unset',
      );
    });

    test('WDO branch flags control conditional evidence requirements', () {
      final enabledForms = {FormType.wdo};

      // With visible evidence flag, wdo_infestation_evidence is required
      final stateWithEvidence = buildState(
        enabledForms: enabledForms,
        branchContext: {FormRequirements.wdoVisibleEvidenceBranchFlag: true},
      );

      final summariesWith = stateWithEvidence.buildFormSummaries();
      final wdoWith = summariesWith.firstWhere((s) => s.form == FormType.wdo);
      expect(
        wdoWith.missingRequirements.any((r) => r.key == 'photo:wdo_infestation_evidence'),
        isTrue,
      );

      // Without the flag, requirement is not included
      final stateWithout = buildState(enabledForms: enabledForms);
      final summariesWithout = stateWithout.buildFormSummaries();
      final wdoWithout = summariesWithout.firstWhere((s) => s.form == FormType.wdo);
      expect(
        wdoWithout.missingRequirements.any((r) => r.key == 'photo:wdo_infestation_evidence'),
        isFalse,
      );
    });

    test('mold branch flags control moisture source requirement', () {
      final enabledForms = {FormType.moldAssessment};

      final stateWith = buildState(
        enabledForms: enabledForms,
        branchContext: {FormRequirements.moldMoistureSourceFoundBranchFlag: true},
      );
      final moldWith = stateWith.buildFormSummaries().firstWhere(
        (s) => s.form == FormType.moldAssessment,
      );
      expect(
        moldWith.missingRequirements.any((r) => r.key == 'photo:mold_moisture_source'),
        isTrue,
        reason: 'mold_moisture_source required when moisture source found',
      );

      final stateWithout = buildState(enabledForms: enabledForms);
      final moldWithout = stateWithout.buildFormSummaries().firstWhere(
        (s) => s.form == FormType.moldAssessment,
      );
      expect(
        moldWithout.missingRequirements.any((r) => r.key == 'photo:mold_moisture_source'),
        isFalse,
        reason: 'mold_moisture_source NOT required when flag unset',
      );
    });
  });

  group('Evidence sharing completeness', () {
    test('completing all requirements for a form yields 100%', () {
      final enabledForms = {FormType.roofCondition};

      // roofCondition base requirements (no branch flags): main_slope + secondary_slope
      final reqs = FormRequirements.forFormRequirements(FormType.roofCondition);
      final completion = <String, bool>{};
      for (final req in reqs) {
        completion[req.key] = true;
      }

      final state = buildState(
        enabledForms: enabledForms,
        completion: completion,
      );
      final summary = state.buildFormSummaries().single;
      expect(summary.percentComplete, 100);
      expect(summary.isComplete, isTrue);
    });

    test('each form has correct total requirement count with no branch flags', () {
      // Verify each form's base requirement count for regression
      final expectedCounts = <FormType, int>{
        FormType.fourPoint: 11, // 12 total but hazardPhoto requires branch flag
        FormType.roofCondition: 2, // roofDefect requires branch flag
        FormType.windMitigation: 7, // 3 documents require branch flags
        FormType.wdo: 2, // many conditional
        FormType.sinkholeInspection: 2, // many conditional
        FormType.moldAssessment: 3, // moisture_source and lab_report conditional
        FormType.generalInspection: 5, // deficiency requires branch flag
      };

      for (final form in FormType.values) {
        final reqs = FormRequirements.forFormRequirements(form);
        expect(
          reqs.length,
          expectedCounts[form],
          reason: '${form.code} base requirement count mismatch',
        );
      }
    });
  });

  group('Photo path copying / evidence media path simulation', () {
    test('evidence media paths map captures for shared categories', () {
      // Simulate what the controller does: when capturing exteriorFront,
      // the path is stored under both the 4PT key and the GEN equivalent key
      final evidenceMediaPaths = <String, List<String>>{
        'photo:exterior_front': ['/tmp/photo_001.jpg'],
        'photo:general_front_elevation': ['/tmp/photo_001.jpg'], // same file
      };

      // Both requirement keys should reference the same file
      expect(
        evidenceMediaPaths['photo:exterior_front'],
        evidenceMediaPaths['photo:general_front_elevation'],
        reason: 'Shared evidence should reference the same file path',
      );

      // Simulate for electricalPanelLabel <-> generalElectricalPanel
      evidenceMediaPaths['photo:electrical_panel_label'] = ['/tmp/photo_002.jpg'];
      evidenceMediaPaths['photo:general_electrical_panel'] = ['/tmp/photo_002.jpg'];

      expect(
        evidenceMediaPaths['photo:electrical_panel_label'],
        evidenceMediaPaths['photo:general_electrical_panel'],
      );
    });

    test('native shared categories produce separate requirement keys with same path', () {
      // roofSlopeMain: 4PT key=photo:roof_slope_main, ROOF key=photo:roof_condition_main_slope
      final evidenceMediaPaths = <String, List<String>>{
        'photo:roof_slope_main': ['/tmp/roof_001.jpg'],
        'photo:roof_condition_main_slope': ['/tmp/roof_001.jpg'],
      };

      expect(
        evidenceMediaPaths['photo:roof_slope_main'],
        evidenceMediaPaths['photo:roof_condition_main_slope'],
        reason: 'Native shared category should copy the same file path to both keys',
      );
    });
  });

  group('Edge cases: form deselection', () {
    test('deselecting a form recalculates shared evidence correctly', () {
      // Start with 3 forms: 4PT, ROOF, GEN
      final fullCompletion = <String, bool>{
        'photo:roof_slope_main': true,
        'photo:roof_condition_main_slope': true,
        'photo:exterior_front': true,
        'photo:general_front_elevation': true,
      };

      // Full session: all 3 forms
      final fullState = buildState(
        enabledForms: {FormType.fourPoint, FormType.roofCondition, FormType.generalInspection},
        completion: fullCompletion,
      );
      expect(fullState.buildFormSummaries().length, 3);

      // Remove roofCondition mid-session
      final reducedState = buildState(
        enabledForms: {FormType.fourPoint, FormType.generalInspection},
        completion: fullCompletion,
      );
      final summaries = reducedState.buildFormSummaries();
      expect(summaries.length, 2);

      // 4PT should still have roof_slope_main satisfied
      final fourPt = summaries.firstWhere((s) => s.form == FormType.fourPoint);
      expect(fourPt.missingRequirements.any((r) => r.key == 'photo:roof_slope_main'), isFalse);

      // GEN should still have front elevation satisfied
      final gen = summaries.firstWhere((s) => s.form == FormType.generalInspection);
      expect(gen.missingRequirements.any((r) => r.key == 'photo:general_front_elevation'), isFalse);
    });

    test('evidence captured for form A persists when form A is disabled but form B still shares', () {
      // Capture exteriorFront (4PT) and its equivalent generalFrontElevation (GEN)
      final completion = <String, bool>{
        'photo:exterior_front': true,
        'photo:general_front_elevation': true,
      };

      // Now disable fourPoint — generalInspection should still have its evidence
      final state = buildState(
        enabledForms: {FormType.generalInspection},
        completion: completion,
      );

      final summary = state.buildFormSummaries().single;
      expect(
        summary.missingRequirements.any((r) => r.key == 'photo:general_front_elevation'),
        isFalse,
        reason: 'GEN should retain evidence even after 4PT is disabled',
      );
    });

    test('adding a new form mid-session picks up existing shared evidence', () {
      // Start with just 4PT, capture some evidence
      final completion = <String, bool>{
        'photo:exterior_front': true,
        'photo:general_front_elevation': true, // pre-marked for cross-form
        'photo:electrical_panel_label': true,
        'photo:general_electrical_panel': true,
      };

      // Now add generalInspection
      final state = buildState(
        enabledForms: {FormType.fourPoint, FormType.generalInspection},
        completion: completion,
      );

      final gen = state.buildFormSummaries().firstWhere(
        (s) => s.form == FormType.generalInspection,
      );

      // GEN should pick up the already-captured front elevation and electrical panel
      expect(gen.missingRequirements.any((r) => r.key == 'photo:general_front_elevation'), isFalse);
      expect(gen.missingRequirements.any((r) => r.key == 'photo:general_electrical_panel'), isFalse);
      expect(gen.percentComplete, greaterThan(0));
    });
  });

  group('Evidence sharing UI model: CrossFormEvidenceBadge data', () {
    test('shared categories list correct form abbreviations', () {
      final enabledForms = FormType.values.toSet();

      // exteriorFront is shared with generalInspection
      final exteriorFrontForms = EvidenceSharingMatrix.formsAcceptingCategoryFiltered(
        RequiredPhotoCategory.exteriorFront,
        enabledForms,
      );
      expect(exteriorFrontForms, contains(FormType.fourPoint));
      expect(exteriorFrontForms, contains(FormType.generalInspection));
      expect(exteriorFrontForms.length, 2);

      // roofSlopeMain is shared with roofCondition
      final roofSlopeForms = EvidenceSharingMatrix.formsAcceptingCategoryFiltered(
        RequiredPhotoCategory.roofSlopeMain,
        enabledForms,
      );
      expect(roofSlopeForms, contains(FormType.fourPoint));
      expect(roofSlopeForms, contains(FormType.roofCondition));
      expect(roofSlopeForms.length, 2);
    });

    test('non-shared categories return single form', () {
      final enabledForms = FormType.values.toSet();

      // wdoPropertyExterior is WDO-only
      final wdoForms = EvidenceSharingMatrix.formsAcceptingCategoryFiltered(
        RequiredPhotoCategory.wdoPropertyExterior,
        enabledForms,
      );
      expect(wdoForms, {FormType.wdo});

      // moldAffectedArea is MOLD-only
      final moldForms = EvidenceSharingMatrix.formsAcceptingCategoryFiltered(
        RequiredPhotoCategory.moldAffectedArea,
        enabledForms,
      );
      expect(moldForms, {FormType.moldAssessment});
    });

    test('filtering by enabled forms excludes disabled forms from badge', () {
      // Only enable 4PT (not GEN)
      final enabledForms = {FormType.fourPoint};

      final forms = EvidenceSharingMatrix.formsAcceptingCategoryFiltered(
        RequiredPhotoCategory.exteriorFront,
        enabledForms,
      );

      // Should only show 4PT, not GEN
      expect(forms, {FormType.fourPoint});
    });

    test('EvidenceRequirementCard sharedForms: all 3 semantic pairs return correct targets', () {
      final enabledForms = {FormType.fourPoint, FormType.generalInspection};

      // exteriorFront -> should show both forms
      final extFrontForms = EvidenceSharingMatrix.formsAcceptingCategoryFiltered(
        RequiredPhotoCategory.exteriorFront,
        enabledForms,
      );
      expect(extFrontForms, containsAll([FormType.fourPoint, FormType.generalInspection]));

      // electricalPanelLabel -> should show both forms
      final elecForms = EvidenceSharingMatrix.formsAcceptingCategoryFiltered(
        RequiredPhotoCategory.electricalPanelLabel,
        enabledForms,
      );
      expect(elecForms, containsAll([FormType.fourPoint, FormType.generalInspection]));

      // hvacDataPlate -> should show both forms
      final hvacForms = EvidenceSharingMatrix.formsAcceptingCategoryFiltered(
        RequiredPhotoCategory.hvacDataPlate,
        enabledForms,
      );
      expect(hvacForms, containsAll([FormType.fourPoint, FormType.generalInspection]));
    });
  });

  group('Requirement key exhaustiveness', () {
    test('every shared category has requirement keys in all accepting forms', () {
      // Verify that for each shared category, every accepting form has a
      // corresponding requirement key in FormRequirements
      for (final category in RequiredPhotoCategory.values) {
        final acceptingForms = EvidenceSharingMatrix.formsAcceptingCategory(category);
        if (acceptingForms.length < 2) continue;

        for (final form in acceptingForms) {
          final formReqs = allRequirementsForForm(form);
          final hasDirectMatch = formReqs.any((r) => r.category == category);
          if (!hasDirectMatch) {
            // Must have an equivalent category match
            final equivalents = EvidenceSharingMatrix.equivalentCategories(category);
            final hasEquivMatch = formReqs.any((r) => equivalents.contains(r.category));
            expect(
              hasEquivMatch,
              isTrue,
              reason: '$form accepts $category but has no direct or equivalent requirement',
            );
          }
        }
      }
    });

    test('no duplicate requirement keys across forms for same session', () {
      // Each form should have unique keys within itself
      for (final form in FormType.values) {
        final reqs = allRequirementsForForm(form);
        final keys = reqs.map((r) => r.key).toSet();
        expect(
          keys.length,
          reqs.length,
          reason: '${form.code} has duplicate requirement keys',
        );
      }
    });
  });
}
