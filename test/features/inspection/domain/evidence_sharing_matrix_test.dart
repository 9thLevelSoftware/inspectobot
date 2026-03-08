import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/evidence_sharing_matrix.dart';
import 'package:inspectobot/features/inspection/domain/evidence_requirement.dart';
import 'package:inspectobot/features/inspection/domain/form_requirements.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/inspection_wizard_state.dart';
import 'package:inspectobot/features/inspection/domain/required_photo_category.dart';

void main() {
  group('EvidenceSharingMatrix', () {
    group('natively shared categories', () {
      test('roofSlopeMain is shared by fourPoint and roofCondition', () {
        final forms = EvidenceSharingMatrix.formsAcceptingCategory(
          RequiredPhotoCategory.roofSlopeMain,
        );
        expect(forms, containsAll([FormType.fourPoint, FormType.roofCondition]));
        expect(forms.length, 2);
      });

      test('roofSlopeSecondary is shared by fourPoint and roofCondition', () {
        final forms = EvidenceSharingMatrix.formsAcceptingCategory(
          RequiredPhotoCategory.roofSlopeSecondary,
        );
        expect(forms, containsAll([FormType.fourPoint, FormType.roofCondition]));
        expect(forms.length, 2);
      });
    });

    group('semantically shared categories', () {
      test(
        'exteriorFront maps to fourPoint and generalInspection',
        () {
          final forms = EvidenceSharingMatrix.formsAcceptingCategory(
            RequiredPhotoCategory.exteriorFront,
          );
          expect(
            forms,
            containsAll([FormType.fourPoint, FormType.generalInspection]),
          );
          expect(forms.length, 2);
        },
      );

      test(
        'generalFrontElevation maps to fourPoint and generalInspection',
        () {
          final forms = EvidenceSharingMatrix.formsAcceptingCategory(
            RequiredPhotoCategory.generalFrontElevation,
          );
          expect(
            forms,
            containsAll([FormType.fourPoint, FormType.generalInspection]),
          );
          expect(forms.length, 2);
        },
      );

      test(
        'electricalPanelLabel maps to fourPoint and generalInspection',
        () {
          final forms = EvidenceSharingMatrix.formsAcceptingCategory(
            RequiredPhotoCategory.electricalPanelLabel,
          );
          expect(
            forms,
            containsAll([FormType.fourPoint, FormType.generalInspection]),
          );
          expect(forms.length, 2);
        },
      );

      test(
        'generalElectricalPanel maps to fourPoint and generalInspection',
        () {
          final forms = EvidenceSharingMatrix.formsAcceptingCategory(
            RequiredPhotoCategory.generalElectricalPanel,
          );
          expect(
            forms,
            containsAll([FormType.fourPoint, FormType.generalInspection]),
          );
          expect(forms.length, 2);
        },
      );

      test(
        'hvacDataPlate maps to fourPoint and generalInspection',
        () {
          final forms = EvidenceSharingMatrix.formsAcceptingCategory(
            RequiredPhotoCategory.hvacDataPlate,
          );
          expect(
            forms,
            containsAll([FormType.fourPoint, FormType.generalInspection]),
          );
          expect(forms.length, 2);
        },
      );

      test(
        'generalDataPlate maps to fourPoint and generalInspection',
        () {
          final forms = EvidenceSharingMatrix.formsAcceptingCategory(
            RequiredPhotoCategory.generalDataPlate,
          );
          expect(
            forms,
            containsAll([FormType.fourPoint, FormType.generalInspection]),
          );
          expect(forms.length, 2);
        },
      );
    });

    group('non-shared categories', () {
      test('windRoofDeck returns only windMitigation', () {
        final forms = EvidenceSharingMatrix.formsAcceptingCategory(
          RequiredPhotoCategory.windRoofDeck,
        );
        expect(forms, {FormType.windMitigation});
      });

      test('wdoPropertyExterior returns only wdo', () {
        final forms = EvidenceSharingMatrix.formsAcceptingCategory(
          RequiredPhotoCategory.wdoPropertyExterior,
        );
        expect(forms, {FormType.wdo});
      });

      test('moldAffectedArea returns only moldAssessment', () {
        final forms = EvidenceSharingMatrix.formsAcceptingCategory(
          RequiredPhotoCategory.moldAffectedArea,
        );
        expect(forms, {FormType.moldAssessment});
      });
    });

    group('equivalentCategories', () {
      test('exteriorFront has generalFrontElevation as equivalent', () {
        final equivalents = EvidenceSharingMatrix.equivalentCategories(
          RequiredPhotoCategory.exteriorFront,
        );
        expect(equivalents, {RequiredPhotoCategory.generalFrontElevation});
      });

      test('generalFrontElevation has exteriorFront as equivalent', () {
        final equivalents = EvidenceSharingMatrix.equivalentCategories(
          RequiredPhotoCategory.generalFrontElevation,
        );
        expect(equivalents, {RequiredPhotoCategory.exteriorFront});
      });

      test('roofSlopeMain has no semantic equivalents (natively shared)', () {
        final equivalents = EvidenceSharingMatrix.equivalentCategories(
          RequiredPhotoCategory.roofSlopeMain,
        );
        expect(equivalents, isEmpty);
      });

      test('windRoofDeck has no equivalents', () {
        final equivalents = EvidenceSharingMatrix.equivalentCategories(
          RequiredPhotoCategory.windRoofDeck,
        );
        expect(equivalents, isEmpty);
      });
    });

    group('formsAcceptingCategoryFiltered', () {
      test('filters to only enabled forms', () {
        final forms = EvidenceSharingMatrix.formsAcceptingCategoryFiltered(
          RequiredPhotoCategory.roofSlopeMain,
          {FormType.fourPoint},
        );
        expect(forms, {FormType.fourPoint});
      });

      test('returns empty when no enabled forms match', () {
        final forms = EvidenceSharingMatrix.formsAcceptingCategoryFiltered(
          RequiredPhotoCategory.roofSlopeMain,
          {FormType.windMitigation},
        );
        expect(forms, isEmpty);
      });

      test('includes semantic equivalents when enabled', () {
        final forms = EvidenceSharingMatrix.formsAcceptingCategoryFiltered(
          RequiredPhotoCategory.exteriorFront,
          {FormType.fourPoint, FormType.generalInspection},
        );
        expect(
          forms,
          containsAll([FormType.fourPoint, FormType.generalInspection]),
        );
      });
    });

    group('isSharedCategory', () {
      test('roofSlopeMain is shared (native)', () {
        expect(
          EvidenceSharingMatrix.isSharedCategory(
            RequiredPhotoCategory.roofSlopeMain,
          ),
          isTrue,
        );
      });

      test('exteriorFront is shared (semantic)', () {
        expect(
          EvidenceSharingMatrix.isSharedCategory(
            RequiredPhotoCategory.exteriorFront,
          ),
          isTrue,
        );
      });

      test('windRoofDeck is not shared', () {
        expect(
          EvidenceSharingMatrix.isSharedCategory(
            RequiredPhotoCategory.windRoofDeck,
          ),
          isFalse,
        );
      });

      test('wdoPropertyExterior is not shared', () {
        expect(
          EvidenceSharingMatrix.isSharedCategory(
            RequiredPhotoCategory.wdoPropertyExterior,
          ),
          isFalse,
        );
      });
    });

    group('golden: no orphan categories', () {
      test('every RequiredPhotoCategory has at least one form mapped', () {
        for (final category in RequiredPhotoCategory.values) {
          final forms = EvidenceSharingMatrix.formsAcceptingCategory(category);
          expect(
            forms,
            isNotEmpty,
            reason: '${category.name} has no form mapping — orphaned category',
          );
        }
      });
    });
  });

  group('FormRequirements.formsRequiringCategory', () {
    test('delegates to EvidenceSharingMatrix correctly', () {
      final fromMatrix = EvidenceSharingMatrix.formsAcceptingCategory(
        RequiredPhotoCategory.roofSlopeMain,
      );
      final fromRequirements = FormRequirements.formsRequiringCategory(
        RequiredPhotoCategory.roofSlopeMain,
      );
      expect(fromRequirements, fromMatrix);
    });

    test('works for semantically shared categories', () {
      final forms = FormRequirements.formsRequiringCategory(
        RequiredPhotoCategory.exteriorFront,
      );
      expect(
        forms,
        containsAll([FormType.fourPoint, FormType.generalInspection]),
      );
    });
  });

  group('FormProgressSummary', () {
    group('percentComplete', () {
      test('0 missing of 10 total → 100%', () {
        final summary = FormProgressSummary(
          form: FormType.fourPoint,
          missingRequirements: const [],
          totalRequirements: 10,
        );
        expect(summary.percentComplete, 100);
      });

      test('5 missing of 10 total → 50%', () {
        final missing = List.generate(
          5,
          (i) => EvidenceRequirement(
            key: 'test:$i',
            label: 'Test $i',
            form: FormType.fourPoint,
            mediaType: EvidenceMediaType.photo,
            minimumCount: 1,
          ),
        );
        final summary = FormProgressSummary(
          form: FormType.fourPoint,
          missingRequirements: missing,
          totalRequirements: 10,
        );
        expect(summary.percentComplete, 50);
      });

      test('10 missing of 10 total → 0%', () {
        final missing = List.generate(
          10,
          (i) => EvidenceRequirement(
            key: 'test:$i',
            label: 'Test $i',
            form: FormType.fourPoint,
            mediaType: EvidenceMediaType.photo,
            minimumCount: 1,
          ),
        );
        final summary = FormProgressSummary(
          form: FormType.fourPoint,
          missingRequirements: missing,
          totalRequirements: 10,
        );
        expect(summary.percentComplete, 0);
      });

      test('0 total requirements → 100%', () {
        final summary = FormProgressSummary(
          form: FormType.fourPoint,
          missingRequirements: const [],
          totalRequirements: 0,
        );
        expect(summary.percentComplete, 100);
      });

      test('3 missing of 7 total → 57% (rounds correctly)', () {
        final missing = List.generate(
          3,
          (i) => EvidenceRequirement(
            key: 'test:$i',
            label: 'Test $i',
            form: FormType.fourPoint,
            mediaType: EvidenceMediaType.photo,
            minimumCount: 1,
          ),
        );
        final summary = FormProgressSummary(
          form: FormType.fourPoint,
          missingRequirements: missing,
          totalRequirements: 7,
        );
        // (7-3)/7 * 100 = 57.14... → rounds to 57
        expect(summary.percentComplete, 57);
      });
    });

    group('abbreviation', () {
      test('fourPoint → 4PT', () {
        final summary = FormProgressSummary(
          form: FormType.fourPoint,
          missingRequirements: const [],
          totalRequirements: 0,
        );
        expect(summary.abbreviation, '4PT');
      });

      test('roofCondition → ROOF', () {
        final summary = FormProgressSummary(
          form: FormType.roofCondition,
          missingRequirements: const [],
          totalRequirements: 0,
        );
        expect(summary.abbreviation, 'ROOF');
      });

      test('windMitigation → WIND', () {
        final summary = FormProgressSummary(
          form: FormType.windMitigation,
          missingRequirements: const [],
          totalRequirements: 0,
        );
        expect(summary.abbreviation, 'WIND');
      });

      test('wdo → WDO', () {
        final summary = FormProgressSummary(
          form: FormType.wdo,
          missingRequirements: const [],
          totalRequirements: 0,
        );
        expect(summary.abbreviation, 'WDO');
      });

      test('sinkholeInspection → SINK', () {
        final summary = FormProgressSummary(
          form: FormType.sinkholeInspection,
          missingRequirements: const [],
          totalRequirements: 0,
        );
        expect(summary.abbreviation, 'SINK');
      });

      test('moldAssessment → MOLD', () {
        final summary = FormProgressSummary(
          form: FormType.moldAssessment,
          missingRequirements: const [],
          totalRequirements: 0,
        );
        expect(summary.abbreviation, 'MOLD');
      });

      test('generalInspection → GEN', () {
        final summary = FormProgressSummary(
          form: FormType.generalInspection,
          missingRequirements: const [],
          totalRequirements: 0,
        );
        expect(summary.abbreviation, 'GEN');
      });
    });

    test('backward compatibility: isComplete still works', () {
      final summary = FormProgressSummary(
        form: FormType.fourPoint,
        missingRequirements: const [],
        totalRequirements: 5,
      );
      expect(summary.isComplete, isTrue);
    });
  });
}
