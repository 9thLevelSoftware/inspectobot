import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/data/inspection_repository.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/inspection_setup.dart';
import 'package:inspectobot/features/inspection/domain/inspection_wizard_state.dart';
import 'package:inspectobot/features/sync/sync_operation.dart';
import 'package:inspectobot/features/sync/sync_outbox_store.dart';

void main() {
  InspectionSetup buildSetup({
    String id = 'insp-1',
    String organizationId = 'org-1',
    String userId = 'user-1',
    DateTime? inspectionDate,
    int yearBuilt = 2004,
    Set<FormType>? enabledForms,
  }) {
    return InspectionSetup(
      id: id,
      organizationId: organizationId,
      userId: userId,
      clientName: 'Jane Doe',
      clientEmail: 'jane@example.com',
      clientPhone: '555-0100',
      propertyAddress: '123 Palm Ave, Tampa, FL',
      inspectionDate: inspectionDate ?? DateTime.utc(2026, 3, 4),
      yearBuilt: yearBuilt,
      enabledForms: enabledForms ?? {FormType.fourPoint, FormType.windMitigation},
    );
  }

  test('create and fetch preserve required setup payload shape', () async {
    final repository = InspectionRepository(InMemoryInspectionStore());
    final created = await repository.createInspection(buildSetup());

    expect(created.clientName, 'Jane Doe');
    expect(created.clientEmail, 'jane@example.com');
    expect(created.clientPhone, '555-0100');
    expect(created.propertyAddress, '123 Palm Ave, Tampa, FL');
    expect(created.yearBuilt, 2004);
    expect(created.inspectionDate.toIso8601String(), startsWith('2026-03-04'));

    final fetched = await repository.fetchInspectionById(
      inspectionId: created.id,
      organizationId: created.organizationId,
      userId: created.userId,
    );

    expect(fetched, isNotNull);
    expect(fetched!.id, created.id);
    expect(fetched.enabledForms, contains(FormType.fourPoint));
    expect(fetched.enabledForms, contains(FormType.windMitigation));
  });

  test('canonical form codes roundtrip through persistence mapping', () async {
    final repository = InspectionRepository(InMemoryInspectionStore());
    final created = await repository.createInspection(
      buildSetup(enabledForms: {FormType.roofCondition}),
    );

    expect(created.enabledForms.single.code, 'roof_condition');
    expect(created.enabledForms.single.label, 'RCF-1 03-25');

    final fetched = await repository.fetchInspectionById(
      inspectionId: created.id,
      organizationId: created.organizationId,
      userId: created.userId,
    );
    expect(fetched!.enabledForms.single, FormType.roofCondition);
  });

  test('create rejects empty form selection', () async {
    final repository = InspectionRepository(InMemoryInspectionStore());

    await expectLater(
      () => repository.createInspection(buildSetup(enabledForms: {})),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('create rejects invalid year built range', () async {
    final repository = InspectionRepository(InMemoryInspectionStore());

    await expectLater(
      () => repository.createInspection(buildSetup(yearBuilt: 1700)),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('create rejects far future inspection date', () async {
    final repository = InspectionRepository(InMemoryInspectionStore());

    await expectLater(
      () => repository.createInspection(
        buildSetup(inspectionDate: DateTime.now().add(const Duration(days: 450))),
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('fetch is isolated by organization and user scope', () async {
    final repository = InspectionRepository(InMemoryInspectionStore());
    final created = await repository.createInspection(buildSetup());

    final wrongOrg = await repository.fetchInspectionById(
      inspectionId: created.id,
      organizationId: 'org-2',
      userId: created.userId,
    );
    final wrongUser = await repository.fetchInspectionById(
      inspectionId: created.id,
      organizationId: created.organizationId,
      userId: 'user-2',
    );

    expect(wrongOrg, isNull);
    expect(wrongUser, isNull);
  });

  test('update and fetch wizard progress roundtrips checkpoint state', () async {
    final repository = InspectionRepository(InMemoryInspectionStore());
    final created = await repository.createInspection(buildSetup());

    final updated = await repository.updateWizardProgress(
      inspectionId: created.id,
      organizationId: created.organizationId,
      userId: created.userId,
      snapshot: const WizardProgressSnapshot(
        lastStepIndex: 2,
        completion: <String, bool>{
          'photo:exteriorFront': true,
          'photo:exteriorRear': false,
        },
        branchContext: <String, dynamic>{
          'enabled_forms': <String>['four_point'],
        },
        status: WizardProgressStatus.inProgress,
      ),
    );

    expect(updated.snapshot.lastStepIndex, 2);
    expect(updated.snapshot.completion['photo:exteriorFront'], isTrue);
    expect(updated.snapshot.completion['photo:exteriorRear'], isFalse);

    final fetched = await repository.fetchWizardProgress(
      inspectionId: created.id,
      organizationId: created.organizationId,
      userId: created.userId,
    );
    expect(fetched, isNotNull);
    expect(fetched!.snapshot.lastStepIndex, 2);
    expect(fetched.snapshot.status, WizardProgressStatus.inProgress);
    expect(fetched.snapshot.branchContext['enabled_forms'], isNotNull);
  });

  test('listInProgressInspections enforces tenant scoping and status filtering', () async {
    final repository = InspectionRepository(InMemoryInspectionStore());
    final inProgress = await repository.createInspection(
      buildSetup(id: 'insp-a', organizationId: 'org-1', userId: 'user-1'),
    );
    final complete = await repository.createInspection(
      buildSetup(id: 'insp-b', organizationId: 'org-1', userId: 'user-1'),
    );
    await repository.createInspection(
      buildSetup(id: 'insp-c', organizationId: 'org-2', userId: 'user-1'),
    );

    await repository.updateWizardProgress(
      inspectionId: inProgress.id,
      organizationId: inProgress.organizationId,
      userId: inProgress.userId,
      snapshot: const WizardProgressSnapshot(
        lastStepIndex: 1,
        completion: <String, bool>{'photo:exteriorFront': true},
        branchContext: <String, dynamic>{},
        status: WizardProgressStatus.inProgress,
      ),
    );
    await repository.updateWizardProgress(
      inspectionId: complete.id,
      organizationId: complete.organizationId,
      userId: complete.userId,
      snapshot: const WizardProgressSnapshot(
        lastStepIndex: 4,
        completion: <String, bool>{},
        branchContext: <String, dynamic>{},
        status: WizardProgressStatus.complete,
      ),
    );

    final rows = await repository.listInProgressInspections(
      organizationId: 'org-1',
      userId: 'user-1',
    );
    expect(rows.length, 1);
    expect(rows.single.inspectionId, inProgress.id);
  });

  test('malformed wizard payload falls back to safe defaults', () async {
    final malformedStore = _MalformedWizardPayloadStore();
    final repository = InspectionRepository(malformedStore);

    final progress = await repository.fetchWizardProgress(
      inspectionId: 'insp-1',
      organizationId: 'org-1',
      userId: 'user-1',
    );

    expect(progress, isNotNull);
    expect(progress!.snapshot.lastStepIndex, 0);
    expect(progress.snapshot.completion, isEmpty);
    expect(progress.snapshot.status, WizardProgressStatus.inProgress);
  });

  test('offline-first create queues inspection upsert operation', () async {
    final tempRoot = await Directory.systemTemp.createTemp('inspectobot_repo_queue_');
    addTearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    final outbox = SyncOutboxStore(directoryProvider: () async => tempRoot);
    final repository = InspectionRepository(
      OfflineFirstInspectionStore(
        localStore: InMemoryInspectionStore(),
        remoteStore: _AlwaysFailInspectionStore(),
      ),
      outboxStore: outbox,
      enqueueSyncOperations: true,
    );

    final created = await repository.createInspection(buildSetup(id: 'insp-offline'));
    expect(created.id, 'insp-offline');

    final pending = await outbox.listByStatus(SyncOperationStatus.pending);
    expect(pending.where((op) => op.type == SyncOperationType.inspectionUpsert), hasLength(1));
    expect(pending.first.aggregateId, 'insp-offline');
  });

  test('wizard progress updates queue deterministic upsert operation', () async {
    final tempRoot = await Directory.systemTemp.createTemp('inspectobot_repo_progress_');
    addTearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    final outbox = SyncOutboxStore(directoryProvider: () async => tempRoot);
    final repository = InspectionRepository(
      OfflineFirstInspectionStore(
        localStore: InMemoryInspectionStore(),
        remoteStore: _AlwaysFailInspectionStore(),
      ),
      outboxStore: outbox,
      enqueueSyncOperations: true,
    );

    final created = await repository.createInspection(buildSetup(id: 'insp-progress'));

    await repository.updateWizardProgress(
      inspectionId: created.id,
      organizationId: created.organizationId,
      userId: created.userId,
      snapshot: const WizardProgressSnapshot(
        lastStepIndex: 3,
        completion: <String, bool>{'photo:exteriorFront': true},
        branchContext: <String, dynamic>{'enabled_forms': <String>['four_point']},
        status: WizardProgressStatus.inProgress,
      ),
    );

    final pending = await outbox.listByStatus(SyncOperationStatus.pending);
    final wizardOps = pending.where(
      (op) => op.type == SyncOperationType.wizardProgressUpsert,
    );
    expect(wizardOps, hasLength(1));
    expect(
      wizardOps.single.payload['wizard_last_step'],
      3,
    );
  });
}

class _AlwaysFailInspectionStore implements InspectionStore {
  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> inspectionJson) async {
    throw StateError('offline');
  }

  @override
  Future<Map<String, dynamic>?> fetchById({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    throw StateError('offline');
  }

  @override
  Future<Map<String, dynamic>?> fetchWizardProgress({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    throw StateError('offline');
  }

  @override
  Future<List<Map<String, dynamic>>> listInProgressInspections({
    required String organizationId,
    required String userId,
  }) async {
    throw StateError('offline');
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
    throw StateError('offline');
  }
}

class _MalformedWizardPayloadStore implements InspectionStore {
  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> inspectionJson) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>?> fetchById({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>?> fetchWizardProgress({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    return <String, dynamic>{
      'id': inspectionId,
      'organization_id': organizationId,
      'user_id': userId,
      'client_name': 'Jane Doe',
      'property_address': '123 Palm Ave',
      'forms_enabled': <String>['four_point'],
      'wizard_last_step': 'bad-value',
      'wizard_completion': <String, dynamic>{'photo:exteriorFront': 'yes'},
      'wizard_branch_context': <String, dynamic>{'enabled_forms': <String>['four_point']},
      'wizard_status': 'unknown',
    };
  }

  @override
  Future<List<Map<String, dynamic>>> listInProgressInspections({
    required String organizationId,
    required String userId,
  }) async {
    return const <Map<String, dynamic>>[];
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
    throw UnimplementedError();
  }
}
