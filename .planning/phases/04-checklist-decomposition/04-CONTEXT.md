# Phase 4: Checklist Page Decomposition -- Context

## Phase Goal
Break the 822-line monolithic `form_checklist_page.dart` into focused, navigable sub-views with a centralized controller for shared state.

## Requirements Covered
- UX-01: Checklist Page Decomposition — Break 822-line `form_checklist_page.dart` monolith into distinct views: wizard navigation, evidence capture, PDF/delivery, audit timeline.

## What Already Exists (from prior phases)

### Phase 1: Design Token System
- `lib/theme/app_theme.dart` — AppTheme.dark() factory with full ThemeData
- `lib/theme/` — Complete design token system (colors, spacing, typography, elevation, radii)

### Phase 2: Component Library
- `lib/common/widgets/` — 16 reusable component widgets with barrel export
- Key widgets: SectionHeader, SectionCard, StatusBadge, CompletionChip, AppProgressBar, AppButton, AppTextField, LoadingOverlay, ErrorBanner, EmptyState, SnackbarHelper, StatusCard, InspectionCard, etc.

### Phase 3: Navigation System
- go_router integrated with NavigationService abstraction + get_it service locator
- AuthNotifier replaces AuthGate for auth-gated routing
- FormChecklistPage receives InspectionDraft via GoRouter `extra`
- Full-screen flow (no bottom nav) at `/inspections/:id/checklist`
- 352+ tests passing

### Current Monolith State
- `lib/features/inspection/presentation/form_checklist_page.dart` (822 lines)
- 19 mutable state fields, 10 injected service dependencies
- Handles: wizard navigation, branch flags, evidence capture, PDF generation (cloud/on-device fallback), delivery (download/share), audit timeline, readiness evaluation
- `test/features/inspection/form_checklist_page_test.dart` (1,453 lines, 18 test cases)
- Complex mock patterns: _ChecklistStore, _FixedOutcomeCloudPdfService, _FakePendingMediaSyncStore, etc.

## Key Design Decisions
- **Architecture**: Proposal B (Clean) — InspectionSessionController + 4 sub-views + tab navigation
- **State management**: Plain Dart class controller (not ChangeNotifier/Provider/Riverpod) + parent setState
- **Navigation between sub-views**: SegmentedButton (M3) tab bar — field-friendly, flat navigation
- **Sub-view data flow**: Immutable params + callbacks (not InheritedWidget)
- **Shared widgets**: BranchFlagToggleTile + EvidenceRequirementCard extracted for reuse
- **EvidenceCaptureView**: Summary-only (form completion status); actual capture stays in WizardNavigationView

## Plan Structure
- **Plan 04-01 (Wave 1)**: Extract InspectionSessionController & Shared Widgets — controller with all business logic, 2 shared widgets, controller unit tests
- **Plan 04-02 (Wave 2)**: Build Sub-Views & Tab Navigation — 4 sub-views, sub-view widget tests
- **Plan 04-03 (Wave 2)**: Refactor Parent Page & Wire Sub-Views — thin orchestrator, callback wiring, router integration
- **Plan 04-04 (Wave 3)**: Test Decomposition & Coverage — decompose 1,453-line test file, shared helpers, integration tests
- **Plan 04-05 (Wave 3)**: Verification & Line Count Enforcement — constraint verification, final audit

## Spec Document
`.planning/specs/04-checklist-decomposition-spec.md` — Full specification with architecture, deliverables, service mapping, and complexity assessment.
