import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:inspectobot/app/app.dart';
import 'package:inspectobot/app/app_shell.dart';
import 'package:inspectobot/app/auth_notifier.dart';
import 'package:inspectobot/app/navigation_service.dart';
import 'package:inspectobot/app/routes.dart';
import 'package:inspectobot/app/service_locator.dart';
import 'package:inspectobot/features/audit/data/audit_event_repository.dart';
import 'package:inspectobot/features/delivery/data/delivery_repository.dart';
import 'package:inspectobot/features/delivery/data/report_artifact_repository.dart';
import 'package:inspectobot/features/delivery/services/delivery_service.dart';
import 'package:inspectobot/features/auth/data/auth_repository.dart';
import 'package:inspectobot/features/auth/presentation/sign_in_page.dart';
import 'package:inspectobot/features/identity/data/inspector_profile_repository.dart';
import 'package:inspectobot/features/identity/data/signature_repository.dart';
import 'package:inspectobot/features/identity/presentation/inspector_identity_page.dart';
import 'package:inspectobot/features/inspection/data/inspection_repository.dart';
import 'package:inspectobot/features/inspection/domain/form_requirements.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/inspection_draft.dart';
import 'package:inspectobot/features/inspection/domain/inspection_wizard_state.dart';
import 'package:inspectobot/features/inspection/presentation/form_checklist_page.dart';
import 'package:inspectobot/features/inspection/presentation/new_inspection_page.dart';
import 'package:inspectobot/features/inspection/presentation/dashboard_page.dart';
import 'package:inspectobot/features/media/local_media_store.dart';
import 'package:inspectobot/features/media/media_capture_service.dart';
import 'package:inspectobot/features/media/media_sync_task.dart';
import 'package:inspectobot/features/media/pending_media_sync_store.dart';
import 'package:inspectobot/features/pdf/cloud_pdf_service.dart';
import 'package:inspectobot/features/pdf/on_device_pdf_service.dart';
import 'package:inspectobot/features/pdf/pdf_generation_input.dart';
import 'package:inspectobot/features/pdf/pdf_orchestrator.dart';
import 'package:inspectobot/features/pdf/pdf_strategy.dart';
import 'package:inspectobot/features/signing/data/report_signature_evidence_repository.dart';
import 'package:inspectobot/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthChangeEvent;

const String reviewOrganizationId = 'org-review';
const String reviewUserId = 'user-review';

class ReviewAuthGateway implements AuthGateway {
  final StreamController<AuthStateChange> _controller =
      StreamController<AuthStateChange>.broadcast();
  AuthSession? _session;

  @override
  AuthSession? get currentSession => _session;

  @override
  Stream<AuthStateChange> get onAuthStateChange => _controller.stream;

  @override
  Future<AuthSession?> resolveCurrentSession() async => _session;

  @override
  Future<void> resetPasswordForEmail({
    required String email,
    required String redirectTo,
  }) async {}

  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    _session = const AuthSession(
      userId: reviewUserId,
      organizationId: reviewOrganizationId,
    );
    _controller.add(
      AuthStateChange(event: AuthChangeEvent.signedIn, session: _session),
    );
  }

  @override
  Future<void> signOut() async {
    _session = null;
    _controller.add(
      const AuthStateChange(event: AuthChangeEvent.signedOut, session: null),
    );
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
  }) {
    return signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> updatePassword({required String newPassword}) async {}
}

class InMemoryPendingMediaSyncStore extends PendingMediaSyncStore {
  InMemoryPendingMediaSyncStore();

  final Map<String, List<String>> _pathsByRequirement = <String, List<String>>{};
  final List<MediaSyncTask> _tasks = <MediaSyncTask>[];

  @override
  Future<void> enqueue(MediaSyncTask task) async {
    _tasks.removeWhere(
      (existing) =>
          existing.inspectionId == task.inspectionId &&
          existing.requirementKey == task.requirementKey &&
          existing.mediaType == task.mediaType &&
          existing.evidenceInstanceId == task.evidenceInstanceId,
    );
    _tasks.add(task);
    _pathsByRequirement[task.requirementKey] = <String>[task.filePath];
  }

  @override
  Future<List<MediaSyncTask>> listPending() async {
    return List<MediaSyncTask>.unmodifiable(_tasks);
  }

  @override
  Future<Map<String, List<String>>> loadEvidenceMediaPaths({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    return _pathsByRequirement.map(
      (key, value) => MapEntry(key, List<String>.from(value)),
    );
  }

  @override
  Future<void> markUploaded(String taskId) async {
    _tasks.removeWhere((task) => task.taskId == taskId);
  }

  void seedPaths(Map<String, List<String>> pathsByRequirement) {
    _pathsByRequirement
      ..clear()
      ..addAll(
        pathsByRequirement.map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      );
  }
}

class InMemoryLocalMediaStore extends LocalMediaStore {
  InMemoryLocalMediaStore();

  final Map<String, Map<String, String>> _capturesByInspection =
      <String, Map<String, String>>{};

  @override
  Future<void> saveCapture({
    required String inspectionId,
    required category,
    required String filePath,
  }) async {
    final captures =
        _capturesByInspection.putIfAbsent(inspectionId, () => <String, String>{});
    captures[category.name] = filePath;
  }
}

class HarnessOnDevicePdfService extends OnDevicePdfService {
  HarnessOnDevicePdfService(this._outputDirectory);

  final Directory _outputDirectory;

  @override
  Future<File> generate(PdfGenerationInput input) async {
    final file = File(
      '${_outputDirectory.path}/inspectobot_review_${DateTime.now().microsecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(
      <int>[37, 80, 68, 70, 45, 49, 46, 52],
      flush: true,
    );
    return file;
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

class _ChecklistRuntimeDependencies {
  _ChecklistRuntimeDependencies({
    required this.tempDirectory,
    required this.pendingStore,
    required this.localStore,
    required this.mediaCaptureService,
    required this.signatureRepository,
    required this.profileRepository,
    required this.signatureEvidenceRepository,
    required this.artifactRepository,
    required this.deliveryRepository,
    required this.deliveryService,
    required this.auditRepository,
    required this.pdfOrchestrator,
  });

  final Directory tempDirectory;
  final InMemoryPendingMediaSyncStore pendingStore;
  final InMemoryLocalMediaStore localStore;
  final MediaCaptureService mediaCaptureService;
  final SignatureRepository signatureRepository;
  final InspectorProfileRepository profileRepository;
  final ReportSignatureEvidenceRepository signatureEvidenceRepository;
  final ReportArtifactRepository artifactRepository;
  final DeliveryRepository deliveryRepository;
  final DeliveryService deliveryService;
  final AuditEventRepository auditRepository;
  final PdfOrchestrator pdfOrchestrator;

  static Future<_ChecklistRuntimeDependencies> create() async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'inspectobot_operational_review_',
    );
    final pendingStore = InMemoryPendingMediaSyncStore();
    final localStore = InMemoryLocalMediaStore();
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

    final auditRepository = AuditEventRepository(InMemoryAuditEventGateway());
    final signatureEvidenceRepository = ReportSignatureEvidenceRepository(
      InMemoryReportSignatureEvidenceGateway(),
      auditRepository: auditRepository,
    );
    final artifactRepository = ReportArtifactRepository(
      InMemoryReportArtifactGateway(),
    );
    final deliveryRepository = DeliveryRepository(
      InMemoryDeliveryActionGateway(),
    );
    final deliveryService = DeliveryService(
      artifactRepository: artifactRepository,
      deliveryRepository: deliveryRepository,
      auditRepository: auditRepository,
      signedUrlGateway: TestSignedUrlGateway(),
      shareGateway: TestShareGateway(),
      artifactStorageGateway: InMemoryReportArtifactStorageGateway(),
    );
    final mediaCaptureService = MediaCaptureService(
      pickPhoto: () async => '${tempDirectory.path}/source.jpg',
      compressPhoto: (_) async => <int>[7, 8, 9],
      writeCapture: ({
        required String inspectionId,
        required category,
        required CapturedMediaType mediaType,
        required String sourcePath,
        List<int>? bytes,
      }) async {
        final extension =
            mediaType == CapturedMediaType.document ? '.pdf' : '.jpg';
        final file = File(
          '${tempDirectory.path}/${category.name}_${DateTime.now().microsecondsSinceEpoch}$extension',
        );
        await file.writeAsBytes(bytes ?? <int>[7, 8, 9], flush: true);
        return file;
      },
      localStore: localStore,
      pendingSyncStore: pendingStore,
    );
    final pdfOrchestrator = PdfOrchestrator(
      onDevice: HarnessOnDevicePdfService(tempDirectory),
      cloud: const CloudPdfService(
        runtimeGateway: DisabledCloudPdfRuntimeGateway(),
      ),
      primaryStrategy: PdfStrategy.onDevice,
    );

    return _ChecklistRuntimeDependencies(
      tempDirectory: tempDirectory,
      pendingStore: pendingStore,
      localStore: localStore,
      mediaCaptureService: mediaCaptureService,
      signatureRepository: signatureRepository,
      profileRepository: InspectorProfileRepository(
        InMemoryInspectorProfileStore(),
      ),
      signatureEvidenceRepository: signatureEvidenceRepository,
      artifactRepository: artifactRepository,
      deliveryRepository: deliveryRepository,
      deliveryService: deliveryService,
      auditRepository: auditRepository,
      pdfOrchestrator: pdfOrchestrator,
    );
  }

  Future<void> dispose() async {
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  }
}

class OperationalReviewAppHarness {
  OperationalReviewAppHarness._({
    required this.authGateway,
    required this.inspectionStore,
    required this.authRepository,
    required this.authNotifier,
    required this.inspectionRepository,
    required this.router,
    required _ChecklistRuntimeDependencies checklistDependencies,
  }) : _checklistDependencies = checklistDependencies;

  final ReviewAuthGateway authGateway;
  final InspectionStore inspectionStore;
  final AuthRepository authRepository;
  final AuthNotifier authNotifier;
  final InspectionRepository inspectionRepository;
  final GoRouter router;
  final _ChecklistRuntimeDependencies _checklistDependencies;

  static Future<OperationalReviewAppHarness> create({
    ReviewAuthGateway? authGateway,
    InspectionStore? inspectionStore,
  }) async {
    await resetServiceLocator();

    final sharedAuthGateway = authGateway ?? ReviewAuthGateway();
    final authRepository = AuthRepository(sharedAuthGateway);
    final authNotifier = AuthNotifier(authRepository);
    final sharedInspectionStore = inspectionStore ?? InMemoryInspectionStore();
    final inspectionRepository = InspectionRepository(sharedInspectionStore);
    final checklistDependencies =
        await _ChecklistRuntimeDependencies.create();
    final repositoryProvider = _FixedNewInspectionRepositoryProvider(
      inspectionRepository,
    );

    final router = GoRouter(
      initialLocation: AppRoutes.signIn,
      refreshListenable: authNotifier,
      redirect: (context, state) {
        final currentPath = state.matchedLocation;
        final isOnAuthRoute = currentPath.startsWith(AppRoutes.auth);
        if (!authNotifier.isAuthenticated) {
          return isOnAuthRoute ? null : AppRoutes.signIn;
        }
        if (isOnAuthRoute || currentPath == '/') {
          return AppRoutes.dashboard;
        }
        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.signIn,
          builder: (context, state) =>
              SignInPage(repository: authRepository),
        ),
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(
              path: AppRoutes.dashboard,
              builder: (context, state) => DashboardPage(
                organizationId: reviewOrganizationId,
                userId: reviewUserId,
                repository: inspectionRepository,
              ),
            ),
            GoRoute(
              path: AppRoutes.inspectorIdentity,
              builder: (context, state) => InspectorIdentityPage(
                organizationId: reviewOrganizationId,
                userId: reviewUserId,
                profileRepository: checklistDependencies.profileRepository,
                signatureRepository:
                    checklistDependencies.signatureRepository,
              ),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.newInspection,
          builder: (context, state) => NewInspectionPage(
            organizationId: reviewOrganizationId,
            userId: reviewUserId,
            repository: repositoryProvider,
          ),
        ),
        GoRoute(
          path: '/inspections/:id/checklist',
          redirect: (context, state) {
            if (state.extra is! InspectionDraft) {
              return AppRoutes.dashboard;
            }
            return null;
          },
          builder: (context, state) => FormChecklistPage(
            draft: state.extra! as InspectionDraft,
            repository: inspectionRepository,
            signatureRepository:
                checklistDependencies.signatureRepository,
            signatureEvidenceRepository:
                checklistDependencies.signatureEvidenceRepository,
            deliveryService: checklistDependencies.deliveryService,
            pendingMediaSyncStore: checklistDependencies.pendingStore,
            pdfOrchestrator: checklistDependencies.pdfOrchestrator,
            auditRepository: checklistDependencies.auditRepository,
            mediaCapture: checklistDependencies.mediaCaptureService,
          ),
        ),
      ],
    );

    setupTestServiceLocator(
      authNotifier: authNotifier,
      router: router,
      navigationService: GoRouterNavigationService(router),
    );

    return OperationalReviewAppHarness._(
      authGateway: sharedAuthGateway,
      inspectionStore: sharedInspectionStore,
      authRepository: authRepository,
      authNotifier: authNotifier,
      inspectionRepository: inspectionRepository,
      router: router,
      checklistDependencies: checklistDependencies,
    );
  }

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const InspectoBotApp());
    await tester.pumpAndSettle();
  }

  Future<void> dispose() async {
    authNotifier.dispose();
    await _checklistDependencies.dispose();
    await resetServiceLocator();
  }
}

class ChecklistOperationalHarness {
  ChecklistOperationalHarness._({
    required this.draft,
    required this.repository,
    required _ChecklistRuntimeDependencies checklistDependencies,
  }) : _checklistDependencies = checklistDependencies;

  final InspectionDraft draft;
  final InspectionRepository repository;
  final _ChecklistRuntimeDependencies _checklistDependencies;

  InMemoryPendingMediaSyncStore get pendingStore =>
      _checklistDependencies.pendingStore;

  Future<int> artifactCount() async {
    final artifacts = await _checklistDependencies.artifactRepository
        .listByInspection(
          inspectionId: draft.inspectionId,
          organizationId: draft.organizationId,
          userId: draft.userId,
        );
    return artifacts.length;
  }

  Future<List<String>> deliveryActionTypes() async {
    final actions = await _checklistDependencies.deliveryRepository
        .listByInspection(
          inspectionId: draft.inspectionId,
          organizationId: draft.organizationId,
          userId: draft.userId,
        );
    return actions.map((action) => action.actionType).toList(growable: false);
  }

  static Future<ChecklistOperationalHarness> create({
    required InspectionDraft draft,
    bool seedReadyEvidence = false,
  }) async {
    final checklistDependencies =
        await _ChecklistRuntimeDependencies.create();
    final repository = InspectionRepository(InMemoryInspectionStore());

    if (seedReadyEvidence) {
      checklistDependencies.pendingStore.seedPaths(
        _seededEvidencePaths(
          forms: draft.enabledForms,
          branchContext: draft.wizardSnapshot.branchContext,
        ),
      );
    }

    return ChecklistOperationalHarness._(
      draft: draft,
      repository: repository,
      checklistDependencies: checklistDependencies,
    );
  }

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: FormChecklistPage(
          draft: draft,
          repository: repository,
          signatureRepository: _checklistDependencies.signatureRepository,
          signatureEvidenceRepository:
              _checklistDependencies.signatureEvidenceRepository,
          deliveryService: _checklistDependencies.deliveryService,
          pendingMediaSyncStore: _checklistDependencies.pendingStore,
          pdfOrchestrator: _checklistDependencies.pdfOrchestrator,
          auditRepository: _checklistDependencies.auditRepository,
          mediaCapture: _checklistDependencies.mediaCaptureService,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> dispose() => _checklistDependencies.dispose();
}

InspectionDraft buildFourPointDraft({
  required String inspectionId,
  bool ready = false,
  int initialStepIndex = 0,
}) {
  final completion = ready
      ? {
          for (final requirement in FormRequirements.forFormRequirements(
            FormType.fourPoint,
          ))
            requirement.key: true,
        }
      : <String, bool>{};
  final snapshot = WizardProgressSnapshot(
    lastStepIndex: ready ? 1 : 0,
    completion: completion,
    branchContext: const <String, dynamic>{},
    status: ready
        ? WizardProgressStatus.complete
        : WizardProgressStatus.inProgress,
  );

  return InspectionDraft(
    inspectionId: inspectionId,
    organizationId: reviewOrganizationId,
    userId: reviewUserId,
    clientName: 'Jane Reviewer',
    clientEmail: 'jane.reviewer@example.com',
    clientPhone: '555-0110',
    propertyAddress: '123 Palm Ave',
    inspectionDate: DateTime.utc(2026, 3, 12),
    yearBuilt: 2004,
    enabledForms: const <FormType>{FormType.fourPoint},
    wizardSnapshot: snapshot,
    initialStepIndex: initialStepIndex,
  );
}

Map<String, List<String>> _seededEvidencePaths({
  required Set<FormType> forms,
  required Map<String, dynamic> branchContext,
}) {
  final output = <String, List<String>>{};
  for (final requirement
      in FormRequirements.evaluate(forms, branchContext: branchContext)) {
    output[requirement.key] = <String>[
      '/tmp/${requirement.key.replaceAll(':', '_')}.jpg',
    ];
  }
  return output;
}

class _FixedNewInspectionRepositoryProvider
    implements NewInspectionRepositoryProvider {
  const _FixedNewInspectionRepositoryProvider(this._repository);

  final InspectionRepository _repository;

  @override
  InspectionRepository resolve() => _repository;
}
