import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/mold_form_data.dart';
import 'package:inspectobot/features/pdf/narrative/templates/mold_assessment_template.dart';

void main() {
  group('Mold Assessment Integration Tests', () {
    // -----------------------------------------------------------------------
    // Test 1: FormData key alignment with MoldAssessmentTemplate
    // -----------------------------------------------------------------------
    group('formData key alignment', () {
      test(
        'toFormDataMap() keys exactly match MoldAssessmentTemplate.referencedFormDataKeys',
        () {
          final formData = MoldFormData(
            scopeOfAssessment: 'Full property assessment',
            visualObservations: 'Black mold on ceiling',
            moistureSources: 'Roof leak near flashing',
            moldTypeLocation: 'Aspergillus niger, master bathroom',
            remediationRecommendations: 'Remove affected drywall',
            additionalFindings: 'Minor water staining',
          );

          final map = formData.toFormDataMap();
          const template = MoldAssessmentTemplate();
          final expectedKeys = template.referencedFormDataKeys;

          // Keys from toFormDataMap must exactly match template expectations
          expect(
            map.keys.toSet(),
            equals(expectedKeys),
            reason:
                'toFormDataMap() keys must exactly match referencedFormDataKeys',
          );

          // Verify count matches
          expect(map.length, expectedKeys.length);

          // Verify each expected key is present with correct value
          expect(map['scope_of_assessment'], 'Full property assessment');
          expect(map['visual_observations'], 'Black mold on ceiling');
          expect(map['moisture_sources'], 'Roof leak near flashing');
          expect(
            map['mold_type_location'],
            'Aspergillus niger, master bathroom',
          );
          expect(map['remediation_recommendations'], 'Remove affected drywall');
          expect(map['additional_findings'], 'Minor water staining');
        },
      );

      test('template referencedFormDataKeys contains exactly 6 keys', () {
        const template = MoldAssessmentTemplate();
        expect(template.referencedFormDataKeys.length, 6);
      });
    });

    // -----------------------------------------------------------------------
    // Test 2: Draft persistence round-trip
    // -----------------------------------------------------------------------
    group('draft persistence round-trip', () {
      test('MoldFormData survives JSON encode/decode round-trip', () {
        final original = MoldFormData(
          scopeOfAssessment: 'Comprehensive mold assessment of 3BR/2BA home',
          visualObservations: 'Visible black mold on bathroom ceiling tiles',
          moistureSources: 'Active leak from HVAC condensate line',
          moldTypeLocation: 'Stachybotrys chartarum, master bath ceiling',
          remediationRecommendations:
              'Remove and replace all affected drywall and ceiling tiles',
          additionalFindings: 'Elevated humidity readings in adjacent closet',
          remediationRecommended: true,
          airSamplesTaken: true,
        );

        // Simulate draft persistence: toJson → encode → decode → fromJson
        final json = original.toJson();
        final encoded = jsonEncode(json);
        final decoded = jsonDecode(encoded) as Map<String, dynamic>;
        final restored = MoldFormData.fromJson(decoded);

        expect(restored, equals(original));
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

      test('draft stored in parent map round-trips correctly', () {
        final original = MoldFormData(
          scopeOfAssessment: 'Limited assessment — kitchen only',
          visualObservations: 'Green mold behind refrigerator',
          moistureSources: 'Supply line drip',
          moldTypeLocation: 'Penicillium, kitchen wall',
          remediationRecommendations: '',
          additionalFindings: '',
          remediationRecommended: false,
          airSamplesTaken: false,
        );

        // Simulate storing in a larger draft map
        final draftMap = <String, dynamic>{
          'inspectionId': 'insp-abc-123',
          'moldFormData': original.toJson(),
          'version': 1,
        };

        final encoded = jsonEncode(draftMap);
        final decoded = jsonDecode(encoded) as Map<String, dynamic>;
        final restoredMold = MoldFormData.fromJson(
          decoded['moldFormData'] as Map<String, dynamic>,
        );

        expect(restoredMold, equals(original));
      });
    });

    // -----------------------------------------------------------------------
    // Test 3: Empty form defaults
    // -----------------------------------------------------------------------
    group('empty form defaults', () {
      test('MoldFormData.empty() toFormDataMap returns empty strings', () {
        final data = MoldFormData.empty();
        final map = data.toFormDataMap();

        expect(map.length, 6);
        for (final entry in map.entries) {
          expect(
            entry.value,
            '',
            reason: 'Key "${entry.key}" should be empty string',
          );
        }
      });

      test('empty form produces no null values in toFormDataMap', () {
        final data = MoldFormData.empty();
        final map = data.toFormDataMap();

        for (final entry in map.entries) {
          expect(
            entry.value,
            isNotNull,
            reason: 'Key "${entry.key}" must not be null',
          );
          expect(
            entry.value,
            isA<String>(),
            reason: 'Key "${entry.key}" must be a String',
          );
        }
      });
    });

    // -----------------------------------------------------------------------
    // Test 4: Branch flag persistence
    // -----------------------------------------------------------------------
    group('branch flag persistence', () {
      test('flags set to true survive toJson → fromJson', () {
        final original = MoldFormData.empty().copyWith(
          remediationRecommended: true,
          airSamplesTaken: true,
        );

        final restored = MoldFormData.fromJson(original.toJson());

        expect(restored.remediationRecommended, true);
        expect(restored.airSamplesTaken, true);
      });

      test('flags set to false survive toJson → fromJson', () {
        final original = MoldFormData(
          scopeOfAssessment: 'test',
          remediationRecommended: false,
          airSamplesTaken: false,
        );

        final restored = MoldFormData.fromJson(original.toJson());

        expect(restored.remediationRecommended, false);
        expect(restored.airSamplesTaken, false);
      });

      test('mixed flag states survive round-trip', () {
        final original = MoldFormData.empty().copyWith(
          remediationRecommended: true,
          airSamplesTaken: false,
        );

        final restored = MoldFormData.fromJson(original.toJson());

        expect(restored.remediationRecommended, true);
        expect(restored.airSamplesTaken, false);
      });
    });

    // -----------------------------------------------------------------------
    // Test 5: PdfGenerationInput bridge
    // -----------------------------------------------------------------------
    group('PdfGenerationInput bridge', () {
      test('toFormDataMap produces map usable as PDF formData input', () {
        final formData = MoldFormData(
          scopeOfAssessment: 'Full assessment of single-family residence',
          visualObservations: 'Extensive mold growth on HVAC ducts',
          moistureSources: 'Condensation from undersized HVAC system',
          moldTypeLocation: 'Cladosporium, all supply ducts',
          remediationRecommendations:
              'Professional duct cleaning and HVAC resizing',
          additionalFindings: 'Filter last changed 18+ months ago',
        );

        final map = formData.toFormDataMap();

        // Verify the map contains all keys the template needs
        const template = MoldAssessmentTemplate();
        for (final key in template.referencedFormDataKeys) {
          expect(
            map.containsKey(key),
            true,
            reason: 'PDF bridge map must contain key "$key"',
          );
          expect(
            map[key],
            isNotEmpty,
            reason: 'PDF bridge map key "$key" should have content',
          );
        }
      });

      test('toFormDataMap values are String type for PDF engine', () {
        final formData = MoldFormData(
          scopeOfAssessment: 'Assessment scope',
          visualObservations: 'Observations',
          moistureSources: 'Sources',
          moldTypeLocation: 'Type/Location',
          remediationRecommendations: 'Recommendations',
          additionalFindings: 'Findings',
        );

        final map = formData.toFormDataMap();

        for (final entry in map.entries) {
          expect(
            entry.value,
            isA<String>(),
            reason: 'All values must be String for PDF engine',
          );
        }
      });
    });

    // -----------------------------------------------------------------------
    // Test 6: Partial form data
    // -----------------------------------------------------------------------
    group('partial form data', () {
      test(
        'only some fields filled returns empty strings for unfilled (no nulls)',
        () {
          final formData = MoldFormData(
            scopeOfAssessment: 'Limited kitchen assessment',
            moistureSources: 'Dishwasher supply line',
          );

          final map = formData.toFormDataMap();

          // Filled fields
          expect(map['scope_of_assessment'], 'Limited kitchen assessment');
          expect(map['moisture_sources'], 'Dishwasher supply line');

          // Unfilled fields — must be empty string, not null
          expect(map['visual_observations'], '');
          expect(map['mold_type_location'], '');
          expect(map['remediation_recommendations'], '');
          expect(map['additional_findings'], '');

          // No null values anywhere
          for (final entry in map.entries) {
            expect(
              entry.value,
              isNotNull,
              reason: 'Key "${entry.key}" must not be null',
            );
          }
        },
      );

      test('single field filled still produces all 6 keys', () {
        final formData = MoldFormData(
          scopeOfAssessment: 'Bathroom only',
        );

        final map = formData.toFormDataMap();
        expect(map.length, 6);
        expect(map['scope_of_assessment'], 'Bathroom only');
      });
    });
  });
}
