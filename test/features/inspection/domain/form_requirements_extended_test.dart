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
    test('sinkhole_checklist_item appears with sinkhole_any_yes flag', () {
      final requirements = FormRequirements.forFormRequirements(
        FormType.sinkholeInspection,
        branchContext: const {'sinkhole_any_yes': true},
      );
      final keys = requirements.map((r) => r.key).toSet();

      expect(keys, contains('photo:sinkhole_checklist_item'));
    });

    test('sinkhole_checklist_item absent without flag', () {
      final requirements = FormRequirements.forFormRequirements(
        FormType.sinkholeInspection,
      );
      final keys = requirements.map((r) => r.key).toSet();

      expect(keys, isNot(contains('photo:sinkhole_checklist_item')));
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
