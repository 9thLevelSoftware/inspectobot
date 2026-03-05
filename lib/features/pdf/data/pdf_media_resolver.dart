import 'dart:io';
import 'dart:typed_data';

import '../models/pdf_field_map.dart';
import '../pdf_generation_input.dart';

typedef PdfRemoteMediaReader = Future<Uint8List?> Function(String storagePath);

class ResolvedPdfFieldData {
  const ResolvedPdfFieldData({
    required this.textByFieldKey,
    required this.checkboxByFieldKey,
    required this.imageByFieldKey,
    required this.signatureByFieldKey,
    required this.unresolvedMediaByFieldKey,
  });

  final Map<String, String> textByFieldKey;
  final Map<String, bool> checkboxByFieldKey;
  final Map<String, Uint8List> imageByFieldKey;
  final Map<String, Uint8List> signatureByFieldKey;
  final Map<String, String> unresolvedMediaByFieldKey;
}

class PdfMediaResolver {
  const PdfMediaResolver({this.remoteReadBytes});

  final PdfRemoteMediaReader? remoteReadBytes;

  Future<ResolvedPdfFieldData> resolve({
    required PdfGenerationInput input,
    required PdfFieldMap fieldMap,
  }) async {
    final textByFieldKey = <String, String>{};
    final checkboxByFieldKey = <String, bool>{};
    final imageByFieldKey = <String, Uint8List>{};
    final signatureByFieldKey = <String, Uint8List>{};
    final unresolvedMediaByFieldKey = <String, String>{};

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
          final imageResult = await _resolveImageBytes(
            sourceKey: field.sourceKey,
            input: input,
          );
          if (imageResult.bytes != null) {
            imageByFieldKey[field.key] = imageResult.bytes!;
          } else {
            unresolvedMediaByFieldKey[field.key] = imageResult.reason;
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
      unresolvedMediaByFieldKey: unresolvedMediaByFieldKey,
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

  Future<_ImageResolutionResult> _resolveImageBytes({
    required String sourceKey,
    required PdfGenerationInput input,
  }) async {
    final paths = input.evidenceMediaPaths[sourceKey];
    if (paths == null || paths.isEmpty) {
      return const _ImageResolutionResult(
        bytes: null,
        reason: 'No media references provided',
      );
    }

    String? lastFailure;
    for (final rawPath in paths) {
      final reference = rawPath.trim();
      if (reference.isEmpty) {
        continue;
      }

      final file = File(reference);
      try {
        if (await file.exists()) {
          final localBytes = await file.readAsBytes();
          if (localBytes.isNotEmpty) {
            return _ImageResolutionResult(
              bytes: localBytes,
              reason: 'Resolved from local file',
            );
          }
          lastFailure = 'Local file was empty: $reference';
          continue;
        }
      } catch (_) {
        lastFailure = 'Local read failed: $reference';
      }

      final remoteReader = remoteReadBytes;
      if (remoteReader != null) {
        try {
          final remoteBytes = await remoteReader(reference);
          if (remoteBytes != null && remoteBytes.isNotEmpty) {
            return _ImageResolutionResult(
              bytes: remoteBytes,
              reason: 'Resolved from remote storage key',
            );
          }
          lastFailure = 'Remote object key not found: $reference';
        } catch (_) {
          lastFailure = 'Remote read failed: $reference';
        }
      }
    }

    return _ImageResolutionResult(
      bytes: null,
      reason: lastFailure ?? 'Unable to resolve media references',
    );
  }
}

class _ImageResolutionResult {
  const _ImageResolutionResult({required this.bytes, required this.reason});

  final Uint8List? bytes;
  final String reason;
}
