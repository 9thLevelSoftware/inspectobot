import 'package:uuid/uuid.dart';

enum SyncOperationType { inspectionUpsert, wizardProgressUpsert, mediaUpload }

enum SyncOperationStatus { pending, inFlight, failed, completed }

class SyncOperation {
  SyncOperation({
    required this.operationId,
    required this.type,
    required this.aggregateId,
    required this.organizationId,
    required this.userId,
    required this.payload,
    required this.createdAt,
    required this.updatedAt,
    this.status = SyncOperationStatus.pending,
    this.retryCount = 0,
    this.maxRetries = 3,
    this.lastError,
    this.lastAttemptAt,
    this.dependencyOperationId,
  });

  static const Uuid _uuid = Uuid();

  final String operationId;
  final SyncOperationType type;
  final String aggregateId;
  final String organizationId;
  final String userId;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SyncOperationStatus status;
  final int retryCount;
  final int maxRetries;
  final String? lastError;
  final DateTime? lastAttemptAt;
  final String? dependencyOperationId;

  static String newId() => _uuid.v4();

  SyncOperation copyWith({
    SyncOperationStatus? status,
    int? retryCount,
    String? lastError,
    DateTime? lastAttemptAt,
    DateTime? updatedAt,
    Map<String, dynamic>? payload,
  }) {
    return SyncOperation(
      operationId: operationId,
      type: type,
      aggregateId: aggregateId,
      organizationId: organizationId,
      userId: userId,
      payload: payload ?? this.payload,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now().toUtc(),
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries,
      lastError: lastError,
      lastAttemptAt: lastAttemptAt,
      dependencyOperationId: dependencyOperationId,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'operation_id': operationId,
      'type': _encodeType(type),
      'aggregate_id': aggregateId,
      'organization_id': organizationId,
      'user_id': userId,
      'payload': payload,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'status': _encodeStatus(status),
      'retry_count': retryCount,
      'max_retries': maxRetries,
      'last_error': lastError,
      'last_attempt_at': lastAttemptAt?.toIso8601String(),
      'dependency_operation_id': dependencyOperationId,
    };
  }

  static SyncOperation fromJson(Map<String, dynamic> json) {
    final operationId = _requireString(json, 'operation_id');
    final type = _parseType(_requireString(json, 'type'));
    final aggregateId = _requireString(json, 'aggregate_id');
    final organizationId = _requireString(json, 'organization_id');
    final userId = _requireString(json, 'user_id');
    final payloadRaw = json['payload'];
    if (payloadRaw is! Map) {
      throw const FormatException('payload must be an object');
    }
    final payload = Map<String, dynamic>.from(payloadRaw);
    final createdAt = _parseDate(_requireString(json, 'created_at'), 'created_at');
    final updatedAt = _parseDate(_requireString(json, 'updated_at'), 'updated_at');
    final status = _parseStatus(_requireString(json, 'status'));
    final retryCount = _parseInt(json, 'retry_count');
    final maxRetries = _parseInt(json, 'max_retries');
    if (retryCount < 0 || maxRetries < 0) {
      throw const FormatException('retry counters must be >= 0');
    }
    if (operationId.trim().isEmpty ||
        aggregateId.trim().isEmpty ||
        organizationId.trim().isEmpty ||
        userId.trim().isEmpty) {
      throw const FormatException('operation identity fields cannot be empty');
    }

    final dependencyIdRaw = json['dependency_operation_id'];
    final lastErrorRaw = json['last_error'];
    final lastAttemptAtRaw = json['last_attempt_at'];

    return SyncOperation(
      operationId: operationId,
      type: type,
      aggregateId: aggregateId,
      organizationId: organizationId,
      userId: userId,
      payload: payload,
      createdAt: createdAt,
      updatedAt: updatedAt,
      status: status,
      retryCount: retryCount,
      maxRetries: maxRetries,
      lastError: lastErrorRaw == null ? null : lastErrorRaw.toString(),
      lastAttemptAt: lastAttemptAtRaw == null
          ? null
          : _parseDate(lastAttemptAtRaw.toString(), 'last_attempt_at'),
      dependencyOperationId:
          dependencyIdRaw == null ? null : dependencyIdRaw.toString(),
    );
  }

  static String _requireString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) {
      throw FormatException('$key is required');
    }
    return value.toString();
  }

  static int _parseInt(Map<String, dynamic> json, String key) {
    final raw = json[key];
    if (raw is int) {
      return raw;
    }
    final value = int.tryParse(raw?.toString() ?? '');
    if (value == null) {
      throw FormatException('$key must be an int');
    }
    return value;
  }

  static DateTime _parseDate(String raw, String key) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      throw FormatException('$key must be an ISO-8601 date');
    }
    return parsed.toUtc();
  }
}

String _encodeType(SyncOperationType type) {
  switch (type) {
    case SyncOperationType.inspectionUpsert:
      return 'inspection_upsert';
    case SyncOperationType.wizardProgressUpsert:
      return 'wizard_progress_upsert';
    case SyncOperationType.mediaUpload:
      return 'media_upload';
  }
}

SyncOperationType _parseType(String value) {
  switch (value) {
    case 'inspection_upsert':
      return SyncOperationType.inspectionUpsert;
    case 'wizard_progress_upsert':
      return SyncOperationType.wizardProgressUpsert;
    case 'media_upload':
      return SyncOperationType.mediaUpload;
    default:
      throw FormatException('Unknown operation type: $value');
  }
}

String _encodeStatus(SyncOperationStatus status) {
  switch (status) {
    case SyncOperationStatus.pending:
      return 'pending';
    case SyncOperationStatus.inFlight:
      return 'in_flight';
    case SyncOperationStatus.failed:
      return 'failed';
    case SyncOperationStatus.completed:
      return 'completed';
  }
}

SyncOperationStatus _parseStatus(String value) {
  switch (value) {
    case 'pending':
      return SyncOperationStatus.pending;
    case 'in_flight':
      return SyncOperationStatus.inFlight;
    case 'failed':
      return SyncOperationStatus.failed;
    case 'completed':
      return SyncOperationStatus.completed;
    default:
      throw FormatException('Unknown operation status: $value');
  }
}
