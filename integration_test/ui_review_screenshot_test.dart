import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:inspectobot/features/auth/data/auth_repository.dart';
import 'package:inspectobot/features/auth/presentation/forgot_password_page.dart';
import 'package:inspectobot/features/auth/presentation/reset_password_page.dart';
import 'package:inspectobot/features/auth/presentation/sign_in_page.dart';
import 'package:inspectobot/features/auth/presentation/sign_up_page.dart';
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
import 'package:inspectobot/features/inspection/presentation/new_inspection_page.dart';
import 'package:inspectobot/features/inspection/presentation/sub_views/general_inspection_form_step.dart';
import 'package:inspectobot/features/inspection/presentation/sub_views/mold_form_step.dart';
import 'package:inspectobot/theme/app_theme.dart';

import 'support/operational_review_harness.dart';

const Size _phoneSize = Size(390, 844);
const Size _narrowPhoneSize = Size(390, 640);

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await binding.convertFlutterSurfaceToImage();
  });

  testWidgets('captures auth review surfaces', (tester) async {
    _configureViewport(tester, _phoneSize);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final authRepository = AuthRepository(ReviewAuthGateway());

    await _pumpReviewSurface(
      tester,
      SignInPage(repository: authRepository),
    );
    await binding.takeScreenshot('auth-sign-in-default');

    await tester.tap(find.widgetWithText(FilledButton, 'Sign In'));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('auth-sign-in-validation');

    await _pumpReviewSurface(
      tester,
      SignInPage(repository: authRepository),
      textScale: 1.6,
    );
    await binding.takeScreenshot('auth-sign-in-text-scale-1_6');

    await _pumpReviewSurface(
      tester,
      SignUpPage(repository: authRepository),
    );
    await binding.takeScreenshot('auth-sign-up-default');

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
    await binding.takeScreenshot('auth-forgot-password-success');

    await _pumpReviewSurface(
      tester,
      ResetPasswordPage(repository: authRepository),
    );
    await binding.takeScreenshot('auth-reset-password-default');
  });

  testWidgets('captures dashboard, identity, and setup review surfaces', (
    tester,
  ) async {
    _configureViewport(tester, _phoneSize);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final emptyHarness = await OperationalReviewAppHarness.create();
    addTearDown(emptyHarness.dispose);
    await emptyHarness.authRepository.signInWithPassword(
      email: 'reviewer@example.com',
      password: 'password123',
    );
    await emptyHarness.pumpApp(tester);
    await binding.takeScreenshot('dashboard-empty');

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

    final populatedHarness = await OperationalReviewAppHarness.create(
      inspectionStore: populatedStore,
    );
    addTearDown(populatedHarness.dispose);
    await populatedHarness.authRepository.signInWithPassword(
      email: 'reviewer@example.com',
      password: 'password123',
    );
    await populatedHarness.pumpApp(tester);
    await binding.takeScreenshot('dashboard-populated');

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
    await binding.takeScreenshot('identity-saved');

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
    await binding.takeScreenshot('new-inspection-default');

    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('new-inspection-validation');

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
    await binding.takeScreenshot('new-inspection-narrow-height');
  });

  testWidgets('captures checklist review surfaces', (tester) async {
    _configureViewport(tester, _phoneSize);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final harness = await ChecklistOperationalHarness.create(
      draft: buildFourPointDraft(
        inspectionId: 'ui-review-checklist',
        ready: true,
        initialStepIndex: 1,
      ),
      seedReadyEvidence: true,
    );
    addTearDown(harness.dispose);
    await harness.pump(tester);

    await binding.takeScreenshot('checklist-steps');

    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('checklist-summary');

    await tester.tap(find.text('Report'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('generate-pdf-button')));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('checklist-report-ready');

    await tester.tap(find.text('Timeline'));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('checklist-timeline');
  });

  testWidgets('captures narrative form review surfaces', (tester) async {
    _configureViewport(tester, _phoneSize);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

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
    await binding.takeScreenshot('mold-form-default');

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
    await binding.takeScreenshot('general-form-default');
  });
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
    MaterialApp(
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
  );
  await tester.pumpAndSettle();
}

class _StaticNewInspectionRepositoryProvider
    implements NewInspectionRepositoryProvider {
  const _StaticNewInspectionRepositoryProvider(this._repository);

  final InspectionRepository _repository;

  @override
  InspectionRepository resolve() => _repository;
}
