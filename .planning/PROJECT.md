# InspectoBot — UI/UX Overhaul

## What This Is

A comprehensive redesign of InspectoBot's presentation layer, replacing the current unstyled, bland UI with a dark-only, utilitarian/industrial design system inspired by construction management apps (PlanGrid, Fieldwire, Procore). The overhaul establishes a custom design token system wired into Material 3, decomposes the monolithic checklist page, and applies field-optimized UX across all 8 screens.

## Core Value

Inspectors can navigate and complete field workflows faster and with less cognitive load through a purpose-built, high-contrast interface designed for real-world conditions — bright sun, gloves, one-handed use, intermittent attention.

## Who It's For

Florida home insurance inspectors using the app on-site during property inspections. They work on roofs, in attics, under houses, and in bright outdoor conditions. The UI must prioritize readability, large touch targets, and quick scanning over aesthetic refinement.

## Requirements

### Validated
(None yet — ship to validate)

### Active

- **THEME-01**: Design Token System — Custom tokens (colors, spacing, radii, elevation, typography) in `lib/theme/` wired into Material 3 `ThemeData`. Dark-only palette with orange/yellow accents on dark surfaces.
- **THEME-02**: Reusable Component Library — Shared widgets (buttons, cards, form fields, status badges, section headers, loading/error states) built on design tokens.
- **UX-01**: Checklist Page Decomposition — Break 822-line `form_checklist_page.dart` monolith into distinct views: wizard navigation, evidence capture, PDF/delivery, audit timeline.
- **UX-02**: Field Usability Optimization — Large tap targets (min 48dp), one-handed reach zones, glove-friendly inputs, high contrast for outdoor/bright-sun readability.
- **UX-03**: Visual Hierarchy & Density — Section grouping, card elevation, status badges, progress indicators, typographic contrast for quick scanning.
- **UX-04**: Navigation System — Replace raw `MaterialPageRoute` with structured navigation (`go_router` or similar). Visual continuity and transitions between screens.
- **SCREEN-01**: Auth Screens Redesign — Apply design system to all 4 auth screens (sign in, sign up, forgot password, reset password). Extract shared form components.
- **SCREEN-02**: Dashboard Redesign — Status indicators, at-a-glance progress, inspection cards with visual state.
- **SCREEN-03**: New Inspection Page Redesign — Progressive disclosure, section grouping, improved form UX.
- **SCREEN-04**: Inspector Identity Page Redesign — Profile and signature UI refresh with design system.

### Out of Scope

- Backend or Supabase schema changes
- Business logic refactoring (repositories, domain layer)
- New features or workflows beyond what exists in v1.0
- Light mode (dark-only by design)
- State management migration (unless decomposition requires it)
- General-purpose narrative inspection reporting

## Constraints

- **Visual Direction**: Utilitarian/industrial. Dark surfaces, orange/yellow accents, card-based layouts, bold headers. Construction management app aesthetic (PlanGrid/Fieldwire/Procore reference).
- **Dark Mode Only**: No light mode. Token system designed for dark palette exclusively.
- **Field Conditions**: UI must remain usable in bright sunlight, with gloves, one-handed, on unstable surfaces. Minimum 48dp tap targets.
- **Dependencies**: Open to new packages that meaningfully accelerate results (icon sets, navigation, animations). No package for package's sake.
- **Test Preservation**: Existing 14,554 LOC test suite must continue passing. Widget tests will need updates as screens are refactored.
- **No Backend Changes**: All changes are presentation-layer only. Repository interfaces and domain models remain unchanged.
- **Incremental Delivery**: Each phase must leave the app in a working state. No "big bang" rewrites.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Dark-only, utilitarian/industrial direction | Inspectors work outdoors in bright conditions; high contrast dark UI improves readability and reduces glare | Pending |
| Custom token system + Material 3 | Gives full control over design language while leveraging Flutter's built-in theming. More structured than raw M3 customization alone | Pending |
| Construction management app reference (PlanGrid/Fieldwire/Procore) | Closest app category to field inspection tools; visual language will feel familiar to target users | Pending |
| Parallel tracks execution: tokens + checklist decomposition first | Checklist page is where real complexity lives; forces design system to earn its keep immediately rather than being built in a vacuum | Pending |
| All 8 screens in scope | Partial redesign creates inconsistency; complete overhaul ensures unified experience | Pending |
| Open to accelerator packages | Speed matters; packages like go_router, custom icon sets save significant implementation time | Pending |

## Architecture Influences

- **Existing pattern**: `lib/features/<name>/presentation/` convention for screens. Overhaul will add `lib/theme/` for tokens and `lib/common/widgets/` for shared components.
- **State management**: Currently vanilla `setState()`. Checklist decomposition may require introducing a lightweight state solution if prop-drilling becomes unmanageable.
- **Navigation**: `AppRoutes` class with named constants exists. Will be replaced or extended with a proper router package.
- **Testing**: High test-to-code ratio (78%). Widget tests will need systematic updates as screens change. New components need test coverage.

---
*Last updated: 2026-03-05 after initialization*
