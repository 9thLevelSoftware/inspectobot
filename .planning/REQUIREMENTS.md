# Requirements: InspectoBot

**Defined:** 2026-03-04
**Core Value:** An inspector can complete a Florida insurance inspection workflow quickly and generate compliant, underwriter-ready PDFs with all required data and photos enforced.

## v1 Requirements

Requirements for initial release. Each maps to exactly one roadmap phase.

### Authentication and Inspector Identity

- [x] **AUTH-01**: User can create an account with email and password.
- [x] **AUTH-02**: User can sign in and stay signed in across app restarts.
- [x] **AUTH-03**: User can reset password using an email reset flow.
- [x] **AUTH-04**: User can save inspector profile details including license type and license number.
- [x] **AUTH-05**: User can capture and store inspector signature for report signing.

### Inspection Setup and Workflow

- [x] **FLOW-01**: User can create an inspection with client identity, property address, inspection date, and year built.
- [x] **FLOW-02**: User can select one or more supported forms for an inspection (`Insp4pt 03-25`, `RCF-1 03-25`, `OIR-B1-1802 Rev 04/26`).
- [ ] **FLOW-03**: User can complete a linear wizard with required-step progression and conditional branching.
- [x] **FLOW-04**: User can resume an in-progress inspection and continue from last incomplete step.
- [x] **FLOW-05**: User can see a per-form completion summary that identifies missing required items.

### Evidence and Media Compliance

- [x] **EVID-01**: User can capture required exterior elevation photos (front, rear, left, right) for applicable forms.
- [ ] **EVID-02**: User can capture required roof evidence including slope-specific photos and defect photos when present.
- [x] **EVID-03**: User can capture required plumbing, HVAC, electrical, and hazard photos based on selected form logic.
- [x] **EVID-04**: User can capture evidence for all seven wind mitigation categories, including supporting documents when required.
- [x] **EVID-05**: System blocks PDF generation when any required field or required evidence category is incomplete.
- [x] **EVID-06**: System compresses captured images to mobile-friendly sizes before upload and PDF embedding.

### Forms, PDF, Delivery, and Audit

- [x] **PDF-01**: System generates official-form-aligned PDFs for each selected inspection form using version-pinned templates.
- [x] **PDF-02**: Generated PDFs include mapped data, mapped images, and inspector signature in required locations.
- [x] **PDF-03**: Generated PDF artifacts stay within configurable size guardrails suitable for insurer submission.
- [x] **DLV-01**: User can deliver generated reports via download and secure sharing.
- [x] **DLV-02**: System records an immutable audit timeline for inspection edits, signatures, generation, and delivery actions.

### Security, Offline, and Data Integrity

- [x] **SEC-01**: System enforces strict tenant isolation so users can only access their own organization data.
- [x] **SEC-02**: System stores signature evidence metadata (timestamp, signer role, hash linkage, attribution metadata) with each signed report.
- [x] **OFF-01**: User can complete core inspection capture workflows offline and queue sync operations for later.
- [x] **OFF-02**: System performs idempotent sync to prevent duplicate or orphaned inspection/media records.
- [x] **DATA-01**: System supports retention controls consistent with minimum 5-year record retention baseline.

## v2 Requirements

Deferred to future release. Tracked but not in current roadmap.

### Differentiators

- **DIFF-01**: User sees an underwriter-readiness score before PDF generation.
- **DIFF-02**: System provides dynamic evidence prompts based on answer context.
- **DIFF-03**: Agent can review reports through secure links and leave deficiency comments.
- **DIFF-04**: User can export a one-click verification-defense packet.

### Commercial and Expansion

- **COMM-01**: System supports subscription and pay-per-report billing plans.
- **COMM-02**: System provides analytics and support portal capabilities.
- **EXP-01**: System supports multi-state inspection form expansion.
- **EXP-02**: System supports assistive AI suggestions for photo/data workflows.

## Out of Scope

| Feature | Reason |
|---------|--------|
| Full CRM (lead pipeline, campaigns, sales automation) | Not required for core Florida insurance inspection value; increases complexity and delivery risk. |
| Full scheduling/dispatch suite | Outside first-release compliance workflow and not a differentiator for this niche. |
| General narrative home-inspection report builder | Different product category from targeted Florida insurance form workflows. |
| Desktop-first authoring experience | Field workflow is mobile-first; desktop tooling is deferred. |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| AUTH-01 | Phase 17 | Complete |
| AUTH-02 | Phase 17 | Complete |
| AUTH-03 | Phase 13 | Complete |
| AUTH-04 | Phase 16 | Complete |
| AUTH-05 | Phase 16 | Complete |
| FLOW-01 | Phase 17 | Complete |
| FLOW-02 | Phase 16 | Complete |
| FLOW-03 | Phase 16 | Pending |
| FLOW-04 | Phase 14 | Complete |
| FLOW-05 | Phase 16 | Complete |
| EVID-01 | Phase 16 | Complete |
| EVID-02 | Phase 18 | Pending |
| EVID-03 | Phase 16 | Complete |
| EVID-04 | Phase 16 | Complete |
| EVID-05 | Phase 16 | Complete |
| EVID-06 | Phase 16 | Complete |
| PDF-01 | Phase 11 | Complete |
| PDF-02 | Phase 14 | Complete |
| PDF-03 | Phase 7 | Complete |
| DLV-01 | Phase 12 | Complete |
| DLV-02 | Phase 12 | Complete |
| SEC-01 | Phase 17 | Complete |
| SEC-02 | Phase 16 | Complete |
| OFF-01 | Phase 14 | Complete |
| OFF-02 | Phase 12 | Complete |
| DATA-01 | Phase 16 | Complete |

**Coverage:**
- v1 requirements: 26 total
- Mapped to phases: 26
- Unmapped: 0 ✓
- Checked-off: 24/26

---
*Requirements defined: 2026-03-04*
*Last updated: 2026-03-05 after phase 17 closure reconciliation*
