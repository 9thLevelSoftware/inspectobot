import 'dart:io';
import 'dart:typed_data';

import '../models/pdf_field_map.dart';
import '../pdf_generation_input.dart';

class ResolvedPdfFieldData {
  const ResolvedPdfFieldData({
    required this.textByFieldKey,
    required this.checkboxByFieldKey,
    required this.imageByFieldKey,
    required this.signatureByFieldKey,
  });

  final Map<String, String> textByFieldKey;
  final Map<String, bool> checkboxByFieldKey;
  final Map<String, Uint8List> imageByFieldKey;
  final Map<String, Uint8List> signatureByFieldKey;
}

class PdfMediaResolver {
  const PdfMediaResolver();

  Future<ResolvedPdfFieldData> resolve({
    required PdfGenerationInput input,
    required PdfFieldMap fieldMap,
  }) async {
    final textByFieldKey = <String, String>{};
    final checkboxByFieldKey = <String, bool>{};
    final imageByFieldKey = <String, Uint8List>{};
    final signatureByFieldKey = <String, Uint8List>{};

    for (final field in fieldMap.fields) {
      switch (field.type) {
        case PdfFieldType.text:
          textByFieldKey[field.key] = _resolveTextValue(
            sourceKey: field.sourceKey,
            input: input,
          );
        case PdfFieldType.checkbox:
          checkboxByFieldKey[field.key] = _resolveCheckboxValue(
            sourceKey: field.sourceKey,
            input: input,
          );
        case PdfFieldType.image:
          final bytes = await _resolveImageBytes(
            sourceKey: field.sourceKey,
            input: input,
          );
          if (bytes != null) {
            imageByFieldKey[field.key] = bytes;
          }
        case PdfFieldType.signature:
          final signature = input.signatureBytes;
          if (signature != null && signature.isNotEmpty) {
            signatureByFieldKey[field.key] = signature;
          }
      }
    }

    return ResolvedPdfFieldData(
      textByFieldKey: textByFieldKey,
      checkboxByFieldKey: checkboxByFieldKey,
      imageByFieldKey: imageByFieldKey,
      signatureByFieldKey: signatureByFieldKey,
    );
  }

  String _resolveTextValue({
    required String sourceKey,
    required PdfGenerationInput input,
  }) {
    final explicit = input.fieldValues[sourceKey];
    if (explicit != null) {
      return explicit;
    }
    switch (sourceKey) {
      case 'inspection_id':
        return input.inspectionId;
      case 'organization_id':
        return input.organizationId;
      case 'user_id':
        return input.userId;
      case 'client_name':
        return input.clientName;
      case 'property_address':
        return input.propertyAddress;
      default:
        return '';
    }
  }

  bool _resolveCheckboxValue({
    required String sourceKey,
    required PdfGenerationInput input,
  }) {
    final explicit = input.checkboxValues[sourceKey];
    if (explicit != null) {
      return explicit;
    }
    return input.wizardCompletion[sourceKey] == true;
  }

  Future<Uint8List?> _resolveImageBytes({
    required String sourceKey,
    required PdfGenerationInput input,
  }) async {
    final paths = input.evidenceMediaPaths[sourceKey];
    if (paths == null || paths.isEmpty) {
      return null;
    }
    final file = File(paths.first);
    if (!await file.exists()) {
      return null;
    }
    return file.readAsBytes();
  }
}
