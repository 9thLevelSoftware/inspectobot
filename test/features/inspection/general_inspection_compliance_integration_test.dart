import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/condition_rating.dart';
import 'package:inspectobot/features/inspection/domain/general_inspection_compliance_validator.dart';
import 'package:inspectobot/features/inspection/domain/general_inspection_form_data.dart';
import 'package:inspectobot/features/inspection/domain/system_inspection_data.dart';
import 'package:inspectobot/features/pdf/narrative/templates/general_inspection_template.dart';

void main() {
  group('General Inspection Compliance Integration Tests', () {
    // =========================================================================
    // Helpers
    // =========================================================================

    GeneralInspectionFormData createFullyCompliantFormData() {
      return GeneralInspectionFormData(
        scopeAndPurpose: 'Full visual home inspection per Rule 61-30.801',
        generalComments: 'Property is in overall satisfactory condition',
        structural: SystemInspectionData.structural().copyWith(
          rating: ConditionRating.satisfactory,
          findings: 'Foundation and framing in good condition',
          subsystems: [
            const SubsystemData(
              id: 'foundation',
              name: 'Foundation',
              rating: ConditionRating.satisfactory,
              findings: 'Slab on grade, no issues',
            ),
            const SubsystemData(
              id: 'framing',
              name: 'Framing',
              rating: ConditionRating.satisfactory,
              findings: 'Wood frame intact',
            ),
            const SubsystemData(
              id: 'roof_structure',
              name: 'Roof Structure',
              rating: ConditionRating.satisfactory,
              findings: 'Trusses intact',
            ),
          ],
        ),
        exterior: SystemInspectionData.exterior().copyWith(
          rating: ConditionRating.satisfactory,
          findings: 'Exterior in good condition',
          subsystems: [
            const SubsystemData(
              id: 'siding',
              name: 'Siding',
              rating: ConditionRating.satisfactory,
              findings: 'Stucco intact',
            ),
            const SubsystemData(
              id: 'trim',
              name: 'Trim',
              rating: ConditionRating.satisfactory,
              findings: 'Good condition',
            ),
            const SubsystemData(
              id: 'porches',
              name: 'Porches',
              rating: ConditionRating.satisfactory,
              findings: 'Structurally sound',
            ),
            const SubsystemData(
              id: 'driveways',
              name: 'Driveways',
              rating: ConditionRating.satisfactory,
              findings: 'No cracks',
            ),
          ],
        ),
        roofing: SystemInspectionData.roofing().copyWith(
          rating: ConditionRating.satisfactory,
          findings: 'Roof in good condition',
          subsystems: [
            const SubsystemData(
              id: 'covering',
              name: 'Covering',
              rating: ConditionRating.satisfactory,
              findings: 'Shingles intact',
            ),
            const SubsystemData(
              id: 'flashing',
              name: 'Flashing',
              rating: ConditionRating.satisfactory,
              findings: 'Properly sealed',
            ),
            const SubsystemData(
              id: 'drainage',
              name: 'Drainage',
              rating: ConditionRating.satisfactory,
              findings: 'Gutters clear',
            ),
          ],
        ),
        plumbing: SystemInspectionData.plumbing().copyWith(
          rating: ConditionRating.satisfactory,
          findings: 'All fixtures functional',
          subsystems: [
            const SubsystemData(
              id: 'supply',
              name: 'Supply',
              rating: ConditionRating.satisfactory,
              findings: 'Good pressure',
            ),
            const SubsystemData(
              id: 'drain_waste',
              name: 'Drain/Waste',
              rating: ConditionRating.satisfactory,
              findings: 'No blockages',
            ),
            const SubsystemData(
              id: 'water_heater',
              name: 'Water Heater',
              rating: ConditionRating.satisfactory,
              findings: 'Functional',
            ),
          ],
        ),
        electrical: SystemInspectionData.electrical().copyWith(
          rating: ConditionRating.satisfactory,
          findings: '200A service adequate',
          subsystems: [
            const SubsystemData(
              id: 'service',
              name: 'Service',
              rating: ConditionRating.satisfactory,
              findings: '200A',
            ),
            const SubsystemData(
              id: 'panels',
              name: 'Panels',
              rating: ConditionRating.satisfactory,
              findings: 'Labeled',
            ),
            const SubsystemData(
              id: 'branch_circuits',
              name: 'Branch Circuits',
              rating: ConditionRating.satisfactory,
              findings: 'Tested OK',
            ),
            const SubsystemData(
              id: 'gfci',
              name: 'GFCI',
              rating: ConditionRating.satisfactory,
              findings: 'Present in wet areas',
            ),
          ],
        ),
        hvac: SystemInspectionData.hvac().copyWith(
          rating: ConditionRating.satisfactory,
          findings: 'HVAC operational',
          subsystems: [
            const SubsystemData(
              id: 'heating',
              name: 'Heating',
              rating: ConditionRating.satisfactory,
              findings: 'Heat pump OK',
            ),
            const SubsystemData(
              id: 'cooling',
              name: 'Cooling',
              rating: ConditionRating.satisfactory,
              findings: 'AC operational',
            ),
            const SubsystemData(
              id: 'distribution',
              name: 'Distribution',
              rating: ConditionRating.satisfactory,
              findings: 'Ductwork sealed',
            ),
          ],
        ),
        insulationVentilation:
            SystemInspectionData.insulationVentilation().copyWith(
          rating: ConditionRating.satisfactory,
          findings: 'Adequate insulation',
          subsystems: [
            const SubsystemData(
              id: 'attic',
              name: 'Attic',
              rating: ConditionRating.satisfactory,
              findings: 'R-30',
            ),
            const SubsystemData(
              id: 'wall',
              name: 'Wall',
              rating: ConditionRating.satisfactory,
              findings: 'Insulated',
            ),
            const SubsystemData(
              id: 'crawlspace',
              name: 'Crawlspace',
              rating: ConditionRating.satisfactory,
              findings: 'Ventilated',
            ),
          ],
        ),
        appliances: SystemInspectionData.appliances().copyWith(
          rating: ConditionRating.satisfactory,
          findings: 'All appliances operational',
        ),
        lifeSafety: SystemInspectionData.lifeSafety().copyWith(
          rating: ConditionRating.satisfactory,
          findings: 'Safety devices present',
          subsystems: [
            const SubsystemData(
              id: 'smoke_detectors',
              name: 'Smoke Detectors',
              rating: ConditionRating.satisfactory,
              findings: 'In all bedrooms',
            ),
            const SubsystemData(
              id: 'co_detectors',
              name: 'CO Detectors',
              rating: ConditionRating.satisfactory,
              findings: 'Near sleeping areas',
            ),
            const SubsystemData(
              id: 'fire_sprinklers',
              name: 'Fire Sprinklers',
              rating: ConditionRating.satisfactory,
              findings: 'Functional',
            ),
          ],
        ),
      );
    }

    Map<String, int> allSystemPhotos() => {
          GeneralInspectionComplianceValidator.photoKeyStructural: 2,
          GeneralInspectionComplianceValidator.photoKeyExterior: 2,
          GeneralInspectionComplianceValidator.photoKeyRoofing: 2,
          GeneralInspectionComplianceValidator.photoKeyPlumbing: 2,
          GeneralInspectionComplianceValidator.photoKeyElectrical: 2,
          GeneralInspectionComplianceValidator.photoKeyHvac: 2,
          GeneralInspectionComplianceValidator.photoKeyInsulationVentilation: 2,
          GeneralInspectionComplianceValidator.photoKeyAppliances: 2,
          GeneralInspectionComplianceValidator.photoKeyLifeSafety: 2,
        };

    // =========================================================================
    // 0. Photo key alignment with template
    // =========================================================================
    test('validator photo keys align with template requiredPhotoKeys', () {
      const template = GeneralInspectionTemplate();
      expect(
        GeneralInspectionComplianceValidator.allPhotoKeys,
        equals(template.requiredPhotoKeys),
      );
    });

    // =========================================================================
    // 1. Full compliance flow
    // =========================================================================
    test('fully compliant form passes validation', () {
      final result = GeneralInspectionComplianceValidator.validate(
        createFullyCompliantFormData(),
        hasInspectorLicense: true,
        photoCounts: allSystemPhotos(),
      );

      expect(result.isCompliant, true);
      expect(result.missingElements, isEmpty);
    });

    // =========================================================================
    // 2. Per-system validation — notInspected rating is non-compliant
    // =========================================================================
    group('per-system notInspected rating', () {
      final systemNames = {
        'structural': 'Structural Components',
        'exterior': 'Exterior',
        'roofing': 'Roofing',
        'plumbing': 'Plumbing',
        'electrical': 'Electrical',
        'hvac': 'HVAC',
        'insulation_ventilation': 'Insulation and Ventilation',
        'appliances': 'Built-in Appliances',
        'life_safety': 'Life Safety',
      };

      for (final entry in systemNames.entries) {
        test('${entry.key} with notInspected is non-compliant', () {
          final compliant = createFullyCompliantFormData();
          final notInspectedSystem = SystemInspectionData(
            systemId: entry.key,
            systemName: entry.value,
            rating: ConditionRating.notInspected,
            findings: '',
          );
          final modified = compliant.updateSystem(entry.key, notInspectedSystem);

          final result = GeneralInspectionComplianceValidator.validate(
            modified,
            hasInspectorLicense: true,
            photoCounts: allSystemPhotos(),
          );

          expect(result.isCompliant, false);
          expect(
            result.missingElements,
            contains('${entry.value} rating is required'),
          );
        });
      }
    });

    // =========================================================================
    // 3. Findings requirements
    // =========================================================================
    group('findings requirements', () {
      test('deficient rating with empty findings is non-compliant', () {
        final compliant = createFullyCompliantFormData();
        final deficientNoFindings =
            SystemInspectionData.structural().copyWith(
          rating: ConditionRating.deficient,
          findings: '',
        );
        final modified =
            compliant.updateSystem('structural', deficientNoFindings);

        final result = GeneralInspectionComplianceValidator.validate(
          modified,
          hasInspectorLicense: true,
          photoCounts: allSystemPhotos(),
        );

        expect(result.isCompliant, false);
        expect(
          result.missingElements,
          contains(
            'Structural Components findings required for Deficient rating',
          ),
        );
      });

      test('marginal rating with empty findings is non-compliant', () {
        final compliant = createFullyCompliantFormData();
        final marginalNoFindings = SystemInspectionData.exterior().copyWith(
          rating: ConditionRating.marginal,
          findings: '',
        );
        final modified =
            compliant.updateSystem('exterior', marginalNoFindings);

        final result = GeneralInspectionComplianceValidator.validate(
          modified,
          hasInspectorLicense: true,
          photoCounts: allSystemPhotos(),
        );

        expect(result.isCompliant, false);
        expect(
          result.missingElements,
          contains('Exterior findings required for Marginal rating'),
        );
      });

      test('satisfactory rating with empty findings is compliant', () {
        final compliant = createFullyCompliantFormData();
        final satisfactoryNoFindings =
            SystemInspectionData.roofing().copyWith(
          rating: ConditionRating.satisfactory,
          findings: '',
        );
        final modified =
            compliant.updateSystem('roofing', satisfactoryNoFindings);

        final result = GeneralInspectionComplianceValidator.validate(
          modified,
          hasInspectorLicense: true,
          photoCounts: allSystemPhotos(),
        );

        expect(result.isCompliant, true);
      });
    });

    // =========================================================================
    // 4. Photo evidence per system
    // =========================================================================
    group('photo evidence per system', () {
      final photoKeys = {
        'structural_photos': 'Structural Components',
        'exterior_photos': 'Exterior',
        'roofing_photos': 'Roofing',
        'plumbing_photos': 'Plumbing',
        'electrical_photos': 'Electrical',
        'hvac_photos': 'HVAC',
        'insulation_ventilation_photos': 'Insulation and Ventilation',
        'appliances_photos': 'Built-in Appliances',
        'life_safety_photos': 'Life Safety',
      };

      for (final entry in photoKeys.entries) {
        test('removing ${entry.key} photo is non-compliant', () {
          final photos = allSystemPhotos();
          photos[entry.key] = 0; // Remove photos for this system

          final result = GeneralInspectionComplianceValidator.validate(
            createFullyCompliantFormData(),
            hasInspectorLicense: true,
            photoCounts: photos,
          );

          expect(result.isCompliant, false);
          expect(
            result.missingElements,
            contains('At least 1 ${entry.value} photo is required'),
          );
        });
      }
    });

    // =========================================================================
    // 5. Branch flag conditionals
    // =========================================================================
    group('branch flag conditionals', () {
      test('safetyHazard flag with < 2 life safety photos is non-compliant',
          () {
        final formData = createFullyCompliantFormData().copyWith(
          safetyHazard: true,
        );
        final photos = allSystemPhotos();
        photos[GeneralInspectionComplianceValidator.photoKeyLifeSafety] = 1;

        final result = GeneralInspectionComplianceValidator.validate(
          formData,
          hasInspectorLicense: true,
          photoCounts: photos,
        );

        expect(result.isCompliant, false);
        expect(
          result.missingElements,
          contains(
            'Safety hazard flagged — at least 2 life safety photos required',
          ),
        );
      });

      test('safetyHazard flag with >= 2 life safety photos is compliant', () {
        final formData = createFullyCompliantFormData().copyWith(
          safetyHazard: true,
        );
        final photos = allSystemPhotos();
        photos[GeneralInspectionComplianceValidator.photoKeyLifeSafety] = 2;

        final result = GeneralInspectionComplianceValidator.validate(
          formData,
          hasInspectorLicense: true,
          photoCounts: photos,
        );

        expect(result.isCompliant, true);
      });

      test('moistureMoldEvidence without plumbing/roofing findings -> warning',
          () {
        final formData = createFullyCompliantFormData().copyWith(
          moistureMoldEvidence: true,
          plumbing: SystemInspectionData.plumbing().copyWith(
            rating: ConditionRating.satisfactory,
            findings: '',
          ),
          roofing: SystemInspectionData.roofing().copyWith(
            rating: ConditionRating.satisfactory,
            findings: '',
          ),
        );

        final result = GeneralInspectionComplianceValidator.validate(
          formData,
          hasInspectorLicense: true,
          photoCounts: allSystemPhotos(),
        );

        // Warning, not a blocker
        expect(result.isCompliant, true);
        expect(
          result.warnings,
          contains(
            'Moisture/mold evidence flagged but no plumbing or roofing findings documented',
          ),
        );
      });

      test('pestEvidence without exterior findings -> warning', () {
        final formData = createFullyCompliantFormData().copyWith(
          pestEvidence: true,
          exterior: SystemInspectionData.exterior().copyWith(
            rating: ConditionRating.satisfactory,
            findings: '',
          ),
        );

        final result = GeneralInspectionComplianceValidator.validate(
          formData,
          hasInspectorLicense: true,
          photoCounts: allSystemPhotos(),
        );

        expect(result.isCompliant, true);
        expect(
          result.warnings,
          contains(
            'Pest evidence flagged but no exterior findings documented',
          ),
        );
      });

      test('structuralConcern without structural findings -> warning', () {
        final formData = createFullyCompliantFormData().copyWith(
          structuralConcern: true,
          structural: SystemInspectionData.structural().copyWith(
            rating: ConditionRating.satisfactory,
            findings: '',
          ),
        );

        final result = GeneralInspectionComplianceValidator.validate(
          formData,
          hasInspectorLicense: true,
          photoCounts: allSystemPhotos(),
        );

        expect(result.isCompliant, true);
        expect(
          result.warnings,
          contains(
            'Structural concern flagged but no structural findings documented',
          ),
        );
      });
    });

    // =========================================================================
    // 6. Warnings (non-blocking)
    // =========================================================================
    group('warnings', () {
      test('empty general comments produces warning (not blocker)', () {
        final formData = createFullyCompliantFormData().copyWith(
          generalComments: '',
        );

        final result = GeneralInspectionComplianceValidator.validate(
          formData,
          hasInspectorLicense: true,
          photoCounts: allSystemPhotos(),
        );

        expect(result.isCompliant, true);
        expect(
          result.warnings,
          contains('General comments section is empty (recommended)'),
        );
      });

      test(
          'subsystem deficient with empty findings produces warning (not blocker)',
          () {
        final formData = createFullyCompliantFormData().copyWith(
          structural: SystemInspectionData.structural().copyWith(
            rating: ConditionRating.satisfactory,
            findings: 'Overall OK',
            subsystems: [
              const SubsystemData(
                id: 'foundation',
                name: 'Foundation',
                rating: ConditionRating.deficient,
                findings: '', // Deficient with no findings -> warning
              ),
              const SubsystemData(
                id: 'framing',
                name: 'Framing',
                rating: ConditionRating.satisfactory,
                findings: 'OK',
              ),
              const SubsystemData(
                id: 'roof_structure',
                name: 'Roof Structure',
                rating: ConditionRating.satisfactory,
                findings: 'OK',
              ),
            ],
          ),
        );

        final result = GeneralInspectionComplianceValidator.validate(
          formData,
          hasInspectorLicense: true,
          photoCounts: allSystemPhotos(),
        );

        // Should still be compliant (subsystem issues are warnings)
        expect(result.isCompliant, true);
        expect(
          result.warnings,
          contains(
            'Foundation subsystem has Deficient rating without findings (recommended)',
          ),
        );
      });

      test(
          'subsystem marginal with empty findings produces warning',
          () {
        final formData = createFullyCompliantFormData().copyWith(
          electrical: SystemInspectionData.electrical().copyWith(
            rating: ConditionRating.satisfactory,
            findings: 'Overall OK',
            subsystems: [
              const SubsystemData(
                id: 'service',
                name: 'Service',
                rating: ConditionRating.satisfactory,
                findings: 'OK',
              ),
              const SubsystemData(
                id: 'panels',
                name: 'Panels',
                rating: ConditionRating.marginal,
                findings: '', // Marginal with no findings -> warning
              ),
              const SubsystemData(
                id: 'branch_circuits',
                name: 'Branch Circuits',
                rating: ConditionRating.satisfactory,
                findings: 'OK',
              ),
              const SubsystemData(
                id: 'gfci',
                name: 'GFCI',
                rating: ConditionRating.satisfactory,
                findings: 'OK',
              ),
            ],
          ),
        );

        final result = GeneralInspectionComplianceValidator.validate(
          formData,
          hasInspectorLicense: true,
          photoCounts: allSystemPhotos(),
        );

        expect(result.isCompliant, true);
        expect(
          result.warnings,
          contains(
            'Panels subsystem has Marginal rating without findings (recommended)',
          ),
        );
      });
    });

    // =========================================================================
    // 7. Inspector license
    // =========================================================================
    group('inspector license', () {
      test('missing license is non-compliant', () {
        final result = GeneralInspectionComplianceValidator.validate(
          createFullyCompliantFormData(),
          hasInspectorLicense: false,
          photoCounts: allSystemPhotos(),
        );

        expect(result.isCompliant, false);
        expect(
          result.missingElements,
          contains('Inspector license is required'),
        );
      });

      test('present license with everything else valid is compliant', () {
        final result = GeneralInspectionComplianceValidator.validate(
          createFullyCompliantFormData(),
          hasInspectorLicense: true,
          photoCounts: allSystemPhotos(),
        );

        expect(result.isCompliant, true);
        expect(result.missingElements, isEmpty);
      });
    });

    // =========================================================================
    // 8. Scope and purpose required
    // =========================================================================
    test('empty scope and purpose is non-compliant', () {
      final formData = createFullyCompliantFormData().copyWith(
        scopeAndPurpose: '',
      );

      final result = GeneralInspectionComplianceValidator.validate(
        formData,
        hasInspectorLicense: true,
        photoCounts: allSystemPhotos(),
      );

      expect(result.isCompliant, false);
      expect(
        result.missingElements,
        contains('Scope and purpose is required'),
      );
    });
  });
}
