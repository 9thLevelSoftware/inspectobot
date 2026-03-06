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
import 'package:inspectobot/common/widgets/empty_state.dart';
import 'package:inspectobot/common/widgets/status_badge.dart';
import 'package:inspectobot/features/sync/sync_outbox_store.dart';
import 'package:inspectobot/features/sync/sync_runner.dart';
import 'package:inspectobot/features/sync/sync_scheduler.dart';
import 'package:inspectobot/features/media/media_sync_remote_store.dart';
import 'package:inspectobot/features/media/media_sync_task.dart';
import 'package:inspectobot/features/inspection/domain/required_photo_category.dart';
import 'package:inspectobot/theme/theme.dart';
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
        theme: AppTheme.dark(),
        home: DashboardPage(
          repository: repository,
          syncScheduler: scheduler,
          organizationId: organizationId,
          userId: userId,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Inspections'), findsOneWidget);
    expect(find.text('Jane Doe'), findsOneWidget);
    expect(find.text('In Progress'), findsWidgets);

    await tester.tap(find.text('Resume'));
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
        theme: AppTheme.dark(),
        home: DashboardPage(
          repository: repository,
          syncScheduler: scheduler,
          organizationId: organizationId,
          userId: userId,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The empty state shows a "New Inspection" action button
    await tester.tap(find.text('New Inspection').first);
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
        theme: AppTheme.dark(),
        home: DashboardPage(
          repository: repository,
          syncScheduler: scheduler,
          organizationId: organizationId,
          userId: userId,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Inspector Identity is now an IconButton in the AppBar
    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();

    verify(() => mockNav.go(AppRoutes.inspectorIdentity)).called(1);
  });

  // ---- Task 2: Empty state and metrics summary tests ----

  testWidgets('shows empty state when no inspections exist', (tester) async {
    const organizationId = 'org-session';
    const userId = 'user-session';
    final store = _ScopeSpyInspectionStore(InMemoryInspectionStore());
    final repository = InspectionRepository(store);
    final scheduler = _TestSyncScheduler();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: DashboardPage(
          repository: repository,
          syncScheduler: scheduler,
          organizationId: organizationId,
          userId: userId,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // EmptyState widget should appear when no inspections exist
    expect(find.byType(EmptyState), findsOneWidget);
    expect(
      find.text(
        'No inspections yet.\nStart a new inspection to begin capturing required items.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows metrics summary with correct counts', (tester) async {
    const organizationId = 'org-session';
    const userId = 'user-session';
    // Use _AllStatusInspectionStore so completed inspections are also returned
    // (the real InMemoryInspectionStore filters by wizard_status == in_progress).
    final delegate = InMemoryInspectionStore();
    final store = _AllStatusInspectionStore(delegate);
    final repository = InspectionRepository(store);

    // Create 3 inspections with different statuses:
    // 1) In-progress (has some wizard completion)
    // 2) Draft (no wizard progress at all -- defaults to in_progress status)
    // 3) Complete (wizard status = complete)
    final setup1 = InspectionSetup(
      id: 'insp-metric-1',
      organizationId: organizationId,
      userId: userId,
      clientName: 'Client A',
      clientEmail: 'a@example.com',
      clientPhone: '555-0001',
      propertyAddress: '100 Main St',
      inspectionDate: DateTime.utc(2026, 3, 4),
      yearBuilt: 2010,
      enabledForms: {FormType.fourPoint},
    );
    final created1 = await repository.createInspection(setup1);
    final completion1 = <String, bool>{};
    for (final key in FormRequirements.requirementKeysForForm(
      FormType.fourPoint,
    )) {
      completion1[key] = true;
    }
    await repository.updateWizardProgress(
      inspectionId: created1.id,
      organizationId: created1.organizationId,
      userId: created1.userId,
      snapshot: WizardProgressSnapshot(
        lastStepIndex: 1,
        completion: completion1,
        branchContext: const <String, dynamic>{},
        status: WizardProgressStatus.inProgress,
      ),
    );

    // Draft inspection (no progress update -- defaults to empty snapshot)
    final setup2 = InspectionSetup(
      id: 'insp-metric-2',
      organizationId: organizationId,
      userId: userId,
      clientName: 'Client B',
      clientEmail: 'b@example.com',
      clientPhone: '555-0002',
      propertyAddress: '200 Main St',
      inspectionDate: DateTime.utc(2026, 3, 4),
      yearBuilt: 2015,
      enabledForms: {FormType.fourPoint},
    );
    await repository.createInspection(setup2);

    // Complete inspection
    final setup3 = InspectionSetup(
      id: 'insp-metric-3',
      organizationId: organizationId,
      userId: userId,
      clientName: 'Client C',
      clientEmail: 'c@example.com',
      clientPhone: '555-0003',
      propertyAddress: '300 Main St',
      inspectionDate: DateTime.utc(2026, 3, 4),
      yearBuilt: 2020,
      enabledForms: {FormType.fourPoint},
    );
    final created3 = await repository.createInspection(setup3);
    await repository.updateWizardProgress(
      inspectionId: created3.id,
      organizationId: created3.organizationId,
      userId: created3.userId,
      snapshot: WizardProgressSnapshot(
        lastStepIndex: 2,
        completion: completion1,
        branchContext: const <String, dynamic>{},
        status: WizardProgressStatus.complete,
      ),
    );

    final scheduler = _TestSyncScheduler();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: DashboardPage(
          repository: repository,
          syncScheduler: scheduler,
          organizationId: organizationId,
          userId: userId,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Metrics summary: Total = 3, In Progress = 2 (in-progress + draft), Completed = 1
    expect(find.text('3'), findsOneWidget); // Total count
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('2'), findsOneWidget); // In Progress count
    expect(find.text('1'), findsOneWidget); // Completed count
    expect(find.text('Completed'), findsOneWidget);
  });

  testWidgets('hides metrics when inspection list is empty', (tester) async {
    const organizationId = 'org-session';
    const userId = 'user-session';
    final store = _ScopeSpyInspectionStore(InMemoryInspectionStore());
    final repository = InspectionRepository(store);
    final scheduler = _TestSyncScheduler();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: DashboardPage(
          repository: repository,
          syncScheduler: scheduler,
          organizationId: organizationId,
          userId: userId,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Metrics section should not be visible when empty
    expect(find.text('Total'), findsNothing);
    expect(find.text('Completed'), findsNothing);
    // EmptyState should be shown instead
    expect(find.byType(EmptyState), findsOneWidget);
  });

  // ---- Task 3: Status badge and pull-to-refresh tests ----

  testWidgets('displays correct status badge for in-progress inspection', (
    tester,
  ) async {
    const organizationId = 'org-session';
    const userId = 'user-session';
    final store = _ScopeSpyInspectionStore(InMemoryInspectionStore());
    final repository = InspectionRepository(store);

    final setup = InspectionSetup(
      id: 'insp-status-ip',
      organizationId: organizationId,
      userId: userId,
      clientName: 'Status Test',
      clientEmail: 'test@example.com',
      clientPhone: '555-0100',
      propertyAddress: '456 Oak Dr',
      inspectionDate: DateTime.utc(2026, 3, 4),
      yearBuilt: 2012,
      enabledForms: {FormType.fourPoint},
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
        theme: AppTheme.dark(),
        home: DashboardPage(
          repository: repository,
          syncScheduler: scheduler,
          organizationId: organizationId,
          userId: userId,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(StatusBadge), findsOneWidget);
    expect(find.text('In Progress'), findsWidgets);
  });

  testWidgets('displays correct status badge for complete inspection', (
    tester,
  ) async {
    const organizationId = 'org-session';
    const userId = 'user-session';
    // Use _AllStatusInspectionStore so the complete inspection is returned
    final delegate = InMemoryInspectionStore();
    final store = _AllStatusInspectionStore(delegate);
    final repository = InspectionRepository(store);

    final setup = InspectionSetup(
      id: 'insp-status-comp',
      organizationId: organizationId,
      userId: userId,
      clientName: 'Complete Test',
      clientEmail: 'test@example.com',
      clientPhone: '555-0100',
      propertyAddress: '789 Elm Rd',
      inspectionDate: DateTime.utc(2026, 3, 4),
      yearBuilt: 2018,
      enabledForms: {FormType.fourPoint},
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
        lastStepIndex: 2,
        completion: completion,
        branchContext: const <String, dynamic>{},
        status: WizardProgressStatus.complete,
      ),
    );

    final scheduler = _TestSyncScheduler();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: DashboardPage(
          repository: repository,
          syncScheduler: scheduler,
          organizationId: organizationId,
          userId: userId,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(StatusBadge), findsOneWidget);
    expect(find.text('Complete'), findsOneWidget);
  });

  testWidgets('displays draft status badge for fresh inspection', (
    tester,
  ) async {
    const organizationId = 'org-session';
    const userId = 'user-session';
    final store = _ScopeSpyInspectionStore(InMemoryInspectionStore());
    final repository = InspectionRepository(store);

    // A fresh inspection with no wizard progress yields a draft badge
    final setup = InspectionSetup(
      id: 'insp-status-draft',
      organizationId: organizationId,
      userId: userId,
      clientName: 'Draft Test',
      clientEmail: 'test@example.com',
      clientPhone: '555-0100',
      propertyAddress: '101 Pine Ln',
      inspectionDate: DateTime.utc(2026, 3, 4),
      yearBuilt: 2005,
      enabledForms: {FormType.fourPoint},
    );
    await repository.createInspection(setup);
    // No wizard progress update -- defaults to empty snapshot (draft)

    final scheduler = _TestSyncScheduler();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: DashboardPage(
          repository: repository,
          syncScheduler: scheduler,
          organizationId: organizationId,
          userId: userId,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(StatusBadge), findsOneWidget);
    expect(find.text('Draft'), findsOneWidget);
  });

  testWidgets('pull to refresh reloads inspections', (tester) async {
    const organizationId = 'org-session';
    const userId = 'user-session';
    final store = _ScopeSpyInspectionStore(InMemoryInspectionStore());
    final repository = InspectionRepository(store);

    // Create an inspection so the RefreshIndicator-wrapped ListView is shown
    final setup = InspectionSetup(
      id: 'insp-refresh',
      organizationId: organizationId,
      userId: userId,
      clientName: 'Refresh Test',
      clientEmail: 'test@example.com',
      clientPhone: '555-0100',
      propertyAddress: '321 Maple Way',
      inspectionDate: DateTime.utc(2026, 3, 4),
      yearBuilt: 2011,
      enabledForms: {FormType.fourPoint},
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
        theme: AppTheme.dark(),
        home: DashboardPage(
          repository: repository,
          syncScheduler: scheduler,
          organizationId: organizationId,
          userId: userId,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // RefreshIndicator should be present in the widget tree
    expect(find.byType(RefreshIndicator), findsOneWidget);

    // Track the initial list call count
    store.listCallCount = 0;

    // Perform pull-to-refresh gesture (fling down from the top of the list)
    await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
    await tester.pumpAndSettle();

    // After pull-to-refresh, the repository's list method should be called again
    expect(store.listCallCount, greaterThanOrEqualTo(1));
  });
}

class _ScopeSpyInspectionStore implements InspectionStore {
  _ScopeSpyInspectionStore(this._delegate);

  final InMemoryInspectionStore _delegate;
  String? lastListOrganizationId;
  String? lastListUserId;
  int listCallCount = 0;

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
    listCallCount += 1;
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

/// A test store that delegates to [InMemoryInspectionStore] but returns ALL
/// inspections from [listInProgressInspections] regardless of wizard_status.
/// This lets tests exercise the dashboard's rendering of "complete" badges
/// and metrics, which the real store filters out.
class _AllStatusInspectionStore extends _ScopeSpyInspectionStore {
  _AllStatusInspectionStore(super.delegate);

  final List<String> _knownIds = [];

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> inspectionJson) {
    final id = inspectionJson['id'] as String;
    _knownIds.add(id);
    return super.create(inspectionJson);
  }

  @override
  Future<List<Map<String, dynamic>>> listInProgressInspections({
    required String organizationId,
    required String userId,
  }) async {
    lastListOrganizationId = organizationId;
    lastListUserId = userId;
    listCallCount += 1;
    // Fetch each known inspection by ID to return ALL regardless of status
    final results = <Map<String, dynamic>>[];
    for (final id in _knownIds) {
      final row = await _delegate.fetchById(
        inspectionId: id,
        organizationId: organizationId,
        userId: userId,
      );
      if (row != null) {
        results.add(row);
      }
    }
    return results;
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
