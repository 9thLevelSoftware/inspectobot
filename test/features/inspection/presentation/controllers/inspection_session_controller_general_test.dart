import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/audit/data/audit_event_repository.dart';
import 'package:inspectobot/features/inspection/data/inspection_repository.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/general_inspection_form_data.dart';
import 'package:inspectobot/features/inspection/domain/inspection_draft.dart';
import 'package:inspectobot/features/inspection/presentation/controllers/inspection_session_controller.dart';
import 'package:inspectobot/features/media/media_capture_service.dart';
import 'package:inspectobot/features/media/media_sync_task.dart';
import 'package:inspectobot/features/media/pending_media_sync_store.dart';
import 'package:inspectobot/features/pdf/cloud_pdf_service.dart';
import 'package:inspectobot/features/pdf/on_device_pdf_service.dart';
import 'package:inspectobot/features/pdf/pdf_generation_input.dart';
import 'package:inspectobot/features/pdf/pdf_orchestrator.dart';
import 'package:inspectobot/features/inspection/domain/required_photo_category.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  InspectionDraft makeDraft({
    Set<FormType> enabledForms = const {FormType.generalInspection},
    Map<FormType, Map<String, dynamic>>? formData,
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
      formData: formData,
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
  // group: general form data state management
  // ---------------------------------------------------------------------------

  group('general form data state management', () {
    test('generalFormData starts as empty when no prior data exists in draft',
        () {
      final controller = makeController();
      controller.initialize();

      expect(controller.generalFormData, GeneralInspectionFormData.empty());
      expect(controller.generalFormData.isEmpty, isTrue);
    });

    test('updateGeneralFormData updates the controller generalFormData state',
        () {
      final controller = makeController();
      controller.initialize();

      final data = GeneralInspectionFormData.empty().copyWith(
        scopeAndPurpose: 'Full property general inspection',
      );
      controller.updateGeneralFormData(data);

      expect(controller.generalFormData.scopeAndPurpose,
          'Full property general inspection');
    });

    test(
        'updateGeneralFormData persists data to draft.formData under generalInspection key',
        () {
      final controller = makeController();
      controller.initialize();

      final data = GeneralInspectionFormData.empty().copyWith(
        scopeAndPurpose: 'Scope text',
        generalComments: 'Some general comments',
      );
      controller.updateGeneralFormData(data);

      final stored = controller.draft.formData[FormType.generalInspection];
      expect(stored, isNotNull);
      expect(stored!['scopeAndPurpose'], 'Scope text');
      expect(stored['generalComments'], 'Some general comments');
    });

    test('GeneralInspectionFormData round-trips through draft persistence', () {
      final original = GeneralInspectionFormData.empty().copyWith(
        scopeAndPurpose: 'Full scope',
        generalComments: 'Comments here',
        safetyHazard: true,
        moistureMoldEvidence: true,
      );

      // 1. Store via the REAL updateGeneralFormData write path.
      final controller = makeController();
      controller.initialize();
      controller.updateGeneralFormData(original);

      // 2. Capture what was ACTUALLY stored in draft.formData.
      final actuallyStored =
          controller.draft.formData[FormType.generalInspection]!;

      // 3. Create a new controller seeded with those exact stored bytes.
      final draft2 = makeDraft(
        formData: {
          FormType.generalInspection:
              Map<String, dynamic>.from(actuallyStored),
        },
      );
      final controller2 = makeController(draft: draft2);
      controller2.initialize();

      // 4. Verify the data survives the full write -> hydrate round-trip.
      expect(controller2.generalFormData.scopeAndPurpose, 'Full scope');
      expect(controller2.generalFormData.generalComments, 'Comments here');
      expect(controller2.generalFormData.safetyHazard, isTrue);
      expect(controller2.generalFormData.moistureMoldEvidence, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // group: narrative data bridge
  // ---------------------------------------------------------------------------

  group('narrative data bridge', () {
    test(
        'draft.formData stores camelCase keys via toJson() for hydration fidelity',
        () {
      final controller = makeController();
      controller.initialize();

      final data = GeneralInspectionFormData.empty().copyWith(
        scopeAndPurpose: 'Full assessment',
        generalComments: 'All systems operational',
      );
      controller.updateGeneralFormData(data);

      final stored = controller.draft.formData[FormType.generalInspection]!;
      expect(stored['scopeAndPurpose'], 'Full assessment');
      expect(stored['generalComments'], 'All systems operational');
    });

    test(
        'camelCase stored data can be translated to snake_case for narrative engine',
        () {
      final controller = makeController();
      controller.initialize();

      final data = GeneralInspectionFormData.empty().copyWith(
        scopeAndPurpose: 'Full assessment',
        generalComments: 'All good',
      );
      controller.updateGeneralFormData(data);

      // Simulate what generatePdf does: fromJson -> toFormDataMap.
      final stored = controller.draft.formData[FormType.generalInspection]!;
      final hydrated =
          GeneralInspectionFormData.fromJson(Map<String, dynamic>.from(stored));
      final templateMap = hydrated.toFormDataMap();

      expect(templateMap['scope_and_purpose'], 'Full assessment');
      expect(templateMap['general_comments'], 'All good');
    });

    test(
        'generatePdf narrative path: updateGeneralFormData -> stored rawData -> fromJson -> toFormDataMap',
        () {
      final controller = makeController();
      controller.initialize();

      // Step 1: Store data via the real controller write path (uses toJson()).
      final inputData = GeneralInspectionFormData.empty().copyWith(
        scopeAndPurpose: 'Interior and exterior assessment',
        generalComments: 'Overall property in good condition',
      );
      controller.updateGeneralFormData(inputData);

      // Step 2: Read back the raw stored map (same as generatePdf does).
      final rawData = controller.draft.formData[FormType.generalInspection];
      expect(rawData, isNotNull,
          reason: 'formData should contain general inspection entry');

      // Step 3: Perform the EXACT same conversion as generatePdf.
      final generalData = GeneralInspectionFormData.fromJson(
          Map<String, dynamic>.from(rawData!));
      final narrativeFormData =
          Map<String, dynamic>.from(generalData.toFormDataMap());

      // Step 4: Verify output has correct snake_case keys with correct values.
      expect(narrativeFormData['scope_and_purpose'],
          'Interior and exterior assessment');
      expect(narrativeFormData['general_comments'],
          'Overall property in good condition');
    });
  });
}

// ---------------------------------------------------------------------------
// Test doubles
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
