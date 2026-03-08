import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/form_requirements.dart';
import 'package:inspectobot/features/inspection/domain/wdo_section_definitions.dart';

void main() {
  group('WdoSectionDefinitions', () {
    test('defines exactly 5 sections', () {
      expect(WdoSectionDefinitions.all, hasLength(5));
    });

    test('section IDs match expected values', () {
      final ids = WdoSectionDefinitions.all.map((s) => s.id).toList();
      expect(ids, [
        'wdo_general_info',
        'wdo_findings',
        'wdo_inaccessible',
        'wdo_treatment',
        'wdo_comments',
      ]);
    });

    test('section titles match expected values', () {
      final titles = WdoSectionDefinitions.all.map((s) => s.title).toList();
      expect(titles, [
        'General Info',
        'Findings',
        'Inaccessible',
        'Treatment',
        'Comments',
      ]);
    });

    group('field counts per section', () {
      test('generalInfo has 12 fields', () {
        expect(
          WdoSectionDefinitions.generalInfo.fieldDefinitions,
          hasLength(12),
        );
      });

      test('findings has 4 fields', () {
        expect(
          WdoSectionDefinitions.findings.fieldDefinitions,
          hasLength(4),
        );
      });

      test('inaccessibleAreas has 10 fields', () {
        expect(
          WdoSectionDefinitions.inaccessibleAreas.fieldDefinitions,
          hasLength(10),
        );
      });

      test('treatment has 7 fields', () {
        expect(
          WdoSectionDefinitions.treatment.fieldDefinitions,
          hasLength(7),
        );
      });

      test('comments has 4 fields', () {
        expect(
          WdoSectionDefinitions.comments.fieldDefinitions,
          hasLength(4),
        );
      });
    });

    group('branch flag keys cross-reference FormRequirements', () {
      test('all branch flag keys exist in canonicalBranchFlags', () {
        final allBranchFlags = <String>{};
        for (final section in WdoSectionDefinitions.all) {
          allBranchFlags.addAll(section.branchFlagKeys);
        }

        for (final flag in allBranchFlags) {
          expect(
            FormRequirements.canonicalBranchFlags.contains(flag),
            isTrue,
            reason: 'Branch flag "$flag" not in canonicalBranchFlags',
          );
        }
      });

      test('findings uses the correct WDO branch flags', () {
        expect(WdoSectionDefinitions.findings.branchFlagKeys, [
          FormRequirements.wdoVisibleEvidenceBranchFlag,
          FormRequirements.wdoLiveWdoBranchFlag,
          FormRequirements.wdoEvidenceOfWdoBranchFlag,
          FormRequirements.wdoDamageByWdoBranchFlag,
        ]);
      });

      test('inaccessibleAreas uses the 5 inaccessible area flags', () {
        expect(WdoSectionDefinitions.inaccessibleAreas.branchFlagKeys, [
          FormRequirements.wdoAtticInaccessibleBranchFlag,
          FormRequirements.wdoInteriorInaccessibleBranchFlag,
          FormRequirements.wdoExteriorInaccessibleBranchFlag,
          FormRequirements.wdoCrawlspaceInaccessibleBranchFlag,
          FormRequirements.wdoOtherInaccessibleBranchFlag,
        ]);
      });

      test('treatment uses the 3 treatment flags', () {
        expect(WdoSectionDefinitions.treatment.branchFlagKeys, [
          FormRequirements.wdoPreviousTreatmentBranchFlag,
          FormRequirements.wdoTreatedAtInspectionBranchFlag,
          FormRequirements.wdoSpotTreatmentBranchFlag,
        ]);
      });
    });

    group('conditional fields reference valid branch flag keys', () {
      test('all conditionalOn values are valid canonical branch flags', () {
        for (final section in WdoSectionDefinitions.all) {
          for (final field in section.fieldDefinitions) {
            if (field.conditionalOn != null) {
              expect(
                FormRequirements.canonicalBranchFlags
                    .contains(field.conditionalOn),
                isTrue,
                reason: 'Field "${field.key}" conditionalOn '
                    '"${field.conditionalOn}" not in canonicalBranchFlags',
              );
            }
          }
        }
      });

      test('conditional fields are only visible when flag is true', () {
        final liveField = WdoSectionDefinitions.findings.fieldDefinitions
            .firstWhere((f) => f.key == 'find_live_description');

        expect(liveField.isVisible(const {}), isFalse);
        expect(
          liveField.isVisible(
            const {FormRequirements.wdoLiveWdoBranchFlag: true},
          ),
          isTrue,
        );
        expect(
          liveField.isVisible(
            const {FormRequirements.wdoLiveWdoBranchFlag: false},
          ),
          isFalse,
        );
      });
    });

    test('all field keys are unique across all sections', () {
      final allKeys = <String>{};
      for (final section in WdoSectionDefinitions.all) {
        for (final field in section.fieldDefinitions) {
          expect(
            allKeys.add(field.key),
            isTrue,
            reason: 'Duplicate field key: ${field.key}',
          );
        }
      }
    });

    test('total field count is 37', () {
      final totalFields = WdoSectionDefinitions.all.fold<int>(
        0,
        (sum, section) => sum + section.fieldDefinitions.length,
      );
      expect(totalFields, 37);
    });
  });
}
