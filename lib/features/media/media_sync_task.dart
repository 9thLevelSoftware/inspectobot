import '../inspection/domain/required_photo_category.dart';
import '../sync/sync_operation.dart';

enum MediaSyncStatus { pending, uploaded }

class MediaSyncTask {
  const MediaSyncTask({
    required this.taskId,
    required this.inspectionId,
    required this.category,
    required this.filePath,
    required this.createdAt,
    this.retryCount = 0,
    this.lastError,
    this.status = MediaSyncStatus.pending,
  });

  final String taskId;
  final String inspectionId;
  final RequiredPhotoCategory category;
  final String filePath;
  final DateTime createdAt;
  final int retryCount;
  final String? lastError;
  final MediaSyncStatus status;

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'inspectionId': inspectionId,
      'category': category.name,
      'filePath': filePath,
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
      'lastError': lastError,
      'status': status.name,
    };
  }

  SyncOperation toSyncOperation({
    required String organizationId,
    required String userId,
  }) {
    return SyncOperation(
      operationId: taskId,
      type: SyncOperationType.mediaUpload,
      aggregateId: inspectionId,
      organizationId: organizationId,
      userId: userId,
      payload: <String, dynamic>{
        'inspection_id': inspectionId,
        'category': category.name,
        'file_path': filePath,
      },
      createdAt: createdAt,
      updatedAt: createdAt,
      status: switch (status) {
        MediaSyncStatus.pending => SyncOperationStatus.pending,
        MediaSyncStatus.uploaded => SyncOperationStatus.completed,
      },
      retryCount: retryCount,
      lastError: lastError,
    );
  }

  static MediaSyncTask? fromSyncOperation(SyncOperation operation) {
    if (operation.type != SyncOperationType.mediaUpload) {
      return null;
    }
    final categoryRaw = operation.payload['category']?.toString();
    final filePath = operation.payload['file_path']?.toString();
    if (categoryRaw == null || filePath == null || filePath.trim().isEmpty) {
      return null;
    }
    final category = RequiredPhotoCategory.values.where(
      (value) => value.name == categoryRaw,
    );
    if (category.isEmpty) {
      return null;
    }
    return MediaSyncTask(
      taskId: operation.operationId,
      inspectionId: operation.aggregateId,
      category: category.first,
      filePath: filePath,
      createdAt: operation.createdAt,
      retryCount: operation.retryCount,
      lastError: operation.lastError,
      status: switch (operation.status) {
        SyncOperationStatus.completed => MediaSyncStatus.uploaded,
        _ => MediaSyncStatus.pending,
      },
    );
  }

  static MediaSyncTask? fromJson(Map<String, dynamic> json) {
    final categoryName = json['category']?.toString();
    final statusName = json['status']?.toString() ?? MediaSyncStatus.pending.name;
    if (categoryName == null) {
      return null;
    }

    final category = RequiredPhotoCategory.values.where(
      (c) => c.name == categoryName,
    );
    if (category.isEmpty) {
      return null;
    }

    final status = MediaSyncStatus.values.where((s) => s.name == statusName);

    final taskId = json['taskId']?.toString() ?? '';
    final inspectionId = json['inspectionId']?.toString() ?? '';
    final filePath = json['filePath']?.toString() ?? '';
    if (taskId.trim().isEmpty || inspectionId.trim().isEmpty || filePath.trim().isEmpty) {
      return null;
    }

    return MediaSyncTask(
      taskId: taskId,
      inspectionId: inspectionId,
      category: category.first,
      filePath: filePath,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      retryCount: int.tryParse(json['retryCount']?.toString() ?? '0') ?? 0,
      lastError: json['lastError']?.toString(),
      status: status.isEmpty ? MediaSyncStatus.pending : status.first,
    );
  }
}

