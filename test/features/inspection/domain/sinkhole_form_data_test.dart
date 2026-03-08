import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/form_requirements.dart';
import 'package:inspectobot/features/inspection/domain/sinkhole_form_data.dart';
import 'package:inspectobot/features/inspection/domain/universal_property_fields.dart';

void main() {
  group('SinkholeFormData', () {
    SinkholeFormData fullyPopulated() {
      return const SinkholeFormData(
        // Section 0
        insuredName: 'John Smith',
        propertyAddress: '123 Main St, Tampa, FL',
        policyNumber: 'POL-12345',
        inspectionDate: '2026-03-07',
        inspectorName: 'Jane Inspector',
        inspectorLicenseNumber: 'FL-9876',
        inspectorCompany: 'Inspect Co',
        inspectorPhone: '555-0100',
        // Section 1
        ext1Depression: 'Yes',
        ext1Detail: 'NE corner',
        ext2AdjacentSinkholes: 'No',
        ext2Detail: '',
        ext3SoilErosion: 'N/A',
        ext3Detail: '',
        ext4FoundationCracks: 'Yes',
        ext4Detail: 'Hairline crack E wall',
        ext5ExteriorWallCracks: 'No',
        ext5Detail: '',
        // Section 2
        int1DoorsOutOfPlumb: 'Yes',
        int1Detail: 'Master bedroom door',
        int2DoorsWindowsOutOfSquare: 'No',
        int2Detail: '',
        int3CompressionCracks: 'N/A',
        int3Detail: '',
        int4FloorsOutOfLevel: 'Yes',
        int4Detail: 'Kitchen slopes E',
        int5CabinetsPulledFromWall: 'No',
        int5Detail: '',
        int6InteriorWallCracks: 'Yes',
        int6Detail: 'Living room NW corner',
        int7CeilingCracks: 'No',
        int7Detail: '',
        int8FlooringCracks: 'N/A',
        int8Detail: '',
        // Section 3
        gar1WallToSlabCracks: 'Yes',
        gar1Detail: 'N wall to slab joint',
        gar2FloorCracksRadiate: 'No',
        gar2Detail: '',
        // Section 4
        app1CracksNoted: 'No',
        app1Detail: '',
        app2UpliftNoted: 'No',
        app2Detail: '',
        app3PoolCracksDamage: 'Yes',
        app3Detail: 'Pool deck separation',
        app4PoolDeckCracks: 'Yes',
        app4Detail: 'Radial cracks from corner',
        // Section 5
        generalConditionOverview: 'Fair condition overall',
        adjacentBuildingDescription: 'None adjacent',
        distanceToNearestSinkhole: '2.5 miles',
        otherRelevantFindings: 'None',
        unableToScheduleExplanation: '',
        // Section 6
        attempt1Date: '2026-02-15',
        attempt1Time: '09:00',
        attempt1NumberCalled: '555-0101',
        attempt1Result: 'No answer',
        attempt2Date: '2026-02-16',
        attempt2Time: '14:00',
        attempt2NumberCalled: '555-0101',
        attempt2Result: 'Scheduled',
        attempt3Date: '',
        attempt3Time: '',
        attempt3NumberCalled: '',
        attempt3Result: '',
        attempt4Date: '',
        attempt4Time: '',
        attempt4NumberCalled: '',
        attempt4Result: '',
      );
    }

    group('toJson / fromJson round-trip', () {
      test('round-trips with all fields populated', () {
        final original = fullyPopulated();
        final json = original.toJson();
        final restored = SinkholeFormData.fromJson(json);

        expect(restored, equals(original));
      });

      test('round-trips with empty map (all defaults)', () {
        final data = SinkholeFormData.fromJson(const {});

        expect(data.insuredName, isNull);
        expect(data.inspectorName, isNull);
        expect(data.ext1Depression, isNull);
        expect(data.attempt1Date, isNull);

        final json = data.toJson();
        final restored = SinkholeFormData.fromJson(json);
        expect(restored, equals(data));
      });

      test('fieldKeys has exactly 67 entries', () {
        expect(SinkholeFormData.fieldKeys.length, 67);
      });

      test('all fieldKeys are unique', () {
        final unique = SinkholeFormData.fieldKeys.toSet();
        expect(unique.length, SinkholeFormData.fieldKeys.length);
      });

      test('toJson keys match fieldKeys', () {
        final data = fullyPopulated();
        final jsonKeys = data.toJson().keys.toSet();
        final fieldKeySet = SinkholeFormData.fieldKeys.toSet();
        expect(jsonKeys, equals(fieldKeySet));
      });
    });

    group('toPdfMaps', () {
      test('separates text fields into fieldValues', () {
        final data = fullyPopulated();
        final result = data.toPdfMaps();

        expect(result.fieldValues['insuredName'], 'John Smith');
        expect(result.fieldValues['propertyAddress'], '123 Main St, Tampa, FL');
        // Tri-state values should NOT be in fieldValues
        expect(result.fieldValues.containsKey('ext1Depression'), isFalse);
      });

      test('expands tri-state fields to 3 checkboxes', () {
        const data = SinkholeFormData(ext1Depression: 'Yes');
        final result = data.toPdfMaps();

        expect(result.checkboxValues['ext1Depression_yes'], isTrue);
        expect(result.checkboxValues['ext1Depression_no'], isFalse);
        expect(result.checkboxValues['ext1Depression_na'], isFalse);
      });

      test('tri-state N/A maps correctly', () {
        const data = SinkholeFormData(ext3SoilErosion: 'N/A');
        final result = data.toPdfMaps();

        expect(result.checkboxValues['ext3SoilErosion_yes'], isFalse);
        expect(result.checkboxValues['ext3SoilErosion_no'], isFalse);
        expect(result.checkboxValues['ext3SoilErosion_na'], isTrue);
      });

      test('merges canonical sinkhole branch flags', () {
        const data = SinkholeFormData(insuredName: 'Test');
        final result = data.toPdfMaps(branchContext: {
          FormRequirements.sinkholeAnyExteriorYesBranchFlag: true,
          FormRequirements.sinkholeAnyGarageYesBranchFlag: false,
          'unrelated_flag': true,
        });

        expect(
          result.checkboxValues[
              FormRequirements.sinkholeAnyExteriorYesBranchFlag],
          isTrue,
        );
        expect(
          result.checkboxValues[
              FormRequirements.sinkholeAnyGarageYesBranchFlag],
          isFalse,
        );
        expect(result.checkboxValues.containsKey('unrelated_flag'), isFalse);
      });

      test('excludes null text fields from fieldValues', () {
        const data = SinkholeFormData(insuredName: 'Test');
        final result = data.toPdfMaps();

        expect(result.fieldValues.containsKey('insuredName'), isTrue);
        expect(result.fieldValues.containsKey('propertyAddress'), isFalse);
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

        final data = SinkholeFormData.withDefaults(universal: universal);

        expect(data.insuredName, 'Client A');
        expect(data.propertyAddress, '789 Elm St');
        expect(data.inspectorName, 'Jane Smith');
        expect(data.inspectorCompany, 'Smith Inspections');
        expect(data.inspectorLicenseNumber, 'FL-555');
        expect(data.inspectionDate, '2026-03-07');
      });

      test('returns empty SinkholeFormData when no args', () {
        final data = SinkholeFormData.withDefaults();

        expect(data.insuredName, isNull);
        expect(data.inspectorName, isNull);
        expect(data.propertyAddress, isNull);
      });
    });

    group('copyWith', () {
      test('creates independent copy with changed field', () {
        final original = fullyPopulated();
        final copy = original.copyWith(
          insuredName: () => 'New Name',
        );

        expect(copy.insuredName, 'New Name');
        expect(copy.propertyAddress, original.propertyAddress);
        expect(original.insuredName, 'John Smith');
      });

      test('can set field to null via closure', () {
        final original = fullyPopulated();
        final copy = original.copyWith(
          insuredName: () => null,
        );

        expect(copy.insuredName, isNull);
      });

      test('preserves all fields when no args', () {
        final original = fullyPopulated();
        final copy = original.copyWith();

        expect(copy, equals(original));
      });
    });

    group('equality / hashCode', () {
      test('equal instances', () {
        final a = fullyPopulated();
        final b = fullyPopulated();

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('different instances are not equal', () {
        final a = fullyPopulated();
        final b = a.copyWith(insuredName: () => 'Different');

        expect(a, isNot(equals(b)));
      });
    });
  });
}
