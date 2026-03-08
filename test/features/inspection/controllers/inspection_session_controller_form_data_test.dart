import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/audit/data/audit_event_repository.dart';
import 'package:inspectobot/features/inspection/data/inspection_repository.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/inspection_draft.dart';
import 'package:inspectobot/features/inspection/domain/property_data.dart';
import 'package:inspectobot/features/inspection/presentation/controllers/inspection_session_controller.dart';
import 'package:inspectobot/features/media/media_capture_service.dart';
import 'package:inspectobot/features/media/media_sync_task.dart';
import 'package:inspectobot/features/media/pending_media_sync_store.dart';
import 'package:inspectobot/features/pdf/cloud_pdf_service.dart';
import 'package:inspectobot/features/pdf/on_device_pdf_service.dart';
import 'package:inspectobot/features/pdf/pdf_generation_input.dart';
import 'package:inspectobot/features/pdf/pdf_orchestrator.dart';
import 'package:inspectobot/features/inspection/domain/required_photo_category.dart';

import 'dart:io';

void main() {
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  InspectionDraft makeDraft({
    Set<FormType> enabledForms = const {FormType.wdo},
  }) {
    return InspectionDraft(
      inspectionId: 'insp-1',
      organizationId: 'org-1',
      userId: 'user-1',
      clientName: 'Test User',
      clientEmail: 'test@example.com',
      clientPhone: '555-0100',
      propertyAddress: '123 Test St',
      inspectionDate: DateTime.utc(2026, 3, 4),
      yearBuilt: 2005,
      enabledForms: enabledForms,
    );
  }

  InspectionSessionController makeController({InspectionDraft? draft}) {
    final store = _FakeStore();
    return InspectionSessionController(
      draft: draft ?? makeDraft(),
      repository: InspectionRepository(store),
      mediaCapture: _NoOpMediaCaptureService(),
      pdfOrchestrator: PdfOrchestrator(
        onDevice: _SuccessfulOnDevicePdfService(),
        cloud: const CloudPdfService(
          runtimeGateway: DisabledCloudPdfRuntimeGateway(),
        ),
      ),
      pendingMediaSyncStore: _EmptyPendingStore(),
      auditRepository: AuditEventRepository(InMemoryAuditEventGateway()),
    );
  }

  // ---------------------------------------------------------------------------
  // group: InspectionDraft.formData
  // ---------------------------------------------------------------------------

  group('InspectionDraft.formData', () {
    test('starts empty by default', () {
      final draft = makeDraft();
      expect(draft.formData, isEmpty);
    });

    test('direct mutation persists values', () {
      final draft = makeDraft();
      draft.formData[FormType.wdo] = <String, dynamic>{'key': 'value'};
      expect(draft.formData[FormType.wdo]?['key'], 'value');
    });

    test('constructor accepts initial formData', () {
      final draft = InspectionDraft(
        inspectionId: 'insp-1',
        organizationId: 'org-1',
        userId: 'user-1',
        clientName: 'Test User',
        clientEmail: 'test@example.com',
        clientPhone: '555-0100',
        propertyAddress: '123 Test St',
        inspectionDate: DateTime.utc(2026, 3, 4),
        yearBuilt: 2005,
        enabledForms: {FormType.wdo},
        formData: {
          FormType.wdo: {'existing': 'data'},
        },
      );
      expect(draft.formData[FormType.wdo]?['existing'], 'data');
    });
  });

  // ---------------------------------------------------------------------------
  // group: controller form field methods
  // ---------------------------------------------------------------------------

  group('controller form field methods', () {
    test('setFormFieldValue stores value in draft.formData', () {
      final controller = makeController();
      controller.initialize();

      controller.setFormFieldValue(FormType.wdo, 'companyName', 'Acme Inc');

      expect(controller.draft.formData[FormType.wdo]?['companyName'],
          'Acme Inc');
    });

    test('setFormFieldValue triggers notification callback', () {
      var notifyCount = 0;
      final controller = makeController();
      controller.onStateChanged = () => notifyCount += 1;
      controller.initialize();
      notifyCount = 0;

      controller.setFormFieldValue(FormType.wdo, 'key', 'value');

      expect(notifyCount, 1);
    });

    test('getFormFieldValue retrieves stored value', () {
      final controller = makeController();
      controller.initialize();

      controller.setFormFieldValue(FormType.wdo, 'phoneNumber', '555-1234');

      expect(
        controller.getFormFieldValue<String>(FormType.wdo, 'phoneNumber'),
        '555-1234',
      );
    });

    test('getFormFieldValue returns null for missing key', () {
      final controller = makeController();
      controller.initialize();

      expect(
        controller.getFormFieldValue<String>(FormType.wdo, 'nonexistent'),
        isNull,
      );
    });

    test('getFormFieldValue returns null for missing form type', () {
      final controller = makeController();
      controller.initialize();

      expect(
        controller.getFormFieldValue<String>(
            FormType.fourPoint, 'nonexistent'),
        isNull,
      );
    });

    test('getFormData returns unmodifiable copy', () {
      final controller = makeController();
      controller.initialize();

      controller.setFormFieldValue(FormType.wdo, 'key', 'value');
      final data = controller.getFormData(FormType.wdo);

      expect(data['key'], 'value');
      expect(
        () => data['new_key'] = 'fail',
        throwsUnsupportedError,
      );
    });

    test('getFormData returns empty map for missing form type', () {
      final controller = makeController();
      controller.initialize();

      final data = controller.getFormData(FormType.fourPoint);
      expect(data, isEmpty);
    });

    test('multiple form types store data independently', () {
      final controller = makeController(
        draft: makeDraft(
          enabledForms: {FormType.wdo, FormType.fourPoint},
        ),
      );
      controller.initialize();

      controller.setFormFieldValue(FormType.wdo, 'key', 'wdo_value');
      controller.setFormFieldValue(FormType.fourPoint, 'key', 'fp_value');

      expect(
        controller.getFormFieldValue<String>(FormType.wdo, 'key'),
        'wdo_value',
      );
      expect(
        controller.getFormFieldValue<String>(FormType.fourPoint, 'key'),
        'fp_value',
      );
    });
  });

  // ---------------------------------------------------------------------------
  // group: PropertyData bridge
  // ---------------------------------------------------------------------------

  group('PropertyData bridge', () {
    test('fromInspectionDraft preserves formData', () {
      final draft = makeDraft();
      draft.formData[FormType.wdo] = <String, dynamic>{
        'companyName': 'Acme',
        'phoneNumber': '555-0000',
      };

      final pd = PropertyData.fromInspectionDraft(draft);

      expect(pd.formData[FormType.wdo]?['companyName'], 'Acme');
      expect(pd.formData[FormType.wdo]?['phoneNumber'], '555-0000');
    });

    test('toInspectionDraft preserves formData back', () {
      final draft = makeDraft();
      draft.formData[FormType.wdo] = <String, dynamic>{
        'companyName': 'Acme',
      };

      final pd = PropertyData.fromInspectionDraft(draft);
      final restored = pd.toInspectionDraft();

      expect(restored.formData[FormType.wdo]?['companyName'], 'Acme');
    });

    test('fromInspectionDraft deep copies formData (no shared references)', () {
      final draft = makeDraft();
      draft.formData[FormType.wdo] = <String, dynamic>{
        'companyName': 'Original',
      };

      final pd = PropertyData.fromInspectionDraft(draft);

      // Mutate the original draft's formData
      draft.formData[FormType.wdo]!['companyName'] = 'Mutated';

      // PropertyData should still have the original value
      expect(pd.formData[FormType.wdo]?['companyName'], 'Original');
    });

    test('toInspectionDraft deep copies formData (no shared references)', () {
      final draft = makeDraft();
      draft.formData[FormType.wdo] = <String, dynamic>{
        'companyName': 'Original',
      };

      final pd = PropertyData.fromInspectionDraft(draft);
      final restored = pd.toInspectionDraft();

      // Mutate the restored draft's formData
      restored.formData[FormType.wdo]!['companyName'] = 'Mutated';

      // PropertyData should still have the original value
      expect(pd.formData[FormType.wdo]?['companyName'], 'Original');
    });

    test('round-trip draft -> PropertyData -> draft preserves formData', () {
      final original = makeDraft();
      original.formData[FormType.wdo] = <String, dynamic>{
        'companyName': 'Acme',
        'phoneNumber': '555-0000',
      };
      original.formData[FormType.fourPoint] = <String, dynamic>{
        'rating': 'Good',
      };

      final pd = PropertyData.fromInspectionDraft(original);
      final restored = pd.toInspectionDraft();

      expect(restored.formData[FormType.wdo]?['companyName'], 'Acme');
      expect(restored.formData[FormType.wdo]?['phoneNumber'], '555-0000');
      expect(restored.formData[FormType.fourPoint]?['rating'], 'Good');
    });
  });
}

// ---------------------------------------------------------------------------
// Test doubles (minimal subset for form data tests)
// ---------------------------------------------------------------------------

class _FakeStore implements InspectionStore {
  Map<String, dynamic>? readiness;

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> inspectionJson) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>?> fetchById({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    return null;
  }

  @override
  Future<Map<String, dynamic>?> fetchWizardProgress({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    return null;
  }

  @override
  Future<List<Map<String, dynamic>>> listInProgressInspections({
    required String organizationId,
    required String userId,
  }) async {
    return const <Map<String, dynamic>>[];
  }

  @override
  Future<Map<String, dynamic>?> fetchReportReadiness({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    return readiness;
  }

  @override
  Future<Map<String, dynamic>> updateWizardProgress({
    required String inspectionId,
    required String organizationId,
    required String userId,
    required int wizardLastStep,
    required Map<String, bool> wizardCompletion,
    required Map<String, dynamic> wizardBranchContext,
    required String wizardStatus,
  }) async {
    return <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> upsertReportReadiness({
    required String inspectionId,
    required String organizationId,
    required String userId,
    required String status,
    required List<String> missingItems,
    required DateTime computedAt,
  }) async {
    readiness = <String, dynamic>{
      'inspection_id': inspectionId,
      'organization_id': organizationId,
      'user_id': userId,
      'status': status,
      'missing_items': missingItems,
      'computed_at': computedAt.toIso8601String(),
    };
    return readiness!;
  }
}

class _NoOpMediaCaptureService extends MediaCaptureService {
  _NoOpMediaCaptureService()
      : super(
          pickPhoto: () async => null,
          pickDocument: () async => null,
          compressPhoto: (_) async => null,
          writeCapture: ({
            required String inspectionId,
            required RequiredPhotoCategory category,
            required CapturedMediaType mediaType,
            required String sourcePath,
            List<int>? bytes,
          }) async =>
              File('/dev/null'),
        );
}

class _SuccessfulOnDevicePdfService extends OnDevicePdfService {
  @override
  Future<File> generate(PdfGenerationInput input) async {
    final file = File(
      '${Directory.systemTemp.path}/inspectobot_test_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(<int>[1, 2, 3], flush: true);
    return file;
  }
}

class _EmptyPendingStore extends PendingMediaSyncStore {
  @override
  Future<Map<String, List<String>>> loadEvidenceMediaPaths({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    return const <String, List<String>>{};
  }
}
