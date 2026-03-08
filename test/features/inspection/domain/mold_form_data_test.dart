import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/mold_form_data.dart';

void main() {
  group('MoldFormData', () {
    group('empty()', () {
      test('produces expected defaults', () {
        final data = MoldFormData.empty();
        expect(data.scopeOfAssessment, '');
        expect(data.visualObservations, '');
        expect(data.moistureSources, '');
        expect(data.moldTypeLocation, '');
        expect(data.remediationRecommendations, '');
        expect(data.additionalFindings, '');
        expect(data.remediationRecommended, false);
        expect(data.airSamplesTaken, false);
      });
    });

    group('copyWith', () {
      test('preserves unchanged fields', () {
        final original = MoldFormData(
          scopeOfAssessment: 'Full assessment',
          visualObservations: 'Black mold on wall',
          moistureSources: 'Leaking pipe',
          moldTypeLocation: 'Aspergillus, bathroom',
          remediationRecommendations: 'Remove drywall',
          additionalFindings: 'Minor staining',
          remediationRecommended: true,
          airSamplesTaken: true,
        );

        final modified = original.copyWith(
          scopeOfAssessment: 'Limited assessment',
        );

        expect(modified.scopeOfAssessment, 'Limited assessment');
        expect(modified.visualObservations, 'Black mold on wall');
        expect(modified.moistureSources, 'Leaking pipe');
        expect(modified.moldTypeLocation, 'Aspergillus, bathroom');
        expect(modified.remediationRecommendations, 'Remove drywall');
        expect(modified.additionalFindings, 'Minor staining');
        expect(modified.remediationRecommended, true);
        expect(modified.airSamplesTaken, true);
      });

      test('updates boolean flags', () {
        final original = MoldFormData.empty();
        final modified = original.copyWith(
          remediationRecommended: true,
          airSamplesTaken: true,
        );

        expect(modified.remediationRecommended, true);
        expect(modified.airSamplesTaken, true);
      });
    });

    group('toFormDataMap()', () {
      test('returns correct keys matching MoldAssessmentTemplate', () {
        final data = MoldFormData(
          scopeOfAssessment: 'scope',
          visualObservations: 'visual',
          moistureSources: 'moisture',
          moldTypeLocation: 'type',
          remediationRecommendations: 'remediation',
          additionalFindings: 'findings',
        );

        final map = data.toFormDataMap();

        expect(map.length, 6);
        expect(map.containsKey('scope_of_assessment'), true);
        expect(map.containsKey('visual_observations'), true);
        expect(map.containsKey('moisture_sources'), true);
        expect(map.containsKey('mold_type_location'), true);
        expect(map.containsKey('remediation_recommendations'), true);
        expect(map.containsKey('additional_findings'), true);

        expect(map['scope_of_assessment'], 'scope');
        expect(map['visual_observations'], 'visual');
        expect(map['moisture_sources'], 'moisture');
        expect(map['mold_type_location'], 'type');
        expect(map['remediation_recommendations'], 'remediation');
        expect(map['additional_findings'], 'findings');
      });
    });

    group('toJson/fromJson', () {
      test('round-trip preserves all fields including branch flags', () {
        final original = MoldFormData(
          scopeOfAssessment: 'Full property assessment',
          visualObservations: 'Visible mold on ceiling',
          moistureSources: 'Roof leak',
          moldTypeLocation: 'Stachybotrys, master bath',
          remediationRecommendations: 'Professional remediation required',
          additionalFindings: 'Water damage in closet',
          remediationRecommended: true,
          airSamplesTaken: true,
        );

        final json = original.toJson();
        final restored = MoldFormData.fromJson(json);

        expect(restored, original);
        expect(restored.scopeOfAssessment, original.scopeOfAssessment);
        expect(restored.visualObservations, original.visualObservations);
        expect(restored.moistureSources, original.moistureSources);
        expect(restored.moldTypeLocation, original.moldTypeLocation);
        expect(
          restored.remediationRecommendations,
          original.remediationRecommendations,
        );
        expect(restored.additionalFindings, original.additionalFindings);
        expect(restored.remediationRecommended, true);
        expect(restored.airSamplesTaken, true);
      });

      test('fromJson with missing keys uses safe defaults', () {
        final data = MoldFormData.fromJson(<String, dynamic>{});

        expect(data.scopeOfAssessment, '');
        expect(data.visualObservations, '');
        expect(data.moistureSources, '');
        expect(data.moldTypeLocation, '');
        expect(data.remediationRecommendations, '');
        expect(data.additionalFindings, '');
        expect(data.remediationRecommended, false);
        expect(data.airSamplesTaken, false);
      });

      test('fromJson with partial keys fills missing with defaults', () {
        final data = MoldFormData.fromJson(<String, dynamic>{
          'scopeOfAssessment': 'partial',
          'remediationRecommended': true,
        });

        expect(data.scopeOfAssessment, 'partial');
        expect(data.visualObservations, '');
        expect(data.remediationRecommended, true);
        expect(data.airSamplesTaken, false);
      });
    });

    group('isEmpty', () {
      test('returns true for empty form', () {
        expect(MoldFormData.empty().isEmpty, true);
      });

      test('returns false when any text field is set', () {
        expect(
          MoldFormData.empty()
              .copyWith(scopeOfAssessment: 'something')
              .isEmpty,
          false,
        );
        expect(
          MoldFormData.empty()
              .copyWith(additionalFindings: 'note')
              .isEmpty,
          false,
        );
      });

      test('returns false when remediationRecommended is true', () {
        expect(
          MoldFormData.empty()
              .copyWith(remediationRecommended: true)
              .isEmpty,
          false,
        );
      });

      test('returns false when airSamplesTaken is true', () {
        expect(
          MoldFormData.empty()
              .copyWith(airSamplesTaken: true)
              .isEmpty,
          false,
        );
      });
    });

    group('equality', () {
      test('two empty instances are equal', () {
        expect(MoldFormData.empty(), MoldFormData.empty());
        expect(MoldFormData.empty().hashCode, MoldFormData.empty().hashCode);
      });

      test('different values are not equal', () {
        final a = MoldFormData.empty();
        final b = a.copyWith(scopeOfAssessment: 'different');
        expect(a, isNot(b));
      });
    });
  });
}
