/// Fields common to every inspection type: property address, inspector info,
/// client name, and inspection date.
class UniversalPropertyFields {
  const UniversalPropertyFields({
    required this.propertyAddress,
    required this.inspectionDate,
    required this.inspectorName,
    required this.inspectorCompany,
    required this.inspectorLicenseNumber,
    required this.clientName,
    this.inspectorSignaturePath,
    this.comments,
  });

  final String propertyAddress;
  final DateTime inspectionDate;
  final String inspectorName;
  final String inspectorCompany;
  final String inspectorLicenseNumber;
  final String clientName;
  final String? inspectorSignaturePath;
  final String? comments;

  // ---------------------------------------------------------------------------
  // JSON serialization
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'property_address': propertyAddress,
      'inspection_date': inspectionDate.toIso8601String(),
      'inspector_name': inspectorName,
      'inspector_company': inspectorCompany,
      'inspector_license_number': inspectorLicenseNumber,
      'client_name': clientName,
    };
    if (inspectorSignaturePath != null) {
      map['inspector_signature_path'] = inspectorSignaturePath;
    }
    if (comments != null) {
      map['comments'] = comments;
    }
    return map;
  }

  factory UniversalPropertyFields.fromJson(Map<String, dynamic> json) {
    return UniversalPropertyFields(
      propertyAddress: json['property_address'] as String,
      inspectionDate: DateTime.parse(json['inspection_date'] as String),
      inspectorName: json['inspector_name'] as String,
      inspectorCompany: json['inspector_company'] as String,
      inspectorLicenseNumber: json['inspector_license_number'] as String,
      clientName: json['client_name'] as String,
      inspectorSignaturePath: json['inspector_signature_path'] as String?,
      comments: json['comments'] as String?,
    );
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  UniversalPropertyFields copyWith({
    String? propertyAddress,
    DateTime? inspectionDate,
    String? inspectorName,
    String? inspectorCompany,
    String? inspectorLicenseNumber,
    String? clientName,
    String? Function()? inspectorSignaturePath,
    String? Function()? comments,
  }) {
    return UniversalPropertyFields(
      propertyAddress: propertyAddress ?? this.propertyAddress,
      inspectionDate: inspectionDate ?? this.inspectionDate,
      inspectorName: inspectorName ?? this.inspectorName,
      inspectorCompany: inspectorCompany ?? this.inspectorCompany,
      inspectorLicenseNumber:
          inspectorLicenseNumber ?? this.inspectorLicenseNumber,
      clientName: clientName ?? this.clientName,
      inspectorSignaturePath: inspectorSignaturePath != null
          ? inspectorSignaturePath()
          : this.inspectorSignaturePath,
      comments: comments != null ? comments() : this.comments,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UniversalPropertyFields &&
          runtimeType == other.runtimeType &&
          propertyAddress == other.propertyAddress &&
          inspectionDate == other.inspectionDate &&
          inspectorName == other.inspectorName &&
          inspectorCompany == other.inspectorCompany &&
          inspectorLicenseNumber == other.inspectorLicenseNumber &&
          clientName == other.clientName &&
          inspectorSignaturePath == other.inspectorSignaturePath &&
          comments == other.comments;

  @override
  int get hashCode => Object.hash(
        propertyAddress,
        inspectionDate,
        inspectorName,
        inspectorCompany,
        inspectorLicenseNumber,
        clientName,
        inspectorSignaturePath,
        comments,
      );
}
