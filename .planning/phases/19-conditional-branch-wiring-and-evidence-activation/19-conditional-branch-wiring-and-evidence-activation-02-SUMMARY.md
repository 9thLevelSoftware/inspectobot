---
phase: 19-conditional-branch-wiring-and-evidence-activation
plan: 02
subsystem: inspection
tags: [flutter, branch-context, wizard, evidence, readiness, parity, widget-test]

# Dependency graph
requires:
  - phase: 19-01
    provides: "Branch flag constants, conditional predicate evaluation, canonicalization in FormRequirements and InspectionWizardState"
  - phase: 10-02
    provides: "Evidence requirement model with EvidencePredicate and branch-conditioned filtering"
provides:
  - "Live branch-input SwitchListTile controls in wizard checklist steps"
  - "Immediate snapshot update and readiness refresh when branch flags toggle"
  - "Integration tests proving setup→wizard→save→resume preserves branch context"
  - "Parity regression tests proving checklist and readiness use identical branch evaluation"
affects: [milestone-audit, report-generation]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Per-form branch flag mapping (_branchFlagsByForm) for step-scoped branch UI controls"
    - "scrollUntilVisible pattern for testing off-screen ListView content"

key-files:
  created: []
  modified:
    - "lib/features/inspection/presentation/form_checklist_page.dart"
    - "test/features/inspection/form_checklist_page_test.dart"
    - "test/features/inspection/report_readiness_test.dart"
    - "test/features/inspection/dashboard_page_test.dart"
    - "test/features/inspection/new_inspection_page_test.dart"

key-decisions:
  - "Branch controls render as SwitchListTile above requirement cards per step, keyed by branch flag"
  - "Branch flag mapping is form-scoped via static _branchFlagsByForm to show only relevant toggles per wizard step"
  - "Toggling branch flag immediately updates _snapshot.branchContext and calls _syncReadinessFromSnapshot, but does NOT persist until user taps Continue/Finish"
  - "Parity tests verify requirement key identity between readiness evaluate path and per-form checklist path"

patterns-established:
  - "Branch UI controls pattern: _branchFlagsByForm static map + _setBranchFlag + _buildBranchInputControls"
  - "Widget test scroll pattern: scrollUntilVisible for off-viewport ListView items"

requirements-completed: [FLOW-03, EVID-02, EVID-03, EVID-04]

# Metrics
duration: ~45min
completed: 2026-03-05
---

# Phase 19 Plan 02: Conditional Branch Wiring and Evidence Activation Summary

**Live branch-input SwitchListTile controls in wizard flow with save/resume persistence and checklist/readiness parity regression coverage**

## Performance

- **Duration:** ~45 min
- **Tasks:** 3
- **Files modified:** 5

## Accomplishments
- Inspectors can toggle hazard, roof-defect, and wind document-needed flags directly in checklist wizard steps via SwitchListTile controls
- Branch toggles immediately show/hide conditional evidence requirements in the same session without requiring save/resume
- Save→resume cycle preserves branch context and reactivates identical conditional requirements on resume
- Checklist step requirement keys and readiness evaluation keys are proven identical under all branch flag combinations

## Task Commits

Each task was committed atomically:

1. **Task 1: add live branch-input capture controls in wizard flow** - `14e68ce` (feat)
2. **Task 2: prove setup and resume preserve branch-driven conditional activation** - `3bf1a81` (test)
3. **Task 3: lock checklist/readiness parity for conditional evidence requirements** - `5e9835d` (test)

## Files Created/Modified
- `lib/features/inspection/presentation/form_checklist_page.dart` - Added _branchFlagsByForm, _branchFlagLabels, _setBranchFlag, _buildBranchInputControls; modified _buildStepContent to show branch controls above requirement cards
- `test/features/inspection/form_checklist_page_test.dart` - Added 4 new tests: toggle-on, toggle-off, save/resume cycle, checklist/readiness parity
- `test/features/inspection/dashboard_page_test.dart` - Added 1 new test: resume preserves branch context and activates conditional requirements
- `test/features/inspection/new_inspection_page_test.dart` - Added 1 new test + _BranchAwareSpyInspectionStore: roof form shows branch controls in checklist
- `test/features/inspection/report_readiness_test.dart` - Added 6 new parity regression tests: EVID-02 roof defect, EVID-04 wind permit, independent wind flags, key parity, exclusion parity, multi-form parity

## Decisions Made
- Used SwitchListTile with ValueKey('branch-flag-$flag') for testability and accessibility
- Branch flags are mapped per-form via static const to only show relevant toggles per wizard step (e.g., wind step shows only wind doc flags)
- Branch context persists to store only on Continue/Finish tap (not on every toggle) — matches existing progress save pattern
- Parity tests use FormRequirements.evaluate and FormRequirements.forFormRequirements side-by-side to prove key identity

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Missing FormType import in form_checklist_page.dart**
- **Found during:** Task 1
- **Issue:** `FormType` was not imported; needed for `_branchFlagsByForm` map
- **Fix:** Added `import '../domain/form_type.dart';`
- **Files modified:** lib/features/inspection/presentation/form_checklist_page.dart
- **Verification:** Compilation successful, all existing tests pass
- **Committed in:** 14e68ce (Task 1 commit)

**2. [Rule 1 - Bug] ListView virtualization hid Finish Wizard button in tests**
- **Found during:** Task 2
- **Issue:** "Finish Wizard" button was off-screen in test viewport (800x600) due to many requirement cards + branch controls; Flutter's lazy ListView didn't build the button widget
- **Fix:** Added `tester.scrollUntilVisible` before tapping the button; also redesigned test to pre-seed all requirements as complete with branch flag active
- **Files modified:** test/features/inspection/form_checklist_page_test.dart
- **Verification:** Test passes — branch context persisted and verified on resume
- **Committed in:** 3bf1a81 (Task 2 commit)

**3. [Rule 3 - Blocking] _SpyInspectionStore.updateWizardProgress throws in new_inspection_page_test**
- **Found during:** Task 2
- **Issue:** Tests that navigate into the checklist and trigger updateWizardProgress hit UnimplementedError in the spy store
- **Fix:** Created _BranchAwareSpyInspectionStore extending the spy with a working updateWizardProgress override
- **Files modified:** test/features/inspection/new_inspection_page_test.dart
- **Verification:** Test passes — branch controls visible when only roof condition form is selected
- **Committed in:** 3bf1a81 (Task 2 commit)

---

**Total deviations:** 3 auto-fixed (1 bug, 2 blocking)
**Impact on plan:** All auto-fixes necessary for test correctness. No scope creep.

## Issues Encountered
None beyond the auto-fixed deviations above.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- All EVID-02/EVID-03/EVID-04 conditional evidence requirements are now user-drivable through branch UI toggles
- FLOW-03 branch-input → conditional progression is fully wired and tested
- Ready for milestone audit verification or any remaining phase 19 plans

---
*Phase: 19-conditional-branch-wiring-and-evidence-activation*
*Plan: 02*
*Completed: 2026-03-05*
