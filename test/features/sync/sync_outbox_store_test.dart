import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/sync/sync_operation.dart';
import 'package:inspectobot/features/sync/sync_outbox_store.dart';

void main() {
  SyncOperation buildOperation({
    required String operationId,
    required String aggregateId,
    String category = 'exteriorFront',
  }) {
    final now = DateTime.utc(2026, 3, 4, 18, 0, 0);
    return SyncOperation(
      operationId: operationId,
      type: SyncOperationType.mediaUpload,
      aggregateId: aggregateId,
      organizationId: 'org-1',
      userId: 'user-1',
      payload: <String, dynamic>{
        'inspection_id': aggregateId,
        'category': category,
        'file_path': '/tmp/$operationId.jpg',
      },
      createdAt: now,
      updatedAt: now,
    );
  }

  test('enqueue/list/status transitions persist with strict model', () async {
    final tempRoot = await Directory.systemTemp.createTemp('inspectobot_outbox_');
    addTearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    final store = SyncOutboxStore(directoryProvider: () async => tempRoot);
    final operation = buildOperation(operationId: 'op-1', aggregateId: 'insp-1');

    await store.enqueue(operation);
    await store.markInFlight('op-1');
    await store.markFailed('op-1', error: 'network timeout');

    final all = await store.listAll();
    expect(all, hasLength(1));
    expect(all.first.operationId, 'op-1');
    expect(all.first.status, SyncOperationStatus.failed);
    expect(all.first.retryCount, 1);
    expect(all.first.lastError, 'network timeout');

    await store.markCompleted('op-1');
    final completed = await store.listByStatus(SyncOperationStatus.completed);
    expect(completed, hasLength(1));
    expect(completed.first.operationId, 'op-1');
  });

  test('malformed records are parked and excluded from active outbox', () async {
    final tempRoot = await Directory.systemTemp.createTemp('inspectobot_outbox_bad_');
    addTearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    final queueDir = Directory('${tempRoot.path}/sync_queue');
    await queueDir.create(recursive: true);
    final now = DateTime.utc(2026, 3, 4, 18, 0, 0).toIso8601String();
    final payload = <dynamic>[
      <String, dynamic>{
        'operation_id': 'valid-1',
        'type': 'media_upload',
        'aggregate_id': 'insp-1',
        'organization_id': 'org-1',
        'user_id': 'user-1',
        'payload': <String, dynamic>{
          'inspection_id': 'insp-1',
          'category': 'exteriorFront',
          'file_path': '/tmp/front.jpg',
        },
        'created_at': now,
        'updated_at': now,
        'status': 'pending',
        'retry_count': 0,
        'max_retries': 3,
      },
      <String, dynamic>{
        'operation_id': '',
        'type': 'media_upload',
        'aggregate_id': 'insp-1',
        'organization_id': 'org-1',
        'user_id': 'user-1',
        'payload': <String, dynamic>{},
        'created_at': now,
        'updated_at': now,
        'status': 'pending',
        'retry_count': 0,
        'max_retries': 3,
      },
    ];
    final outboxFile = File('${queueDir.path}/sync_outbox.json');
    await outboxFile.writeAsString(jsonEncode(payload), flush: true);

    final store = SyncOutboxStore(directoryProvider: () async => tempRoot);
    final operations = await store.listAll();

    expect(operations, hasLength(1));
    expect(operations.first.operationId, 'valid-1');

    final corruptFile = File('${queueDir.path}/sync_outbox_corrupt.jsonl');
    expect(await corruptFile.exists(), isTrue);
    final corruptRaw = await corruptFile.readAsString();
    expect(corruptRaw, contains('operation identity fields cannot be empty'));
  });
}
