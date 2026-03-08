import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/condition_rating.dart';
import 'package:inspectobot/features/inspection/domain/system_inspection_data.dart';

void main() {
  group('SubsystemData', () {
    test('defaults to notInspected rating and empty findings', () {
      const sub = SubsystemData(id: 'test', name: 'Test');
      expect(sub.rating, ConditionRating.notInspected);
      expect(sub.findings, '');
      expect(sub.isEmpty, isTrue);
    });

    test('isEmpty is false when rating is set', () {
      const sub = SubsystemData(
        id: 'test',
        name: 'Test',
        rating: ConditionRating.satisfactory,
      );
      expect(sub.isEmpty, isFalse);
    });

    test('isEmpty is false when findings is non-empty', () {
      const sub = SubsystemData(
        id: 'test',
        name: 'Test',
        findings: 'Found crack',
      );
      expect(sub.isEmpty, isFalse);
    });

    test('copyWith replaces fields', () {
      const original = SubsystemData(id: 'a', name: 'A');
      final updated = original.copyWith(
        id: 'b',
        name: 'B',
        rating: ConditionRating.deficient,
        findings: 'Bad',
      );
      expect(updated.id, 'b');
      expect(updated.name, 'B');
      expect(updated.rating, ConditionRating.deficient);
      expect(updated.findings, 'Bad');
    });

    test('copyWith preserves unchanged fields', () {
      const original = SubsystemData(
        id: 'a',
        name: 'A',
        rating: ConditionRating.marginal,
        findings: 'Notes',
      );
      final updated = original.copyWith(findings: 'New notes');
      expect(updated.id, 'a');
      expect(updated.name, 'A');
      expect(updated.rating, ConditionRating.marginal);
      expect(updated.findings, 'New notes');
    });

    test('toJson serializes correctly', () {
      const sub = SubsystemData(
        id: 'foundation',
        name: 'Foundation',
        rating: ConditionRating.satisfactory,
        findings: 'Solid concrete',
      );
      final json = sub.toJson();
      expect(json['id'], 'foundation');
      expect(json['name'], 'Foundation');
      expect(json['rating'], 'satisfactory');
      expect(json['findings'], 'Solid concrete');
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'id': 'framing',
        'name': 'Framing',
        'rating': 'marginal',
        'findings': 'Minor issue',
      };
      final sub = SubsystemData.fromJson(json);
      expect(sub.id, 'framing');
      expect(sub.name, 'Framing');
      expect(sub.rating, ConditionRating.marginal);
      expect(sub.findings, 'Minor issue');
    });

    test('fromJson with missing rating defaults to notInspected', () {
      final json = {
        'id': 'test',
        'name': 'Test',
      };
      final sub = SubsystemData.fromJson(json);
      expect(sub.rating, ConditionRating.notInspected);
    });

    test('fromJson with null rating defaults to notInspected', () {
      final json = {
        'id': 'test',
        'name': 'Test',
        'rating': null,
        'findings': '',
      };
      final sub = SubsystemData.fromJson(json);
      expect(sub.rating, ConditionRating.notInspected);
    });

    test('toJson/fromJson round-trip preserves data', () {
      const original = SubsystemData(
        id: 'gfci',
        name: 'GFCI',
        rating: ConditionRating.deficient,
        findings: 'Not functioning',
      );
      final roundTripped = SubsystemData.fromJson(original.toJson());
      expect(roundTripped, original);
    });

    test('equality works correctly', () {
      const a = SubsystemData(
        id: 'x',
        name: 'X',
        rating: ConditionRating.satisfactory,
      );
      const b = SubsystemData(
        id: 'x',
        name: 'X',
        rating: ConditionRating.satisfactory,
      );
      const c = SubsystemData(
        id: 'x',
        name: 'X',
        rating: ConditionRating.deficient,
      );
      expect(a, b);
      expect(a, isNot(c));
      expect(a.hashCode, b.hashCode);
    });
  });

  group('SystemInspectionData', () {
    test('defaults to notInspected rating, empty findings and subsystems', () {
      const system = SystemInspectionData(
        systemId: 'test',
        systemName: 'Test',
      );
      expect(system.rating, ConditionRating.notInspected);
      expect(system.findings, '');
      expect(system.subsystems, isEmpty);
      expect(system.isEmpty, isTrue);
    });

    test('isEmpty is false when system rating is set', () {
      const system = SystemInspectionData(
        systemId: 'test',
        systemName: 'Test',
        rating: ConditionRating.satisfactory,
      );
      expect(system.isEmpty, isFalse);
    });

    test('isEmpty is false when findings is non-empty', () {
      const system = SystemInspectionData(
        systemId: 'test',
        systemName: 'Test',
        findings: 'Some findings',
      );
      expect(system.isEmpty, isFalse);
    });

    test('isEmpty is false when any subsystem is non-empty', () {
      const system = SystemInspectionData(
        systemId: 'test',
        systemName: 'Test',
        subsystems: [
          SubsystemData(id: 'a', name: 'A'),
          SubsystemData(
            id: 'b',
            name: 'B',
            rating: ConditionRating.marginal,
          ),
        ],
      );
      expect(system.isEmpty, isFalse);
    });

    test('isEmpty is true when all subsystems are empty', () {
      const system = SystemInspectionData(
        systemId: 'test',
        systemName: 'Test',
        subsystems: [
          SubsystemData(id: 'a', name: 'A'),
          SubsystemData(id: 'b', name: 'B'),
        ],
      );
      expect(system.isEmpty, isTrue);
    });

    test('copyWith replaces fields', () {
      const original = SystemInspectionData(
        systemId: 'a',
        systemName: 'A',
      );
      final updated = original.copyWith(
        systemId: 'b',
        systemName: 'B',
        rating: ConditionRating.deficient,
        findings: 'Bad',
        subsystems: [const SubsystemData(id: 's1', name: 'S1')],
      );
      expect(updated.systemId, 'b');
      expect(updated.systemName, 'B');
      expect(updated.rating, ConditionRating.deficient);
      expect(updated.findings, 'Bad');
      expect(updated.subsystems, hasLength(1));
    });

    test('copyWith preserves unchanged fields including subsystems', () {
      final original = SystemInspectionData.structural();
      final updated = original.copyWith(findings: 'Updated');
      expect(updated.systemId, 'structural');
      expect(updated.systemName, 'Structural Components');
      expect(updated.rating, ConditionRating.notInspected);
      expect(updated.findings, 'Updated');
      expect(updated.subsystems, hasLength(3));
    });

    test('toJson serializes correctly', () {
      const system = SystemInspectionData(
        systemId: 'hvac',
        systemName: 'HVAC',
        rating: ConditionRating.satisfactory,
        findings: 'All good',
        subsystems: [
          SubsystemData(
            id: 'heating',
            name: 'Heating',
            rating: ConditionRating.satisfactory,
          ),
        ],
      );
      final json = system.toJson();
      expect(json['systemId'], 'hvac');
      expect(json['systemName'], 'HVAC');
      expect(json['rating'], 'satisfactory');
      expect(json['findings'], 'All good');
      expect(json['subsystems'], isList);
      expect((json['subsystems'] as List).first['id'], 'heating');
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'systemId': 'electrical',
        'systemName': 'Electrical',
        'rating': 'deficient',
        'findings': 'Panel issues',
        'subsystems': [
          {
            'id': 'panels',
            'name': 'Panels',
            'rating': 'deficient',
            'findings': 'Corrosion',
          },
        ],
      };
      final system = SystemInspectionData.fromJson(json);
      expect(system.systemId, 'electrical');
      expect(system.systemName, 'Electrical');
      expect(system.rating, ConditionRating.deficient);
      expect(system.findings, 'Panel issues');
      expect(system.subsystems, hasLength(1));
      expect(system.subsystems.first.id, 'panels');
      expect(system.subsystems.first.rating, ConditionRating.deficient);
    });

    test('fromJson with missing rating defaults to notInspected', () {
      final json = {
        'systemId': 'test',
        'systemName': 'Test',
      };
      final system = SystemInspectionData.fromJson(json);
      expect(system.rating, ConditionRating.notInspected);
    });

    test('fromJson with empty subsystems list returns empty list', () {
      final json = {
        'systemId': 'test',
        'systemName': 'Test',
        'subsystems': <dynamic>[],
      };
      final system = SystemInspectionData.fromJson(json);
      expect(system.subsystems, isEmpty);
    });

    test('fromJson with missing subsystems returns empty list', () {
      final json = {
        'systemId': 'test',
        'systemName': 'Test',
      };
      final system = SystemInspectionData.fromJson(json);
      expect(system.subsystems, isEmpty);
    });

    test('toJson/fromJson round-trip preserves data', () {
      final original = SystemInspectionData.electrical().copyWith(
        rating: ConditionRating.marginal,
        findings: 'Minor issues',
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
            findings: 'Aging',
          ),
        ],
      );
      final roundTripped = SystemInspectionData.fromJson(original.toJson());
      expect(roundTripped, original);
    });

    test('ConditionRating serialization round-trip within toJson/fromJson', () {
      for (final rating in ConditionRating.values) {
        final system = SystemInspectionData(
          systemId: 'test',
          systemName: 'Test',
          rating: rating,
          subsystems: [
            SubsystemData(id: 'sub', name: 'Sub', rating: rating),
          ],
        );
        final restored = SystemInspectionData.fromJson(system.toJson());
        expect(restored.rating, rating,
            reason: 'System rating $rating should round-trip');
        expect(restored.subsystems.first.rating, rating,
            reason: 'Subsystem rating $rating should round-trip');
      }
    });

    test('equality works correctly', () {
      final a = SystemInspectionData.structural();
      final b = SystemInspectionData.structural();
      final c = SystemInspectionData.electrical();
      expect(a, b);
      expect(a, isNot(c));
      expect(a.hashCode, b.hashCode);
    });

    test('equality considers subsystem differences', () {
      final a = SystemInspectionData.structural();
      final b = a.copyWith(
        subsystems: [
          const SubsystemData(
            id: 'foundation',
            name: 'Foundation',
            rating: ConditionRating.deficient,
          ),
        ],
      );
      expect(a, isNot(b));
    });
  });

  group('SystemInspectionData factory constructors', () {
    test('structural() has correct id, name, and 3 subsystems', () {
      final s = SystemInspectionData.structural();
      expect(s.systemId, 'structural');
      expect(s.systemName, 'Structural Components');
      expect(s.subsystems, hasLength(3));
      expect(s.subsystems.map((e) => e.id).toList(),
          ['foundation', 'framing', 'roof_structure']);
      expect(s.subsystems.map((e) => e.name).toList(),
          ['Foundation', 'Framing', 'Roof Structure']);
    });

    test('exterior() has correct id, name, and 4 subsystems', () {
      final s = SystemInspectionData.exterior();
      expect(s.systemId, 'exterior');
      expect(s.systemName, 'Exterior');
      expect(s.subsystems, hasLength(4));
      expect(s.subsystems.map((e) => e.id).toList(),
          ['siding', 'trim', 'porches', 'driveways']);
      expect(s.subsystems.map((e) => e.name).toList(),
          ['Siding', 'Trim', 'Porches', 'Driveways']);
    });

    test('roofing() has correct id, name, and 3 subsystems', () {
      final s = SystemInspectionData.roofing();
      expect(s.systemId, 'roofing');
      expect(s.systemName, 'Roofing');
      expect(s.subsystems, hasLength(3));
      expect(s.subsystems.map((e) => e.id).toList(),
          ['covering', 'flashing', 'drainage']);
    });

    test('plumbing() has correct id, name, and 3 subsystems', () {
      final s = SystemInspectionData.plumbing();
      expect(s.systemId, 'plumbing');
      expect(s.systemName, 'Plumbing');
      expect(s.subsystems, hasLength(3));
      expect(s.subsystems.map((e) => e.id).toList(),
          ['supply', 'drain_waste', 'water_heater']);
      expect(s.subsystems.map((e) => e.name).toList(),
          ['Supply', 'Drain/Waste', 'Water Heater']);
    });

    test('electrical() has correct id, name, and 4 subsystems', () {
      final s = SystemInspectionData.electrical();
      expect(s.systemId, 'electrical');
      expect(s.systemName, 'Electrical');
      expect(s.subsystems, hasLength(4));
      expect(s.subsystems.map((e) => e.id).toList(),
          ['service', 'panels', 'branch_circuits', 'gfci']);
      expect(s.subsystems.map((e) => e.name).toList(),
          ['Service', 'Panels', 'Branch Circuits', 'GFCI']);
    });

    test('hvac() has correct id, name, and 3 subsystems', () {
      final s = SystemInspectionData.hvac();
      expect(s.systemId, 'hvac');
      expect(s.systemName, 'HVAC');
      expect(s.subsystems, hasLength(3));
      expect(s.subsystems.map((e) => e.id).toList(),
          ['heating', 'cooling', 'distribution']);
    });

    test('insulationVentilation() has correct id, name, and 3 subsystems', () {
      final s = SystemInspectionData.insulationVentilation();
      expect(s.systemId, 'insulation_ventilation');
      expect(s.systemName, 'Insulation and Ventilation');
      expect(s.subsystems, hasLength(3));
      expect(s.subsystems.map((e) => e.id).toList(),
          ['attic', 'wall', 'crawlspace']);
    });

    test('appliances() has correct id, name, and no subsystems', () {
      final s = SystemInspectionData.appliances();
      expect(s.systemId, 'appliances');
      expect(s.systemName, 'Built-in Appliances');
      expect(s.subsystems, isEmpty);
    });

    test('lifeSafety() has correct id, name, and 3 subsystems', () {
      final s = SystemInspectionData.lifeSafety();
      expect(s.systemId, 'life_safety');
      expect(s.systemName, 'Life Safety');
      expect(s.subsystems, hasLength(3));
      expect(s.subsystems.map((e) => e.id).toList(),
          ['smoke_detectors', 'co_detectors', 'fire_sprinklers']);
      expect(s.subsystems.map((e) => e.name).toList(),
          ['Smoke Detectors', 'CO Detectors', 'Fire Sprinklers']);
    });
  });
}
