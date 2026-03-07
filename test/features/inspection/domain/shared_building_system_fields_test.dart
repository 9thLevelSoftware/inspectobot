import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/rating_scale.dart';
import 'package:inspectobot/features/inspection/domain/shared_building_system_fields.dart';

void main() {
  group('SharedBuildingSystemFields', () {
    test('toJson on empty instance returns empty map', () {
      const empty = SharedBuildingSystemFields();
      expect(empty.toJson(), isEmpty);
    });

    test('fromJson with partial data', () {
      final partial = SharedBuildingSystemFields.fromJson(const {
        'year_built': 1995,
        'roof_age': 10,
      });

      expect(partial.yearBuilt, 1995);
      expect(partial.roofAge, 10);
      expect(partial.policyNumber, isNull);
      expect(partial.roofCondition, isNull);
    });

    test('toJson -> fromJson round-trip with all fields', () {
      final full = SharedBuildingSystemFields(
        yearBuilt: 2000,
        policyNumber: 'POL-999',
        inspectorPhone: '555-1234',
        signatureDate: DateTime(2026, 1, 15),
        roofCoveringMaterial: 'Shingle',
        roofAge: 5,
        roofCondition: RatingScale.satisfactory,
        electricalPanelType: 'Breaker',
        electricalPanelAmps: 200,
        plumbingPipeMaterial: 'Copper',
        waterHeaterType: 'Gas',
        hvacType: 'Central',
        foundationCracks: false,
      );

      final restored = SharedBuildingSystemFields.fromJson(full.toJson());
      expect(restored, full);
    });

    test('roofCondition serializes via RatingScale', () {
      final fields = SharedBuildingSystemFields(
        roofCondition: RatingScale.marginal,
      );
      final json = fields.toJson();

      expect(json['roof_condition'], 'marginal');
      final restored = SharedBuildingSystemFields.fromJson(json);
      expect(restored.roofCondition, RatingScale.marginal);
    });
  });
}
