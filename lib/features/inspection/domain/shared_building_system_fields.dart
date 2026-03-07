import 'package:inspectobot/features/inspection/domain/rating_scale.dart';

/// Fields shared across multiple (but not all) inspection form types,
/// covering building systems like roof, electrical, plumbing, and HVAC.
class SharedBuildingSystemFields {
  const SharedBuildingSystemFields({
    this.yearBuilt,
    this.policyNumber,
    this.inspectorPhone,
    this.signatureDate,
    this.roofCoveringMaterial,
    this.roofAge,
    this.roofCondition,
    this.electricalPanelType,
    this.electricalPanelAmps,
    this.plumbingPipeMaterial,
    this.waterHeaterType,
    this.hvacType,
    this.foundationCracks,
  });

  final int? yearBuilt;
  final String? policyNumber;
  final String? inspectorPhone;
  final DateTime? signatureDate;
  final String? roofCoveringMaterial;
  final int? roofAge;
  final RatingScale? roofCondition;
  final String? electricalPanelType;
  final int? electricalPanelAmps;
  final String? plumbingPipeMaterial;
  final String? waterHeaterType;
  final String? hvacType;
  final bool? foundationCracks;

  // ---------------------------------------------------------------------------
  // JSON serialization
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (yearBuilt != null) map['year_built'] = yearBuilt;
    if (policyNumber != null) map['policy_number'] = policyNumber;
    if (inspectorPhone != null) map['inspector_phone'] = inspectorPhone;
    if (signatureDate != null) {
      map['signature_date'] = signatureDate!.toIso8601String();
    }
    if (roofCoveringMaterial != null) {
      map['roof_covering_material'] = roofCoveringMaterial;
    }
    if (roofAge != null) map['roof_age'] = roofAge;
    if (roofCondition != null) {
      map['roof_condition'] = roofCondition!.toJsonValue();
    }
    if (electricalPanelType != null) {
      map['electrical_panel_type'] = electricalPanelType;
    }
    if (electricalPanelAmps != null) {
      map['electrical_panel_amps'] = electricalPanelAmps;
    }
    if (plumbingPipeMaterial != null) {
      map['plumbing_pipe_material'] = plumbingPipeMaterial;
    }
    if (waterHeaterType != null) map['water_heater_type'] = waterHeaterType;
    if (hvacType != null) map['hvac_type'] = hvacType;
    if (foundationCracks != null) map['foundation_cracks'] = foundationCracks;
    return map;
  }

  factory SharedBuildingSystemFields.fromJson(Map<String, dynamic> json) {
    return SharedBuildingSystemFields(
      yearBuilt: json['year_built'] as int?,
      policyNumber: json['policy_number'] as String?,
      inspectorPhone: json['inspector_phone'] as String?,
      signatureDate: json['signature_date'] != null
          ? DateTime.parse(json['signature_date'] as String)
          : null,
      roofCoveringMaterial: json['roof_covering_material'] as String?,
      roofAge: json['roof_age'] as int?,
      roofCondition: RatingScale.fromJsonValue(json['roof_condition'] as String?),
      electricalPanelType: json['electrical_panel_type'] as String?,
      electricalPanelAmps: json['electrical_panel_amps'] as int?,
      plumbingPipeMaterial: json['plumbing_pipe_material'] as String?,
      waterHeaterType: json['water_heater_type'] as String?,
      hvacType: json['hvac_type'] as String?,
      foundationCracks: json['foundation_cracks'] as bool?,
    );
  }

  // ---------------------------------------------------------------------------
  // copyWith (closure-based for all nullable fields)
  // ---------------------------------------------------------------------------

  SharedBuildingSystemFields copyWith({
    int? Function()? yearBuilt,
    String? Function()? policyNumber,
    String? Function()? inspectorPhone,
    DateTime? Function()? signatureDate,
    String? Function()? roofCoveringMaterial,
    int? Function()? roofAge,
    RatingScale? Function()? roofCondition,
    String? Function()? electricalPanelType,
    int? Function()? electricalPanelAmps,
    String? Function()? plumbingPipeMaterial,
    String? Function()? waterHeaterType,
    String? Function()? hvacType,
    bool? Function()? foundationCracks,
  }) {
    return SharedBuildingSystemFields(
      yearBuilt: yearBuilt != null ? yearBuilt() : this.yearBuilt,
      policyNumber: policyNumber != null ? policyNumber() : this.policyNumber,
      inspectorPhone:
          inspectorPhone != null ? inspectorPhone() : this.inspectorPhone,
      signatureDate:
          signatureDate != null ? signatureDate() : this.signatureDate,
      roofCoveringMaterial: roofCoveringMaterial != null
          ? roofCoveringMaterial()
          : this.roofCoveringMaterial,
      roofAge: roofAge != null ? roofAge() : this.roofAge,
      roofCondition:
          roofCondition != null ? roofCondition() : this.roofCondition,
      electricalPanelType: electricalPanelType != null
          ? electricalPanelType()
          : this.electricalPanelType,
      electricalPanelAmps: electricalPanelAmps != null
          ? electricalPanelAmps()
          : this.electricalPanelAmps,
      plumbingPipeMaterial: plumbingPipeMaterial != null
          ? plumbingPipeMaterial()
          : this.plumbingPipeMaterial,
      waterHeaterType:
          waterHeaterType != null ? waterHeaterType() : this.waterHeaterType,
      hvacType: hvacType != null ? hvacType() : this.hvacType,
      foundationCracks:
          foundationCracks != null ? foundationCracks() : this.foundationCracks,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SharedBuildingSystemFields &&
          runtimeType == other.runtimeType &&
          yearBuilt == other.yearBuilt &&
          policyNumber == other.policyNumber &&
          inspectorPhone == other.inspectorPhone &&
          signatureDate == other.signatureDate &&
          roofCoveringMaterial == other.roofCoveringMaterial &&
          roofAge == other.roofAge &&
          roofCondition == other.roofCondition &&
          electricalPanelType == other.electricalPanelType &&
          electricalPanelAmps == other.electricalPanelAmps &&
          plumbingPipeMaterial == other.plumbingPipeMaterial &&
          waterHeaterType == other.waterHeaterType &&
          hvacType == other.hvacType &&
          foundationCracks == other.foundationCracks;

  @override
  int get hashCode => Object.hash(
        yearBuilt,
        policyNumber,
        inspectorPhone,
        signatureDate,
        roofCoveringMaterial,
        roofAge,
        roofCondition,
        electricalPanelType,
        electricalPanelAmps,
        plumbingPipeMaterial,
        waterHeaterType,
        hvacType,
        foundationCracks,
      );
}
