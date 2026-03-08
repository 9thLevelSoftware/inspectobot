import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/form_requirements.dart';
import 'package:inspectobot/features/inspection/domain/universal_property_fields.dart';
import 'package:inspectobot/features/inspection/domain/wdo_form_data.dart';

void main() {
  group('WdoFormData', () {
    WdoFormData fullyPopulated() {
      return const WdoFormData(
        companyName: 'Acme Pest Control',
        businessLicenseNumber: 'BL-12345',
        companyAddress: '123 Main St',
        phoneNumber: '555-0100',
        companyCityStateZip: 'Tampa, FL 33601',
        inspectionDate: '2026-03-07',
        inspectorName: 'John Doe',
        inspectorIdCardNumber: 'ID-9876',
        propertyAddress: '456 Oak Ave',
        structuresInspected: 'Main dwelling',
        requestedBy: 'Insurance Co',
        reportSentTo: 'Agent Smith',
        liveWdoDescription: 'Termites found in garage',
        evidenceDescription: 'Mud tubes on foundation',
        damageDescription: 'Wood damage in attic',
        findingsNotes: 'Recommend treatment',
        atticSpecificAreas: 'NE corner',
        atticReason: 'Insulation blocking access',
        interiorSpecificAreas: 'Behind built-in cabinets',
        interiorReason: 'Cannot move furniture',
        exteriorSpecificAreas: 'Behind AC unit',
        exteriorReason: 'Equipment blocking',
        crawlspaceSpecificAreas: 'Under addition',
        crawlspaceReason: 'Too narrow',
        otherSpecificAreas: 'Detached garage',
        otherReason: 'Locked',
        previousTreatmentDescription: 'Spot treatment 2024',
        noticeLocation: 'Garage wall',
        organismTreated: 'Subterranean termites',
        pesticideUsed: 'Termidor SC',
        treatmentTerms: 'Annual renewal',
        spotTreatmentDescription: 'Applied to garage sill plate',
        treatmentNoticeLocation: 'Front door frame',
        comments: 'Property in fair condition',
        signatureDate: '2026-03-07',
        propertyAddressRepeat: '456 Oak Ave',
        inspectionDateRepeat: '2026-03-07',
      );
    }

    group('toJson / fromJson round-trip', () {
      test('round-trips with all fields populated', () {
        final original = fullyPopulated();
        final json = original.toJson();
        final restored = WdoFormData.fromJson(json);

        expect(restored, equals(original));
      });

      test('round-trips with empty map (all defaults)', () {
        final data = WdoFormData.fromJson(const {});

        expect(data.companyName, isNull);
        expect(data.inspectorName, isNull);
        expect(data.comments, isNull);

        // Round-trip the defaults
        final json = data.toJson();
        final restored = WdoFormData.fromJson(json);
        expect(restored, equals(data));
      });

      test('fieldKeys has exactly 37 entries', () {
        expect(WdoFormData.fieldKeys.length, 37);
      });
    });

    group('toPdfMaps', () {
      test('separates text fields into fieldValues', () {
        final data = fullyPopulated();
        final result = data.toPdfMaps();

        expect(result.fieldValues['companyName'], 'Acme Pest Control');
        expect(result.fieldValues['inspectorName'], 'John Doe');
        expect(result.checkboxValues, isEmpty);
      });

      test('merges branchContext booleans into checkboxValues', () {
        const data = WdoFormData(companyName: 'Test');
        final result = data.toPdfMaps(branchContext: {
          FormRequirements.wdoLiveWdoBranchFlag: true,
          FormRequirements.wdoDamageByWdoBranchFlag: false,
          'unrelated_flag': true,
        });

        expect(result.checkboxValues[FormRequirements.wdoLiveWdoBranchFlag], isTrue);
        expect(result.checkboxValues[FormRequirements.wdoDamageByWdoBranchFlag], isFalse);
        expect(result.checkboxValues.containsKey('unrelated_flag'), isFalse);
        expect(result.fieldValues['companyName'], 'Test');
      });

      test('excludes null text fields from fieldValues', () {
        const data = WdoFormData(companyName: 'Test');
        final result = data.toPdfMaps();

        expect(result.fieldValues.containsKey('companyName'), isTrue);
        expect(result.fieldValues.containsKey('inspectorName'), isFalse);
      });
    });

    group('withDefaults', () {
      test('pre-fills from universal fields', () {
        final universal = UniversalPropertyFields(
          propertyAddress: '789 Elm St',
          inspectionDate: DateTime(2026, 3, 7),
          inspectorName: 'Jane Smith',
          inspectorCompany: 'Smith Inspections',
          inspectorLicenseNumber: 'FL-555',
          clientName: 'Client A',
        );

        final data = WdoFormData.withDefaults(universal: universal);

        expect(data.inspectorName, 'Jane Smith');
        expect(data.propertyAddress, '789 Elm St');
        expect(data.companyName, 'Smith Inspections');
        expect(data.inspectionDate, '2026-03-07');
        expect(data.propertyAddressRepeat, '789 Elm St');
        expect(data.inspectionDateRepeat, '2026-03-07');
      });

      test('returns empty WdoFormData when no args provided', () {
        final data = WdoFormData.withDefaults();

        expect(data.inspectorName, isNull);
        expect(data.propertyAddress, isNull);
        expect(data.companyName, isNull);
      });
    });

    group('copyWith', () {
      test('creates independent copy with changed fields', () {
        final original = fullyPopulated();
        final copy = original.copyWith(
          companyName: () => 'New Company',
          comments: () => null,
        );

        expect(copy.companyName, 'New Company');
        expect(copy.comments, isNull);
        expect(copy.inspectorName, 'John Doe');
        expect(original.companyName, 'Acme Pest Control');
      });

      test('preserves all fields when no arguments provided', () {
        final original = fullyPopulated();
        final copy = original.copyWith();

        expect(copy, equals(original));
      });
    });

    group('toFormDataMap', () {
      test('matches expected key structure', () {
        final data = fullyPopulated();
        final map = data.toFormDataMap();

        expect(map.containsKey('companyName'), isTrue);
        expect(map.containsKey('inspectorName'), isTrue);
        expect(map.containsKey('comments'), isTrue);
        expect(map['companyName'], 'Acme Pest Control');
        expect(map.length, 37);
      });
    });
  });
}
