import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:inspectobot/app/navigation_service.dart';
import 'package:inspectobot/app/routes.dart';
import 'package:inspectobot/app/service_locator.dart';
import 'package:inspectobot/features/inspection/data/inspection_repository.dart';
import 'package:inspectobot/features/inspection/domain/form_requirements.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/inspection_setup.dart';
import 'package:inspectobot/features/inspection/domain/inspection_wizard_state.dart';
import 'package:inspectobot/features/inspection/presentation/dashboard_page.dart';
import 'package:inspectobot/features/sync/sync_outbox_store.dart';
import 'package:inspectobot/features/sync/sync_runner.dart';
import 'package:inspectobot/features/sync/sync_scheduler.dart';
import 'package:inspectobot/features/media/media_sync_remote_store.dart';
import 'package:inspectobot/features/media/media_sync_task.dart';
import 'package:inspectobot/features/inspection/domain/required_photo_category.dart';
import 'dart:typed_data';

class _MockNavigationService extends Mock implements NavigationService {}

void main() {
  late _MockNavigationService mockNav;

  setUp(() {
    mockNav = _MockNavigationService();
    when(() => mockNav.push<void>(any(), extra: any(named: 'extra')))
        .thenAnswer((_) async => null);
    when(() => mockNav.go(any(), extra: any(named: 'extra'))).thenReturn(null);
    when(() => mockNav.go(any())).thenReturn(null);
    setupTestServiceLocator(navigationService: mockNav);
  });

  tearDown(() async {
    await resetServiceLocator();
  });

  testWidgets('dashboard lists in-progress inspections with resume action', (
    tester,
  ) async {
    const organizationId = 'org-session';
    const userId = 'user-session';
    final store = _ScopeSpyInspectionStore(InMemoryInspectionStore());
    final repository = InspectionRepository(store);
    final setup = InspectionSetup(
      id: 'insp-1',
      organizationId: organizationId,
      userId: userId,
      clientName: 'Jane Doe',
      clientEmail: 'jane@example.com',
      clientPhone: '555-0100',
      propertyAddress: '123 Palm Ave',
      inspectionDate: DateTime.utc(2026, 3, 4),
      yearBuilt: 2008,
      enabledForms: {FormType.fourPoint, FormType.roofCondition},
    );
    final created = await repository.createInspection(setup);
    final completion = <String, bool>{};
    for (final key in FormRequirements.requirementKeysForForm(
      FormType.fourPoint,
    )) {
      completion[key] = true;
    }
    await repository.updateWizardProgress(
      inspectionId: created.id,
      organizationId: created.organizationId,
      userId: created.userId,
      snapshot: WizardProgressSnapshot(
        lastStepIndex: 1,
        completion: completion,
        branchContext: const <String, dynamic>{},
        status: WizardProgressStatus.inProgress,
      ),
    );

    final scheduler = _TestSyncScheduler();

    await tester.pumpWidget(
      MaterialApp(
        home: DashboardPage(
          repository: repository,
          syncScheduler: scheduler,
          organizationId: organizationId,
          userId: userId,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Resume In-Progress Inspections'), findsOneWidget);
    expect(find.text('Jane Doe'), findsOneWidget);
    expect(find.textContaining('last incomplete step 3'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Resume'));
    await tester.pumpAndSettle();

    expect(store.lastListOrganizationId, organizationId);
    expect(store.lastListUserId, userId);
    expect(scheduler.runCalls, 1);

    // Verify NavigationService.push was called with correct checklist route
    verify(
      () => mockNav.push<void>(
        AppRoutes.inspectionChecklist('insp-1'),
        extra: any(named: 'extra'),
      ),
    ).called(1);
  });

  testWidgets('new inspection button navigates via NavigationService', (
    tester,
  ) async {
    const organizationId = 'org-session';
    const userId = 'user-session';
    final store = _ScopeSpyInspectionStore(InMemoryInspectionStore());
    final repository = InspectionRepository(store);
    final scheduler = _TestSyncScheduler();

    await tester.pumpWidget(
      MaterialApp(
        home: DashboardPage(
          repository: repository,
          syncScheduler: scheduler,
          organizationId: organizationId,
          userId: userId,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // FilledButton.icon creates an _FilledButtonWithIcon, not a FilledButton
    await tester.tap(find.text('New Inspection'));
    await tester.pumpAndSettle();

    verify(() => mockNav.push<void>(AppRoutes.newInspection)).called(1);
  });

  testWidgets('inspector identity button navigates via NavigationService', (
    tester,
  ) async {
    const organizationId = 'org-session';
    const userId = 'user-session';
    final store = _ScopeSpyInspectionStore(InMemoryInspectionStore());
    final repository = InspectionRepository(store);
    final scheduler = _TestSyncScheduler();

    await tester.pumpWidget(
      MaterialApp(
        home: DashboardPage(
          repository: repository,
          syncScheduler: scheduler,
          organizationId: organizationId,
          userId: userId,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Inspector Identity'));
    await tester.pumpAndSettle();

    verify(() => mockNav.go(AppRoutes.inspectorIdentity)).called(1);
  });
}

class _ScopeSpyInspectionStore implements InspectionStore {
  _ScopeSpyInspectionStore(this._delegate);

  final InMemoryInspectionStore _delegate;
  String? lastListOrganizationId;
  String? lastListUserId;

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> inspectionJson) {
    return _delegate.create(inspectionJson);
  }

  @override
  Future<Map<String, dynamic>?> fetchById({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) {
    return _delegate.fetchById(
      inspectionId: inspectionId,
      organizationId: organizationId,
      userId: userId,
    );
  }

  @override
  Future<Map<String, dynamic>?> fetchWizardProgress({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) {
    return _delegate.fetchWizardProgress(
      inspectionId: inspectionId,
      organizationId: organizationId,
      userId: userId,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> listInProgressInspections({
    required String organizationId,
    required String userId,
  }) {
    lastListOrganizationId = organizationId;
    lastListUserId = userId;
    return _delegate.listInProgressInspections(
      organizationId: organizationId,
      userId: userId,
    );
  }

  @override
  Future<Map<String, dynamic>?> fetchReportReadiness({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) {
    return _delegate.fetchReportReadiness(
      inspectionId: inspectionId,
      organizationId: organizationId,
      userId: userId,
    );
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
  }) {
    return _delegate.updateWizardProgress(
      inspectionId: inspectionId,
      organizationId: organizationId,
      userId: userId,
      wizardLastStep: wizardLastStep,
      wizardCompletion: wizardCompletion,
      wizardBranchContext: wizardBranchContext,
      wizardStatus: wizardStatus,
    );
  }

  @override
  Future<Map<String, dynamic>> upsertReportReadiness({
    required String inspectionId,
    required String organizationId,
    required String userId,
    required String status,
    required List<String> missingItems,
    required DateTime computedAt,
  }) {
    return _delegate.upsertReportReadiness(
      inspectionId: inspectionId,
      organizationId: organizationId,
      userId: userId,
      status: status,
      missingItems: missingItems,
      computedAt: computedAt,
    );
  }
}

class _TestSyncScheduler extends SyncScheduler {
  _TestSyncScheduler()
    : super(runner: _NoopSyncRunner(), connectivityChanges: null);

  int runCalls = 0;

  @override
  Future<SyncRunResult> runPending() async {
    runCalls += 1;
    return const SyncRunResult(
      attempted: 0,
      succeeded: 0,
      failed: 0,
      skipped: 0,
    );
  }
}

class _NoopSyncRunner extends SyncRunner {
  _NoopSyncRunner()
    : super(
        outboxStore: SyncOutboxStore(),
        inspectionRemoteStore: _NoopInspectionStore(),
        mediaRemoteStore: _NoopMediaRemoteStore(),
      );
}

class _NoopInspectionStore implements InspectionStore {
  @override
  Future<Map<String, dynamic>> create(
    Map<String, dynamic> inspectionJson,
  ) async {
    return inspectionJson;
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
    return null;
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
    return <String, dynamic>{
      'inspection_id': inspectionId,
      'organization_id': organizationId,
      'user_id': userId,
      'status': status,
      'missing_items': missingItems,
      'computed_at': computedAt.toIso8601String(),
    };
  }
}

class _NoopMediaRemoteStore extends MediaSyncRemoteStore {
  _NoopMediaRemoteStore()
    : super(storage: _NoopStorageGateway(), metadata: _NoopMetadataGateway());

  @override
  Future<void> upload({
    required String mediaId,
    required String inspectionId,
    required String organizationId,
    required String userId,
    required String requirementKey,
    required CapturedMediaType mediaType,
    required String evidenceInstanceId,
    required RequiredPhotoCategory category,
    required String filePath,
    DateTime? capturedAt,
  }) async {}
}

class _NoopStorageGateway implements MediaStorageGateway {
  @override
  Future<Uint8List?> readBytes({required String path}) async {
    return null;
  }

  @override
  Future<void> upload({
    required String path,
    required Uint8List bytes,
    required String contentType,
  }) async {}
}

class _NoopMetadataGateway implements MediaMetadataGateway {
  @override
  Future<List<Map<String, dynamic>>> listByInspection({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    return const <Map<String, dynamic>>[];
  }

  @override
  Future<void> upsertMetadata({
    required String mediaId,
    required String inspectionId,
    required String organizationId,
    required String userId,
    required String requirementKey,
    required CapturedMediaType mediaType,
    required String evidenceInstanceId,
    required RequiredPhotoCategory category,
    required String storagePath,
    required String contentType,
    required DateTime capturedAt,
  }) async {}
}
