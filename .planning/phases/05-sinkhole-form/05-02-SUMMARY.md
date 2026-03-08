# Plan 05-02 Summary: UI Widgets

## Status: COMPLETE

## Files Created
- `lib/common/widgets/tri_state_chip_group.dart` -- TriStateChipGroup widget (3 ChoiceChips for Yes/No/N/A selection)
- `lib/common/widgets/repeating_group_card.dart` -- RepeatingGroupCard widget (Card with labeled header + divider for repetition groups)
- `test/common/widgets/tri_state_chip_group_test.dart` -- 7 tests
- `test/common/widgets/repeating_group_card_test.dart` -- 3 tests

## Files Modified
- `lib/common/widgets/widgets.dart` -- Added exports for tri_state_chip_group.dart and repeating_group_card.dart
- `lib/features/inspection/presentation/widgets/form_field_input.dart` -- Replaced UnimplementedError placeholder with TriStateChipGroup rendering for FieldType.triState
- `lib/features/inspection/presentation/widgets/form_section_ui.dart` -- Added FieldGroup and RepeatingFieldGroup rendering after standalone fields; fixed field source to use standalone fieldDefinitions only (not section.visibleFields which includes group fields)
- `test/features/inspection/presentation/widgets/form_field_input_test.dart` -- Added 2 tests for triState rendering and onChanged
- `test/features/inspection/presentation/widgets/form_section_ui_test.dart` -- Added 7 tests for FieldGroup visibility, RepeatingFieldGroup iteration, indexed keys, backward compat

## Implementation Decisions

1. **TriStateChipGroup design**: Uses `ChoiceChip` (not `FilterChip`) since this is single-select. Selected chip uses `Palette.primary` directly for high-contrast orange; unselected uses `colorScheme.surfaceContainerHigh`. Tapping selected chip deselects to null.

2. **RepeatingGroupCard styling**: Minimal Card with header text + Divider separator. Uses `tokens.sectionHeader` for the header style and `tokens.spacingLg` for padding, consistent with existing SectionCard patterns.

3. **FormSectionUI rendering order**: Branch toggles -> standalone fieldDefinitions -> FieldGroups -> RepeatingFieldGroups. Critical fix: standalone fields are filtered from `section.fieldDefinitions` directly (not `section.visibleFields()`) to avoid double-rendering fields that also appear in FieldGroups or RepeatingFieldGroups.

4. **RepeatingFieldGroup key remapping**: Each repeating template field's `onChanged` callback remaps the template field key to the concrete indexed key (`attempt_1_date` etc.) before calling `onFieldChanged`. The template's original key is used only for rendering; the concrete key is used for data storage.

5. **Widget keys**: FieldGroup and RepeatingFieldGroup FormFieldInput instances use `ValueKey` prefixed with `fg_` or `rg_` respectively to ensure Flutter can correctly differentiate them during rebuilds.

## Test Results
- 19 new tests: ALL PASSED
- Full suite: 804 total, 792 passed, 12 failed (all 12 are pre-existing failures in router_config_test and design_token_audit_test -- unrelated to this plan)
- Static analysis: No issues found

## Risks / Issues
- **Pre-existing test failures**: 12 tests in router_config_test.dart (AppTokens ThemeExtension not registered) and design_token_audit_test.dart continue to fail. Not related to this plan.
- **FieldGroup visibility uses formValues, not branchContext**: By design (per 05-01), FieldGroup.visibleFields checks `formValues[triggerField.key]` for string equality. This is distinct from section-level conditional visibility which uses `branchContext`. Callers must ensure the trigger field value flows through `formValues`.
