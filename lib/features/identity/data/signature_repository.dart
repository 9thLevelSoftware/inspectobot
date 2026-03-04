import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:inspectobot/data/supabase/supabase_client_provider.dart';
import 'package:inspectobot/features/identity/domain/inspector_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SignatureStorageGateway {
  Future<void> upload({required String path, required Uint8List bytes});
}

abstract class SignatureMetadataGateway {
  Future<void> upsertMetadata({
    required String organizationId,
    required String userId,
    required String storagePath,
    required String fileHash,
    required DateTime capturedAt,
  });

  Future<Map<String, dynamic>?> fetchMetadata({
    required String organizationId,
    required String userId,
  });
}

class SignatureRepository {
  SignatureRepository({
    required SignatureStorageGateway storage,
    required SignatureMetadataGateway metadata,
  }) : _storage = storage,
       _metadata = metadata;

  factory SignatureRepository.live() {
    if (SupabaseClientProvider.isConfigured) {
      final client = SupabaseClientProvider.client;
      return SignatureRepository(
        storage: SupabaseSignatureStorageGateway(client),
        metadata: SupabaseSignatureMetadataGateway(client),
      );
    }
    final inMemory = InMemorySignatureGateway();
    return SignatureRepository(storage: inMemory, metadata: inMemory);
  }

  final SignatureStorageGateway _storage;
  final SignatureMetadataGateway _metadata;

  String buildStoragePath({
    required String organizationId,
    required String userId,
  }) {
    return 'org/$organizationId/users/$userId/signature.png';
  }

  Future<SignatureRecord> saveSignature({
    required String organizationId,
    required String userId,
    required Uint8List bytes,
  }) async {
    final storagePath = buildStoragePath(
      organizationId: organizationId,
      userId: userId,
    );
    final fileHash = sha256.convert(bytes).toString();
    final capturedAt = DateTime.now().toUtc();

    await _storage.upload(path: storagePath, bytes: bytes);
    await _metadata.upsertMetadata(
      organizationId: organizationId,
      userId: userId,
      storagePath: storagePath,
      fileHash: fileHash,
      capturedAt: capturedAt,
    );

    return SignatureRecord(
      storagePath: storagePath,
      fileHash: fileHash,
      capturedAt: capturedAt,
    );
  }

  Future<SignatureRecord?> loadSignature({
    required String organizationId,
    required String userId,
  }) async {
    final json = await _metadata.fetchMetadata(
      organizationId: organizationId,
      userId: userId,
    );
    if (json == null) {
      return null;
    }

    return SignatureRecord(
      storagePath: json['storage_path'] as String,
      fileHash: json['file_hash'] as String,
      capturedAt: DateTime.parse(json['captured_at'] as String).toUtc(),
    );
  }
}

class SupabaseSignatureStorageGateway implements SignatureStorageGateway {
  SupabaseSignatureStorageGateway(this._client);

  final SupabaseClient _client;

  @override
  Future<void> upload({required String path, required Uint8List bytes}) {
    return _client.storage.from('signature-private').uploadBinary(
      path,
      bytes,
      fileOptions: const FileOptions(upsert: true),
    );
  }
}

class SupabaseSignatureMetadataGateway implements SignatureMetadataGateway {
  SupabaseSignatureMetadataGateway(this._client);

  final SupabaseClient _client;

  @override
  Future<Map<String, dynamic>?> fetchMetadata({
    required String organizationId,
    required String userId,
  }) async {
    final result = await _client
        .from('inspector_signatures')
        .select()
        .eq('organization_id', organizationId)
        .eq('user_id', userId)
        .maybeSingle();
    if (result == null) {
      return null;
    }
    return Map<String, dynamic>.from(result);
  }

  @override
  Future<void> upsertMetadata({
    required String organizationId,
    required String userId,
    required String storagePath,
    required String fileHash,
    required DateTime capturedAt,
  }) {
    return _client.from('inspector_signatures').upsert({
      'organization_id': organizationId,
      'user_id': userId,
      'storage_path': storagePath,
      'file_hash': fileHash,
      'captured_at': capturedAt.toIso8601String(),
    });
  }
}

class InMemorySignatureGateway
    implements SignatureStorageGateway, SignatureMetadataGateway {
  final Map<String, String> _bytesByPath = {};
  final Map<String, Map<String, dynamic>> _metadata = {};

  String _key(String organizationId, String userId) => '$organizationId::$userId';

  @override
  Future<Map<String, dynamic>?> fetchMetadata({
    required String organizationId,
    required String userId,
  }) async {
    return _metadata[_key(organizationId, userId)];
  }

  @override
  Future<void> upload({required String path, required Uint8List bytes}) async {
    _bytesByPath[path] = base64Encode(bytes);
  }

  @override
  Future<void> upsertMetadata({
    required String organizationId,
    required String userId,
    required String storagePath,
    required String fileHash,
    required DateTime capturedAt,
  }) async {
    _metadata[_key(organizationId, userId)] = {
      'storage_path': storagePath,
      'file_hash': fileHash,
      'captured_at': capturedAt.toIso8601String(),
    };
  }
}
