import 'form_type.dart';

class InspectionSetup {
  InspectionSetup({
    required this.id,
    required this.organizationId,
    required this.userId,
    required this.clientName,
    required this.clientEmail,
    required this.clientPhone,
    required this.propertyAddress,
    required this.inspectionDate,
    required this.yearBuilt,
    required Set<FormType> enabledForms,
  }) : enabledForms = Set<FormType>.unmodifiable(enabledForms);

  final String id;
  final String organizationId;
  final String userId;
  final String clientName;
  final String clientEmail;
  final String clientPhone;
  final String propertyAddress;
  final DateTime inspectionDate;
  final int yearBuilt;
  final Set<FormType> enabledForms;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'user_id': userId,
      'client_name': clientName,
      'client_email': clientEmail,
      'client_phone': clientPhone,
      'property_address': propertyAddress,
      'inspection_date': inspectionDate.toIso8601String().split('T').first,
      'year_built': yearBuilt,
      'forms_enabled': enabledForms.map((form) => form.code).toList(growable: false),
    };
  }

  factory InspectionSetup.fromJson(Map<String, dynamic> json) {
    final formsEnabled = (json['forms_enabled'] as List<dynamic>).cast<String>();
    final inspectionDateRaw = json['inspection_date'] as String;
    return InspectionSetup(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      userId: json['user_id'] as String,
      clientName: json['client_name'] as String,
      clientEmail: json['client_email'] as String,
      clientPhone: json['client_phone'] as String,
      propertyAddress: json['property_address'] as String,
      inspectionDate: DateTime.parse(inspectionDateRaw).toUtc(),
      yearBuilt: json['year_built'] as int,
      enabledForms: FormType.fromCodes(formsEnabled),
    );
  }
}
