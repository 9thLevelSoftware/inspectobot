class AuditEvent {
  const AuditEvent({
    required this.id,
    required this.inspectionId,
    required this.organizationId,
    required this.userId,
    required this.eventType,
    required this.occurredAt,
    required this.payload,
    required this.createdAt,
  });

  final String id;
  final String inspectionId;
  final String organizationId;
  final String userId;
  final String eventType;
  final DateTime occurredAt;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'inspection_id': inspectionId,
      'organization_id': organizationId,
      'user_id': userId,
      'event_type': eventType,
      'occurred_at': occurredAt.toIso8601String(),
      'payload': payload,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory AuditEvent.fromJson(Map<String, dynamic> json) {
    return AuditEvent(
      id: json['id'] as String,
      inspectionId: json['inspection_id'] as String,
      organizationId: json['organization_id'] as String,
      userId: json['user_id'] as String,
      eventType: json['event_type'] as String,
      occurredAt: DateTime.parse(json['occurred_at'] as String).toUtc(),
      payload: Map<String, dynamic>.from(json['payload'] as Map? ?? const {}),
      createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
    );
  }
}

extension AuditEventPresentation on AuditEvent {
  String get timelineLabel {
    switch (eventType) {
      case 'inspection_progress_updated':
        return 'Inspection progress updated';
      case 'signature_persisted':
        return 'Inspector signature captured';
      case 'delivery_artifact_saved':
        return 'Report artifact saved';
      case 'delivery_download_started':
        return 'Download link generated';
      case 'delivery_share_started':
        return 'Secure share link generated';
      default:
        return 'Audit event: ${eventType.replaceAll('_', ' ')}';
    }
  }
}
