import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/required_photo_category.dart';
import 'package:inspectobot/features/media/local_media_store.dart';
import 'package:inspectobot/features/media/media_capture_service.dart';
import 'package:inspectobot/features/media/media_sync_task.dart';
import 'package:inspectobot/features/media/pending_media_sync_store.dart';

void main() {
  test('media capture service returns metadata and stores manifest', () async {
    final tempRoot = await Directory.systemTemp.createTemp(
      'inspectobot_capture_',
    );
    addTearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    final pickedFile = File('${tempRoot.path}/picked.jpg');
    await pickedFile.writeAsBytes(<int>[0, 1, 2, 3], flush: true);

    final outputFile = File('${tempRoot.path}/output.jpg');

    final store = LocalMediaStore(directoryProvider: () async => tempRoot);
    final pendingStore = PendingMediaSyncStore(
      directoryProvider: () async => tempRoot,
    );
    final service = MediaCaptureService(
      pickPhoto: () async => pickedFile.path,
      compressPhoto: (path) async => <int>[1, 2, 3],
      writeCapture:
          ({
            required inspectionId,
            required category,
            required mediaType,
            required sourcePath,
            bytes,
          }) async {
            expect(mediaType, CapturedMediaType.photo);
            expect(sourcePath, pickedFile.path);
            expect(bytes, isNotNull);
            await outputFile.writeAsBytes(bytes!, flush: true);
            return outputFile;
          },
      localStore: store,
      pendingSyncStore: pendingStore,
      operationIdFactory: () => 'op-123',
    );

    final result = await service.captureRequiredPhoto(
      inspectionId: 'inspection-2',
      organizationId: 'org-1',
      userId: 'user-1',
      category: RequiredPhotoCategory.exteriorRear,
    );

    expect(result.isSuccess, isTrue);
    expect(result.result!.filePath, outputFile.path);
    expect(result.result!.byteSize, 3);

    final manifest = await store.readCaptures('inspection-2');
    expect(manifest[RequiredPhotoCategory.exteriorRear], outputFile.path);

    final pending = await pendingStore.listPending();
    expect(pending.length, 1);
    expect(pending.first.inspectionId, 'inspection-2');
    expect(pending.first.organizationId, 'org-1');
    expect(pending.first.userId, 'user-1');
    expect(pending.first.taskId, 'op-123');
    expect(pending.first.category, RequiredPhotoCategory.exteriorRear);
    expect(pending.first.requirementKey, 'photo:exterior_rear');
    expect(pending.first.evidenceInstanceId, 'photo:exterior_rear');
    expect(pending.first.filePath, outputFile.path);
  });

  test('media capture service returns null when user cancels', () async {
    final tempRoot = await Directory.systemTemp.createTemp(
      'inspectobot_capture_cancel_',
    );
    addTearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    final store = LocalMediaStore(directoryProvider: () async => tempRoot);
    final pendingStore = PendingMediaSyncStore(
      directoryProvider: () async => tempRoot,
    );
    final service = MediaCaptureService(
      pickPhoto: () async => null,
      compressPhoto: (path) async => <int>[1, 2, 3],
      writeCapture:
          ({
            required inspectionId,
            required category,
            required mediaType,
            required sourcePath,
            bytes,
          }) async {
            throw StateError('should not write when canceled');
          },
      localStore: store,
      pendingSyncStore: pendingStore,
    );

    final result = await service.captureRequiredPhoto(
      inspectionId: 'inspection-3',
      organizationId: 'org-1',
      userId: 'user-1',
      category: RequiredPhotoCategory.exteriorRear,
    );

    expect(result.isError, isTrue);
    expect(result.error, MediaCaptureError.captureCanceled);
    final pending = await pendingStore.listPending();
    expect(pending, isEmpty);
  });

  test('capture still succeeds when outbox enqueue fails', () async {
    final tempRoot = await Directory.systemTemp.createTemp(
      'inspectobot_capture_enqueue_fail_',
    );
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
      writeCapture:
          ({
            required inspectionId,
            required category,
            required mediaType,
            required sourcePath,
            bytes,
          }) async {
            expect(mediaType, CapturedMediaType.photo);
            expect(bytes, isNotNull);
            await outputFile.writeAsBytes(bytes!, flush: true);
            return outputFile;
          },
      localStore: store,
      pendingSyncStore: failingPendingStore,
      operationIdFactory: () => 'op-fail-queue',
    );

    final result = await service.captureRequiredPhoto(
      inspectionId: 'inspection-4',
      organizationId: 'org-1',
      userId: 'user-1',
      category: RequiredPhotoCategory.exteriorFront,
    );

    expect(result.isSuccess, isTrue);
    expect(result.result!.filePath, outputFile.path);

    final manifest = await store.readCaptures('inspection-4');
    expect(manifest[RequiredPhotoCategory.exteriorFront], outputFile.path);
  });

  test(
    'document capture bypasses compression and preserves file extension',
    () async {
      final tempRoot = await Directory.systemTemp.createTemp(
        'inspectobot_capture_doc_',
      );
      addTearDown(() async {
        if (await tempRoot.exists()) {
          await tempRoot.delete(recursive: true);
        }
      });

      final pickedDoc = File('${tempRoot.path}/wind-doc.pdf');
      await pickedDoc.writeAsBytes(<int>[9, 8, 7, 6], flush: true);
      final outputDoc = File('${tempRoot.path}/stored-doc.pdf');
      var compressCalled = false;

      final store = LocalMediaStore(directoryProvider: () async => tempRoot);
      final pendingStore = PendingMediaSyncStore(
        directoryProvider: () async => tempRoot,
      );
      final service = MediaCaptureService(
        pickPhoto: () async =>
            throw StateError('photo picker should not be used'),
        pickDocument: () async => pickedDoc.path,
        compressPhoto: (_) async {
          compressCalled = true;
          return <int>[1, 2, 3];
        },
        writeCapture:
            ({
              required inspectionId,
              required category,
              required mediaType,
              required sourcePath,
              bytes,
            }) async {
              expect(mediaType, CapturedMediaType.document);
              expect(sourcePath, pickedDoc.path);
              expect(bytes, isNull);
              await outputDoc.writeAsBytes(
                await File(sourcePath).readAsBytes(),
                flush: true,
              );
              return outputDoc;
            },
        localStore: store,
        pendingSyncStore: pendingStore,
        operationIdFactory: () => 'op-doc-123',
      );

      final result = await service.captureRequiredPhoto(
        inspectionId: 'inspection-doc-1',
        organizationId: 'org-1',
        userId: 'user-1',
        category: RequiredPhotoCategory.windRoofDeck,
        requirementKey: 'document:wind_roof_deck',
        mediaType: CapturedMediaType.document,
        evidenceInstanceId: 'document:wind_roof_deck',
      );

      expect(result.isSuccess, isTrue);
      expect(result.result!.filePath, outputDoc.path);
      expect(result.result!.byteSize, 4);
      expect(compressCalled, isFalse);

      final pending = await pendingStore.listPending();
      expect(pending.single.mediaType, CapturedMediaType.document);
      expect(pending.single.requirementKey, 'document:wind_roof_deck');
    },
  );

  test('document capture rejects unsupported extension', () async {
    final tempRoot = await Directory.systemTemp.createTemp(
      'inspectobot_capture_doc_bad_',
    );
    addTearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    final pickedDoc = File('${tempRoot.path}/wind-doc.txt');
    await pickedDoc.writeAsBytes(<int>[1, 2], flush: true);
    var writeCalled = false;

    final service = MediaCaptureService(
      pickPhoto: () async =>
          throw StateError('photo picker should not be used'),
      pickDocument: () async => pickedDoc.path,
      compressPhoto: (_) async => <int>[1, 2, 3],
      writeCapture:
          ({
            required inspectionId,
            required category,
            required mediaType,
            required sourcePath,
            bytes,
          }) async {
            writeCalled = true;
            throw StateError('should not write unsupported document');
          },
    );

    final result = await service.captureRequiredPhoto(
      inspectionId: 'inspection-doc-2',
      organizationId: 'org-1',
      userId: 'user-1',
      category: RequiredPhotoCategory.windRoofDeck,
      mediaType: CapturedMediaType.document,
    );

    expect(result.isError, isTrue);
    expect(result.error, MediaCaptureError.unsupportedDocumentType);
    expect(writeCalled, isFalse);
  });

  test('media capture service returns error on camera permission denied', () async {
    final tempRoot = await Directory.systemTemp.createTemp(
      'inspectobot_capture_permission_',
    );
    addTearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    final store = LocalMediaStore(directoryProvider: () async => tempRoot);
    final pendingStore = PendingMediaSyncStore(
      directoryProvider: () async => tempRoot,
    );

    final service = MediaCaptureService(
      pickPhoto: () async => throw Exception('camera permission denied'),
      compressPhoto: (path) async => <int>[1, 2, 3],
      writeCapture:
          ({
            required inspectionId,
            required category,
            required mediaType,
            required sourcePath,
            bytes,
          }) async {
            throw StateError('should not write when permission denied');
          },
      localStore: store,
      pendingSyncStore: pendingStore,
    );

    final result = await service.captureRequiredPhoto(
      inspectionId: 'inspection-perm',
      organizationId: 'org-1',
      userId: 'user-1',
      category: RequiredPhotoCategory.exteriorRear,
    );

    expect(result.isError, isTrue);
    expect(result.errorMessage, isNotNull);
    expect(result.errorMessage!.toLowerCase(), contains('camera'));
    final pending = await pendingStore.listPending();
    expect(pending, isEmpty);
  });
}
