import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/condition_rating.dart';
import 'package:inspectobot/features/inspection/domain/general_inspection_form_data.dart';
import 'package:inspectobot/features/inspection/domain/system_inspection_data.dart';
import 'package:inspectobot/features/pdf/narrative/templates/general_inspection_template.dart';

void main() {
  group('GeneralInspectionFormData', () {
    group('empty()', () {
      test('produces isEmpty == true', () {
        final data = GeneralInspectionFormData.empty();
        expect(data.isEmpty, true);
      });

      test('produces expected defaults', () {
        final data = GeneralInspectionFormData.empty();
        expect(data.scopeAndPurpose, '');
        expect(data.generalComments, '');
        expect(data.safetyHazard, false);
        expect(data.moistureMoldEvidence, false);
        expect(data.pestEvidence, false);
        expect(data.structuralConcern, false);
        expect(data.structural.systemId, 'structural');
        expect(data.exterior.systemId, 'exterior');
        expect(data.roofing.systemId, 'roofing');
        expect(data.plumbing.systemId, 'plumbing');
        expect(data.electrical.systemId, 'electrical');
        expect(data.hvac.systemId, 'hvac');
        expect(data.insulationVentilation.systemId, 'insulation_ventilation');
        expect(data.appliances.systemId, 'appliances');
        expect(data.lifeSafety.systemId, 'life_safety');
      });
    });

    group('copyWith', () {
      test('preserves unchanged fields', () {
        final original = GeneralInspectionFormData.empty().copyWith(
          scopeAndPurpose: 'Full inspection',
          safetyHazard: true,
        );

        final modified = original.copyWith(
          generalComments: 'All systems functional',
        );

        expect(modified.scopeAndPurpose, 'Full inspection');
        expect(modified.generalComments, 'All systems functional');
        expect(modified.safetyHazard, true);
        expect(modified.structural, original.structural);
        expect(modified.electrical, original.electrical);
      });

      test('updates system fields', () {
        final original = GeneralInspectionFormData.empty();
        final updatedStructural = original.structural.copyWith(
          rating: ConditionRating.satisfactory,
          findings: 'No issues found',
        );

        final modified = original.copyWith(structural: updatedStructural);

        expect(modified.structural.rating, ConditionRating.satisfactory);
        expect(modified.structural.findings, 'No issues found');
        expect(modified.exterior, original.exterior);
      });
    });

    group('updateSystem', () {
      test('replaces correct system by systemId', () {
        final original = GeneralInspectionFormData.empty();
        final updatedElectrical = original.electrical.copyWith(
          rating: ConditionRating.deficient,
          findings: 'Panel overloaded',
        );

        final modified = original.updateSystem('electrical', updatedElectrical);

        expect(modified.electrical.rating, ConditionRating.deficient);
        expect(modified.electrical.findings, 'Panel overloaded');
        // Other systems unchanged
        expect(modified.structural, original.structural);
        expect(modified.plumbing, original.plumbing);
      });

      test('handles insulation_ventilation systemId', () {
        final original = GeneralInspectionFormData.empty();
        final updated = original.insulationVentilation.copyWith(
          rating: ConditionRating.marginal,
        );

        final modified =
            original.updateSystem('insulation_ventilation', updated);

        expect(
          modified.insulationVentilation.rating,
          ConditionRating.marginal,
        );
      });

      test('handles life_safety systemId', () {
        final original = GeneralInspectionFormData.empty();
        final updated = original.lifeSafety.copyWith(
          rating: ConditionRating.satisfactory,
        );

        final modified = original.updateSystem('life_safety', updated);

        expect(modified.lifeSafety.rating, ConditionRating.satisfactory);
      });

      test('returns same instance for unknown systemId', () {
        final original = GeneralInspectionFormData.empty();
        final result = original.updateSystem(
          'unknown',
          SystemInspectionData.structural(),
        );

        expect(identical(result, original), true);
      });
    });

    group('toFormDataMap()', () {
      test('toFormDataMap produces all template keys', () {
        final keys =
            GeneralInspectionFormData.empty().toFormDataMap().keys.toSet();
        expect(keys, equals(const GeneralInspectionTemplate().referencedFormDataKeys));
      });

      test('produces exactly 72 keys', () {
        final map = GeneralInspectionFormData.empty().toFormDataMap();
        // 2 narrative + 18 system-level + 52 subsystem-level = 72
        expect(map.length, 72);
      });

      test('rating values match ConditionRating.name', () {
        final data = GeneralInspectionFormData.empty().copyWith(
          structural: SystemInspectionData.structural().copyWith(
            rating: ConditionRating.satisfactory,
          ),
          electrical: SystemInspectionData.electrical().copyWith(
            rating: ConditionRating.deficient,
          ),
        );

        final map = data.toFormDataMap();

        expect(map['structural_rating'], 'satisfactory');
        expect(map['electrical_rating'], 'deficient');
        // Default systems use notInspected
        expect(map['exterior_rating'], 'notInspected');
        expect(map['hvac_rating'], 'notInspected');
      });

      test('subsystem ratings and findings are mapped correctly', () {
        final data = GeneralInspectionFormData.empty().copyWith(
          plumbing: SystemInspectionData.plumbing().copyWith(
            subsystems: [
              const SubsystemData(
                id: 'supply',
                name: 'Supply',
                rating: ConditionRating.marginal,
                findings: 'Low pressure',
              ),
              const SubsystemData(
                id: 'drain_waste',
                name: 'Drain/Waste',
              ),
              const SubsystemData(
                id: 'water_heater',
                name: 'Water Heater',
              ),
            ],
          ),
        );

        final map = data.toFormDataMap();

        expect(map['plumbing_supply_rating'], 'marginal');
        expect(map['plumbing_supply_findings'], 'Low pressure');
        expect(map['plumbing_drain_waste_rating'], 'notInspected');
        expect(map['plumbing_drain_waste_findings'], '');
      });

      test('narrative fields map to correct keys', () {
        final data = GeneralInspectionFormData.empty().copyWith(
          scopeAndPurpose: 'Visual inspection per Rule 61-30.801',
          generalComments: 'Property in good condition overall',
        );

        final map = data.toFormDataMap();

        expect(
          map['scope_and_purpose'],
          'Visual inspection per Rule 61-30.801',
        );
        expect(
          map['general_comments'],
          'Property in good condition overall',
        );
      });
    });

    group('toJson/fromJson', () {
      test('round-trip preserves all data', () {
        final original = _fullyPopulatedFormData();

        final json = original.toJson();
        final restored = GeneralInspectionFormData.fromJson(json);

        expect(restored, original);
        expect(restored.scopeAndPurpose, original.scopeAndPurpose);
        expect(restored.generalComments, original.generalComments);
        expect(restored.structural, original.structural);
        expect(restored.exterior, original.exterior);
        expect(restored.roofing, original.roofing);
        expect(restored.plumbing, original.plumbing);
        expect(restored.electrical, original.electrical);
        expect(restored.hvac, original.hvac);
        expect(
          restored.insulationVentilation,
          original.insulationVentilation,
        );
        expect(restored.appliances, original.appliances);
        expect(restored.lifeSafety, original.lifeSafety);
        expect(restored.safetyHazard, true);
        expect(restored.moistureMoldEvidence, true);
        expect(restored.pestEvidence, false);
        expect(restored.structuralConcern, true);
      });

      test('fromJson handles missing system gracefully', () {
        final data = GeneralInspectionFormData.fromJson(<String, dynamic>{
          'scopeAndPurpose': 'partial',
          // Missing all system keys
        });

        expect(data.scopeAndPurpose, 'partial');
        // Systems should fall back to their factory defaults
        expect(data.structural.systemId, 'structural');
        expect(data.structural.subsystems.length, 3);
        expect(data.electrical.systemId, 'electrical');
        expect(data.electrical.subsystems.length, 4);
      });

      test('fromJson handles null branch flags', () {
        final data = GeneralInspectionFormData.fromJson(<String, dynamic>{
          'safetyHazard': null,
          'moistureMoldEvidence': null,
          'pestEvidence': null,
          'structuralConcern': null,
        });

        expect(data.safetyHazard, false);
        expect(data.moistureMoldEvidence, false);
        expect(data.pestEvidence, false);
        expect(data.structuralConcern, false);
      });

      test('fromJson handles empty map', () {
        final data = GeneralInspectionFormData.fromJson(<String, dynamic>{});

        expect(data.scopeAndPurpose, '');
        expect(data.generalComments, '');
        expect(data.safetyHazard, false);
        expect(data.structural.systemId, 'structural');
      });
    });

    group('isEmpty', () {
      test('returns true for empty form', () {
        expect(GeneralInspectionFormData.empty().isEmpty, true);
      });

      test('returns false when scopeAndPurpose is set', () {
        final data = GeneralInspectionFormData.empty().copyWith(
          scopeAndPurpose: 'something',
        );
        expect(data.isEmpty, false);
      });

      test('returns false when a system has a rating', () {
        final data = GeneralInspectionFormData.empty().copyWith(
          hvac: SystemInspectionData.hvac().copyWith(
            rating: ConditionRating.satisfactory,
          ),
        );
        expect(data.isEmpty, false);
      });

      test('returns false when a branch flag is true', () {
        final data = GeneralInspectionFormData.empty().copyWith(
          safetyHazard: true,
        );
        expect(data.isEmpty, false);
      });
    });

    group('equality', () {
      test('two empty instances are equal', () {
        expect(
          GeneralInspectionFormData.empty(),
          GeneralInspectionFormData.empty(),
        );
        expect(
          GeneralInspectionFormData.empty().hashCode,
          GeneralInspectionFormData.empty().hashCode,
        );
      });

      test('different values are not equal', () {
        final a = GeneralInspectionFormData.empty();
        final b = a.copyWith(scopeAndPurpose: 'different');
        expect(a, isNot(b));
      });

      test('different system ratings are not equal', () {
        final a = GeneralInspectionFormData.empty();
        final b = a.copyWith(
          structural: a.structural.copyWith(
            rating: ConditionRating.deficient,
          ),
        );
        expect(a, isNot(b));
      });
    });
  });
}

/// Returns a fully populated form data instance for round-trip testing.
GeneralInspectionFormData _fullyPopulatedFormData() {
  return GeneralInspectionFormData(
    scopeAndPurpose: 'Visual inspection per Rule 61-30.801',
    generalComments: 'Property in good condition',
    structural: SystemInspectionData.structural().copyWith(
      rating: ConditionRating.satisfactory,
      findings: 'No structural issues',
    ),
    exterior: SystemInspectionData.exterior().copyWith(
      rating: ConditionRating.marginal,
      findings: 'Minor siding damage',
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
      rating: ConditionRating.deficient,
      findings: 'Panel overloaded',
    ),
    hvac: SystemInspectionData.hvac().copyWith(
      rating: ConditionRating.satisfactory,
      findings: 'System operational',
    ),
    insulationVentilation: SystemInspectionData.insulationVentilation().copyWith(
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
    safetyHazard: true,
    moistureMoldEvidence: true,
    pestEvidence: false,
    structuralConcern: true,
  );
}
