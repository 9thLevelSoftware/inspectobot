import 'dart:convert';

import 'package:flutter/services.dart';

import '../../inspection/domain/form_type.dart';
import '../models/pdf_field_map.dart';
import '../models/pdf_template_manifest.dart';

typedef PdfMapAssetReader = Future<String> Function(String assetPath);

class PdfTemplateAssetBundle {
  const PdfTemplateAssetBundle({
    required this.manifestEntry,
    required this.fieldMap,
  });

  final PdfTemplateManifestEntry manifestEntry;
  final PdfFieldMap fieldMap;
}

class PdfTemplateAssetLoader {
  PdfTemplateAssetLoader({
    PdfTemplateManifest? manifest,
    PdfMapAssetReader? readMapAsset,
  })  : manifest = manifest ?? PdfTemplateManifest.standard(),
        _readMapAsset = readMapAsset ?? rootBundle.loadString;

  final PdfTemplateManifest manifest;
  final PdfMapAssetReader _readMapAsset;

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
    return PdfTemplateAssetBundle(
      manifestEntry: entry,
      fieldMap: PdfFieldMap(
        formType: formType,
        mapVersion: mapVersion,
        fields: fields,
      ),
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
          sourceKey: _requiredString(rawField, 'source_key'),
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
