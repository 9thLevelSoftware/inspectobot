import 'local_media_store.dart';
import 'media_sync_task.dart';
import '../sync/sync_operation.dart';
import '../sync/sync_outbox_store.dart';

class PendingMediaSyncStore {
  PendingMediaSyncStore({
    DirectoryProvider? directoryProvider,
    SyncOutboxStore? outboxStore,
  }) : _outboxStore = outboxStore ?? SyncOutboxStore(directoryProvider: directoryProvider);

  final SyncOutboxStore _outboxStore;

  Future<void> enqueue(MediaSyncTask task) async {
    final dependencyOperationId = await _resolveInspectionDependency(task);
    final operation = task.toSyncOperation(
      dependencyOperationId: dependencyOperationId,
    );
    await _outboxStore.enqueue(
      operation,
      replaceWhere: (existing) {
        if (existing.type != SyncOperationType.mediaUpload) {
          return false;
        }
        final requirementKey = existing.payload['requirement_key']?.toString();
        final mediaType = existing.payload['media_type']?.toString();
        final evidenceInstanceId = existing.payload['evidence_instance_id']?.toString();
        return existing.aggregateId == task.inspectionId &&
            requirementKey == task.requirementKey &&
            mediaType == task.mediaType.name &&
            evidenceInstanceId == task.evidenceInstanceId;
      },
    );
  }

  Future<String?> _resolveInspectionDependency(MediaSyncTask task) async {
    final operations = await _outboxStore.listAll();
    final inspectionOp = operations
        .where(
          (operation) =>
              operation.type == SyncOperationType.inspectionUpsert &&
              operation.aggregateId == task.inspectionId &&
              operation.organizationId == task.organizationId &&
              operation.userId == task.userId &&
              operation.status != SyncOperationStatus.completed,
        )
        .toList(growable: false);
    if (inspectionOp.isEmpty) {
      return null;
    }
    inspectionOp.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return inspectionOp.first.operationId;
  }

  Future<List<MediaSyncTask>> listPending() async {
    final operations = await _outboxStore.listByStatus(SyncOperationStatus.pending);
    return operations
        .map(MediaSyncTask.fromSyncOperation)
        .whereType<MediaSyncTask>()
        .where((task) => task.status == MediaSyncStatus.pending)
        .toList(growable: false);
  }

  Future<void> markUploaded(String taskId) async {
    await _outboxStore.markCompleted(taskId);
    await _outboxStore.remove(taskId);
  }
}
