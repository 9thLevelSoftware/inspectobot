import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/audit/data/audit_event_repository.dart';
import 'package:inspectobot/features/delivery/data/delivery_repository.dart';
import 'package:inspectobot/features/delivery/data/report_artifact_repository.dart';
import 'package:inspectobot/features/delivery/domain/report_artifact.dart';
import 'package:inspectobot/features/delivery/services/delivery_service.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/required_photo_category.dart';
import 'package:inspectobot/features/pdf/pdf_generation_input.dart';

void main() {
  PdfGenerationInput buildInput() {
    return PdfGenerationInput(
      inspectionId: 'insp-1',
      organizationId: 'org-1',
      userId: 'user-1',
      clientName: 'Jane Doe',
      propertyAddress: '123 Palm Ave',
      enabledForms: {FormType.fourPoint},
      capturedCategories: {RequiredPhotoCategory.exteriorFront},
    );
  }

  test(
    'persistGeneratedArtifact stores artifact and logs delivery/audit actions',
    () async {
      final auditGateway = InMemoryAuditEventGateway();
      final deliveryGateway = InMemoryDeliveryActionGateway();
      final service = DeliveryService(
        artifactRepository: ReportArtifactRepository(
          InMemoryReportArtifactGateway(),
        ),
        deliveryRepository: DeliveryRepository(deliveryGateway),
        auditRepository: AuditEventRepository(auditGateway),
        signedUrlGateway: _FakeSignedUrlGateway(),
        shareGateway: _NoopShareGateway(),
      );

      final artifact = await service.persistGeneratedArtifact(
        input: buildInput(),
        localFilePath: '/tmp/report.pdf',
        sizeBytes: 2048,
        payloadHash: 'payload-hash-1',
        signatureHash: 'signature-hash-1',
      );

      expect(
        artifact.storagePath,
        'org/org-1/users/user-1/reports/insp-1/report.pdf',
      );
      expect(artifact.payloadHash, 'payload-hash-1');
      expect(artifact.signatureHash, 'signature-hash-1');

      final deliveryActions = await DeliveryRepository(deliveryGateway)
          .listByInspection(
            inspectionId: 'insp-1',
            organizationId: 'org-1',
            userId: 'user-1',
          );
      expect(deliveryActions, hasLength(1));
      expect(deliveryActions.single.actionType, 'artifact_saved');

      final auditEvents = await AuditEventRepository(auditGateway)
          .listByInspection(
            inspectionId: 'insp-1',
            organizationId: 'org-1',
            userId: 'user-1',
          );
      expect(auditEvents, hasLength(1));
      expect(auditEvents.single.eventType, 'delivery_artifact_saved');
    },
  );

  test(
    'startSecureShare and startDownload issue 15-minute signed links and audit writes',
    () async {
      final auditGateway = InMemoryAuditEventGateway();
      final deliveryGateway = InMemoryDeliveryActionGateway();
      final signedUrlGateway = _FakeSignedUrlGateway();
      final shareGateway = _CapturingShareGateway();
      final service = DeliveryService(
        artifactRepository: ReportArtifactRepository(
          InMemoryReportArtifactGateway(),
        ),
        deliveryRepository: DeliveryRepository(deliveryGateway),
        auditRepository: AuditEventRepository(auditGateway),
        signedUrlGateway: signedUrlGateway,
        shareGateway: shareGateway,
      );

      final artifact = ReportArtifact(
        id: 'art-1',
        inspectionId: 'insp-2',
        organizationId: 'org-1',
        userId: 'user-1',
        storageBucket: 'report-artifacts-private',
        storagePath: 'org/org-1/users/user-1/reports/insp-2/report.pdf',
        fileName: 'report.pdf',
        contentType: 'application/pdf',
        sizeBytes: 1024,
        payloadHash: 'payload-hash',
        signatureHash: 'sig-hash',
        retainUntil: DateTime.utc(2031, 3, 5),
        createdAt: DateTime.utc(2026, 3, 5),
        updatedAt: DateTime.utc(2026, 3, 5),
      );

      final downloadResult = await service.startDownload(artifact: artifact);
      final shareResult = await service.startSecureShare(artifact: artifact);

      expect(downloadResult.url, contains('expires=900'));
      expect(shareResult.url, contains('expires=900'));
      expect(signedUrlGateway.lastExpiresInSeconds, 900);
      expect(shareGateway.sharedUris, hasLength(1));

      final actions = await DeliveryRepository(deliveryGateway)
          .listByInspection(
            inspectionId: 'insp-2',
            organizationId: 'org-1',
            userId: 'user-1',
          );
      expect(
        actions.map((action) => action.actionType),
        containsAll(<String>['download_started', 'share_started']),
      );

      final events = await AuditEventRepository(auditGateway).listByInspection(
        inspectionId: 'insp-2',
        organizationId: 'org-1',
        userId: 'user-1',
      );
      expect(
        events.map((event) => event.eventType),
        containsAll(<String>[
          'delivery_download_started',
          'delivery_share_started',
        ]),
      );
    },
  );
}

class _FakeSignedUrlGateway implements SignedUrlGateway {
  int? lastExpiresInSeconds;

  @override
  Future<String> createSignedUrl({
    required String bucket,
    required String path,
    required int expiresInSeconds,
  }) async {
    lastExpiresInSeconds = expiresInSeconds;
    return 'https://example.test/$bucket/$path?expires=$expiresInSeconds';
  }
}

class _NoopShareGateway implements ShareGateway {
  @override
  Future<void> shareUri(String uri) async {}
}

class _CapturingShareGateway implements ShareGateway {
  final List<String> sharedUris = <String>[];

  @override
  Future<void> shareUri(String uri) async {
    sharedUris.add(uri);
  }
}
