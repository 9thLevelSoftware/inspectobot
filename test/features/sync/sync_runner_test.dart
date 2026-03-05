import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/auth/domain/tenant_context.dart';
import 'package:inspectobot/features/inspection/data/inspection_repository.dart';
import 'package:inspectobot/features/inspection/domain/required_photo_category.dart';
import 'package:inspectobot/features/media/media_sync_remote_store.dart';
import 'package:inspectobot/features/media/media_sync_task.dart';
import 'package:inspectobot/features/sync/sync_operation.dart';
import 'package:inspectobot/features/sync/sync_outbox_store.dart';
import 'package:inspectobot/features/sync/sync_runner.dart';

void main() {
  SyncOperation buildOp({
    required String id,
    required SyncOperationType type,
    required Map<String, dynamic> payload,
    int retryCount = 0,
    SyncOperationStatus status = SyncOperationStatus.pending,
    int maxRetries = 3,
  }) {
    final now = DateTime.utc(2026, 3, 4, 18, 0, 0);
    return SyncOperation(
      operationId: id,
      type: type,
      aggregateId: payload['inspection_id']?.toString() ?? 'insp-1',
      organizationId: 'org-1',
      userId: 'user-1',
      payload: payload,
      createdAt: now,
      updatedAt: now,
      retryCount: retryCount,
      status: status,
      maxRetries: maxRetries,
    );
  }

  test('runner executes operations in dependency-safe order', () async {
    final tempRoot = await Directory.systemTemp.createTemp(
      'inspectobot_sync_runner_',
    );
    addTearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    final outbox = SyncOutboxStore(directoryProvider: () async => tempRoot);
    await outbox.enqueue(
      buildOp(
        id: 'media-1',
        type: SyncOperationType.mediaUpload,
        payload: <String, dynamic>{
          'inspection_id': 'insp-1',
          'organization_id': 'org-1',
          'user_id': 'user-1',
          'requirement_key': 'photo:exteriorFront',
          'media_type': 'photo',
          'evidence_instance_id': 'photo:exteriorFront',
          'category': 'exteriorFront',
          'file_path': '/tmp/front.jpg',
        },
      ),
    );
    await outbox.enqueue(
      buildOp(
        id: 'insp-1',
        type: SyncOperationType.inspectionUpsert,
        payload: <String, dynamic>{
          'id': 'insp-1',
          'organization_id': 'org-1',
          'user_id': 'user-1',
          'client_name': 'Jane Doe',
          'client_email': 'jane@example.com',
          'client_phone': '555-0100',
          'property_address': '123 Palm Ave',
          'inspection_date': '2026-03-04',
          'year_built': 2004,
          'forms_enabled': <String>['four_point'],
        },
      ),
    );

    final inspectionStore = _RecordingInspectionStore();
    final mediaStore = _RecordingMediaRemoteStore();
    final runner = SyncRunner(
      outboxStore: outbox,
      inspectionRemoteStore: inspectionStore,
      mediaRemoteStore: mediaStore,
    );

    final result = await runner.runPending(
      activeTenantContext: const TenantContext(
        userId: 'user-1',
        organizationId: 'org-1',
      ),
    );
    expect(result.attempted, 2);
    expect(result.succeeded, 2);
    expect(result.failed, 0);
    expect(inspectionStore.events.first, 'inspection:create:insp-1');
    expect(mediaStore.events.first, 'media:upload:media-1');
  });

  test(
    'runner increments retry metadata and skips exhausted failures',
    () async {
      final tempRoot = await Directory.systemTemp.createTemp(
        'inspectobot_sync_retry_',
      );
      addTearDown(() async {
        if (await tempRoot.exists()) {
          await tempRoot.delete(recursive: true);
        }
      });

      final outbox = SyncOutboxStore(directoryProvider: () async => tempRoot);
      await outbox.enqueue(
        buildOp(
          id: 'failable',
          type: SyncOperationType.mediaUpload,
          payload: <String, dynamic>{
            'inspection_id': 'insp-1',
            'organization_id': 'org-1',
            'user_id': 'user-1',
            'requirement_key': 'photo:exteriorFront',
            'media_type': 'photo',
            'evidence_instance_id': 'photo:exteriorFront',
            'category': 'exteriorFront',
            'file_path': '/tmp/front.jpg',
          },
        ),
      );
      await outbox.enqueue(
        buildOp(
          id: 'exhausted',
          type: SyncOperationType.mediaUpload,
          payload: <String, dynamic>{
            'inspection_id': 'insp-1',
            'organization_id': 'org-1',
            'user_id': 'user-1',
            'requirement_key': 'photo:exteriorRear',
            'media_type': 'photo',
            'evidence_instance_id': 'photo:exteriorRear',
            'category': 'exteriorRear',
            'file_path': '/tmp/rear.jpg',
          },
          status: SyncOperationStatus.failed,
          retryCount: 3,
          maxRetries: 3,
        ),
      );

      final runner = SyncRunner(
        outboxStore: outbox,
        inspectionRemoteStore: _RecordingInspectionStore(),
        mediaRemoteStore: _AlwaysFailMediaRemoteStore(),
      );

      final result = await runner.runPending(
        activeTenantContext: const TenantContext(
          userId: 'user-1',
          organizationId: 'org-1',
        ),
      );
      expect(result.attempted, 1);
      expect(result.failed, 1);
      expect(result.skipped, 1);

      final operations = await outbox.listAll();
      final failed = operations.firstWhere(
        (op) => op.operationId == 'failable',
      );
      expect(failed.status, SyncOperationStatus.failed);
      expect(failed.retryCount, 1);
      expect(failed.lastError, contains('upload failed'));
    },
  );

  test(
    'runner skips operations for mismatched active tenant context',
    () async {
      final tempRoot = await Directory.systemTemp.createTemp(
        'inspectobot_sync_tenant_gate_',
      );
      addTearDown(() async {
        if (await tempRoot.exists()) {
          await tempRoot.delete(recursive: true);
        }
      });

      final outbox = SyncOutboxStore(directoryProvider: () async => tempRoot);
      await outbox.enqueue(
        SyncOperation(
          operationId: 'media-other-user',
          type: SyncOperationType.mediaUpload,
          aggregateId: 'insp-1',
          organizationId: 'org-1',
          userId: 'user-2',
          payload: <String, dynamic>{
            'inspection_id': 'insp-1',
            'organization_id': 'org-1',
            'user_id': 'user-2',
            'requirement_key': 'photo:exteriorFront',
            'media_type': 'photo',
            'evidence_instance_id': 'photo:exteriorFront',
            'category': 'exteriorFront',
            'file_path': '/tmp/front.jpg',
          },
          createdAt: DateTime.utc(2026, 3, 4, 18, 0, 0),
          updatedAt: DateTime.utc(2026, 3, 4, 18, 0, 0),
        ),
      );

      final inspectionStore = _RecordingInspectionStore();
      final mediaStore = _RecordingMediaRemoteStore();
      final runner = SyncRunner(
        outboxStore: outbox,
        inspectionRemoteStore: inspectionStore,
        mediaRemoteStore: mediaStore,
      );

      final result = await runner.runPending(
        activeTenantContext: const TenantContext(
          userId: 'user-1',
          organizationId: 'org-1',
        ),
      );

      expect(result.attempted, 0);
      expect(result.succeeded, 0);
      expect(result.failed, 0);
      expect(result.skipped, 1);
      expect(inspectionStore.events, isEmpty);
      expect(mediaStore.events, isEmpty);
    },
  );
}

class _RecordingInspectionStore implements InspectionStore {
  final List<String> events = <String>[];

  @override
  Future<Map<String, dynamic>> create(
    Map<String, dynamic> inspectionJson,
  ) async {
    events.add('inspection:create:${inspectionJson['id']}');
    return inspectionJson;
  }

  @override
  Future<Map<String, dynamic>?> fetchById({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    return null;
  }

  @override
  Future<Map<String, dynamic>?> fetchWizardProgress({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    return null;
  }

  @override
  Future<List<Map<String, dynamic>>> listInProgressInspections({
    required String organizationId,
    required String userId,
  }) async {
    return const <Map<String, dynamic>>[];
  }

  @override
  Future<Map<String, dynamic>?> fetchReportReadiness({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    return null;
  }

  @override
  Future<Map<String, dynamic>> updateWizardProgress({
    required String inspectionId,
    required String organizationId,
    required String userId,
    required int wizardLastStep,
    required Map<String, bool> wizardCompletion,
    required Map<String, dynamic> wizardBranchContext,
    required String wizardStatus,
  }) async {
    events.add('wizard:update:$inspectionId');
    return <String, dynamic>{
      'id': inspectionId,
      'organization_id': organizationId,
      'user_id': userId,
      'client_name': 'Jane Doe',
      'property_address': '123 Palm Ave',
      'forms_enabled': <String>['four_point'],
      'wizard_last_step': wizardLastStep,
      'wizard_completion': wizardCompletion,
      'wizard_branch_context': wizardBranchContext,
      'wizard_status': wizardStatus,
    };
  }

  @override
  Future<Map<String, dynamic>> upsertReportReadiness({
    required String inspectionId,
    required String organizationId,
    required String userId,
    required String status,
    required List<String> missingItems,
    required DateTime computedAt,
  }) async {
    events.add('readiness:upsert:$inspectionId');
    return <String, dynamic>{
      'inspection_id': inspectionId,
      'organization_id': organizationId,
      'user_id': userId,
      'status': status,
      'missing_items': missingItems,
      'computed_at': computedAt.toIso8601String(),
    };
  }
}

class _RecordingMediaRemoteStore extends MediaSyncRemoteStore {
  _RecordingMediaRemoteStore()
    : super(storage: _NoopStorageGateway(), metadata: _NoopMetadataGateway());

  final List<String> events = <String>[];

  @override
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
    events.add('media:upload:$mediaId');
  }
}

class _AlwaysFailMediaRemoteStore extends MediaSyncRemoteStore {
  _AlwaysFailMediaRemoteStore()
    : super(storage: _NoopStorageGateway(), metadata: _NoopMetadataGateway());

  @override
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
  }) {
    throw StateError('upload failed');
  }
}

class _NoopStorageGateway implements MediaStorageGateway {
  @override
  Future<void> upload({
    required String path,
    required Uint8List bytes,
    required String contentType,
  }) async {}
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
    required DateTime capturedAt,
  }) async {}
}
