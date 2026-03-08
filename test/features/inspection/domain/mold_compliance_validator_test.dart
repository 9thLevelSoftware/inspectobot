import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/mold_compliance_validator.dart';
import 'package:inspectobot/features/inspection/domain/mold_form_data.dart';

void main() {
  group('MoldComplianceValidator', () {
    MoldFormData fullyCompliant() {
      return const MoldFormData(
        scopeOfAssessment: 'Full property mold assessment',
        visualObservations: 'Visible mold on bathroom ceiling',
        moistureSources: 'Leaking shower pan identified',
        moldTypeLocation: 'Aspergillus niger, master bathroom ceiling',
        remediationRecommendations: 'Remove affected drywall',
        additionalFindings: 'Minor water staining in adjacent closet',
        remediationRecommended: true,
        airSamplesTaken: false,
      );
    }

    Map<String, int> fullPhotoCounts() => {
          MoldComplianceValidator.photoKeyMoistureReadings: 2,
          MoldComplianceValidator.photoKeyGrowthEvidence: 3,
          MoldComplianceValidator.photoKeyAffectedAreas: 2,
        };

    test('fully compliant form returns isCompliant: true', () {
      final result = MoldComplianceValidator.validate(
        fullyCompliant(),
        hasInspectorLicense: true,
        photoCounts: fullPhotoCounts(),
      );

      expect(result.isCompliant, true);
      expect(result.missingElements, isEmpty);
    });

    test('missing license returns isCompliant: false', () {
      final result = MoldComplianceValidator.validate(
        fullyCompliant(),
        hasInspectorLicense: false,
        photoCounts: fullPhotoCounts(),
      );

      expect(result.isCompliant, false);
      expect(
        result.missingElements,
        contains('MRSA license is required'),
      );
    });

    group('empty mandatory fields', () {
      test('empty scopeOfAssessment', () {
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

      test('empty visualObservations', () {
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

      test('empty moistureSources', () {
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

      test('empty moldTypeLocation', () {
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

      test('whitespace-only fields count as empty', () {
        final result = MoldComplianceValidator.validate(
          fullyCompliant().copyWith(scopeOfAssessment: '   '),
          hasInspectorLicense: true,
          photoCounts: fullPhotoCounts(),
        );

        expect(result.isCompliant, false);
      });
    });

    group('remediation conditional', () {
      test(
        'remediation flag true + empty recommendations → isCompliant: false',
        () {
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
        },
      );

      test(
        'remediation flag false + empty recommendations → isCompliant: true',
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

    group('missing photos', () {
      test('missing moisture readings photo', () {
        final counts = fullPhotoCounts()..[MoldComplianceValidator.photoKeyMoistureReadings] = 0;
        final result = MoldComplianceValidator.validate(
          fullyCompliant(),
          hasInspectorLicense: true,
          photoCounts: counts,
        );

        expect(result.isCompliant, false);
        expect(
          result.missingElements,
          contains('At least 1 moisture readings photo is required'),
        );
      });

      test('missing mold growth evidence photo', () {
        final counts = fullPhotoCounts()..[MoldComplianceValidator.photoKeyGrowthEvidence] = 0;
        final result = MoldComplianceValidator.validate(
          fullyCompliant(),
          hasInspectorLicense: true,
          photoCounts: counts,
        );

        expect(result.isCompliant, false);
        expect(
          result.missingElements,
          contains('At least 1 mold growth evidence photo is required'),
        );
      });

      test('missing affected areas photo', () {
        final counts = fullPhotoCounts()..[MoldComplianceValidator.photoKeyAffectedAreas] = 0;
        final result = MoldComplianceValidator.validate(
          fullyCompliant(),
          hasInspectorLicense: true,
          photoCounts: counts,
        );

        expect(result.isCompliant, false);
        expect(
          result.missingElements,
          contains('At least 1 affected areas photo is required'),
        );
      });

      test('empty photoCounts map fails all photo checks', () {
        final result = MoldComplianceValidator.validate(
          fullyCompliant(),
          hasInspectorLicense: true,
          photoCounts: <String, int>{},
        );

        expect(result.isCompliant, false);
        expect(result.missingElements.length, greaterThanOrEqualTo(3));
      });
    });

    group('warnings', () {
      test('empty additionalFindings produces warning', () {
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
        'remediation not recommended + mold growth evidence produces warning',
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

      test('no warning when remediation recommended and growth documented', () {
        final result = MoldComplianceValidator.validate(
          fullyCompliant(),
          hasInspectorLicense: true,
          photoCounts: fullPhotoCounts(),
        );

        expect(
          result.warnings,
          isNot(contains(
            'Consider recommending remediation when mold growth is documented',
          )),
        );
      });
    });

    test('partial compliance: multiple failures accumulate', () {
      final result = MoldComplianceValidator.validate(
        MoldFormData.empty(),
        hasInspectorLicense: false,
        photoCounts: <String, int>{},
      );

      expect(result.isCompliant, false);
      // License + 4 text fields + 3 photos = 8 minimum
      expect(result.missingElements.length, greaterThanOrEqualTo(8));
    });
  });
}
