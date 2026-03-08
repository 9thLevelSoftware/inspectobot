import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/evidence_requirement.dart';
import 'package:inspectobot/features/inspection/domain/evidence_sharing_matrix.dart';
import 'package:inspectobot/features/inspection/domain/form_requirements.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/inspection_wizard_state.dart';
import 'package:inspectobot/features/inspection/domain/required_photo_category.dart';

void main() {
  group('Multi-form wizard step construction', () {
    test('all 7 forms produce correct step count and ordering', () {
      final state = InspectionWizardState(
        enabledForms: FormType.values.toSet(),
        snapshot: WizardProgressSnapshot.empty,
      );

      // 1 overview + 7 form steps = 8 total
      expect(state.steps.length, 8);

      // First step is always overview
      expect(state.steps.first.id, 'inspection_overview');
      expect(state.steps.first.form, isNull);

      // Form steps should be sorted by FormType.index
      final formSteps = state.steps.where((s) => s.form != null).toList();
      expect(formSteps.length, 7);

      final sortedFormTypes = FormType.values.toList()
        ..sort((a, b) => a.index.compareTo(b.index));

      for (var i = 0; i < formSteps.length; i++) {
        expect(
          formSteps[i].form,
          sortedFormTypes[i],
          reason:
              'Step $i should be ${sortedFormTypes[i]} but was ${formSteps[i].form}',
        );
      }
    });

    test('each form step has non-empty requirements', () {
      final state = InspectionWizardState(
        enabledForms: FormType.values.toSet(),
        snapshot: WizardProgressSnapshot.empty,
      );

      final formSteps = state.steps.where((s) => s.form != null);
      for (final step in formSteps) {
        expect(
          step.requirements,
          isNotEmpty,
          reason: '${step.form} should have requirements',
        );
      }
    });
  });

  group('Evidence sharing end-to-end', () {
    test(
        'capturing exteriorFront marks completion for fourPoint and generalInspection',
        () {
      // Create draft with both forms enabled
      final enabledForms = {FormType.fourPoint, FormType.generalInspection};

      // Start with empty completion
      final completion = <String, bool>{};

      // Simulate capturing exteriorFront photo (fourPoint's requirement)
      completion['photo:exterior_front'] = true;

      // Now simulate cross-form completion:
      // exteriorFront is semantically equivalent to generalFrontElevation.
      // The controller's _markCrossFormCompletion would mark the general form's
      // equivalent requirement too. We simulate that here at the domain level.
      final equivalents = EvidenceSharingMatrix.equivalentCategories(
        RequiredPhotoCategory.exteriorFront,
      );
      expect(equivalents, contains(RequiredPhotoCategory.generalFrontElevation));

      // Mark the equivalent requirement key
      completion['photo:general_front_elevation'] = true;

      // Build wizard state with the shared completion
      final state = InspectionWizardState(
        enabledForms: enabledForms,
        snapshot: WizardProgressSnapshot(
          lastStepIndex: 0,
          completion: completion,
          branchContext: const <String, dynamic>{},
          status: WizardProgressStatus.inProgress,
        ),
      );

      // Both forms' summaries should reflect the capture
      final summaries = state.buildFormSummaries();

      final fourPointSummary =
          summaries.firstWhere((s) => s.form == FormType.fourPoint);
      final generalSummary =
          summaries.firstWhere((s) => s.form == FormType.generalInspection);

      // exteriorFront should NOT be in fourPoint missing list
      expect(
        fourPointSummary.missingRequirements
            .any((r) => r.key == 'photo:exterior_front'),
        isFalse,
        reason: 'fourPoint should show exterior_front as captured',
      );

      // generalFrontElevation should NOT be in general missing list
      expect(
        generalSummary.missingRequirements
            .any((r) => r.key == 'photo:general_front_elevation'),
        isFalse,
        reason: 'generalInspection should show general_front_elevation as captured',
      );

      // Both should have percentComplete > 0
      expect(fourPointSummary.percentComplete, greaterThan(0));
      expect(generalSummary.percentComplete, greaterThan(0));
    });

    test('3-way sharing of roofSlopeMain across fourPoint + roofCondition', () {
      // roofSlopeMain is natively shared between fourPoint and roofCondition.
      // generalInspection does NOT have roofSlopeMain.
      final enabledForms = {
        FormType.fourPoint,
        FormType.roofCondition,
        FormType.generalInspection,
      };

      final acceptingForms = EvidenceSharingMatrix.formsAcceptingCategoryFiltered(
        RequiredPhotoCategory.roofSlopeMain,
        enabledForms,
      );

      // roofSlopeMain is shared between fourPoint and roofCondition
      expect(acceptingForms, contains(FormType.fourPoint));
      expect(acceptingForms, contains(FormType.roofCondition));
      // generalInspection does NOT use roofSlopeMain
      expect(acceptingForms, isNot(contains(FormType.generalInspection)));

      // Simulate capturing roofSlopeMain for fourPoint
      final completion = <String, bool>{
        'photo:roof_slope_main': true,
        'photo:roof_condition_main_slope': true, // cross-form completion
      };

      final state = InspectionWizardState(
        enabledForms: enabledForms,
        snapshot: WizardProgressSnapshot(
          lastStepIndex: 0,
          completion: completion,
          branchContext: const <String, dynamic>{},
          status: WizardProgressStatus.inProgress,
        ),
      );

      final summaries = state.buildFormSummaries();
      final fourPointSummary =
          summaries.firstWhere((s) => s.form == FormType.fourPoint);
      final roofSummary =
          summaries.firstWhere((s) => s.form == FormType.roofCondition);

      // roof_slope_main should be satisfied in fourPoint
      expect(
        fourPointSummary.missingRequirements
            .any((r) => r.key == 'photo:roof_slope_main'),
        isFalse,
      );

      // roof_condition_main_slope should be satisfied in roofCondition
      expect(
        roofSummary.missingRequirements
            .any((r) => r.key == 'photo:roof_condition_main_slope'),
        isFalse,
      );
    });
  });

  group('Non-shared evidence isolation', () {
    test('WDO-only evidence does not affect mold form progress', () {
      final enabledForms = {FormType.wdo, FormType.moldAssessment};

      // wdoInfestationEvidence requires wdo_visible_evidence branch flag
      final branchContext = <String, dynamic>{
        FormRequirements.wdoVisibleEvidenceBranchFlag: true,
      };

      // Get initial summaries (nothing captured)
      final initialState = InspectionWizardState(
        enabledForms: enabledForms,
        snapshot: WizardProgressSnapshot(
          lastStepIndex: 0,
          completion: const <String, bool>{},
          branchContext: branchContext,
          status: WizardProgressStatus.inProgress,
        ),
      );

      final initialMoldSummary = initialState
          .buildFormSummaries()
          .firstWhere((s) => s.form == FormType.moldAssessment);
      final initialMoldPercent = initialMoldSummary.percentComplete;

      // Capture wdoInfestationEvidence (WDO-only)
      final completion = <String, bool>{
        'photo:wdo_infestation_evidence': true,
      };

      final afterState = InspectionWizardState(
        enabledForms: enabledForms,
        snapshot: WizardProgressSnapshot(
          lastStepIndex: 0,
          completion: completion,
          branchContext: branchContext,
          status: WizardProgressStatus.inProgress,
        ),
      );

      final afterMoldSummary = afterState
          .buildFormSummaries()
          .firstWhere((s) => s.form == FormType.moldAssessment);

      // Mold progress should be unchanged
      expect(afterMoldSummary.percentComplete, initialMoldPercent);

      // But WDO progress should have increased
      final afterWdoSummary = afterState
          .buildFormSummaries()
          .firstWhere((s) => s.form == FormType.wdo);
      final initialWdoSummary = initialState
          .buildFormSummaries()
          .firstWhere((s) => s.form == FormType.wdo);

      expect(
        afterWdoSummary.percentComplete,
        greaterThan(initialWdoSummary.percentComplete),
      );

      // Verify the category is indeed WDO-only
      final wdoAccepting = EvidenceSharingMatrix.formsAcceptingCategory(
        RequiredPhotoCategory.wdoInfestationEvidence,
      );
      expect(wdoAccepting, {FormType.wdo});
    });
  });

  group('Per-form wizard independence (INTEG-01c)', () {
    test(
        'completing fourPoint does not complete moldAssessment or overall wizard',
        () {
      final enabledForms = {FormType.fourPoint, FormType.moldAssessment};

      // Complete ALL fourPoint requirements
      final completion = <String, bool>{};
      for (final req
          in FormRequirements.forFormRequirements(FormType.fourPoint)) {
        completion[req.key] = true;
      }

      final state = InspectionWizardState(
        enabledForms: enabledForms,
        snapshot: WizardProgressSnapshot(
          lastStepIndex: 0,
          completion: completion,
          branchContext: const <String, dynamic>{},
          status: WizardProgressStatus.inProgress,
        ),
      );

      final summaries = state.buildFormSummaries();
      final fourPointSummary =
          summaries.firstWhere((s) => s.form == FormType.fourPoint);
      final moldSummary =
          summaries.firstWhere((s) => s.form == FormType.moldAssessment);

      // fourPoint should be 100% complete
      expect(fourPointSummary.percentComplete, 100);
      expect(fourPointSummary.isComplete, isTrue);

      // moldAssessment should NOT be 100%
      expect(moldSummary.percentComplete, lessThan(100));
      expect(moldSummary.isComplete, isFalse);

      // Overall wizard should NOT be complete (both forms must be done)
      expect(state.isComplete, isFalse);
    });
  });

  group('Key alignment', () {
    test(
        'shared categories in EvidenceSharingMatrix match actual FormRequirements keys',
        () {
      // For each category that is shared, verify the requirement key exists
      // in FormRequirements for each form that claims to accept it.
      for (final category in RequiredPhotoCategory.values) {
        final acceptingForms =
            EvidenceSharingMatrix.formsAcceptingCategory(category);

        if (acceptingForms.length < 2) continue; // Not shared

        for (final form in acceptingForms) {
          // Get ALL requirements for the form (no branch filtering)
          final allRequirements =
              FormRequirements.canonicalSourceKeysForForm(form);

          // Find the specific requirement for this category
          final formReqs = _allRequirementsForForm(form);
          final matchingReqs =
              formReqs.where((r) => r.category == category).toList();

          // If this form accepts the category via semantic equivalence,
          // the actual requirement might use an equivalent category.
          if (matchingReqs.isEmpty) {
            // Check if the form has a requirement for an equivalent category
            final equivalents =
                EvidenceSharingMatrix.equivalentCategories(category);
            final equivMatches = formReqs
                .where((r) => equivalents.contains(r.category))
                .toList();

            expect(
              equivMatches,
              isNotEmpty,
              reason:
                  'Form $form claims to accept $category but has no '
                  'requirement for it or its equivalents',
            );
          } else {
            // Direct match — verify the key is in canonical source keys
            for (final req in matchingReqs) {
              expect(
                allRequirements,
                contains(req.key),
                reason:
                    'Requirement key ${req.key} for $category in $form '
                    'should exist in canonical source keys',
              );
            }
          }
        }
      }
    });

    test('semantic equivalents are bidirectional', () {
      // If A is equivalent to B, then B must be equivalent to A
      for (final category in RequiredPhotoCategory.values) {
        final equivalents =
            EvidenceSharingMatrix.equivalentCategories(category);
        for (final equiv in equivalents) {
          final reverseEquivalents =
              EvidenceSharingMatrix.equivalentCategories(equiv);
          expect(
            reverseEquivalents,
            contains(category),
            reason:
                '$equiv should list $category as equivalent (bidirectional)',
          );
        }
      }
    });
  });

  group('FormProgressSummary properties', () {
    test('percentComplete is 0 when nothing captured', () {
      final state = InspectionWizardState(
        enabledForms: {FormType.fourPoint},
        snapshot: WizardProgressSnapshot.empty,
      );

      final summary = state.buildFormSummaries().single;
      expect(summary.percentComplete, 0);
      expect(summary.isComplete, isFalse);
    });

    test('abbreviation returns correct values for all form types', () {
      final state = InspectionWizardState(
        enabledForms: FormType.values.toSet(),
        snapshot: WizardProgressSnapshot.empty,
      );

      final summaries = state.buildFormSummaries();
      final abbreviations = {
        for (final s in summaries) s.form: s.abbreviation,
      };

      expect(abbreviations[FormType.fourPoint], '4PT');
      expect(abbreviations[FormType.roofCondition], 'ROOF');
      expect(abbreviations[FormType.windMitigation], 'WIND');
      expect(abbreviations[FormType.wdo], 'WDO');
      expect(abbreviations[FormType.sinkholeInspection], 'SINK');
      expect(abbreviations[FormType.moldAssessment], 'MOLD');
      expect(abbreviations[FormType.generalInspection], 'GEN');
    });
  });
}

/// Helper: returns all requirements for a form without branch filtering.
/// Uses the internal structure by calling with all branch flags enabled.
List<EvidenceRequirement> _allRequirementsForForm(FormType form) {
  // Call with all possible branch flags set to true to get all requirements
  final allBranchFlags = <String, dynamic>{};
  for (final flag in FormRequirements.canonicalBranchFlags) {
    allBranchFlags[flag] = true;
  }
  return FormRequirements.forFormRequirements(form,
      branchContext: allBranchFlags);
}
