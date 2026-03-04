import 'dart:async';

import '../inspection/domain/required_photo_category.dart';
import '../inspection/data/inspection_repository.dart';
import '../media/media_sync_remote_store.dart';
import 'sync_operation.dart';
import 'sync_outbox_store.dart';

class SyncRunResult {
  const SyncRunResult({
    required this.attempted,
    required this.succeeded,
    required this.failed,
    required this.skipped,
  });

  final int attempted;
  final int succeeded;
  final int failed;
  final int skipped;
}

class SyncRunner {
  SyncRunner({
    required SyncOutboxStore outboxStore,
    required InspectionStore inspectionRemoteStore,
    required MediaSyncRemoteStore mediaRemoteStore,
  })  : _outboxStore = outboxStore,
        _inspectionRemoteStore = inspectionRemoteStore,
        _mediaRemoteStore = mediaRemoteStore;

  final SyncOutboxStore _outboxStore;
  final InspectionStore _inspectionRemoteStore;
  final MediaSyncRemoteStore _mediaRemoteStore;
  Completer<SyncRunResult>? _inFlightRun;

  Future<SyncRunResult> runPending() {
    final inFlight = _inFlightRun;
    if (inFlight != null) {
      return inFlight.future;
    }

    final completer = Completer<SyncRunResult>();
    _inFlightRun = completer;
    _drain().then(completer.complete).catchError(completer.completeError).whenComplete(
      () {
        _inFlightRun = null;
      },
    );
    return completer.future;
  }

  Future<SyncRunResult> _drain() async {
    final all = await _outboxStore.listAll();
    final runnable = all
        .where(_isRunnable)
        .toList(growable: true)
      ..sort(_operationComparator);

    var succeeded = 0;
    var failed = 0;
    var skipped = all.length - runnable.length;

    for (final operation in runnable) {
      try {
        await _outboxStore.markInFlight(operation.operationId);
        await _execute(operation);
        await _outboxStore.markCompleted(operation.operationId);
        succeeded += 1;
      } catch (error) {
        await _outboxStore.markFailed(
          operation.operationId,
          error: error.toString(),
        );
        failed += 1;
      }
    }

    return SyncRunResult(
      attempted: runnable.length,
      succeeded: succeeded,
      failed: failed,
      skipped: skipped,
    );
  }

  bool _isRunnable(SyncOperation operation) {
    if (operation.status == SyncOperationStatus.completed) {
      return false;
    }
    if (operation.status == SyncOperationStatus.failed &&
        operation.retryCount >= operation.maxRetries) {
      return false;
    }
    if (operation.dependencyOperationId == null) {
      return true;
    }
    return true;
  }

  Future<void> _execute(SyncOperation operation) async {
    switch (operation.type) {
      case SyncOperationType.inspectionUpsert:
        await _inspectionRemoteStore.create(operation.payload);
        return;
      case SyncOperationType.wizardProgressUpsert:
        await _inspectionRemoteStore.updateWizardProgress(
          inspectionId: operation.payload['inspection_id'].toString(),
          organizationId: operation.payload['organization_id'].toString(),
          userId: operation.payload['user_id'].toString(),
          wizardLastStep: int.parse(operation.payload['wizard_last_step'].toString()),
          wizardCompletion: Map<String, bool>.from(
            operation.payload['wizard_completion'] as Map,
          ),
          wizardBranchContext: Map<String, dynamic>.from(
            operation.payload['wizard_branch_context'] as Map,
          ),
          wizardStatus: operation.payload['wizard_status'].toString(),
        );
        return;
      case SyncOperationType.mediaUpload:
        final categoryName = operation.payload['category']?.toString() ?? '';
        final category = RequiredPhotoCategory.values.firstWhere(
          (value) => value.name == categoryName,
          orElse: () => throw StateError('Unknown media category: $categoryName'),
        );
        await _mediaRemoteStore.upload(
          mediaId: operation.operationId,
          inspectionId: operation.payload['inspection_id'].toString(),
          organizationId: operation.organizationId,
          userId: operation.userId,
          category: category,
          filePath: operation.payload['file_path'].toString(),
          capturedAt: operation.createdAt,
        );
        return;
    }
  }
}

int _operationComparator(SyncOperation a, SyncOperation b) {
  final typeOrderA = _typeOrder(a.type);
  final typeOrderB = _typeOrder(b.type);
  if (typeOrderA != typeOrderB) {
    return typeOrderA.compareTo(typeOrderB);
  }
  return a.createdAt.compareTo(b.createdAt);
}

int _typeOrder(SyncOperationType type) {
  switch (type) {
    case SyncOperationType.inspectionUpsert:
      return 0;
    case SyncOperationType.wizardProgressUpsert:
      return 1;
    case SyncOperationType.mediaUpload:
      return 2;
  }
}
