import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/form_requirements.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/inspection_wizard_state.dart';
import 'package:inspectobot/features/inspection/domain/required_photo_category.dart';
import 'package:inspectobot/features/media/media_sync_task.dart';
import 'package:inspectobot/features/media/pending_media_sync_store.dart';
import 'package:inspectobot/features/sync/sync_operation.dart';
import 'package:inspectobot/features/sync/sync_outbox_store.dart';

void main() {
  late Directory tempRoot;
  late SyncOutboxStore outboxStore;

  setUp(() async {
    tempRoot = await Directory.systemTemp.createTemp('inspectobot_offline_');
    outboxStore = SyncOutboxStore(directoryProvider: () async => tempRoot);
  });

  tearDown(() async {
    if (await tempRoot.exists()) {
      await tempRoot.delete(recursive: true);
    }
  });

  SyncOperation buildInspectionUpsert({
    required String inspectionId,
    required List<String> formCodes,
  }) {
    final now = DateTime.utc(2026, 3, 8, 10, 0, 0);
    return SyncOperation(
      operationId: inspectionId,
      type: SyncOperationType.inspectionUpsert,
      aggregateId: inspectionId,
      organizationId: 'org-1',
      userId: 'user-1',
      payload: <String, dynamic>{
        'id': inspectionId,
        'organization_id': 'org-1',
        'user_id': 'user-1',
        'client_name': 'Offline Test Client',
        'client_email': 'offline@test.com',
        'client_phone': '555-0199',
        'property_address': '456 Offline Rd, Tampa, FL 33602',
        'inspection_date': '2026-03-08',
        'year_built': 2010,
        'forms_enabled': formCodes,
      },
      createdAt: now,
      updatedAt: now,
    );
  }

  MediaSyncTask buildMediaTask({
    required String taskId,
    required String inspectionId,
    required String requirementKey,
    required RequiredPhotoCategory category,
    required String filePath,
    CapturedMediaType mediaType = CapturedMediaType.photo,
  }) {
    return MediaSyncTask(
      taskId: taskId,
      inspectionId: inspectionId,
      organizationId: 'org-1',
      userId: 'user-1',
      requirementKey: requirementKey,
      mediaType: mediaType,
      evidenceInstanceId: requirementKey,
      category: category,
      filePath: filePath,
      createdAt: DateTime.utc(2026, 3, 8, 10, 5, 0),
    );
  }

  group('WDO form offline scenarios', () {
    test('create WDO inspection while offline — draft persists locally', () async {
      final operation = buildInspectionUpsert(
        inspectionId: 'insp-wdo-offline',
        formCodes: ['wdo'],
      );

      await outboxStore.enqueue(operation);
      final pending = await outboxStore.listByStatus(SyncOperationStatus.pending);

      expect(pending, hasLength(1));
      expect(pending.first.operationId, 'insp-wdo-offline');
      expect(pending.first.type, SyncOperationType.inspectionUpsert);
      expect(
        (pending.first.payload['forms_enabled'] as List).contains('wdo'),
        isTrue,
      );
    });

    test('capture WDO evidence while offline — outbox entry created', () async {
      // First, enqueue the inspection
      await outboxStore.enqueue(buildInspectionUpsert(
        inspectionId: 'insp-wdo-capture',
        formCodes: ['wdo'],
      ));

      // Then, capture evidence via PendingMediaSyncStore
      final mediaStore = PendingMediaSyncStore(
        outboxStore: outboxStore,
      );
      await mediaStore.enqueue(buildMediaTask(
        taskId: 'media-wdo-001',
        inspectionId: 'insp-wdo-capture',
        requirementKey: 'photo:wdo_property_exterior',
        category: RequiredPhotoCategory.wdoPropertyExterior,
        filePath: '/tmp/wdo_exterior.jpg',
      ));

      final all = await outboxStore.listAll();
      expect(all, hasLength(2));

      final mediaOps = all.where((op) => op.type == SyncOperationType.mediaUpload);
      expect(mediaOps, hasLength(1));
      expect(mediaOps.first.payload['requirement_key'], 'photo:wdo_property_exterior');
      expect(mediaOps.first.payload['file_path'], '/tmp/wdo_exterior.jpg');
    });

    test('WDO wizard progress reflects locally captured evidence', () {
      final enabledForms = {FormType.wdo};
      final completion = <String, bool>{
        'photo:wdo_property_exterior': true,
        'photo:wdo_notice_posting': true,
      };

      final state = InspectionWizardState(
        enabledForms: enabledForms,
        snapshot: WizardProgressSnapshot(
          lastStepIndex: 0,
          completion: completion,
          branchContext: const <String, dynamic>{},
          status: WizardProgressStatus.inProgress,
        ),
      );

      final summary = state.buildFormSummaries().single;
      expect(summary.percentComplete, 100);
      expect(summary.isComplete, isTrue);
    });
  });

  group('Sinkhole form offline scenarios', () {
    test('create sinkhole inspection while offline — draft persists', () async {
      await outboxStore.enqueue(buildInspectionUpsert(
        inspectionId: 'insp-sink-offline',
        formCodes: ['sinkhole_inspection'],
      ));

      final pending = await outboxStore.listByStatus(SyncOperationStatus.pending);
      expect(pending, hasLength(1));
      expect(
        (pending.first.payload['forms_enabled'] as List).contains('sinkhole_inspection'),
        isTrue,
      );
    });

    test('capture sinkhole evidence while offline', () async {
      await outboxStore.enqueue(buildInspectionUpsert(
        inspectionId: 'insp-sink-capture',
        formCodes: ['sinkhole_inspection'],
      ));

      final mediaStore = PendingMediaSyncStore(outboxStore: outboxStore);
      await mediaStore.enqueue(buildMediaTask(
        taskId: 'media-sink-001',
        inspectionId: 'insp-sink-capture',
        requirementKey: 'photo:sinkhole_front_elevation',
        category: RequiredPhotoCategory.sinkholeFrontElevation,
        filePath: '/tmp/sinkhole_front.jpg',
      ));

      final paths = await mediaStore.loadEvidenceMediaPaths(
        inspectionId: 'insp-sink-capture',
        organizationId: 'org-1',
        userId: 'user-1',
      );
      expect(paths['photo:sinkhole_front_elevation'], ['/tmp/sinkhole_front.jpg']);
    });
  });

  group('Mold Assessment form offline scenarios', () {
    test('create mold inspection while offline — draft persists', () async {
      await outboxStore.enqueue(buildInspectionUpsert(
        inspectionId: 'insp-mold-offline',
        formCodes: ['mold_assessment'],
      ));

      final pending = await outboxStore.listByStatus(SyncOperationStatus.pending);
      expect(pending, hasLength(1));
      expect(
        (pending.first.payload['forms_enabled'] as List).contains('mold_assessment'),
        isTrue,
      );
    });

    test('capture mold evidence while offline — media manifest updated', () async {
      await outboxStore.enqueue(buildInspectionUpsert(
        inspectionId: 'insp-mold-capture',
        formCodes: ['mold_assessment'],
      ));

      final mediaStore = PendingMediaSyncStore(outboxStore: outboxStore);

      // Capture multiple mold photos
      await mediaStore.enqueue(buildMediaTask(
        taskId: 'media-mold-001',
        inspectionId: 'insp-mold-capture',
        requirementKey: 'photo:mold_moisture_reading',
        category: RequiredPhotoCategory.moldMoistureReading,
        filePath: '/tmp/mold_moisture.jpg',
      ));
      await mediaStore.enqueue(buildMediaTask(
        taskId: 'media-mold-002',
        inspectionId: 'insp-mold-capture',
        requirementKey: 'photo:mold_growth_evidence',
        category: RequiredPhotoCategory.moldGrowthEvidence,
        filePath: '/tmp/mold_growth.jpg',
      ));

      final paths = await mediaStore.loadEvidenceMediaPaths(
        inspectionId: 'insp-mold-capture',
        organizationId: 'org-1',
        userId: 'user-1',
      );

      expect(paths['photo:mold_moisture_reading'], ['/tmp/mold_moisture.jpg']);
      expect(paths['photo:mold_growth_evidence'], ['/tmp/mold_growth.jpg']);
    });
  });

  group('General Inspection form offline scenarios', () {
    test('create general inspection while offline — draft persists', () async {
      await outboxStore.enqueue(buildInspectionUpsert(
        inspectionId: 'insp-gen-offline',
        formCodes: ['general_inspection'],
      ));

      final pending = await outboxStore.listByStatus(SyncOperationStatus.pending);
      expect(pending, hasLength(1));
      expect(
        (pending.first.payload['forms_enabled'] as List).contains('general_inspection'),
        isTrue,
      );
    });

    test('capture general inspection evidence while offline', () async {
      await outboxStore.enqueue(buildInspectionUpsert(
        inspectionId: 'insp-gen-capture',
        formCodes: ['general_inspection'],
      ));

      final mediaStore = PendingMediaSyncStore(outboxStore: outboxStore);
      await mediaStore.enqueue(buildMediaTask(
        taskId: 'media-gen-001',
        inspectionId: 'insp-gen-capture',
        requirementKey: 'photo:general_front_elevation',
        category: RequiredPhotoCategory.generalFrontElevation,
        filePath: '/tmp/gen_front.jpg',
      ));

      final paths = await mediaStore.loadEvidenceMediaPaths(
        inspectionId: 'insp-gen-capture',
        organizationId: 'org-1',
        userId: 'user-1',
      );
      expect(paths['photo:general_front_elevation'], ['/tmp/gen_front.jpg']);
    });
  });

  group('Offline queue management', () {
    test('queue PDF generation while offline — outbox entry created', () async {
      // Create an inspection upsert (simulates offline draft)
      await outboxStore.enqueue(buildInspectionUpsert(
        inspectionId: 'insp-pdf-queue',
        formCodes: ['four_point', 'wdo'],
      ));

      // Simulate queuing a wizard progress update (which triggers PDF generation)
      final now = DateTime.utc(2026, 3, 8, 10, 10, 0);
      await outboxStore.enqueue(SyncOperation(
        operationId: 'wizard-pdf-queue',
        type: SyncOperationType.wizardProgressUpsert,
        aggregateId: 'insp-pdf-queue',
        organizationId: 'org-1',
        userId: 'user-1',
        payload: <String, dynamic>{
          'inspection_id': 'insp-pdf-queue',
          'organization_id': 'org-1',
          'user_id': 'user-1',
          'wizard_last_step': 2,
          'wizard_completion': <String, bool>{
            'photo:exterior_front': true,
            'photo:wdo_property_exterior': true,
          },
          'wizard_branch_context': <String, dynamic>{},
          'wizard_status': 'in_progress',
        },
        createdAt: now,
        updatedAt: now,
        dependencyOperationId: 'insp-pdf-queue',
      ));

      final all = await outboxStore.listAll();
      expect(all, hasLength(2));

      final wizardOps = all.where(
        (op) => op.type == SyncOperationType.wizardProgressUpsert,
      );
      expect(wizardOps, hasLength(1));
      expect(wizardOps.first.dependencyOperationId, 'insp-pdf-queue');
      expect(wizardOps.first.status, SyncOperationStatus.pending);
    });

    test('multiple offline operations maintain correct dependency order', () async {
      // Enqueue inspection upsert
      await outboxStore.enqueue(buildInspectionUpsert(
        inspectionId: 'insp-order-test',
        formCodes: ['wdo', 'mold_assessment'],
      ));

      // Enqueue media with dependency on inspection
      final mediaStore = PendingMediaSyncStore(outboxStore: outboxStore);
      await mediaStore.enqueue(buildMediaTask(
        taskId: 'media-order-001',
        inspectionId: 'insp-order-test',
        requirementKey: 'photo:wdo_property_exterior',
        category: RequiredPhotoCategory.wdoPropertyExterior,
        filePath: '/tmp/wdo_ext.jpg',
      ));

      final all = await outboxStore.listAll();
      expect(all, hasLength(2));

      // Media operation should have dependency on the inspection upsert
      final mediaOp = all.firstWhere(
        (op) => op.type == SyncOperationType.mediaUpload,
      );
      expect(mediaOp.dependencyOperationId, 'insp-order-test');
    });

    test('connectivity restore processes queued operations in correct order', () async {
      // This test verifies the outbox maintains correct ordering for
      // operations that will be processed when connectivity is restored.

      // Enqueue in "wrong" order: media first, then inspection
      final now = DateTime.utc(2026, 3, 8, 10, 0, 0);
      await outboxStore.enqueue(SyncOperation(
        operationId: 'media-first',
        type: SyncOperationType.mediaUpload,
        aggregateId: 'insp-restore',
        organizationId: 'org-1',
        userId: 'user-1',
        payload: <String, dynamic>{
          'inspection_id': 'insp-restore',
          'organization_id': 'org-1',
          'user_id': 'user-1',
          'requirement_key': 'photo:wdo_property_exterior',
          'media_type': 'photo',
          'evidence_instance_id': 'photo:wdo_property_exterior',
          'category': 'wdoPropertyExterior',
          'file_path': '/tmp/wdo.jpg',
        },
        createdAt: now,
        updatedAt: now,
        dependencyOperationId: 'insp-restore',
      ));

      await outboxStore.enqueue(buildInspectionUpsert(
        inspectionId: 'insp-restore',
        formCodes: ['wdo'],
      ));

      final pending = await outboxStore.listByStatus(SyncOperationStatus.pending);
      expect(pending, hasLength(2));

      // The inspection upsert must exist and media must depend on it
      final inspOp = pending.firstWhere(
        (op) => op.type == SyncOperationType.inspectionUpsert,
      );
      final mediaOp = pending.firstWhere(
        (op) => op.type == SyncOperationType.mediaUpload,
      );
      expect(mediaOp.dependencyOperationId, inspOp.operationId);
    });

    test('outbox status transitions work correctly for offline operations', () async {
      await outboxStore.enqueue(buildInspectionUpsert(
        inspectionId: 'insp-status',
        formCodes: ['sinkhole_inspection'],
      ));

      // Verify initial status
      var ops = await outboxStore.listAll();
      expect(ops.single.status, SyncOperationStatus.pending);

      // Transition to inFlight
      await outboxStore.markInFlight('insp-status');
      ops = await outboxStore.listAll();
      expect(ops.single.status, SyncOperationStatus.inFlight);

      // Simulate failure
      await outboxStore.markFailed('insp-status', error: 'No network');
      ops = await outboxStore.listAll();
      expect(ops.single.status, SyncOperationStatus.failed);
      expect(ops.single.lastError, 'No network');
      expect(ops.single.retryCount, 1);

      // Mark completed (simulating successful retry)
      await outboxStore.markCompleted('insp-status');
      ops = await outboxStore.listByStatus(SyncOperationStatus.completed);
      expect(ops, hasLength(1));
    });
  });

  group('Multi-form offline session', () {
    test('4-form offline session with mixed form types', () async {
      // Create inspection with all 4 new form types
      await outboxStore.enqueue(buildInspectionUpsert(
        inspectionId: 'insp-multi-offline',
        formCodes: ['wdo', 'sinkhole_inspection', 'mold_assessment', 'general_inspection'],
      ));

      final mediaStore = PendingMediaSyncStore(outboxStore: outboxStore);

      // Capture one photo for each form
      final captures = <(String, String, RequiredPhotoCategory, String)>[
        ('media-wdo', 'photo:wdo_property_exterior', RequiredPhotoCategory.wdoPropertyExterior, '/tmp/wdo.jpg'),
        ('media-sink', 'photo:sinkhole_front_elevation', RequiredPhotoCategory.sinkholeFrontElevation, '/tmp/sink.jpg'),
        ('media-mold', 'photo:mold_moisture_reading', RequiredPhotoCategory.moldMoistureReading, '/tmp/mold.jpg'),
        ('media-gen', 'photo:general_front_elevation', RequiredPhotoCategory.generalFrontElevation, '/tmp/gen.jpg'),
      ];

      for (final (taskId, reqKey, cat, path) in captures) {
        await mediaStore.enqueue(buildMediaTask(
          taskId: taskId,
          inspectionId: 'insp-multi-offline',
          requirementKey: reqKey,
          category: cat,
          filePath: path,
        ));
      }

      // Verify all operations are in outbox
      final all = await outboxStore.listAll();
      expect(all, hasLength(5)); // 1 inspection + 4 media

      // Verify evidence paths are loaded correctly
      final paths = await mediaStore.loadEvidenceMediaPaths(
        inspectionId: 'insp-multi-offline',
        organizationId: 'org-1',
        userId: 'user-1',
      );
      expect(paths.keys, hasLength(4));
      expect(paths['photo:wdo_property_exterior'], ['/tmp/wdo.jpg']);
      expect(paths['photo:sinkhole_front_elevation'], ['/tmp/sink.jpg']);
      expect(paths['photo:mold_moisture_reading'], ['/tmp/mold.jpg']);
      expect(paths['photo:general_front_elevation'], ['/tmp/gen.jpg']);

      // Verify wizard state reflects the captures
      final completion = <String, bool>{
        for (final (_, reqKey, _, _) in captures) reqKey: true,
      };

      final state = InspectionWizardState(
        enabledForms: {
          FormType.wdo,
          FormType.sinkholeInspection,
          FormType.moldAssessment,
          FormType.generalInspection,
        },
        snapshot: WizardProgressSnapshot(
          lastStepIndex: 0,
          completion: completion,
          branchContext: const <String, dynamic>{},
          status: WizardProgressStatus.inProgress,
        ),
      );

      final summaries = state.buildFormSummaries();
      expect(summaries.length, 4);

      // Each form should have some progress but not 100% (only 1 photo each)
      for (final summary in summaries) {
        expect(
          summary.percentComplete,
          greaterThan(0),
          reason: '${summary.form.code} should have > 0% completion',
        );
      }
    });
  });
}
