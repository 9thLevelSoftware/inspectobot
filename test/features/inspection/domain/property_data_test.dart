import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/inspection_draft.dart';
import 'package:inspectobot/features/inspection/domain/property_data.dart';
import 'package:inspectobot/features/inspection/domain/property_data_migrations.dart';

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
  });
}
