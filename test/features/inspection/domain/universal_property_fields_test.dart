import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/universal_property_fields.dart';

void main() {
  group('UniversalPropertyFields', () {
    UniversalPropertyFields buildFull() {
      return UniversalPropertyFields(
        propertyAddress: '123 Main St',
        inspectionDate: DateTime(2026, 3, 7),
        inspectorName: 'Jane Doe',
        inspectorCompany: 'Acme Inspections',
        inspectorLicenseNumber: 'FL-12345',
        clientName: 'John Smith',
        inspectorSignaturePath: '/signatures/sig.png',
        comments: 'All good',
      );
    }

    test('toJson -> fromJson round-trip with all fields', () {
      final original = buildFull();
      final restored = UniversalPropertyFields.fromJson(original.toJson());

      expect(restored, original);
    });

    test('copyWith preserves unchanged fields', () {
      final original = buildFull();
      final copied = original.copyWith(clientName: 'New Client');

      expect(copied.clientName, 'New Client');
      expect(copied.propertyAddress, original.propertyAddress);
      expect(copied.inspectorName, original.inspectorName);
      expect(copied.inspectorSignaturePath, original.inspectorSignaturePath);
    });

    test('copyWith with closure null-setting', () {
      final original = buildFull();
      final copied = original.copyWith(
        inspectorSignaturePath: () => null,
      );

      expect(copied.inspectorSignaturePath, isNull);
      expect(copied.propertyAddress, original.propertyAddress);
    });
  });
}
