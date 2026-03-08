# Plan 10-02 Summary: Migration Validation Tests

## Status: Complete

## Tests Created/Updated

### 1. `test/features/inspection/domain/migration_validation_test.dart` (28 tests)
**Pre-existing file, augmented with 3 new tests:**
- `InspectionDraft with formData for new form types works` — verifies Draft construction with WDO/Sinkhole/Mold/General form data and conversion to PropertyData
- `legacy JSON with only original 3 form types deserializes correctly` — simulates pre-Phase 3 JSON payload through PropertyData.fromJson
- `legacy JSON round-trip: fromJson → toJson → fromJson preserves all data` — full round-trip of legacy payload including wizard snapshot, shared fields, media state

**Existing coverage (25 tests):**
- InspectionDraft backward compatibility (defaults, enabledForms, media collections)
- InspectionDraft → PropertyData migration path (field mapping, media transfer, formData transfer)
- PropertyData round-trips (Draft → PD → JSON → PD → Draft)
- PropertyData fromJson with legacy-shaped JSON (missing fields, unknown codes)
- WizardProgressSnapshot with legacy step definitions (original keys, all 7 form types, mixed old+new)

### 2. `test/features/inspection/domain/property_data_migration_test.dart` (26 tests)
**Pre-existing file, augmented with 6 new tests:**
- `SharedBuildingSystemFields: all fields populated survive toJson → fromJson` — full round-trip with all 13 fields including RatingScale
- `SharedBuildingSystemFields: empty toJson produces empty map` — verifies null-omission behavior
- `SharedBuildingSystemFields: equality` — verifies == operator
- `PropertyData combined media + all form data round-trip` — comprehensive test with all 7 form namespaces, media categories from all forms, wizard snapshot, shared fields with RatingScale, inspector signature path, and comments

**Existing coverage (22 tests):**
- Migration v1 passthrough/forward compat
- Missing optional field defaults
- All 7 form type namespace round-trips
- Form namespace isolation (WDO/Sinkhole)
- branchContext prefix correctness
- Shared field accessibility, empty PropertyData edge case
- setFormValues batch update, media state round-trip

### 3. `test/features/inspection/domain/requirements_compat_test.dart` (51 tests)
**Pre-existing file, augmented with 21 new tests:**
- WDO conditional photos with branch flags (infestation evidence, damage area)
- WDO compound inaccessible area predicate (all 5 flags individually tested)
- WDO inaccessible area absent without flags
- Sinkhole checklist photos with compound anySinkholeYes (all 4 section flags)
- Sinkhole checklist minimumCount = 2
- Sinkhole garage crack and adjacent structure conditional tests
- Mold moisture source photo, lab report document conditionals
- Mold conditional absence without flags
- General deficiency photo conditional (present/absent)
- General data_plate minimumCount = 2
- canonicalSourceKeysForForm coverage (all forms)
- canonicalSourceKeys global coverage
- canonicalSourceKeysForForm includes conditional requirements

**Existing coverage (30 tests):**
- Original 3 form types baseline/conditional evidence rules
- New 4 form types well-formedness (non-empty, unique keys, categories)
- Branch flags coverage (all 7 forms in branchFlagsByForm, labels, original 3)
- Cross-form evaluate (original 3, mixed old+new, all 7)
- WizardProgressSnapshot compatibility (original keys, new keys, step ordering, completeness)
- FormType code round-trip, fromCodes, uniqueness

## Migration Edge Cases Discovered
- **No breaking backward compat issues found.** All existing test patterns passed without modification.
- PropertyData.fromJson gracefully handles unknown form codes (both in enabled_forms and form_data) via try/catch on ArgumentError.
- SharedBuildingSystemFields.toJson correctly omits null fields, preventing legacy payloads from growing unnecessarily.
- WDO inaccessible area uses a compound OR predicate across 5 flags — all individually validated.

## Backward Compatibility Issues Found and Fixed
None. The existing data model handles legacy payloads correctly through:
1. Optional field defaults in PropertyData.fromJson
2. ArgumentError catch for unknown FormType codes
3. PropertyDataMigrations passthrough for v1 and forward versions

## Test Counts
| File | Total Tests | New Tests Added |
|------|------------|-----------------|
| migration_validation_test.dart | 28 | 3 |
| property_data_migration_test.dart | 26 | 6 |
| requirements_compat_test.dart | 51 | 21 |
| **Total** | **105** | **30** |

## Verification Commands
```bash
flutter test test/features/inspection/domain/migration_validation_test.dart
flutter test test/features/inspection/domain/property_data_migration_test.dart
flutter test test/features/inspection/domain/requirements_compat_test.dart
```
