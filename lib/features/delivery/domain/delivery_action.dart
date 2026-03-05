class DeliveryAction {
  const DeliveryAction({
    required this.id,
    required this.artifactId,
    required this.inspectionId,
    required this.organizationId,
    required this.userId,
    required this.actionType,
    required this.channel,
    required this.occurredAt,
    required this.payload,
    this.correlationId,
  });

  final String id;
  final String artifactId;
  final String inspectionId;
  final String organizationId;
  final String userId;
  final String actionType;
  final String channel;
  final String? correlationId;
  final DateTime occurredAt;
  final Map<String, dynamic> payload;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'artifact_id': artifactId,
      'inspection_id': inspectionId,
      'organization_id': organizationId,
      'user_id': userId,
      'action_type': actionType,
      'channel': channel,
      'correlation_id': correlationId,
      'payload': payload,
      'occurred_at': occurredAt.toIso8601String(),
      'created_at': occurredAt.toIso8601String(),
    };
  }

  factory DeliveryAction.fromJson(Map<String, dynamic> json) {
    return DeliveryAction(
      id: json['id'] as String,
      artifactId: json['artifact_id'] as String,
      inspectionId: json['inspection_id'] as String,
      organizationId: json['organization_id'] as String,
      userId: json['user_id'] as String,
      actionType: json['action_type'] as String,
      channel: json['channel'] as String,
      correlationId: json['correlation_id'] as String?,
      occurredAt: DateTime.parse(json['occurred_at'] as String).toUtc(),
      payload: Map<String, dynamic>.from(json['payload'] as Map? ?? const {}),
    );
  }
}
