import 'dart:convert';

import 'package:flutter/services.dart';

import '../../inspection/domain/form_requirements.dart';
import '../../inspection/domain/form_type.dart';
import '../models/pdf_field_map.dart';
import '../models/pdf_template_manifest.dart';

typedef PdfMapAssetReader = Future<String> Function(String assetPath);
typedef PdfTemplateAssetReader = Future<ByteData> Function(String assetPath);

class PdfTemplateAssetBundle {
  const PdfTemplateAssetBundle({
    required this.manifestEntry,
    required this.fieldMap,
    required this.templateBytes,
  });

  final PdfTemplateManifestEntry manifestEntry;
  final PdfFieldMap fieldMap;
  final Uint8List templateBytes;
}

class PdfTemplateAssetLoader {
  /// AUTH-04 POLICY: Inspector license data (licenseType, licenseNumber) is
  /// captured in InspectorProfile and persisted to Supabase for profile
  /// continuity, but is intentionally excluded from PDF output.
  ///
  /// Rationale: Florida's standard inspection forms (Four-Point, Roof
  /// Condition, Wind Mitigation OIR-B1-1802) do not include designated
  /// inspector license number fields. Adding them would create non-standard
  /// content in official form PDFs.
  ///
  /// License data is available for:
  ///   - Inspector identity display in the app
  ///   - Future multi-state form expansion (EXP-01) where forms may require
  ///     license fields
  ///
  /// To reverse this policy:
  ///   1. Remove these keys from [inspectorLicenseSourceKeys]
  ///   2. Add resolver cases in PdfMediaResolver._resolveTextValue()
  ///   3. Add field entries to the relevant JSON map files
  ///   4. Update pdf_profile_mapping_contract_test.dart to assert consumer status
  ///   5. Load InspectorProfile during PDF input assembly
  static const Set<String> inspectorLicenseSourceKeys = <String>{
    'license_type',
    'license_number',
  };

  /// Sinkhole form source keys used in sinkhole_inspection PDF field maps.
  ///
  /// Includes text field keys, tri-state checkbox keys ({field}__yes/__no/__na),
  /// and branch flag keys for checkbox entries.
  static const Set<String> sinkholeFormFieldSourceKeys = <String>{
    // Section 0: Property ID
    'insuredName',
    'propertyAddress',
    'policyNumber',
    'inspectionDate',
    'inspectorName',
    'inspectorLicenseNumber',
    'inspectorCompany',
    'inspectorPhone',
    // Section 1: Exterior (detail text fields)
    'ext1Detail',
    'ext2Detail',
    'ext3Detail',
    'ext4Detail',
    'ext5Detail',
    // Section 1: Exterior (tri-state checkboxes)
    'ext1Depression__yes',
    'ext1Depression__no',
    'ext1Depression__na',
    'ext2AdjacentSinkholes__yes',
    'ext2AdjacentSinkholes__no',
    'ext2AdjacentSinkholes__na',
    'ext3SoilErosion__yes',
    'ext3SoilErosion__no',
    'ext3SoilErosion__na',
    'ext4FoundationCracks__yes',
    'ext4FoundationCracks__no',
    'ext4FoundationCracks__na',
    'ext5ExteriorWallCracks__yes',
    'ext5ExteriorWallCracks__no',
    'ext5ExteriorWallCracks__na',
    // Section 2: Interior (detail text fields)
    'int1Detail',
    'int2Detail',
    'int3Detail',
    'int4Detail',
    'int5Detail',
    'int6Detail',
    'int7Detail',
    'int8Detail',
    // Section 2: Interior (tri-state checkboxes)
    'int1DoorsOutOfPlumb__yes',
    'int1DoorsOutOfPlumb__no',
    'int1DoorsOutOfPlumb__na',
    'int2DoorsWindowsOutOfSquare__yes',
    'int2DoorsWindowsOutOfSquare__no',
    'int2DoorsWindowsOutOfSquare__na',
    'int3CompressionCracks__yes',
    'int3CompressionCracks__no',
    'int3CompressionCracks__na',
    'int4FloorsOutOfLevel__yes',
    'int4FloorsOutOfLevel__no',
    'int4FloorsOutOfLevel__na',
    'int5CabinetsPulledFromWall__yes',
    'int5CabinetsPulledFromWall__no',
    'int5CabinetsPulledFromWall__na',
    'int6InteriorWallCracks__yes',
    'int6InteriorWallCracks__no',
    'int6InteriorWallCracks__na',
    'int7CeilingCracks__yes',
    'int7CeilingCracks__no',
    'int7CeilingCracks__na',
    'int8FlooringCracks__yes',
    'int8FlooringCracks__no',
    'int8FlooringCracks__na',
    // Section 3: Garage (detail text fields)
    'gar1Detail',
    'gar2Detail',
    // Section 3: Garage (tri-state checkboxes)
    'gar1WallToSlabCracks__yes',
    'gar1WallToSlabCracks__no',
    'gar1WallToSlabCracks__na',
    'gar2FloorCracksRadiate__yes',
    'gar2FloorCracksRadiate__no',
    'gar2FloorCracksRadiate__na',
    // Section 4: Appurtenant (detail text fields)
    'app1Detail',
    'app2Detail',
    'app3Detail',
    'app4Detail',
    // Section 4: Appurtenant (tri-state checkboxes)
    'app1CracksNoted__yes',
    'app1CracksNoted__no',
    'app1CracksNoted__na',
    'app2UpliftNoted__yes',
    'app2UpliftNoted__no',
    'app2UpliftNoted__na',
    'app3PoolCracksDamage__yes',
    'app3PoolCracksDamage__no',
    'app3PoolCracksDamage__na',
    'app4PoolDeckCracks__yes',
    'app4PoolDeckCracks__no',
    'app4PoolDeckCracks__na',
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
    // Branch flag checkboxes
    'sinkhole_any_exterior_yes',
    'sinkhole_any_interior_yes',
    'sinkhole_any_garage_yes',
    'sinkhole_any_appurtenant_yes',
    'sinkhole_any_yes',
    'sinkhole_townhouse',
    'sinkhole_unable_to_schedule',
    'sinkhole_crack_significant',
  };

  /// WDO form text field source keys used in FDACS-13645 PDF field maps.
  static const Set<String> wdoFormFieldSourceKeys = <String>{
    'gen_company_name',
    'gen_business_license',
    'gen_company_address',
    'gen_phone',
    'gen_city_state_zip',
    'gen_inspection_date',
    'gen_inspector_name',
    'gen_inspector_id',
    'gen_property_address',
    'gen_structures',
    'gen_requested_by',
    'gen_report_sent_to',
    'find_live_description',
    'find_evidence_description',
    'find_damage_description',
    'find_notes',
    'attic_specific_areas',
    'attic_reason',
    'interior_specific_areas',
    'interior_reason',
    'exterior_specific_areas',
    'exterior_reason',
    'crawlspace_specific_areas',
    'crawlspace_reason',
    'other_specific_areas',
    'other_reason',
    'treat_prev_description',
    'treat_notice_location',
    'treat_organism',
    'treat_pesticide',
    'treat_terms',
    'treat_spot_description',
    'treat_notice_treatment_location',
    'comments',
    'sig_date',
    'repeat_property_address',
    'repeat_inspection_date',
  };

  PdfTemplateAssetLoader({
    PdfTemplateManifest? manifest,
    PdfMapAssetReader? readMapAsset,
    PdfTemplateAssetReader? readTemplateAsset,
    Set<String>? allowedSourceKeys,
  })  : manifest = manifest ?? PdfTemplateManifest.standard(),
        _readMapAsset = readMapAsset ?? rootBundle.loadString,
        _readTemplateAsset = readTemplateAsset ?? rootBundle.load,
        _allowedSourceKeys =
            Set<String>.from(
              allowedSourceKeys ??
                  <String>{
                    ...FormRequirements.canonicalSourceKeys(),
                    'inspection_id',
                    'organization_id',
                    'user_id',
                    'client_name',
                    'property_address',
                    'inspector_signature',
                    ...wdoFormFieldSourceKeys,
                    ...sinkholeFormFieldSourceKeys,
                  },
            // AUTH-04 POLICY: Exclude license keys from allowlist — see policy doc above.
            )..removeAll(inspectorLicenseSourceKeys);

  final PdfTemplateManifest manifest;
  final PdfMapAssetReader _readMapAsset;
  final PdfTemplateAssetReader _readTemplateAsset;
  final Set<String> _allowedSourceKeys;

  Set<String> get allowedSourceKeys =>
      Set<String>.unmodifiable(_allowedSourceKeys);

  Future<PdfTemplateAssetBundle> load(FormType formType) async {
    final entry = manifest.requireForForm(formType);
    final decoded = await _readAndParseMap(entry, formType);

    final mapVersion = _requiredString(decoded, 'map_version');
    if (mapVersion != entry.mapVersion) {
      throw PdfTemplateAssetLoaderError(
        'Template map version mismatch for ${formType.code}: '
        'manifest=${entry.mapVersion}, map=$mapVersion',
      );
    }

    final fields = _parseFields(decoded['fields'], formType);
    final templateBytes = await _readTemplateBytes(entry, formType);
    return PdfTemplateAssetBundle(
      manifestEntry: entry,
      fieldMap: PdfFieldMap(
        formType: formType,
        mapVersion: mapVersion,
        fields: fields,
      ),
      templateBytes: templateBytes,
    );
  }

  Future<Map<String, dynamic>> _readAndParseMap(
    PdfTemplateManifestEntry entry,
    FormType formType,
  ) async {
    final raw = await _readMapAsset(entry.mapAssetPath);
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw PdfTemplateAssetLoaderError(
        'Invalid map payload for ${formType.code}: expected top-level object',
      );
    }

    final mapFormCode = _requiredString(decoded, 'form_code');
    if (mapFormCode != formType.code) {
      throw PdfTemplateAssetLoaderError(
        'Map payload form mismatch for ${formType.code}: map=$mapFormCode',
      );
    }
    return decoded;
  }

  List<PdfFieldDefinition> _parseFields(Object? rawFields, FormType formType) {
    if (rawFields is! List<dynamic>) {
      throw PdfTemplateAssetLoaderError(
        'Invalid map payload for ${formType.code}: "fields" must be a list',
      );
    }

    final fields = <PdfFieldDefinition>[];
    for (final rawField in rawFields) {
      if (rawField is! Map<String, dynamic>) {
        throw PdfTemplateAssetLoaderError(
          'Invalid map payload for ${formType.code}: field must be an object',
        );
      }

      fields.add(
        PdfFieldDefinition(
          key: _requiredString(rawField, 'key'),
          sourceKey: _validatedSourceKey(rawField, formType),
          type: PdfFieldType.fromWireValue(_requiredString(rawField, 'type')),
          page: _requiredInt(rawField, 'page'),
          x: _requiredDouble(rawField, 'x'),
          y: _requiredDouble(rawField, 'y'),
          width: _requiredDouble(rawField, 'width'),
          height: _requiredDouble(rawField, 'height'),
        ),
      );
    }
    return fields;
  }

  String _validatedSourceKey(
    Map<String, dynamic> source,
    FormType formType,
  ) {
    final sourceKey = _requiredString(source, 'source_key');
    if (_allowedSourceKeys.contains(sourceKey)) {
      return sourceKey;
    }
    throw PdfTemplateAssetLoaderError(
      'Unknown source_key "$sourceKey" in map for ${formType.code}',
    );
  }

  Future<Uint8List> _readTemplateBytes(
    PdfTemplateManifestEntry entry,
    FormType formType,
  ) async {
    final raw = await _readTemplateAsset(entry.templateAssetId);
    final bytes = raw.buffer.asUint8List(raw.offsetInBytes, raw.lengthInBytes);
    if (bytes.isEmpty) {
      throw PdfTemplateAssetLoaderError(
        'Template asset is empty for ${formType.code}: ${entry.templateAssetId}',
      );
    }
    return bytes;
  }

  String _requiredString(Map<String, dynamic> source, String key) {
    final value = source[key];
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
    throw PdfTemplateAssetLoaderError('Missing or invalid "$key" string value');
  }

  int _requiredInt(Map<String, dynamic> source, String key) {
    final value = source[key];
    if (value is int) {
      return value;
    }
    throw PdfTemplateAssetLoaderError('Missing or invalid "$key" integer value');
  }

  double _requiredDouble(Map<String, dynamic> source, String key) {
    final value = source[key];
    if (value is num) {
      return value.toDouble();
    }
    throw PdfTemplateAssetLoaderError('Missing or invalid "$key" numeric value');
  }
}

class PdfTemplateAssetLoaderError implements Exception {
  const PdfTemplateAssetLoaderError(this.message);

  final String message;

  @override
  String toString() => message;
}
