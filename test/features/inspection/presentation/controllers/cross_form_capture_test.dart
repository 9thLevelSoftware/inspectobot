import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/audit/data/audit_event_repository.dart';
import 'package:inspectobot/features/inspection/data/inspection_repository.dart';

import 'package:inspectobot/features/inspection/domain/form_requirements.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/inspection_draft.dart';
import 'package:inspectobot/features/inspection/domain/inspection_wizard_state.dart';
import 'package:inspectobot/features/inspection/domain/required_photo_category.dart';
import 'package:inspectobot/features/inspection/presentation/controllers/inspection_session_controller.dart';
import 'package:inspectobot/features/media/media_capture_result.dart';
import 'package:inspectobot/features/media/media_capture_service.dart';
import 'package:inspectobot/features/media/media_sync_task.dart';
import 'package:inspectobot/features/media/pending_media_sync_store.dart';
import 'package:inspectobot/features/pdf/cloud_pdf_service.dart';
import 'package:inspectobot/features/pdf/on_device_pdf_service.dart';
import 'package:inspectobot/features/pdf/pdf_generation_input.dart';
import 'package:inspectobot/features/pdf/pdf_orchestrator.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  InspectionDraft makeDraft({
    String inspectionId = 'insp-cross',
    Set<FormType> enabledForms = const {FormType.fourPoint},
    WizardProgressSnapshot? wizardSnapshot,
    Map<String, dynamic>? branchContext,
  }) {
    return InspectionDraft(
      inspectionId: inspectionId,
      organizationId: 'org-1',
      userId: 'user-1',
      clientName: 'Test User',
      clientEmail: 'test@example.com',
      clientPhone: '555-0100',
      propertyAddress: '123 Test St',
      inspectionDate: DateTime.utc(2026, 3, 8),
      yearBuilt: 2005,
      enabledForms: enabledForms,
      wizardSnapshot: wizardSnapshot ??
          WizardProgressSnapshot(
            lastStepIndex: 0,
            completion: const <String, bool>{},
            branchContext: branchContext ?? const <String, dynamic>{},
            status: WizardProgressStatus.inProgress,
          ),
    );
  }

  InspectionSessionController makeController({
    InspectionDraft? draft,
    MediaCaptureService? mediaCapture,
  }) {
    final store = _FakeStore();
    return InspectionSessionController(
      draft: draft ?? makeDraft(),
      repository: InspectionRepository(store),
      mediaCapture: mediaCapture ?? _SuccessfulMediaCaptureService(),
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
  // group: cross-form capture
  // ---------------------------------------------------------------------------

  group('cross-form capture', () {
    // Test 1: Semantic equivalents — exteriorFront (4PT) → generalFrontElevation (GEN)
    test(
      'capture exteriorFront for 4-Point with General enabled marks both '
      "forms' requirement keys complete",
      () async {
        final draft = makeDraft(
          enabledForms: {FormType.fourPoint, FormType.generalInspection},
        );
        final controller = makeController(draft: draft);
        controller.initialize();
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // The 4-Point exteriorFront requirement.
        final fourPointReqs = FormRequirements.forFormRequirements(
          FormType.fourPoint,
        );
        final exteriorFrontReq = fourPointReqs.firstWhere(
          (r) => r.category == RequiredPhotoCategory.exteriorFront,
        );

        final result = await controller.capture(exteriorFrontReq);

        expect(result, CaptureResult.captured);

        // Primary key marked.
        expect(
          controller.snapshot.completion[exteriorFrontReq.key],
          isTrue,
        );

        // Semantic equivalent key for General inspection also marked.
        const generalKey = 'photo:general_front_elevation';
        expect(controller.snapshot.completion[generalKey], isTrue);

        // Photo path copied for the equivalent category.
        expect(
          draft.capturedPhotoPaths[RequiredPhotoCategory.generalFrontElevation],
          isNotNull,
        );
        expect(
          draft.capturedEvidencePaths[generalKey],
          isNotEmpty,
        );
      },
    );

    // Test 2: Native shares — roofSlopeMain shared by 4PT + Roof Condition
    test(
      'capture roofSlopeMain for 4-Point with Roof Condition + General enabled '
      "marks all forms' keys",
      () async {
        final draft = makeDraft(
          enabledForms: {
            FormType.fourPoint,
            FormType.roofCondition,
            FormType.generalInspection,
          },
        );
        final controller = makeController(draft: draft);
        controller.initialize();
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final fourPointReqs = FormRequirements.forFormRequirements(
          FormType.fourPoint,
        );
        final roofSlopeReq = fourPointReqs.firstWhere(
          (r) => r.category == RequiredPhotoCategory.roofSlopeMain,
        );

        final result = await controller.capture(roofSlopeReq);

        expect(result, CaptureResult.captured);

        // Primary key (4PT).
        expect(controller.snapshot.completion[roofSlopeReq.key], isTrue);

        // Native share key (Roof Condition).
        const roofConditionKey = 'photo:roof_condition_main_slope';
        expect(controller.snapshot.completion[roofConditionKey], isTrue);
        expect(draft.capturedEvidencePaths[roofConditionKey], isNotEmpty);

        // General inspection should NOT be marked — roofSlopeMain is not
        // shared with generalInspection.
        final generalReqs = FormRequirements.forFormRequirements(
          FormType.generalInspection,
        );
        for (final req in generalReqs) {
          if (req.category == RequiredPhotoCategory.roofSlopeMain) {
            fail('generalInspection should not have roofSlopeMain');
          }
        }
      },
    );

    // Test 3: Non-shared category — wdoInfestationEvidence only for WDO
    test(
      'capture a non-shared category (wdoInfestationEvidence) only marks WDO key',
      () async {
        final draft = makeDraft(
          enabledForms: {FormType.wdo, FormType.fourPoint},
          branchContext: {
            FormRequirements.wdoVisibleEvidenceBranchFlag: true,
          },
        );
        final controller = makeController(draft: draft);
        controller.initialize();
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final wdoReqs = FormRequirements.forFormRequirements(
          FormType.wdo,
          branchContext: {
            FormRequirements.wdoVisibleEvidenceBranchFlag: true,
          },
        );
        final infestationReq = wdoReqs.firstWhere(
          (r) => r.category == RequiredPhotoCategory.wdoInfestationEvidence,
        );

        final result = await controller.capture(infestationReq);

        expect(result, CaptureResult.captured);
        expect(
          controller.snapshot.completion[infestationReq.key],
          isTrue,
        );

        // No 4-Point keys should be marked by this capture.
        final fourPointReqs = FormRequirements.forFormRequirements(
          FormType.fourPoint,
        );
        for (final req in fourPointReqs) {
          if (req.key != infestationReq.key) {
            expect(
              controller.snapshot.completion[req.key],
              isNot(true),
              reason: '4PT key ${req.key} should not be marked by WDO capture',
            );
          }
        }
      },
    );

    // Test 4: Single form enabled — no sharing possible
    test(
      'capture with only 1 form enabled behaves normally (no cross-form)',
      () async {
        final draft = makeDraft(
          enabledForms: {FormType.fourPoint},
        );
        final controller = makeController(draft: draft);
        controller.initialize();
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final reqs = FormRequirements.forFormRequirements(FormType.fourPoint);
        final firstReq = reqs.first;

        final result = await controller.capture(firstReq);

        expect(result, CaptureResult.captured);
        expect(controller.snapshot.completion[firstReq.key], isTrue);

        // Only one key should be marked — no cross-form sharing.
        final markedKeys = controller.snapshot.completion.entries
            .where((e) => e.value == true)
            .map((e) => e.key)
            .toList();
        expect(markedKeys, [firstReq.key]);
      },
    );

    // Test 5: Conditional requirement where other form's condition isn't met
    test(
      'capture conditional requirement where other form condition is not met '
      'does not mark other form',
      () async {
        // generalDeficiency requires general_safety_hazard=true.
        // We enable both but do NOT set the general branch flag.
        final draft = makeDraft(
          enabledForms: {FormType.fourPoint, FormType.generalInspection},
          // hazard_present=true for 4PT, but general_safety_hazard NOT set
          branchContext: {
            FormRequirements.hazardPresentBranchFlag: true,
          },
        );
        final controller = makeController(draft: draft);
        controller.initialize();
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Capture the 4PT hazardPhoto. This is NOT shared with general
        // inspection (different category), so no cross-form marking.
        final fourPointReqs = FormRequirements.forFormRequirements(
          FormType.fourPoint,
          branchContext: {
            FormRequirements.hazardPresentBranchFlag: true,
          },
        );
        final hazardReq = fourPointReqs.firstWhere(
          (r) => r.category == RequiredPhotoCategory.hazardPhoto,
        );

        final result = await controller.capture(hazardReq);

        expect(result, CaptureResult.captured);
        expect(controller.snapshot.completion[hazardReq.key], isTrue);

        // generalDeficiency key should NOT be marked (different category
        // and the general_safety_hazard flag isn't set).
        const generalDeficiencyKey = 'photo:general_deficiency';
        expect(
          controller.snapshot.completion[generalDeficiencyKey],
          isNot(true),
        );
      },
    );

    // Test 6: Semantic equivalent capture also copies photo paths
    test(
      'capture electricalPanelLabel (4PT) marks generalElectricalPanel (GEN) '
      'and copies photo path',
      () async {
        final draft = makeDraft(
          enabledForms: {FormType.fourPoint, FormType.generalInspection},
        );
        final controller = makeController(draft: draft);
        controller.initialize();
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final fourPointReqs = FormRequirements.forFormRequirements(
          FormType.fourPoint,
        );
        final panelReq = fourPointReqs.firstWhere(
          (r) => r.category == RequiredPhotoCategory.electricalPanelLabel,
        );

        final result = await controller.capture(panelReq);

        expect(result, CaptureResult.captured);

        // Primary key marked.
        expect(controller.snapshot.completion[panelReq.key], isTrue);

        // Semantic equivalent for General marked.
        const generalPanelKey = 'photo:general_electrical_panel';
        expect(controller.snapshot.completion[generalPanelKey], isTrue);

        // Photo paths copied.
        expect(
          draft.capturedPhotoPaths[RequiredPhotoCategory.generalElectricalPanel],
          isNotNull,
        );
        expect(
          draft.capturedEvidencePaths[generalPanelKey],
          isNotEmpty,
        );

        // Both paths point to same file.
        expect(
          draft.capturedPhotoPaths[RequiredPhotoCategory.generalElectricalPanel],
          draft.capturedPhotoPaths[RequiredPhotoCategory.electricalPanelLabel],
        );
      },
    );

    // Test 7: Capture after one form already complete
    test(
      'capture after one form already complete still marks other forms',
      () async {
        // Set up 4PT as already complete, then capture a shared photo.
        final fourPointReqs = FormRequirements.forFormRequirements(
          FormType.fourPoint,
        );
        final completion = <String, bool>{
          for (final req in fourPointReqs) req.key: true,
        };

        final draft = makeDraft(
          enabledForms: {FormType.fourPoint, FormType.generalInspection},
          wizardSnapshot: WizardProgressSnapshot(
            lastStepIndex: 0,
            completion: completion,
            branchContext: const <String, dynamic>{},
            status: WizardProgressStatus.inProgress,
          ),
        );
        final controller = makeController(draft: draft);
        controller.initialize();
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Now capture from the general inspection side.
        final generalReqs = FormRequirements.forFormRequirements(
          FormType.generalInspection,
        );
        final generalFrontReq = generalReqs.firstWhere(
          (r) => r.category == RequiredPhotoCategory.generalFrontElevation,
        );

        final result = await controller.capture(generalFrontReq);

        expect(result, CaptureResult.captured);

        // General key marked.
        expect(
          controller.snapshot.completion[generalFrontReq.key],
          isTrue,
        );

        // 4PT exteriorFront was already marked — should still be true.
        const fourPointExteriorKey = 'photo:exterior_front';
        expect(
          controller.snapshot.completion[fourPointExteriorKey],
          isTrue,
        );
      },
    );

    // Test 8: hvacDataPlate (4PT) ↔ generalDataPlate (GEN) semantic share
    test(
      'capture hvacDataPlate (4PT) marks generalDataPlate (GEN) complete',
      () async {
        final draft = makeDraft(
          enabledForms: {FormType.fourPoint, FormType.generalInspection},
        );
        final controller = makeController(draft: draft);
        controller.initialize();
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final fourPointReqs = FormRequirements.forFormRequirements(
          FormType.fourPoint,
        );
        final hvacReq = fourPointReqs.firstWhere(
          (r) => r.category == RequiredPhotoCategory.hvacDataPlate,
        );

        final result = await controller.capture(hvacReq);

        expect(result, CaptureResult.captured);
        expect(controller.snapshot.completion[hvacReq.key], isTrue);

        const generalDataPlateKey = 'photo:general_data_plate';
        expect(controller.snapshot.completion[generalDataPlateKey], isTrue);

        // Captured categories includes the equivalent.
        expect(
          draft.capturedCategories,
          contains(RequiredPhotoCategory.generalDataPlate),
        );
      },
    );
  });
}

// =============================================================================
// Test Doubles
// =============================================================================

class _SuccessfulMediaCaptureService extends MediaCaptureService {
  _SuccessfulMediaCaptureService()
      : super(
          pickPhoto: () async => '/tmp/test_photo.jpg',
          pickDocument: () async => '/tmp/test_doc.pdf',
          compressPhoto: (_) async => <int>[1, 2, 3],
          writeCapture: ({
            required String inspectionId,
            required RequiredPhotoCategory category,
            required CapturedMediaType mediaType,
            required String sourcePath,
            List<int>? bytes,
          }) async =>
              File('/tmp/captured_${category.name}.jpg'),
        );

  @override
  Future<MediaCaptureServiceResult> captureRequiredPhoto({
    required String inspectionId,
    required String organizationId,
    required String userId,
    required RequiredPhotoCategory category,
    String? requirementKey,
    CapturedMediaType mediaType = CapturedMediaType.photo,
    String? evidenceInstanceId,
  }) async {
    return MediaCaptureServiceResult.success(
      MediaCaptureResult(
        category: category,
        filePath: '/tmp/captured_${category.name}.jpg',
        byteSize: 1024,
      ),
    );
  }
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
    return <String, dynamic>{
      'id': inspectionId,
      'organization_id': organizationId,
      'user_id': userId,
      'wizard_last_step': wizardLastStep,
      'wizard_completion': wizardCompletion,
      'wizard_branch_context': wizardBranchContext,
      'wizard_status': wizardStatus,
    };
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
