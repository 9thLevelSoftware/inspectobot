# Plan 05-04 Summary: Integration -- SinkholeFormStep, Wizard Routing, Controller Wiring, E2E Tests

## Status: COMPLETE

## Files Created
- `lib/features/inspection/presentation/sub_views/sinkhole_form_step.dart` -- TabBar view composing 7 FormSectionUI panels (isScrollable: true)
- `test/features/inspection/presentation/sub_views/sinkhole_form_step_test.dart` -- 7 widget tests
- `test/features/inspection/sinkhole_integration_test.dart` -- 12 integration tests

## Files Modified
- `lib/features/inspection/presentation/sub_views/wizard_navigation_view.dart` -- Added sinkhole case to `_buildFormStepWidget` with same bounded height layout and branch toggle suppression pattern as WDO
- `lib/features/inspection/presentation/controllers/inspection_session_controller.dart` -- Added sinkhole form data extraction in `generatePdf()` using `SinkholeFormData.toPdfMaps()`, added `remapSinkholeSchedulingKeys()` static method for key format conversion

## Integration Approach
- **SinkholeFormStep**: Follows WdoFormStep pattern exactly. 7 tabs via scrollable TabBar, each tab renders FormSectionUI for the corresponding SinkholeSectionDefinitions section. Receives formData, branchContext, onFieldChanged, and onBranchFlagChanged callbacks.
- **Wizard routing**: `_buildFormStepWidget` in WizardNavigationView now handles `FormType.sinkholeInspection`. Same bounded height layout (Column + Expanded) as WDO. Branch toggle suppression applies -- FormSectionUI renders toggles per-section, so `_buildBranchInputControls` is skipped when form step widget is active.
- **Data flow**: User input -> FormSectionUI.onFieldChanged -> SinkholeFormStep callback -> WizardNavigationView.onFieldChanged -> FormChecklistPage -> controller.setFormFieldValue -> draft.formData[FormType.sinkholeInspection] updated -> setState() rebuild.

## Key Decision: Scheduling Key Remapping
The RepeatingFieldGroup generates keys like `attempt_1_Date`, `attempt_1_Time`, etc. (pattern: `{groupKey}_{index+1}_{templateKey}`). SinkholeFormData and the PDF field map use camelCase keys like `attempt1Date`, `attempt1Time`.

Resolution: Added `InspectionSessionController.remapSinkholeSchedulingKeys()` which uses a regex (`^attempt_(\d+)_(\w+)$`) to convert from the generated format to the camelCase format before constructing SinkholeFormData for PDF generation. Non-scheduling keys pass through unchanged. The raw formData in the draft stores the generated keys as-is (this is fine for persistence), and remapping only occurs at PDF generation time.

## PDF Generation Wiring
When `FormType.sinkholeInspection` is enabled:
1. Raw form data is extracted from `draft.formData[FormType.sinkholeInspection]`
2. Scheduling keys are remapped via `remapSinkholeSchedulingKeys()`
3. A `SinkholeFormData` instance is constructed via `fromJson()`
4. `toPdfMaps(branchContext: ...)` separates text fields into `fieldValues` and expands tri-state fields to 3 checkboxes each (`_yes`, `_no`, `_na`) in `checkboxValues`
5. Branch flags are merged into `checkboxValues`

## Test Results
- `sinkhole_form_step_test.dart`: 7/7 passed
- `sinkhole_integration_test.dart`: 12/12 passed
- Full suite: 839 passed, 12 failed (all 12 are pre-existing failures in router_config_test and design_token_audit_test -- unrelated)
- Static analysis: No issues found

## Risks / Issues
- **PDF map underscore convention mismatch**: SinkholeFormData.toPdfMaps() uses single underscore (`ext1Depression_yes`) while the PDF field map JSON uses double underscore (`ext1Depression__yes`). This mismatch needs to be resolved in the PDF resolver layer. Not blocking for this plan since PDF generation is stub-based, but must be fixed before production PDF filling.
- **Pre-existing test failures**: 12 tests in router_config_test.dart and design_token_audit_test.dart continue to fail (AppTokens ThemeExtension not registered). Not related to this plan.
