class ReportArtifact {
  const ReportArtifact({
    required this.id,
    required this.inspectionId,
    required this.organizationId,
    required this.userId,
    required this.storageBucket,
    required this.storagePath,
    required this.fileName,
    required this.contentType,
    required this.sizeBytes,
    required this.retainUntil,
    required this.createdAt,
    required this.updatedAt,
    this.payloadHash,
    this.signatureHash,
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final String inspectionId;
  final String organizationId;
  final String userId;
  final String storageBucket;
  final String storagePath;
  final String fileName;
  final String contentType;
  final int sizeBytes;
  final String? payloadHash;
  final String? signatureHash;
  final DateTime retainUntil;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'inspection_id': inspectionId,
      'organization_id': organizationId,
      'user_id': userId,
      'storage_bucket': storageBucket,
      'storage_path': storagePath,
      'file_name': fileName,
      'content_type': contentType,
      'size_bytes': sizeBytes,
      'payload_hash': payloadHash,
      'signature_hash': signatureHash,
      'retain_until': retainUntil.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory ReportArtifact.fromJson(Map<String, dynamic> json) {
    return ReportArtifact(
      id: json['id'] as String,
      inspectionId: json['inspection_id'] as String,
      organizationId: json['organization_id'] as String,
      userId: json['user_id'] as String,
      storageBucket: json['storage_bucket'] as String,
      storagePath: json['storage_path'] as String,
      fileName: json['file_name'] as String,
      contentType: json['content_type'] as String,
      sizeBytes: json['size_bytes'] as int,
      payloadHash: json['payload_hash'] as String?,
      signatureHash: json['signature_hash'] as String?,
      retainUntil: DateTime.parse(json['retain_until'] as String).toUtc(),
      createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
      updatedAt: DateTime.parse(json['updated_at'] as String).toUtc(),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? const {}),
    );
  }
}
