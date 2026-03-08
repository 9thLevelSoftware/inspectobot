import 'dart:typed_data';

import 'package:inspectobot/features/pdf/narrative/narrative_render_context.dart';

/// Creates a [NarrativeRenderContext] with sensible defaults for testing.
///
/// All parameters can be overridden for specific test scenarios.
NarrativeRenderContext buildTestRenderContext({
  Map<String, List<ResolvedNarrativePhoto>>? resolvedPhotos,
  Map<String, dynamic>? formData,
  String inspectorName = 'John Inspector',
  String inspectorLicense = 'FL-12345',
  String inspectorCompany = 'Test Inspections LLC',
  String clientName = 'Jane Client',
  String propertyAddress = '123 Main St, Tampa, FL 33601',
  DateTime? inspectionDate,
  String inspectionId = 'test-inspection-001',
  Uint8List? signatureBytes,
}) {
  return NarrativeRenderContext(
    resolvedPhotos: resolvedPhotos ?? const {},
    formData: formData ?? const {},
    inspectorName: inspectorName,
    inspectorLicense: inspectorLicense,
    inspectorCompany: inspectorCompany,
    clientName: clientName,
    propertyAddress: propertyAddress,
    inspectionDate: inspectionDate ?? DateTime(2026, 3, 8),
    inspectionId: inspectionId,
    signatureBytes: signatureBytes,
  );
}

/// Creates a minimal 1x1 white PNG for testing photo rendering.
///
/// This is a valid PNG that the pdf package can decode as a MemoryImage.
Uint8List buildTestPngBytes() {
  // Minimal valid 1x1 white pixel PNG
  return Uint8List.fromList([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
    0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, // IHDR chunk
    0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
    0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53,
    0xDE,
    0x00, 0x00, 0x00, 0x0C, 0x49, 0x44, 0x41, 0x54, // IDAT chunk
    0x08, 0xD7, 0x63, 0xF8, 0xCF, 0xC0, 0x00, 0x00,
    0x00, 0x02, 0x00, 0x01, 0xE2, 0x21, 0xBC, 0x33,
    0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, // IEND chunk
    0xAE, 0x42, 0x60, 0x82,
  ]);
}

/// Creates a [ResolvedNarrativePhoto] that successfully resolved.
ResolvedNarrativePhoto buildResolvedPhoto({
  String sourceKey = 'test_photo',
  String originalPath = '/tmp/test.jpg',
  Uint8List? bytes,
}) {
  return ResolvedNarrativePhoto(
    sourceKey: sourceKey,
    originalPath: originalPath,
    bytes: bytes ?? buildTestPngBytes(),
  );
}

/// Creates a [ResolvedNarrativePhoto] that failed to resolve.
ResolvedNarrativePhoto buildUnresolvedPhoto({
  String sourceKey = 'missing_photo',
  String originalPath = '/tmp/missing.jpg',
  String failureReason = 'File not found',
}) {
  return ResolvedNarrativePhoto(
    sourceKey: sourceKey,
    originalPath: originalPath,
    failureReason: failureReason,
  );
}
