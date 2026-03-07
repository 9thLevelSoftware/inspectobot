# InspectoBot — Form Expansion & Unified Schema

## What This Is

A major expansion of InspectoBot from 3 to 7 Florida inspection form types (adding WDO, Sinkhole, Mold Assessment, and General Inspection), built on a unified property schema designed from ground-truth document analysis. This project establishes the data foundation and form coverage that a future AI-assist layer (v2) will build upon.

## Core Value

Inspectors can complete all major Florida property inspection types in a single app instead of switching between tools or paper forms. A unified property schema means data entered once flows to every applicable form, eliminating redundant data entry across inspection types.

## Who It's For

Florida home insurance inspectors conducting on-site property inspections. They need to produce compliant reports for 4-Point, Roof Condition, Wind Mitigation, WDO (wood-destroying organisms), Sinkhole, Mold Assessment, and General Home Inspection — often multiple reports for a single property visit.

## Requirements

### Validated
(None yet — ship to validate)

### Active

- **SCHEMA-01**: Ground Truth Extraction — Analyze all docs/ folder PDFs and templates to extract every field, checkbox, and narrative section into a comprehensive field inventory across all 7 form types.
- **SCHEMA-02**: Unified Property Schema — Design a master JSON schema where every form field maps to a normalized property model. Shared properties (address, year built, client info) defined once; form-specific properties namespaced per form type.
- **DATA-01**: Data Model Evolution — Extend FormType enum (4 new values), refactor InspectionDraft to support unified schema, update FormRequirements and WizardProgressSnapshot for new form types. Backward-compatible with existing inspections.
- **FORM-01**: WDO Form Type — FDACS-13645 wood-destroying organism inspection. Fillable PDF with field map. Evidence requirements, wizard steps, and branch logic (active infestation, previous treatment, damage extent).
- **FORM-02**: Sinkhole Form Type — Citizens Sinkhole Form + FGS Subsidence Incident Report. Fillable PDFs with field maps. Evidence requirements for geological indicators and insurance triggers.
- **FORM-03**: Mold Assessment Form Type — Narrative-based report per Florida Chapter 468, Part XVI, F.S. MRSA license validation, scope, source identification, remediation protocol. Template derived from HUDreport.doc patterns.
- **FORM-04**: General Inspection Form Type — Narrative-based full home inspection report per Florida Rule 61-30.801. Structural, electrical, plumbing narrative minimums. Template derived from fullinspection.doc and residentialmanual.pdf.
- **PDF-02**: Narrative Report Engine — Template-based narrative PDF generation for non-fillable form types (Mold, General). Boilerplate sections + inspector findings injection. Distinct from existing coordinate-based field placement.
- **WIZARD-02**: Cross-Form Evidence Sharing — One photo or document can satisfy requirements on multiple form types simultaneously. Inspector captures once, system routes to all applicable forms.
- **INTEG-01**: Multi-Form Sessions — Inspector selects multiple form types per property visit. Unified progress tracking, shared property data, independent per-form wizard completion.

### Out of Scope

- Zero-UI camera HUD (future v2 — AI-assist layer)
- AI-assisted auto-fill from photos/dictation (future v2)
- On-device speech-to-text (future v2)
- Cloud LLM routing (future v2)
- Light mode (dark-only by design)
- Multi-tenant/organization switching
- Video capture
- Client-facing portal
- Real-time collaboration
- Backend/Supabase schema changes beyond what form expansion requires

## Constraints

- **Backward Compatibility**: Existing 3 form types (4-Point, Roof Condition, Wind Mitigation) must continue working identically. No breaking changes to existing inspections.
- **Unified Schema First**: The schema must be designed before individual form implementations begin. Forms are implemented against the schema, not independently.
- **Florida Compliance**: Each form type must produce output that matches the exact regulatory form (FDACS-13645, Citizens Sinkhole Form, etc.) or satisfies statutory requirements (Chapter 468, Rule 61-30.801).
- **Two PDF Paradigms**: Fillable PDFs (WDO, Sinkhole) use coordinate-based field placement like existing forms. Narrative PDFs (Mold, General) require a new template-injection approach.
- **No Code Generation**: Project continues the manual serialization pattern. Consider migration to code generation only if serialization complexity becomes unmanageable with 7+ form types.
- **Test Coverage**: All new form types need widget tests. Existing test suite must continue passing. Target: maintain 78%+ test-to-code ratio.
- **Incremental Delivery**: Each phase leaves the app in a working state. New forms can ship independently once the schema foundation is in place.
- **Doc Ground Truth**: The docs/ folder contents are the authoritative source for form field mapping. AI pipeline design (v2) must be compatible with the schema produced here.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Schema + Forms first, AI-assist deferred to v2 | De-risks the project: validates form coverage and schema design before introducing AI complexity. AI layer becomes a bolt-on, not a dependency. | Active |
| Unified Property Schema designed upfront | Prevents per-form data silos. Enables cross-form evidence sharing and future AI routing. More work upfront but eliminates refactoring later. | Active |
| Doc analysis sprint as Phase 1 | Ground truth must exist before schema design. Every field on every form must be inventoried to prevent schema gaps. | Active |
| Narrative report engine as distinct subsystem | Mold and General inspections use narrative templates, not fillable PDFs. Different generation approach requires its own abstraction. | Active |
| Autonomous execution, deep analysis, premium agents | Complex domain with regulatory compliance requirements. Deep analysis catches compliance gaps early. Premium agents provide specialist coverage. | Active |
| All 4 new form types in scope | Partial expansion creates inconsistency. Full coverage makes the app a true "one-stop" inspection tool. | Active |

## Architecture Influences

- **Existing pattern**: `lib/features/<name>/` convention continues. New form types may share the `inspection/` feature or get dedicated feature modules if complexity warrants.
- **PDF pipeline**: Existing `PdfOrchestrator` + `OnDevicePdfService` extend to new templates. Narrative engine is a new subsystem alongside coordinate-based placement.
- **Data model**: `InspectionDraft` evolves to carry unified schema data. `FormType` enum extends. `FormRequirements` grows significantly (50+ rules per new form type).
- **Wizard**: Current linear wizard model may need refactoring for narrative-based forms where the "steps" are different from fillable PDF forms.
- **Sync**: Existing `SyncScheduler` + outbox handles new form types without changes. Media sync extends naturally.
- **Testing**: New form types need comprehensive requirement/readiness tests. PDF field map coverage tests (existing pattern) extend to new templates.
- **Future AI hook**: The unified schema is explicitly designed to be the target for v2's AI multimodal router. Schema paths become the AI's structured output spec.

---
*Last updated: 2026-03-07 after initialization (concept crystallized via /legion:explore)*
