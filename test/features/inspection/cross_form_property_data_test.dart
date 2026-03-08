import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/inspection_draft.dart';
import 'package:inspectobot/features/inspection/domain/property_data.dart';
import 'package:inspectobot/features/inspection/domain/universal_property_fields.dart';

/// Verifies that shared property data (INTEG-01b) flows correctly across
/// all enabled forms when using a single InspectionDraft.
void main() {
  group('Cross-form property data flow (INTEG-01b)', () {
    InspectionDraft buildMultiFormDraft() {
      return InspectionDraft(
        inspectionId: 'insp-cross',
        organizationId: 'org-1',
        userId: 'user-1',
        clientName: 'Jane Doe',
        clientEmail: 'jane@example.com',
        clientPhone: '555-1234',
        propertyAddress: '789 Main St',
        inspectionDate: DateTime.utc(2026, 3, 8),
        yearBuilt: 1998,
        enabledForms: {
          FormType.fourPoint,
          FormType.roofCondition,
          FormType.generalInspection,
        },
      );
    }

    test('all 3 forms share the same universal property fields from draft', () {
      final draft = buildMultiFormDraft();

      // The draft is the single source of truth for property data.
      // All forms reference the same draft object, so universal fields
      // (clientName, propertyAddress, yearBuilt) are inherently shared.
      expect(draft.clientName, 'Jane Doe');
      expect(draft.propertyAddress, '789 Main St');
      expect(draft.yearBuilt, 1998);

      // PropertyData.fromInspectionDraft verifies the mapping is correct.
      final pd = PropertyData.fromInspectionDraft(draft);
      expect(pd.universal.clientName, 'Jane Doe');
      expect(pd.universal.propertyAddress, '789 Main St');
      expect(pd.shared.yearBuilt, 1998);
      expect(pd.enabledForms, contains(FormType.fourPoint));
      expect(pd.enabledForms, contains(FormType.roofCondition));
      expect(pd.enabledForms, contains(FormType.generalInspection));
    });

    test('updating form-specific data in one form does not affect others', () {
      final draft = buildMultiFormDraft();

      // Set form-specific data for fourPoint only.
      draft.formData[FormType.fourPoint] = {'hazard_present': true};

      // roofCondition and generalInspection should not have this data.
      expect(draft.formData[FormType.roofCondition], isNull);
      expect(draft.formData[FormType.generalInspection], isNull);

      // But universal fields remain shared.
      expect(draft.clientName, 'Jane Doe');
    });

    test('property data changes are visible across all form contexts', () {
      final draft = buildMultiFormDraft();

      // Simulate setting form data for multiple forms
      draft.formData[FormType.fourPoint] = {'hazard_present': false};
      draft.formData[FormType.roofCondition] = {
        'roof_defect_present': true,
      };
      draft.formData[FormType.generalInspection] = {
        'general_safety_hazard': false,
      };

      // Verify each form sees its own data.
      expect(draft.formData[FormType.fourPoint]!['hazard_present'], isFalse);
      expect(
        draft.formData[FormType.roofCondition]!['roof_defect_present'],
        isTrue,
      );
      expect(
        draft.formData[FormType.generalInspection]!['general_safety_hazard'],
        isFalse,
      );

      // Universal property data is still shared (single source of truth).
      expect(draft.clientName, 'Jane Doe');
      expect(draft.propertyAddress, '789 Main St');
    });

    test('PropertyData round-trips through toInspectionDraft correctly', () {
      final draft = buildMultiFormDraft();
      draft.formData[FormType.fourPoint] = {'hazard_present': true};

      final pd = PropertyData.fromInspectionDraft(draft);
      final roundTripped = pd.toInspectionDraft();

      expect(roundTripped.clientName, draft.clientName);
      expect(roundTripped.propertyAddress, draft.propertyAddress);
      expect(roundTripped.yearBuilt, draft.yearBuilt);
      expect(roundTripped.enabledForms, draft.enabledForms);
      expect(
        roundTripped.formData[FormType.fourPoint]?['hazard_present'],
        true,
      );
    });

    test('PropertyData.setFormValue creates new instance with updated data', () {
      final draft = buildMultiFormDraft();
      final pd = PropertyData.fromInspectionDraft(draft);

      final updated = pd.setFormValue(
        FormType.fourPoint,
        'hazard_present',
        true,
      );

      // Original is unchanged (immutable).
      expect(pd.formData[FormType.fourPoint]?['hazard_present'], isNull);

      // Updated has the new value.
      expect(
        updated.formData[FormType.fourPoint]?['hazard_present'],
        isTrue,
      );

      // Universal fields unchanged in both.
      expect(updated.universal.clientName, 'Jane Doe');
      expect(pd.universal.clientName, 'Jane Doe');
    });
  });
}
