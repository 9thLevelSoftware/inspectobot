# Plan 05-03 Summary: Section Definitions + PDF Assets

## Status: COMPLETE

## Files Created
- `lib/features/inspection/domain/sinkhole_section_definitions.dart` -- SinkholeSectionDefinitions with 7 sections, FieldGroup composites, RepeatingFieldGroup for scheduling
- `assets/pdf/templates/sinkhole_inspection.pdf` -- Stub PDF template (copy of existing stub)
- `assets/pdf/maps/sinkhole_inspection.v1.json` -- Field map with 67 text fields, 57 tri-state checkboxes, 8 branch flag checkboxes, 5 image entries, 1 signature entry
- `test/features/inspection/domain/sinkhole_section_definitions_test.dart` -- 16 tests

## Files Modified
- `lib/features/pdf/models/pdf_template_manifest.dart` -- Added sinkholeInspection entry (Citizens Sinkhole v2 Ed. 6/2012)
- `lib/features/pdf/data/pdf_template_asset_loader.dart` -- Added sinkholeFormFieldSourceKeys (120 keys) to allowlist
- `test/features/pdf/pdf_template_manifest_test.dart` -- Added sinkholeInspection to key set assertion, verified entry paths and revision label, added sinkhole map to allowlist compatibility test

## Section Field Counts
| Section | ID | Standalone | FieldGroups | RepeatingFieldGroup | Total |
|---------|----|-----------|-------------|---------------------|-------|
| 0 Property ID | sinkhole_property_id | 8 | 0 | 0 | 8 |
| 1 Exterior | sinkhole_exterior | 0 | 5 x 2 = 10 | 0 | 10 |
| 2 Interior | sinkhole_interior | 0 | 8 x 2 = 16 | 0 | 16 |
| 3 Garage | sinkhole_garage | 0 | 2 x 2 = 4 | 0 | 4 |
| 4 Appurtenant | sinkhole_appurtenant | 0 | 4 x 2 = 8 | 0 | 8 |
| 5 Additional | sinkhole_additional | 5 | 0 | 0 | 5 |
| 6 Scheduling | sinkhole_scheduling | 0 | 0 | 4 x 4 = 16 | 16 |
| **Total** | | **13** | **38** | **16** | **67** |

## Implementation Decisions

1. **RepeatingFieldGroup key format vs SinkholeFormData keys**: The RepeatingFieldGroup generates keys using `{groupKey}_{index+1}_{templateKey}` (e.g., `attempt_1_Date`), which differs from SinkholeFormData's camelCase keys (`attempt1Date`). This is intentional -- the RepeatingFieldGroup provides structural/rendering information, while SinkholeFormData keys are the serialization keys. The key mapping between these two systems will be handled in the controller layer (Plan 05-04).

2. **sinkholeAnyYesBranchFlag excluded from additionalInfo section**: Per plan, this is now a computed predicate (`FormRequirements.anySinkholeYes`) rather than a user-toggled branch flag. It is NOT included in section 5's `branchFlagKeys`.

3. **PDF field map source keys use double underscore**: Tri-state checkboxes use `{fieldKey}__yes`, `{fieldKey}__no`, `{fieldKey}__na` (double underscore) matching the `toPdfMaps()` pattern in SinkholeFormData which uses `_yes`, `_no`, `_na` (single underscore). The field map uses double underscore to distinguish from field key substrings. This needs to be reconciled in the PDF resolver (Plan 05-04).

4. **totalFieldCount helper**: Added a static `totalFieldCount` getter on SinkholeSectionDefinitions that sums standalone + fieldGroup + repeatingFieldGroup concrete fields. This enables the test to verify the 67-field total matches SinkholeFormData.fieldKeys.length.

5. **Allowlist surface**: Added 120 sinkhole source keys to PdfTemplateAssetLoader (8 property ID text + 19 detail text + 57 tri-state checkboxes + 5 additional text + 16 scheduling text + 8 branch flags + 5 photo keys + 1 signature = 119 unique, plus inspector_signature shared).

## Test Results
- 16 new section definition tests: ALL PASSED
- 7 PDF manifest tests: ALL PASSED (including updated allowlist compatibility)
- Full suite: 820 passed, 12 failed (all 12 are pre-existing failures -- same as Plan 05-01)
- Static analysis: No issues found

## Risks / Issues
- **Key format mismatch**: RepeatingFieldGroup's `allFieldKeys` generates `attempt_1_Date` etc., while SinkholeFormData uses `attempt1Date`. The "no duplicate field keys" test passes because both formats are internally consistent, but the controller/renderer will need a key mapping strategy in Plan 05-04.
- **toPdfMaps underscore convention**: SinkholeFormData.toPdfMaps() uses single underscore (`ext1Depression_yes`) while the field map JSON uses double underscore (`ext1Depression__yes`). This mismatch must be resolved in the PDF resolver layer. Flagging for Plan 05-04.
