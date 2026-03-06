import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/audit/data/audit_event_repository.dart';
import 'package:inspectobot/features/delivery/data/delivery_repository.dart';
import 'package:inspectobot/features/delivery/data/report_artifact_repository.dart';
import 'package:inspectobot/features/delivery/services/delivery_service.dart';
import 'package:inspectobot/features/inspection/data/inspection_repository.dart';
import 'package:inspectobot/features/inspection/domain/form_requirements.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/report_readiness.dart';
import 'package:inspectobot/features/inspection/domain/inspection_wizard_state.dart';
import 'package:inspectobot/features/pdf/cloud_pdf_service.dart';
import 'package:inspectobot/features/pdf/on_device_pdf_service.dart';
import 'package:inspectobot/features/pdf/pdf_generation_input.dart';
import 'package:inspectobot/features/pdf/pdf_orchestrator.dart';
import 'package:inspectobot/features/pdf/pdf_strategy.dart';
import 'package:inspectobot/features/signing/data/report_signature_evidence_repository.dart';

import 'helpers/checklist_test_helpers.dart';

void main() {
  group('wizard navigation', () {
    testWidgets('enforces linear guarded progression', (tester) async {
      final store = FakeChecklistStore();
      await pumpChecklistPage(tester,
          draft: buildTestDraft(), repository: InspectionRepository(store));
      expect(find.textContaining('Step 1 of'), findsWidgets);

      await tester.tap(find.text('Continue to Next Step'));
      await tester.pumpAndSettle();
      expect(store.updateCalls, 1);
      expect(find.textContaining('Step 2 of'), findsWidgets);
      expect(find.text('Exterior Front'), findsWidgets);
    });

    testWidgets('resume step uses persisted last incomplete step', (t) async {
      final completion = <String, bool>{
        for (final k
            in FormRequirements.requirementKeysForForm(FormType.fourPoint))
          k: true,
      };
      await pumpChecklistPage(t,
          draft: buildTestDraft(
            enabledForms: {FormType.fourPoint, FormType.roofCondition},
            wizardSnapshot: WizardProgressSnapshot(
                lastStepIndex: 2,
                completion: completion,
                branchContext: const {},
                status: WizardProgressStatus.inProgress),
            initialStepIndex: 2,
          ));
      expect(find.textContaining('Step 3 of'), findsWidgets);
    });

    testWidgets('roof defect prompt appears with branch context', (t) async {
      await pumpChecklistPage(t,
          draft: buildTestDraft(
            enabledForms: {FormType.roofCondition},
            wizardSnapshot: WizardProgressSnapshot(
                lastStepIndex: 1,
                completion: const {},
                branchContext: const {'roof_defect_present': true},
                status: WizardProgressStatus.inProgress),
            initialStepIndex: 1,
          ));
      expect(find.text('Roof Defect'), findsOneWidget);
    });

    testWidgets('wind mitigation shows supporting doc prompts', (t) async {
      await pumpChecklistPage(t,
          draft: buildTestDraft(
            enabledForms: {FormType.windMitigation},
            wizardSnapshot: WizardProgressSnapshot(
                lastStepIndex: 1,
                completion: const {},
                branchContext: const {
                  'wind_roof_deck_document_required': true,
                  'wind_opening_document_required': true,
                  'wind_permit_document_required': true,
                },
                status: WizardProgressStatus.inProgress),
            initialStepIndex: 1,
          ));
      expect(find.text('Wind Roof Deck Supporting Document'), findsOneWidget);
      expect(find.text('Wind Opening Protection Document'), findsOneWidget);
      expect(find.text('Wind Permit/Age Document'), findsOneWidget);
      expect(find.text('Upload'), findsWidgets);
    });
  });

  group('branch flags', () {
    testWidgets('save progress preserves branch flags', (t) async {
      final store = FakeChecklistStore();
      await pumpChecklistPage(t,
          draft: buildTestDraft(
            enabledForms: {FormType.windMitigation},
            wizardSnapshot: WizardProgressSnapshot(
                lastStepIndex: 0,
                completion: const {},
                branchContext: const {
                  'wind_roof_deck_document_required': true,
                  'wind_opening_document_required': true,
                },
                status: WizardProgressStatus.inProgress),
          ),
          repository: InspectionRepository(store));
      await t.tap(find.text('Continue to Next Step'));
      await t.pumpAndSettle();
      expect(store.lastWizardBranchContext!['wind_roof_deck_document_required'],
          isTrue);
      expect(store.lastWizardBranchContext!['wind_opening_document_required'],
          isTrue);
      expect(store.lastWizardBranchContext!['enabled_forms'],
          contains('wind_mitigation'));
    });

    testWidgets('toggling flag activates conditional requirement', (t) async {
      await pumpChecklistPage(t,
          draft: buildTestDraft(
            enabledForms: {FormType.roofCondition},
            wizardSnapshot: WizardProgressSnapshot(
                lastStepIndex: 1,
                completion: const {},
                branchContext: const {},
                status: WizardProgressStatus.inProgress),
            initialStepIndex: 1,
          ),
          repository: InspectionRepository(FakeChecklistStore()));
      expect(find.text('Roof Defect'), findsNothing);
      await t.tap(find.byKey(const ValueKey('branch-flag-roof_defect_present')));
      await t.pumpAndSettle();
      expect(find.text('Roof Defect'), findsOneWidget);
    });

    testWidgets('toggling flag off removes conditional requirement', (t) async {
      await pumpChecklistPage(t,
          draft: buildTestDraft(
            enabledForms: {FormType.fourPoint},
            wizardSnapshot: WizardProgressSnapshot(
                lastStepIndex: 1,
                completion: const {},
                branchContext: const {'hazard_present': true},
                status: WizardProgressStatus.inProgress),
            initialStepIndex: 1,
          ),
          repository: InspectionRepository(FakeChecklistStore()));
      expect(find.text('Hazard Photo'), findsOneWidget);
      await t.tap(find.byKey(const ValueKey('branch-flag-hazard_present')));
      await t.pumpAndSettle();
      expect(find.text('Hazard Photo'), findsNothing);
    });

    testWidgets('branch toggle persists through save and resume', (t) async {
      final store = FakeChecklistStore();
      final repo = InspectionRepository(store);
      await pumpChecklistPage(t,
          draft: buildTestDraft(
            inspectionId: 'insp-bp',
            enabledForms: {FormType.windMitigation},
            wizardSnapshot: WizardProgressSnapshot(
                lastStepIndex: 1,
                completion: {
                  for (final req in FormRequirements.forFormRequirements(
                    FormType.windMitigation,
                    branchContext: const {
                      'wind_roof_deck_document_required': true
                    },
                  ))
                    req.key: true,
                },
                branchContext: const {
                  'wind_roof_deck_document_required': true
                },
                status: WizardProgressStatus.inProgress),
            initialStepIndex: 1,
          ),
          repository: repo);
      expect(find.text('Wind Roof Deck Supporting Document'), findsOneWidget);

      await t.scrollUntilVisible(find.text('Finish Wizard'), 200,
          scrollable: find.byType(Scrollable).first);
      await t.pumpAndSettle();
      await t.tap(find.text('Finish Wizard'));
      await t.pumpAndSettle();
      expect(
          store.lastWizardBranchContext!['wind_roof_deck_document_required'],
          isTrue);

      // Resume
      await pumpChecklistPage(t,
          draft: buildTestDraft(
            inspectionId: 'insp-bp',
            enabledForms: {FormType.windMitigation},
            wizardSnapshot: WizardProgressSnapshot(
                lastStepIndex: 1,
                completion: const {},
                branchContext: const {
                  'wind_roof_deck_document_required': true
                },
                status: WizardProgressStatus.inProgress),
            initialStepIndex: 1,
          ),
          repository: repo);
      expect(find.text('Wind Roof Deck Supporting Document'), findsOneWidget);
    });
  });

  testWidgets('visible requirements match readiness evaluation', (t) async {
    const bc = <String, dynamic>{'roof_defect_present': true};
    final forms = {FormType.roofCondition};
    final labels =
        FormRequirements.evaluate(forms, branchContext: bc).map((r) => r.label);
    await pumpChecklistPage(t,
        draft: buildTestDraft(
          enabledForms: forms,
          wizardSnapshot: WizardProgressSnapshot(
              lastStepIndex: 1,
              completion: const {},
              branchContext: bc,
              status: WizardProgressStatus.inProgress),
          initialStepIndex: 1,
        ),
        repository: InspectionRepository(FakeChecklistStore()));
    for (final l in labels) {
      expect(find.text(l), findsOneWidget, reason: 'Should show "$l"');
    }
    final r = ReportReadiness.evaluate(
        enabledForms: forms, completion: const {}, branchContext: bc);
    expect(r.status, ReportReadinessStatus.blocked);
    expect(r.missingItems, contains('Roof Defect'));
  });

  group('Report tab', () {
    testWidgets('PDF CTA stays blocked when readiness is blocked', (t) async {
      await pumpChecklistPage(t,
          draft: buildTestDraft(
              inspectionId: 'insp-5',
              wizardSnapshot: completeFourPointSnapshot(),
              initialStepIndex: 1),
          repository: InspectionRepository(FakeChecklistStore(
              seededReadiness: const {
                'inspection_id': 'insp-5',
                'organization_id': 'org-1',
                'user_id': 'user-1',
                'status': 'blocked',
                'missing_items': ['Exterior Front'],
                'computed_at': '2026-03-05T00:00:00.000Z',
              })));
      await t.pumpAndSettle();
      expect(find.text('Guided Inspection Wizard'), findsOneWidget);
    });

    testWidgets('generate PDF rehydrates pending evidence', (t) async {
      final reqs = FormRequirements.forFormRequirements(FormType.fourPoint);
      final onDevice = CapturingOnDevicePdfService();
      await pumpChecklistPage(t,
          draft: buildTestDraft(
              inspectionId: 'insp-9',
              wizardSnapshot: completeFourPointSnapshot(),
              initialStepIndex: 1),
          repository: InspectionRepository(
              FakeChecklistStore(seededReadiness: readyReadiness('insp-9'))),
          signatureRepository: await seededSignatureRepository(),
          signatureEvidenceRepository: ReportSignatureEvidenceRepository(
              InMemoryReportSignatureEvidenceGateway()),
          deliveryService: testDeliveryService(),
          pendingMediaSyncStore: pendingStoreFor(reqs),
          pdfOrchestrator: PdfOrchestrator(
              onDevice: onDevice, cloud: const CloudPdfService()));
      await t.pump();
      await t.pump(const Duration(milliseconds: 200));
      await switchToTab(t, 'Report');
      await t.tap(find.byKey(const ValueKey('generate-pdf-button')));
      await t.pump();
      await t.pump(const Duration(milliseconds: 200));
      final key = reqs.first.key;
      expect(onDevice.lastInput, isNotNull);
      expect(onDevice.lastInput!.evidenceMediaPaths[key],
          contains('/tmp/${key.replaceAll(':', '_')}.jpg'));
    });

    testWidgets('cloud-fallback with terminal outcome shows error', (t) async {
      await pumpPdfReadyPage(t,
          inspectionId: 'insp-cg',
          cloudPdfService: CloudPdfService(
              runtimeGateway: StaticCloudPdfRuntimeGateway(
                  CloudPdfGenerationOutcome.terminalFailure(
                      error: StateError('x'), reason: 'terminal'))));
      await switchToTab(t, 'Report');
      await t.tap(find.byKey(const ValueKey('generate-pdf-button')));
      await t.pump();
      await t.pump(const Duration(milliseconds: 200));
      expect(
          find.text(
              'Cloud PDF generation failed and on-device fallback was not attempted.'),
          findsOneWidget);
    });

    testWidgets('falls back to on-device when cloud unavailable', (t) async {
      final cloud = FixedOutcomeCloudPdfService(
          const CloudPdfGenerationOutcome.unavailable(
              reason: 'cloud disabled'));
      await pumpPdfReadyPage(t,
          inspectionId: 'insp-cu',
          pdfOrchestrator: PdfOrchestrator(
              onDevice: SuccessfulOnDevicePdfService(),
              cloud: cloud,
              primaryStrategy: PdfStrategy.cloudFallback));
      await switchToTab(t, 'Report');
      await t.tap(find.byKey(const ValueKey('generate-pdf-button')));
      await t.pump();
      await t.pump(const Duration(milliseconds: 200));
      expect(cloud.callCount, 1);
      expect(
          find.text(
              'Cloud PDF generation failed and on-device fallback was not attempted.'),
          findsNothing);
    });

    testWidgets('terminal cloud failure shows deterministic message', (
      t,
    ) async {
      final dGw = InMemoryDeliveryActionGateway();
      final aGw = InMemoryAuditEventGateway();
      await pumpPdfReadyPage(t,
          inspectionId: 'insp-ct',
          deliveryService: DeliveryService(
              artifactRepository:
                  ReportArtifactRepository(InMemoryReportArtifactGateway()),
              deliveryRepository: DeliveryRepository(dGw),
              auditRepository: AuditEventRepository(aGw),
              signedUrlGateway: TestSignedUrlGateway(),
              shareGateway: TestShareGateway()),
          pdfOrchestrator: PdfOrchestrator(
              onDevice: SuccessfulOnDevicePdfService(),
              cloud: FixedOutcomeCloudPdfService(
                  CloudPdfGenerationOutcome.terminalFailure(
                      error: StateError('x'), reason: 'terminal')),
              primaryStrategy: PdfStrategy.cloudFallback));
      await switchToTab(t, 'Report');
      await t.tap(find.byKey(const ValueKey('generate-pdf-button')));
      await t.pump();
      expect(
          find.text(
              'Cloud PDF generation failed and on-device fallback was not attempted.'),
          findsOneWidget);
      expect(
          await DeliveryRepository(dGw).listByInspection(
              inspectionId: 'insp-ct',
              organizationId: 'org-1',
              userId: 'user-1'),
          isEmpty);
      final events = await AuditEventRepository(aGw).listByInspection(
          inspectionId: 'insp-ct',
          organizationId: 'org-1',
          userId: 'user-1');
      expect(events.where((e) => e.eventType.startsWith('delivery_')), isEmpty);
    });
  });

  group('Timeline tab', () {
    testWidgets('renders audit timeline in deterministic order', (t) async {
      final gw = RecordingAuditEventGateway(events: [
        {'id': 'evt-1', 'inspection_id': 'insp-a1', 'organization_id': 'org-1',
         'user_id': 'user-1', 'event_type': 'inspection_progress_updated',
         'occurred_at': '2026-03-05T09:00:00.000Z',
         'created_at': '2026-03-05T09:00:01.000Z',
         'payload': <String, dynamic>{}},
        {'id': 'evt-2', 'inspection_id': 'insp-a1', 'organization_id': 'org-1',
         'user_id': 'user-1', 'event_type': 'delivery_artifact_saved',
         'occurred_at': '2026-03-05T11:00:00.000Z',
         'created_at': '2026-03-05T11:00:02.000Z',
         'payload': <String, dynamic>{}},
      ]);
      await pumpChecklistPage(t,
          draft: buildTestDraft(inspectionId: 'insp-a1'),
          auditRepository: AuditEventRepository(gw));
      await t.pump();
      await t.pump(const Duration(milliseconds: 200));
      await switchToTab(t, 'Timeline');
      expect(gw.lastInspectionId, 'insp-a1');
      expect(find.text('Audit Timeline'), findsOneWidget);
      final saved = find.text('Report artifact saved');
      final progress = find.text('Inspection progress updated');
      expect(saved, findsOneWidget);
      expect(progress, findsOneWidget);
      expect(t.getTopLeft(saved).dy, lessThan(t.getTopLeft(progress).dy));
    });

    testWidgets('shows explicit empty state', (t) async {
      await pumpChecklistPage(t,
          draft: buildTestDraft(),
          auditRepository: AuditEventRepository(
              RecordingAuditEventGateway(events: const [])));
      await t.pump();
      await t.pump(const Duration(milliseconds: 200));
      await switchToTab(t, 'Timeline');
      expect(find.text('No audit events recorded yet'), findsOneWidget);
    });

    testWidgets('shows error state when audit load fails', (t) async {
      await pumpChecklistPage(t,
          draft: buildTestDraft(),
          auditRepository: AuditEventRepository(FailingAuditEventGateway()));
      await t.pumpAndSettle();
      await switchToTab(t, 'Timeline');
      expect(find.text('Audit timeline unavailable'), findsOneWidget);
      expect(
          find.text(
              'Unable to load audit timeline right now. Please retry shortly.'),
          findsOneWidget);
    });
  });

  group('dependency injection', () {
    testWidgets('accepts injected signature evidence deps', (t) async {
      await pumpChecklistPage(t,
          draft: buildTestDraft(
              inspectionId: 'insp-6',
              wizardSnapshot: completeFourPointSnapshot(),
              initialStepIndex: 1),
          repository: InspectionRepository(
              FakeChecklistStore(seededReadiness: readyReadiness('insp-6'))),
          signatureRepository: await seededSignatureRepository(),
          signatureEvidenceRepository: FailingSignatureEvidenceRepository(),
          pdfOrchestrator: PdfOrchestrator(
              onDevice: SuccessfulOnDevicePdfService(),
              cloud: const CloudPdfService()));
      await t.pumpAndSettle();
      expect(find.text('Guided Inspection Wizard'), findsOneWidget);
    });

    testWidgets('accepts injected delivery service deps', (t) async {
      await pumpChecklistPage(t,
          draft: buildTestDraft(
              inspectionId: 'insp-8',
              wizardSnapshot: completeFourPointSnapshot(),
              initialStepIndex: 1),
          repository: InspectionRepository(
              FakeChecklistStore(seededReadiness: readyReadiness('insp-8'))),
          signatureRepository: await seededSignatureRepository(),
          deliveryService: testDeliveryService(),
          pdfOrchestrator: PdfOrchestrator(
              onDevice: SuccessfulOnDevicePdfService(),
              cloud: const CloudPdfService()));
      await t.pumpAndSettle();
      expect(find.text('Guided Inspection Wizard'), findsOneWidget);
    });
  });

  test('deterministic over-budget error messaging contract', () {
    expect(
        () => OverBudgetOnDevicePdfService().generate(PdfGenerationInput(
            inspectionId: 'x', organizationId: 'org-1', userId: 'user-1',
            clientName: 'X', propertyAddress: 'X',
            enabledForms: {FormType.fourPoint}, capturedCategories: const {})),
        throwsA(isA<PdfGenerationSizeBudgetExceeded>().having(
            (e) => e.message, 'message', contains('PDF exceeded configured'))));
  });

  group('tab navigation', () {
    testWidgets('switching between all 4 tabs renders correct sub-views', (
      t,
    ) async {
      await pumpChecklistPage(t, draft: buildTestDraft());
      await t.pumpAndSettle();
      expect(find.textContaining('Step 1 of'), findsWidgets);
      await switchToTab(t, 'Summary');
      expect(find.text('Evidence Summary'), findsOneWidget);
      await switchToTab(t, 'Report');
      expect(find.byKey(const ValueKey('generate-pdf-button')), findsOneWidget);
      await switchToTab(t, 'Timeline');
      expect(find.textContaining('audit'), findsWidgets);
      await switchToTab(t, 'Steps');
      expect(find.textContaining('Step 1 of'), findsWidgets);
    });

    testWidgets('tab selection persists across state updates', (t) async {
      await pumpChecklistPage(t,
          draft: buildTestDraft(),
          repository: InspectionRepository(FakeChecklistStore()));
      await t.pumpAndSettle();
      await switchToTab(t, 'Summary');
      expect(find.text('Evidence Summary'), findsOneWidget);
      await switchToTab(t, 'Steps');
      await t.tap(find.text('Continue to Next Step'));
      await t.pumpAndSettle();
      await switchToTab(t, 'Summary');
      expect(find.text('Evidence Summary'), findsOneWidget);
    });

    testWidgets('Report tab shows generate button', (t) async {
      await pumpChecklistPage(t,
          draft: buildTestDraft(
              wizardSnapshot: completeFourPointSnapshot(),
              initialStepIndex: 1));
      await t.pumpAndSettle();
      await switchToTab(t, 'Report');
      expect(find.byKey(const ValueKey('generate-pdf-button')), findsOneWidget);
    });
  });
}
