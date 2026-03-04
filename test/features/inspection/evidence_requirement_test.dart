import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/evidence_requirement.dart';
import 'package:inspectobot/features/inspection/domain/form_requirements.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';

void main() {
  group('FormRequirements.evaluate', () {
    test('returns four-point exterior elevation requirements', () {
      final requirements = FormRequirements.evaluate({FormType.fourPoint});
      final keys = requirements.map((requirement) => requirement.key).toSet();

      expect(keys, contains('photo:exterior_front'));
      expect(keys, contains('photo:exterior_rear'));
      expect(keys, contains('photo:exterior_left'));
      expect(keys, contains('photo:exterior_right'));
    });

    test('includes roof defect requirement only when branch flag is true', () {
      final withoutDefect = FormRequirements.evaluate({FormType.roofCondition});
      final withDefect = FormRequirements.evaluate(
        {FormType.roofCondition},
        branchContext: const <String, dynamic>{'roof_defect_present': true},
      );

      expect(
        withoutDefect.any((requirement) => requirement.key == 'photo:roof_defect'),
        isFalse,
      );
      expect(
        withDefect.any((requirement) => requirement.key == 'photo:roof_defect'),
        isTrue,
      );
    });

    test('includes hazard photo only when hazard answer is true', () {
      final withoutHazard = FormRequirements.evaluate({FormType.fourPoint});
      final withHazard = FormRequirements.evaluate(
        {FormType.fourPoint},
        branchContext: const <String, dynamic>{'hazard_present': true},
      );

      expect(
        withoutHazard.any((requirement) => requirement.key == 'photo:hazard_photo'),
        isFalse,
      );
      expect(
        withHazard.any((requirement) => requirement.key == 'photo:hazard_photo'),
        isTrue,
      );
    });

    test('contains all seven wind mitigation categories', () {
      final windOnly = FormRequirements.evaluate({FormType.windMitigation});
      final photoKeys = windOnly
          .where((requirement) => requirement.mediaType == EvidenceMediaType.photo)
          .map((requirement) => requirement.key)
          .toSet();

      expect(photoKeys, contains('photo:wind_roof_deck'));
      expect(photoKeys, contains('photo:wind_roof_to_wall'));
      expect(photoKeys, contains('photo:wind_roof_shape'));
      expect(photoKeys, contains('photo:wind_secondary_water_resistance'));
      expect(photoKeys, contains('photo:wind_opening_protection'));
      expect(photoKeys, contains('photo:wind_opening_type'));
      expect(photoKeys, contains('photo:wind_permit_year'));
      expect(photoKeys.length, 7);
    });

    test('adds wind document requirements when trigger answers are true', () {
      final requirements = FormRequirements.evaluate(
        {FormType.windMitigation},
        branchContext: const <String, dynamic>{
          'wind_roof_deck_document_required': true,
          'wind_opening_document_required': true,
          'wind_permit_document_required': true,
        },
      );

      final docs = requirements
          .where((requirement) => requirement.mediaType == EvidenceMediaType.document)
          .map((requirement) => requirement.key)
          .toSet();

      expect(docs, contains('document:wind_roof_deck'));
      expect(docs, contains('document:wind_opening_protection'));
      expect(docs, contains('document:wind_permit_year'));
    });

    test('returns deterministic ordering and unique requirement keys', () {
      final requirements = FormRequirements.evaluate(
        {FormType.windMitigation, FormType.fourPoint, FormType.roofCondition},
        branchContext: const <String, dynamic>{
          'roof_defect_present': true,
          'hazard_present': true,
          'wind_roof_deck_document_required': true,
        },
      );

      final keys = requirements.map((requirement) => requirement.key).toList();
      final sorted = List<String>.from(keys)..sort();

      expect(keys, sorted);
      expect(keys.length, keys.toSet().length);
    });

    test('every requirement carries minimum count and stable metadata', () {
      final requirements = FormRequirements.evaluate(
        {FormType.fourPoint, FormType.windMitigation},
      );

      for (final requirement in requirements) {
        expect(requirement.key, isNotEmpty);
        expect(requirement.label, isNotEmpty);
        expect(requirement.minimumCount, greaterThanOrEqualTo(1));
      }
    });
  });
}
