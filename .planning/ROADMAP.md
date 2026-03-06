# InspectoBot UI/UX Overhaul — Roadmap

## Phases

- [x] Phase 1: Design Token System & Theme Foundation (THEME-01)
- [x] Phase 2: Reusable Component Library (THEME-02)
- [x] Phase 3: Navigation System & App Shell (UX-04)
- [x] Phase 4: Checklist Page Decomposition (UX-01)
- [x] Phase 5: Field Usability & Visual Hierarchy (UX-02, UX-03)
- [ ] Phase 6: Auth Screens Redesign (SCREEN-01)
- [x] Phase 7: Dashboard & New Inspection Redesign (SCREEN-02, SCREEN-03)
- [ ] Phase 8: Inspector Identity & Final Polish (SCREEN-04)

## Phase Details

### Phase 1: Design Token System & Theme Foundation
**Goal**: Establish the complete design token system and dark theme that all subsequent phases build on.
**Requirements**: THEME-01
**Recommended Agents**: UI Designer, UX Architect, Brand Guardian, Senior Developer
**Success Criteria**:
- Color tokens defined: surface, background, accent (orange/yellow), error, success, warning, text primary/secondary/disabled
- Spacing scale defined (4dp base grid)
- Typography scale defined with selected font family
- Elevation/shadow tokens defined
- Border radius tokens defined
- `ThemeData` wired with all tokens, `ColorScheme`, `TextTheme`, component themes
- App renders with new dark theme (visually different from current indigo seed)
- All existing tests pass with new theme
**Plans**: 4

### Phase 2: Reusable Component Library
**Goal**: Build the shared widget library that all screens will use, eliminating inline widget construction.
**Requirements**: THEME-02
**Recommended Agents**: UI Designer, UX Architect, Frontend Developer, Mobile App Builder
**Success Criteria**:
- Button variants: primary, secondary, text, icon (all with loading states)
- Card components: inspection card, section card, status card
- Form components: themed text field, dropdown, checkbox, date picker, section header
- Status components: badges, progress indicators, completion chips
- Feedback components: loading overlay, error banner, empty state, snackbar
- All components use design tokens exclusively (zero hardcoded values)
- Component catalog or test file demonstrating each variant
- Widget tests for all components
**Plans**: 4

### Phase 3: Navigation System & App Shell
**Goal**: Replace raw MaterialPageRoute navigation with a structured router and establish the app shell layout.
**Requirements**: UX-04
**Recommended Agents**: UX Architect, Mobile App Builder, Senior Developer, Security Engineer
**Success Criteria**:
- Router package integrated (go_router or equivalent)
- Route definitions migrated from AppRoutes constants
- Auth-gated routing preserved (unauthenticated vs authenticated shells)
- Screen transitions defined (shared axis, fade through, or equivalent)
- Deep link support maintained (password reset URI scheme)
- App shell structure established (if applicable: bottom nav, drawer, or tab scaffold)
- All navigation-dependent tests updated
**Plans**: 3

### Phase 4: Checklist Page Decomposition
**Goal**: Break the 822-line monolithic `form_checklist_page.dart` into focused, navigable sub-views.
**Requirements**: UX-01
**Recommended Agents**: UX Architect, Senior Developer, Mobile App Builder, Evidence Collector
**Success Criteria**:
- Monolith decomposed into minimum 4 distinct views/sections: wizard steps, evidence capture, PDF/delivery actions, audit timeline
- Each sub-view is independently testable
- Navigation between sub-views is clear (tabs, stepper, sub-routes, or segmented control)
- State shared between sub-views without prop-drilling hell (introduce state solution if needed)
- No functionality lost from original monolith
- Original form_checklist_page tests refactored to cover new structure
- No sub-view exceeds 250 lines
**Plans**: 5

### Phase 5: Field Usability & Visual Hierarchy
**Goal**: Apply field-optimized UX patterns and visual hierarchy across all decomposed checklist views and shared components.
**Requirements**: UX-02, UX-03
**Recommended Agents**: UX Researcher, UX Architect, UI Designer, Mobile App Builder
**Success Criteria**:
- All interactive elements meet 48dp minimum tap target
- Touch targets spaced for glove-friendly use (min 8dp gap)
- High contrast ratios verified (WCAG AAA for critical elements)
- Section grouping with visual separators and card elevation
- Status badges on checklist items (complete/incomplete/required)
- Progress indicator showing wizard completion percentage
- Typography hierarchy: 3+ distinct levels clearly differentiated
- One-handed reach zones considered in layout (critical actions in thumb zone)
**Plans**: 4

### Phase 6: Auth Screens Redesign
**Goal**: Apply design system to all auth screens and extract shared form components.
**Requirements**: SCREEN-01
**Recommended Agents**: UI Designer, Frontend Developer, Senior Developer, Security Engineer
**Success Criteria**:
- All 4 auth screens (sign in, sign up, forgot password, reset password) use design tokens and component library
- Shared auth form widget extracted (email field, password field, submit button pattern)
- Validation UX improved (inline errors, field-level feedback)
- Auth gate visual transition polished
- Zero hardcoded colors, spacing, or text styles in auth presentation files
- All auth widget tests updated and passing
**Plans**: 3

### Phase 7: Dashboard & New Inspection Redesign
**Goal**: Redesign the dashboard and new inspection pages with design system, status indicators, and improved form UX.
**Requirements**: SCREEN-02, SCREEN-03
**Recommended Agents**: UI Designer, UX Architect, Mobile App Builder, Frontend Developer
**Success Criteria**:
- Dashboard: inspection cards with visual status (draft/in-progress/complete/delivered)
- Dashboard: at-a-glance metrics or summary (inspection count, pending actions)
- Dashboard: empty state for new users
- New Inspection: progressive disclosure (sections expand as needed)
- New Inspection: section grouping (client info, property info, form selection)
- New Inspection: form selection with visual descriptions, not just checkboxes
- Both pages use design tokens and component library exclusively
- Widget tests updated
**Plans**: 4

### Phase 8: Inspector Identity & Final Polish
**Goal**: Redesign identity page, apply final consistency pass, and verify complete design system coverage.
**Requirements**: SCREEN-04
**Recommended Agents**: UI Designer, UX Architect, Evidence Collector, Reality Checker
**Success Criteria**:
- Inspector identity page redesigned with design system
- Signature capture UI polished with clear affordances
- License information display improved
- Full app audit: zero hardcoded colors, spacing, or text styles remaining
- Visual consistency verified across all screens (spacing, elevation, typography)
- All tests passing (existing + new)
- Design token usage report: 100% coverage across presentation layer
**Plans**: 3

## Progress

| Phase | Plans | Completed | Status |
|-------|-------|-----------|--------|
| 1. Design Token System | 4 | 4 | Complete |
| 2. Component Library | 4 | 4 | Complete |
| 3. Navigation System | 3 | 3 | Complete |
| 4. Checklist Decomposition | 5 | 5 | Complete |
| 5. Field Usability & Hierarchy | 4 | 4 | Complete |
| 6. Auth Screens | 3 | 3 | Complete |
| 7. Dashboard & New Inspection | 4 | 4 | Complete |
| 8. Identity & Final Polish | 3 | 0 | Not started |
| **Total** | **30** | **27** | **90%** |
