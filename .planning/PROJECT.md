# InspectoBot - Florida Insurance Inspection Micro-SaaS

## What This Is

InspectoBot is a mobile-first app for Florida home inspectors that produces compliant insurance inspection reports quickly in the field. It focuses on Citizens 4-Point (Insp4pt 03-25), Roof Condition (RCF-1 03-25), and Wind Mitigation (OIR-B1-1802 Rev 04/26) instead of full narrative inspection suites. The product is designed for independent inspectors and small firms that need fast, reliable, photo-complete PDFs.

## Core Value

An inspector can complete a Florida insurance inspection workflow quickly and generate compliant, underwriter-ready PDFs with all required data and photos enforced.

## Current State

- v1.0 MVP shipped on 2026-03-06 across 20 phases (56 plans, 145 commits).
- Codebase: 16,632 LOC Dart (9,350 source + 7,282 test), 221 files.
- End-to-end auth, workflow, evidence capture, PDF generation, delivery, and audit retention flows are in place.
- All 32 v1.0 requirements verified and closed, including gap-closure phases 13-20.
- All integration flows validated: setup → wizard → evidence → PDF → delivery → audit.

## Next Milestone Goals

- Define and prioritize post-v1 differentiators and commercial requirements (DIFF-*, COMM-*, EXP-*).
- Establish release objective and phase slice for v1.1.
- Candidate features: underwriter-readiness scoring, dynamic evidence prompts, agent review portals, billing integration.

## Requirements

### Validated

- ✓ Secure tenant-scoped authentication with RLS isolation and inspector identity — v1.0 (AUTH-01, AUTH-02, AUTH-03, AUTH-04)
- ✓ Inspector profile and signature capture with hash/timestamp attribution — v1.0 (AUTH-04, SEC-01)
- ✓ Linear wizard with required-step progression and conditional branching — v1.0 (FLOW-01, FLOW-02, FLOW-03)
- ✓ Required evidence capture for roof, systems, wind mitigation, and exterior — v1.0 (EVID-01, EVID-02, EVID-03, EVID-04)
- ✓ Compliance gating blocks PDF generation until all required fields and photos are captured — v1.0 (COMPL-01, COMPL-02, COMPL-03)
- ✓ Official-form-aligned PDFs with mapped data, images, signatures, and 100% field coverage — v1.0 (PDF-01, PDF-02, PDF-03)
- ✓ Report delivery with signed URLs, immutable audit timeline, and 5-year retention — v1.0 (DELIV-01, DELIV-02, DELIV-03)
- ✓ Offline capture with idempotent sync and dependency-ordered queue processing — v1.0 (SYNC-01, SYNC-02)
- ✓ Multi-tenant data isolation and encryption in transit/at rest — v1.0 (SEC-01, SEC-02, SEC-03)

### Active

- Candidate v1.1+ requirements pending milestone definition (see `.planning/milestones/v1.0-REQUIREMENTS.md` for DIFF-*, COMM-*, EXP-* candidates).

### Out of Scope

- Full CRM/scheduling platform features — explicitly excluded to keep the product focused on insurance-form execution speed.
- General-purpose narrative inspection reporting — outside the micro-SaaS scope and not core to Florida insurance form compliance.

## Context

- Domain focus is Florida insurance inspections, not general home inspection reporting.
- Primary documents emphasize three forms: Citizens 4-Point (Insp4pt 03-25), Roof Condition (RCF-1 03-25), and OIR-B1-1802 Rev 04/26 (effective 2026-04-01).
- Workflow is wizard-first and state-machine driven to reduce cognitive load in field conditions (attics, roofs, bright sun, intermittent connectivity).
- Compliance requirements include legally meaningful e-signature metadata (timestamp/hash/IP), secure tenant isolation, and long-term record retention.
- Technical direction captured in idea docs favors Flutter + Supabase + aggressive image compression + template-overlay PDF generation.
- v1.0 shipped with comprehensive test coverage (7,282 LOC test code) and 3 rounds of milestone auditing to close all gaps.

## Constraints

- **Regulatory**: Must align with current Florida/Citizens form requirements and enforce required-photo completeness before PDF generation — compliance is product-critical.
- **Data Security**: Multi-tenant access isolation, encryption in transit/at rest, and auditability are mandatory — inspection records are sensitive.
- **Performance**: Photo-heavy workflows must remain responsive on mobile and produce insurer-acceptable PDF sizes — otherwise reports are rejected.
- **Offline Tolerance**: Core capture flow must tolerate poor/no signal and sync safely later — inspectors routinely work in low-connectivity environments.
- **Scope Discipline**: Product must remain narrowly focused on insurance forms, not broad inspection suite features — differentiation comes from speed and simplicity.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| `docs/blueprint.md` is canonical product intent | It contains the most complete operational breakdown of workflow, schema, and implementation details | ✓ Good — Established in v1.0 |
| On-device PDF generation is default architecture direction | Better offline capability and lower variable costs than per-document cloud PDF APIs | ✓ Good — Established in v1.0 |
| Required-photo gating is a hard blocker for PDF generation | Prevents compliance failures and underwriter rejections at source | ✓ Good — Established in v1.0 |
| Micro-SaaS scope excludes CRM/scheduling | Reduces complexity and keeps delivery aligned with core value (fast compliant forms) | ✓ Good — Established in v1.0 |
| Cloud PDF fallback uses explicit generated/unavailable/terminal outcomes | Deterministic runtime branching is required to avoid silent degradation and partial delivery persistence | ✓ Good — Established in Phase 18 |
| License source keys are non-required unless policy is intentionally changed | Prevents profile/license map drift and enforces intentional contract updates through tests | ✓ Good — Established in Phase 18 |
| Canonical branch keys defined in FormRequirements and reused by predicates/tests | Prevents literal drift between branch-flag persistence and predicate evaluation | ✓ Good — Established in Phase 19 |
| Repository write/decode paths persist only canonical bool branch flags | Retains enabled_forms metadata while keeping branch context durable across resume cycles | ✓ Good — Established in Phase 19 |
| Coverage enforcement tests compare canonical source keys against map source_key sets | Catches evidence field omissions at test time before they reach PDF generation | ✓ Good — Established in Phase 20 |
| License exclusion formalized as AUTH-04 POLICY with explicit reversal steps | Prevents implicit omission from becoming ambiguous non-compliance | ✓ Good — Established in Phase 20 |

---
*Last updated: 2026-03-06 after v1.0 milestone completion (20 phases, 56 plans)*
