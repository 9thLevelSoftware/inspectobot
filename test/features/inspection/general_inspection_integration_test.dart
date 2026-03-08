import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/condition_rating.dart';
import 'package:inspectobot/features/inspection/domain/general_inspection_form_data.dart';
import 'package:inspectobot/features/inspection/domain/system_inspection_data.dart';
import 'package:inspectobot/features/pdf/narrative/templates/general_inspection_template.dart';

void main() {
  group('General Inspection Integration Tests', () {
    // =========================================================================
    // 1. Key alignment — toFormDataMap vs GeneralInspectionTemplate
    // =========================================================================
    group('key alignment', () {
      test('toFormDataMap produces exactly all template form data keys', () {
        final formData = GeneralInspectionFormData.empty();
        final producedKeys = formData.toFormDataMap().keys.toSet();
        final templateKeys =
            const GeneralInspectionTemplate().referencedFormDataKeys;
        expect(producedKeys, equals(templateKeys));
      });

      test('toFormDataMap keys contain no extra keys', () {
        final producedKeys =
            GeneralInspectionFormData.empty().toFormDataMap().keys.toSet();
        final templateKeys =
            const GeneralInspectionTemplate().referencedFormDataKeys;
        final extraKeys = producedKeys.difference(templateKeys);
        expect(extraKeys, isEmpty, reason: 'Extra keys: $extraKeys');
      });

      test('template keys contain no keys missing from toFormDataMap', () {
        final producedKeys =
            GeneralInspectionFormData.empty().toFormDataMap().keys.toSet();
        final templateKeys =
            const GeneralInspectionTemplate().referencedFormDataKeys;
        final missingKeys = templateKeys.difference(producedKeys);
        expect(missingKeys, isEmpty, reason: 'Missing keys: $missingKeys');
      });

      test('toFormDataMap produces exactly 72 keys', () {
        final map = GeneralInspectionFormData.empty().toFormDataMap();
        // 2 narrative + 18 system-level (9 x 2) + 52 subsystem (26 x 2) = 72
        expect(map.length, 72);
      });

      test('template referencedFormDataKeys contains exactly 72 keys', () {
        const template = GeneralInspectionTemplate();
        expect(template.referencedFormDataKeys.length, 72);
      });
    });

    // =========================================================================
    // 2. Serialization round-trip
    // =========================================================================
    group('serialization round-trip', () {
      GeneralInspectionFormData populatedFormData() {
        return GeneralInspectionFormData(
          scopeAndPurpose: 'Full visual home inspection per Rule 61-30.801',
          generalComments: 'Property is in overall good condition',
          structural: SystemInspectionData.structural().copyWith(
            rating: ConditionRating.satisfactory,
            findings: 'Foundation intact, no cracks observed',
            subsystems: [
              const SubsystemData(
                id: 'foundation',
                name: 'Foundation',
                rating: ConditionRating.satisfactory,
                findings: 'Slab on grade, no settlement',
              ),
              const SubsystemData(
                id: 'framing',
                name: 'Framing',
                rating: ConditionRating.marginal,
                findings: 'Minor wood rot at east wall',
              ),
              const SubsystemData(
                id: 'roof_structure',
                name: 'Roof Structure',
                rating: ConditionRating.satisfactory,
                findings: 'Trusses in good condition',
              ),
            ],
          ),
          exterior: SystemInspectionData.exterior().copyWith(
            rating: ConditionRating.marginal,
            findings: 'Paint peeling on south wall',
            subsystems: [
              const SubsystemData(
                id: 'siding',
                name: 'Siding',
                rating: ConditionRating.marginal,
                findings: 'Stucco cracking at corners',
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
                rating: ConditionRating.deficient,
                findings: 'Large settlement crack in driveway',
              ),
            ],
          ),
          roofing: SystemInspectionData.roofing().copyWith(
            rating: ConditionRating.satisfactory,
            findings: 'Shingle roof, 5 years old',
            subsystems: [
              const SubsystemData(
                id: 'covering',
                name: 'Covering',
                rating: ConditionRating.satisfactory,
                findings: 'Asphalt shingles intact',
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
                rating: ConditionRating.marginal,
                findings: 'Gutter debris accumulation',
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
                findings: 'Copper piping, good pressure',
              ),
              const SubsystemData(
                id: 'drain_waste',
                name: 'Drain/Waste',
                rating: ConditionRating.satisfactory,
                findings: 'No blockages detected',
              ),
              const SubsystemData(
                id: 'water_heater',
                name: 'Water Heater',
                rating: ConditionRating.marginal,
                findings: 'Tank water heater, nearing end of life',
              ),
            ],
          ),
          electrical: SystemInspectionData.electrical().copyWith(
            rating: ConditionRating.satisfactory,
            findings: '200A service, adequate',
            subsystems: [
              const SubsystemData(
                id: 'service',
                name: 'Service',
                rating: ConditionRating.satisfactory,
                findings: '200A overhead service',
              ),
              const SubsystemData(
                id: 'panels',
                name: 'Panels',
                rating: ConditionRating.satisfactory,
                findings: 'Properly labeled breaker panel',
              ),
              const SubsystemData(
                id: 'branch_circuits',
                name: 'Branch Circuits',
                rating: ConditionRating.satisfactory,
                findings: 'All circuits tested OK',
              ),
              const SubsystemData(
                id: 'gfci',
                name: 'GFCI',
                rating: ConditionRating.satisfactory,
                findings: 'GFCI outlets in wet areas',
              ),
            ],
          ),
          hvac: SystemInspectionData.hvac().copyWith(
            rating: ConditionRating.deficient,
            findings: 'AC compressor making noise',
            subsystems: [
              const SubsystemData(
                id: 'heating',
                name: 'Heating',
                rating: ConditionRating.satisfactory,
                findings: 'Heat pump functional',
              ),
              const SubsystemData(
                id: 'cooling',
                name: 'Cooling',
                rating: ConditionRating.deficient,
                findings: 'Compressor vibration excessive',
              ),
              const SubsystemData(
                id: 'distribution',
                name: 'Distribution',
                rating: ConditionRating.satisfactory,
                findings: 'Ductwork insulated and sealed',
              ),
            ],
          ),
          insulationVentilation:
              SystemInspectionData.insulationVentilation().copyWith(
            rating: ConditionRating.satisfactory,
            findings: 'R-30 attic insulation',
            subsystems: [
              const SubsystemData(
                id: 'attic',
                name: 'Attic',
                rating: ConditionRating.satisfactory,
                findings: 'Blown-in fiberglass R-30',
              ),
              const SubsystemData(
                id: 'wall',
                name: 'Wall',
                rating: ConditionRating.satisfactory,
                findings: 'Wall cavities insulated',
              ),
              const SubsystemData(
                id: 'crawlspace',
                name: 'Crawlspace',
                rating: ConditionRating.notInspected,
                findings: '',
              ),
            ],
          ),
          appliances: SystemInspectionData.appliances().copyWith(
            rating: ConditionRating.satisfactory,
            findings: 'All built-in appliances operational',
          ),
          lifeSafety: SystemInspectionData.lifeSafety().copyWith(
            rating: ConditionRating.satisfactory,
            findings: 'Smoke and CO detectors present',
            subsystems: [
              const SubsystemData(
                id: 'smoke_detectors',
                name: 'Smoke Detectors',
                rating: ConditionRating.satisfactory,
                findings: 'Present in all bedrooms',
              ),
              const SubsystemData(
                id: 'co_detectors',
                name: 'CO Detectors',
                rating: ConditionRating.satisfactory,
                findings: 'Present near sleeping areas',
              ),
              const SubsystemData(
                id: 'fire_sprinklers',
                name: 'Fire Sprinklers',
                rating: ConditionRating.notInspected,
                findings: 'Not present in this property',
              ),
            ],
          ),
          safetyHazard: true,
          moistureMoldEvidence: false,
          pestEvidence: true,
          structuralConcern: false,
        );
      }

      test('toJson -> fromJson preserves all data', () {
        final original = populatedFormData();
        final json = original.toJson();
        final restored = GeneralInspectionFormData.fromJson(json);
        expect(restored, equals(original));
      });

      test('toJson -> fromJson -> toJson produces identical JSON', () {
        final original = populatedFormData();
        final json1 = original.toJson();
        final restored = GeneralInspectionFormData.fromJson(json1);
        final json2 = restored.toJson();
        expect(jsonEncode(json2), jsonEncode(json1));
      });

      test('toJson uses camelCase keys', () {
        final json = populatedFormData().toJson();
        expect(json.containsKey('scopeAndPurpose'), true);
        expect(json.containsKey('generalComments'), true);
        expect(json.containsKey('insulationVentilation'), true);
        expect(json.containsKey('lifeSafety'), true);
        expect(json.containsKey('safetyHazard'), true);
        expect(json.containsKey('moistureMoldEvidence'), true);
        expect(json.containsKey('pestEvidence'), true);
        expect(json.containsKey('structuralConcern'), true);
        // Ensure no snake_case keys at top level
        expect(json.containsKey('scope_and_purpose'), false);
        expect(json.containsKey('general_comments'), false);
        expect(json.containsKey('insulation_ventilation'), false);
      });

      test('toFormDataMap uses snake_case keys', () {
        final map = populatedFormData().toFormDataMap();
        expect(map.containsKey('scope_and_purpose'), true);
        expect(map.containsKey('general_comments'), true);
        expect(map.containsKey('structural_rating'), true);
        expect(map.containsKey('insulation_ventilation_rating'), true);
        expect(map.containsKey('life_safety_rating'), true);
        // Ensure no camelCase keys
        expect(map.containsKey('scopeAndPurpose'), false);
        expect(map.containsKey('generalComments'), false);
        expect(map.containsKey('insulationVentilation'), false);
      });
    });

    // =========================================================================
    // 3. SystemInspectionData round-trip with subsystems
    // =========================================================================
    group('SystemInspectionData round-trip through GeneralInspectionFormData',
        () {
      test('subsystem ratings survive round-trip', () {
        final original = GeneralInspectionFormData(
          structural: SystemInspectionData.structural().copyWith(
            rating: ConditionRating.satisfactory,
            findings: 'Test structural',
            subsystems: [
              const SubsystemData(
                id: 'foundation',
                name: 'Foundation',
                rating: ConditionRating.deficient,
                findings: 'Cracked foundation',
              ),
              const SubsystemData(
                id: 'framing',
                name: 'Framing',
                rating: ConditionRating.marginal,
                findings: 'Minor issues',
              ),
              const SubsystemData(
                id: 'roof_structure',
                name: 'Roof Structure',
                rating: ConditionRating.satisfactory,
                findings: 'Good',
              ),
            ],
          ),
          exterior: SystemInspectionData.exterior(),
          roofing: SystemInspectionData.roofing(),
          plumbing: SystemInspectionData.plumbing(),
          electrical: SystemInspectionData.electrical(),
          hvac: SystemInspectionData.hvac(),
          insulationVentilation: SystemInspectionData.insulationVentilation(),
          appliances: SystemInspectionData.appliances(),
          lifeSafety: SystemInspectionData.lifeSafety(),
        );

        final json = original.toJson();
        final restored = GeneralInspectionFormData.fromJson(json);

        expect(restored.structural.subsystems.length, 3);
        expect(restored.structural.subsystems[0].rating,
            ConditionRating.deficient);
        expect(restored.structural.subsystems[0].findings, 'Cracked foundation');
        expect(
            restored.structural.subsystems[1].rating, ConditionRating.marginal);
        expect(restored.structural.subsystems[2].rating,
            ConditionRating.satisfactory);
      });

      test('all 9 systems subsystems survive round-trip', () {
        final original = GeneralInspectionFormData(
          structural: SystemInspectionData.structural().copyWith(
            rating: ConditionRating.satisfactory,
            subsystems: [
              const SubsystemData(
                id: 'foundation',
                name: 'Foundation',
                rating: ConditionRating.marginal,
                findings: 'F1',
              ),
              const SubsystemData(
                id: 'framing',
                name: 'Framing',
                rating: ConditionRating.deficient,
                findings: 'F2',
              ),
              const SubsystemData(
                id: 'roof_structure',
                name: 'Roof Structure',
                rating: ConditionRating.satisfactory,
                findings: 'F3',
              ),
            ],
          ),
          exterior: SystemInspectionData.exterior().copyWith(
            rating: ConditionRating.marginal,
            subsystems: [
              const SubsystemData(
                  id: 'siding',
                  name: 'Siding',
                  rating: ConditionRating.marginal,
                  findings: 'E1'),
              const SubsystemData(
                  id: 'trim',
                  name: 'Trim',
                  rating: ConditionRating.satisfactory,
                  findings: 'E2'),
              const SubsystemData(
                  id: 'porches',
                  name: 'Porches',
                  rating: ConditionRating.satisfactory,
                  findings: 'E3'),
              const SubsystemData(
                  id: 'driveways',
                  name: 'Driveways',
                  rating: ConditionRating.deficient,
                  findings: 'E4'),
            ],
          ),
          roofing: SystemInspectionData.roofing().copyWith(
            rating: ConditionRating.satisfactory,
          ),
          plumbing: SystemInspectionData.plumbing().copyWith(
            rating: ConditionRating.satisfactory,
          ),
          electrical: SystemInspectionData.electrical().copyWith(
            rating: ConditionRating.satisfactory,
          ),
          hvac: SystemInspectionData.hvac().copyWith(
            rating: ConditionRating.deficient,
          ),
          insulationVentilation:
              SystemInspectionData.insulationVentilation().copyWith(
            rating: ConditionRating.satisfactory,
          ),
          appliances: SystemInspectionData.appliances().copyWith(
            rating: ConditionRating.satisfactory,
          ),
          lifeSafety: SystemInspectionData.lifeSafety().copyWith(
            rating: ConditionRating.satisfactory,
          ),
        );

        final json = original.toJson();
        final restored = GeneralInspectionFormData.fromJson(json);
        expect(restored, equals(original));
      });
    });

    // =========================================================================
    // 4. ConditionRating serialization through form data
    // =========================================================================
    group('ConditionRating serialization through toFormDataMap', () {
      test('rating values in toFormDataMap match rating.name', () {
        final formData = GeneralInspectionFormData(
          structural: SystemInspectionData.structural().copyWith(
            rating: ConditionRating.satisfactory,
          ),
          exterior: SystemInspectionData.exterior().copyWith(
            rating: ConditionRating.marginal,
          ),
          roofing: SystemInspectionData.roofing().copyWith(
            rating: ConditionRating.deficient,
          ),
          plumbing: SystemInspectionData.plumbing().copyWith(
            rating: ConditionRating.notInspected,
          ),
          electrical: SystemInspectionData.electrical().copyWith(
            rating: ConditionRating.satisfactory,
          ),
          hvac: SystemInspectionData.hvac().copyWith(
            rating: ConditionRating.marginal,
          ),
          insulationVentilation:
              SystemInspectionData.insulationVentilation().copyWith(
            rating: ConditionRating.deficient,
          ),
          appliances: SystemInspectionData.appliances().copyWith(
            rating: ConditionRating.satisfactory,
          ),
          lifeSafety: SystemInspectionData.lifeSafety().copyWith(
            rating: ConditionRating.notInspected,
          ),
        );

        final map = formData.toFormDataMap();
        expect(map['structural_rating'], 'satisfactory');
        expect(map['exterior_rating'], 'marginal');
        expect(map['roofing_rating'], 'deficient');
        expect(map['plumbing_rating'], 'notInspected');
        expect(map['electrical_rating'], 'satisfactory');
        expect(map['hvac_rating'], 'marginal');
        expect(map['insulation_ventilation_rating'], 'deficient');
        expect(map['appliances_rating'], 'satisfactory');
        expect(map['life_safety_rating'], 'notInspected');
      });

      test('all ConditionRating enum values round-trip through name', () {
        for (final rating in ConditionRating.values) {
          final parsed = ConditionRating.parse(rating.name);
          expect(parsed, rating,
              reason: '${rating.name} should round-trip through parse');
        }
      });
    });

    // =========================================================================
    // 5. updateSystem helper
    // =========================================================================
    group('updateSystem', () {
      test('updateSystem replaces correct system and leaves others unchanged',
          () {
        final original = GeneralInspectionFormData.empty();
        final newStructural = SystemInspectionData.structural().copyWith(
          rating: ConditionRating.deficient,
          findings: 'Major foundation cracks',
        );

        final updated = original.updateSystem('structural', newStructural);

        expect(updated.structural, equals(newStructural));
        // All other systems unchanged
        expect(updated.exterior, equals(original.exterior));
        expect(updated.roofing, equals(original.roofing));
        expect(updated.plumbing, equals(original.plumbing));
        expect(updated.electrical, equals(original.electrical));
        expect(updated.hvac, equals(original.hvac));
        expect(
            updated.insulationVentilation,
            equals(original.insulationVentilation));
        expect(updated.appliances, equals(original.appliances));
        expect(updated.lifeSafety, equals(original.lifeSafety));
        // Narrative and flags unchanged
        expect(updated.scopeAndPurpose, original.scopeAndPurpose);
        expect(updated.generalComments, original.generalComments);
        expect(updated.safetyHazard, original.safetyHazard);
      });

      test('updateSystem works for each system ID', () {
        final original = GeneralInspectionFormData.empty();
        final systemIds = [
          'structural',
          'exterior',
          'roofing',
          'plumbing',
          'electrical',
          'hvac',
          'insulation_ventilation',
          'appliances',
          'life_safety',
        ];

        for (final id in systemIds) {
          final replacement = SystemInspectionData(
            systemId: id,
            systemName: 'Test $id',
            rating: ConditionRating.deficient,
            findings: 'Updated $id',
          );
          final updated = original.updateSystem(id, replacement);
          // The updated form should not equal original (the target changed)
          expect(updated == original, false,
              reason: 'updateSystem($id) should change the form');
        }
      });

      test('updateSystem with unknown ID returns unchanged instance', () {
        final original = GeneralInspectionFormData.empty();
        final result = original.updateSystem(
          'unknown_system',
          SystemInspectionData.structural(),
        );
        expect(identical(result, original), true);
      });
    });
  });
}
