import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/inspection_draft.dart';
import 'package:inspectobot/features/inspection/domain/inspection_wizard_state.dart';
import 'package:inspectobot/features/inspection/domain/property_data.dart';
import 'package:inspectobot/features/inspection/domain/required_photo_category.dart';

/// Migration validation tests ensuring InspectionDraft and PropertyData
/// backward compatibility across the Phase 3-9 data model expansion.
void main() {
  /// Builds a "legacy-style" InspectionDraft using only the original 3 form
  /// types and pre-Phase 3 fields (no formData, no propertyData).
  InspectionDraft buildLegacyDraft({
    Set<FormType>? enabledForms,
    WizardProgressSnapshot? wizardSnapshot,
  }) {
    return InspectionDraft(
      inspectionId: 'legacy-001',
      organizationId: 'org-legacy',
      userId: 'user-legacy',
      clientName: 'Bob Legacy',
      clientEmail: 'bob@legacy.com',
      clientPhone: '555-1234',
      propertyAddress: '123 Main St',
      inspectionDate: DateTime(2025, 6, 15),
      yearBuilt: 1985,
      enabledForms: enabledForms ??
          {FormType.fourPoint, FormType.roofCondition, FormType.windMitigation},
      wizardSnapshot: wizardSnapshot,
    );
  }

  group('InspectionDraft backward compatibility', () {
    test('constructs successfully with original 3 form types only', () {
      final draft = buildLegacyDraft();

      expect(draft.inspectionId, 'legacy-001');
      expect(draft.organizationId, 'org-legacy');
      expect(draft.userId, 'user-legacy');
      expect(draft.clientName, 'Bob Legacy');
      expect(draft.clientEmail, 'bob@legacy.com');
      expect(draft.clientPhone, '555-1234');
      expect(draft.propertyAddress, '123 Main St');
      expect(draft.inspectionDate, DateTime(2025, 6, 15));
      expect(draft.yearBuilt, 1985);
      expect(draft.enabledForms, {
        FormType.fourPoint,
        FormType.roofCondition,
        FormType.windMitigation,
      });
    });

    test('formData defaults to empty map when not provided', () {
      final draft = buildLegacyDraft();
      expect(draft.formData, isEmpty);
    });

    test('propertyData defaults to null when not provided', () {
      final draft = buildLegacyDraft();
      expect(draft.propertyData, isNull);
    });

    test('wizardSnapshot defaults to empty when not provided', () {
      final draft = buildLegacyDraft();
      expect(draft.wizardSnapshot.lastStepIndex, 0);
      expect(draft.wizardSnapshot.completion, isEmpty);
      expect(draft.wizardSnapshot.branchContext, isEmpty);
      expect(
          draft.wizardSnapshot.status, WizardProgressStatus.inProgress);
    });

    test('initialStepIndex defaults to 0 when not provided', () {
      final draft = buildLegacyDraft();
      expect(draft.initialStepIndex, 0);
    });

    test('mutable media collections are initially empty', () {
      final draft = buildLegacyDraft();
      expect(draft.capturedCategories, isEmpty);
      expect(draft.capturedPhotoPaths, isEmpty);
      expect(draft.capturedEvidencePaths, isEmpty);
    });

    test('media collections can be populated after construction', () {
      final draft = buildLegacyDraft();
      draft.capturedCategories.add(RequiredPhotoCategory.exteriorFront);
      draft.capturedPhotoPaths[RequiredPhotoCategory.exteriorFront] =
          '/path/front.jpg';
      draft.capturedEvidencePaths['photo:exterior_front'] = [
        '/path/front.jpg',
      ];

      expect(draft.capturedCategories,
          contains(RequiredPhotoCategory.exteriorFront));
      expect(
        draft.capturedPhotoPaths[RequiredPhotoCategory.exteriorFront],
        '/path/front.jpg',
      );
      expect(
        draft.capturedEvidencePaths['photo:exterior_front'],
        ['/path/front.jpg'],
      );
    });

    test('enabledForms with single original type works', () {
      final draft = buildLegacyDraft(
          enabledForms: {FormType.fourPoint});
      expect(draft.enabledForms, {FormType.fourPoint});
    });

    test('enabledForms with all 7 types works alongside original 3', () {
      final draft = buildLegacyDraft(enabledForms: FormType.values.toSet());
      expect(draft.enabledForms.length, 7);
      expect(draft.enabledForms, contains(FormType.fourPoint));
      expect(draft.enabledForms, contains(FormType.roofCondition));
      expect(draft.enabledForms, contains(FormType.windMitigation));
      expect(draft.enabledForms, contains(FormType.wdo));
      expect(draft.enabledForms, contains(FormType.sinkholeInspection));
      expect(draft.enabledForms, contains(FormType.moldAssessment));
      expect(draft.enabledForms, contains(FormType.generalInspection));
    });
  });

  group('InspectionDraft → PropertyData migration path', () {
    test('legacy draft converts to PropertyData without errors', () {
      final draft = buildLegacyDraft();
      final pd = PropertyData.fromInspectionDraft(draft);

      expect(pd.inspectionId, 'legacy-001');
      expect(pd.universal.clientName, 'Bob Legacy');
      expect(pd.universal.propertyAddress, '123 Main St');
      expect(pd.universal.inspectionDate, DateTime(2025, 6, 15));
      expect(pd.shared.yearBuilt, 1985);
      expect(pd.enabledForms, {
        FormType.fourPoint,
        FormType.roofCondition,
        FormType.windMitigation,
      });
    });

    test('legacy draft media state transfers to PropertyData', () {
      final draft = buildLegacyDraft();
      draft.capturedCategories.add(RequiredPhotoCategory.roofSlopeMain);
      draft.capturedPhotoPaths[RequiredPhotoCategory.roofSlopeMain] =
          '/path/roof.jpg';
      draft.capturedEvidencePaths['photo:roof_slope_main'] = [
        '/path/roof.jpg',
      ];

      final pd = PropertyData.fromInspectionDraft(draft);

      expect(pd.capturedCategories,
          contains(RequiredPhotoCategory.roofSlopeMain));
      expect(
        pd.capturedPhotoPaths[RequiredPhotoCategory.roofSlopeMain],
        '/path/roof.jpg',
      );
      expect(
        pd.capturedEvidencePaths['photo:roof_slope_main'],
        ['/path/roof.jpg'],
      );
    });

    test('legacy draft with formData transfers to PropertyData', () {
      final draft = InspectionDraft(
        inspectionId: 'legacy-002',
        organizationId: 'org-legacy',
        userId: 'user-legacy',
        clientName: 'Carol',
        clientEmail: 'carol@test.com',
        clientPhone: '555-0001',
        propertyAddress: '456 Oak Ave',
        inspectionDate: DateTime(2025, 7, 1),
        yearBuilt: 2000,
        enabledForms: {FormType.fourPoint},
        formData: {
          FormType.fourPoint: {'hazard_present': true, 'notes': 'test'},
        },
      );

      final pd = PropertyData.fromInspectionDraft(draft);
      expect(pd.getFormValue<bool>(FormType.fourPoint, 'hazard_present'), true);
      expect(pd.getFormValue<String>(FormType.fourPoint, 'notes'), 'test');
    });

    test('PropertyData round-trip preserves legacy draft fields', () {
      final draft = buildLegacyDraft();
      draft.capturedCategories.add(RequiredPhotoCategory.electricalPanelOpen);
      draft.capturedPhotoPaths[RequiredPhotoCategory.electricalPanelOpen] =
          '/path/panel.jpg';

      final pd = PropertyData.fromInspectionDraft(draft);
      final json = pd.toJson();
      final restored = PropertyData.fromJson(json);

      expect(restored.inspectionId, 'legacy-001');
      expect(restored.universal.clientName, 'Bob Legacy');
      expect(restored.universal.propertyAddress, '123 Main St');
      expect(restored.universal.inspectionDate, DateTime(2025, 6, 15));
      expect(restored.shared.yearBuilt, 1985);
      expect(restored.enabledForms, {
        FormType.fourPoint,
        FormType.roofCondition,
        FormType.windMitigation,
      });
      expect(restored.capturedCategories,
          contains(RequiredPhotoCategory.electricalPanelOpen));
      expect(
        restored.capturedPhotoPaths[RequiredPhotoCategory.electricalPanelOpen],
        '/path/panel.jpg',
      );
    });

    test('PropertyData → InspectionDraft reverse conversion preserves fields',
        () {
      final draft = buildLegacyDraft();
      final pd = PropertyData.fromInspectionDraft(draft);
      final restoredDraft = pd.toInspectionDraft();

      expect(restoredDraft.inspectionId, 'legacy-001');
      expect(restoredDraft.clientName, 'Bob Legacy');
      expect(restoredDraft.propertyAddress, '123 Main St');
      expect(restoredDraft.inspectionDate, DateTime(2025, 6, 15));
      expect(restoredDraft.yearBuilt, 1985);
      expect(restoredDraft.enabledForms, {
        FormType.fourPoint,
        FormType.roofCondition,
        FormType.windMitigation,
      });
    });

    test('full round-trip: Draft → PropertyData → JSON → PropertyData → Draft',
        () {
      final draft = buildLegacyDraft();
      draft.capturedCategories.add(RequiredPhotoCategory.hvacDataPlate);

      final pd1 = PropertyData.fromInspectionDraft(draft);
      final json = pd1.toJson();
      final pd2 = PropertyData.fromJson(json);
      final restoredDraft = pd2.toInspectionDraft();

      expect(restoredDraft.inspectionId, draft.inspectionId);
      expect(restoredDraft.clientName, draft.clientName);
      expect(restoredDraft.propertyAddress, draft.propertyAddress);
      expect(restoredDraft.yearBuilt, draft.yearBuilt);
      expect(restoredDraft.enabledForms, draft.enabledForms);
      expect(restoredDraft.capturedCategories,
          contains(RequiredPhotoCategory.hvacDataPlate));
    });
  });

  group('PropertyData fromJson with legacy-shaped JSON', () {
    test('missing optional fields default gracefully', () {
      // Minimal valid PropertyData JSON — simulating a legacy payload missing
      // many newer fields.
      final legacyJson = <String, dynamic>{
        'inspection_id': 'old-001',
        'organization_id': 'org-old',
        'user_id': 'user-old',
        'enabled_forms': ['four_point'],
        'universal': {
          'property_address': '789 Elm St',
          'inspection_date': '2025-01-01T00:00:00.000',
          'inspector_name': '',
          'inspector_company': '',
          'inspector_license_number': '',
          'client_name': 'Legacy Client',
        },
        'schema_version': 1,
      };

      final pd = PropertyData.fromJson(legacyJson);

      expect(pd.inspectionId, 'old-001');
      expect(pd.clientEmail, ''); // defaults to ''
      expect(pd.clientPhone, ''); // defaults to ''
      expect(pd.wizardSnapshot.lastStepIndex, 0);
      expect(pd.wizardSnapshot.completion, isEmpty);
      expect(pd.initialStepIndex, 0);
      expect(pd.formData, isEmpty);
      expect(pd.capturedCategories, isEmpty);
      expect(pd.capturedPhotoPaths, isEmpty);
      expect(pd.capturedEvidencePaths, isEmpty);
      expect(pd.shared.yearBuilt, isNull); // SharedBuildingSystemFields default
    });

    test('missing wizard_snapshot defaults to empty', () {
      final json = <String, dynamic>{
        'inspection_id': 'old-002',
        'organization_id': 'org-old',
        'user_id': 'user-old',
        'enabled_forms': ['four_point', 'roof_condition'],
        'universal': {
          'property_address': '100 Pine Rd',
          'inspection_date': '2025-02-01T00:00:00.000',
          'inspector_name': 'Joe',
          'inspector_company': 'Acme',
          'inspector_license_number': 'LIC-001',
          'client_name': 'Jane',
        },
        'schema_version': 1,
      };

      final pd = PropertyData.fromJson(json);
      expect(pd.wizardSnapshot.lastStepIndex, 0);
      expect(pd.wizardSnapshot.status, WizardProgressStatus.inProgress);
    });

    test('missing shared field defaults to empty SharedBuildingSystemFields',
        () {
      final json = <String, dynamic>{
        'inspection_id': 'old-003',
        'organization_id': 'org-old',
        'user_id': 'user-old',
        'enabled_forms': <String>[],
        'universal': {
          'property_address': '200 Birch Ln',
          'inspection_date': '2025-03-01T00:00:00.000',
          'inspector_name': '',
          'inspector_company': '',
          'inspector_license_number': '',
          'client_name': '',
        },
        'schema_version': 1,
      };

      final pd = PropertyData.fromJson(json);
      expect(pd.shared.yearBuilt, isNull);
      expect(pd.shared.roofAge, isNull);
      expect(pd.shared.electricalPanelType, isNull);
    });

    test('unknown form codes in enabled_forms are gracefully skipped', () {
      final json = <String, dynamic>{
        'inspection_id': 'old-004',
        'organization_id': 'org-old',
        'user_id': 'user-old',
        'enabled_forms': ['four_point', 'future_form_2030', 'roof_condition'],
        'universal': {
          'property_address': '300 Cedar Dr',
          'inspection_date': '2025-04-01T00:00:00.000',
          'inspector_name': '',
          'inspector_company': '',
          'inspector_license_number': '',
          'client_name': '',
        },
        'schema_version': 1,
      };

      final pd = PropertyData.fromJson(json);
      expect(pd.enabledForms, {FormType.fourPoint, FormType.roofCondition});
    });

    test('legacy JSON with only original 3 form types deserializes correctly', () {
      // Simulates a JSON payload saved before Phase 3 added new form types.
      // Has only the 3 original forms, no formData map, no WDO/Sinkhole/Mold/General.
      final legacyJson = <String, dynamic>{
        'inspection_id': 'pre-phase3-001',
        'organization_id': 'org-pre',
        'user_id': 'user-pre',
        'client_email': 'pre@test.com',
        'client_phone': '555-PRE',
        'enabled_forms': ['four_point', 'roof_condition', 'wind_mitigation'],
        'universal': {
          'property_address': '500 Legacy Blvd',
          'inspection_date': '2024-12-01T00:00:00.000',
          'inspector_name': 'Legacy Inspector',
          'inspector_company': 'Legacy Co',
          'inspector_license_number': 'LIC-LEGACY',
          'client_name': 'Legacy Owner',
        },
        'shared': {'year_built': 1978},
        'schema_version': 1,
      };

      final pd = PropertyData.fromJson(legacyJson);

      expect(pd.inspectionId, 'pre-phase3-001');
      expect(pd.clientEmail, 'pre@test.com');
      expect(pd.enabledForms, {
        FormType.fourPoint,
        FormType.roofCondition,
        FormType.windMitigation,
      });
      expect(pd.universal.clientName, 'Legacy Owner');
      expect(pd.universal.propertyAddress, '500 Legacy Blvd');
      expect(pd.shared.yearBuilt, 1978);
      expect(pd.formData, isEmpty);
      expect(pd.capturedCategories, isEmpty);
      expect(pd.capturedPhotoPaths, isEmpty);
      expect(pd.capturedEvidencePaths, isEmpty);
    });

    test('legacy JSON round-trip: fromJson → toJson → fromJson preserves all data', () {
      final legacyJson = <String, dynamic>{
        'inspection_id': 'roundtrip-001',
        'organization_id': 'org-rt',
        'user_id': 'user-rt',
        'client_email': 'rt@test.com',
        'client_phone': '555-RT',
        'enabled_forms': ['four_point', 'wind_mitigation'],
        'wizard_snapshot': {
          'last_step_index': 2,
          'completion': {
            'photo:exterior_front': true,
            'photo:wind_roof_deck': true,
          },
          'branch_context': {'hazard_present': false},
          'status': 'inProgress',
        },
        'universal': {
          'property_address': '600 Roundtrip Ave',
          'inspection_date': '2025-08-01T00:00:00.000',
          'inspector_name': 'RT Inspector',
          'inspector_company': 'RT Co',
          'inspector_license_number': 'LIC-RT',
          'client_name': 'RT Owner',
        },
        'shared': {'year_built': 2001, 'roof_age': 10},
        'captured_categories': ['exteriorFront'],
        'captured_photo_paths': {'exteriorFront': '/photos/front.jpg'},
        'captured_evidence_paths': {
          'photo:exterior_front': ['/photos/front.jpg'],
        },
        'schema_version': 1,
      };

      final pd1 = PropertyData.fromJson(legacyJson);
      final json2 = pd1.toJson();
      final pd2 = PropertyData.fromJson(json2);

      expect(pd2.inspectionId, 'roundtrip-001');
      expect(pd2.enabledForms, {FormType.fourPoint, FormType.windMitigation});
      expect(pd2.wizardSnapshot.lastStepIndex, 2);
      expect(pd2.wizardSnapshot.completion['photo:exterior_front'], true);
      expect(pd2.wizardSnapshot.completion['photo:wind_roof_deck'], true);
      expect(pd2.shared.yearBuilt, 2001);
      expect(pd2.shared.roofAge, 10);
      expect(pd2.capturedCategories, contains(RequiredPhotoCategory.exteriorFront));
      expect(pd2.capturedPhotoPaths[RequiredPhotoCategory.exteriorFront],
          '/photos/front.jpg');
      expect(pd2.capturedEvidencePaths['photo:exterior_front'],
          ['/photos/front.jpg']);
    });

    test('unknown form codes in form_data are gracefully skipped', () {
      final json = <String, dynamic>{
        'inspection_id': 'old-005',
        'organization_id': 'org-old',
        'user_id': 'user-old',
        'enabled_forms': ['wind_mitigation'],
        'form_data': {
          'wind_mitigation': {'key': 'val'},
          'unknown_form': {'key2': 'val2'},
        },
        'universal': {
          'property_address': '400 Maple Way',
          'inspection_date': '2025-05-01T00:00:00.000',
          'inspector_name': '',
          'inspector_company': '',
          'inspector_license_number': '',
          'client_name': '',
        },
        'schema_version': 1,
      };

      final pd = PropertyData.fromJson(json);
      expect(pd.formData.length, 1);
      expect(pd.formData.containsKey(FormType.windMitigation), isTrue);
      expect(pd.getFormValue(FormType.windMitigation, 'key'), 'val');
    });
  });

  group('WizardProgressSnapshot with legacy step definitions', () {
    test('legacy wizard snapshot with original step keys loads correctly', () {
      final snapshot = WizardProgressSnapshot(
        lastStepIndex: 1,
        completion: {
          'photo:exterior_front': true,
          'photo:exterior_rear': true,
          'photo:roof_slope_main': false,
        },
        branchContext: {'hazard_present': false},
        status: WizardProgressStatus.inProgress,
      );

      expect(snapshot.lastStepIndex, 1);
      expect(snapshot.completion['photo:exterior_front'], true);
      expect(snapshot.completion['photo:exterior_rear'], true);
      expect(snapshot.completion['photo:roof_slope_main'], false);
      expect(snapshot.branchContext['hazard_present'], false);
    });

    test('InspectionWizardState builds steps for original 3 form types', () {
      final snapshot = WizardProgressSnapshot.empty;
      final state = InspectionWizardState(
        enabledForms: {
          FormType.fourPoint,
          FormType.roofCondition,
          FormType.windMitigation,
        },
        snapshot: snapshot,
      );

      // Overview + 3 form steps = 4
      expect(state.steps.length, 4);
      expect(state.steps[0].id, 'inspection_overview');
      expect(state.steps[1].id, 'form_four_point');
      expect(state.steps[2].id, 'form_roof_condition');
      expect(state.steps[3].id, 'form_wind_mitigation');
    });

    test('InspectionWizardState builds steps for all 7 form types', () {
      final snapshot = WizardProgressSnapshot.empty;
      final state = InspectionWizardState(
        enabledForms: FormType.values.toSet(),
        snapshot: snapshot,
      );

      // Overview + 7 form steps = 8
      expect(state.steps.length, 8);
      expect(state.steps[0].id, 'inspection_overview');

      final formStepIds = state.steps.skip(1).map((s) => s.id).toSet();
      expect(formStepIds, contains('form_four_point'));
      expect(formStepIds, contains('form_roof_condition'));
      expect(formStepIds, contains('form_wind_mitigation'));
      expect(formStepIds, contains('form_wdo'));
      expect(formStepIds, contains('form_sinkhole_inspection'));
      expect(formStepIds, contains('form_mold_assessment'));
      expect(formStepIds, contains('form_general_inspection'));
    });

    test('InspectionDraft with formData for new form types works', () {
      final draft = InspectionDraft(
        inspectionId: 'new-forms-001',
        organizationId: 'org-new',
        userId: 'user-new',
        clientName: 'New Client',
        clientEmail: 'new@test.com',
        clientPhone: '555-NEW',
        propertyAddress: '999 New Rd',
        inspectionDate: DateTime(2026, 2, 1),
        yearBuilt: 2010,
        enabledForms: {
          FormType.fourPoint,
          FormType.wdo,
          FormType.sinkholeInspection,
          FormType.moldAssessment,
          FormType.generalInspection,
        },
        formData: {
          FormType.fourPoint: {'hazard_present': false},
          FormType.wdo: {'species': 'subterranean'},
          FormType.moldAssessment: {'moisture_level': 55},
          FormType.generalInspection: {'overall': 'fair'},
        },
      );

      expect(draft.enabledForms.length, 5);
      expect(draft.formData[FormType.wdo]!['species'], 'subterranean');
      expect(draft.formData[FormType.moldAssessment]!['moisture_level'], 55);

      // Convert to PropertyData and verify data survives
      final pd = PropertyData.fromInspectionDraft(draft);
      expect(pd.getFormValue<String>(FormType.wdo, 'species'), 'subterranean');
      expect(pd.getFormValue<int>(FormType.moldAssessment, 'moisture_level'), 55);
      expect(pd.getFormValue<String>(FormType.generalInspection, 'overall'), 'fair');
    });

    test('mixed old+new form types in single wizard session', () {
      final snapshot = WizardProgressSnapshot.empty;
      final state = InspectionWizardState(
        enabledForms: {
          FormType.fourPoint,
          FormType.wdo,
          FormType.moldAssessment,
        },
        snapshot: snapshot,
      );

      // Overview + 3 form steps = 4
      expect(state.steps.length, 4);
      final formStepIds = state.steps.skip(1).map((s) => s.id).toSet();
      expect(formStepIds, contains('form_four_point'));
      expect(formStepIds, contains('form_wdo'));
      expect(formStepIds, contains('form_mold_assessment'));
    });

    test('wizard snapshot serialized through PropertyData round-trip', () {
      final draft = buildLegacyDraft();
      var pd = PropertyData.fromInspectionDraft(draft);
      pd = pd.copyWith(
        wizardSnapshot: const WizardProgressSnapshot(
          lastStepIndex: 3,
          completion: {
            'photo:exterior_front': true,
            'photo:wind_roof_deck': true,
          },
          branchContext: {
            'hazard_present': true,
            'wind_roof_deck_document_required': false,
          },
          status: WizardProgressStatus.inProgress,
        ),
      );

      final json = pd.toJson();
      final restored = PropertyData.fromJson(json);

      expect(restored.wizardSnapshot.lastStepIndex, 3);
      expect(
          restored.wizardSnapshot.completion['photo:exterior_front'], true);
      expect(
          restored.wizardSnapshot.completion['photo:wind_roof_deck'], true);
      expect(restored.wizardSnapshot.branchContext['hazard_present'], true);
      expect(
        restored.wizardSnapshot
            .branchContext['wind_roof_deck_document_required'],
        false,
      );
    });
  });
}
