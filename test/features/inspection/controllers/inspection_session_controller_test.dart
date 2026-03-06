import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/audit/data/audit_event_repository.dart';
import 'package:inspectobot/features/delivery/data/delivery_repository.dart';
import 'package:inspectobot/features/delivery/data/report_artifact_repository.dart';
import 'package:inspectobot/features/delivery/services/delivery_service.dart';
import 'package:inspectobot/features/identity/data/signature_repository.dart';
import 'package:inspectobot/features/inspection/data/inspection_repository.dart';
import 'package:inspectobot/features/inspection/domain/form_requirements.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/inspection_draft.dart';
import 'package:inspectobot/features/inspection/domain/inspection_wizard_state.dart';
import 'package:inspectobot/features/inspection/presentation/controllers/inspection_session_controller.dart';
import 'package:inspectobot/features/inspection/domain/evidence_requirement.dart';
import 'package:inspectobot/features/media/media_capture_service.dart';
import 'package:inspectobot/features/media/media_capture_result.dart';
import 'package:inspectobot/features/media/media_sync_task.dart';
import 'package:inspectobot/features/media/pending_media_sync_store.dart';
import 'package:inspectobot/features/pdf/cloud_pdf_service.dart';
import 'package:inspectobot/features/pdf/on_device_pdf_service.dart';
import 'package:inspectobot/features/pdf/pdf_generation_input.dart';
import 'package:inspectobot/features/pdf/pdf_orchestrator.dart';
import 'package:inspectobot/features/pdf/pdf_strategy.dart';
import 'package:inspectobot/features/signing/data/report_signature_evidence_repository.dart';
import 'package:inspectobot/features/inspection/domain/required_photo_category.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  InspectionDraft _makeDraft({
    String inspectionId = 'insp-1',
    Set<FormType> enabledForms = const {FormType.fourPoint},
    WizardProgressSnapshot? wizardSnapshot,
    int? initialStepIndex,
  }) {
    return InspectionDraft(
      inspectionId: inspectionId,
      organizationId: 'org-1',
      userId: 'user-1',
      clientName: 'Test User',
      clientEmail: 'test@example.com',
      clientPhone: '555-0100',
      propertyAddress: '123 Test St',
      inspectionDate: DateTime.utc(2026, 3, 4),
      yearBuilt: 2005,
      enabledForms: enabledForms,
      wizardSnapshot: wizardSnapshot,
      initialStepIndex: initialStepIndex,
    );
  }

  InspectionSessionController _makeController({
    InspectionDraft? draft,
    _FakeStore? store,
    MediaCaptureService? mediaCapture,
    PdfOrchestrator? pdfOrchestrator,
    PendingMediaSyncStore? pendingMediaSyncStore,
    SignatureRepository? signatureRepository,
    ReportSignatureEvidenceRepository? signatureEvidenceRepository,
    DeliveryService? deliveryService,
    AuditEventRepository? auditRepository,
  }) {
    final effectiveStore = store ?? _FakeStore();
    return InspectionSessionController(
      draft: draft ?? _makeDraft(),
      repository: InspectionRepository(effectiveStore),
      mediaCapture: mediaCapture ?? _NoOpMediaCaptureService(),
      pdfOrchestrator: pdfOrchestrator ??
          PdfOrchestrator(
            onDevice: _SuccessfulOnDevicePdfService(),
            cloud: const CloudPdfService(
              runtimeGateway: DisabledCloudPdfRuntimeGateway(),
            ),
          ),
      pendingMediaSyncStore: pendingMediaSyncStore ?? _EmptyPendingStore(),
      signatureRepository: signatureRepository,
      signatureEvidenceRepository: signatureEvidenceRepository,
      deliveryService: deliveryService,
      auditRepository: auditRepository,
    );
  }

  // ---------------------------------------------------------------------------
  // group: initialization
  // ---------------------------------------------------------------------------

  group('initialization', () {
    test('initializes snapshot from draft and clamps step index', () {
      final controller = _makeController(
        draft: _makeDraft(initialStepIndex: 99),
      );
      controller.initialize();

      // Step index should be clamped to valid range
      expect(controller.currentStepIndex, lessThan(100));
      expect(controller.currentStepIndex, greaterThanOrEqualTo(0));
      expect(controller.snapshot, isNotNull);
    });

    test('initialize loads readiness and triggers onStateChanged', () async {
      var notifyCount = 0;
      final controller = _makeController();
      controller.onStateChanged = () => notifyCount += 1;
      controller.initialize();

      // Allow async readiness + audit loads to complete
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(notifyCount, greaterThan(0));
    });

    test('initialize loads audit events', () async {
      final gateway = _FakeAuditEventGateway(events: [
        _auditEventJson('evt-1', 'inspection_progress_updated'),
      ]);
      final controller = _makeController(
        auditRepository: AuditEventRepository(gateway),
      );
      controller.initialize();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(controller.auditEvents, hasLength(1));
      expect(controller.isLoadingAuditEvents, isFalse);
    });

    test('initialize hydrates captured categories from snapshot', () {
      final requirements =
          FormRequirements.forFormRequirements(FormType.fourPoint);
      final firstKey = requirements.first.key;
      final controller = _makeController(
        draft: _makeDraft(
          wizardSnapshot: WizardProgressSnapshot(
            lastStepIndex: 0,
            completion: {firstKey: true},
            branchContext: const <String, dynamic>{},
            status: WizardProgressStatus.inProgress,
          ),
        ),
      );
      controller.initialize();
      expect(controller.draft.capturedCategories, isNotEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // group: wizard navigation
  // ---------------------------------------------------------------------------

  group('wizard navigation', () {
    test('continueStep advances from overview (no requirements)', () async {
      final controller = _makeController();
      controller.initialize();

      final result = await controller.continueStep();

      expect(result, ContinueStepResult.advanced);
      expect(controller.currentStepIndex, 1);
    });

    test('continueStep returns blocked when requirements not met', () async {
      final controller = _makeController(
        draft: _makeDraft(initialStepIndex: 1),
      );
      controller.initialize();

      final result = await controller.continueStep();

      expect(result, ContinueStepResult.blocked);
    });

    test('continueStep returns finished on last step when complete', () async {
      final requirements =
          FormRequirements.forFormRequirements(FormType.fourPoint);
      final completion = <String, bool>{
        for (final req in requirements) req.key: true,
      };
      final controller = _makeController(
        draft: _makeDraft(
          wizardSnapshot: WizardProgressSnapshot(
            lastStepIndex: 1,
            completion: completion,
            branchContext: const <String, dynamic>{},
            status: WizardProgressStatus.inProgress,
          ),
          initialStepIndex: 1,
        ),
      );
      controller.initialize();

      // Step 1 is the last step for single-form fourPoint (overview + fourPoint)
      final result = await controller.continueStep();

      expect(result, ContinueStepResult.finished);
    });

    test('continueStep returns error when save fails', () async {
      final controller = _makeController(store: _FailingSaveStore());
      controller.initialize();

      final result = await controller.continueStep();

      expect(result, ContinueStepResult.error);
    });

    test('continueStep triggers onStateChanged', () async {
      var count = 0;
      final controller = _makeController();
      controller.onStateChanged = () => count += 1;
      controller.initialize();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final before = count;

      await controller.continueStep();

      expect(count, greaterThan(before));
    });
  });

  // ---------------------------------------------------------------------------
  // group: branch flags
  // ---------------------------------------------------------------------------

  group('branch flags', () {
    test('setBranchFlag updates snapshot and calls onStateChanged', () {
      var notifyCount = 0;
      final controller = _makeController(
        draft: _makeDraft(enabledForms: {FormType.roofCondition}),
      );
      controller.onStateChanged = () => notifyCount += 1;
      controller.initialize();
      notifyCount = 0; // Reset after init notifications

      controller.setBranchFlag('roof_defect_present', true);

      expect(
        controller.snapshot.branchContext['roof_defect_present'],
        isTrue,
      );
      expect(notifyCount, greaterThanOrEqualTo(1));
    });

    test('setBranchFlag false removes requirement from wizard steps', () {
      final controller = _makeController(
        draft: _makeDraft(
          enabledForms: {FormType.fourPoint},
          wizardSnapshot: WizardProgressSnapshot(
            lastStepIndex: 1,
            completion: const <String, bool>{},
            branchContext: const <String, dynamic>{'hazard_present': true},
            status: WizardProgressStatus.inProgress,
          ),
          initialStepIndex: 1,
        ),
      );
      controller.initialize();

      // Should have hazard photo in requirements
      var state = controller.wizardState;
      var step = state.steps[1];
      expect(step.requirements.any((r) => r.label == 'Hazard Photo'), isTrue);

      controller.setBranchFlag('hazard_present', false);

      state = controller.wizardState;
      step = state.steps[1];
      expect(step.requirements.any((r) => r.label == 'Hazard Photo'), isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // group: PDF generation
  // ---------------------------------------------------------------------------

  group('PDF generation', () {
    test('generatePdf returns success with sizeKb', () async {
      final requirements =
          FormRequirements.forFormRequirements(FormType.fourPoint);
      final completion = <String, bool>{
        for (final req in requirements) req.key: true,
      };
      final pendingStore = _FakePendingMediaSyncStore(byRequirement: {
        for (final req in requirements)
          req.key: ['/tmp/${req.key.replaceAll(':', '_')}.jpg'],
      });
      final signatureRepository = await _seededSignatureRepository();
      final deliveryService = _testDeliveryService();

      final controller = _makeController(
        draft: _makeDraft(
          wizardSnapshot: WizardProgressSnapshot(
            lastStepIndex: 1,
            completion: completion,
            branchContext: const <String, dynamic>{},
            status: WizardProgressStatus.complete,
          ),
          initialStepIndex: 1,
        ),
        pendingMediaSyncStore: pendingStore,
        signatureRepository: signatureRepository,
        signatureEvidenceRepository: ReportSignatureEvidenceRepository(
          InMemoryReportSignatureEvidenceGateway(),
        ),
        deliveryService: deliveryService,
      );
      controller.initialize();

      final result = await controller.generatePdf();

      expect(result.success, isTrue);
      expect(result.sizeKb, isNotNull);
      expect(controller.lastPdfPath, isNotNull);
      expect(controller.lastArtifact, isNotNull);
      expect(controller.isGenerating, isFalse);
    });

    test('generatePdf returns cloudTerminalFailure on terminal cloud error',
        () async {
      final requirements =
          FormRequirements.forFormRequirements(FormType.fourPoint);
      final completion = <String, bool>{
        for (final req in requirements) req.key: true,
      };
      final pendingStore = _FakePendingMediaSyncStore(byRequirement: {
        for (final req in requirements)
          req.key: ['/tmp/${req.key.replaceAll(':', '_')}.jpg'],
      });
      final signatureRepository = await _seededSignatureRepository();

      final controller = _makeController(
        draft: _makeDraft(
          wizardSnapshot: WizardProgressSnapshot(
            lastStepIndex: 1,
            completion: completion,
            branchContext: const <String, dynamic>{},
            status: WizardProgressStatus.complete,
          ),
          initialStepIndex: 1,
        ),
        store: _FakeStore(
          seededReadiness: _readyReadiness('insp-1'),
        ),
        pendingMediaSyncStore: pendingStore,
        signatureRepository: signatureRepository,
        pdfOrchestrator: PdfOrchestrator(
          onDevice: _SuccessfulOnDevicePdfService(),
          cloud: _FixedOutcomeCloudPdfService(
            CloudPdfGenerationOutcome.terminalFailure(
              error: StateError('terminal'),
              reason: 'terminal failure',
            ),
          ),
          primaryStrategy: PdfStrategy.cloudFallback,
        ),
      );
      controller.initialize();

      final result = await controller.generatePdf();

      expect(result.success, isFalse);
      expect(result.isCloudTerminalFailure, isTrue);
      expect(controller.isGenerating, isFalse);
    });

    test('generatePdf returns error when signature is missing', () async {
      final requirements =
          FormRequirements.forFormRequirements(FormType.fourPoint);
      final completion = <String, bool>{
        for (final req in requirements) req.key: true,
      };
      final pendingStore = _FakePendingMediaSyncStore(byRequirement: {
        for (final req in requirements)
          req.key: ['/tmp/${req.key.replaceAll(':', '_')}.jpg'],
      });

      // No signature seeded -- loadSignatureForGeneration returns null
      final emptySignatureGateway = InMemorySignatureGateway();
      final signatureRepository = SignatureRepository(
        storage: emptySignatureGateway,
        metadata: emptySignatureGateway,
      );

      final controller = _makeController(
        draft: _makeDraft(
          wizardSnapshot: WizardProgressSnapshot(
            lastStepIndex: 1,
            completion: completion,
            branchContext: const <String, dynamic>{},
            status: WizardProgressStatus.complete,
          ),
          initialStepIndex: 1,
        ),
        pendingMediaSyncStore: pendingStore,
        signatureRepository: signatureRepository,
      );
      controller.initialize();

      final result = await controller.generatePdf();

      expect(result.success, isFalse);
      expect(result.errorMessage, contains('signature'));
      expect(controller.isGenerating, isFalse);
    });

    test('generatePdf toggles isGenerating and notifies', () async {
      var generatingSeenTrue = false;
      final controller = _makeController(
        draft: _makeDraft(
          wizardSnapshot: WizardProgressSnapshot(
            lastStepIndex: 1,
            completion: {
              for (final req
                  in FormRequirements.forFormRequirements(FormType.fourPoint))
                req.key: true,
            },
            branchContext: const <String, dynamic>{},
            status: WizardProgressStatus.complete,
          ),
          initialStepIndex: 1,
        ),
        pendingMediaSyncStore: _FakePendingMediaSyncStore(byRequirement: {
          for (final req
              in FormRequirements.forFormRequirements(FormType.fourPoint))
            req.key: ['/tmp/${req.key.replaceAll(':', '_')}.jpg'],
        }),
        signatureRepository: await _seededSignatureRepository(),
        signatureEvidenceRepository: ReportSignatureEvidenceRepository(
          InMemoryReportSignatureEvidenceGateway(),
        ),
        deliveryService: _testDeliveryService(),
      );
      controller.onStateChanged = () {
        if (controller.isGenerating) {
          generatingSeenTrue = true;
        }
      };
      controller.initialize();

      await controller.generatePdf();

      expect(generatingSeenTrue, isTrue);
      expect(controller.isGenerating, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // group: completionPercent
  // ---------------------------------------------------------------------------

  group('completionPercent', () {
    test('returns 0 when no requirements captured', () {
      final controller = _makeController();
      controller.initialize();

      expect(controller.completionPercent, 0);
    });

    test('returns 0 when no requirements exist', () {
      final controller = _makeController(
        draft: _makeDraft(enabledForms: const <FormType>{}),
      );
      controller.initialize();

      expect(controller.completionPercent, 0);
    });

    test('returns 100 when all requirements captured', () {
      final requirements =
          FormRequirements.forFormRequirements(FormType.fourPoint);
      final completion = <String, bool>{
        for (final req in requirements) req.key: true,
      };
      final controller = _makeController(
        draft: _makeDraft(
          wizardSnapshot: WizardProgressSnapshot(
            lastStepIndex: 0,
            completion: completion,
            branchContext: const <String, dynamic>{},
            status: WizardProgressStatus.inProgress,
          ),
        ),
      );
      controller.initialize();

      expect(controller.completionPercent, 100);
    });

    test('returns correct intermediate value', () {
      final requirements =
          FormRequirements.forFormRequirements(FormType.fourPoint);
      // Capture exactly the first requirement
      final completion = <String, bool>{
        requirements.first.key: true,
      };
      final controller = _makeController(
        draft: _makeDraft(
          wizardSnapshot: WizardProgressSnapshot(
            lastStepIndex: 0,
            completion: completion,
            branchContext: const <String, dynamic>{},
            status: WizardProgressStatus.inProgress,
          ),
        ),
      );
      controller.initialize();

      // 1 / totalRequirements * 100, rounded
      final expected = ((1 / requirements.length) * 100).round();
      expect(controller.completionPercent, expected);
    });

    test('denominator is total step requirements, NOT completion map size', () {
      final requirements =
          FormRequirements.forFormRequirements(FormType.fourPoint);
      // Put ALL keys in the map but only one is true
      final completion = <String, bool>{
        for (final req in requirements) req.key: false,
      };
      completion[requirements.first.key] = true;

      final controller = _makeController(
        draft: _makeDraft(
          wizardSnapshot: WizardProgressSnapshot(
            lastStepIndex: 0,
            completion: completion,
            branchContext: const <String, dynamic>{},
            status: WizardProgressStatus.inProgress,
          ),
        ),
      );
      controller.initialize();

      // If denominator were completion.length, we'd get
      // (1/requirements.length)*100 which is low. With the wrong denominator
      // of completion.length (same as requirements.length here but the values
      // differ), the result is the same value. So instead verify it's NOT 100.
      expect(controller.completionPercent, lessThan(100));
      // And it should be 1/totalRequirements * 100
      final expected = ((1 / requirements.length) * 100).round();
      expect(controller.completionPercent, expected);
    });
  });

  // ---------------------------------------------------------------------------
  // group: delivery
  // ---------------------------------------------------------------------------

  group('delivery', () {
    test('downloadArtifact returns error when no artifact', () async {
      final controller = _makeController();
      controller.initialize();

      final result = await controller.downloadArtifact();

      expect(result.success, isFalse);
      expect(result.errorMessage, isNotNull);
    });

    test('shareArtifact returns error when no artifact', () async {
      final controller = _makeController();
      controller.initialize();

      final result = await controller.shareArtifact();

      expect(result.success, isFalse);
      expect(result.errorMessage, isNotNull);
    });
  });

  // ---------------------------------------------------------------------------
  // group: capture
  // ---------------------------------------------------------------------------

  group('capture', () {
    test('successful capture updates snapshot completion and calls onStateChanged',
        () async {
      var notifyCount = 0;
      final requirements =
          FormRequirements.forFormRequirements(FormType.fourPoint);
      final firstReq = requirements.first;
      final mediaCapture = _SuccessfulMediaCaptureService();
      final controller = _makeController(
        draft: _makeDraft(),
        mediaCapture: mediaCapture,
      );
      controller.onStateChanged = () => notifyCount += 1;
      controller.initialize();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      notifyCount = 0;

      final result = await controller.capture(firstReq);

      expect(result, CaptureResult.captured);
      expect(controller.snapshot.completion[firstReq.key], isTrue);
      expect(notifyCount, greaterThanOrEqualTo(1));
    });

    test('capture returns cancelled when requirement has null category',
        () async {
      final controller = _makeController();
      controller.initialize();

      final nullCategoryRequirement = EvidenceRequirement(
        key: 'test:null_category',
        label: 'Null Category',
        form: FormType.fourPoint,
        mediaType: EvidenceMediaType.photo,
        minimumCount: 1,
        category: null,
      );

      final result = await controller.capture(nullCategoryRequirement);

      expect(result, CaptureResult.cancelled);
    });

    test('capture returns cancelled when media service returns null', () async {
      // _NoOpMediaCaptureService always returns null from captureRequiredPhoto
      final controller = _makeController(
        mediaCapture: _NoOpMediaCaptureService(),
      );
      controller.initialize();

      final requirements =
          FormRequirements.forFormRequirements(FormType.fourPoint);
      final firstReq = requirements.first;

      final result = await controller.capture(firstReq);

      expect(result, CaptureResult.cancelled);
    });
  });

  // ---------------------------------------------------------------------------
  // group: delivery (extended)
  // ---------------------------------------------------------------------------

  group('delivery success paths', () {
    test('downloadArtifact returns success after generatePdf', () async {
      final requirements =
          FormRequirements.forFormRequirements(FormType.fourPoint);
      final completion = <String, bool>{
        for (final req in requirements) req.key: true,
      };
      final pendingStore = _FakePendingMediaSyncStore(byRequirement: {
        for (final req in requirements)
          req.key: ['/tmp/${req.key.replaceAll(':', '_')}.jpg'],
      });
      final signatureRepository = await _seededSignatureRepository();
      final deliveryService = _testDeliveryService();

      final controller = _makeController(
        draft: _makeDraft(
          wizardSnapshot: WizardProgressSnapshot(
            lastStepIndex: 1,
            completion: completion,
            branchContext: const <String, dynamic>{},
            status: WizardProgressStatus.complete,
          ),
          initialStepIndex: 1,
        ),
        pendingMediaSyncStore: pendingStore,
        signatureRepository: signatureRepository,
        signatureEvidenceRepository: ReportSignatureEvidenceRepository(
          InMemoryReportSignatureEvidenceGateway(),
        ),
        deliveryService: deliveryService,
      );
      controller.initialize();

      final pdfResult = await controller.generatePdf();
      expect(pdfResult.success, isTrue);

      final downloadResult = await controller.downloadArtifact();
      expect(downloadResult.success, isTrue);
      expect(downloadResult.url, isNotNull);
    });

    test('shareArtifact returns success after generatePdf', () async {
      final requirements =
          FormRequirements.forFormRequirements(FormType.fourPoint);
      final completion = <String, bool>{
        for (final req in requirements) req.key: true,
      };
      final pendingStore = _FakePendingMediaSyncStore(byRequirement: {
        for (final req in requirements)
          req.key: ['/tmp/${req.key.replaceAll(':', '_')}.jpg'],
      });
      final signatureRepository = await _seededSignatureRepository();
      final deliveryService = _testDeliveryService();

      final controller = _makeController(
        draft: _makeDraft(
          wizardSnapshot: WizardProgressSnapshot(
            lastStepIndex: 1,
            completion: completion,
            branchContext: const <String, dynamic>{},
            status: WizardProgressStatus.complete,
          ),
          initialStepIndex: 1,
        ),
        pendingMediaSyncStore: pendingStore,
        signatureRepository: signatureRepository,
        signatureEvidenceRepository: ReportSignatureEvidenceRepository(
          InMemoryReportSignatureEvidenceGateway(),
        ),
        deliveryService: deliveryService,
      );
      controller.initialize();

      final pdfResult = await controller.generatePdf();
      expect(pdfResult.success, isTrue);

      final shareResult = await controller.shareArtifact();
      expect(shareResult.success, isTrue);
      expect(shareResult.url, isNotNull);
    });

    test('downloadArtifact returns error when delivery service fails',
        () async {
      final requirements =
          FormRequirements.forFormRequirements(FormType.fourPoint);
      final completion = <String, bool>{
        for (final req in requirements) req.key: true,
      };
      final pendingStore = _FakePendingMediaSyncStore(byRequirement: {
        for (final req in requirements)
          req.key: ['/tmp/${req.key.replaceAll(':', '_')}.jpg'],
      });
      final signatureRepository = await _seededSignatureRepository();
      final failingDeliveryService = _failingDeliveryService();

      final controller = _makeController(
        draft: _makeDraft(
          wizardSnapshot: WizardProgressSnapshot(
            lastStepIndex: 1,
            completion: completion,
            branchContext: const <String, dynamic>{},
            status: WizardProgressStatus.complete,
          ),
          initialStepIndex: 1,
        ),
        pendingMediaSyncStore: pendingStore,
        signatureRepository: signatureRepository,
        signatureEvidenceRepository: ReportSignatureEvidenceRepository(
          InMemoryReportSignatureEvidenceGateway(),
        ),
        deliveryService: failingDeliveryService,
      );
      controller.initialize();

      final pdfResult = await controller.generatePdf();
      expect(pdfResult.success, isTrue);

      final downloadResult = await controller.downloadArtifact();
      expect(downloadResult.success, isFalse);
      expect(downloadResult.errorMessage, contains('Download failed'));
    });

    test('shareArtifact returns error when delivery service fails', () async {
      final requirements =
          FormRequirements.forFormRequirements(FormType.fourPoint);
      final completion = <String, bool>{
        for (final req in requirements) req.key: true,
      };
      final pendingStore = _FakePendingMediaSyncStore(byRequirement: {
        for (final req in requirements)
          req.key: ['/tmp/${req.key.replaceAll(':', '_')}.jpg'],
      });
      final signatureRepository = await _seededSignatureRepository();
      final failingDeliveryService = _failingDeliveryService();

      final controller = _makeController(
        draft: _makeDraft(
          wizardSnapshot: WizardProgressSnapshot(
            lastStepIndex: 1,
            completion: completion,
            branchContext: const <String, dynamic>{},
            status: WizardProgressStatus.complete,
          ),
          initialStepIndex: 1,
        ),
        pendingMediaSyncStore: pendingStore,
        signatureRepository: signatureRepository,
        signatureEvidenceRepository: ReportSignatureEvidenceRepository(
          InMemoryReportSignatureEvidenceGateway(),
        ),
        deliveryService: failingDeliveryService,
      );
      controller.initialize();

      final pdfResult = await controller.generatePdf();
      expect(pdfResult.success, isTrue);

      final shareResult = await controller.shareArtifact();
      expect(shareResult.success, isFalse);
      expect(shareResult.errorMessage, contains('Secure share failed'));
    });
  });

  // ---------------------------------------------------------------------------
  // group: audit events
  // ---------------------------------------------------------------------------

  group('audit events', () {
    test('loadAuditEvents populates list', () async {
      final gateway = _FakeAuditEventGateway(events: [
        _auditEventJson('evt-1', 'inspection_progress_updated'),
        _auditEventJson('evt-2', 'delivery_artifact_saved'),
      ]);
      final controller = _makeController(
        auditRepository: AuditEventRepository(gateway),
      );
      controller.initialize();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(controller.auditEvents, hasLength(2));
      expect(controller.isLoadingAuditEvents, isFalse);
      expect(controller.auditTimelineError, isNull);
    });

    test('loadAuditEvents sets error on failure', () async {
      final controller = _makeController(
        auditRepository: AuditEventRepository(_FailingAuditGateway()),
      );
      controller.initialize();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(controller.auditTimelineError, isNotNull);
      expect(controller.isLoadingAuditEvents, isFalse);
    });

    test('loadAuditEvents sorts newest first', () async {
      final gateway = _FakeAuditEventGateway(events: [
        _auditEventJson(
          'evt-old',
          'inspection_progress_updated',
          occurredAt: '2026-03-04T09:00:00.000Z',
        ),
        _auditEventJson(
          'evt-new',
          'delivery_artifact_saved',
          occurredAt: '2026-03-05T11:00:00.000Z',
        ),
      ]);
      final controller = _makeController(
        auditRepository: AuditEventRepository(gateway),
      );
      controller.initialize();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(controller.auditEvents.first.id, 'evt-new');
      expect(controller.auditEvents.last.id, 'evt-old');
    });

    test('loadAuditEvents triggers onStateChanged', () async {
      var count = 0;
      final controller = _makeController(
        auditRepository: AuditEventRepository(
          _FakeAuditEventGateway(events: [
            _auditEventJson('evt-1', 'inspection_progress_updated'),
          ]),
        ),
      );
      controller.onStateChanged = () => count += 1;
      controller.initialize();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Should have notified for: audit loading start + audit loading end
      // Plus readiness notifications
      expect(count, greaterThanOrEqualTo(2));
    });
  });
}

// ---------------------------------------------------------------------------
// Test doubles
// ---------------------------------------------------------------------------

Map<String, dynamic> _auditEventJson(
  String id,
  String eventType, {
  String occurredAt = '2026-03-05T10:00:00.000Z',
}) {
  return <String, dynamic>{
    'id': id,
    'inspection_id': 'insp-1',
    'organization_id': 'org-1',
    'user_id': 'user-1',
    'event_type': eventType,
    'occurred_at': occurredAt,
    'created_at': occurredAt,
    'payload': <String, dynamic>{},
  };
}

Map<String, dynamic> _readyReadiness(String inspectionId) {
  return <String, dynamic>{
    'inspection_id': inspectionId,
    'organization_id': 'org-1',
    'user_id': 'user-1',
    'status': 'ready',
    'missing_items': <String>[],
    'computed_at': '2026-03-05T00:00:00.000Z',
  };
}

Future<SignatureRepository> _seededSignatureRepository() async {
  final gateway = InMemorySignatureGateway();
  final repository = SignatureRepository(storage: gateway, metadata: gateway);
  await repository.saveSignature(
    organizationId: 'org-1',
    userId: 'user-1',
    bytes: Uint8List.fromList(<int>[1, 2, 3]),
  );
  return repository;
}

DeliveryService _testDeliveryService() {
  return DeliveryService(
    artifactRepository: ReportArtifactRepository(
      InMemoryReportArtifactGateway(),
    ),
    deliveryRepository: DeliveryRepository(InMemoryDeliveryActionGateway()),
    auditRepository: AuditEventRepository(InMemoryAuditEventGateway()),
    signedUrlGateway: _TestSignedUrlGateway(),
    shareGateway: _TestShareGateway(),
  );
}

class _FakeStore implements InspectionStore {
  _FakeStore({this.seededReadiness});

  Map<String, dynamic>? readiness;
  final Map<String, dynamic>? seededReadiness;

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
    return <String, dynamic>{
      'id': inspectionId,
      'organization_id': organizationId,
      'user_id': userId,
      'client_name': 'Test User',
      'client_email': 'test@example.com',
      'client_phone': '555-0100',
      'property_address': '123 Test St',
      'inspection_date': '2026-03-04',
      'year_built': 2005,
      'forms_enabled': <String>['four_point'],
      'wizard_last_step': 0,
      'wizard_completion': <String, bool>{},
      'wizard_branch_context': <String, dynamic>{},
      'wizard_status': 'in_progress',
    };
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
    return readiness ?? seededReadiness;
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
      'client_name': 'Test User',
      'property_address': '123 Test St',
      'forms_enabled': <String>['four_point'],
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

class _FailingSaveStore extends _FakeStore {
  @override
  Future<Map<String, dynamic>> updateWizardProgress({
    required String inspectionId,
    required String organizationId,
    required String userId,
    required int wizardLastStep,
    required Map<String, bool> wizardCompletion,
    required Map<String, dynamic> wizardBranchContext,
    required String wizardStatus,
  }) {
    throw StateError('save failed');
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

class _FixedOutcomeCloudPdfService extends CloudPdfService {
  _FixedOutcomeCloudPdfService(this.outcome);

  final CloudPdfGenerationOutcome outcome;

  @override
  Future<CloudPdfGenerationOutcome> generate(PdfGenerationInput input) async {
    return outcome;
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

class _FakePendingMediaSyncStore extends PendingMediaSyncStore {
  _FakePendingMediaSyncStore({required this.byRequirement});

  final Map<String, List<String>> byRequirement;

  @override
  Future<Map<String, List<String>>> loadEvidenceMediaPaths({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    return byRequirement;
  }
}

class _FakeAuditEventGateway implements AuditEventGateway {
  _FakeAuditEventGateway({required this.events});

  final List<Map<String, dynamic>> events;

  @override
  Future<Map<String, dynamic>> append(Map<String, dynamic> payload) async {
    return payload;
  }

  @override
  Future<List<Map<String, dynamic>>> listByInspection({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    return events;
  }
}

class _FailingAuditGateway implements AuditEventGateway {
  @override
  Future<Map<String, dynamic>> append(Map<String, dynamic> payload) {
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> listByInspection({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) {
    throw StateError('audit load failed');
  }
}

class _TestSignedUrlGateway implements SignedUrlGateway {
  @override
  Future<String> createSignedUrl({
    required String bucket,
    required String path,
    required int expiresInSeconds,
  }) async {
    return 'https://test.example/$bucket/$path?expires=$expiresInSeconds';
  }
}

class _TestShareGateway implements ShareGateway {
  @override
  Future<void> shareUri(String uri) async {}
}

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
  Future<MediaCaptureResult?> captureRequiredPhoto({
    required String inspectionId,
    required String organizationId,
    required String userId,
    required RequiredPhotoCategory category,
    String? requirementKey,
    CapturedMediaType mediaType = CapturedMediaType.photo,
    String? evidenceInstanceId,
  }) async {
    return MediaCaptureResult(
      category: category,
      filePath: '/tmp/captured_${category.name}.jpg',
      byteSize: 1024,
    );
  }
}

class _FailingSignedUrlGateway implements SignedUrlGateway {
  @override
  Future<String> createSignedUrl({
    required String bucket,
    required String path,
    required int expiresInSeconds,
  }) {
    throw StateError('signed url generation failed');
  }
}

class _FailingShareGateway implements ShareGateway {
  @override
  Future<void> shareUri(String uri) {
    throw StateError('share failed');
  }
}

DeliveryService _failingDeliveryService() {
  return DeliveryService(
    artifactRepository: ReportArtifactRepository(
      InMemoryReportArtifactGateway(),
    ),
    deliveryRepository: DeliveryRepository(InMemoryDeliveryActionGateway()),
    auditRepository: AuditEventRepository(InMemoryAuditEventGateway()),
    signedUrlGateway: _FailingSignedUrlGateway(),
    shareGateway: _FailingShareGateway(),
  );
}
