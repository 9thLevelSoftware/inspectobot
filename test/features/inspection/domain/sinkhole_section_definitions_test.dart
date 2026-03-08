import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/field_type.dart';
import 'package:inspectobot/features/inspection/domain/form_requirements.dart';
import 'package:inspectobot/features/inspection/domain/sinkhole_form_data.dart';
import 'package:inspectobot/features/inspection/domain/sinkhole_section_definitions.dart';

void main() {
  group('SinkholeSectionDefinitions', () {
    test('all getter returns 7 sections', () {
      expect(SinkholeSectionDefinitions.all, hasLength(7));
    });

    test('each section has correct ID and title', () {
      final sections = SinkholeSectionDefinitions.all;

      expect(sections[0].id, 'sinkhole_property_id');
      expect(sections[0].title, 'Property ID');

      expect(sections[1].id, 'sinkhole_exterior');
      expect(sections[1].title, 'Exterior');

      expect(sections[2].id, 'sinkhole_interior');
      expect(sections[2].title, 'Interior');

      expect(sections[3].id, 'sinkhole_garage');
      expect(sections[3].title, 'Garage');

      expect(sections[4].id, 'sinkhole_appurtenant');
      expect(sections[4].title, 'Appurtenant');

      expect(sections[5].id, 'sinkhole_additional');
      expect(sections[5].title, 'Additional');

      expect(sections[6].id, 'sinkhole_scheduling');
      expect(sections[6].title, 'Scheduling');
    });

    test('total field count matches SinkholeFormData.fieldKeys.length', () {
      expect(
        SinkholeSectionDefinitions.totalFieldCount,
        SinkholeFormData.fieldKeys.length,
      );
    });

    test('exterior has 5 field groups', () {
      expect(
        SinkholeSectionDefinitions.exterior.fieldGroups,
        hasLength(5),
      );
    });

    test('interior has 8 field groups', () {
      expect(
        SinkholeSectionDefinitions.interior.fieldGroups,
        hasLength(8),
      );
    });

    test('trigger fields are all triState type', () {
      final sectionsWithGroups = [
        SinkholeSectionDefinitions.exterior,
        SinkholeSectionDefinitions.interior,
        SinkholeSectionDefinitions.garage,
        SinkholeSectionDefinitions.appurtenant,
      ];

      for (final section in sectionsWithGroups) {
        for (final group in section.fieldGroups) {
          expect(
            group.triggerField.type,
            FieldType.triState,
            reason: '${section.id} group ${group.groupKey} trigger should be '
                'triState',
          );
        }
      }
    });

    test('scheduling has 1 RepeatingFieldGroup with 4 repetitions', () {
      final scheduling = SinkholeSectionDefinitions.scheduling;
      expect(scheduling.repeatingFieldGroups, hasLength(1));
      expect(scheduling.repeatingFieldGroups.first.repetitions, 4);
      expect(scheduling.repeatingFieldGroups.first.fieldTemplate, hasLength(4));
      expect(scheduling.repeatingFieldGroups.first.totalFieldCount, 16);
    });

    test('all branch flag keys exist in FormRequirements.canonicalBranchFlags',
        () {
      final allBranchFlags = <String>[];
      for (final section in SinkholeSectionDefinitions.all) {
        allBranchFlags.addAll(section.branchFlagKeys);
      }

      for (final flag in allBranchFlags) {
        expect(
          FormRequirements.canonicalBranchFlags,
          contains(flag),
          reason: 'Branch flag "$flag" should be in canonicalBranchFlags',
        );
      }
    });

    test('no duplicate field keys across sections', () {
      final allKeys = <String>{};
      final duplicates = <String>[];

      for (final section in SinkholeSectionDefinitions.all) {
        // Standalone field definitions
        for (final field in section.fieldDefinitions) {
          if (!allKeys.add(field.key)) {
            duplicates.add(field.key);
          }
        }

        // Field group fields
        for (final group in section.fieldGroups) {
          for (final field in group.allFields) {
            if (!allKeys.add(field.key)) {
              duplicates.add(field.key);
            }
          }
        }

        // Repeating field group concrete keys
        for (final rg in section.repeatingFieldGroups) {
          for (final key in rg.allFieldKeys) {
            if (!allKeys.add(key)) {
              duplicates.add(key);
            }
          }
        }
      }

      expect(duplicates, isEmpty, reason: 'Found duplicate keys: $duplicates');
    });

    test('property ID section has 8 standalone fields, no groups', () {
      final section = SinkholeSectionDefinitions.propertyId;
      expect(section.fieldDefinitions, hasLength(8));
      expect(section.fieldGroups, isEmpty);
      expect(section.repeatingFieldGroups, isEmpty);
      expect(section.branchFlagKeys, isEmpty);
    });

    test('garage has 2 field groups', () {
      expect(SinkholeSectionDefinitions.garage.fieldGroups, hasLength(2));
    });

    test('appurtenant has 4 field groups', () {
      expect(SinkholeSectionDefinitions.appurtenant.fieldGroups, hasLength(4));
    });

    test('additional info has correct branch flags', () {
      final section = SinkholeSectionDefinitions.additionalInfo;
      expect(section.branchFlagKeys, containsAll([
        FormRequirements.sinkholeTownhouseBranchFlag,
        FormRequirements.sinkholeUnableToScheduleBranchFlag,
        FormRequirements.sinkholeCrackSignificantBranchFlag,
      ]));
      // Must NOT contain sinkholeAnyYesBranchFlag
      expect(
        section.branchFlagKeys,
        isNot(contains(FormRequirements.sinkholeAnyYesBranchFlag)),
      );
    });

    test('additional info has conditional fields', () {
      final section = SinkholeSectionDefinitions.additionalInfo;
      final adjacentField = section.fieldDefinitions.firstWhere(
        (f) => f.key == 'adjacentBuildingDescription',
      );
      expect(
        adjacentField.conditionalOn,
        FormRequirements.sinkholeTownhouseBranchFlag,
      );

      final scheduleField = section.fieldDefinitions.firstWhere(
        (f) => f.key == 'unableToScheduleExplanation',
      );
      expect(
        scheduleField.conditionalOn,
        FormRequirements.sinkholeUnableToScheduleBranchFlag,
      );
    });

    test('each checklist section has evidence requirement keys', () {
      expect(
        SinkholeSectionDefinitions.exterior.evidenceRequirementKeys,
        contains('photo:sinkhole_front_elevation'),
      );
      expect(
        SinkholeSectionDefinitions.interior.evidenceRequirementKeys,
        contains('photo:sinkhole_checklist_item'),
      );
      expect(
        SinkholeSectionDefinitions.garage.evidenceRequirementKeys,
        contains('photo:sinkhole_garage_crack'),
      );
      expect(
        SinkholeSectionDefinitions.appurtenant.evidenceRequirementKeys,
        contains('photo:sinkhole_adjacent_structure'),
      );
    });

    test('section field counts match expected values', () {
      // Section 0: 8 standalone
      expect(SinkholeSectionDefinitions.propertyId.fieldDefinitions.length, 8);

      // Section 1: 5 groups x 2 = 10
      expect(
        SinkholeSectionDefinitions.exterior.fieldGroups
            .fold<int>(0, (sum, g) => sum + g.allFields.length),
        10,
      );

      // Section 2: 8 groups x 2 = 16
      expect(
        SinkholeSectionDefinitions.interior.fieldGroups
            .fold<int>(0, (sum, g) => sum + g.allFields.length),
        16,
      );

      // Section 3: 2 groups x 2 = 4
      expect(
        SinkholeSectionDefinitions.garage.fieldGroups
            .fold<int>(0, (sum, g) => sum + g.allFields.length),
        4,
      );

      // Section 4: 4 groups x 2 = 8
      expect(
        SinkholeSectionDefinitions.appurtenant.fieldGroups
            .fold<int>(0, (sum, g) => sum + g.allFields.length),
        8,
      );

      // Section 5: 5 standalone
      expect(
        SinkholeSectionDefinitions.additionalInfo.fieldDefinitions.length,
        5,
      );

      // Section 6: 4 reps x 4 template = 16
      expect(
        SinkholeSectionDefinitions.scheduling.repeatingFieldGroups.first
            .totalFieldCount,
        16,
      );
    });
  });
}
