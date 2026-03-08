import 'system_inspection_data.dart';

/// Typed data class for the General Home Inspection form (Rule 61-30.801).
///
/// Contains 2 narrative text fields, 9 system inspection data entries
/// (each with subsystems), and 4 branch flag booleans for conditional logic.
class GeneralInspectionFormData {
  const GeneralInspectionFormData({
    this.scopeAndPurpose = '',
    this.generalComments = '',
    required this.structural,
    required this.exterior,
    required this.roofing,
    required this.plumbing,
    required this.electrical,
    required this.hvac,
    required this.insulationVentilation,
    required this.appliances,
    required this.lifeSafety,
    this.safetyHazard = false,
    this.moistureMoldEvidence = false,
    this.pestEvidence = false,
    this.structuralConcern = false,
  });

  // Narrative fields (2)
  final String scopeAndPurpose;
  final String generalComments;

  // 9 system fields
  final SystemInspectionData structural;
  final SystemInspectionData exterior;
  final SystemInspectionData roofing;
  final SystemInspectionData plumbing;
  final SystemInspectionData electrical;
  final SystemInspectionData hvac;
  final SystemInspectionData insulationVentilation;
  final SystemInspectionData appliances;
  final SystemInspectionData lifeSafety;

  // Branch flags (4)
  final bool safetyHazard;
  final bool moistureMoldEvidence;
  final bool pestEvidence;
  final bool structuralConcern;

  // ---------------------------------------------------------------------------
  // empty factory
  // ---------------------------------------------------------------------------

  /// Creates an empty [GeneralInspectionFormData] with all defaults.
  factory GeneralInspectionFormData.empty() => GeneralInspectionFormData(
        structural: SystemInspectionData.structural(),
        exterior: SystemInspectionData.exterior(),
        roofing: SystemInspectionData.roofing(),
        plumbing: SystemInspectionData.plumbing(),
        electrical: SystemInspectionData.electrical(),
        hvac: SystemInspectionData.hvac(),
        insulationVentilation: SystemInspectionData.insulationVentilation(),
        appliances: SystemInspectionData.appliances(),
        lifeSafety: SystemInspectionData.lifeSafety(),
      );

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  GeneralInspectionFormData copyWith({
    String? scopeAndPurpose,
    String? generalComments,
    SystemInspectionData? structural,
    SystemInspectionData? exterior,
    SystemInspectionData? roofing,
    SystemInspectionData? plumbing,
    SystemInspectionData? electrical,
    SystemInspectionData? hvac,
    SystemInspectionData? insulationVentilation,
    SystemInspectionData? appliances,
    SystemInspectionData? lifeSafety,
    bool? safetyHazard,
    bool? moistureMoldEvidence,
    bool? pestEvidence,
    bool? structuralConcern,
  }) {
    return GeneralInspectionFormData(
      scopeAndPurpose: scopeAndPurpose ?? this.scopeAndPurpose,
      generalComments: generalComments ?? this.generalComments,
      structural: structural ?? this.structural,
      exterior: exterior ?? this.exterior,
      roofing: roofing ?? this.roofing,
      plumbing: plumbing ?? this.plumbing,
      electrical: electrical ?? this.electrical,
      hvac: hvac ?? this.hvac,
      insulationVentilation:
          insulationVentilation ?? this.insulationVentilation,
      appliances: appliances ?? this.appliances,
      lifeSafety: lifeSafety ?? this.lifeSafety,
      safetyHazard: safetyHazard ?? this.safetyHazard,
      moistureMoldEvidence: moistureMoldEvidence ?? this.moistureMoldEvidence,
      pestEvidence: pestEvidence ?? this.pestEvidence,
      structuralConcern: structuralConcern ?? this.structuralConcern,
    );
  }

  // ---------------------------------------------------------------------------
  // updateSystem
  // ---------------------------------------------------------------------------

  /// Returns a new instance with the system matching [systemId] replaced.
  GeneralInspectionFormData updateSystem(
    String systemId,
    SystemInspectionData system,
  ) {
    switch (systemId) {
      case 'structural':
        return copyWith(structural: system);
      case 'exterior':
        return copyWith(exterior: system);
      case 'roofing':
        return copyWith(roofing: system);
      case 'plumbing':
        return copyWith(plumbing: system);
      case 'electrical':
        return copyWith(electrical: system);
      case 'hvac':
        return copyWith(hvac: system);
      case 'insulation_ventilation':
        return copyWith(insulationVentilation: system);
      case 'appliances':
        return copyWith(appliances: system);
      case 'life_safety':
        return copyWith(lifeSafety: system);
      default:
        // Graceful degradation: unknown systemIds return unchanged instance.
        // This is tested and intentional — protects against data loss if a
        // systemId string is mismatched during refactoring.
        return this;
    }
  }

  // ---------------------------------------------------------------------------
  // toFormDataMap — bridge to narrative engine
  // ---------------------------------------------------------------------------

  /// Returns form data keyed to match
  /// [GeneralInspectionTemplate.referencedFormDataKeys].
  ///
  /// Produces exactly 72 keys: 2 narrative + 18 system-level (9 x rating/findings)
  /// + 52 subsystem-level entries (26 subsystems x 2 keys each).
  ///
  /// Branch flags (safetyHazard, moistureMoldEvidence, pestEvidence,
  /// structuralConcern) are intentionally excluded — they flow through
  /// `branchContext` in the narrative engine, not through `formData`.
  Map<String, String> toFormDataMap() {
    final map = <String, String>{
      'scope_and_purpose': scopeAndPurpose,
      'general_comments': generalComments,
    };

    _addSystemToMap(map, structural);
    _addSystemToMap(map, exterior);
    _addSystemToMap(map, roofing);
    _addSystemToMap(map, plumbing);
    _addSystemToMap(map, electrical);
    _addSystemToMap(map, hvac);
    _addSystemToMap(map, insulationVentilation);
    _addSystemToMap(map, appliances);
    _addSystemToMap(map, lifeSafety);

    return map;
  }

  static void _addSystemToMap(
    Map<String, String> map,
    SystemInspectionData system,
  ) {
    final sid = system.systemId;
    map['${sid}_rating'] = system.rating.name;
    map['${sid}_findings'] = system.findings;
    for (final sub in system.subsystems) {
      map['${sid}_${sub.id}_rating'] = sub.rating.name;
      map['${sid}_${sub.id}_findings'] = sub.findings;
    }
  }

  // ---------------------------------------------------------------------------
  // Serialization
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'scopeAndPurpose': scopeAndPurpose,
      'generalComments': generalComments,
      'structural': structural.toJson(),
      'exterior': exterior.toJson(),
      'roofing': roofing.toJson(),
      'plumbing': plumbing.toJson(),
      'electrical': electrical.toJson(),
      'hvac': hvac.toJson(),
      'insulationVentilation': insulationVentilation.toJson(),
      'appliances': appliances.toJson(),
      'lifeSafety': lifeSafety.toJson(),
      'safetyHazard': safetyHazard,
      'moistureMoldEvidence': moistureMoldEvidence,
      'pestEvidence': pestEvidence,
      'structuralConcern': structuralConcern,
    };
  }

  factory GeneralInspectionFormData.fromJson(Map<String, dynamic> json) {
    return GeneralInspectionFormData(
      scopeAndPurpose: json['scopeAndPurpose']?.toString() ?? '',
      generalComments: json['generalComments']?.toString() ?? '',
      structural: _systemFromJson(
        json['structural'],
        SystemInspectionData.structural,
      ),
      exterior: _systemFromJson(
        json['exterior'],
        SystemInspectionData.exterior,
      ),
      roofing: _systemFromJson(
        json['roofing'],
        SystemInspectionData.roofing,
      ),
      plumbing: _systemFromJson(
        json['plumbing'],
        SystemInspectionData.plumbing,
      ),
      electrical: _systemFromJson(
        json['electrical'],
        SystemInspectionData.electrical,
      ),
      hvac: _systemFromJson(
        json['hvac'],
        SystemInspectionData.hvac,
      ),
      insulationVentilation: _systemFromJson(
        json['insulationVentilation'],
        SystemInspectionData.insulationVentilation,
      ),
      appliances: _systemFromJson(
        json['appliances'],
        SystemInspectionData.appliances,
      ),
      lifeSafety: _systemFromJson(
        json['lifeSafety'],
        SystemInspectionData.lifeSafety,
      ),
      safetyHazard: json['safetyHazard'] == true,
      moistureMoldEvidence: json['moistureMoldEvidence'] == true,
      pestEvidence: json['pestEvidence'] == true,
      structuralConcern: json['structuralConcern'] == true,
    );
  }

  /// Resilient system deserialization — falls back to factory default when
  /// the stored value is null or not a valid map.
  static SystemInspectionData _systemFromJson(
    dynamic value,
    SystemInspectionData Function() fallback,
  ) {
    if (value is Map<String, dynamic>) {
      return SystemInspectionData.fromJson(value);
    }
    return fallback();
  }

  // ---------------------------------------------------------------------------
  // isEmpty
  // ---------------------------------------------------------------------------

  /// Returns true if all text fields are empty, all systems are empty, and
  /// all branch flags are false.
  bool get isEmpty =>
      scopeAndPurpose.isEmpty &&
      generalComments.isEmpty &&
      structural.isEmpty &&
      exterior.isEmpty &&
      roofing.isEmpty &&
      plumbing.isEmpty &&
      electrical.isEmpty &&
      hvac.isEmpty &&
      insulationVentilation.isEmpty &&
      appliances.isEmpty &&
      lifeSafety.isEmpty &&
      !safetyHazard &&
      !moistureMoldEvidence &&
      !pestEvidence &&
      !structuralConcern;

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeneralInspectionFormData &&
          runtimeType == other.runtimeType &&
          scopeAndPurpose == other.scopeAndPurpose &&
          generalComments == other.generalComments &&
          structural == other.structural &&
          exterior == other.exterior &&
          roofing == other.roofing &&
          plumbing == other.plumbing &&
          electrical == other.electrical &&
          hvac == other.hvac &&
          insulationVentilation == other.insulationVentilation &&
          appliances == other.appliances &&
          lifeSafety == other.lifeSafety &&
          safetyHazard == other.safetyHazard &&
          moistureMoldEvidence == other.moistureMoldEvidence &&
          pestEvidence == other.pestEvidence &&
          structuralConcern == other.structuralConcern;

  @override
  int get hashCode => Object.hashAll(<Object>[
        scopeAndPurpose,
        generalComments,
        structural,
        exterior,
        roofing,
        plumbing,
        electrical,
        hvac,
        insulationVentilation,
        appliances,
        lifeSafety,
        safetyHazard,
        moistureMoldEvidence,
        pestEvidence,
        structuralConcern,
      ]);
}
