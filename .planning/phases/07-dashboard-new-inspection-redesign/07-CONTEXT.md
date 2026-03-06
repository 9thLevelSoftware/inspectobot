# Phase 7: Dashboard & New Inspection Redesign -- Context

## Phase Goal
Redesign the dashboard and new inspection pages with design system, status indicators, and improved form UX.

## Requirements Covered
- SCREEN-02: Dashboard Redesign — Status indicators, at-a-glance progress, inspection cards with visual state
- SCREEN-03: New Inspection Page Redesign — Progressive disclosure, section grouping, improved form UX

Note: REQUIREMENTS.md does not exist for this milestone cycle. Requirements are sourced from ROADMAP.md phase details.

## What Already Exists (from prior phases)

### Design Token System (Phase 1)
- `lib/theme/tokens.dart` — AppSpacing, AppRadii, AppElevation, AppFieldUsability
- `lib/theme/palette.dart` — Dark palette with orange primary (#F28C38), yellow secondary (#F2C744)
- `lib/theme/typography.dart` — Bumped type scale + custom styles (sectionTitle, fieldLabel, statusBadge, timestamp)
- `lib/theme/extensions.dart` — AppTokens ThemeExtension with semantic colors (success, warning, info, error, disabled)
- `lib/theme/app_theme.dart` — AppTheme.dark() factory
- `lib/theme/context_ext.dart` — BuildContext.appTokens extension

### Component Library (Phase 2)
- Buttons: `AppButton` (filled/outlined/text/icon variants, loading state, isThumbZone)
- Cards: `SectionCard` (density levels, leadingBadge), `StatusCard`, `InspectionCard`
- Form: `AppTextField`, `AppDropdown`, `AppCheckboxTile`, `AppDatePicker`, `SectionHeader`
- Status: `StatusBadge` (highContrast), `CompletionChip`, `ProgressBar`, `WizardProgressIndicator`
- Layout: `ReachZoneScaffold` (sticky bottom action area), `SectionGroup`
- Feedback: `ErrorBanner`, `LoadingOverlay`, `EmptyState`, `SnackbarHelper`

### Navigation System (Phase 3)
- `go_router` with `NavigationService` via GetIt service locator
- `AppRoutes` constants for all routes
- Auth-gated routing preserved

### Field Usability Patterns (Phase 5)
- 48dp min tap targets, 56dp thumb zone targets
- ReachZoneScaffold for sticky-bottom CTA placement
- StatusBadge highContrast mode for outdoor visibility
- SectionCard density levels (compact/normal/spacious)
- Typography: sectionTitle (24sp w700), subsectionTitle (18sp w600)

### Auth Screen Patterns (Phase 6)
- AuthFormScaffold pattern: ReachZoneScaffold + scrollable body + sticky action
- Token-based layout: AppSpacing.spacingMd between fields, zero hardcoded values
- ErrorBanner for inline feedback
- TextInputAction (next/done) for keyboard UX flow
- AutofillHints + AutofillGroup for browser/password manager support

### Current Dashboard Page
- `lib/features/inspection/presentation/dashboard_page.dart` (232 lines)
- StatefulWidget with FutureBuilder for async inspection list
- Flat column layout, no status indicators, no empty state
- Two action buttons: "New Inspection" + "Inspector Identity"
- In-progress inspection cards with client name, address, resume button

### Current New Inspection Page
- `lib/features/inspection/presentation/new_inspection_page.dart` (277 lines)
- 6 TextFormField inputs (client name, email, phone, address, date, year built)
- CheckboxListTile per FormType (no descriptions, wall-of-fields layout)
- Custom validators per field type (email regex, date range, year range)
- Saves InspectionSetup and navigates to checklist

### Domain Models
- `FormType` enum: fourPoint, roofCondition, windMitigation (with code + label)
- `InspectionSetup`: immutable value object for initial inspection data
- `InspectionDraft`: mutable working state for inspection wizard
- `InspectionWizardState`: stateless wizard logic with WizardProgressSnapshot
- `WizardProgressStatus`: inProgress, complete

### Existing Tests
- `test/features/inspection/dashboard_page_test.dart` — 3 tests (navigation, sync, resume)
- `test/features/inspection/new_inspection_page_test.dart` — 4 tests (validation, form labels, submit)

## Key Design Decisions
- **Architecture proposals**: Skipped by user (established patterns from Phase 5-6 apply directly)
- **Spec pipeline**: Run — spec document at `.planning/specs/07-dashboard-new-inspection-redesign-spec.md`
- **Wave structure**: Wave 1 = parallel screen rewrites, Wave 2 = test updates (tests depend on screen changes)
- **Agent choice**: engineering-mobile-app-builder for Flutter screen work, testing-evidence-collector for widget tests
- **Progressive disclosure**: ExpansionTile with design token theming (built-in Flutter, accessible, themeable)
- **Status mapping**: Presentation-layer only — derive from WizardProgressSnapshot status (no backend changes)
- **Form type cards**: Visual cards with descriptions replacing plain CheckboxListTile

## Plan Structure
- **Plan 07-01 (Wave 1)**: Dashboard Page Redesign — status cards, metrics summary, empty state
- **Plan 07-02 (Wave 1)**: New Inspection Form Redesign — section grouping, progressive disclosure, form type cards
- **Plan 07-03 (Wave 2)**: Dashboard Widget Tests — update existing + add coverage for new features
- **Plan 07-04 (Wave 2)**: New Inspection Widget Tests — update existing + add progressive disclosure tests
