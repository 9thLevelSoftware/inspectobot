class ReportSignatureAttribution {
  const ReportSignatureAttribution({
    this.appVersion,
    this.device,
    this.sessionId,
    this.network,
  });

  final String? appVersion;
  final String? device;
  final String? sessionId;
  final String? network;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'app_version': appVersion,
      'device': device,
      'session_id': sessionId,
      'network': network,
    };
  }

  factory ReportSignatureAttribution.fromJson(Map<String, dynamic> json) {
    return ReportSignatureAttribution(
      appVersion: json['app_version'] as String?,
      device: json['device'] as String?,
      sessionId: json['session_id'] as String?,
      network: json['network'] as String?,
    );
  }
}

class ReportSignatureEvidence {
  const ReportSignatureEvidence({
    required this.id,
    required this.inspectionId,
    required this.organizationId,
    required this.userId,
    required this.signerRole,
    required this.signedAt,
    required this.signatureHash,
    required this.payloadHash,
    required this.attribution,
    required this.createdAt,
  });

  final String id;
  final String inspectionId;
  final String organizationId;
  final String userId;
  final String signerRole;
  final DateTime signedAt;
  final String signatureHash;
  final String payloadHash;
  final ReportSignatureAttribution attribution;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'inspection_id': inspectionId,
      'organization_id': organizationId,
      'user_id': userId,
      'signer_role': signerRole,
      'signed_at': signedAt.toIso8601String(),
      'signature_hash': signatureHash,
      'payload_hash': payloadHash,
      'attribution': attribution.toJson(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ReportSignatureEvidence.fromJson(Map<String, dynamic> json) {
    return ReportSignatureEvidence(
      id: json['id'] as String,
      inspectionId: json['inspection_id'] as String,
      organizationId: json['organization_id'] as String,
      userId: json['user_id'] as String,
      signerRole: json['signer_role'] as String,
      signedAt: DateTime.parse(json['signed_at'] as String).toUtc(),
      signatureHash: json['signature_hash'] as String,
      payloadHash: json['payload_hash'] as String,
      attribution: ReportSignatureAttribution.fromJson(
        Map<String, dynamic>.from(json['attribution'] as Map),
      ),
      createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
    );
  }
}
