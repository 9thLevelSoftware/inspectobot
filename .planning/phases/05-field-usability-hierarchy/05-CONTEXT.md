# Phase 5: Field Usability & Visual Hierarchy -- Context

## Phase Goal
Apply field-optimized UX patterns and visual hierarchy across all decomposed checklist views and shared components. Create reusable layout primitives (ReachZoneScaffold, SectionGroup, WizardProgressIndicator) and enforce 48dp tap targets, WCAG AAA contrast, and one-handed reach zones.

## Requirements Covered
- UX-02: Field Usability Optimization — Large tap targets (min 48dp), one-handed reach zones, glove-friendly inputs, high contrast for outdoor/bright-sun readability.
- UX-03: Visual Hierarchy & Density — Section grouping, card elevation, status badges, progress indicators, typographic contrast for quick scanning.

## What Already Exists (from prior phases)

### Phase 1: Design Token System
- `lib/theme/tokens.dart` — AppSpacing (4dp grid, 2-48dp), AppEdgeInsets, AppRadii, AppElevation
- `lib/theme/typography.dart` — Full M3 type scale + 4 semantic helpers (sectionHeader, fieldLabel, statusBadge, timestamp)
- `lib/theme/palette.dart` — 29 color constants (dark surfaces, orange primary, yellow secondary, semantic colors)
- `lib/theme/app_theme.dart` — Complete ThemeData with 20+ component themes

### Phase 2: Component Library
- `lib/common/widgets/` — 17 reusable widgets with barrel export
- Key widgets: AppButton (48dp min height), StatusBadge (5 semantic types), AppProgressBar (linear/circular), SectionCard, SectionHeader, CompletionChip

### Phase 3: Navigation System
- go_router + NavigationService + get_it service locator
- AuthNotifier for auth-gated routing
- FormChecklistPage receives InspectionDraft via GoRouter `extra`

### Phase 4: Checklist Decomposition
- FormChecklistPage (269 lines) — thin orchestrator with SegmentedButton tabs
- InspectionSessionController (608 lines) — pure Dart controller with all business logic
- 4 sub-views: WizardNavigationView (121), EvidenceCaptureView (57), PdfDeliveryView (87), AuditTimelineView (87)
- 2 shared widgets: EvidenceRequirementCard (50), BranchFlagToggleTile (37)
- 450+ tests passing

## Architecture Approach
**Clean approach** — Systematic abstractions with proper layout primitives:
- ReachZoneScaffold: Bottom-anchored action bar for thumb-zone ergonomics
- SectionGroup: Consistent section grouping with dividers and spacing
- WizardProgressIndicator: Step progress with percentage for field visibility
- ContrastHelpers: WCAG luminance ratio calculation utility
- Enhanced existing widgets: StatusBadge (high-contrast mode), AppButton (thumb-zone sizing), SectionCard (density)
- New typography semantic styles: sectionTitle, subsectionTitle, fieldValue, fieldLabelRequired

## Key Design Decisions
- **Layout primitives over wrappers**: ReachZoneScaffold and SectionGroup are composable widgets, not wrapper layers
- **Enhance existing widgets**: StatusBadge, AppButton, SectionCard get new parameters rather than creating duplicates
- **Controller stays pure Dart**: completionPercent getter added to InspectionSessionController without Flutter imports
- **Bottom-anchored actions**: ReachZoneScaffold enforces primary actions in thumb zone (bottom 40% of viewport)
- **FormChecklistPage restructured**: Changed from ListView body to Column+Expanded to provide bounded height for active view (required for ReachZoneScaffold's Expanded child)
- **Binary StatusBadge on evidence cards**: Complete/Missing only — domain model has no required-vs-optional distinction (all visible requirements are required)
- **completionPercent uses wizardState.steps as denominator**: NOT snapshot.completion.length (which only contains captured entries)
- **EvidenceCaptureView uses FormProgressSummary**: Actual model API (form.label, missingRequirements, isComplete) — no capturedCount/totalCount fields
- **WCAG thresholds per text size**: AAA normal (7.0:1) for body text, AAA large (4.5:1) for badges/buttons/headers, AA (4.5:1) for secondary text
- **Palette fixes for contrast failures**: onError/error and possibly primary/surface need adjustment
- **Token-driven everything**: All new spacing, sizing, and typography use design tokens exclusively

## Critique Findings (applied to plans)
Pre-mortem and assumption hunting identified 6 issues, all fixed:
1. ReachZoneScaffold inside ListView → crash → FormChecklistPage restructured to Column+Expanded
2. completionPercent wrong denominator → fixed to use wizardState.steps total
3. WCAG contrast failures (onError/error ~3.38:1) → Plan 05-04 calculates and fixes palette
4. EvidenceRequirement.isRequired is a Function → simplified to binary Complete/Missing
5. FormCompletionSummary doesn't exist → uses actual FormProgressSummary API
6. Wave dependency: 05-02 needs 05-01 tokens → 05-02 now depends_on: ["05-01"]

## Plan Structure (4 plans, 4 waves — sequential)
- **Plan 05-01 (Wave 1)**: Token Extensions, Typography & Layout Primitives — tokens, typography, ReachZoneScaffold, SectionGroup, ContrastHelpers
- **Plan 05-02 (Wave 2)**: Widget Enhancements — WizardProgressIndicator, StatusBadge high-contrast, AppButton thumb-zone (both ConstrainedBox), SectionCard density, controller completionPercent
- **Plan 05-03 (Wave 3)**: Screen Integration — Restructure FormChecklistPage (Column+Expanded), apply all primitives across 4 sub-views + 2 shared widgets
- **Plan 05-04 (Wave 4)**: Verification & Contrast Audit — Palette fixes, WCAG tests, tap target sweep, typography verification, full suite pass
