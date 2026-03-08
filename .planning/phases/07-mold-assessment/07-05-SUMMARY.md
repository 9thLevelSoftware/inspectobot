# Plan 07-05 Summary: Integration Tests + Compliance Validation

## Status: Complete with Warnings

Pre-existing test failures (12) and analyzer warnings (2) documented below. All new Phase 7 tests pass.

## Files Created

| File | Lines | Purpose |
|------|-------|---------|
| `test/features/inspection/mold_integration_test.dart` | 212 | End-to-end MoldFormData integration tests |
| `test/features/inspection/domain/mold_compliance_integration_test.dart` | 283 | MoldComplianceValidator integration tests |

## Test Inventory

### mold_integration_test.dart (13 tests, 13 passed)

| # | Test Name | Result |
|---|-----------|--------|
| 1 | toFormDataMap() keys exactly match MoldAssessmentTemplate.referencedFormDataKeys | PASS |
| 2 | template referencedFormDataKeys contains exactly 6 keys | PASS |
| 3 | MoldFormData survives JSON encode/decode round-trip | PASS |
| 4 | draft stored in parent map round-trips correctly | PASS |
| 5 | MoldFormData.empty() toFormDataMap returns empty strings | PASS |
| 6 | empty form produces no null values in toFormDataMap | PASS |
| 7 | flags set to true survive toJson/fromJson | PASS |
| 8 | flags set to false survive toJson/fromJson | PASS |
| 9 | mixed flag states survive round-trip | PASS |
| 10 | toFormDataMap produces map usable as PDF formData input | PASS |
| 11 | toFormDataMap values are String type for PDF engine | PASS |
| 12 | only some fields filled returns empty strings for unfilled (no nulls) | PASS |
| 13 | single field filled still produces all 6 keys | PASS |

### mold_compliance_integration_test.dart (18 tests, 18 passed)

| # | Test Name | Result |
|---|-----------|--------|
| 1 | fully compliant form passes all checks | PASS |
| 2 | missing MRSA license fails compliance | PASS |
| 3 | empty scope of assessment fails | PASS |
| 4 | empty visual observations fails | PASS |
| 5 | empty moisture sources fails | PASS |
| 6 | empty mold type/location fails | PASS |
| 7 | remediation recommended + empty recommendations fails | PASS |
| 8 | remediation recommended + filled recommendations passes | PASS |
| 9 | remediation not recommended + empty recommendations passes | PASS |
| 10 | all zero photo counts → 3 photo failures | PASS |
| 11 | partial photos → only missing categories fail | PASS |
| 12 | all categories >= 1 → passes photo checks | PASS |
| 13 | empty photoCounts map fails all 3 photo checks | PASS |
| 14 | multiple missing items are all listed (9 failures) | PASS |
| 15 | empty additional findings produces warning | PASS |
| 16 | mold growth evidence present but no remediation recommended → warning | PASS |
| 17 | no mold growth evidence + no remediation → no remediation warning | PASS |
| 18 | only warnings with no failures → isCompliant is still true | PASS |

## Key Alignment Verification

MoldFormData.toFormDataMap() keys exactly match MoldAssessmentTemplate.referencedFormDataKeys:

| formData Key | Template References | Aligned |
|-------------|-------------------|---------|
| `scope_of_assessment` | NarrativeParagraphSection bodyKey | Yes |
| `visual_observations` | NarrativeParagraphSection bodyKey | Yes |
| `moisture_sources` | NarrativeParagraphSection bodyKey | Yes |
| `mold_type_location` | NarrativeParagraphSection bodyKey | Yes |
| `remediation_recommendations` | NarrativeParagraphSection bodyKey | Yes |
| `additional_findings` | NarrativeParagraphSection bodyKey | Yes |

## Compliance Check Coverage Matrix

| Check | Validator Rule | Test Coverage |
|-------|---------------|---------------|
| MRSA license | Check 1 | Tests 2, 14 |
| Scope of assessment | Check 2 | Tests 3, 14 |
| Visual observations | Check 3 | Tests 4, 14 |
| Moisture sources | Check 4 | Tests 5, 14 |
| Mold type/location | Check 5 | Tests 6, 14 |
| Remediation conditional | Check 6 | Tests 7, 8, 9, 14 |
| Moisture readings photo | Check 7 | Tests 10, 11, 12, 13, 14 |
| Mold growth photo | Check 8 | Tests 10, 11, 12, 13, 14 |
| Affected areas photo | Check 9 | Tests 10, 11, 12, 13, 14 |
| Additional findings warning | Warning 1 | Tests 15, 18 |
| Remediation warning | Warning 2 | Tests 16, 17, 18 |

## Full Suite Test Results

- **Total**: 1041 passed, 12 failed (pre-existing)
- **New Phase 7 tests**: 31 passed, 0 failed
- **Analyzer**: 2 warnings (pre-existing, in `narrative_media_resolver.dart`)

### Pre-existing Failures (12)

All 12 failures are in `router_config_test.dart` and `dashboard_page_test.dart`, caused by missing `AppTokens` ThemeExtension in test harness setup. These are unrelated to Phase 7 work.

### Pre-existing Analyzer Warnings (2)

Both in `lib/features/pdf/narrative/narrative_media_resolver.dart:119` — dead code and dead null-aware expression. Unrelated to Phase 7.

## Files Modified

None. No `lib/` files were modified (test-only plan).
