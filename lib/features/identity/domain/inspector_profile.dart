class InspectorProfile {
  const InspectorProfile({
    required this.organizationId,
    required this.userId,
    required this.licenseType,
    required this.licenseNumber,
  });

  final String organizationId;
  final String userId;
  final String licenseType;
  final String licenseNumber;

  Map<String, dynamic> toJson() {
    return {
      'organization_id': organizationId,
      'user_id': userId,
      'license_type': licenseType,
      'license_number': licenseNumber,
    };
  }

  factory InspectorProfile.fromJson(Map<String, dynamic> json) {
    return InspectorProfile(
      organizationId: json['organization_id'] as String,
      userId: json['user_id'] as String,
      licenseType: (json['license_type'] as String?) ?? '',
      licenseNumber: (json['license_number'] as String?) ?? '',
    );
  }
}

class SignatureRecord {
  const SignatureRecord({
    required this.storagePath,
    required this.fileHash,
    required this.capturedAt,
  });

  final String storagePath;
  final String fileHash;
  final DateTime capturedAt;
}
