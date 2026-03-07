import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/inspection_draft.dart';
import 'package:inspectobot/features/inspection/domain/inspection_wizard_state.dart';
import 'package:inspectobot/features/inspection/domain/property_data.dart';
import 'package:inspectobot/features/inspection/domain/property_data_migrations.dart';
import 'package:inspectobot/features/inspection/domain/required_photo_category.dart';
import 'package:inspectobot/features/inspection/domain/shared_building_system_fields.dart';
import 'package:inspectobot/features/inspection/domain/rating_scale.dart';

void main() {
  group('PropertyData', () {
    InspectionDraft buildDraft() {
      return InspectionDraft(
        inspectionId: 'insp-001',
        organizationId: 'org-001',
        userId: 'user-001',
        clientName: 'Alice',
        clientEmail: 'alice@test.com',
        clientPhone: '555-0000',
        propertyAddress: '456 Oak Ave',
        inspectionDate: DateTime(2026, 3, 7),
        yearBuilt: 1990,
        enabledForms: {FormType.fourPoint},
      );
    }

    test('fromInspectionDraft maps scalar fields correctly', () {
      final draft = buildDraft();
      final pd = PropertyData.fromInspectionDraft(draft);

      expect(pd.inspectionId, 'insp-001');
      expect(pd.organizationId, 'org-001');
      expect(pd.userId, 'user-001');
      expect(pd.clientEmail, 'alice@test.com');
      expect(pd.clientPhone, '555-0000');
      expect(pd.universal.propertyAddress, '456 Oak Ave');
      expect(pd.universal.clientName, 'Alice');
      expect(pd.universal.inspectionDate, DateTime(2026, 3, 7));
      expect(pd.shared.yearBuilt, 1990);
      expect(pd.enabledForms, {FormType.fourPoint});
    });

    test('branchContext merges universal, shared, and form-specific fields', () {
      final draft = buildDraft();
      var pd = PropertyData.fromInspectionDraft(draft);
      pd = pd.setFormValue(FormType.fourPoint, 'hazard_present', true);

      final ctx = pd.branchContext;

      // Universal fields present
      expect(ctx['property_address'], '456 Oak Ave');
      expect(ctx['client_name'], 'Alice');

      // Shared fields present (yearBuilt is non-null)
      expect(ctx['year_built'], 1990);

      // Form-specific prefixed with "fourPoint."
      expect(ctx['fourPoint.hazard_present'], true);
    });

    test('getFormValue returns correct typed value', () {
      final draft = buildDraft();
      var pd = PropertyData.fromInspectionDraft(draft);
      pd = pd.setFormValue(FormType.fourPoint, 'rating', 'Good');

      expect(pd.getFormValue<String>(FormType.fourPoint, 'rating'), 'Good');
      expect(pd.getFormValue<String>(FormType.fourPoint, 'missing_key'), isNull);
    });

    test('setFormValue returns new instance (immutable)', () {
      final draft = buildDraft();
      final pd1 = PropertyData.fromInspectionDraft(draft);
      final pd2 = pd1.setFormValue(FormType.fourPoint, 'key', 'value');

      expect(identical(pd1, pd2), isFalse);
      expect(pd1.getFormValue(FormType.fourPoint, 'key'), isNull);
      expect(pd2.getFormValue(FormType.fourPoint, 'key'), 'value');
    });

    test('toJson -> fromJson round-trip', () {
      final draft = buildDraft();
      var pd = PropertyData.fromInspectionDraft(draft);
      pd = pd.setFormValue(FormType.fourPoint, 'test_field', 42);

      final json = pd.toJson();
      final restored = PropertyData.fromJson(json);

      expect(restored.inspectionId, pd.inspectionId);
      expect(restored.organizationId, pd.organizationId);
      expect(restored.userId, pd.userId);
      expect(restored.clientEmail, pd.clientEmail);
      expect(restored.universal.propertyAddress, pd.universal.propertyAddress);
      expect(restored.shared.yearBuilt, pd.shared.yearBuilt);
      expect(restored.enabledForms, pd.enabledForms);
      expect(restored.getFormValue(FormType.fourPoint, 'test_field'), 42);
    });

    test('toJson includes schema_version', () {
      final draft = buildDraft();
      final pd = PropertyData.fromInspectionDraft(draft);
      final json = pd.toJson();

      expect(json['schema_version'], PropertyDataMigrations.currentVersion);
    });

    test('toJson -> fromJson round-trip preserves all fields including media state', () {
      final draft = buildDraft();
      draft.capturedCategories.add(RequiredPhotoCategory.exteriorFront);
      draft.capturedPhotoPaths[RequiredPhotoCategory.exteriorFront] =
          '/photos/front.jpg';
      draft.capturedEvidencePaths['photo:exterior_front'] = [
        '/photos/front.jpg',
      ];

      var pd = PropertyData.fromInspectionDraft(draft);
      pd = pd.copyWith(
        wizardSnapshot: const WizardProgressSnapshot(
          lastStepIndex: 2,
          completion: {'step_a': true},
          branchContext: {'hazard_present': true},
          status: WizardProgressStatus.inProgress,
        ),
        shared: SharedBuildingSystemFields(
          yearBuilt: 1990,
          roofCondition: RatingScale.satisfactory,
          roofAge: 15,
        ),
      );
      pd = pd.setFormValue(FormType.fourPoint, 'rating', 'Good');

      final json = pd.toJson();
      final restored = PropertyData.fromJson(json);

      expect(restored.clientPhone, pd.clientPhone);
      expect(restored.wizardSnapshot.lastStepIndex, 2);
      expect(restored.wizardSnapshot.completion, {'step_a': true});
      expect(restored.wizardSnapshot.branchContext['hazard_present'], true);
      expect(restored.shared.roofCondition, RatingScale.satisfactory);
      expect(restored.shared.roofAge, 15);
      expect(restored.capturedCategories,
          contains(RequiredPhotoCategory.exteriorFront));
      expect(restored.capturedPhotoPaths[RequiredPhotoCategory.exteriorFront],
          '/photos/front.jpg');
      expect(restored.capturedEvidencePaths['photo:exterior_front'],
          ['/photos/front.jpg']);
      expect(
          restored.getFormValue(FormType.fourPoint, 'rating'), 'Good');
    });

    test('toInspectionDraft preserves expected fields and media state', () {
      final draft = buildDraft();
      draft.capturedCategories.add(RequiredPhotoCategory.exteriorFront);
      draft.capturedPhotoPaths[RequiredPhotoCategory.exteriorFront] =
          '/photos/front.jpg';
      draft.capturedEvidencePaths['photo:exterior_front'] = [
        '/photos/front.jpg',
      ];

      final pd = PropertyData.fromInspectionDraft(draft);
      final restored = pd.toInspectionDraft();

      expect(restored.inspectionId, 'insp-001');
      expect(restored.clientName, 'Alice');
      expect(restored.propertyAddress, '456 Oak Ave');
      expect(restored.yearBuilt, 1990);
      expect(restored.capturedCategories,
          contains(RequiredPhotoCategory.exteriorFront));
      expect(restored.capturedPhotoPaths[RequiredPhotoCategory.exteriorFront],
          '/photos/front.jpg');
      expect(restored.capturedEvidencePaths['photo:exterior_front'],
          ['/photos/front.jpg']);
    });

    test('copyWith creates independent collection copies', () {
      final draft = buildDraft();
      var pd1 = PropertyData.fromInspectionDraft(draft);
      pd1 = pd1.setFormValue(FormType.fourPoint, 'key', 'original');

      final pd2 = pd1.copyWith(clientEmail: 'new@test.com');

      // Mutate pd1's formData inner map via a new setFormValue
      final pd1b = pd1.setFormValue(FormType.fourPoint, 'key', 'mutated');

      // pd2 should still have the original value
      expect(pd2.getFormValue(FormType.fourPoint, 'key'), 'original');
      expect(pd1b.getFormValue(FormType.fourPoint, 'key'), 'mutated');
    });

    test('fromJson gracefully skips unknown form codes', () {
      final draft = buildDraft();
      final pd = PropertyData.fromInspectionDraft(draft);
      final json = pd.toJson();

      // Inject unknown form code into enabled_forms and form_data
      (json['enabled_forms'] as List).add('unknown_future_form');
      (json['form_data'] as Map)['unknown_future_form'] = {'key': 'val'};

      final restored = PropertyData.fromJson(json);
      expect(restored.enabledForms, {FormType.fourPoint});
      expect(restored.formData.containsKey(FormType.fourPoint), isFalse);
    });
  });
}
