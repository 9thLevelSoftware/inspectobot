import 'condition_rating.dart';

/// Data for a subsystem within a building system inspection.
class SubsystemData {
  const SubsystemData({
    required this.id,
    required this.name,
    this.rating = ConditionRating.notInspected,
    this.findings = '',
  });

  final String id;
  final String name;
  final ConditionRating rating;
  final String findings;

  /// Creates a copy with the given fields replaced.
  SubsystemData copyWith({
    String? id,
    String? name,
    ConditionRating? rating,
    String? findings,
  }) {
    return SubsystemData(
      id: id ?? this.id,
      name: name ?? this.name,
      rating: rating ?? this.rating,
      findings: findings ?? this.findings,
    );
  }

  /// Serializes this subsystem to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rating': rating.name,
      'findings': findings,
    };
  }

  /// Deserializes a [SubsystemData] from a JSON-compatible map.
  factory SubsystemData.fromJson(Map<String, dynamic> json) {
    return SubsystemData(
      id: json['id'] as String,
      name: json['name'] as String,
      rating: ConditionRating.parse(json['rating'] as String?),
      findings: json['findings'] as String? ?? '',
    );
  }

  /// Whether this subsystem has no meaningful data.
  bool get isEmpty =>
      rating == ConditionRating.notInspected && findings.isEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubsystemData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          rating == other.rating &&
          findings == other.findings;

  @override
  int get hashCode => Object.hashAll([id, name, rating, findings]);

  @override
  String toString() =>
      'SubsystemData(id: $id, name: $name, rating: $rating, findings: $findings)';
}

/// Data for a building system inspection (e.g., Structural, Electrical).
///
/// Each system may contain zero or more [SubsystemData] entries for
/// fine-grained component tracking per Rule 61-30.801.
class SystemInspectionData {
  const SystemInspectionData({
    required this.systemId,
    required this.systemName,
    this.rating = ConditionRating.notInspected,
    this.findings = '',
    this.subsystems = const [],
  });

  final String systemId;
  final String systemName;
  final ConditionRating rating;
  final String findings;
  final List<SubsystemData> subsystems;

  /// Creates a copy with the given fields replaced.
  SystemInspectionData copyWith({
    String? systemId,
    String? systemName,
    ConditionRating? rating,
    String? findings,
    List<SubsystemData>? subsystems,
  }) {
    return SystemInspectionData(
      systemId: systemId ?? this.systemId,
      systemName: systemName ?? this.systemName,
      rating: rating ?? this.rating,
      findings: findings ?? this.findings,
      subsystems: subsystems ?? this.subsystems,
    );
  }

  /// Serializes this system inspection to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'systemId': systemId,
      'systemName': systemName,
      'rating': rating.name,
      'findings': findings,
      'subsystems': subsystems.map((s) => s.toJson()).toList(),
    };
  }

  /// Deserializes a [SystemInspectionData] from a JSON-compatible map.
  factory SystemInspectionData.fromJson(Map<String, dynamic> json) {
    return SystemInspectionData(
      systemId: json['systemId'] as String,
      systemName: json['systemName'] as String,
      rating: ConditionRating.parse(json['rating'] as String?),
      findings: json['findings'] as String? ?? '',
      subsystems: (json['subsystems'] as List<dynamic>?)
              ?.map(
                (e) => SubsystemData.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );
  }

  /// Whether this system has no meaningful data.
  bool get isEmpty =>
      rating == ConditionRating.notInspected &&
      findings.isEmpty &&
      subsystems.every((s) => s.isEmpty);

  // ---------------------------------------------------------------------------
  // Factory constructors for all 9 General Inspection systems
  // ---------------------------------------------------------------------------

  /// Structural Components system with foundation, framing, and roof structure.
  factory SystemInspectionData.structural() {
    return const SystemInspectionData(
      systemId: 'structural',
      systemName: 'Structural Components',
      subsystems: [
        SubsystemData(id: 'foundation', name: 'Foundation'),
        SubsystemData(id: 'framing', name: 'Framing'),
        SubsystemData(id: 'roof_structure', name: 'Roof Structure'),
      ],
    );
  }

  /// Exterior system with siding, trim, porches, and driveways.
  factory SystemInspectionData.exterior() {
    return const SystemInspectionData(
      systemId: 'exterior',
      systemName: 'Exterior',
      subsystems: [
        SubsystemData(id: 'siding', name: 'Siding'),
        SubsystemData(id: 'trim', name: 'Trim'),
        SubsystemData(id: 'porches', name: 'Porches'),
        SubsystemData(id: 'driveways', name: 'Driveways'),
      ],
    );
  }

  /// Roofing system with covering, flashing, and drainage.
  factory SystemInspectionData.roofing() {
    return const SystemInspectionData(
      systemId: 'roofing',
      systemName: 'Roofing',
      subsystems: [
        SubsystemData(id: 'covering', name: 'Covering'),
        SubsystemData(id: 'flashing', name: 'Flashing'),
        SubsystemData(id: 'drainage', name: 'Drainage'),
      ],
    );
  }

  /// Plumbing system with supply, drain/waste, and water heater.
  factory SystemInspectionData.plumbing() {
    return const SystemInspectionData(
      systemId: 'plumbing',
      systemName: 'Plumbing',
      subsystems: [
        SubsystemData(id: 'supply', name: 'Supply'),
        SubsystemData(id: 'drain_waste', name: 'Drain/Waste'),
        SubsystemData(id: 'water_heater', name: 'Water Heater'),
      ],
    );
  }

  /// Electrical system with service, panels, branch circuits, and GFCI.
  factory SystemInspectionData.electrical() {
    return const SystemInspectionData(
      systemId: 'electrical',
      systemName: 'Electrical',
      subsystems: [
        SubsystemData(id: 'service', name: 'Service'),
        SubsystemData(id: 'panels', name: 'Panels'),
        SubsystemData(id: 'branch_circuits', name: 'Branch Circuits'),
        SubsystemData(id: 'gfci', name: 'GFCI'),
      ],
    );
  }

  /// HVAC system with heating, cooling, and distribution.
  factory SystemInspectionData.hvac() {
    return const SystemInspectionData(
      systemId: 'hvac',
      systemName: 'HVAC',
      subsystems: [
        SubsystemData(id: 'heating', name: 'Heating'),
        SubsystemData(id: 'cooling', name: 'Cooling'),
        SubsystemData(id: 'distribution', name: 'Distribution'),
      ],
    );
  }

  /// Insulation and Ventilation system with attic, wall, and crawlspace.
  factory SystemInspectionData.insulationVentilation() {
    return const SystemInspectionData(
      systemId: 'insulation_ventilation',
      systemName: 'Insulation and Ventilation',
      subsystems: [
        SubsystemData(id: 'attic', name: 'Attic'),
        SubsystemData(id: 'wall', name: 'Wall'),
        SubsystemData(id: 'crawlspace', name: 'Crawlspace'),
      ],
    );
  }

  /// Built-in Appliances system (no subsystems).
  factory SystemInspectionData.appliances() {
    return const SystemInspectionData(
      systemId: 'appliances',
      systemName: 'Built-in Appliances',
    );
  }

  /// Life Safety system with smoke detectors, CO detectors, and fire
  /// sprinklers.
  factory SystemInspectionData.lifeSafety() {
    return const SystemInspectionData(
      systemId: 'life_safety',
      systemName: 'Life Safety',
      subsystems: [
        SubsystemData(id: 'smoke_detectors', name: 'Smoke Detectors'),
        SubsystemData(id: 'co_detectors', name: 'CO Detectors'),
        SubsystemData(id: 'fire_sprinklers', name: 'Fire Sprinklers'),
      ],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemInspectionData &&
          runtimeType == other.runtimeType &&
          systemId == other.systemId &&
          systemName == other.systemName &&
          rating == other.rating &&
          findings == other.findings &&
          _listEquals(subsystems, other.subsystems);

  @override
  int get hashCode =>
      Object.hashAll([systemId, systemName, rating, findings, ...subsystems]);

  @override
  String toString() =>
      'SystemInspectionData(systemId: $systemId, systemName: $systemName, '
      'rating: $rating, findings: $findings, '
      'subsystems: $subsystems)';

  static bool _listEquals(List<SubsystemData> a, List<SubsystemData> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
