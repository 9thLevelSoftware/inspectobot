import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/required_photo_category.dart';
import 'package:inspectobot/features/media/media_sync_remote_store.dart';
import 'package:inspectobot/features/media/media_sync_task.dart';

void main() {
  test('buildStoragePath uses org/users tenant contract for media uploads', () {
    final store = MediaSyncRemoteStore(
      storage: _CapturingStorageGateway(),
      metadata: _NoopMetadataGateway(),
    );

    final photoPath = store.buildStoragePath(
      organizationId: 'org-1',
      userId: 'user-1',
      inspectionId: 'insp-1',
      mediaId: 'media-1',
      mediaType: CapturedMediaType.photo,
    );
    final documentPath = store.buildStoragePath(
      organizationId: 'org-1',
      userId: 'user-1',
      inspectionId: 'insp-1',
      mediaId: 'media-2',
      mediaType: CapturedMediaType.document,
    );

    expect(
      photoPath,
      'org/org-1/users/user-1/inspections/insp-1/media/media-1.jpg',
    );
    expect(
      documentPath,
      'org/org-1/users/user-1/inspections/insp-1/media/media-2.pdf',
    );
  });

  test('upload uses pdf content type for document media', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'inspectobot_media_store_',
    );
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });
    final file = File('${tempDir.path}/doc.pdf');
    await file.writeAsBytes(Uint8List.fromList(<int>[1, 2, 3, 4]));

    final storage = _CapturingStorageGateway();
    final metadata = _CapturingMetadataGateway();
    final store = MediaSyncRemoteStore(storage: storage, metadata: metadata);

    await store.upload(
      mediaId: 'media-doc',
      inspectionId: 'insp-1',
      organizationId: 'org-1',
      userId: 'user-1',
      requirementKey: 'wind:doc',
      mediaType: CapturedMediaType.document,
      evidenceInstanceId: 'wind:doc',
      category: RequiredPhotoCategory.windRoofDeck,
      filePath: file.path,
    );

    expect(storage.lastContentType, 'application/pdf');
    expect(metadata.lastContentType, 'application/pdf');
    expect(
      storage.lastPath,
      'org/org-1/users/user-1/inspections/insp-1/media/media-doc.pdf',
    );
  });

  test(
    'upload preserves image content type for document image files',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'inspectobot_media_store_doc_image_',
      );
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });
      final file = File('${tempDir.path}/doc.jpg');
      await file.writeAsBytes(Uint8List.fromList(<int>[1, 2, 3, 4]));

      final storage = _CapturingStorageGateway();
      final metadata = _CapturingMetadataGateway();
      final store = MediaSyncRemoteStore(storage: storage, metadata: metadata);

      await store.upload(
        mediaId: 'media-doc-jpg',
        inspectionId: 'insp-1',
        organizationId: 'org-1',
        userId: 'user-1',
        requirementKey: 'wind:doc',
        mediaType: CapturedMediaType.document,
        evidenceInstanceId: 'wind:doc',
        category: RequiredPhotoCategory.windRoofDeck,
        filePath: file.path,
      );

      expect(storage.lastContentType, 'image/jpeg');
      expect(metadata.lastContentType, 'image/jpeg');
      expect(
        storage.lastPath,
        'org/org-1/users/user-1/inspections/insp-1/media/media-doc-jpg.pdf',
      );
    },
  );
}

class _CapturingStorageGateway implements MediaStorageGateway {
  String? lastPath;
  String? lastContentType;

  @override
  Future<void> upload({
    required String path,
    required Uint8List bytes,
    required String contentType,
  }) async {
    lastPath = path;
    lastContentType = contentType;
  }
}

class _NoopMetadataGateway implements MediaMetadataGateway {
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

class _CapturingMetadataGateway implements MediaMetadataGateway {
  String? lastContentType;

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
  }) async {
    lastContentType = contentType;
  }
}
