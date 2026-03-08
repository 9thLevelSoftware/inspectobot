# Plan 09-04 Summary: Dashboard + Form Selection UI

## Status: Complete

## What Was Done
- Enhanced `InspectionCard` widget with optional `formSummaries` parameter that renders colored progress chips (green=100%, orange=50-99%, red=<50%) using `FormProgressChips` widget
- Extracted `FormProgressChips` as a reusable public widget for use across both `InspectionCard` and the dashboard's `_InspectionListCard`
- Wired `DashboardPage` to compute `FormProgressSummary` lists via `InspectionWizardState.buildFormSummaries()` for each inspection with meaningful wizard data, and pass them to `_InspectionListCard`
- Added category grouping to `NewInspectionPage` form selection: Core Inspections (4-Point, Roof, Wind), Specialized Inspections (WDO, Sinkhole), Narrative Reports (Mold, General)
- Added "Select All" / "Deselect All" toggle button above the categorized form list
- Wrote 6 new widget tests covering chips rendering, category headers, select/deselect all, and validation error on empty selection
- Updated 2 pre-existing tests that were affected by the layout change (deselect-all and subset selection)

## Files Created
- None

## Files Modified
- `lib/common/widgets/inspection_card.dart` — Added `formSummaries` parameter, `FormProgressChips` widget, `_ProgressChip` widget
- `lib/features/inspection/presentation/dashboard_page.dart` — Added `formSummaries` parameter to `_InspectionListCard`, computed summaries in ListView builder, rendered `FormProgressChips`
- `lib/features/inspection/presentation/new_inspection_page.dart` — Added `_formCategories` constant, category-grouped rendering with section headers, "Select All"/"Deselect All" toggle
- `test/common/widgets/inspection_card_test.dart` — Added 2 tests: chips rendering with 3 forms, no chips when null
- `test/features/inspection/new_inspection_page_test.dart` — Added 4 tests: category headers, Select All, Deselect All, deselect-all validation error; updated 2 pre-existing tests

## Verification
- `flutter test test/common/widgets/inspection_card_test.dart` — 11/11 passed
- `flutter test test/features/inspection/new_inspection_page_test.dart` — 14/14 passed
- `flutter test test/features/inspection/dashboard_page_test.dart` — 10/10 passed
- `flutter analyze` on all 3 modified source files — No issues found

## Decisions Made
- Created `FormProgressChips` as a standalone reusable widget (not private) so both `InspectionCard` and the dashboard's `_InspectionListCard` can use it without duplication
- Used `Palette.error` for the red chip color (<50%) since the tokens only expose `success`, `warning`, `info`, `disabled` — error is the appropriate semantic red
- Chip styling uses 20% alpha background with 50% alpha border for a subtle look consistent with the dark theme
- Dashboard only computes summaries when `snapshot.completion.isNotEmpty || snapshot.lastStepIndex > 0` to avoid showing empty chips for drafts
- Updated pre-existing tests to use the new "Deselect All" button rather than individually tapping each card, since category headers changed the scroll layout

## Issues
- Some pre-existing widget tests had flaky tap targeting due to FormTypeCards overlapping the stickyBottom "Continue" button. Fixed with `warnIfMissed: false` and `ensureVisible` calls.
