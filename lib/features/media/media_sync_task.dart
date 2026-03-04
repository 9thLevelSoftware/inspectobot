import '../inspection/domain/required_photo_category.dart';
import '../sync/sync_operation.dart';

enum MediaSyncStatus { pending, uploaded }
enum CapturedMediaType { photo, document }

class MediaSyncTask {
  const MediaSyncTask({
    required this.taskId,
    required this.inspectionId,
    required this.organizationId,
    required this.userId,
    required this.requirementKey,
    required this.mediaType,
    required this.evidenceInstanceId,
    required this.category,
    required this.filePath,
    required this.createdAt,
    this.retryCount = 0,
    this.lastError,
    this.status = MediaSyncStatus.pending,
  });

  final String taskId;
  final String inspectionId;
  final String organizationId;
  final String userId;
  final String requirementKey;
  final CapturedMediaType mediaType;
  final String evidenceInstanceId;
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
      'organizationId': organizationId,
      'userId': userId,
      'requirementKey': requirementKey,
      'mediaType': mediaType.name,
      'evidenceInstanceId': evidenceInstanceId,
      'category': category.name,
      'filePath': filePath,
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
      'lastError': lastError,
      'status': status.name,
    };
  }

  SyncOperation toSyncOperation({
    String? organizationId,
    String? userId,
  }) {
    final org = organizationId ?? this.organizationId;
    final user = userId ?? this.userId;
    return SyncOperation(
      operationId: taskId,
      type: SyncOperationType.mediaUpload,
      aggregateId: inspectionId,
      organizationId: org,
      userId: user,
      payload: <String, dynamic>{
        'inspection_id': inspectionId,
        'organization_id': org,
        'user_id': user,
        'requirement_key': requirementKey,
        'media_type': mediaType.name,
        'evidence_instance_id': evidenceInstanceId,
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
    final requirementKey = operation.payload['requirement_key']?.toString() ?? '';
    final mediaTypeRaw = operation.payload['media_type']?.toString() ?? CapturedMediaType.photo.name;
    final evidenceInstanceId = operation.payload['evidence_instance_id']?.toString() ?? operation.operationId;
    final filePath = operation.payload['file_path']?.toString();
    if (categoryRaw == null || filePath == null || filePath.trim().isEmpty || requirementKey.trim().isEmpty) {
      return null;
    }
    final category = RequiredPhotoCategory.values.where(
      (value) => value.name == categoryRaw,
    );
    if (category.isEmpty) {
      return null;
    }
    final mediaType = CapturedMediaType.values.where(
      (value) => value.name == mediaTypeRaw,
    );
    if (mediaType.isEmpty) {
      return null;
    }

    return MediaSyncTask(
      taskId: operation.operationId,
      inspectionId: operation.aggregateId,
      organizationId: operation.organizationId,
      userId: operation.userId,
      requirementKey: requirementKey,
      mediaType: mediaType.first,
      evidenceInstanceId: evidenceInstanceId,
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
    final requirementKey = json['requirementKey']?.toString() ?? '';
    final mediaTypeName = json['mediaType']?.toString() ?? CapturedMediaType.photo.name;
    final evidenceInstanceId = json['evidenceInstanceId']?.toString() ?? '';
    final statusName = json['status']?.toString() ?? MediaSyncStatus.pending.name;
    if (categoryName == null || requirementKey.trim().isEmpty) {
      return null;
    }

    final category = RequiredPhotoCategory.values.where(
      (c) => c.name == categoryName,
    );
    if (category.isEmpty) {
      return null;
    }

    final status = MediaSyncStatus.values.where((s) => s.name == statusName);
    final mediaType = CapturedMediaType.values.where((s) => s.name == mediaTypeName);

    final taskId = json['taskId']?.toString() ?? '';
    final inspectionId = json['inspectionId']?.toString() ?? '';
    final organizationId = json['organizationId']?.toString() ?? '';
    final userId = json['userId']?.toString() ?? '';
    final filePath = json['filePath']?.toString() ?? '';
    if (taskId.trim().isEmpty ||
        inspectionId.trim().isEmpty ||
        organizationId.trim().isEmpty ||
        userId.trim().isEmpty ||
        evidenceInstanceId.trim().isEmpty ||
        filePath.trim().isEmpty ||
        mediaType.isEmpty) {
      return null;
    }

    return MediaSyncTask(
      taskId: taskId,
      inspectionId: inspectionId,
      organizationId: organizationId,
      userId: userId,
      requirementKey: requirementKey,
      mediaType: mediaType.first,
      evidenceInstanceId: evidenceInstanceId,
      category: category.first,
      filePath: filePath,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      retryCount: int.tryParse(json['retryCount']?.toString() ?? '0') ?? 0,
      lastError: json['lastError']?.toString(),
      status: status.isEmpty ? MediaSyncStatus.pending : status.first,
    );
  }
}

