import 'dart:io';
import 'dart:typed_data';

import 'package:inspectobot/data/supabase/supabase_client_provider.dart';
import 'package:inspectobot/features/storage/storage_path_contract.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'media_sync_task.dart';
import '../inspection/domain/required_photo_category.dart';

abstract class MediaStorageGateway {
  Future<void> upload({
    required String path,
    required Uint8List bytes,
    required String contentType,
  });
}

abstract class MediaMetadataGateway {
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
  });
}

class MediaSyncRemoteStore {
  MediaSyncRemoteStore({
    required MediaStorageGateway storage,
    required MediaMetadataGateway metadata,
  }) : _storage = storage,
       _metadata = metadata;

  factory MediaSyncRemoteStore.live() {
    if (!SupabaseClientProvider.isConfigured) {
      throw StateError('Supabase must be configured for remote media sync.');
    }
    final client = SupabaseClientProvider.client;
    return MediaSyncRemoteStore(
      storage: SupabaseMediaStorageGateway(client),
      metadata: SupabaseMediaMetadataGateway(client),
    );
  }

  final MediaStorageGateway _storage;
  final MediaMetadataGateway _metadata;

  String buildStoragePath({
    required String organizationId,
    required String userId,
    required String inspectionId,
    required String mediaId,
    required CapturedMediaType mediaType,
  }) {
    return buildMediaStoragePath(
      organizationId: organizationId,
      userId: userId,
      inspectionId: inspectionId,
      mediaId: mediaId,
      mediaType: mediaType,
    );
  }

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
  }) async {
    final bytes = await File(filePath).readAsBytes();
    final storagePath = buildStoragePath(
      organizationId: organizationId,
      userId: userId,
      inspectionId: inspectionId,
      mediaId: mediaId,
      mediaType: mediaType,
    );

    final contentType = _resolveContentType(
      mediaType: mediaType,
      filePath: filePath,
    );

    await _storage.upload(
      path: storagePath,
      bytes: bytes,
      contentType: contentType,
    );
    await _metadata.upsertMetadata(
      mediaId: mediaId,
      inspectionId: inspectionId,
      organizationId: organizationId,
      userId: userId,
      requirementKey: requirementKey,
      mediaType: mediaType,
      evidenceInstanceId: evidenceInstanceId,
      category: category,
      storagePath: storagePath,
      contentType: contentType,
      capturedAt: (capturedAt ?? DateTime.now()).toUtc(),
    );
  }

  static String _resolveContentType({
    required CapturedMediaType mediaType,
    required String filePath,
  }) {
    if (mediaType == CapturedMediaType.photo) {
      return 'image/jpeg';
    }

    final lowerPath = filePath.toLowerCase();
    if (lowerPath.endsWith('.png')) {
      return 'image/png';
    }
    if (lowerPath.endsWith('.jpg') || lowerPath.endsWith('.jpeg')) {
      return 'image/jpeg';
    }
    if (lowerPath.endsWith('.pdf')) {
      return 'application/pdf';
    }
    return 'application/octet-stream';
  }
}

class SupabaseMediaStorageGateway implements MediaStorageGateway {
  SupabaseMediaStorageGateway(this._client);

  final SupabaseClient _client;

  @override
  Future<void> upload({
    required String path,
    required Uint8List bytes,
    required String contentType,
  }) {
    return _client.storage
        .from('inspection-media-private')
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: true),
        );
  }
}

class SupabaseMediaMetadataGateway implements MediaMetadataGateway {
  SupabaseMediaMetadataGateway(this._client);

  final SupabaseClient _client;

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
  }) {
    return _client.from('inspection_media_assets').upsert(
      <String, dynamic>{
        'id': mediaId,
        'inspection_id': inspectionId,
        'organization_id': organizationId,
        'user_id': userId,
        'requirement_key': requirementKey,
        'media_type': mediaType.name,
        'evidence_instance_id': evidenceInstanceId,
        'category': category.name,
        'storage_path': storagePath,
        'content_type': contentType,
        'captured_at': capturedAt.toIso8601String(),
      },
      onConflict:
          'inspection_id,requirement_key,evidence_instance_id,media_type',
    );
  }
}
