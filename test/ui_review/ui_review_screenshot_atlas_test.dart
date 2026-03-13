import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/auth/data/auth_repository.dart';
import 'package:inspectobot/features/auth/presentation/forgot_password_page.dart';
import 'package:inspectobot/features/auth/presentation/reset_password_page.dart';
import 'package:inspectobot/features/auth/presentation/sign_in_page.dart';
import 'package:inspectobot/features/auth/presentation/sign_up_page.dart';
import 'package:inspectobot/features/audit/domain/audit_event.dart';
import 'package:inspectobot/features/delivery/domain/report_artifact.dart';
import 'package:inspectobot/features/identity/data/inspector_profile_repository.dart';
import 'package:inspectobot/features/identity/data/signature_repository.dart';
import 'package:inspectobot/features/identity/domain/inspector_profile.dart';
import 'package:inspectobot/features/identity/presentation/inspector_identity_page.dart';
import 'package:inspectobot/features/inspection/data/inspection_repository.dart';
import 'package:inspectobot/features/inspection/domain/form_requirements.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/general_inspection_form_data.dart';
import 'package:inspectobot/features/inspection/domain/inspection_setup.dart';
import 'package:inspectobot/features/inspection/domain/inspection_wizard_state.dart';
import 'package:inspectobot/features/inspection/domain/mold_form_data.dart';
import 'package:inspectobot/features/inspection/domain/report_readiness.dart';
import 'package:inspectobot/features/inspection/presentation/dashboard_page.dart';
import 'package:inspectobot/features/inspection/presentation/new_inspection_page.dart';
import 'package:inspectobot/features/inspection/presentation/sub_views/audit_timeline_view.dart';
import 'package:inspectobot/features/inspection/presentation/sub_views/evidence_capture_view.dart';
import 'package:inspectobot/features/inspection/presentation/sub_views/general_inspection_form_step.dart';
import 'package:inspectobot/features/inspection/presentation/sub_views/mold_form_step.dart';
import 'package:inspectobot/features/inspection/presentation/sub_views/pdf_delivery_view.dart';
import 'package:inspectobot/features/inspection/presentation/sub_views/wizard_navigation_view.dart';
import 'package:inspectobot/theme/app_theme.dart';

import '../../integration_test/support/operational_review_harness.dart';

const Size _phoneSize = Size(390, 844);
const Size _narrowPhoneSize = Size(390, 640);
const _captureBoundaryKey = ValueKey<String>('ui-review-capture-boundary');
const _runAtlas = bool.fromEnvironment('GENERATE_UI_REVIEW_ATLAS');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('generates auth atlas screenshots', (tester) async {
    _prepareTestViewport(tester, _phoneSize);
    await _generateAuthAtlas(tester);
  }, skip: !_runAtlas);

  testWidgets('generates dashboard and setup atlas screenshots', (tester) async {
    _prepareTestViewport(tester, _phoneSize);
    await _generateDashboardAndSetupAtlas(tester);
  }, skip: !_runAtlas);

  testWidgets('generates checklist atlas screenshots', (tester) async {
    _prepareTestViewport(tester, _phoneSize);
    await _generateChecklistAtlas(tester);
  }, skip: !_runAtlas);

  testWidgets('generates narrative atlas screenshots', (tester) async {
    _prepareTestViewport(tester, _phoneSize);
    await _generateNarrativeAtlas(tester);
  }, skip: !_runAtlas);
}

void _prepareTestViewport(WidgetTester tester, Size size) {
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  _configureViewport(tester, size);
}

Future<void> _generateAuthAtlas(WidgetTester tester) async {
  final authRepository = AuthRepository(ReviewAuthGateway());

  await _pumpReviewSurface(
    tester,
    SignInPage(repository: authRepository),
  );
  await _captureSurface(tester, 'auth-sign-in-default');

  await tester.tap(find.widgetWithText(FilledButton, 'Sign In'));
  await tester.pumpAndSettle();
  await _captureSurface(tester, 'auth-sign-in-validation');

  await _pumpReviewSurface(
    tester,
    SignInPage(repository: authRepository),
    textScale: 1.6,
  );
  await _captureSurface(tester, 'auth-sign-in-text-scale-1_6');

  await _pumpReviewSurface(
    tester,
    SignUpPage(repository: authRepository),
  );
  await _captureSurface(tester, 'auth-sign-up-default');

  await _pumpReviewSurface(
    tester,
    ForgotPasswordPage(repository: authRepository),
  );
  await tester.enterText(
    find.byType(TextFormField).first,
    'reviewer@example.com',
  );
  await tester.tap(find.widgetWithText(FilledButton, 'Send Recovery Link'));
  await tester.pumpAndSettle();
  await _captureSurface(tester, 'auth-forgot-password-success');

  await _pumpReviewSurface(
    tester,
    ResetPasswordPage(repository: authRepository),
  );
  await _captureSurface(tester, 'auth-reset-password-default');
}

Future<void> _generateDashboardAndSetupAtlas(WidgetTester tester) async {
  final emptyRepository = InspectionRepository(InMemoryInspectionStore());
  await _pumpReviewSurface(
    tester,
    DashboardPage(
      organizationId: reviewOrganizationId,
      userId: reviewUserId,
      repository: emptyRepository,
    ),
  );
  await _captureSurface(tester, 'dashboard-empty');

  final populatedStore = InMemoryInspectionStore();
  final populatedRepository = InspectionRepository(populatedStore);
  final inspection = await populatedRepository.createInspection(
    InspectionSetup(
      id: 'dashboard-review-inspection',
      organizationId: reviewOrganizationId,
      userId: reviewUserId,
      clientName: 'Maria Policyholder',
      clientEmail: 'maria@example.com',
      clientPhone: '555-0130',
      propertyAddress: '842 Cypress Hammock Dr',
      inspectionDate: DateTime.utc(2026, 3, 12),
      yearBuilt: 1998,
      enabledForms: const <FormType>{FormType.fourPoint},
    ),
  );
  final firstRequirement = FormRequirements.forFormRequirements(
    FormType.fourPoint,
  ).first;
  await populatedRepository.updateWizardProgress(
    inspectionId: inspection.id,
    organizationId: inspection.organizationId,
    userId: inspection.userId,
    snapshot: WizardProgressSnapshot(
      lastStepIndex: 1,
      completion: <String, bool>{firstRequirement.key: true},
      branchContext: const <String, dynamic>{},
      status: WizardProgressStatus.inProgress,
    ),
  );

  await _pumpReviewSurface(
    tester,
    DashboardPage(
      organizationId: reviewOrganizationId,
      userId: reviewUserId,
      repository: populatedRepository,
    ),
  );
  await _captureSurface(tester, 'dashboard-populated');

  final profileRepository = InspectorProfileRepository(
    InMemoryInspectorProfileStore(),
  );
  await profileRepository.upsertProfile(
    const InspectorProfile(
      organizationId: reviewOrganizationId,
      userId: reviewUserId,
      licenseType: 'Home Inspector',
      licenseNumber: 'HI-42017',
    ),
  );
  final signatureGateway = InMemorySignatureGateway();
  final signatureRepository = SignatureRepository(
    storage: signatureGateway,
    metadata: signatureGateway,
  );
  await signatureRepository.saveSignature(
    organizationId: reviewOrganizationId,
    userId: reviewUserId,
    bytes: Uint8List.fromList(<int>[1, 2, 3, 4]),
  );
  await _pumpReviewSurface(
    tester,
    InspectorIdentityPage(
      organizationId: reviewOrganizationId,
      userId: reviewUserId,
      profileRepository: profileRepository,
      signatureRepository: signatureRepository,
    ),
  );
  await _captureSurface(tester, 'identity-saved');

  final reviewInspectionRepository = InspectionRepository(
    InMemoryInspectionStore(),
  );
  await _pumpReviewSurface(
    tester,
    NewInspectionPage(
      organizationId: reviewOrganizationId,
      userId: reviewUserId,
      repository: _StaticNewInspectionRepositoryProvider(
        reviewInspectionRepository,
      ),
    ),
  );
  await _captureSurface(tester, 'new-inspection-default');

  await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
  await tester.pumpAndSettle();
  await _captureSurface(tester, 'new-inspection-validation');

  _configureViewport(tester, _narrowPhoneSize);
  await _pumpReviewSurface(
    tester,
    NewInspectionPage(
      organizationId: reviewOrganizationId,
      userId: reviewUserId,
      repository: _StaticNewInspectionRepositoryProvider(
        reviewInspectionRepository,
      ),
    ),
  );
  await _captureSurface(tester, 'new-inspection-narrow-height');
}

Future<void> _generateChecklistAtlas(WidgetTester tester) async {
  final draft = buildFourPointDraft(
    inspectionId: 'ui-review-checklist',
    ready: false,
    initialStepIndex: 1,
  );
  final wizardState = InspectionWizardState(
    enabledForms: draft.enabledForms,
    snapshot: draft.wizardSnapshot,
  );
  await _pumpReviewSurface(
    tester,
    Scaffold(
      appBar: AppBar(title: const Text('Guided Inspection Wizard')),
      body: WizardNavigationView(
        wizardState: wizardState,
        currentStepIndex: 1,
        snapshot: draft.wizardSnapshot,
        isSavingProgress: false,
        onCapture: (_) {},
        onContinue: () {},
        onSetBranchFlag: (_, value) {},
        formData: const <FormType, Map<String, dynamic>>{},
        moldFormData: MoldFormData.empty(),
        onMoldChanged: (_) {},
        generalFormData: GeneralInspectionFormData.empty(),
        onGeneralChanged: (_) {},
      ),
    ),
  );
  await _captureSurface(tester, 'checklist-steps');

  final summaryWizardState = InspectionWizardState(
    enabledForms: const <FormType>{
      FormType.fourPoint,
      FormType.roofCondition,
    },
    snapshot: WizardProgressSnapshot(
      lastStepIndex: 1,
      completion: <String, bool>{
        FormRequirements.forFormRequirements(FormType.fourPoint).first.key: true,
      },
      branchContext: const <String, dynamic>{},
      status: WizardProgressStatus.inProgress,
    ),
  );
  await _pumpReviewSurface(
    tester,
    Scaffold(
      appBar: AppBar(title: const Text('Evidence Summary')),
      body: EvidenceCaptureView(wizardState: summaryWizardState),
    ),
  );
  await _captureSurface(tester, 'checklist-summary');

  await _pumpReviewSurface(
    tester,
    Scaffold(
      appBar: AppBar(title: const Text('Report & Delivery')),
      body: PdfDeliveryView(
        readiness: ReportReadiness(
          inspectionId: 'ui-review-checklist',
          organizationId: reviewOrganizationId,
          userId: reviewUserId,
          status: ReportReadinessStatus.ready,
          missingItems: const <String>[],
          computedAt: DateTime.utc(2026, 3, 12),
        ),
        isComplete: true,
        isGenerating: false,
        lastPdfPath: '/review/output/inspectobot_report.pdf',
        lastArtifact: ReportArtifact(
          id: 'artifact-review',
          inspectionId: 'ui-review-checklist',
          organizationId: reviewOrganizationId,
          userId: reviewUserId,
          storageBucket: 'report-artifacts-private',
          storagePath: 'org/$reviewOrganizationId/reports/inspectobot_report.pdf',
          fileName: 'inspectobot_report.pdf',
          contentType: 'application/pdf',
          sizeBytes: 182304,
          retainUntil: DateTime.utc(2026, 4, 12),
          createdAt: DateTime.utc(2026, 3, 12, 14),
          updatedAt: DateTime.utc(2026, 3, 12, 14, 1),
        ),
        onGeneratePdf: () {},
        onDownload: () {},
        onShare: () {},
      ),
    ),
  );
  await _captureSurface(tester, 'checklist-report-ready');

  await _pumpReviewSurface(
    tester,
    Scaffold(
      appBar: AppBar(title: const Text('Audit Timeline')),
      body: AuditTimelineView(
        isLoading: false,
        auditEvents: <AuditEvent>[
          AuditEvent(
            id: 'audit-1',
            inspectionId: 'ui-review-checklist',
            organizationId: reviewOrganizationId,
            userId: reviewUserId,
            eventType: 'inspection_progress_updated',
            occurredAt: DateTime.utc(2026, 3, 12, 13, 50),
            payload: const <String, dynamic>{'step_index': 1},
            createdAt: DateTime.utc(2026, 3, 12, 13, 50),
          ),
          AuditEvent(
            id: 'audit-2',
            inspectionId: 'ui-review-checklist',
            organizationId: reviewOrganizationId,
            userId: reviewUserId,
            eventType: 'delivery_artifact_saved',
            occurredAt: DateTime.utc(2026, 3, 12, 14, 0),
            payload: const <String, dynamic>{'size_bytes': 182304},
            createdAt: DateTime.utc(2026, 3, 12, 14, 0),
          ),
          AuditEvent(
            id: 'audit-3',
            inspectionId: 'ui-review-checklist',
            organizationId: reviewOrganizationId,
            userId: reviewUserId,
            eventType: 'delivery_share_started',
            occurredAt: DateTime.utc(2026, 3, 12, 14, 2),
            payload: const <String, dynamic>{'channel': 'secure_share'},
            createdAt: DateTime.utc(2026, 3, 12, 14, 2),
          ),
        ],
      ),
    ),
  );
  await _captureSurface(tester, 'checklist-timeline');
}

Future<void> _generateNarrativeAtlas(WidgetTester tester) async {
  await _pumpReviewSurface(
    tester,
    Scaffold(
      appBar: AppBar(title: const Text('Mold Assessment')),
      body: SizedBox.expand(
        child: MoldFormStep(
          formData: const MoldFormData(
            scopeOfAssessment:
                'Visual survey of the first-floor living areas and attached garage. Limited by occupied furnishings and sealed wall cavities.',
            remediationRecommended: true,
          ),
          onChanged: (_) {},
        ),
      ),
    ),
  );
  await _captureSurface(tester, 'mold-form-default');

  await _pumpReviewSurface(
    tester,
    Scaffold(
      appBar: AppBar(title: const Text('General Inspection')),
      body: SizedBox.expand(
        child: GeneralInspectionFormStep(
          formData: GeneralInspectionFormData.empty().copyWith(
            scopeAndPurpose:
                'Visual general home inspection for underwriting support with representative access to the major systems.',
            generalComments:
                'Deferred conditions should be documented with follow-up recommendations before report delivery.',
          ),
          onChanged: (_) {},
          hasInspectorLicense: true,
          photoCounts: const <String, int>{'structural': 3, 'roofing': 2},
        ),
      ),
    ),
  );
  await _captureSurface(tester, 'general-form-default');
}

void _configureViewport(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
}

Future<void> _pumpReviewSurface(
  WidgetTester tester,
  Widget child, {
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    RepaintBoundary(
      key: _captureBoundaryKey,
      child: MaterialApp(
        theme: AppTheme.dark(),
        builder: (context, home) {
          final media = MediaQuery.of(context);
          return MediaQuery(
            data: media.copyWith(
              textScaler: TextScaler.linear(textScale),
            ),
            child: home!,
          );
        },
        home: child,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _captureSurface(WidgetTester tester, String name) async {
  await tester.pumpAndSettle();
  await expectLater(
    find.byKey(_captureBoundaryKey),
    matchesGoldenFile(
      '../../docs/ui-ux-review/screenshots/$name.png',
    ),
  );
}

class _StaticNewInspectionRepositoryProvider
    implements NewInspectionRepositoryProvider {
  const _StaticNewInspectionRepositoryProvider(this._repository);

  final InspectionRepository _repository;

  @override
  InspectionRepository resolve() => _repository;
}
