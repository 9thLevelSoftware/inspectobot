import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/form_requirements.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';

void main() {
  group('FormRequirements extended — WDO', () {
    test('returns non-empty list with wdo_property_exterior', () {
      final requirements = FormRequirements.forFormRequirements(FormType.wdo);
      final keys = requirements.map((r) => r.key).toSet();

      expect(requirements, isNotEmpty);
      expect(keys, contains('photo:wdo_property_exterior'));
    });

    test('wdo_inaccessible_area absent when no inaccessible flags', () {
      final requirements = FormRequirements.forFormRequirements(FormType.wdo);
      final keys = requirements.map((r) => r.key).toSet();

      expect(keys, isNot(contains('photo:wdo_inaccessible_area')));
    });

    test('wdo_inaccessible_area present when wdo_attic_inaccessible is true', () {
      final requirements = FormRequirements.forFormRequirements(
        FormType.wdo,
        branchContext: const {'wdo_attic_inaccessible': true},
      );
      final keys = requirements.map((r) => r.key).toSet();

      expect(keys, contains('photo:wdo_inaccessible_area'));
    });
  });

  group('FormRequirements extended — Sinkhole', () {
    test('sinkhole_checklist_item appears when any section flag is true', () {
      final requirements = FormRequirements.forFormRequirements(
        FormType.sinkholeInspection,
        branchContext: const {'sinkhole_any_exterior_yes': true},
      );
      final keys = requirements.map((r) => r.key).toSet();

      expect(keys, contains('photo:sinkhole_checklist_item'));
    });

    test('sinkhole_checklist_item absent without any section flags', () {
      final requirements = FormRequirements.forFormRequirements(
        FormType.sinkholeInspection,
      );
      final keys = requirements.map((r) => r.key).toSet();

      expect(keys, isNot(contains('photo:sinkhole_checklist_item')));
    });

    test('anySinkholeYes returns true when any section flag is true', () {
      expect(
        FormRequirements.anySinkholeYes(
            {'sinkhole_any_exterior_yes': true}),
        isTrue,
      );
      expect(
        FormRequirements.anySinkholeYes(
            {'sinkhole_any_interior_yes': true}),
        isTrue,
      );
      expect(
        FormRequirements.anySinkholeYes(
            {'sinkhole_any_garage_yes': true}),
        isTrue,
      );
      expect(
        FormRequirements.anySinkholeYes(
            {'sinkhole_any_appurtenant_yes': true}),
        isTrue,
      );
    });

    test('anySinkholeYes returns false when all flags are false', () {
      expect(
        FormRequirements.anySinkholeYes(const {}),
        isFalse,
      );
      expect(
        FormRequirements.anySinkholeYes({
          'sinkhole_any_exterior_yes': false,
          'sinkhole_any_interior_yes': false,
          'sinkhole_any_garage_yes': false,
          'sinkhole_any_appurtenant_yes': false,
        }),
        isFalse,
      );
    });
  });

  group('FormRequirements extended — Mold', () {
    test('mold_lab_report present with mold_samples_taken flag', () {
      final requirements = FormRequirements.forFormRequirements(
        FormType.moldAssessment,
        branchContext: const {'mold_samples_taken': true},
      );
      final keys = requirements.map((r) => r.key).toSet();

      expect(keys, contains('document:mold_lab_report'));
    });

    test('mold_moisture_source present with mold_moisture_source_found flag', () {
      final requirements = FormRequirements.forFormRequirements(
        FormType.moldAssessment,
        branchContext: const {'mold_moisture_source_found': true},
      );
      final keys = requirements.map((r) => r.key).toSet();

      expect(keys, contains('photo:mold_moisture_source'));
    });
  });

  group('FormRequirements extended — General', () {
    test('returns non-empty list for generalInspection', () {
      final requirements = FormRequirements.forFormRequirements(
        FormType.generalInspection,
      );

      expect(requirements, isNotEmpty);
    });

    test('general_deficiency present with general_safety_hazard flag', () {
      final requirements = FormRequirements.forFormRequirements(
        FormType.generalInspection,
        branchContext: const {'general_safety_hazard': true},
      );
      final keys = requirements.map((r) => r.key).toSet();

      expect(keys, contains('photo:general_deficiency'));
    });
  });

  group('FormRequirements extended — cross-form coverage', () {
    test('all 7 form types return non-empty requirement lists', () {
      for (final formType in FormType.values) {
        final requirements = FormRequirements.forFormRequirements(formType);
        expect(
          requirements,
          isNotEmpty,
          reason: '${formType.code} should have requirements',
        );
      }
    });

    test('evaluate with new form types works without errors', () {
      final requirements = FormRequirements.evaluate(
        {FormType.wdo, FormType.sinkholeInspection},
      );

      expect(requirements, isNotEmpty);
    });
  });
}
