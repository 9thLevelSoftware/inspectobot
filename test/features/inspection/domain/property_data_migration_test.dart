import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/inspection_wizard_state.dart';
import 'package:inspectobot/features/inspection/domain/property_data.dart';
import 'package:inspectobot/features/inspection/domain/property_data_migrations.dart';
import 'package:inspectobot/features/inspection/domain/rating_scale.dart';
import 'package:inspectobot/features/inspection/domain/required_photo_category.dart';
import 'package:inspectobot/features/inspection/domain/shared_building_system_fields.dart';
import 'package:inspectobot/features/inspection/domain/universal_property_fields.dart';

/// Tests for PropertyData migration, serialization round-trips, and cross-form
/// namespace isolation.
void main() {
  /// Builds a fully populated PropertyData for testing.
  PropertyData buildFullPropertyData({
    Set<FormType>? enabledForms,
    Map<FormType, Map<String, dynamic>>? formData,
    SharedBuildingSystemFields? shared,
  }) {
    return PropertyData(
      inspectionId: 'pd-001',
      organizationId: 'org-001',
      userId: 'user-001',
      clientEmail: 'test@example.com',
      clientPhone: '555-9999',
      enabledForms: enabledForms ?? {FormType.fourPoint},
      wizardSnapshot: WizardProgressSnapshot.empty,
      universal: UniversalPropertyFields(
        propertyAddress: '100 Test St',
        inspectionDate: DateTime(2026, 1, 15),
        inspectorName: 'Inspector Smith',
        inspectorCompany: 'Smith Inspections',
        inspectorLicenseNumber: 'FL-12345',
        clientName: 'Client Jones',
      ),
      shared: shared ?? const SharedBuildingSystemFields(yearBuilt: 1995),
      formData: formData ?? const {},
      schemaVersion: PropertyDataMigrations.currentVersion,
    );
  }

  /// Builds a minimal valid PropertyData JSON map.
  Map<String, dynamic> buildMinimalJson({
    int? schemaVersion,
    List<String>? enabledForms,
    Map<String, dynamic>? formData,
    Map<String, dynamic>? shared,
  }) {
    final json = <String, dynamic>{
      'inspection_id': 'json-001',
      'organization_id': 'org-001',
      'user_id': 'user-001',
      'client_email': 'json@test.com',
      'client_phone': '555-0000',
      'enabled_forms': enabledForms ?? ['four_point'],
      'universal': {
        'property_address': '200 JSON Ave',
        'inspection_date': '2026-01-20T00:00:00.000',
        'inspector_name': 'Inspector A',
        'inspector_company': 'Company A',
        'inspector_license_number': 'LIC-A',
        'client_name': 'Client B',
      },
      'schema_version': schemaVersion ?? 1,
    };
    if (shared != null) {
      json['shared'] = shared;
    }
    if (formData != null) {
      json['form_data'] = formData;
    }
    return json;
  }

  group('PropertyData v1 migration', () {
    test('migrate passes through v1 data unchanged', () {
      final input = buildMinimalJson(schemaVersion: 1);
      final result = PropertyDataMigrations.migrate(input);
      expect(result['schema_version'], 1);
      expect(result['inspection_id'], 'json-001');
    });

    test('migrate passes through data without schema_version (defaults to 1)',
        () {
      final input = buildMinimalJson();
      input.remove('schema_version');
      final result = PropertyDataMigrations.migrate(input);
      // Missing version defaults to 1, which >= currentVersion => pass through.
      expect(result['inspection_id'], 'json-001');
    });

    test('migrate preserves future versions (forward compatibility)', () {
      final input = buildMinimalJson(schemaVersion: 99);
      final result = PropertyDataMigrations.migrate(input);
      expect(result['schema_version'], 99);
    });
  });

  group('PropertyData with missing optional fields', () {
    test('missing client_email defaults to empty string', () {
      final json = buildMinimalJson();
      json.remove('client_email');
      final pd = PropertyData.fromJson(json);
      expect(pd.clientEmail, '');
    });

    test('missing client_phone defaults to empty string', () {
      final json = buildMinimalJson();
      json.remove('client_phone');
      final pd = PropertyData.fromJson(json);
      expect(pd.clientPhone, '');
    });

    test('missing initial_step_index defaults to 0', () {
      final json = buildMinimalJson();
      json.remove('initial_step_index');
      final pd = PropertyData.fromJson(json);
      expect(pd.initialStepIndex, 0);
    });

    test('missing form_data defaults to empty map', () {
      final json = buildMinimalJson();
      // form_data not included in buildMinimalJson by default
      final pd = PropertyData.fromJson(json);
      expect(pd.formData, isEmpty);
    });

    test('missing captured_categories defaults to empty set', () {
      final json = buildMinimalJson();
      final pd = PropertyData.fromJson(json);
      expect(pd.capturedCategories, isEmpty);
    });

    test('missing captured_photo_paths defaults to empty map', () {
      final json = buildMinimalJson();
      final pd = PropertyData.fromJson(json);
      expect(pd.capturedPhotoPaths, isEmpty);
    });

    test('missing captured_evidence_paths defaults to empty map', () {
      final json = buildMinimalJson();
      final pd = PropertyData.fromJson(json);
      expect(pd.capturedEvidencePaths, isEmpty);
    });

    test('missing shared defaults to empty SharedBuildingSystemFields', () {
      final json = buildMinimalJson();
      final pd = PropertyData.fromJson(json);
      expect(pd.shared.yearBuilt, isNull);
      expect(pd.shared.roofAge, isNull);
      expect(pd.shared.foundationCracks, isNull);
    });
  });

  group('PropertyData round-trip with all 7 form type namespaces', () {
    test('each form type namespace is preserved independently', () {
      final allFormData = <FormType, Map<String, dynamic>>{
        FormType.fourPoint: {'hazard_present': true, 'rating': 'Good'},
        FormType.roofCondition: {'roof_defect_present': false, 'slope': 'hip'},
        FormType.windMitigation: {'deck_type': 'plywood', 'nail_spacing': 6},
        FormType.wdo: {'wdo_visible_evidence': true, 'species': 'subterranean'},
        FormType.sinkholeInspection: {
          'sinkhole_any_exterior_yes': false,
          'floor_level': true,
        },
        FormType.moldAssessment: {
          'mold_visible_found': true,
          'moisture_reading': 45.2,
        },
        FormType.generalInspection: {
          'general_safety_hazard': false,
          'overall_condition': 'fair',
        },
      };

      final pd = buildFullPropertyData(
        enabledForms: FormType.values.toSet(),
        formData: allFormData,
      );

      final json = pd.toJson();
      final restored = PropertyData.fromJson(json);

      for (final formType in FormType.values) {
        final original = allFormData[formType]!;
        for (final entry in original.entries) {
          expect(
            restored.getFormValue(formType, entry.key),
            entry.value,
            reason:
                '${formType.code}.${entry.key} should be ${entry.value}',
          );
        }
      }
    });

    test('form-specific namespaces are isolated (WDO data does not bleed into '
        'Sinkhole)', () {
      final pd = buildFullPropertyData(
        enabledForms: {FormType.wdo, FormType.sinkholeInspection},
        formData: {
          FormType.wdo: {'species': 'drywood'},
          FormType.sinkholeInspection: {'floor_level': true},
        },
      );

      // WDO namespace has its key
      expect(pd.getFormValue<String>(FormType.wdo, 'species'), 'drywood');
      // Sinkhole does NOT have WDO's key
      expect(
          pd.getFormValue(FormType.sinkholeInspection, 'species'), isNull);
      // Sinkhole has its own key
      expect(
          pd.getFormValue<bool>(FormType.sinkholeInspection, 'floor_level'),
          true);
      // WDO does NOT have Sinkhole's key
      expect(pd.getFormValue(FormType.wdo, 'floor_level'), isNull);
    });

    test('branchContext prefixes form-specific data correctly', () {
      final pd = buildFullPropertyData(
        enabledForms: {FormType.wdo, FormType.moldAssessment},
        formData: {
          FormType.wdo: {'species': 'drywood'},
          FormType.moldAssessment: {'moisture_reading': 60},
        },
      );

      final ctx = pd.branchContext;
      expect(ctx['wdo.species'], 'drywood');
      expect(ctx['mold.moisture_reading'], 60);
      // Unprefixed keys should not exist
      expect(ctx.containsKey('species'), isFalse);
      expect(ctx.containsKey('moisture_reading'), isFalse);
    });
  });

  group('Shared fields accessibility from any form context', () {
    test('universal fields available regardless of enabled forms', () {
      final pd = buildFullPropertyData(
        enabledForms: {FormType.wdo},
      );

      expect(pd.clientName, 'Client Jones');
      expect(pd.propertyAddress, '100 Test St');
      expect(pd.inspectionDate, DateTime(2026, 1, 15));
      expect(pd.yearBuilt, 1995);
    });

    test('shared yearBuilt accessible via backward compat getter', () {
      final pd = buildFullPropertyData(
        shared: const SharedBuildingSystemFields(yearBuilt: 2005),
      );
      expect(pd.yearBuilt, 2005);
    });

    test('shared yearBuilt returns 0 when null (backward compat)', () {
      final pd = buildFullPropertyData(
        shared: const SharedBuildingSystemFields(),
      );
      expect(pd.yearBuilt, 0);
    });
  });

  group('Empty PropertyData edge case', () {
    test('empty PropertyData → toJson → fromJson round-trip', () {
      final pd = PropertyData(
        inspectionId: 'empty-001',
        organizationId: 'org-empty',
        userId: 'user-empty',
        enabledForms: const <FormType>{},
        universal: UniversalPropertyFields(
          propertyAddress: '',
          inspectionDate: DateTime(2026, 1, 1),
          inspectorName: '',
          inspectorCompany: '',
          inspectorLicenseNumber: '',
          clientName: '',
        ),
      );

      final json = pd.toJson();
      final restored = PropertyData.fromJson(json);

      expect(restored.inspectionId, 'empty-001');
      expect(restored.enabledForms, isEmpty);
      expect(restored.formData, isEmpty);
      expect(restored.capturedCategories, isEmpty);
      expect(restored.capturedPhotoPaths, isEmpty);
      expect(restored.capturedEvidencePaths, isEmpty);
      expect(restored.shared.yearBuilt, isNull);
      expect(restored.universal.propertyAddress, '');
      expect(restored.universal.clientName, '');
    });

    test('PropertyData with empty enabledForms is valid', () {
      final pd = buildFullPropertyData(enabledForms: const <FormType>{});
      expect(pd.enabledForms, isEmpty);
      expect(pd.branchContext, isNotEmpty); // still has universal/shared
    });
  });

  group('SharedBuildingSystemFields comprehensive round-trip', () {
    test('all fields populated survive toJson → fromJson', () {
      final shared = SharedBuildingSystemFields(
        yearBuilt: 1985,
        policyNumber: 'POL-12345',
        inspectorPhone: '555-INSPECT',
        signatureDate: DateTime(2026, 3, 1),
        roofCoveringMaterial: 'Asphalt Shingle',
        roofAge: 12,
        roofCondition: RatingScale.marginal,
        electricalPanelType: 'Circuit Breaker',
        electricalPanelAmps: 200,
        plumbingPipeMaterial: 'Copper',
        waterHeaterType: 'Electric Tank',
        hvacType: 'Central Air',
        foundationCracks: false,
      );

      final json = shared.toJson();
      final restored = SharedBuildingSystemFields.fromJson(json);

      expect(restored.yearBuilt, 1985);
      expect(restored.policyNumber, 'POL-12345');
      expect(restored.inspectorPhone, '555-INSPECT');
      expect(restored.signatureDate, DateTime(2026, 3, 1));
      expect(restored.roofCoveringMaterial, 'Asphalt Shingle');
      expect(restored.roofAge, 12);
      expect(restored.roofCondition, RatingScale.marginal);
      expect(restored.electricalPanelType, 'Circuit Breaker');
      expect(restored.electricalPanelAmps, 200);
      expect(restored.plumbingPipeMaterial, 'Copper');
      expect(restored.waterHeaterType, 'Electric Tank');
      expect(restored.hvacType, 'Central Air');
      expect(restored.foundationCracks, false);
    });

    test('empty SharedBuildingSystemFields toJson produces empty map', () {
      const shared = SharedBuildingSystemFields();
      final json = shared.toJson();
      expect(json, isEmpty);
    });

    test('SharedBuildingSystemFields equality', () {
      const a = SharedBuildingSystemFields(yearBuilt: 2000, roofAge: 5);
      const b = SharedBuildingSystemFields(yearBuilt: 2000, roofAge: 5);
      const c = SharedBuildingSystemFields(yearBuilt: 2000, roofAge: 10);

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('PropertyData combined media + all form data round-trip', () {
    test('all 7 form namespaces with media and shared fields round-trip', () {
      final allFormData = <FormType, Map<String, dynamic>>{
        FormType.fourPoint: {'hazard_present': true},
        FormType.roofCondition: {'slope': 'hip'},
        FormType.windMitigation: {'deck_type': 'plywood'},
        FormType.wdo: {'species': 'subterranean'},
        FormType.sinkholeInspection: {'floor_level': true},
        FormType.moldAssessment: {'moisture_reading': 45.2},
        FormType.generalInspection: {'overall_condition': 'fair'},
      };

      final allCategories = {
        RequiredPhotoCategory.exteriorFront,
        RequiredPhotoCategory.roofSlopeMain,
        RequiredPhotoCategory.windRoofDeck,
        RequiredPhotoCategory.wdoPropertyExterior,
        RequiredPhotoCategory.sinkholeFrontElevation,
        RequiredPhotoCategory.moldMoistureReading,
        RequiredPhotoCategory.generalFrontElevation,
      };

      final allPhotoPaths = <RequiredPhotoCategory, String>{
        for (final cat in allCategories) cat: '/photos/${cat.name}.jpg',
      };

      final allEvidencePaths = <String, List<String>>{
        'photo:exterior_front': ['/photos/exteriorFront.jpg'],
        'photo:wdo_property_exterior': ['/photos/wdoPropertyExterior.jpg'],
      };

      final pd = PropertyData(
        inspectionId: 'combo-001',
        organizationId: 'org-combo',
        userId: 'user-combo',
        clientEmail: 'combo@test.com',
        clientPhone: '555-COMBO',
        enabledForms: FormType.values.toSet(),
        wizardSnapshot: const WizardProgressSnapshot(
          lastStepIndex: 5,
          completion: {'photo:exterior_front': true, 'photo:wind_roof_deck': true},
          branchContext: {'hazard_present': true, 'wdo_visible_evidence': true},
          status: WizardProgressStatus.inProgress,
        ),
        universal: UniversalPropertyFields(
          propertyAddress: '777 Combo St',
          inspectionDate: DateTime(2026, 6, 15),
          inspectorName: 'Combo Inspector',
          inspectorCompany: 'Combo LLC',
          inspectorLicenseNumber: 'COMBO-LIC',
          clientName: 'Combo Client',
          inspectorSignaturePath: '/sigs/combo.png',
          comments: 'Test combo round-trip',
        ),
        shared: SharedBuildingSystemFields(
          yearBuilt: 1998,
          roofAge: 8,
          roofCondition: RatingScale.satisfactory,
          electricalPanelAmps: 150,
          foundationCracks: false,
        ),
        formData: allFormData,
        capturedCategories: allCategories,
        capturedPhotoPaths: allPhotoPaths,
        capturedEvidencePaths: allEvidencePaths,
      );

      final json = pd.toJson();
      final restored = PropertyData.fromJson(json);

      // Identity
      expect(restored.inspectionId, 'combo-001');
      expect(restored.clientEmail, 'combo@test.com');

      // Universal
      expect(restored.universal.inspectorSignaturePath, '/sigs/combo.png');
      expect(restored.universal.comments, 'Test combo round-trip');
      expect(restored.universal.clientName, 'Combo Client');

      // Shared
      expect(restored.shared.yearBuilt, 1998);
      expect(restored.shared.roofAge, 8);
      expect(restored.shared.roofCondition, RatingScale.satisfactory);
      expect(restored.shared.electricalPanelAmps, 150);
      expect(restored.shared.foundationCracks, false);

      // Wizard
      expect(restored.wizardSnapshot.lastStepIndex, 5);
      expect(restored.wizardSnapshot.completion['photo:exterior_front'], true);
      expect(restored.wizardSnapshot.branchContext['hazard_present'], true);

      // All 7 form namespaces
      expect(restored.enabledForms.length, 7);
      expect(restored.getFormValue<bool>(FormType.fourPoint, 'hazard_present'), true);
      expect(restored.getFormValue<String>(FormType.wdo, 'species'), 'subterranean');
      expect(restored.getFormValue<bool>(FormType.sinkholeInspection, 'floor_level'), true);
      expect(restored.getFormValue<String>(FormType.generalInspection, 'overall_condition'), 'fair');

      // Media
      for (final cat in allCategories) {
        expect(restored.capturedCategories, contains(cat),
            reason: '${cat.name} should survive round-trip');
        expect(restored.capturedPhotoPaths[cat], '/photos/${cat.name}.jpg');
      }
      expect(restored.capturedEvidencePaths['photo:exterior_front'],
          ['/photos/exteriorFront.jpg']);
    });
  });

  group('PropertyData setFormValues batch update', () {
    test('setFormValues updates multiple keys atomically', () {
      var pd = buildFullPropertyData(
        enabledForms: {FormType.fourPoint},
      );

      pd = pd.setFormValues(FormType.fourPoint, {
        'hazard_present': true,
        'notes': 'test notes',
        'score': 85,
      });

      expect(pd.getFormValue<bool>(FormType.fourPoint, 'hazard_present'), true);
      expect(pd.getFormValue<String>(FormType.fourPoint, 'notes'), 'test notes');
      expect(pd.getFormValue<int>(FormType.fourPoint, 'score'), 85);
    });

    test('setFormValues preserves existing keys not in update', () {
      var pd = buildFullPropertyData(
        enabledForms: {FormType.fourPoint},
        formData: {
          FormType.fourPoint: {'existing_key': 'keep_me'},
        },
      );

      pd = pd.setFormValues(FormType.fourPoint, {'new_key': 'added'});

      expect(
          pd.getFormValue<String>(FormType.fourPoint, 'existing_key'), 'keep_me');
      expect(pd.getFormValue<String>(FormType.fourPoint, 'new_key'), 'added');
    });
  });

  group('PropertyData media state round-trip', () {
    test('all photo categories survive round-trip', () {
      final categories = {
        RequiredPhotoCategory.exteriorFront,
        RequiredPhotoCategory.windRoofDeck,
        RequiredPhotoCategory.wdoPropertyExterior,
        RequiredPhotoCategory.sinkholeFrontElevation,
        RequiredPhotoCategory.moldMoistureReading,
        RequiredPhotoCategory.generalFrontElevation,
      };

      final photoPaths = <RequiredPhotoCategory, String>{
        for (final cat in categories) cat: '/photos/${cat.name}.jpg',
      };

      final pd = PropertyData(
        inspectionId: 'media-001',
        organizationId: 'org-001',
        userId: 'user-001',
        enabledForms: FormType.values.toSet(),
        universal: UniversalPropertyFields(
          propertyAddress: '999 Photo St',
          inspectionDate: DateTime(2026, 3, 1),
          inspectorName: '',
          inspectorCompany: '',
          inspectorLicenseNumber: '',
          clientName: '',
        ),
        capturedCategories: categories,
        capturedPhotoPaths: photoPaths,
      );

      final json = pd.toJson();
      final restored = PropertyData.fromJson(json);

      for (final cat in categories) {
        expect(restored.capturedCategories, contains(cat),
            reason: '${cat.name} should be in capturedCategories');
        expect(restored.capturedPhotoPaths[cat], '/photos/${cat.name}.jpg',
            reason: '${cat.name} photo path should match');
      }
    });
  });
}
