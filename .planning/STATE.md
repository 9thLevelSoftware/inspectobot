# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-03-05)

**Core value:** An inspector can complete a Florida insurance inspection workflow quickly and generate compliant, underwriter-ready PDFs with all required data and photos enforced.
**Current focus:** Post-v1.0 planning - define next milestone scope and phase plan.

## Current Position

**Current Phase:** 19
**Total Phases:** 20
**Current Phase Name:** Conditional Branch Wiring and Evidence Activation
**Current Plan:** 2
**Total Plans in Phase:** 2
**Status:** Phase complete — ready for verification
**Last Activity:** 2026-03-06
**Last Activity Description:** Phase 19 complete — all 4 requirements (FLOW-03, EVID-02, EVID-03, EVID-04) verified and closed

**Progress:** [██████████] 98%

## Performance Metrics

**Velocity:**
- Total plans completed: 33
- Average duration: 23 min
- Total execution time: 11.7 hours

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 1 | 4 | 124 min | 31 min |
| 2 | 2 | 44 min | 22 min |
| 3 | 2 | 72 min | 36 min |
| 4 | 4 | 96 min | 24 min |
| 5 | 3 | 72 min | 24 min |
| 7 | 3 | 130 min | 43 min |
| 8 | 4 | 95 min | 24 min |
| 9 | 3 | 11 min | 4 min |
| 10 | 3 | 43 min | 14 min |
| 11 | 3 | 98 min | 33 min |

**Recent Trend:**
- Last 6 plans: 10-01, 10-02, 10-03, 11-01, 11-02, 11-03
- Trend: Stable (phase 11 heavier due template integrity scope)

*Updated after each plan completion*
| Phase 03 P01 | 33 min | 3 tasks | 6 files |
| Phase 03 P02 | 39 min | 3 tasks | 8 files |
| Phase 04 P01 | 18 min | 1 task | 14 files |
| Phase 04 P02 | 24 min | 2 tasks | 6 files |
| Phase 04 P03 | 21 min | 2 tasks | 3 files |
| Phase 04 P04 | 33 min | 2 tasks | 8 files |
| Phase 05 P01 | 25 min | 3 tasks | 4 files |
| Phase 05 P02 | 24 min | 3 tasks | 9 files |
| Phase 05 P03 | 23 min | 3 tasks | 5 files |
| Phase 07 P01 | 40 min | 3 tasks | 9 files |
| Phase 07 P02 | 35 min | 3 tasks | 3 files |
| Phase 07 P03 | 55 min | 3 tasks | 8 files |
| Phase 08 P01 | 25 min | 2 tasks | 4 files |
| Phase 08 P02 | 30 min | 2 tasks | 4 files |
| Phase 08 P03 | 50 min | 3 tasks | 10 files |
| Phase 08 P04 | 20 min | 2 tasks | 5 files |
| Phase 09 P01 | 4 min | 2 tasks | 7 files |
| Phase 09 P02 | 3 min | 2 tasks | 8 files |
| Phase 09 P03 | 4 min | 2 tasks | 9 files |
| Phase 16 P02 | 2 min | 2 tasks | 3 files |
| Phase 16 P01 | 3 min | 2 tasks | 5 files |
| Phase 16 P03 | 4 min | 3 tasks | 3 files |
| Phase 17 P01 | 1 min | 2 tasks | 2 files |
| Phase 17 P02 | 15 min | 3 tasks | 2 files |
| Phase 17 P03 | 2 min | 3 tasks | 3 files |
| Phase 18 P01 | 22 min | 3 tasks | 5 files |
| Phase 18 P02 | 3 min | 3 tasks | 6 files |
| Phase 19 P01 | 2 min | 2 tasks | 5 files |
| Phase 19 P02 | 3 min | 3 tasks | 7 files |
| Phase 20 P01 | 3min | 2 tasks | 5 files |

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Recent decisions affecting current work:

- [Phase 1]: Start with secure authentication, tenant isolation, and inspector identity prerequisites before workflow execution.
- [Phase 1]: Auth repository + AuthGate split keeps Supabase session logic out of page widgets.
- [Phase 1]: Signature artifacts are persisted with org/user scoped paths and hash metadata for defensible attribution.
- [Phase 4]: Offline capture and idempotent sync are treated as a distinct delivery boundary before full evidence and PDF layers.
- [Phase 6]: Compliance gating is separated from PDF rendering so readiness rules are explicit and testable.
- [Phase 7]: Form rendering is manifest-driven with pinned revision+map versions and strict typed field schemas.
- [Phase 7]: PDF size guardrails use bounded retries and explicit over-budget failure metadata.
- [Phase 8]: Audit timeline persistence is append-only and fail-closed for inspection, signature, and delivery events.
- [Phase 8]: Delivery links are short-lived signed URLs with persisted delivery action rows before user-visible operations.
- [Phase 8]: Retention policies enforce a minimum five-year floor with scheduled server-side cleanup contracts.
- [Phase 09]: Use an auth.users trigger to provision org membership so signup always satisfies org-scoped RLS prerequisites.
- [Phase 09]: Keep deterministic fallback tenant resolution limited to non-Supabase runtime paths for tests/dev while requiring DB membership in live mode.
- [Phase 09]: Route signed-in dashboard access through AuthGate so tenant context resolution happens before runtime page rendering.
- [Phase 09]: Require organizationId/userId constructor scope for dashboard, setup, and identity pages to remove placeholder tenant defaults.
- [Phase 09]: Centralized media and report artifact paths behind org/{orgId}/users/{userId} contract to keep runtime storage writes aligned with bucket policy checks.
- [Phase 09]: Sync scheduler now resolves active auth tenant context and runner skips queued operations that do not match current tenant scope.
- [Phase 10]: Wizard progress saves merge prior branch context before persisting enabled forms so conditional branch inputs survive resume cycles.
- [Phase 10]: Requirement key/category mapping derives from declared requirement contracts (not enum casing) to keep checklist and readiness predicates aligned.
- [Phase 10]: Document evidence capture now follows a document-safe picker/passthrough branch while photo capture remains JPEG-compressed before sync upload.
- [Phase 11]: PDF generation now fails closed unless persisted signature bytes and requirement-keyed evidence paths are loaded into PdfGenerationInput.
- [Phase 11]: Template map loading enforces canonical source-key allowlists so stale aliases fail at load time.
- [Phase 11]: Manifest-pinned template binaries are first-class runtime inputs and renderer requests now require validated template bytes.
- [Phase 12]: Delivery now verifies report artifact upload durability (read-back hash) before metadata persistence or link/share exposure.
- [Phase 12]: Sync enqueue and runner eligibility enforce dependencyOperationId contracts; unresolved dependencies fail explicitly instead of executing out of order.
- [Phase 16]: Standardized verification requirement rows to canonical Requirement|Source Plan|Description|Status|Evidence schema for phases 08/10/11.
- [Phase 16]: Normalized mapped requirement row status vocabulary to lowercase passed for deterministic extraction.
- [Phase 16]: Standardized VERIFICATION requirement trace rows to canonical five-column schema with passed status vocabulary.
- [Phase 16]: Used explicit source plan filename IDs in trace rows for deterministic milestone parser extraction.
- [Phase 16]: Keep phase 16 closure scope limited to the 11 mapped requirement IDs while documenting residual out-of-scope gaps explicitly.
- [Phase 16]: Use satisfied as final milestone status for scoped IDs once VERIFICATION, SUMMARY, and REQUIREMENTS are aligned.
- [Phase 17]: Initialize phase 17 as scaffold-only with all mapped requirements left at human_needed until live evidence is captured.
- [Phase 17]: Require deterministic preflight command outputs before and after live validation to separate regressions from environment failures.
- [Phase 17]: Disallow org-local-* fallback IDs as valid evidence for requirement closure.
- [Phase 17]: Used one controlled Supabase environment run for AUTH-01/AUTH-02/FLOW-01/SEC-01 evidence consistency.
- [Phase 17]: Requirement rows were marked passed only after concrete command output contained tenant IDs and RLS status proof.
- [Phase 17]: Closed phase-9 human_needed debt by linking to phase-17 live evidence instead of duplicating scenario execution.
- [Phase 17]: Used phase-17 verification evidence as canonical source for AUTH-01/AUTH-02/FLOW-01/SEC-01 final status.
- [Phase 17]: Kept unresolved FLOW-03 and EVID-02 findings explicitly out-of-scope during phase-17 closure reconciliation.
- [Phase 17]: Added a committed `live_validation_runner.mjs` harness so live tenant-auth evidence is replayable from source-controlled artifacts.
- [Phase 17]: Replayed live Supabase validation after credential rotation checkpoint and closed AUTH-01/AUTH-02/FLOW-01/SEC-01 rows to passed using sanitized output.
- [Phase 18]: CloudPdfService now invokes Supabase function runtime and classifies 404/429/503 as unavailable while preserving terminal failures.
- [Phase 18]: Checklist generation defaults to PdfStrategy.cloudFallback with deterministic terminal-failure inspector messaging.
- [Phase 18]: License source keys remain explicitly non-required by default and are removed from loader allowlist unless policy is intentionally changed.
- [Phase 18]: Phase-18 verification is the canonical EVID-02 closure source linking plan-01 resilience tests and plan-02 mapping-policy tests.
- [Phase 19]: Canonical branch keys are defined in FormRequirements and reused by predicates/tests to prevent literal drift.
- [Phase 19]: Repository write/decode paths persist only canonical bool branch flags while retaining enabled_forms metadata.
- [Phase 19]: Live branch-input capture wired through checklist UI with immediate snapshot update and readiness refresh.
- [Phase 19]: Setup/resume flow preserves branch answers through wizard progress persistence for conditional evidence reactivation.
- [Phase 20]: Coverage enforcement tests compare canonicalSourceKeysForForm against map source_key sets to catch evidence omissions
- [Phase 20]: Document evidence keys use image type fields in maps since documents are captured as photos in-app

### Pending Todos

From .planning/todos/pending/ - ideas captured during sessions.

None yet.

### Blockers/Concerns

- Validate legal sufficiency details for signature attribution metadata before general availability.
- Confirm insurer-specific practical PDF size thresholds during pilot validation.
- Establish owner and SLA for rapid Citizens/OIR form revision updates.

## Session Continuity

**Last session:** 2026-03-06T01:59:26.832Z
**Stopped At:** Completed 20-01-PLAN.md — ready for 20-02
**Resume File:** None
