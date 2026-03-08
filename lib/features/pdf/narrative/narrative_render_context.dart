import 'dart:typed_data';

/// Holds all resolved data needed to render a narrative PDF report.
///
/// Created by the narrative orchestrator after resolving photos, signatures,
/// and form data. Passed to template renderers for PDF generation.
class NarrativeRenderContext {
  const NarrativeRenderContext({
    required this.resolvedPhotos,
    required this.formData,
    required this.inspectorName,
    required this.inspectorLicense,
    required this.inspectorCompany,
    required this.clientName,
    required this.propertyAddress,
    required this.inspectionDate,
    required this.inspectionId,
    this.signatureBytes,
  });

  /// Photos grouped by section key, resolved to byte data.
  final Map<String, List<ResolvedNarrativePhoto>> resolvedPhotos;

  /// Inspector signature as PNG bytes, if available.
  final Uint8List? signatureBytes;

  /// Raw form data from the inspection session.
  final Map<String, dynamic> formData;

  /// Inspector identity fields.
  final String inspectorName;
  final String inspectorLicense;
  final String inspectorCompany;

  /// Client and property fields.
  final String clientName;
  final String propertyAddress;

  /// When the inspection was performed.
  final DateTime inspectionDate;

  /// Unique identifier for the inspection.
  final String inspectionId;
}

/// A photo that has been resolved from disk or network for PDF embedding.
class ResolvedNarrativePhoto {
  const ResolvedNarrativePhoto({
    required this.sourceKey,
    required this.originalPath,
    this.bytes,
    this.failureReason,
  });

  /// The logical key identifying this photo slot (e.g. 'roof_overview_1').
  final String sourceKey;

  /// The original file path or URL before resolution.
  final String originalPath;

  /// The raw image bytes if resolution succeeded.
  final Uint8List? bytes;

  /// Human-readable reason if resolution failed.
  final String? failureReason;

  /// Whether this photo was successfully resolved and has image data.
  bool get isResolved => bytes != null && bytes!.isNotEmpty;
}
