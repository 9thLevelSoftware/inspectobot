import 'package:flutter_test/flutter_test.dart';

import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/inspection_draft.dart';
import 'package:inspectobot/features/inspection/domain/wdo_form_data.dart';
import 'package:inspectobot/features/inspection/presentation/controllers/inspection_session_controller.dart';

void main() {
  group('WDO Integration', () {
    late InspectionDraft draft;

    setUp(() {
      draft = InspectionDraft(
        inspectionId: 'test-123',
        organizationId: 'org-1',
        userId: 'user-1',
        clientName: 'Jane Doe',
        clientEmail: 'jane@test.com',
        clientPhone: '555-1234',
        propertyAddress: '123 Main St',
        inspectionDate: DateTime(2026, 3, 7),
        yearBuilt: 2000,
        enabledForms: {FormType.wdo},
      );
    });

    test('setFormFieldValue stores values in draft.formData', () {
      final controller = InspectionSessionController(draft: draft);

      controller.setFormFieldValue(FormType.wdo, 'gen_company_name', 'Acme Pest');
      controller.setFormFieldValue(FormType.wdo, 'gen_phone', '555-9999');

      expect(draft.formData[FormType.wdo], isNotNull);
      expect(draft.formData[FormType.wdo]!['gen_company_name'], 'Acme Pest');
      expect(draft.formData[FormType.wdo]!['gen_phone'], '555-9999');
    });

    test('getFormFieldValue retrieves stored values', () {
      final controller = InspectionSessionController(draft: draft);

      controller.setFormFieldValue(FormType.wdo, 'comments', 'No issues');

      final value = controller.getFormFieldValue<String>(FormType.wdo, 'comments');
      expect(value, 'No issues');
    });

    test('getFormData returns all form data', () {
      final controller = InspectionSessionController(draft: draft);

      controller.setFormFieldValue(FormType.wdo, 'gen_company_name', 'Acme');
      controller.setFormFieldValue(FormType.wdo, 'gen_phone', '555-0000');

      final data = controller.getFormData(FormType.wdo);
      expect(data['gen_company_name'], 'Acme');
      expect(data['gen_phone'], '555-0000');
    });

    test('WdoFormData.fromJson round-trips through draft.formData', () {
      final controller = InspectionSessionController(draft: draft);

      // Simulate field entry via controller
      controller.setFormFieldValue(FormType.wdo, 'companyName', 'Acme Pest Co');
      controller.setFormFieldValue(FormType.wdo, 'businessLicenseNumber', '12345');
      controller.setFormFieldValue(FormType.wdo, 'comments', 'All clear');
      controller.setFormFieldValue(FormType.wdo, 'inspectorName', 'John Smith');

      // Extract and parse through WdoFormData
      final rawData = draft.formData[FormType.wdo]!;
      final parsed = WdoFormData.fromJson(rawData);

      expect(parsed.companyName, 'Acme Pest Co');
      expect(parsed.businessLicenseNumber, '12345');
      expect(parsed.comments, 'All clear');
      expect(parsed.inspectorName, 'John Smith');

      // Round-trip: serialize back and compare
      final serialized = parsed.toJson();
      final reparsed = WdoFormData.fromJson(serialized);
      expect(reparsed, equals(parsed));
    });

    test('onStateChanged fires on setFormFieldValue', () {
      final controller = InspectionSessionController(draft: draft);
      var callCount = 0;
      controller.onStateChanged = () => callCount++;

      controller.setFormFieldValue(FormType.wdo, 'gen_company_name', 'Test');

      expect(callCount, 1);
    });

    test('multiple form types can coexist in formData', () {
      final multiDraft = InspectionDraft(
        inspectionId: 'test-456',
        organizationId: 'org-1',
        userId: 'user-1',
        clientName: 'Jane Doe',
        clientEmail: 'jane@test.com',
        clientPhone: '555-1234',
        propertyAddress: '456 Oak Ave',
        inspectionDate: DateTime(2026, 3, 7),
        yearBuilt: 2005,
        enabledForms: {FormType.wdo, FormType.fourPoint},
      );

      final controller = InspectionSessionController(draft: multiDraft);

      controller.setFormFieldValue(FormType.wdo, 'gen_company_name', 'WDO Co');
      controller.setFormFieldValue(FormType.fourPoint, 'some_field', 'FP value');

      expect(multiDraft.formData[FormType.wdo]!['gen_company_name'], 'WDO Co');
      expect(multiDraft.formData[FormType.fourPoint]!['some_field'], 'FP value');
    });
  });
}
