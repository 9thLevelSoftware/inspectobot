import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:inspectobot/features/audit/data/audit_event_repository.dart';
import 'package:inspectobot/data/supabase/supabase_client_provider.dart';
import 'package:inspectobot/features/delivery/data/delivery_repository.dart';
import 'package:inspectobot/features/delivery/data/report_artifact_repository.dart';
import 'package:inspectobot/features/delivery/domain/report_artifact.dart';
import 'package:inspectobot/features/pdf/pdf_generation_input.dart';
import 'package:inspectobot/features/storage/storage_path_contract.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeliveryLinkResult {
  const DeliveryLinkResult({required this.url, required this.correlationId});

  final String url;
  final String correlationId;
}

abstract class SignedUrlGateway {
  Future<String> createSignedUrl({
    required String bucket,
    required String path,
    required int expiresInSeconds,
  });
}

abstract class ShareGateway {
  Future<void> shareUri(String uri);
}

abstract class ReportArtifactStorageGateway {
  Future<void> upload({
    required String bucket,
    required String path,
    required Uint8List bytes,
    required String contentType,
  });

  Future<Uint8List?> read({required String bucket, required String path});
}

class DeliveryService {
  DeliveryService({
    required ReportArtifactRepository artifactRepository,
    required DeliveryRepository deliveryRepository,
    required AuditEventRepository auditRepository,
    required SignedUrlGateway signedUrlGateway,
    required ShareGateway shareGateway,
    ReportArtifactStorageGateway? artifactStorageGateway,
    this.defaultBucket = 'report-artifacts-private',
    this.signedUrlTtl = const Duration(minutes: 15),
  }) : _artifactRepository = artifactRepository,
        _deliveryRepository = deliveryRepository,
        _auditRepository = auditRepository,
        _signedUrlGateway = signedUrlGateway,
        _shareGateway = shareGateway,
        _artifactStorageGateway =
            artifactStorageGateway ?? InMemoryReportArtifactStorageGateway();

  factory DeliveryService.live() {
    if (!SupabaseClientProvider.isConfigured) {
      return DeliveryService(
        artifactRepository: ReportArtifactRepository(
          InMemoryReportArtifactGateway(),
        ),
        deliveryRepository: DeliveryRepository(InMemoryDeliveryActionGateway()),
        auditRepository: AuditEventRepository(InMemoryAuditEventGateway()),
        signedUrlGateway: InMemorySignedUrlGateway(),
        shareGateway: SharePlusGateway(),
        artifactStorageGateway: InMemoryReportArtifactStorageGateway(),
      );
    }
    final client = SupabaseClientProvider.client;
    return DeliveryService(
      artifactRepository: ReportArtifactRepository.live(),
      deliveryRepository: DeliveryRepository.live(),
      auditRepository: AuditEventRepository.live(),
      signedUrlGateway: SupabaseSignedUrlGateway(client),
      shareGateway: SharePlusGateway(),
      artifactStorageGateway: SupabaseReportArtifactStorageGateway(client),
    );
  }

  final ReportArtifactRepository _artifactRepository;
  final DeliveryRepository _deliveryRepository;
  final AuditEventRepository _auditRepository;
  final SignedUrlGateway _signedUrlGateway;
  final ShareGateway _shareGateway;
  final ReportArtifactStorageGateway _artifactStorageGateway;
  final String defaultBucket;
  final Duration signedUrlTtl;

  Future<ReportArtifact> persistGeneratedArtifact({
    required PdfGenerationInput input,
    required String localFilePath,
    required Uint8List bytes,
    required int sizeBytes,
    required String signatureHash,
    String contentType = 'application/pdf',
    String? payloadHash,
  }) async {
    final now = DateTime.now().toUtc();
    final correlationId =
        'delivery-artifact::${input.inspectionId}::${now.millisecondsSinceEpoch}';
    final fileName = localFilePath.split(RegExp(r'[\\/]')).last;
    final storagePath = buildReportArtifactStoragePath(
      organizationId: input.organizationId,
      userId: input.userId,
      inspectionId: input.inspectionId,
      fileName: fileName,
    );
    final uploadedHash = sha256.convert(bytes).toString();

    await _artifactStorageGateway.upload(
      bucket: defaultBucket,
      path: storagePath,
      bytes: bytes,
      contentType: contentType,
    );

    final persistedBytes = await _artifactStorageGateway.read(
      bucket: defaultBucket,
      path: storagePath,
    );
    if (persistedBytes == null || persistedBytes.isEmpty) {
      throw StateError('Generated report artifact bytes are not readable.');
    }
    final persistedHash = sha256.convert(persistedBytes).toString();
    if (persistedHash != uploadedHash) {
      throw StateError('Generated report artifact bytes hash mismatch.');
    }

    final artifact = await _artifactRepository.upsertGeneratedArtifact(
      inspectionId: input.inspectionId,
      organizationId: input.organizationId,
      userId: input.userId,
      storageBucket: defaultBucket,
      storagePath: storagePath,
      fileName: fileName,
      contentType: contentType,
      sizeBytes: sizeBytes,
      createdAt: now,
      payloadHash: payloadHash,
      signatureHash: signatureHash,
      metadata: <String, dynamic>{'source_path': localFilePath},
    );

    await _deliveryRepository.recordAction(
      artifactId: artifact.id,
      inspectionId: artifact.inspectionId,
      organizationId: artifact.organizationId,
      userId: artifact.userId,
      actionType: 'artifact_saved',
      channel: 'system',
      correlationId: correlationId,
      payload: <String, dynamic>{
        'artifact_id': artifact.id,
        'action_type': 'artifact_saved',
        'correlation_id': correlationId,
        'storage_path': artifact.storagePath,
        'size_bytes': artifact.sizeBytes,
      },
      occurredAt: now,
    );

    await _auditRepository.append(
      inspectionId: artifact.inspectionId,
      organizationId: artifact.organizationId,
      userId: artifact.userId,
      eventType: 'delivery_artifact_saved',
      occurredAt: now,
      payload: <String, dynamic>{
        'artifact_id': artifact.id,
        'action_type': 'artifact_saved',
        'correlation_id': correlationId,
        'storage_path': artifact.storagePath,
      },
    );

    return artifact;
  }

  Future<DeliveryLinkResult> startDownload({required ReportArtifact artifact}) {
    return _createLinkAndRecord(
      artifact: artifact,
      actionType: 'download_started',
      eventType: 'delivery_download_started',
      channel: 'download',
      shouldShare: false,
    );
  }

  Future<DeliveryLinkResult> startSecureShare({
    required ReportArtifact artifact,
  }) {
    return _createLinkAndRecord(
      artifact: artifact,
      actionType: 'share_started',
      eventType: 'delivery_share_started',
      channel: 'secure_share',
      shouldShare: true,
    );
  }

  Future<DeliveryLinkResult> _createLinkAndRecord({
    required ReportArtifact artifact,
    required String actionType,
    required String eventType,
    required String channel,
    required bool shouldShare,
  }) async {
    await _assertArtifactSavedBeforeAction(artifact);

    final now = DateTime.now().toUtc();
    final correlationId =
        '$actionType::${artifact.id}::${now.millisecondsSinceEpoch}';
    final url = await _signedUrlGateway.createSignedUrl(
      bucket: artifact.storageBucket,
      path: artifact.storagePath,
      expiresInSeconds: signedUrlTtl.inSeconds,
    );

    await _deliveryRepository.recordAction(
      artifactId: artifact.id,
      inspectionId: artifact.inspectionId,
      organizationId: artifact.organizationId,
      userId: artifact.userId,
      actionType: actionType,
      channel: channel,
      correlationId: correlationId,
      payload: <String, dynamic>{
        'artifact_id': artifact.id,
        'action_type': actionType,
        'correlation_id': correlationId,
        'signed_url_ttl_seconds': signedUrlTtl.inSeconds,
        'storage_path': artifact.storagePath,
      },
      occurredAt: now,
    );

    await _auditRepository.append(
      inspectionId: artifact.inspectionId,
      organizationId: artifact.organizationId,
      userId: artifact.userId,
      eventType: eventType,
      occurredAt: now,
      payload: <String, dynamic>{
        'artifact_id': artifact.id,
        'action_type': actionType,
        'correlation_id': correlationId,
        'signed_url_ttl_seconds': signedUrlTtl.inSeconds,
      },
    );

    if (shouldShare) {
      await _shareGateway.shareUri(url);
    }

    return DeliveryLinkResult(url: url, correlationId: correlationId);
  }

  Future<void> _assertArtifactSavedBeforeAction(ReportArtifact artifact) async {
    final actions = await _deliveryRepository.listByInspection(
      inspectionId: artifact.inspectionId,
      organizationId: artifact.organizationId,
      userId: artifact.userId,
    );
    final hasArtifactSaved = actions.any(
      (action) =>
          action.artifactId == artifact.id && action.actionType == 'artifact_saved',
    );
    if (!hasArtifactSaved) {
      throw StateError(
        'Cannot create delivery link before artifact_saved is recorded for artifact ${artifact.id}.',
      );
    }
  }
}

class SupabaseSignedUrlGateway implements SignedUrlGateway {
  SupabaseSignedUrlGateway(this._client);

  final SupabaseClient _client;

  @override
  Future<String> createSignedUrl({
    required String bucket,
    required String path,
    required int expiresInSeconds,
  }) {
    return _client.storage.from(bucket).createSignedUrl(path, expiresInSeconds);
  }
}

class SharePlusGateway implements ShareGateway {
  @override
  Future<void> shareUri(String uri) {
    return Share.share(uri);
  }
}

class SupabaseReportArtifactStorageGateway implements ReportArtifactStorageGateway {
  SupabaseReportArtifactStorageGateway(this._client);

  final SupabaseClient _client;

  @override
  Future<void> upload({
    required String bucket,
    required String path,
    required Uint8List bytes,
    required String contentType,
  }) {
    return _client.storage.from(bucket).uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(contentType: contentType, upsert: true),
    );
  }

  @override
  Future<Uint8List?> read({required String bucket, required String path}) async {
    final bytes = await _client.storage.from(bucket).download(path);
    if (bytes.isEmpty) {
      return null;
    }
    return bytes;
  }
}

class InMemorySignedUrlGateway implements SignedUrlGateway {
  @override
  Future<String> createSignedUrl({
    required String bucket,
    required String path,
    required int expiresInSeconds,
  }) async {
    return 'https://local.invalid/$bucket/$path?expires=$expiresInSeconds';
  }
}

class InMemoryReportArtifactStorageGateway
    implements ReportArtifactStorageGateway {
  final Map<String, Uint8List> _bytesByObject = <String, Uint8List>{};

  String _key(String bucket, String path) => '$bucket::$path';

  @override
  Future<void> upload({
    required String bucket,
    required String path,
    required Uint8List bytes,
    required String contentType,
  }) async {
    _bytesByObject[_key(bucket, path)] = Uint8List.fromList(bytes);
  }

  @override
  Future<Uint8List?> read({required String bucket, required String path}) async {
    final bytes = _bytesByObject[_key(bucket, path)];
    if (bytes == null) {
      return null;
    }
    return Uint8List.fromList(bytes);
  }
}
