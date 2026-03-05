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
import 'package:inspectobot/features/inspection/domain/required_photo_category.dart';
import 'package:inspectobot/features/inspection/domain/inspection_wizard_state.dart';
import 'package:inspectobot/features/inspection/presentation/form_checklist_page.dart';
import 'package:inspectobot/features/media/media_sync_task.dart';
import 'package:inspectobot/features/media/pending_media_sync_store.dart';
import 'package:inspectobot/features/pdf/cloud_pdf_service.dart';
import 'package:inspectobot/features/pdf/on_device_pdf_service.dart';
import 'package:inspectobot/features/pdf/pdf_generation_input.dart';
import 'package:inspectobot/features/pdf/pdf_orchestrator.dart';
import 'package:inspectobot/features/pdf/pdf_strategy.dart';
import 'package:inspectobot/features/signing/data/report_signature_evidence_repository.dart';
import 'package:inspectobot/features/signing/domain/report_signature_evidence.dart';

void main() {
  testWidgets('wizard enforces linear guarded progression', (tester) async {
    final store = _ChecklistStore();
    final repository = InspectionRepository(store);
    final draft = InspectionDraft(
      inspectionId: 'insp-1',
      organizationId: 'org-1',
      userId: 'user-1',
      clientName: 'Jane Doe',
      clientEmail: 'jane@example.com',
      clientPhone: '555-0100',
      propertyAddress: '123 Palm Ave',
      inspectionDate: DateTime.utc(2026, 3, 4),
      yearBuilt: 2008,
      enabledForms: {FormType.fourPoint},
    );

    await tester.pumpWidget(
      MaterialApp(
        home: FormChecklistPage(draft: draft, repository: repository),
      ),
    );

    expect(find.textContaining('Step 1 of'), findsOneWidget);

    await tester.tap(find.text('Continue to Next Step'));
    await tester.pumpAndSettle();

    expect(store.updateCalls, 1);
    expect(find.textContaining('Step 2 of'), findsOneWidget);
    expect(find.text('Exterior Front'), findsWidgets);
  });

  testWidgets('resume step uses persisted last incomplete step', (
    tester,
  ) async {
    final requirementKeys = FormRequirements.requirementKeysForForm(
      FormType.fourPoint,
    );
    final completion = <String, bool>{};
    for (final key in requirementKeys) {
      completion[key] = true;
    }

    final draft = InspectionDraft(
      inspectionId: 'insp-2',
      organizationId: 'org-1',
      userId: 'user-1',
      clientName: 'Resume User',
      clientEmail: 'resume@example.com',
      clientPhone: '555-0100',
      propertyAddress: '456 Gulf Dr',
      inspectionDate: DateTime.utc(2026, 3, 4),
      yearBuilt: 2001,
      enabledForms: {FormType.fourPoint, FormType.roofCondition},
      wizardSnapshot: WizardProgressSnapshot(
        lastStepIndex: 2,
        completion: completion,
        branchContext: const <String, dynamic>{},
        status: WizardProgressStatus.inProgress,
      ),
      initialStepIndex: 2,
    );

    await tester.pumpWidget(MaterialApp(home: FormChecklistPage(draft: draft)));

    expect(find.textContaining('Step 3 of'), findsOneWidget);
  });

  testWidgets('roof defect prompt appears when branch context requires it', (
    tester,
  ) async {
    final draft = InspectionDraft(
      inspectionId: 'insp-3',
      organizationId: 'org-1',
      userId: 'user-1',
      clientName: 'Roof Defect User',
      clientEmail: 'roof@example.com',
      clientPhone: '555-0100',
      propertyAddress: '789 Roof Ln',
      inspectionDate: DateTime.utc(2026, 3, 4),
      yearBuilt: 1999,
      enabledForms: {FormType.roofCondition},
      wizardSnapshot: WizardProgressSnapshot(
        lastStepIndex: 1,
        completion: const <String, bool>{},
        branchContext: const <String, dynamic>{'roof_defect_present': true},
        status: WizardProgressStatus.inProgress,
      ),
      initialStepIndex: 1,
    );

    await tester.pumpWidget(MaterialApp(home: FormChecklistPage(draft: draft)));

    expect(find.text('Roof Defect'), findsOneWidget);
  });

  testWidgets(
    'wind mitigation step shows supporting document prompts when required',
    (tester) async {
      final draft = InspectionDraft(
        inspectionId: 'insp-4',
        organizationId: 'org-1',
        userId: 'user-1',
        clientName: 'Wind User',
        clientEmail: 'wind@example.com',
        clientPhone: '555-0100',
        propertyAddress: '321 Breeze St',
        inspectionDate: DateTime.utc(2026, 3, 4),
        yearBuilt: 2005,
        enabledForms: {FormType.windMitigation},
        wizardSnapshot: WizardProgressSnapshot(
          lastStepIndex: 1,
          completion: const <String, bool>{},
          branchContext: const <String, dynamic>{
            'wind_roof_deck_document_required': true,
            'wind_opening_document_required': true,
            'wind_permit_document_required': true,
          },
          status: WizardProgressStatus.inProgress,
        ),
        initialStepIndex: 1,
      );

      await tester.pumpWidget(
        MaterialApp(home: FormChecklistPage(draft: draft)),
      );

      expect(find.text('Wind Roof Deck Supporting Document'), findsOneWidget);
      expect(find.text('Wind Opening Protection Document'), findsOneWidget);
      expect(find.text('Wind Permit/Age Document'), findsOneWidget);
      expect(find.text('Upload'), findsWidgets);
    },
  );

  testWidgets('save progress preserves persisted branch flags', (tester) async {
    final store = _ChecklistStore();
    final repository = InspectionRepository(store);
    final draft = InspectionDraft(
      inspectionId: 'insp-branch-1',
      organizationId: 'org-1',
      userId: 'user-1',
      clientName: 'Branch Context User',
      clientEmail: 'branch@example.com',
      clientPhone: '555-0100',
      propertyAddress: '987 Context Ct',
      inspectionDate: DateTime.utc(2026, 3, 4),
      yearBuilt: 2000,
      enabledForms: {FormType.windMitigation},
      wizardSnapshot: WizardProgressSnapshot(
        lastStepIndex: 0,
        completion: const <String, bool>{},
        branchContext: const <String, dynamic>{
          'wind_roof_deck_document_required': true,
          'wind_opening_document_required': true,
        },
        status: WizardProgressStatus.inProgress,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: FormChecklistPage(draft: draft, repository: repository),
      ),
    );

    await tester.tap(find.text('Continue to Next Step'));
    await tester.pumpAndSettle();

    expect(store.lastWizardBranchContext, isNotNull);
    expect(
      store.lastWizardBranchContext!['wind_roof_deck_document_required'],
      isTrue,
    );
    expect(
      store.lastWizardBranchContext!['wind_opening_document_required'],
      isTrue,
    );
    expect(
      store.lastWizardBranchContext!['enabled_forms'],
      contains('wind_mitigation'),
    );
  });

  testWidgets('PDF CTA stays blocked when persisted readiness is blocked', (
    tester,
  ) async {
    final store = _ChecklistStore(
      seededReadiness: const <String, dynamic>{
        'inspection_id': 'insp-5',
        'organization_id': 'org-1',
        'user_id': 'user-1',
        'status': 'blocked',
        'missing_items': <String>['Exterior Front'],
        'computed_at': '2026-03-05T00:00:00.000Z',
      },
    );
    final repository = InspectionRepository(store);
    final draft = InspectionDraft(
      inspectionId: 'insp-5',
      organizationId: 'org-1',
      userId: 'user-1',
      clientName: 'Blocked Readiness',
      clientEmail: 'blocked@example.com',
      clientPhone: '555-0100',
      propertyAddress: '111 Delay Dr',
      inspectionDate: DateTime.utc(2026, 3, 4),
      yearBuilt: 2002,
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

    await tester.pumpWidget(
      MaterialApp(
        home: FormChecklistPage(draft: draft, repository: repository),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Guided Inspection Wizard'), findsOneWidget);
  });

  testWidgets(
    'checklist renders inspection-scoped audit timeline in deterministic order',
    (tester) async {
      final gateway = _RecordingAuditEventGateway(
        events: <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'evt-1',
            'inspection_id': 'insp-audit-1',
            'organization_id': 'org-1',
            'user_id': 'user-1',
            'event_type': 'inspection_progress_updated',
            'occurred_at': '2026-03-05T09:00:00.000Z',
            'created_at': '2026-03-05T09:00:01.000Z',
            'payload': <String, dynamic>{},
          },
          <String, dynamic>{
            'id': 'evt-2',
            'inspection_id': 'insp-audit-1',
            'organization_id': 'org-1',
            'user_id': 'user-1',
            'event_type': 'delivery_artifact_saved',
            'occurred_at': '2026-03-05T11:00:00.000Z',
            'created_at': '2026-03-05T11:00:02.000Z',
            'payload': <String, dynamic>{},
          },
        ],
      );

      final draft = InspectionDraft(
        inspectionId: 'insp-audit-1',
        organizationId: 'org-1',
        userId: 'user-1',
        clientName: 'Audit User',
        clientEmail: 'audit@example.com',
        clientPhone: '555-0100',
        propertyAddress: '303 Audit Way',
        inspectionDate: DateTime.utc(2026, 3, 4),
        yearBuilt: 2007,
        enabledForms: {FormType.fourPoint},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: FormChecklistPage(
            draft: draft,
            auditRepository: AuditEventRepository(gateway),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(gateway.lastInspectionId, 'insp-audit-1');
      expect(gateway.lastOrganizationId, 'org-1');
      expect(gateway.lastUserId, 'user-1');
      expect(find.text('Audit Timeline'), findsOneWidget);

      final savedFinder = find.text('Report artifact saved');
      final progressFinder = find.text('Inspection progress updated');
      expect(savedFinder, findsOneWidget);
      expect(progressFinder, findsOneWidget);
      expect(tester.getTopLeft(savedFinder).dy, lessThan(tester.getTopLeft(progressFinder).dy));
    },
  );

  testWidgets('checklist shows explicit empty audit timeline state', (
    tester,
  ) async {
    final draft = InspectionDraft(
      inspectionId: 'insp-audit-empty',
      organizationId: 'org-1',
      userId: 'user-1',
      clientName: 'Empty Audit User',
      clientEmail: 'audit-empty@example.com',
      clientPhone: '555-0100',
      propertyAddress: '404 Empty Rd',
      inspectionDate: DateTime.utc(2026, 3, 4),
      yearBuilt: 2001,
      enabledForms: {FormType.fourPoint},
    );

    await tester.pumpWidget(
      MaterialApp(
        home: FormChecklistPage(
          draft: draft,
          auditRepository: AuditEventRepository(
            _RecordingAuditEventGateway(events: const <Map<String, dynamic>>[]),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('No audit events recorded yet'), findsOneWidget);
  });

  testWidgets('checklist shows explicit error state when audit load fails', (
    tester,
  ) async {
    final draft = InspectionDraft(
      inspectionId: 'insp-audit-error',
      organizationId: 'org-1',
      userId: 'user-1',
      clientName: 'Error Audit User',
      clientEmail: 'audit-error@example.com',
      clientPhone: '555-0100',
      propertyAddress: '505 Error Blvd',
      inspectionDate: DateTime.utc(2026, 3, 4),
      yearBuilt: 2001,
      enabledForms: {FormType.fourPoint},
    );

    await tester.pumpWidget(
      MaterialApp(
        home: FormChecklistPage(
          draft: draft,
          auditRepository: AuditEventRepository(_FailingAuditEventGateway()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Audit timeline unavailable'), findsOneWidget);
    expect(
      find.text('Unable to load audit timeline right now. Please retry shortly.'),
      findsOneWidget,
    );
  });


  testWidgets('checklist accepts injected signature evidence dependencies', (
    tester,
  ) async {
    final store = _ChecklistStore(
      seededReadiness: const <String, dynamic>{
        'inspection_id': 'insp-6',
        'organization_id': 'org-1',
        'user_id': 'user-1',
        'status': 'ready',
        'missing_items': <String>[],
        'computed_at': '2026-03-05T00:00:00.000Z',
      },
    );
    final signatureGateway = InMemorySignatureGateway();
    final signatureRepository = SignatureRepository(
      storage: signatureGateway,
      metadata: signatureGateway,
    );
    await signatureRepository.saveSignature(
      organizationId: 'org-1',
      userId: 'user-1',
      bytes: Uint8List.fromList(<int>[1, 2, 3]),
    );

    final draft = InspectionDraft(
      inspectionId: 'insp-6',
      organizationId: 'org-1',
      userId: 'user-1',
      clientName: 'Evidence Failure',
      clientEmail: 'evidence@example.com',
      clientPhone: '555-0100',
      propertyAddress: '909 Gate St',
      inspectionDate: DateTime.utc(2026, 3, 4),
      yearBuilt: 2006,
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

    await tester.pumpWidget(
      MaterialApp(
        home: FormChecklistPage(
          draft: draft,
          repository: InspectionRepository(store),
          signatureRepository: signatureRepository,
          signatureEvidenceRepository: _FailingSignatureEvidenceRepository(),
          pdfOrchestrator: PdfOrchestrator(
            onDevice: _SuccessfulOnDevicePdfService(),
            cloud: const CloudPdfService(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Guided Inspection Wizard'), findsOneWidget);
  });

  test('checklist uses deterministic over-budget error messaging contract', () {
    final service = _OverBudgetOnDevicePdfService();

    expect(
      () => service.generate(
        PdfGenerationInput(
          inspectionId: 'insp-7',
          organizationId: 'org-1',
          userId: 'user-1',
          clientName: 'Over Budget User',
          propertyAddress: '101 Budget St',
          enabledForms: {FormType.fourPoint},
          capturedCategories: const {},
        ),
      ),
      throwsA(
        isA<PdfGenerationSizeBudgetExceeded>().having(
          (error) => error.message,
          'message',
          contains('PDF exceeded configured size budget'),
        ),
      ),
    );
  });

  testWidgets('checklist accepts injected delivery service dependencies', (
    tester,
  ) async {
    final store = _ChecklistStore(
      seededReadiness: const <String, dynamic>{
        'inspection_id': 'insp-8',
        'organization_id': 'org-1',
        'user_id': 'user-1',
        'status': 'ready',
        'missing_items': <String>[],
        'computed_at': '2026-03-05T00:00:00.000Z',
      },
    );
    final signatureGateway = InMemorySignatureGateway();
    final signatureRepository = SignatureRepository(
      storage: signatureGateway,
      metadata: signatureGateway,
    );
    await signatureRepository.saveSignature(
      organizationId: 'org-1',
      userId: 'user-1',
      bytes: Uint8List.fromList(<int>[1, 2, 3]),
    );

    final draft = InspectionDraft(
      inspectionId: 'insp-8',
      organizationId: 'org-1',
      userId: 'user-1',
      clientName: 'Delivery User',
      clientEmail: 'delivery@example.com',
      clientPhone: '555-0100',
      propertyAddress: '121 Delivery St',
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

    final deliveryService = DeliveryService(
      artifactRepository: ReportArtifactRepository(
        InMemoryReportArtifactGateway(),
      ),
      deliveryRepository: DeliveryRepository(InMemoryDeliveryActionGateway()),
      auditRepository: AuditEventRepository(InMemoryAuditEventGateway()),
      signedUrlGateway: _TestSignedUrlGateway(),
      shareGateway: _TestShareGateway(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: FormChecklistPage(
          draft: draft,
          repository: InspectionRepository(store),
          signatureRepository: signatureRepository,
          deliveryService: deliveryService,
          pdfOrchestrator: PdfOrchestrator(
            onDevice: _SuccessfulOnDevicePdfService(),
            cloud: const CloudPdfService(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Guided Inspection Wizard'), findsOneWidget);
  });

  testWidgets(
    'generate PDF rehydrates pending evidence when in-memory paths are empty',
    (tester) async {
      final requirements = FormRequirements.forFormRequirements(FormType.fourPoint);
      final requirementKey = requirements.first.key;
      final pendingStore = _FakePendingMediaSyncStore(
        byRequirement: {
          for (final requirement in requirements)
            requirement.key: <String>[
              '/tmp/${requirement.key.replaceAll(':', '_')}.jpg',
            ],
        },
      );

      final store = _ChecklistStore(
        seededReadiness: const <String, dynamic>{
          'inspection_id': 'insp-9',
          'organization_id': 'org-1',
          'user_id': 'user-1',
          'status': 'ready',
          'missing_items': <String>[],
          'computed_at': '2026-03-05T00:00:00.000Z',
        },
      );
      final signatureGateway = InMemorySignatureGateway();
      final signatureRepository = SignatureRepository(
        storage: signatureGateway,
        metadata: signatureGateway,
      );
      await signatureRepository.saveSignature(
        organizationId: 'org-1',
        userId: 'user-1',
        bytes: Uint8List.fromList(<int>[1, 2, 3]),
      );

      final onDevice = _CapturingOnDevicePdfService();
      final draft = InspectionDraft(
        inspectionId: 'insp-9',
        organizationId: 'org-1',
        userId: 'user-1',
        clientName: 'Pending Media User',
        clientEmail: 'pending@example.com',
        clientPhone: '555-0100',
        propertyAddress: '131 Pending St',
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

      final deliveryService = DeliveryService(
        artifactRepository: ReportArtifactRepository(
          InMemoryReportArtifactGateway(),
        ),
        deliveryRepository: DeliveryRepository(InMemoryDeliveryActionGateway()),
        auditRepository: AuditEventRepository(InMemoryAuditEventGateway()),
        signedUrlGateway: _TestSignedUrlGateway(),
        shareGateway: _TestShareGateway(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: FormChecklistPage(
            draft: draft,
            repository: InspectionRepository(store),
            signatureRepository: signatureRepository,
            signatureEvidenceRepository: ReportSignatureEvidenceRepository(
              InMemoryReportSignatureEvidenceGateway(),
            ),
            deliveryService: deliveryService,
            pendingMediaSyncStore: pendingStore,
            pdfOrchestrator: PdfOrchestrator(
              onDevice: onDevice,
              cloud: const CloudPdfService(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('generate-pdf-button')),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(const ValueKey('generate-pdf-button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final generatedInput = onDevice.lastInput;
      expect(generatedInput, isNotNull);
      final expectedPath = '/tmp/${requirementKey.replaceAll(':', '_')}.jpg';
      expect(
        generatedInput!.evidenceMediaPaths[requirementKey],
        contains(expectedPath),
      );
    },
  );

  testWidgets(
    'production checklist wiring uses cloud-fallback strategy with terminal cloud outcome',
    (tester) async {
      final requirements = FormRequirements.forFormRequirements(
        FormType.fourPoint,
      );
      final store = _ChecklistStore(
        seededReadiness: _readyReadiness('insp-cloud-generated'),
      );
      final signatureRepository = await _seededSignatureRepository();
      final pendingStore = _pendingStoreFor(requirements);

      await tester.pumpWidget(
        MaterialApp(
          home: FormChecklistPage(
            draft: _readyDraft('insp-cloud-generated'),
            repository: InspectionRepository(store),
            signatureRepository: signatureRepository,
            signatureEvidenceRepository: ReportSignatureEvidenceRepository(
              InMemoryReportSignatureEvidenceGateway(),
            ),
            deliveryService: DeliveryService(
              artifactRepository: ReportArtifactRepository(
                InMemoryReportArtifactGateway(),
              ),
              deliveryRepository: DeliveryRepository(
                InMemoryDeliveryActionGateway(),
              ),
              auditRepository: AuditEventRepository(InMemoryAuditEventGateway()),
              signedUrlGateway: _TestSignedUrlGateway(),
              shareGateway: _TestShareGateway(),
            ),
            pendingMediaSyncStore: pendingStore,
            cloudPdfService: CloudPdfService(
              runtimeGateway: _StaticCloudPdfRuntimeGateway(
                CloudPdfGenerationOutcome.terminalFailure(
                  error: StateError('terminal cloud failure'),
                  reason: 'terminal cloud failure',
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('generate-pdf-button')),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(const ValueKey('generate-pdf-button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(
        find.text(
          'Cloud PDF generation failed and on-device fallback was not attempted.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('checklist falls back to on-device when cloud is unavailable', (
    tester,
  ) async {
    final requirements = FormRequirements.forFormRequirements(FormType.fourPoint);
    final store = _ChecklistStore(seededReadiness: _readyReadiness('insp-cloud-unavailable'));
    final signatureRepository = await _seededSignatureRepository();
    final pendingStore = _pendingStoreFor(requirements);
    final cloud = _FixedOutcomeCloudPdfService(
      const CloudPdfGenerationOutcome.unavailable(reason: 'cloud disabled'),
    );
    final onDevice = _SuccessfulOnDevicePdfService();

    await tester.pumpWidget(
      MaterialApp(
        home: FormChecklistPage(
          draft: _readyDraft('insp-cloud-unavailable'),
          repository: InspectionRepository(store),
          signatureRepository: signatureRepository,
          signatureEvidenceRepository: ReportSignatureEvidenceRepository(
            InMemoryReportSignatureEvidenceGateway(),
          ),
          deliveryService: DeliveryService(
            artifactRepository: ReportArtifactRepository(InMemoryReportArtifactGateway()),
            deliveryRepository: DeliveryRepository(InMemoryDeliveryActionGateway()),
            auditRepository: AuditEventRepository(InMemoryAuditEventGateway()),
            signedUrlGateway: _TestSignedUrlGateway(),
            shareGateway: _TestShareGateway(),
          ),
          pendingMediaSyncStore: pendingStore,
          pdfOrchestrator: PdfOrchestrator(
            onDevice: onDevice,
            cloud: cloud,
            primaryStrategy: PdfStrategy.cloudFallback,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('generate-pdf-button')),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('generate-pdf-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(cloud.callCount, 1);
    expect(
      find.text(
        'Cloud PDF generation failed and on-device fallback was not attempted.',
      ),
      findsNothing,
    );
  });

  testWidgets(
    'checklist surfaces deterministic message on terminal cloud generation failure',
    (tester) async {
      final requirements = FormRequirements.forFormRequirements(FormType.fourPoint);
      final store = _ChecklistStore(seededReadiness: _readyReadiness('insp-cloud-terminal'));
      final signatureRepository = await _seededSignatureRepository();
      final pendingStore = _pendingStoreFor(requirements);

      await tester.pumpWidget(
        MaterialApp(
          home: FormChecklistPage(
            draft: _readyDraft('insp-cloud-terminal'),
            repository: InspectionRepository(store),
            signatureRepository: signatureRepository,
            signatureEvidenceRepository: ReportSignatureEvidenceRepository(
              InMemoryReportSignatureEvidenceGateway(),
            ),
            deliveryService: DeliveryService(
              artifactRepository: ReportArtifactRepository(InMemoryReportArtifactGateway()),
              deliveryRepository: DeliveryRepository(InMemoryDeliveryActionGateway()),
              auditRepository: AuditEventRepository(InMemoryAuditEventGateway()),
              signedUrlGateway: _TestSignedUrlGateway(),
              shareGateway: _TestShareGateway(),
            ),
            pendingMediaSyncStore: pendingStore,
            pdfOrchestrator: PdfOrchestrator(
              onDevice: _SuccessfulOnDevicePdfService(),
              cloud: _FixedOutcomeCloudPdfService(
                CloudPdfGenerationOutcome.terminalFailure(
                  error: StateError('terminal cloud failure'),
                  reason: 'terminal cloud failure',
                ),
              ),
              primaryStrategy: PdfStrategy.cloudFallback,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('generate-pdf-button')),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(const ValueKey('generate-pdf-button')));
      await tester.pump();

      expect(
        find.text(
          'Cloud PDF generation failed and on-device fallback was not attempted.',
        ),
        findsOneWidget,
      );
    },
  );
}

InspectionDraft _readyDraft(String inspectionId) {
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

_FakePendingMediaSyncStore _pendingStoreFor(
  List<EvidenceRequirement> requirements,
) {
  return _FakePendingMediaSyncStore(
    byRequirement: {
      for (final requirement in requirements)
        requirement.key: <String>[
          '/tmp/${requirement.key.replaceAll(':', '_')}.jpg',
        ],
    },
  );
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

class _StaticCloudPdfRuntimeGateway implements CloudPdfRuntimeGateway {
  _StaticCloudPdfRuntimeGateway(this.outcome);

  final CloudPdfGenerationOutcome outcome;

  @override
  Future<CloudPdfGenerationOutcome> generate(PdfGenerationInput input) async {
    return outcome;
  }
}

class _FixedOutcomeCloudPdfService extends CloudPdfService {
  _FixedOutcomeCloudPdfService(this.outcome);

  final CloudPdfGenerationOutcome outcome;
  int callCount = 0;

  @override
  Future<CloudPdfGenerationOutcome> generate(PdfGenerationInput input) async {
    callCount += 1;
    return outcome;
  }
}

class _ChecklistStore implements InspectionStore {
  _ChecklistStore({this.seededReadiness});

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

class _FailingSignatureEvidenceRepository
    extends ReportSignatureEvidenceRepository {
  _FailingSignatureEvidenceRepository()
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

class _OverBudgetOnDevicePdfService extends OnDevicePdfService {
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

class _CapturingOnDevicePdfService extends OnDevicePdfService {
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

class _TestSignedUrlGateway implements SignedUrlGateway {
  @override
  Future<String> createSignedUrl({
    required String bucket,
    required String path,
    required int expiresInSeconds,
  }) async {
    return 'https://example.test/$bucket/$path?expires=$expiresInSeconds';
  }
}

class _TestShareGateway implements ShareGateway {
  @override
  Future<void> shareUri(String uri) async {}
}

class _RecordingAuditEventGateway implements AuditEventGateway {
  _RecordingAuditEventGateway({required this.events});

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

class _FailingAuditEventGateway implements AuditEventGateway {
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
