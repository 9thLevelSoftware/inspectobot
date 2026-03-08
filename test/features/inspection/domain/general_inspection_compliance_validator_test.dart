import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/condition_rating.dart';
import 'package:inspectobot/features/inspection/domain/general_inspection_compliance_validator.dart';
import 'package:inspectobot/features/inspection/domain/general_inspection_form_data.dart';
import 'package:inspectobot/features/inspection/domain/system_inspection_data.dart';
import 'package:inspectobot/features/pdf/narrative/templates/general_inspection_template.dart';

void main() {
  group('GeneralInspectionComplianceValidator', () {
    /// Returns a fully compliant form data instance.
    GeneralInspectionFormData fullyCompliant() {
      return GeneralInspectionFormData(
        scopeAndPurpose: 'Visual inspection per Rule 61-30.801',
        generalComments: 'Property in good overall condition',
        structural: SystemInspectionData.structural().copyWith(
          rating: ConditionRating.satisfactory,
          findings: 'No structural issues',
        ),
        exterior: SystemInspectionData.exterior().copyWith(
          rating: ConditionRating.satisfactory,
          findings: 'Exterior in good condition',
        ),
        roofing: SystemInspectionData.roofing().copyWith(
          rating: ConditionRating.satisfactory,
          findings: 'Roof in good condition',
        ),
        plumbing: SystemInspectionData.plumbing().copyWith(
          rating: ConditionRating.satisfactory,
          findings: 'All plumbing functional',
        ),
        electrical: SystemInspectionData.electrical().copyWith(
          rating: ConditionRating.satisfactory,
          findings: 'Electrical system adequate',
        ),
        hvac: SystemInspectionData.hvac().copyWith(
          rating: ConditionRating.satisfactory,
          findings: 'HVAC operational',
        ),
        insulationVentilation:
            SystemInspectionData.insulationVentilation().copyWith(
          rating: ConditionRating.satisfactory,
          findings: 'Adequate insulation',
        ),
        appliances: SystemInspectionData.appliances().copyWith(
          rating: ConditionRating.satisfactory,
          findings: 'All appliances working',
        ),
        lifeSafety: SystemInspectionData.lifeSafety().copyWith(
          rating: ConditionRating.satisfactory,
          findings: 'All detectors present',
        ),
      );
    }

    /// Returns photo counts with at least 1 per system.
    Map<String, int> fullPhotoCounts() => {
          GeneralInspectionComplianceValidator.photoKeyStructural: 2,
          GeneralInspectionComplianceValidator.photoKeyExterior: 3,
          GeneralInspectionComplianceValidator.photoKeyRoofing: 2,
          GeneralInspectionComplianceValidator.photoKeyPlumbing: 2,
          GeneralInspectionComplianceValidator.photoKeyElectrical: 2,
          GeneralInspectionComplianceValidator.photoKeyHvac: 1,
          GeneralInspectionComplianceValidator.photoKeyInsulationVentilation: 1,
          GeneralInspectionComplianceValidator.photoKeyAppliances: 1,
          GeneralInspectionComplianceValidator.photoKeyLifeSafety: 2,
        };

    test('fully compliant form returns isCompliant: true', () {
      final result = GeneralInspectionComplianceValidator.validate(
        fullyCompliant(),
        hasInspectorLicense: true,
        photoCounts: fullPhotoCounts(),
      );

      expect(result.isCompliant, true);
      expect(result.missingElements, isEmpty);
    });

    test('missing inspector license -> non-compliant', () {
      final result = GeneralInspectionComplianceValidator.validate(
        fullyCompliant(),
        hasInspectorLicense: false,
        photoCounts: fullPhotoCounts(),
      );

      expect(result.isCompliant, false);
      expect(
        result.missingElements,
        contains('Inspector license is required'),
      );
    });

    test('empty scope -> non-compliant', () {
      final result = GeneralInspectionComplianceValidator.validate(
        fullyCompliant().copyWith(scopeAndPurpose: ''),
        hasInspectorLicense: true,
        photoCounts: fullPhotoCounts(),
      );

      expect(result.isCompliant, false);
      expect(
        result.missingElements,
        contains('Scope and purpose is required'),
      );
    });

    test('whitespace-only scope -> non-compliant', () {
      final result = GeneralInspectionComplianceValidator.validate(
        fullyCompliant().copyWith(scopeAndPurpose: '   '),
        hasInspectorLicense: true,
        photoCounts: fullPhotoCounts(),
      );

      expect(result.isCompliant, false);
    });

    group('system ratings', () {
      test('structural with notInspected -> non-compliant', () {
        final result = GeneralInspectionComplianceValidator.validate(
          fullyCompliant().copyWith(
            structural: SystemInspectionData.structural().copyWith(
              rating: ConditionRating.notInspected,
            ),
          ),
          hasInspectorLicense: true,
          photoCounts: fullPhotoCounts(),
        );

        expect(result.isCompliant, false);
        expect(
          result.missingElements,
          contains('Structural Components rating is required'),
        );
      });

      test('exterior with notInspected -> non-compliant', () {
        final result = GeneralInspectionComplianceValidator.validate(
          fullyCompliant().copyWith(
            exterior: SystemInspectionData.exterior().copyWith(
              rating: ConditionRating.notInspected,
            ),
          ),
          hasInspectorLicense: true,
          photoCounts: fullPhotoCounts(),
        );

        expect(result.isCompliant, false);
        expect(
          result.missingElements,
          contains('Exterior rating is required'),
        );
      });

      test('roofing with notInspected -> non-compliant', () {
        final result = GeneralInspectionComplianceValidator.validate(
          fullyCompliant().copyWith(
            roofing: SystemInspectionData.roofing().copyWith(
              rating: ConditionRating.notInspected,
            ),
          ),
          hasInspectorLicense: true,
          photoCounts: fullPhotoCounts(),
        );

        expect(result.isCompliant, false);
        expect(
          result.missingElements,
          contains('Roofing rating is required'),
        );
      });

      test('plumbing with notInspected -> non-compliant', () {
        final result = GeneralInspectionComplianceValidator.validate(
          fullyCompliant().copyWith(
            plumbing: SystemInspectionData.plumbing().copyWith(
              rating: ConditionRating.notInspected,
            ),
          ),
          hasInspectorLicense: true,
          photoCounts: fullPhotoCounts(),
        );

        expect(result.isCompliant, false);
        expect(
          result.missingElements,
          contains('Plumbing rating is required'),
        );
      });

      test('electrical with notInspected -> non-compliant', () {
        final result = GeneralInspectionComplianceValidator.validate(
          fullyCompliant().copyWith(
            electrical: SystemInspectionData.electrical().copyWith(
              rating: ConditionRating.notInspected,
            ),
          ),
          hasInspectorLicense: true,
          photoCounts: fullPhotoCounts(),
        );

        expect(result.isCompliant, false);
        expect(
          result.missingElements,
          contains('Electrical rating is required'),
        );
      });

      test('hvac with notInspected -> non-compliant', () {
        final result = GeneralInspectionComplianceValidator.validate(
          fullyCompliant().copyWith(
            hvac: SystemInspectionData.hvac().copyWith(
              rating: ConditionRating.notInspected,
            ),
          ),
          hasInspectorLicense: true,
          photoCounts: fullPhotoCounts(),
        );

        expect(result.isCompliant, false);
        expect(
          result.missingElements,
          contains('HVAC rating is required'),
        );
      });

      test('insulation_ventilation with notInspected -> non-compliant', () {
        final result = GeneralInspectionComplianceValidator.validate(
          fullyCompliant().copyWith(
            insulationVentilation:
                SystemInspectionData.insulationVentilation().copyWith(
              rating: ConditionRating.notInspected,
            ),
          ),
          hasInspectorLicense: true,
          photoCounts: fullPhotoCounts(),
        );

        expect(result.isCompliant, false);
        expect(
          result.missingElements,
          contains('Insulation and Ventilation rating is required'),
        );
      });

      test('appliances with notInspected -> non-compliant', () {
        final result = GeneralInspectionComplianceValidator.validate(
          fullyCompliant().copyWith(
            appliances: SystemInspectionData.appliances().copyWith(
              rating: ConditionRating.notInspected,
            ),
          ),
          hasInspectorLicense: true,
          photoCounts: fullPhotoCounts(),
        );

        expect(result.isCompliant, false);
        expect(
          result.missingElements,
          contains('Built-in Appliances rating is required'),
        );
      });

      test('life_safety with notInspected -> non-compliant', () {
        final result = GeneralInspectionComplianceValidator.validate(
          fullyCompliant().copyWith(
            lifeSafety: SystemInspectionData.lifeSafety().copyWith(
              rating: ConditionRating.notInspected,
            ),
          ),
          hasInspectorLicense: true,
          photoCounts: fullPhotoCounts(),
        );

        expect(result.isCompliant, false);
        expect(
          result.missingElements,
          contains('Life Safety rating is required'),
        );
      });
    });

    group('findings requirements', () {
      test('deficient rating with empty findings -> non-compliant', () {
        final result = GeneralInspectionComplianceValidator.validate(
          fullyCompliant().copyWith(
            electrical: SystemInspectionData.electrical().copyWith(
              rating: ConditionRating.deficient,
              findings: '',
            ),
          ),
          hasInspectorLicense: true,
          photoCounts: fullPhotoCounts(),
        );

        expect(result.isCompliant, false);
        expect(
          result.missingElements,
          contains('Electrical findings required for Deficient rating'),
        );
      });

      test('marginal rating with empty findings -> non-compliant', () {
        final result = GeneralInspectionComplianceValidator.validate(
          fullyCompliant().copyWith(
            roofing: SystemInspectionData.roofing().copyWith(
              rating: ConditionRating.marginal,
              findings: '',
            ),
          ),
          hasInspectorLicense: true,
          photoCounts: fullPhotoCounts(),
        );

        expect(result.isCompliant, false);
        expect(
          result.missingElements,
          contains('Roofing findings required for Marginal rating'),
        );
      });

      test('satisfactory with empty findings -> still compliant', () {
        final result = GeneralInspectionComplianceValidator.validate(
          fullyCompliant().copyWith(
            hvac: SystemInspectionData.hvac().copyWith(
              rating: ConditionRating.satisfactory,
              findings: '',
            ),
          ),
          hasInspectorLicense: true,
          photoCounts: fullPhotoCounts(),
        );

        expect(result.isCompliant, true);
      });
    });

    group('missing photos', () {
      test('missing structural photo -> non-compliant', () {
        final counts = fullPhotoCounts()
          ..[GeneralInspectionComplianceValidator.photoKeyStructural] = 0;
        final result = GeneralInspectionComplianceValidator.validate(
          fullyCompliant(),
          hasInspectorLicense: true,
          photoCounts: counts,
        );

        expect(result.isCompliant, false);
        expect(
          result.missingElements,
          contains('At least 1 Structural Components photo is required'),
        );
      });

      test('missing exterior photo -> non-compliant', () {
        final counts = fullPhotoCounts()
          ..[GeneralInspectionComplianceValidator.photoKeyExterior] = 0;
        final result = GeneralInspectionComplianceValidator.validate(
          fullyCompliant(),
          hasInspectorLicense: true,
          photoCounts: counts,
        );

        expect(result.isCompliant, false);
        expect(
          result.missingElements,
          contains('At least 1 Exterior photo is required'),
        );
      });

      test('missing roofing photo -> non-compliant', () {
        final counts = fullPhotoCounts()
          ..[GeneralInspectionComplianceValidator.photoKeyRoofing] = 0;
        final result = GeneralInspectionComplianceValidator.validate(
          fullyCompliant(),
          hasInspectorLicense: true,
          photoCounts: counts,
        );

        expect(result.isCompliant, false);
        expect(
          result.missingElements,
          contains('At least 1 Roofing photo is required'),
        );
      });

      test('empty photoCounts map fails all photo checks', () {
        final result = GeneralInspectionComplianceValidator.validate(
          fullyCompliant(),
          hasInspectorLicense: true,
          photoCounts: <String, int>{},
        );

        expect(result.isCompliant, false);
        expect(result.missingElements.length, greaterThanOrEqualTo(9));
      });
    });

    group('branch flag conditionals', () {
      test(
        'safety hazard flag with missing deficiency photo -> non-compliant',
        () {
          final counts = fullPhotoCounts()
            ..[GeneralInspectionComplianceValidator.photoKeyLifeSafety] = 1;
          final result = GeneralInspectionComplianceValidator.validate(
            fullyCompliant().copyWith(safetyHazard: true),
            hasInspectorLicense: true,
            photoCounts: counts,
          );

          expect(result.isCompliant, false);
          expect(
            result.missingElements,
            contains(
              'Safety hazard flagged — at least 2 life safety photos required',
            ),
          );
        },
      );

      test('safety hazard flag with sufficient photos -> compliant', () {
        final result = GeneralInspectionComplianceValidator.validate(
          fullyCompliant().copyWith(safetyHazard: true),
          hasInspectorLicense: true,
          photoCounts: fullPhotoCounts(),
        );

        expect(result.isCompliant, true);
      });
    });

    group('subsystem warnings', () {
      test('subsystem deficient with empty findings -> warning', () {
        final result = GeneralInspectionComplianceValidator.validate(
          fullyCompliant().copyWith(
            structural: SystemInspectionData.structural().copyWith(
              rating: ConditionRating.satisfactory,
              findings: 'Overall satisfactory',
              subsystems: [
                const SubsystemData(
                  id: 'foundation',
                  name: 'Foundation',
                  rating: ConditionRating.deficient,
                  findings: '', // empty findings for deficient
                ),
                const SubsystemData(id: 'framing', name: 'Framing'),
                const SubsystemData(
                    id: 'roof_structure', name: 'Roof Structure'),
              ],
            ),
          ),
          hasInspectorLicense: true,
          photoCounts: fullPhotoCounts(),
        );

        // Subsystem deficiency is a warning, not a blocker
        expect(result.isCompliant, true);
        expect(
          result.warnings,
          contains(
            'Foundation subsystem has Deficient rating '
            'without findings (recommended)',
          ),
        );
      });

      test('subsystem marginal with empty findings -> warning', () {
        final result = GeneralInspectionComplianceValidator.validate(
          fullyCompliant().copyWith(
            electrical: SystemInspectionData.electrical().copyWith(
              rating: ConditionRating.satisfactory,
              findings: 'System adequate',
              subsystems: [
                const SubsystemData(id: 'service', name: 'Service'),
                const SubsystemData(
                  id: 'panels',
                  name: 'Panels',
                  rating: ConditionRating.marginal,
                  findings: '',
                ),
                const SubsystemData(
                    id: 'branch_circuits', name: 'Branch Circuits'),
                const SubsystemData(id: 'gfci', name: 'GFCI'),
              ],
            ),
          ),
          hasInspectorLicense: true,
          photoCounts: fullPhotoCounts(),
        );

        expect(result.isCompliant, true);
        expect(
          result.warnings,
          contains(
            'Panels subsystem has Marginal rating '
            'without findings (recommended)',
          ),
        );
      });
    });

    group('general comments warning', () {
      test('empty general comments -> warning', () {
        final result = GeneralInspectionComplianceValidator.validate(
          fullyCompliant().copyWith(generalComments: ''),
          hasInspectorLicense: true,
          photoCounts: fullPhotoCounts(),
        );

        expect(result.isCompliant, true);
        expect(
          result.warnings,
          contains('General comments section is empty (recommended)'),
        );
      });
    });

    group('photo key alignment', () {
      test('photo key constants match GeneralInspectionTemplate requiredPhotoKeys', () {
        final templateKeys =
            const GeneralInspectionTemplate().requiredPhotoKeys;
        expect(
          GeneralInspectionComplianceValidator.allPhotoKeys,
          equals(templateKeys),
        );
      });
    });

    test('partial compliance: multiple failures accumulate', () {
      final result = GeneralInspectionComplianceValidator.validate(
        GeneralInspectionFormData.empty(),
        hasInspectorLicense: false,
        photoCounts: <String, int>{},
      );

      expect(result.isCompliant, false);
      // License + scope + 9 system ratings + 9 photos = 20 minimum
      expect(result.missingElements.length, greaterThanOrEqualTo(20));
    });
  });
}
