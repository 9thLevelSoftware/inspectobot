import 'sinkhole_section_definitions.dart';
import 'universal_property_fields.dart';

/// Typed data class for the Sinkhole Inspection form (Citizens ver. 2, Ed.
/// 6/2012).
///
/// Contains ~67 text/tri-state fields across 7 sections. Branch flag booleans
/// (8 flags) are stored in branchContext, not here. Tri-state values ('Yes',
/// 'No', 'N/A', or null) live in [formValues] via this class.
class SinkholeFormData {
  const SinkholeFormData({
    // Section 0: Property ID (8 fields)
    this.insuredName,
    this.propertyAddress,
    this.policyNumber,
    this.inspectionDate,
    this.inspectorName,
    this.inspectorLicenseNumber,
    this.inspectorCompany,
    this.inspectorPhone,
    // Section 1: Exterior (10 fields: 5 tri-state + 5 detail)
    this.ext1Depression,
    this.ext1Detail,
    this.ext2AdjacentSinkholes,
    this.ext2Detail,
    this.ext3SoilErosion,
    this.ext3Detail,
    this.ext4FoundationCracks,
    this.ext4Detail,
    this.ext5ExteriorWallCracks,
    this.ext5Detail,
    // Section 2: Interior (16 fields: 8 tri-state + 8 detail)
    this.int1DoorsOutOfPlumb,
    this.int1Detail,
    this.int2DoorsWindowsOutOfSquare,
    this.int2Detail,
    this.int3CompressionCracks,
    this.int3Detail,
    this.int4FloorsOutOfLevel,
    this.int4Detail,
    this.int5CabinetsPulledFromWall,
    this.int5Detail,
    this.int6InteriorWallCracks,
    this.int6Detail,
    this.int7CeilingCracks,
    this.int7Detail,
    this.int8FlooringCracks,
    this.int8Detail,
    // Section 3: Garage (4 fields: 2 tri-state + 2 detail)
    this.gar1WallToSlabCracks,
    this.gar1Detail,
    this.gar2FloorCracksRadiate,
    this.gar2Detail,
    // Section 4: Appurtenant (8 fields: 4 tri-state + 4 detail)
    this.app1CracksNoted,
    this.app1Detail,
    this.app2UpliftNoted,
    this.app2Detail,
    this.app3PoolCracksDamage,
    this.app3Detail,
    this.app4PoolDeckCracks,
    this.app4Detail,
    // Section 5: Additional (5 fields)
    this.generalConditionOverview,
    this.adjacentBuildingDescription,
    this.distanceToNearestSinkhole,
    this.otherRelevantFindings,
    this.unableToScheduleExplanation,
    // Section 6: Scheduling (16 fields: 4 attempts x 4)
    this.attempt1Date,
    this.attempt1Time,
    this.attempt1NumberCalled,
    this.attempt1Result,
    this.attempt2Date,
    this.attempt2Time,
    this.attempt2NumberCalled,
    this.attempt2Result,
    this.attempt3Date,
    this.attempt3Time,
    this.attempt3NumberCalled,
    this.attempt3Result,
    this.attempt4Date,
    this.attempt4Time,
    this.attempt4NumberCalled,
    this.attempt4Result,
  });

  // Section 0: Property ID
  final String? insuredName;
  final String? propertyAddress;
  final String? policyNumber;
  final String? inspectionDate;
  final String? inspectorName;
  final String? inspectorLicenseNumber;
  final String? inspectorCompany;
  final String? inspectorPhone;

  // Section 1: Exterior (tri-state + detail pairs)
  final String? ext1Depression;
  final String? ext1Detail;
  final String? ext2AdjacentSinkholes;
  final String? ext2Detail;
  final String? ext3SoilErosion;
  final String? ext3Detail;
  final String? ext4FoundationCracks;
  final String? ext4Detail;
  final String? ext5ExteriorWallCracks;
  final String? ext5Detail;

  // Section 2: Interior (tri-state + detail pairs)
  final String? int1DoorsOutOfPlumb;
  final String? int1Detail;
  final String? int2DoorsWindowsOutOfSquare;
  final String? int2Detail;
  final String? int3CompressionCracks;
  final String? int3Detail;
  final String? int4FloorsOutOfLevel;
  final String? int4Detail;
  final String? int5CabinetsPulledFromWall;
  final String? int5Detail;
  final String? int6InteriorWallCracks;
  final String? int6Detail;
  final String? int7CeilingCracks;
  final String? int7Detail;
  final String? int8FlooringCracks;
  final String? int8Detail;

  // Section 3: Garage (tri-state + detail pairs)
  final String? gar1WallToSlabCracks;
  final String? gar1Detail;
  final String? gar2FloorCracksRadiate;
  final String? gar2Detail;

  // Section 4: Appurtenant (tri-state + detail pairs)
  final String? app1CracksNoted;
  final String? app1Detail;
  final String? app2UpliftNoted;
  final String? app2Detail;
  final String? app3PoolCracksDamage;
  final String? app3Detail;
  final String? app4PoolDeckCracks;
  final String? app4Detail;

  // Section 5: Additional Info
  final String? generalConditionOverview;
  final String? adjacentBuildingDescription;
  final String? distanceToNearestSinkhole;
  final String? otherRelevantFindings;
  final String? unableToScheduleExplanation;

  // Section 6: Scheduling (4 attempts x 4 fields)
  final String? attempt1Date;
  final String? attempt1Time;
  final String? attempt1NumberCalled;
  final String? attempt1Result;
  final String? attempt2Date;
  final String? attempt2Time;
  final String? attempt2NumberCalled;
  final String? attempt2Result;
  final String? attempt3Date;
  final String? attempt3Time;
  final String? attempt3NumberCalled;
  final String? attempt3Result;
  final String? attempt4Date;
  final String? attempt4Time;
  final String? attempt4NumberCalled;
  final String? attempt4Result;

  // ---------------------------------------------------------------------------
  // All field keys (used for serialization)
  // ---------------------------------------------------------------------------

  static const List<String> fieldKeys = <String>[
    // Section 0: Property ID
    'insuredName',
    'propertyAddress',
    'policyNumber',
    'inspectionDate',
    'inspectorName',
    'inspectorLicenseNumber',
    'inspectorCompany',
    'inspectorPhone',
    // Section 1: Exterior
    'ext1Depression',
    'ext1Detail',
    'ext2AdjacentSinkholes',
    'ext2Detail',
    'ext3SoilErosion',
    'ext3Detail',
    'ext4FoundationCracks',
    'ext4Detail',
    'ext5ExteriorWallCracks',
    'ext5Detail',
    // Section 2: Interior
    'int1DoorsOutOfPlumb',
    'int1Detail',
    'int2DoorsWindowsOutOfSquare',
    'int2Detail',
    'int3CompressionCracks',
    'int3Detail',
    'int4FloorsOutOfLevel',
    'int4Detail',
    'int5CabinetsPulledFromWall',
    'int5Detail',
    'int6InteriorWallCracks',
    'int6Detail',
    'int7CeilingCracks',
    'int7Detail',
    'int8FlooringCracks',
    'int8Detail',
    // Section 3: Garage
    'gar1WallToSlabCracks',
    'gar1Detail',
    'gar2FloorCracksRadiate',
    'gar2Detail',
    // Section 4: Appurtenant
    'app1CracksNoted',
    'app1Detail',
    'app2UpliftNoted',
    'app2Detail',
    'app3PoolCracksDamage',
    'app3Detail',
    'app4PoolDeckCracks',
    'app4Detail',
    // Section 5: Additional
    'generalConditionOverview',
    'adjacentBuildingDescription',
    'distanceToNearestSinkhole',
    'otherRelevantFindings',
    'unableToScheduleExplanation',
    // Section 6: Scheduling
    'attempt1Date',
    'attempt1Time',
    'attempt1NumberCalled',
    'attempt1Result',
    'attempt2Date',
    'attempt2Time',
    'attempt2NumberCalled',
    'attempt2Result',
    'attempt3Date',
    'attempt3Time',
    'attempt3NumberCalled',
    'attempt3Result',
    'attempt4Date',
    'attempt4Time',
    'attempt4NumberCalled',
    'attempt4Result',
  ];

  // ---------------------------------------------------------------------------
  // Serialization
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'insuredName': insuredName,
      'propertyAddress': propertyAddress,
      'policyNumber': policyNumber,
      'inspectionDate': inspectionDate,
      'inspectorName': inspectorName,
      'inspectorLicenseNumber': inspectorLicenseNumber,
      'inspectorCompany': inspectorCompany,
      'inspectorPhone': inspectorPhone,
      'ext1Depression': ext1Depression,
      'ext1Detail': ext1Detail,
      'ext2AdjacentSinkholes': ext2AdjacentSinkholes,
      'ext2Detail': ext2Detail,
      'ext3SoilErosion': ext3SoilErosion,
      'ext3Detail': ext3Detail,
      'ext4FoundationCracks': ext4FoundationCracks,
      'ext4Detail': ext4Detail,
      'ext5ExteriorWallCracks': ext5ExteriorWallCracks,
      'ext5Detail': ext5Detail,
      'int1DoorsOutOfPlumb': int1DoorsOutOfPlumb,
      'int1Detail': int1Detail,
      'int2DoorsWindowsOutOfSquare': int2DoorsWindowsOutOfSquare,
      'int2Detail': int2Detail,
      'int3CompressionCracks': int3CompressionCracks,
      'int3Detail': int3Detail,
      'int4FloorsOutOfLevel': int4FloorsOutOfLevel,
      'int4Detail': int4Detail,
      'int5CabinetsPulledFromWall': int5CabinetsPulledFromWall,
      'int5Detail': int5Detail,
      'int6InteriorWallCracks': int6InteriorWallCracks,
      'int6Detail': int6Detail,
      'int7CeilingCracks': int7CeilingCracks,
      'int7Detail': int7Detail,
      'int8FlooringCracks': int8FlooringCracks,
      'int8Detail': int8Detail,
      'gar1WallToSlabCracks': gar1WallToSlabCracks,
      'gar1Detail': gar1Detail,
      'gar2FloorCracksRadiate': gar2FloorCracksRadiate,
      'gar2Detail': gar2Detail,
      'app1CracksNoted': app1CracksNoted,
      'app1Detail': app1Detail,
      'app2UpliftNoted': app2UpliftNoted,
      'app2Detail': app2Detail,
      'app3PoolCracksDamage': app3PoolCracksDamage,
      'app3Detail': app3Detail,
      'app4PoolDeckCracks': app4PoolDeckCracks,
      'app4Detail': app4Detail,
      'generalConditionOverview': generalConditionOverview,
      'adjacentBuildingDescription': adjacentBuildingDescription,
      'distanceToNearestSinkhole': distanceToNearestSinkhole,
      'otherRelevantFindings': otherRelevantFindings,
      'unableToScheduleExplanation': unableToScheduleExplanation,
      'attempt1Date': attempt1Date,
      'attempt1Time': attempt1Time,
      'attempt1NumberCalled': attempt1NumberCalled,
      'attempt1Result': attempt1Result,
      'attempt2Date': attempt2Date,
      'attempt2Time': attempt2Time,
      'attempt2NumberCalled': attempt2NumberCalled,
      'attempt2Result': attempt2Result,
      'attempt3Date': attempt3Date,
      'attempt3Time': attempt3Time,
      'attempt3NumberCalled': attempt3NumberCalled,
      'attempt3Result': attempt3Result,
      'attempt4Date': attempt4Date,
      'attempt4Time': attempt4Time,
      'attempt4NumberCalled': attempt4NumberCalled,
      'attempt4Result': attempt4Result,
    };
  }

  factory SinkholeFormData.fromJson(Map<String, dynamic> json) {
    return SinkholeFormData(
      insuredName: json['insuredName'] as String?,
      propertyAddress: json['propertyAddress'] as String?,
      policyNumber: json['policyNumber'] as String?,
      inspectionDate: json['inspectionDate'] as String?,
      inspectorName: json['inspectorName'] as String?,
      inspectorLicenseNumber: json['inspectorLicenseNumber'] as String?,
      inspectorCompany: json['inspectorCompany'] as String?,
      inspectorPhone: json['inspectorPhone'] as String?,
      ext1Depression: json['ext1Depression'] as String?,
      ext1Detail: json['ext1Detail'] as String?,
      ext2AdjacentSinkholes: json['ext2AdjacentSinkholes'] as String?,
      ext2Detail: json['ext2Detail'] as String?,
      ext3SoilErosion: json['ext3SoilErosion'] as String?,
      ext3Detail: json['ext3Detail'] as String?,
      ext4FoundationCracks: json['ext4FoundationCracks'] as String?,
      ext4Detail: json['ext4Detail'] as String?,
      ext5ExteriorWallCracks: json['ext5ExteriorWallCracks'] as String?,
      ext5Detail: json['ext5Detail'] as String?,
      int1DoorsOutOfPlumb: json['int1DoorsOutOfPlumb'] as String?,
      int1Detail: json['int1Detail'] as String?,
      int2DoorsWindowsOutOfSquare:
          json['int2DoorsWindowsOutOfSquare'] as String?,
      int2Detail: json['int2Detail'] as String?,
      int3CompressionCracks: json['int3CompressionCracks'] as String?,
      int3Detail: json['int3Detail'] as String?,
      int4FloorsOutOfLevel: json['int4FloorsOutOfLevel'] as String?,
      int4Detail: json['int4Detail'] as String?,
      int5CabinetsPulledFromWall:
          json['int5CabinetsPulledFromWall'] as String?,
      int5Detail: json['int5Detail'] as String?,
      int6InteriorWallCracks: json['int6InteriorWallCracks'] as String?,
      int6Detail: json['int6Detail'] as String?,
      int7CeilingCracks: json['int7CeilingCracks'] as String?,
      int7Detail: json['int7Detail'] as String?,
      int8FlooringCracks: json['int8FlooringCracks'] as String?,
      int8Detail: json['int8Detail'] as String?,
      gar1WallToSlabCracks: json['gar1WallToSlabCracks'] as String?,
      gar1Detail: json['gar1Detail'] as String?,
      gar2FloorCracksRadiate: json['gar2FloorCracksRadiate'] as String?,
      gar2Detail: json['gar2Detail'] as String?,
      app1CracksNoted: json['app1CracksNoted'] as String?,
      app1Detail: json['app1Detail'] as String?,
      app2UpliftNoted: json['app2UpliftNoted'] as String?,
      app2Detail: json['app2Detail'] as String?,
      app3PoolCracksDamage: json['app3PoolCracksDamage'] as String?,
      app3Detail: json['app3Detail'] as String?,
      app4PoolDeckCracks: json['app4PoolDeckCracks'] as String?,
      app4Detail: json['app4Detail'] as String?,
      generalConditionOverview: json['generalConditionOverview'] as String?,
      adjacentBuildingDescription:
          json['adjacentBuildingDescription'] as String?,
      distanceToNearestSinkhole:
          json['distanceToNearestSinkhole'] as String?,
      otherRelevantFindings: json['otherRelevantFindings'] as String?,
      unableToScheduleExplanation:
          json['unableToScheduleExplanation'] as String?,
      attempt1Date: json['attempt1Date'] as String?,
      attempt1Time: json['attempt1Time'] as String?,
      attempt1NumberCalled: json['attempt1NumberCalled'] as String?,
      attempt1Result: json['attempt1Result'] as String?,
      attempt2Date: json['attempt2Date'] as String?,
      attempt2Time: json['attempt2Time'] as String?,
      attempt2NumberCalled: json['attempt2NumberCalled'] as String?,
      attempt2Result: json['attempt2Result'] as String?,
      attempt3Date: json['attempt3Date'] as String?,
      attempt3Time: json['attempt3Time'] as String?,
      attempt3NumberCalled: json['attempt3NumberCalled'] as String?,
      attempt3Result: json['attempt3Result'] as String?,
      attempt4Date: json['attempt4Date'] as String?,
      attempt4Time: json['attempt4Time'] as String?,
      attempt4NumberCalled: json['attempt4NumberCalled'] as String?,
      attempt4Result: json['attempt4Result'] as String?,
    );
  }

  // ---------------------------------------------------------------------------
  // toPdfMaps
  // ---------------------------------------------------------------------------

  /// Separates text fields into [fieldValues] and tri-state / branch flag
  /// booleans into [checkboxValues] for PDF generation.
  ///
  /// Tri-state fields map to 3 checkboxes each: `{key}__yes`, `{key}__no`,
  /// `{key}__na` (double underscore to match the PDF field map convention).
  ({Map<String, String> fieldValues, Map<String, bool> checkboxValues})
      toPdfMaps() {
    final fieldValues = <String, String>{};
    final checkboxValues = <String, bool>{};

    final json = toJson();
    for (final entry in json.entries) {
      if (entry.value == null) continue;
      if (entry.value is! String) continue;
      final value = entry.value as String;

      // Tri-state fields: expand to 3 checkboxes
      if (_triStateKeys.contains(entry.key)) {
        checkboxValues['${entry.key}__yes'] = value == 'Yes';
        checkboxValues['${entry.key}__no'] = value == 'No';
        checkboxValues['${entry.key}__na'] = value == 'N/A';
      } else {
        fieldValues[entry.key] = value;
      }
    }

    return (fieldValues: fieldValues, checkboxValues: checkboxValues);
  }

  /// Derived from [SinkholeSectionDefinitions]: the set of all tri-state
  /// trigger field keys across every section's [FieldGroup]s.
  static final Set<String> _triStateKeys = SinkholeSectionDefinitions.all
      .expand((s) => s.fieldGroups)
      .map((g) => g.triggerField.key)
      .toSet();

  // ---------------------------------------------------------------------------
  // remapSchedulingKeys
  // ---------------------------------------------------------------------------

  /// Remaps RepeatingFieldGroup scheduling keys from the generated pattern
  /// (`attempt_N_Key`) to SinkholeFormData's camelCase pattern (`attemptNKey`).
  ///
  /// Non-scheduling keys pass through unchanged.
  static Map<String, dynamic> remapSchedulingKeys(
    Map<String, dynamic> rawData,
  ) {
    final result = <String, dynamic>{};
    final schedulingPattern = RegExp(r'^attempt_(\d+)_(\w+)$');
    for (final entry in rawData.entries) {
      final match = schedulingPattern.firstMatch(entry.key);
      if (match != null) {
        final index = match.group(1)!;
        final fieldPart = match.group(2)!;
        // Template keys already start with uppercase (Date, Time, etc.)
        // which concatenates naturally: attempt + 1 + Date = attempt1Date.
        result['attempt$index$fieldPart'] = entry.value;
      } else {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  // toFormDataMap
  // ---------------------------------------------------------------------------

  /// Returns this data in the format expected by
  /// `PropertyData.formData[FormType.sinkholeInspection]`.
  Map<String, dynamic> toFormDataMap() => toJson();

  // ---------------------------------------------------------------------------
  // withDefaults factory
  // ---------------------------------------------------------------------------

  /// Creates a [SinkholeFormData] pre-filled from [universal] fields.
  factory SinkholeFormData.withDefaults({
    UniversalPropertyFields? universal,
  }) {
    return SinkholeFormData(
      insuredName: universal?.clientName,
      propertyAddress: universal?.propertyAddress,
      inspectionDate:
          universal?.inspectionDate.toIso8601String().split('T').first,
      inspectorName: universal?.inspectorName,
      inspectorLicenseNumber: universal?.inspectorLicenseNumber,
      inspectorCompany: universal?.inspectorCompany,
    );
  }

  // ---------------------------------------------------------------------------
  // copyWith (closure-based for nullable String? fields)
  // ---------------------------------------------------------------------------

  SinkholeFormData copyWith({
    // Section 0
    String? Function()? insuredName,
    String? Function()? propertyAddress,
    String? Function()? policyNumber,
    String? Function()? inspectionDate,
    String? Function()? inspectorName,
    String? Function()? inspectorLicenseNumber,
    String? Function()? inspectorCompany,
    String? Function()? inspectorPhone,
    // Section 1
    String? Function()? ext1Depression,
    String? Function()? ext1Detail,
    String? Function()? ext2AdjacentSinkholes,
    String? Function()? ext2Detail,
    String? Function()? ext3SoilErosion,
    String? Function()? ext3Detail,
    String? Function()? ext4FoundationCracks,
    String? Function()? ext4Detail,
    String? Function()? ext5ExteriorWallCracks,
    String? Function()? ext5Detail,
    // Section 2
    String? Function()? int1DoorsOutOfPlumb,
    String? Function()? int1Detail,
    String? Function()? int2DoorsWindowsOutOfSquare,
    String? Function()? int2Detail,
    String? Function()? int3CompressionCracks,
    String? Function()? int3Detail,
    String? Function()? int4FloorsOutOfLevel,
    String? Function()? int4Detail,
    String? Function()? int5CabinetsPulledFromWall,
    String? Function()? int5Detail,
    String? Function()? int6InteriorWallCracks,
    String? Function()? int6Detail,
    String? Function()? int7CeilingCracks,
    String? Function()? int7Detail,
    String? Function()? int8FlooringCracks,
    String? Function()? int8Detail,
    // Section 3
    String? Function()? gar1WallToSlabCracks,
    String? Function()? gar1Detail,
    String? Function()? gar2FloorCracksRadiate,
    String? Function()? gar2Detail,
    // Section 4
    String? Function()? app1CracksNoted,
    String? Function()? app1Detail,
    String? Function()? app2UpliftNoted,
    String? Function()? app2Detail,
    String? Function()? app3PoolCracksDamage,
    String? Function()? app3Detail,
    String? Function()? app4PoolDeckCracks,
    String? Function()? app4Detail,
    // Section 5
    String? Function()? generalConditionOverview,
    String? Function()? adjacentBuildingDescription,
    String? Function()? distanceToNearestSinkhole,
    String? Function()? otherRelevantFindings,
    String? Function()? unableToScheduleExplanation,
    // Section 6
    String? Function()? attempt1Date,
    String? Function()? attempt1Time,
    String? Function()? attempt1NumberCalled,
    String? Function()? attempt1Result,
    String? Function()? attempt2Date,
    String? Function()? attempt2Time,
    String? Function()? attempt2NumberCalled,
    String? Function()? attempt2Result,
    String? Function()? attempt3Date,
    String? Function()? attempt3Time,
    String? Function()? attempt3NumberCalled,
    String? Function()? attempt3Result,
    String? Function()? attempt4Date,
    String? Function()? attempt4Time,
    String? Function()? attempt4NumberCalled,
    String? Function()? attempt4Result,
  }) {
    return SinkholeFormData(
      insuredName: insuredName != null ? insuredName() : this.insuredName,
      propertyAddress:
          propertyAddress != null ? propertyAddress() : this.propertyAddress,
      policyNumber:
          policyNumber != null ? policyNumber() : this.policyNumber,
      inspectionDate:
          inspectionDate != null ? inspectionDate() : this.inspectionDate,
      inspectorName:
          inspectorName != null ? inspectorName() : this.inspectorName,
      inspectorLicenseNumber: inspectorLicenseNumber != null
          ? inspectorLicenseNumber()
          : this.inspectorLicenseNumber,
      inspectorCompany:
          inspectorCompany != null ? inspectorCompany() : this.inspectorCompany,
      inspectorPhone:
          inspectorPhone != null ? inspectorPhone() : this.inspectorPhone,
      ext1Depression:
          ext1Depression != null ? ext1Depression() : this.ext1Depression,
      ext1Detail: ext1Detail != null ? ext1Detail() : this.ext1Detail,
      ext2AdjacentSinkholes: ext2AdjacentSinkholes != null
          ? ext2AdjacentSinkholes()
          : this.ext2AdjacentSinkholes,
      ext2Detail: ext2Detail != null ? ext2Detail() : this.ext2Detail,
      ext3SoilErosion:
          ext3SoilErosion != null ? ext3SoilErosion() : this.ext3SoilErosion,
      ext3Detail: ext3Detail != null ? ext3Detail() : this.ext3Detail,
      ext4FoundationCracks: ext4FoundationCracks != null
          ? ext4FoundationCracks()
          : this.ext4FoundationCracks,
      ext4Detail: ext4Detail != null ? ext4Detail() : this.ext4Detail,
      ext5ExteriorWallCracks: ext5ExteriorWallCracks != null
          ? ext5ExteriorWallCracks()
          : this.ext5ExteriorWallCracks,
      ext5Detail: ext5Detail != null ? ext5Detail() : this.ext5Detail,
      int1DoorsOutOfPlumb: int1DoorsOutOfPlumb != null
          ? int1DoorsOutOfPlumb()
          : this.int1DoorsOutOfPlumb,
      int1Detail: int1Detail != null ? int1Detail() : this.int1Detail,
      int2DoorsWindowsOutOfSquare: int2DoorsWindowsOutOfSquare != null
          ? int2DoorsWindowsOutOfSquare()
          : this.int2DoorsWindowsOutOfSquare,
      int2Detail: int2Detail != null ? int2Detail() : this.int2Detail,
      int3CompressionCracks: int3CompressionCracks != null
          ? int3CompressionCracks()
          : this.int3CompressionCracks,
      int3Detail: int3Detail != null ? int3Detail() : this.int3Detail,
      int4FloorsOutOfLevel: int4FloorsOutOfLevel != null
          ? int4FloorsOutOfLevel()
          : this.int4FloorsOutOfLevel,
      int4Detail: int4Detail != null ? int4Detail() : this.int4Detail,
      int5CabinetsPulledFromWall: int5CabinetsPulledFromWall != null
          ? int5CabinetsPulledFromWall()
          : this.int5CabinetsPulledFromWall,
      int5Detail: int5Detail != null ? int5Detail() : this.int5Detail,
      int6InteriorWallCracks: int6InteriorWallCracks != null
          ? int6InteriorWallCracks()
          : this.int6InteriorWallCracks,
      int6Detail: int6Detail != null ? int6Detail() : this.int6Detail,
      int7CeilingCracks:
          int7CeilingCracks != null ? int7CeilingCracks() : this.int7CeilingCracks,
      int7Detail: int7Detail != null ? int7Detail() : this.int7Detail,
      int8FlooringCracks: int8FlooringCracks != null
          ? int8FlooringCracks()
          : this.int8FlooringCracks,
      int8Detail: int8Detail != null ? int8Detail() : this.int8Detail,
      gar1WallToSlabCracks: gar1WallToSlabCracks != null
          ? gar1WallToSlabCracks()
          : this.gar1WallToSlabCracks,
      gar1Detail: gar1Detail != null ? gar1Detail() : this.gar1Detail,
      gar2FloorCracksRadiate: gar2FloorCracksRadiate != null
          ? gar2FloorCracksRadiate()
          : this.gar2FloorCracksRadiate,
      gar2Detail: gar2Detail != null ? gar2Detail() : this.gar2Detail,
      app1CracksNoted:
          app1CracksNoted != null ? app1CracksNoted() : this.app1CracksNoted,
      app1Detail: app1Detail != null ? app1Detail() : this.app1Detail,
      app2UpliftNoted:
          app2UpliftNoted != null ? app2UpliftNoted() : this.app2UpliftNoted,
      app2Detail: app2Detail != null ? app2Detail() : this.app2Detail,
      app3PoolCracksDamage: app3PoolCracksDamage != null
          ? app3PoolCracksDamage()
          : this.app3PoolCracksDamage,
      app3Detail: app3Detail != null ? app3Detail() : this.app3Detail,
      app4PoolDeckCracks: app4PoolDeckCracks != null
          ? app4PoolDeckCracks()
          : this.app4PoolDeckCracks,
      app4Detail: app4Detail != null ? app4Detail() : this.app4Detail,
      generalConditionOverview: generalConditionOverview != null
          ? generalConditionOverview()
          : this.generalConditionOverview,
      adjacentBuildingDescription: adjacentBuildingDescription != null
          ? adjacentBuildingDescription()
          : this.adjacentBuildingDescription,
      distanceToNearestSinkhole: distanceToNearestSinkhole != null
          ? distanceToNearestSinkhole()
          : this.distanceToNearestSinkhole,
      otherRelevantFindings: otherRelevantFindings != null
          ? otherRelevantFindings()
          : this.otherRelevantFindings,
      unableToScheduleExplanation: unableToScheduleExplanation != null
          ? unableToScheduleExplanation()
          : this.unableToScheduleExplanation,
      attempt1Date:
          attempt1Date != null ? attempt1Date() : this.attempt1Date,
      attempt1Time:
          attempt1Time != null ? attempt1Time() : this.attempt1Time,
      attempt1NumberCalled: attempt1NumberCalled != null
          ? attempt1NumberCalled()
          : this.attempt1NumberCalled,
      attempt1Result:
          attempt1Result != null ? attempt1Result() : this.attempt1Result,
      attempt2Date:
          attempt2Date != null ? attempt2Date() : this.attempt2Date,
      attempt2Time:
          attempt2Time != null ? attempt2Time() : this.attempt2Time,
      attempt2NumberCalled: attempt2NumberCalled != null
          ? attempt2NumberCalled()
          : this.attempt2NumberCalled,
      attempt2Result:
          attempt2Result != null ? attempt2Result() : this.attempt2Result,
      attempt3Date:
          attempt3Date != null ? attempt3Date() : this.attempt3Date,
      attempt3Time:
          attempt3Time != null ? attempt3Time() : this.attempt3Time,
      attempt3NumberCalled: attempt3NumberCalled != null
          ? attempt3NumberCalled()
          : this.attempt3NumberCalled,
      attempt3Result:
          attempt3Result != null ? attempt3Result() : this.attempt3Result,
      attempt4Date:
          attempt4Date != null ? attempt4Date() : this.attempt4Date,
      attempt4Time:
          attempt4Time != null ? attempt4Time() : this.attempt4Time,
      attempt4NumberCalled: attempt4NumberCalled != null
          ? attempt4NumberCalled()
          : this.attempt4NumberCalled,
      attempt4Result:
          attempt4Result != null ? attempt4Result() : this.attempt4Result,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SinkholeFormData &&
          runtimeType == other.runtimeType &&
          insuredName == other.insuredName &&
          propertyAddress == other.propertyAddress &&
          policyNumber == other.policyNumber &&
          inspectionDate == other.inspectionDate &&
          inspectorName == other.inspectorName &&
          inspectorLicenseNumber == other.inspectorLicenseNumber &&
          inspectorCompany == other.inspectorCompany &&
          inspectorPhone == other.inspectorPhone &&
          ext1Depression == other.ext1Depression &&
          ext1Detail == other.ext1Detail &&
          ext2AdjacentSinkholes == other.ext2AdjacentSinkholes &&
          ext2Detail == other.ext2Detail &&
          ext3SoilErosion == other.ext3SoilErosion &&
          ext3Detail == other.ext3Detail &&
          ext4FoundationCracks == other.ext4FoundationCracks &&
          ext4Detail == other.ext4Detail &&
          ext5ExteriorWallCracks == other.ext5ExteriorWallCracks &&
          ext5Detail == other.ext5Detail &&
          int1DoorsOutOfPlumb == other.int1DoorsOutOfPlumb &&
          int1Detail == other.int1Detail &&
          int2DoorsWindowsOutOfSquare == other.int2DoorsWindowsOutOfSquare &&
          int2Detail == other.int2Detail &&
          int3CompressionCracks == other.int3CompressionCracks &&
          int3Detail == other.int3Detail &&
          int4FloorsOutOfLevel == other.int4FloorsOutOfLevel &&
          int4Detail == other.int4Detail &&
          int5CabinetsPulledFromWall == other.int5CabinetsPulledFromWall &&
          int5Detail == other.int5Detail &&
          int6InteriorWallCracks == other.int6InteriorWallCracks &&
          int6Detail == other.int6Detail &&
          int7CeilingCracks == other.int7CeilingCracks &&
          int7Detail == other.int7Detail &&
          int8FlooringCracks == other.int8FlooringCracks &&
          int8Detail == other.int8Detail &&
          gar1WallToSlabCracks == other.gar1WallToSlabCracks &&
          gar1Detail == other.gar1Detail &&
          gar2FloorCracksRadiate == other.gar2FloorCracksRadiate &&
          gar2Detail == other.gar2Detail &&
          app1CracksNoted == other.app1CracksNoted &&
          app1Detail == other.app1Detail &&
          app2UpliftNoted == other.app2UpliftNoted &&
          app2Detail == other.app2Detail &&
          app3PoolCracksDamage == other.app3PoolCracksDamage &&
          app3Detail == other.app3Detail &&
          app4PoolDeckCracks == other.app4PoolDeckCracks &&
          app4Detail == other.app4Detail &&
          generalConditionOverview == other.generalConditionOverview &&
          adjacentBuildingDescription == other.adjacentBuildingDescription &&
          distanceToNearestSinkhole == other.distanceToNearestSinkhole &&
          otherRelevantFindings == other.otherRelevantFindings &&
          unableToScheduleExplanation == other.unableToScheduleExplanation &&
          attempt1Date == other.attempt1Date &&
          attempt1Time == other.attempt1Time &&
          attempt1NumberCalled == other.attempt1NumberCalled &&
          attempt1Result == other.attempt1Result &&
          attempt2Date == other.attempt2Date &&
          attempt2Time == other.attempt2Time &&
          attempt2NumberCalled == other.attempt2NumberCalled &&
          attempt2Result == other.attempt2Result &&
          attempt3Date == other.attempt3Date &&
          attempt3Time == other.attempt3Time &&
          attempt3NumberCalled == other.attempt3NumberCalled &&
          attempt3Result == other.attempt3Result &&
          attempt4Date == other.attempt4Date &&
          attempt4Time == other.attempt4Time &&
          attempt4NumberCalled == other.attempt4NumberCalled &&
          attempt4Result == other.attempt4Result;

  @override
  int get hashCode => Object.hashAll(<Object?>[
        insuredName,
        propertyAddress,
        policyNumber,
        inspectionDate,
        inspectorName,
        inspectorLicenseNumber,
        inspectorCompany,
        inspectorPhone,
        ext1Depression,
        ext1Detail,
        ext2AdjacentSinkholes,
        ext2Detail,
        ext3SoilErosion,
        ext3Detail,
        ext4FoundationCracks,
        ext4Detail,
        ext5ExteriorWallCracks,
        ext5Detail,
        int1DoorsOutOfPlumb,
        int1Detail,
        int2DoorsWindowsOutOfSquare,
        int2Detail,
        int3CompressionCracks,
        int3Detail,
        int4FloorsOutOfLevel,
        int4Detail,
        int5CabinetsPulledFromWall,
        int5Detail,
        int6InteriorWallCracks,
        int6Detail,
        int7CeilingCracks,
        int7Detail,
        int8FlooringCracks,
        int8Detail,
        gar1WallToSlabCracks,
        gar1Detail,
        gar2FloorCracksRadiate,
        gar2Detail,
        app1CracksNoted,
        app1Detail,
        app2UpliftNoted,
        app2Detail,
        app3PoolCracksDamage,
        app3Detail,
        app4PoolDeckCracks,
        app4Detail,
        generalConditionOverview,
        adjacentBuildingDescription,
        distanceToNearestSinkhole,
        otherRelevantFindings,
        unableToScheduleExplanation,
        attempt1Date,
        attempt1Time,
        attempt1NumberCalled,
        attempt1Result,
        attempt2Date,
        attempt2Time,
        attempt2NumberCalled,
        attempt2Result,
        attempt3Date,
        attempt3Time,
        attempt3NumberCalled,
        attempt3Result,
        attempt4Date,
        attempt4Time,
        attempt4NumberCalled,
        attempt4Result,
      ]);
}
