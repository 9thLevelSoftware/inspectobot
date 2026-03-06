import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/audit/data/audit_event_repository.dart';
import 'package:inspectobot/features/delivery/data/delivery_repository.dart';
import 'package:inspectobot/features/delivery/data/report_artifact_repository.dart';
import 'package:inspectobot/features/delivery/services/delivery_service.dart';
import 'package:inspectobot/features/identity/data/signature_repository.dart';
import 'package:inspectobot/features/inspection/data/inspection_repository.dart';
import 'package:inspectobot/features/inspection/domain/evidence_requirement.dart';
import 'package:inspectobot/features/inspection/domain/form_requirements.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/inspection_draft.dart';
import 'package:inspectobot/features/inspection/domain/inspection_wizard_state.dart';
import 'package:inspectobot/features/inspection/presentation/form_checklist_page.dart';
import 'package:inspectobot/features/media/pending_media_sync_store.dart';
import 'package:inspectobot/features/pdf/cloud_pdf_service.dart';
import 'package:inspectobot/features/pdf/on_device_pdf_service.dart';
import 'package:inspectobot/features/pdf/pdf_generation_input.dart';
import 'package:inspectobot/features/pdf/pdf_orchestrator.dart';
import 'package:inspectobot/features/signing/data/report_signature_evidence_repository.dart';
import 'package:inspectobot/features/signing/domain/report_signature_evidence.dart';
import 'package:inspectobot/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Tab navigation helper
// ---------------------------------------------------------------------------

/// Taps the [SegmentedButton] tab with the given [tabLabel].
Future<void> switchToTab(WidgetTester tester, String tabLabel) async {
  await tester.tap(find.text(tabLabel));
  await tester.pumpAndSettle();
}

// ---------------------------------------------------------------------------
// Pump helper
// ---------------------------------------------------------------------------

/// Pumps a [FormChecklistPage] wrapped in [MaterialApp] with [AppTheme.dark()].
Future<void> pumpChecklistPage(
  WidgetTester tester, {
  required InspectionDraft draft,
  InspectionRepository? repository,
  SignatureRepository? signatureRepository,
  ReportSignatureEvidenceRepository? signatureEvidenceRepository,
  DeliveryService? deliveryService,
  PendingMediaSyncStore? pendingMediaSyncStore,
  PdfOrchestrator? pdfOrchestrator,
  CloudPdfService? cloudPdfService,
  AuditEventRepository? auditRepository,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      home: FormChecklistPage(
        draft: draft,
        repository: repository,
        signatureRepository: signatureRepository,
        signatureEvidenceRepository: signatureEvidenceRepository,
        deliveryService: deliveryService,
        pendingMediaSyncStore: pendingMediaSyncStore,
        pdfOrchestrator: pdfOrchestrator,
        cloudPdfService: cloudPdfService,
        auditRepository: auditRepository,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Test fixture builders
// ---------------------------------------------------------------------------

/// Creates an [InspectionDraft] with sensible defaults.
InspectionDraft buildTestDraft({
  String inspectionId = 'insp-1',
  String organizationId = 'org-1',
  String userId = 'user-1',
  String clientName = 'Jane Doe',
  String clientEmail = 'jane@example.com',
  String clientPhone = '555-0100',
  String propertyAddress = '123 Palm Ave',
  DateTime? inspectionDate,
  int yearBuilt = 2008,
  Set<FormType> enabledForms = const {FormType.fourPoint},
  WizardProgressSnapshot? wizardSnapshot,
  int? initialStepIndex,
}) {
  return InspectionDraft(
    inspectionId: inspectionId,
    organizationId: organizationId,
    userId: userId,
    clientName: clientName,
    clientEmail: clientEmail,
    clientPhone: clientPhone,
    propertyAddress: propertyAddress,
    inspectionDate: inspectionDate ?? DateTime.utc(2026, 3, 4),
    yearBuilt: yearBuilt,
    enabledForms: enabledForms,
    wizardSnapshot: wizardSnapshot,
    initialStepIndex: initialStepIndex,
  );
}

/// Creates a ready draft with all fourPoint requirements complete.
InspectionDraft readyDraft(String inspectionId) {
  return InspectionDraft(
    inspectionId: inspectionId,
    organizationId: 'org-1',
    userId: 'user-1',
    clientName: 'Cloud Branch User',
    clientEmail: 'cloud@example.com',
    clientPhone: '555-0100',
    propertyAddress: '131 Branch St',
    inspectionDate: DateTime.utc(2026, 3, 4),
    yearBuilt: 2004,
    enabledForms: {FormType.fourPoint},
    wizardSnapshot: WizardProgressSnapshot(
      lastStepIndex: 1,
      completion: {
        for (final requirement in FormRequirements.forFormRequirements(
          FormType.fourPoint,
        ))
          requirement.key: true,
      },
      branchContext: const <String, dynamic>{},
      status: WizardProgressStatus.complete,
    ),
    initialStepIndex: 1,
  );
}

/// Creates a readiness JSON map with status='ready'.
Map<String, dynamic> readyReadiness(String inspectionId) {
  return <String, dynamic>{
    'inspection_id': inspectionId,
    'organization_id': 'org-1',
    'user_id': 'user-1',
    'status': 'ready',
    'missing_items': <String>[],
    'computed_at': '2026-03-05T00:00:00.000Z',
  };
}

/// Creates a [FakePendingMediaSyncStore] pre-populated with paths for all
/// requirements.
FakePendingMediaSyncStore pendingStoreFor(
  List<EvidenceRequirement> requirements,
) {
  return FakePendingMediaSyncStore(
    byRequirement: {
      for (final requirement in requirements)
        requirement.key: <String>[
          '/tmp/${requirement.key.replaceAll(':', '_')}.jpg',
        ],
    },
  );
}

/// Creates and seeds a [SignatureRepository] with test data.
Future<SignatureRepository> seededSignatureRepository() async {
  final gateway = InMemorySignatureGateway();
  final repository = SignatureRepository(storage: gateway, metadata: gateway);
  await repository.saveSignature(
    organizationId: 'org-1',
    userId: 'user-1',
    bytes: Uint8List.fromList(<int>[1, 2, 3]),
  );
  return repository;
}

/// Creates a test [DeliveryService] with in-memory gateways.
DeliveryService testDeliveryService() {
  return DeliveryService(
    artifactRepository: ReportArtifactRepository(
      InMemoryReportArtifactGateway(),
    ),
    deliveryRepository: DeliveryRepository(InMemoryDeliveryActionGateway()),
    auditRepository: AuditEventRepository(InMemoryAuditEventGateway()),
    signedUrlGateway: TestSignedUrlGateway(),
    shareGateway: TestShareGateway(),
  );
}

// ---------------------------------------------------------------------------
// Fake stores
// ---------------------------------------------------------------------------

class FakeChecklistStore implements InspectionStore {
  FakeChecklistStore({this.seededReadiness});

  int updateCalls = 0;
  Map<String, dynamic>? lastWizardBranchContext;
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
      'client_name': 'Jane Doe',
      'client_email': 'jane@example.com',
      'client_phone': '555-0100',
      'property_address': '123 Palm Ave',
      'inspection_date': '2026-03-04',
      'year_built': 2004,
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
    updateCalls += 1;
    lastWizardBranchContext = Map<String, dynamic>.from(wizardBranchContext);
    return <String, dynamic>{
      'id': inspectionId,
      'organization_id': organizationId,
      'user_id': userId,
      'client_name': 'Jane Doe',
      'property_address': '123 Palm Ave',
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

// ---------------------------------------------------------------------------
// Fake services
// ---------------------------------------------------------------------------

class FailingSignatureEvidenceRepository
    extends ReportSignatureEvidenceRepository {
  FailingSignatureEvidenceRepository()
      : super(InMemoryReportSignatureEvidenceGateway());

  @override
  Future<ReportSignatureEvidence> persist({
    required PdfGenerationInput input,
    required String signerRole,
    required String signatureHash,
    required ReportSignatureAttribution attribution,
    DateTime? signedAt,
  }) {
    throw StateError('evidence write failed');
  }
}

class SuccessfulOnDevicePdfService extends OnDevicePdfService {
  @override
  Future<File> generate(PdfGenerationInput input) async {
    final file = File(
      '${Directory.systemTemp.path}/inspectobot_test_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(<int>[1, 2, 3], flush: true);
    return file;
  }
}

class OverBudgetOnDevicePdfService extends OnDevicePdfService {
  @override
  Future<File> generate(PdfGenerationInput input) {
    throw const PdfGenerationSizeBudgetExceeded(
      message:
          'PDF exceeded configured size budget (bytes=2097152, max=1048576, attempts=2).',
      generatedBytes: 2097152,
      maxBytes: 1048576,
      attempts: 2,
    );
  }
}

class CapturingOnDevicePdfService extends OnDevicePdfService {
  PdfGenerationInput? lastInput;

  @override
  Future<File> generate(PdfGenerationInput input) async {
    lastInput = input;
    final file = File(
      '${Directory.systemTemp.path}/inspectobot_capture_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(<int>[3, 2, 1], flush: true);
    return file;
  }
}

class FixedOutcomeCloudPdfService extends CloudPdfService {
  FixedOutcomeCloudPdfService(this.outcome);

  final CloudPdfGenerationOutcome outcome;
  int callCount = 0;

  @override
  Future<CloudPdfGenerationOutcome> generate(PdfGenerationInput input) async {
    callCount += 1;
    return outcome;
  }
}

class StaticCloudPdfRuntimeGateway implements CloudPdfRuntimeGateway {
  StaticCloudPdfRuntimeGateway(this.outcome);

  final CloudPdfGenerationOutcome outcome;

  @override
  Future<CloudPdfGenerationOutcome> generate(PdfGenerationInput input) async {
    return outcome;
  }
}

// ---------------------------------------------------------------------------
// Fake stores (pending media, audit, etc.)
// ---------------------------------------------------------------------------

class FakePendingMediaSyncStore extends PendingMediaSyncStore {
  FakePendingMediaSyncStore({required this.byRequirement});

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

class RecordingAuditEventGateway implements AuditEventGateway {
  RecordingAuditEventGateway({required this.events});

  final List<Map<String, dynamic>> events;
  String? lastInspectionId;
  String? lastOrganizationId;
  String? lastUserId;

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
    lastInspectionId = inspectionId;
    lastOrganizationId = organizationId;
    lastUserId = userId;
    return events;
  }
}

class FailingAuditEventGateway implements AuditEventGateway {
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

class TestSignedUrlGateway implements SignedUrlGateway {
  @override
  Future<String> createSignedUrl({
    required String bucket,
    required String path,
    required int expiresInSeconds,
  }) async {
    return 'https://example.test/$bucket/$path?expires=$expiresInSeconds';
  }
}

class TestShareGateway implements ShareGateway {
  @override
  Future<void> shareUri(String uri) async {}
}

// ---------------------------------------------------------------------------
// High-level pump helper for PDF generation tests
// ---------------------------------------------------------------------------

/// Pumps a [FormChecklistPage] pre-configured for PDF generation tests.
///
/// Sets up a ready draft, seeded signature, delivery service, and
/// pending media store. Returns a [PdfTestHarness] for accessing the
/// injected test doubles.
Future<PdfTestHarness> pumpPdfReadyPage(
  WidgetTester tester, {
  required String inspectionId,
  PdfOrchestrator? pdfOrchestrator,
  CloudPdfService? cloudPdfService,
  DeliveryService? deliveryService,
  FakeChecklistStore? store,
}) async {
  final requirements =
      FormRequirements.forFormRequirements(FormType.fourPoint);
  final effectiveStore = store ??
      FakeChecklistStore(seededReadiness: readyReadiness(inspectionId));
  final signatureRepo = await seededSignatureRepository();
  final pendingStore = pendingStoreFor(requirements);
  final effectiveDelivery = deliveryService ?? testDeliveryService();

  await pumpChecklistPage(
    tester,
    draft: readyDraft(inspectionId),
    repository: InspectionRepository(effectiveStore),
    signatureRepository: signatureRepo,
    signatureEvidenceRepository: ReportSignatureEvidenceRepository(
      InMemoryReportSignatureEvidenceGateway(),
    ),
    deliveryService: effectiveDelivery,
    pendingMediaSyncStore: pendingStore,
    pdfOrchestrator: pdfOrchestrator,
    cloudPdfService: cloudPdfService,
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));

  return PdfTestHarness(
    store: effectiveStore,
    pendingStore: pendingStore,
  );
}

/// Holds references to test doubles used in PDF generation tests.
class PdfTestHarness {
  PdfTestHarness({required this.store, required this.pendingStore});

  final FakeChecklistStore store;
  final FakePendingMediaSyncStore pendingStore;
}

/// Creates a complete [WizardProgressSnapshot] for fourPoint with all
/// requirements marked complete.
WizardProgressSnapshot completeFourPointSnapshot() {
  return WizardProgressSnapshot(
    lastStepIndex: 1,
    completion: {
      for (final req
          in FormRequirements.forFormRequirements(FormType.fourPoint))
        req.key: true,
    },
    branchContext: const <String, dynamic>{},
    status: WizardProgressStatus.complete,
  );
}
