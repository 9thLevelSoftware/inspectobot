# Plan 05-01 Summary: Domain Abstractions

## Status: COMPLETE

## Files Created
- `lib/features/inspection/domain/field_group.dart` -- FieldGroup composite type (trigger + dependent fields with visibility logic)
- `lib/features/inspection/domain/repeating_field_group.dart` -- RepeatingFieldGroup for fixed-repetition field templates (e.g., scheduling attempts)
- `lib/features/inspection/domain/sinkhole_form_data.dart` -- SinkholeFormData typed class with 67 fields, toJson/fromJson/copyWith/toPdfMaps/withDefaults
- `test/features/inspection/domain/field_group_test.dart` -- 9 tests
- `test/features/inspection/domain/repeating_field_group_test.dart` -- 6 tests
- `test/features/inspection/domain/sinkhole_form_data_test.dart` -- 17 tests

## Files Modified
- `lib/features/inspection/domain/field_type.dart` -- Added `triState` enum value
- `lib/features/inspection/presentation/widgets/form_field_input.dart` -- Added `triState` case with UnimplementedError placeholder (B1 mitigation)
- `lib/features/inspection/domain/form_section_definition.dart` -- Added `fieldGroups` and `repeatingFieldGroups` optional params; extended `visibleFields()` and `countIncomplete()` to include composite groups; added `==`/`hashCode`
- `lib/features/inspection/domain/form_requirements.dart` -- Added `anySinkholeYes()` static predicate; updated `photo:sinkhole_checklist_item` evidence requirement to use it
- `test/features/inspection/domain/form_section_definition_test.dart` -- Added 11 tests for FieldGroup/RepeatingFieldGroup integration, backward compat, equality
- `test/features/inspection/domain/form_requirements_extended_test.dart` -- Updated sinkhole checklist tests for `anySinkholeYes` predicate; added 2 new tests

## Implementation Decisions

1. **FieldGroup visibility**: FieldGroup owns ALL intra-group visibility via `formValues[triggerField.key] == triggerValue`. Dependent fields must NOT use `conditionalOn`. This is by design (B2 mitigation).

2. **RepeatingFieldGroup key format**: `{groupKey}_{index+1}_{templateKey}` (1-indexed). Example: `attempt_1_date`, `attempt_4_result`.

3. **SinkholeFormData toPdfMaps**: Tri-state fields expand to 3 checkboxes (`{key}_yes`, `{key}_no`, `{key}_na`) in `checkboxValues`. Text/detail fields go to `fieldValues`. Branch flags filtered to canonical sinkhole set only.

4. **anySinkholeYes predicate**: Checks the 4 individual section flags (exterior, interior, garage, appurtenant) rather than the aggregate `sinkhole_any_yes` flag. This enables the evidence requirement to trigger from any section independently without requiring the controller to maintain the aggregate flag separately.

5. **FormSectionDefinition backward compatibility**: New `fieldGroups` and `repeatingFieldGroups` params default to empty lists. Existing sections without groups work identically to before.

## Test Results
- 62 new/modified tests: ALL PASSED
- Full suite: 785 passed, 12 failed (all 12 are pre-existing failures in router_config_test and design_token_audit_test -- unrelated to this plan)
- Static analysis: No issues found

## Risks / Issues
- **FieldDefinition lacks `==`/`hashCode`**: FieldDefinition uses identity-based equality. This is fine for `const` definitions (the pattern used throughout the codebase) but could cause unexpected behavior if non-const instances are compared. Not blocking for this plan.
- The 12 pre-existing test failures should be investigated separately (AppTokens ThemeExtension not registered in test widget tree, design_token_audit hardcoded Colors detection).
