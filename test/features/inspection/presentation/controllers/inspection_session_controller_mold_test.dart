import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/audit/data/audit_event_repository.dart';
import 'package:inspectobot/features/inspection/data/inspection_repository.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/inspection_draft.dart';
import 'package:inspectobot/features/inspection/domain/mold_form_data.dart';
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
    Set<FormType> enabledForms = const {FormType.moldAssessment},
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
  // group: mold form data state management
  // ---------------------------------------------------------------------------

  group('mold form data state management', () {
    test('moldFormData starts as empty when no prior mold data exists in draft',
        () {
      final controller = makeController();
      controller.initialize();

      expect(controller.moldFormData, MoldFormData.empty());
      expect(controller.moldFormData.isEmpty, isTrue);
    });

    test('updateMoldFormData updates the controller moldFormData state', () {
      final controller = makeController();
      controller.initialize();

      final data = MoldFormData(
        scopeOfAssessment: 'Full property assessment',
        visualObservations: 'Mold visible on bathroom ceiling',
      );
      controller.updateMoldFormData(data);

      expect(controller.moldFormData.scopeOfAssessment,
          'Full property assessment');
      expect(controller.moldFormData.visualObservations,
          'Mold visible on bathroom ceiling');
    });

    test(
        'updateMoldFormData persists data to draft.formData under moldAssessment key',
        () {
      final controller = makeController();
      controller.initialize();

      final data = MoldFormData(
        scopeOfAssessment: 'Scope text',
        moistureSources: 'Leaking pipe',
      );
      controller.updateMoldFormData(data);

      final stored = controller.draft.formData[FormType.moldAssessment];
      expect(stored, isNotNull);
      expect(stored!['scope_of_assessment'], 'Scope text');
      expect(stored['moisture_sources'], 'Leaking pipe');
    });

    test('MoldFormData round-trips through draft persistence', () {
      final original = MoldFormData(
        scopeOfAssessment: 'Full scope',
        visualObservations: 'Observations here',
        moistureSources: 'Roof leak',
        moldTypeLocation: 'Aspergillus in bathroom',
        remediationRecommendations: 'Remove drywall',
        additionalFindings: 'No additional',
        remediationRecommended: true,
        airSamplesTaken: true,
      );

      // Store via updateMoldFormData
      final controller = makeController();
      controller.initialize();
      controller.updateMoldFormData(original);

      // Create a new controller with the same draft to simulate reload.
      // The formData map on the draft is already populated; hydrate from it.
      final draft2 = makeDraft(
        formData: {
          FormType.moldAssessment:
              Map<String, dynamic>.from(original.toJson()),
        },
      );
      final controller2 = makeController(draft: draft2);
      controller2.initialize();

      expect(controller2.moldFormData.scopeOfAssessment, 'Full scope');
      expect(controller2.moldFormData.visualObservations, 'Observations here');
      expect(controller2.moldFormData.moistureSources, 'Roof leak');
      expect(controller2.moldFormData.moldTypeLocation,
          'Aspergillus in bathroom');
      expect(
          controller2.moldFormData.remediationRecommendations, 'Remove drywall');
      expect(controller2.moldFormData.additionalFindings, 'No additional');
      expect(controller2.moldFormData.remediationRecommended, isTrue);
      expect(controller2.moldFormData.airSamplesTaken, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // group: branch logic helpers
  // ---------------------------------------------------------------------------

  group('branch logic helpers', () {
    test(
        'shouldShowRemediationProtocol returns true when remediationRecommended is true',
        () {
      final controller = makeController();
      controller.initialize();

      controller.updateMoldFormData(
        MoldFormData(remediationRecommended: true),
      );

      expect(controller.shouldShowRemediationProtocol, isTrue);
    });

    test(
        'shouldShowRemediationProtocol returns false when remediationRecommended is false',
        () {
      final controller = makeController();
      controller.initialize();

      controller.updateMoldFormData(
        MoldFormData(remediationRecommended: false),
      );

      expect(controller.shouldShowRemediationProtocol, isFalse);
    });

    test('shouldShowAirSampleResults reflects airSamplesTaken flag', () {
      final controller = makeController();
      controller.initialize();

      controller.updateMoldFormData(
        MoldFormData(airSamplesTaken: false),
      );
      expect(controller.shouldShowAirSampleResults, isFalse);

      controller.updateMoldFormData(
        MoldFormData(airSamplesTaken: true),
      );
      expect(controller.shouldShowAirSampleResults, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // group: narrative data bridge
  // ---------------------------------------------------------------------------

  group('narrative data bridge', () {
    test(
        'draft.formData contains narrative form data from MoldFormData.toFormDataMap()',
        () {
      final controller = makeController();
      controller.initialize();

      final data = MoldFormData(
        scopeOfAssessment: 'Full assessment',
        visualObservations: 'Black spots on drywall',
        moistureSources: 'Plumbing leak',
        moldTypeLocation: 'Stachybotrys in master bath',
        remediationRecommendations: 'Professional remediation needed',
        additionalFindings: 'HVAC ducts also affected',
      );
      controller.updateMoldFormData(data);

      // The data stored in draft.formData should match toFormDataMap() keys
      final stored = controller.draft.formData[FormType.moldAssessment]!;
      expect(stored['scope_of_assessment'], 'Full assessment');
      expect(stored['visual_observations'], 'Black spots on drywall');
      expect(stored['moisture_sources'], 'Plumbing leak');
      expect(stored['mold_type_location'], 'Stachybotrys in master bath');
      expect(stored['remediation_recommendations'],
          'Professional remediation needed');
      expect(stored['additional_findings'], 'HVAC ducts also affected');
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
