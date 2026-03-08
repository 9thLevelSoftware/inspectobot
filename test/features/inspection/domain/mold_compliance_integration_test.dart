import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/mold_compliance_validator.dart';
import 'package:inspectobot/features/inspection/domain/mold_form_data.dart';

void main() {
  group('Mold Compliance Integration Tests', () {
    // Helpers
    MoldFormData fullyCompliant() {
      return const MoldFormData(
        scopeOfAssessment: 'Full property mold assessment per Ch. 468',
        visualObservations: 'Visible mold colonies on bathroom ceiling',
        moistureSources: 'Active roof leak at flashing penetration',
        moldTypeLocation: 'Aspergillus niger, master bathroom ceiling',
        remediationRecommendations: 'Remove all affected drywall and treat',
        additionalFindings: 'Elevated humidity in adjacent closet',
        remediationRecommended: true,
        airSamplesTaken: false,
      );
    }

    Map<String, int> fullPhotoCounts() => {
          MoldComplianceValidator.photoKeyMoistureReadings: 2,
          MoldComplianceValidator.photoKeyGrowthEvidence: 3,
          MoldComplianceValidator.photoKeyAffectedAreas: 2,
        };

    // -----------------------------------------------------------------------
    // Test 1: Fully compliant
    // -----------------------------------------------------------------------
    test('fully compliant form passes all checks', () {
      final result = MoldComplianceValidator.validate(
        fullyCompliant(),
        hasInspectorLicense: true,
        photoCounts: fullPhotoCounts(),
      );

      expect(result.isCompliant, true);
      expect(result.missingElements, isEmpty);
    });

    // -----------------------------------------------------------------------
    // Test 2: No license
    // -----------------------------------------------------------------------
    test('missing MRSA license fails compliance', () {
      final result = MoldComplianceValidator.validate(
        fullyCompliant(),
        hasInspectorLicense: false,
        photoCounts: fullPhotoCounts(),
      );

      expect(result.isCompliant, false);
      expect(result.missingElements, contains('MRSA license is required'));
    });

    // -----------------------------------------------------------------------
    // Test 3: Missing mandatory narratives (each individually)
    // -----------------------------------------------------------------------
    group('missing mandatory narratives', () {
      test('empty scope of assessment fails', () {
        final result = MoldComplianceValidator.validate(
          fullyCompliant().copyWith(scopeOfAssessment: ''),
          hasInspectorLicense: true,
          photoCounts: fullPhotoCounts(),
        );

        expect(result.isCompliant, false);
        expect(
          result.missingElements,
          contains('Scope of assessment is required'),
        );
      });

      test('empty visual observations fails', () {
        final result = MoldComplianceValidator.validate(
          fullyCompliant().copyWith(visualObservations: ''),
          hasInspectorLicense: true,
          photoCounts: fullPhotoCounts(),
        );

        expect(result.isCompliant, false);
        expect(
          result.missingElements,
          contains('Visual observations is required'),
        );
      });

      test('empty moisture sources fails', () {
        final result = MoldComplianceValidator.validate(
          fullyCompliant().copyWith(moistureSources: ''),
          hasInspectorLicense: true,
          photoCounts: fullPhotoCounts(),
        );

        expect(result.isCompliant, false);
        expect(
          result.missingElements,
          contains('Moisture source identification is required'),
        );
      });

      test('empty mold type/location fails', () {
        final result = MoldComplianceValidator.validate(
          fullyCompliant().copyWith(moldTypeLocation: ''),
          hasInspectorLicense: true,
          photoCounts: fullPhotoCounts(),
        );

        expect(result.isCompliant, false);
        expect(
          result.missingElements,
          contains('Mold type and location is required'),
        );
      });
    });

    // -----------------------------------------------------------------------
    // Test 4: Remediation branch
    // -----------------------------------------------------------------------
    group('remediation branch logic', () {
      test('remediation recommended + empty recommendations → fails', () {
        final result = MoldComplianceValidator.validate(
          fullyCompliant().copyWith(
            remediationRecommended: true,
            remediationRecommendations: '',
          ),
          hasInspectorLicense: true,
          photoCounts: fullPhotoCounts(),
        );

        expect(result.isCompliant, false);
        expect(
          result.missingElements,
          contains(
            'Remediation recommendations required when remediation is recommended',
          ),
        );
      });

      test('remediation recommended + filled recommendations → passes', () {
        final result = MoldComplianceValidator.validate(
          fullyCompliant().copyWith(
            remediationRecommended: true,
            remediationRecommendations: 'Remove affected materials',
          ),
          hasInspectorLicense: true,
          photoCounts: fullPhotoCounts(),
        );

        expect(result.isCompliant, true);
      });

      test(
        'remediation not recommended + empty recommendations → passes',
        () {
          final result = MoldComplianceValidator.validate(
            fullyCompliant().copyWith(
              remediationRecommended: false,
              remediationRecommendations: '',
            ),
            hasInspectorLicense: true,
            photoCounts: fullPhotoCounts(),
          );

          expect(result.isCompliant, true);
        },
      );
    });

    // -----------------------------------------------------------------------
    // Test 5: Photo evidence
    // -----------------------------------------------------------------------
    group('photo evidence requirements', () {
      test('all zero photo counts → 3 photo failures', () {
        final result = MoldComplianceValidator.validate(
          fullyCompliant(),
          hasInspectorLicense: true,
          photoCounts: {
            MoldComplianceValidator.photoKeyMoistureReadings: 0,
            MoldComplianceValidator.photoKeyGrowthEvidence: 0,
            MoldComplianceValidator.photoKeyAffectedAreas: 0,
          },
        );

        expect(result.isCompliant, false);
        expect(
          result.missingElements,
          contains('At least 1 moisture readings photo is required'),
        );
        expect(
          result.missingElements,
          contains('At least 1 mold growth evidence photo is required'),
        );
        expect(
          result.missingElements,
          contains('At least 1 affected areas photo is required'),
        );
      });

      test('partial photos → only missing categories fail', () {
        final result = MoldComplianceValidator.validate(
          fullyCompliant(),
          hasInspectorLicense: true,
          photoCounts: {
            MoldComplianceValidator.photoKeyMoistureReadings: 1,
            MoldComplianceValidator.photoKeyGrowthEvidence: 0,
            MoldComplianceValidator.photoKeyAffectedAreas: 2,
          },
        );

        expect(result.isCompliant, false);
        expect(result.missingElements.length, 1);
        expect(
          result.missingElements,
          contains('At least 1 mold growth evidence photo is required'),
        );
      });

      test('all categories >= 1 → passes photo checks', () {
        final result = MoldComplianceValidator.validate(
          fullyCompliant(),
          hasInspectorLicense: true,
          photoCounts: {
            MoldComplianceValidator.photoKeyMoistureReadings: 1,
            MoldComplianceValidator.photoKeyGrowthEvidence: 1,
            MoldComplianceValidator.photoKeyAffectedAreas: 1,
          },
        );

        expect(result.isCompliant, true);
      });

      test('empty photoCounts map fails all 3 photo checks', () {
        final result = MoldComplianceValidator.validate(
          fullyCompliant(),
          hasInspectorLicense: true,
          photoCounts: <String, int>{},
        );

        expect(result.isCompliant, false);
        // Should have exactly 3 photo-related failures
        final photoFailures = result.missingElements
            .where((e) => e.contains('photo'))
            .toList();
        expect(photoFailures.length, 3);
      });
    });

    // -----------------------------------------------------------------------
    // Test 6: Multiple failures
    // -----------------------------------------------------------------------
    test('multiple missing items are all listed', () {
      final result = MoldComplianceValidator.validate(
        MoldFormData.empty().copyWith(
          remediationRecommended: true,
        ),
        hasInspectorLicense: false,
        photoCounts: <String, int>{},
      );

      expect(result.isCompliant, false);

      // License (1) + 4 mandatory fields (4) + remediation conditional (1)
      // + 3 photo categories (3) = 9
      expect(result.missingElements.length, 9);

      expect(
        result.missingElements,
        contains('MRSA license is required'),
      );
      expect(
        result.missingElements,
        contains('Scope of assessment is required'),
      );
      expect(
        result.missingElements,
        contains('Visual observations is required'),
      );
      expect(
        result.missingElements,
        contains('Moisture source identification is required'),
      );
      expect(
        result.missingElements,
        contains('Mold type and location is required'),
      );
      expect(
        result.missingElements,
        contains(
          'Remediation recommendations required when remediation is recommended',
        ),
      );
      expect(
        result.missingElements,
        contains('At least 1 moisture readings photo is required'),
      );
      expect(
        result.missingElements,
        contains('At least 1 mold growth evidence photo is required'),
      );
      expect(
        result.missingElements,
        contains('At least 1 affected areas photo is required'),
      );
    });

    // -----------------------------------------------------------------------
    // Test 7: Warning scenarios
    // -----------------------------------------------------------------------
    group('warning scenarios', () {
      test('empty additional findings produces warning', () {
        final result = MoldComplianceValidator.validate(
          fullyCompliant().copyWith(additionalFindings: ''),
          hasInspectorLicense: true,
          photoCounts: fullPhotoCounts(),
        );

        expect(
          result.warnings,
          contains('Additional findings section is empty (recommended)'),
        );
      });

      test(
        'mold growth evidence present but no remediation recommended → warning',
        () {
          final result = MoldComplianceValidator.validate(
            fullyCompliant().copyWith(remediationRecommended: false),
            hasInspectorLicense: true,
            photoCounts: fullPhotoCounts(),
          );

          expect(
            result.warnings,
            contains(
              'Consider recommending remediation when mold growth is documented',
            ),
          );
        },
      );

      test(
        'no mold growth evidence + no remediation → no remediation warning',
        () {
          final counts = fullPhotoCounts()..[MoldComplianceValidator.photoKeyGrowthEvidence] = 0;
          final result = MoldComplianceValidator.validate(
            fullyCompliant().copyWith(remediationRecommended: false),
            hasInspectorLicense: true,
            photoCounts: counts,
          );

          expect(
            result.warnings,
            isNot(contains(
              'Consider recommending remediation when mold growth is documented',
            )),
          );
        },
      );
    });

    // -----------------------------------------------------------------------
    // Test 8: Only warnings, no failures → still compliant
    // -----------------------------------------------------------------------
    test('only warnings with no failures → isCompliant is still true', () {
      // Create a form that has no failures but triggers warnings:
      // - empty additionalFindings → warning
      // - remediationRecommended false + growth evidence present → warning
      final formData = MoldFormData(
        scopeOfAssessment: 'Full assessment',
        visualObservations: 'Mold observed',
        moistureSources: 'Roof leak',
        moldTypeLocation: 'Aspergillus, bathroom',
        remediationRecommendations: '',
        additionalFindings: '',
        remediationRecommended: false,
        airSamplesTaken: false,
      );

      final result = MoldComplianceValidator.validate(
        formData,
        hasInspectorLicense: true,
        photoCounts: fullPhotoCounts(),
      );

      expect(result.isCompliant, true);
      expect(result.missingElements, isEmpty);
      expect(result.warnings, isNotEmpty);
      expect(result.warnings.length, 2);
      expect(
        result.warnings,
        contains('Additional findings section is empty (recommended)'),
      );
      expect(
        result.warnings,
        contains(
          'Consider recommending remediation when mold growth is documented',
        ),
      );
    });
  });
}
