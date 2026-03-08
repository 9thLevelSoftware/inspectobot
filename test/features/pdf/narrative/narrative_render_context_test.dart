import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_render_context.dart';

void main() {
  group('NarrativeRenderContext', () {
    test('construction with all required fields', () {
      final context = NarrativeRenderContext(
        resolvedPhotos: const {},
        formData: const {'key': 'value'},
        inspectorName: 'John Smith',
        inspectorLicense: 'FL-12345',
        inspectorCompany: 'Acme Inspections',
        clientName: 'Jane Doe',
        propertyAddress: '123 Main St, Miami, FL',
        inspectionDate: DateTime(2026, 3, 7),
        inspectionId: 'insp-001',
      );

      expect(context.inspectorName, 'John Smith');
      expect(context.inspectorLicense, 'FL-12345');
      expect(context.inspectorCompany, 'Acme Inspections');
      expect(context.clientName, 'Jane Doe');
      expect(context.propertyAddress, '123 Main St, Miami, FL');
      expect(context.inspectionDate, DateTime(2026, 3, 7));
      expect(context.inspectionId, 'insp-001');
      expect(context.formData, {'key': 'value'});
      expect(context.signatureBytes, isNull);
    });

    test('signatureBytes is preserved when provided', () {
      final sigBytes = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]);
      final context = NarrativeRenderContext(
        resolvedPhotos: const {},
        formData: const {},
        inspectorName: 'Test',
        inspectorLicense: 'L-1',
        inspectorCompany: 'Co',
        clientName: 'Client',
        propertyAddress: 'Addr',
        inspectionDate: DateTime(2026),
        inspectionId: 'id-1',
        signatureBytes: sigBytes,
      );

      expect(context.signatureBytes, same(sigBytes));
    });
  });

  group('ResolvedNarrativePhoto', () {
    test('isResolved returns true when bytes are non-empty', () {
      final photo = ResolvedNarrativePhoto(
        sourceKey: 'roof_overview',
        originalPath: '/photos/roof.jpg',
        bytes: Uint8List.fromList([0xFF, 0xD8, 0xFF]),
      );

      expect(photo.isResolved, isTrue);
    });

    test('isResolved returns false when bytes are null', () {
      const photo = ResolvedNarrativePhoto(
        sourceKey: 'roof_overview',
        originalPath: '/photos/roof.jpg',
        failureReason: 'File not found',
      );

      expect(photo.isResolved, isFalse);
    });

    test('isResolved returns false when bytes are empty', () {
      final photo = ResolvedNarrativePhoto(
        sourceKey: 'roof_overview',
        originalPath: '/photos/roof.jpg',
        bytes: Uint8List(0),
      );

      expect(photo.isResolved, isFalse);
    });

    test('failureReason is preserved', () {
      const photo = ResolvedNarrativePhoto(
        sourceKey: 'key',
        originalPath: '/path',
        failureReason: 'Corrupt file',
      );

      expect(photo.failureReason, 'Corrupt file');
    });
  });
}
