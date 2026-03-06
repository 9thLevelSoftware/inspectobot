import 'dart:convert';
import 'dart:typed_data';

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
