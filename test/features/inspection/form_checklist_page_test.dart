import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/identity/data/signature_repository.dart';
import 'package:inspectobot/features/inspection/data/inspection_repository.dart';
import 'package:inspectobot/features/inspection/domain/form_requirements.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/inspection_draft.dart';
import 'package:inspectobot/features/inspection/domain/inspection_wizard_state.dart';
import 'package:inspectobot/features/inspection/presentation/form_checklist_page.dart';
import 'package:inspectobot/features/pdf/cloud_pdf_service.dart';
import 'package:inspectobot/features/pdf/on_device_pdf_service.dart';
import 'package:inspectobot/features/pdf/pdf_generation_input.dart';
import 'package:inspectobot/features/pdf/pdf_orchestrator.dart';
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
      MaterialApp(home: FormChecklistPage(draft: draft, repository: repository)),
    );

    expect(find.textContaining('Step 1 of'), findsOneWidget);

    await tester.tap(find.text('Continue to Next Step'));
    await tester.pumpAndSettle();

    expect(store.updateCalls, 1);
    expect(find.textContaining('Step 2 of'), findsOneWidget);
    expect(find.text('Exterior Front'), findsWidgets);
  });

  testWidgets('resume step uses persisted last incomplete step', (tester) async {
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

  testWidgets('wind mitigation step shows supporting document prompts when required', (
    tester,
  ) async {
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

    await tester.pumpWidget(MaterialApp(home: FormChecklistPage(draft: draft)));

    expect(find.text('Wind Roof Deck Supporting Document'), findsOneWidget);
    expect(find.text('Wind Opening Protection Document'), findsOneWidget);
    expect(find.text('Wind Permit/Age Document'), findsOneWidget);
    expect(find.text('Upload'), findsWidgets);
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
          for (final requirement in FormRequirements.forFormRequirements(FormType.fourPoint))
            requirement.key: true,
        },
        branchContext: const <String, dynamic>{},
        status: WizardProgressStatus.complete,
      ),
      initialStepIndex: 1,
    );

    await tester.pumpWidget(
      MaterialApp(home: FormChecklistPage(draft: draft, repository: repository)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Guided Inspection Wizard'), findsOneWidget);
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
          for (final requirement in FormRequirements.forFormRequirements(FormType.fourPoint))
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

  testWidgets('checklist shows deterministic over-budget message when generation fails', (
    tester,
  ) async {
    final store = _ChecklistStore(
      seededReadiness: const <String, dynamic>{
        'inspection_id': 'insp-7',
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
      inspectionId: 'insp-7',
      organizationId: 'org-1',
      userId: 'user-1',
      clientName: 'Over Budget User',
      clientEmail: 'over-budget@example.com',
      clientPhone: '555-0100',
      propertyAddress: '101 Budget St',
      inspectionDate: DateTime.utc(2026, 3, 4),
      yearBuilt: 2009,
      enabledForms: {FormType.fourPoint},
      wizardSnapshot: WizardProgressSnapshot(
        lastStepIndex: 1,
        completion: {
          for (final requirement in FormRequirements.forFormRequirements(FormType.fourPoint))
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
          pdfOrchestrator: PdfOrchestrator(
            onDevice: _OverBudgetOnDevicePdfService(),
            cloud: const CloudPdfService(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('generate-pdf-button')));
    await tester.pump();

    expect(
      find.textContaining('PDF exceeded configured size budget'),
      findsOneWidget,
    );
  });
}

class _ChecklistStore implements InspectionStore {
  _ChecklistStore({this.seededReadiness});

  int updateCalls = 0;
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
