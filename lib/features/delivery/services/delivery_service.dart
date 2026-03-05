import 'package:inspectobot/features/audit/data/audit_event_repository.dart';
import 'package:inspectobot/data/supabase/supabase_client_provider.dart';
import 'package:inspectobot/features/delivery/data/delivery_repository.dart';
import 'package:inspectobot/features/delivery/data/report_artifact_repository.dart';
import 'package:inspectobot/features/delivery/domain/report_artifact.dart';
import 'package:inspectobot/features/pdf/pdf_generation_input.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeliveryLinkResult {
  const DeliveryLinkResult({
    required this.url,
    required this.correlationId,
  });

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

class DeliveryService {
  DeliveryService({
    required ReportArtifactRepository artifactRepository,
    required DeliveryRepository deliveryRepository,
    required AuditEventRepository auditRepository,
    required SignedUrlGateway signedUrlGateway,
    required ShareGateway shareGateway,
    this.defaultBucket = 'report-artifacts-private',
    this.signedUrlTtl = const Duration(minutes: 15),
  })  : _artifactRepository = artifactRepository,
        _deliveryRepository = deliveryRepository,
        _auditRepository = auditRepository,
        _signedUrlGateway = signedUrlGateway,
        _shareGateway = shareGateway;

  factory DeliveryService.live() {
    if (!SupabaseClientProvider.isConfigured) {
      return DeliveryService(
        artifactRepository: ReportArtifactRepository(InMemoryReportArtifactGateway()),
        deliveryRepository: DeliveryRepository(InMemoryDeliveryActionGateway()),
        auditRepository: AuditEventRepository(InMemoryAuditEventGateway()),
        signedUrlGateway: InMemorySignedUrlGateway(),
        shareGateway: SharePlusGateway(),
      );
    }
    final client = SupabaseClientProvider.client;
    return DeliveryService(
      artifactRepository: ReportArtifactRepository.live(),
      deliveryRepository: DeliveryRepository.live(),
      auditRepository: AuditEventRepository.live(),
      signedUrlGateway: SupabaseSignedUrlGateway(client),
      shareGateway: SharePlusGateway(),
    );
  }

  final ReportArtifactRepository _artifactRepository;
  final DeliveryRepository _deliveryRepository;
  final AuditEventRepository _auditRepository;
  final SignedUrlGateway _signedUrlGateway;
  final ShareGateway _shareGateway;
  final String defaultBucket;
  final Duration signedUrlTtl;

  Future<ReportArtifact> persistGeneratedArtifact({
    required PdfGenerationInput input,
    required String localFilePath,
    required int sizeBytes,
    required String signatureHash,
    String contentType = 'application/pdf',
    String? payloadHash,
  }) async {
    final now = DateTime.now().toUtc();
    final correlationId = 'delivery-artifact::${input.inspectionId}::${now.millisecondsSinceEpoch}';
    final fileName = localFilePath.split(RegExp(r'[\\/]')).last;
    final storagePath = '${input.organizationId}/${input.userId}/reports/${input.inspectionId}/$fileName';

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
      metadata: <String, dynamic>{
        'source_path': localFilePath,
      },
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

  Future<DeliveryLinkResult> startSecureShare({required ReportArtifact artifact}) {
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
    final now = DateTime.now().toUtc();
    final correlationId = '$actionType::${artifact.id}::${now.millisecondsSinceEpoch}';
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
        'correlation_id': correlationId,
        'signed_url_ttl_seconds': signedUrlTtl.inSeconds,
      },
    );

    if (shouldShare) {
      await _shareGateway.shareUri(url);
    }

    return DeliveryLinkResult(url: url, correlationId: correlationId);
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
