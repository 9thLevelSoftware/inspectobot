# Plan 09-02 Summary: Controller Cross-Form Capture Logic

## Status: Complete

## What Was Done
- Added `_markCrossFormCompletion()` private method to `InspectionSessionController` that handles both semantic equivalent sharing (e.g., exteriorFront <-> generalFrontElevation) and native sharing (e.g., roofSlopeMain used by fourPoint + roofCondition)
- Integrated the method into `capture()` — called after the primary completion marking and before `_notify()`
- The method: (a) looks up semantic equivalents via `EvidenceSharingMatrix.equivalentCategories()`, (b) looks up native shares via `EvidenceSharingMatrix.formsAcceptingCategoryFiltered()`, (c) marks the other form's requirement keys in the completion map, (d) copies photo paths to `capturedPhotoPaths`, `capturedCategories`, and `capturedEvidencePaths` so other forms' PDF generation can find the evidence
- Branch context conditions are respected: only requirements that pass their `branchContext` predicates (via `FormRequirements.forFormRequirements()`) are cross-marked
- Verified shared property data flow (INTEG-01b): all forms share the same `InspectionDraft` instance, so universal property fields are inherently shared; `PropertyData` correctly round-trips through `fromInspectionDraft` / `toInspectionDraft`

## Files Created
- `test/features/inspection/presentation/controllers/cross_form_capture_test.dart` — 8 cross-form capture unit tests
- `test/features/inspection/cross_form_property_data_test.dart` — 5 property data flow verification tests

## Files Modified
- `lib/features/inspection/presentation/controllers/inspection_session_controller.dart` — added `EvidenceSharingMatrix` import and `_markCrossFormCompletion()` method, integrated call into `capture()`

## Verification
- `flutter test test/features/inspection/presentation/controllers/cross_form_capture_test.dart` — 8/8 passed
- `flutter test test/features/inspection/cross_form_property_data_test.dart` — 5/5 passed
- `flutter test test/features/inspection/controllers/inspection_session_controller_test.dart` — 33/33 passed (no regressions)
- `flutter test test/features/inspection/presentation/controllers/inspection_session_controller_general_test.dart` — 7/7 passed (no regressions)
- `flutter analyze lib/features/inspection/presentation/controllers/` — no issues found

## Decisions Made
- **Single `_notify()` call**: The cross-form completion logic runs synchronously before the existing `_notify()` call in `capture()`, so no additional notification is needed — the UI sees all changes in one update cycle
- **Don't double-mark**: The method skips keys already set to `true` in the completion map, preventing redundant work when capturing from a form that already has the key satisfied
- **Branch context respected**: Uses `FormRequirements.forFormRequirements(form, branchContext:)` which filters out requirements whose predicates aren't met, so conditional requirements (like generalDeficiency requiring `general_safety_hazard=true`) aren't wrongly cross-marked
- **Multi-capture base key**: For semantic equivalents with `minimumCount > 1` (like generalDataPlate with min 2), the cross-form marking sets the base key. This satisfies at least 1 of the minimum count, which is the correct behavior for cross-form sharing (the inspector can capture additional instances for the other form separately)

## Issues
- None encountered
