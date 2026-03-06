---
phase: 20-pdf-mapping-completeness-and-identity-contract-reconciliation
plan: 01
subsystem: pdf
tags: [pdf-field-map, evidence-coverage, form-requirements, regression-test]

# Dependency graph
requires:
  - phase: 18-pdf-delivery-resilience-and-identity-contract-closure
    provides: "Pinned JSON field maps and allowlist validation in PdfTemplateAssetLoader"
  - phase: 19-conditional-branch-wiring-and-evidence-activation
    provides: "Canonical branch flags and conditional evidence requirements in FormRequirements"
provides:
  - "canonicalSourceKeysForForm(FormType) helper for per-form evidence key enumeration"
  - "Complete Four-Point field map with all 12 evidence source keys"
  - "Complete Wind Mitigation field map with all 10 evidence source keys"
  - "Coverage enforcement test preventing silent evidence key regression"
affects: [pdf-generation, evidence-capture, plan-02-identity-contract]

# Tech tracking
tech-stack:
  added: []
  patterns: ["Coverage enforcement test pattern: canonical keys vs pinned map source_key sets"]

key-files:
  created:
    - test/features/pdf/pdf_map_coverage_completeness_test.dart
  modified:
    - lib/features/inspection/domain/form_requirements.dart
    - assets/pdf/maps/insp4pt_03_25.v1.json
    - assets/pdf/maps/oir_b1_1802_rev_04_26.v1.json
    - test/features/pdf/on_device_pdf_service_test.dart

key-decisions:
  - "Coverage enforcement tests compare canonicalSourceKeysForForm against map source_key sets, not field key naming"
  - "Document evidence keys use image type fields in maps since documents are captured as images in-app"

patterns-established:
  - "Coverage enforcement: every canonical evidence source key must have at least one field entry in its form's pinned JSON map"
  - "Test fakes mirror real map structure per form type with oir_b1 branch in _FakeTemplateLoader"

requirements-completed: [PDF-02]

# Metrics
duration: 3min
completed: 2026-03-06
---

# Phase 20 Plan 01: PDF Map Coverage Completeness Summary

**Complete field maps for all three form types with coverage enforcement test preventing silent evidence key omission**

## Performance

- **Duration:** 3 min
- **Started:** 2026-03-06T01:55:17Z
- **Completed:** 2026-03-06T01:58:18Z
- **Tasks:** 2
- **Files modified:** 5

## Accomplishments
- Added `canonicalSourceKeysForForm(FormType)` static helper to FormRequirements for per-form evidence key enumeration
- Expanded Four-Point JSON field map from 1 to 12 evidence source keys (11 new checkbox+image pairs)
- Expanded Wind Mitigation JSON field map from 1 to 10 evidence source keys (9 new checkbox+image pairs)
- Created coverage enforcement test that asserts every canonical key has field entries in all three form maps
- Updated test fakes with complete map data and wind mitigation branch support

## Task Commits

Each task was committed atomically:

1. **Task 1: Add canonicalSourceKeysForForm helper and expand JSON field maps** - `febb162` (feat)
2. **Task 2: Add coverage enforcement test and update test fakes** - `1ab426a` (test)

## Files Created/Modified
- `lib/features/inspection/domain/form_requirements.dart` - Added canonicalSourceKeysForForm(FormType) static helper
- `assets/pdf/maps/insp4pt_03_25.v1.json` - Expanded from 5 fields to 27 fields covering all 12 evidence source keys
- `assets/pdf/maps/oir_b1_1802_rev_04_26.v1.json` - Expanded from 4 fields to 22 fields covering all 10 evidence source keys
- `test/features/pdf/pdf_map_coverage_completeness_test.dart` - New coverage enforcement test for all three form types
- `test/features/pdf/on_device_pdf_service_test.dart` - Expanded _fourPointMap, _roofMap fakes; added _windMap and oir_b1 branch

## Decisions Made
- Coverage enforcement tests compare `canonicalSourceKeysForForm` output against pinned map `source_key` sets — this catches omissions at the evidence level rather than field naming level
- Document evidence keys (`document:wind_*`) use `image` type fields in maps since documents are captured as photos in the app
- `rcf1_03_25.v1.json` was left unchanged — already 100% complete per research gap analysis

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- All three form maps now have 100% evidence source key coverage
- Coverage enforcement test will catch regressions if new evidence keys are added without map entries
- Plan 02 (identity contract reconciliation) can proceed — the `canonicalSourceKeysForForm` helper is available for downstream use

---
*Phase: 20-pdf-mapping-completeness-and-identity-contract-reconciliation*
*Completed: 2026-03-06*

## Self-Check: PASSED

- All 5 modified/created files verified on disk
- Commits febb162 and 1ab426a verified in git log
- All 30 PDF tests passing
