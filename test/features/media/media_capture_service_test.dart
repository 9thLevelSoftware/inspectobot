import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/required_photo_category.dart';
import 'package:inspectobot/features/media/local_media_store.dart';
import 'package:inspectobot/features/media/media_capture_service.dart';
import 'package:inspectobot/features/media/pending_media_sync_store.dart';

void main() {
  test('media capture service returns metadata and stores manifest', () async {
    final tempRoot = await Directory.systemTemp.createTemp('inspectobot_capture_');
    addTearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    final pickedFile = File('${tempRoot.path}/picked.jpg');
    await pickedFile.writeAsBytes(<int>[0, 1, 2, 3], flush: true);

    final outputFile = File('${tempRoot.path}/output.jpg');

    final store = LocalMediaStore(directoryProvider: () async => tempRoot);
    final pendingStore =
        PendingMediaSyncStore(directoryProvider: () async => tempRoot);
    final service = MediaCaptureService(
      pickPhoto: () async => pickedFile.path,
      compressPhoto: (path) async => <int>[1, 2, 3],
      writeCapture: ({required inspectionId, required category, required bytes}) async {
        await outputFile.writeAsBytes(bytes, flush: true);
        return outputFile;
      },
      localStore: store,
      pendingSyncStore: pendingStore,
      operationIdFactory: () => 'op-123',
    );

    final result = await service.captureRequiredPhoto(
      inspectionId: 'inspection-2',
      category: RequiredPhotoCategory.exteriorRear,
    );

    expect(result, isNotNull);
    expect(result!.filePath, outputFile.path);
    expect(result.byteSize, 3);

    final manifest = await store.readCaptures('inspection-2');
    expect(manifest[RequiredPhotoCategory.exteriorRear], outputFile.path);

    final pending = await pendingStore.listPending();
    expect(pending.length, 1);
    expect(pending.first.inspectionId, 'inspection-2');
    expect(pending.first.taskId, 'op-123');
    expect(pending.first.category, RequiredPhotoCategory.exteriorRear);
    expect(pending.first.filePath, outputFile.path);
  });

  test('media capture service returns null when user cancels', () async {
    final tempRoot = await Directory.systemTemp.createTemp('inspectobot_capture_cancel_');
    addTearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    final store = LocalMediaStore(directoryProvider: () async => tempRoot);
    final pendingStore =
        PendingMediaSyncStore(directoryProvider: () async => tempRoot);
    final service = MediaCaptureService(
      pickPhoto: () async => null,
      compressPhoto: (path) async => <int>[1, 2, 3],
      writeCapture: ({required inspectionId, required category, required bytes}) async {
        throw StateError('should not write when canceled');
      },
      localStore: store,
      pendingSyncStore: pendingStore,
    );

    final result = await service.captureRequiredPhoto(
      inspectionId: 'inspection-3',
      category: RequiredPhotoCategory.exteriorRear,
    );

    expect(result, isNull);
    final pending = await pendingStore.listPending();
    expect(pending, isEmpty);
  });

  test('capture still succeeds when outbox enqueue fails', () async {
    final tempRoot = await Directory.systemTemp.createTemp('inspectobot_capture_enqueue_fail_');
    addTearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    final pickedFile = File('${tempRoot.path}/picked.jpg');
    await pickedFile.writeAsBytes(<int>[0, 1, 2], flush: true);

    final outputFile = File('${tempRoot.path}/output.jpg');
    final store = LocalMediaStore(directoryProvider: () async => tempRoot);
    final failingPendingStore = PendingMediaSyncStore(
      directoryProvider: () async => throw StateError('disk unavailable'),
    );

    final service = MediaCaptureService(
      pickPhoto: () async => pickedFile.path,
      compressPhoto: (_) async => <int>[1, 2, 3],
      writeCapture: ({required inspectionId, required category, required bytes}) async {
        await outputFile.writeAsBytes(bytes, flush: true);
        return outputFile;
      },
      localStore: store,
      pendingSyncStore: failingPendingStore,
      operationIdFactory: () => 'op-fail-queue',
    );

    final result = await service.captureRequiredPhoto(
      inspectionId: 'inspection-4',
      category: RequiredPhotoCategory.exteriorFront,
    );

    expect(result, isNotNull);
    expect(result!.filePath, outputFile.path);

    final manifest = await store.readCaptures('inspection-4');
    expect(manifest[RequiredPhotoCategory.exteriorFront], outputFile.path);
  });
}
