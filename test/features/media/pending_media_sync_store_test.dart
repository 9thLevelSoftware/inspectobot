import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/required_photo_category.dart';
import 'package:inspectobot/features/media/media_sync_task.dart';
import 'package:inspectobot/features/media/pending_media_sync_store.dart';
import 'package:inspectobot/features/sync/sync_operation.dart';
import 'package:inspectobot/features/sync/sync_outbox_store.dart';

void main() {
  test('enqueue and listPending keep only latest task per category', () async {
    final tempRoot = await Directory.systemTemp.createTemp('inspectobot_sync_queue_');
    addTearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    final store = PendingMediaSyncStore(directoryProvider: () async => tempRoot);

    final firstTask = MediaSyncTask(
      taskId: 't1',
      inspectionId: 'i1',
      organizationId: 'org-1',
      userId: 'user-1',
      requirementKey: 'photo:exteriorFront',
      mediaType: CapturedMediaType.photo,
      evidenceInstanceId: 'photo:exteriorFront',
      category: RequiredPhotoCategory.exteriorFront,
      filePath: '/tmp/front_1.jpg',
      createdAt: DateTime(2026, 1, 1),
    );
    final secondTask = MediaSyncTask(
      taskId: 't2',
      inspectionId: 'i1',
      organizationId: 'org-1',
      userId: 'user-1',
      requirementKey: 'photo:exteriorFront',
      mediaType: CapturedMediaType.photo,
      evidenceInstanceId: 'photo:exteriorFront',
      category: RequiredPhotoCategory.exteriorFront,
      filePath: '/tmp/front_2.jpg',
      createdAt: DateTime(2026, 1, 2),
    );

    await store.enqueue(firstTask);
    await store.enqueue(secondTask);

    final pending = await store.listPending();
    expect(pending.length, 1);
    expect(pending.first.taskId, 't2');
    expect(pending.first.filePath, '/tmp/front_2.jpg');
  });

  test('markUploaded removes queued task', () async {
    final tempRoot = await Directory.systemTemp.createTemp('inspectobot_sync_done_');
    addTearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    final store = PendingMediaSyncStore(directoryProvider: () async => tempRoot);
    final task = MediaSyncTask(
      taskId: 'done-task',
      inspectionId: 'i2',
      organizationId: 'org-1',
      userId: 'user-1',
      requirementKey: 'photo:windRoofDeck',
      mediaType: CapturedMediaType.photo,
      evidenceInstanceId: 'photo:windRoofDeck',
      category: RequiredPhotoCategory.windRoofDeck,
      filePath: '/tmp/deck.jpg',
      createdAt: DateTime(2026, 1, 3),
    );

    await store.enqueue(task);
    await store.markUploaded('done-task');

    final pending = await store.listPending();
    expect(pending, isEmpty);
  });

  test('enqueue attaches inspection dependency when prerequisite exists', () async {
    final tempRoot = await Directory.systemTemp.createTemp(
      'inspectobot_sync_dependency_',
    );
    addTearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    final outbox = SyncOutboxStore(directoryProvider: () async => tempRoot);
    await outbox.enqueue(
      SyncOperation(
        operationId: 'insp-op-1',
        type: SyncOperationType.inspectionUpsert,
        aggregateId: 'i3',
        organizationId: 'org-1',
        userId: 'user-1',
        payload: <String, dynamic>{
          'id': 'i3',
          'organization_id': 'org-1',
          'user_id': 'user-1',
        },
        createdAt: DateTime.utc(2026, 3, 5),
        updatedAt: DateTime.utc(2026, 3, 5),
      ),
    );

    final store = PendingMediaSyncStore(outboxStore: outbox);
    await store.enqueue(
      MediaSyncTask(
        taskId: 't3',
        inspectionId: 'i3',
        organizationId: 'org-1',
        userId: 'user-1',
        requirementKey: 'photo:exteriorFront',
        mediaType: CapturedMediaType.photo,
        evidenceInstanceId: 'photo:exteriorFront',
        category: RequiredPhotoCategory.exteriorFront,
        filePath: '/tmp/front_3.jpg',
        createdAt: DateTime.utc(2026, 3, 6),
      ),
    );

    final operations = await outbox.listAll();
    final mediaOp = operations.firstWhere(
      (operation) => operation.operationId == 't3',
    );
    expect(mediaOp.dependencyOperationId, 'insp-op-1');
  });

  test('loadEvidenceMediaPaths returns pending requirement-keyed file paths', () async {
    final tempRoot = await Directory.systemTemp.createTemp(
      'inspectobot_sync_rehydrate_',
    );
    addTearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    final store = PendingMediaSyncStore(directoryProvider: () async => tempRoot);
    await store.enqueue(
      MediaSyncTask(
        taskId: 'rehydrate-1',
        inspectionId: 'i4',
        organizationId: 'org-1',
        userId: 'user-1',
        requirementKey: 'photo:exteriorFront',
        mediaType: CapturedMediaType.photo,
        evidenceInstanceId: 'photo:exteriorFront',
        category: RequiredPhotoCategory.exteriorFront,
        filePath: '/tmp/front.jpg',
        createdAt: DateTime.utc(2026, 3, 6),
      ),
    );

    final byRequirement = await store.loadEvidenceMediaPaths(
      inspectionId: 'i4',
      organizationId: 'org-1',
      userId: 'user-1',
    );

    expect(byRequirement['photo:exteriorFront'], <String>['/tmp/front.jpg']);
  });
}

