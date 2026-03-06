# Roadmap: InspectoBot

## Milestones

- ✅ **v1.0 MVP** - Phases 1-18 shipped on 2026-03-05. Full archive: `.planning/milestones/v1.0-ROADMAP.md`

## Next Milestone (Planning)

- Gap closure scope created from latest milestone audit.
- [ ] **Phase 19: Conditional Branch Wiring and Evidence Activation** - Restore live conditional wizard/evidence activation by wiring branch-input capture and persistence into requirement evaluation paths.
- [ ] **Phase 20: PDF Mapping Completeness and Identity Contract Reconciliation** - Close mapped-content coverage risk and reconcile inspector identity profile/license contract usage policy.

## Gap Closure Phase Details

### Phase 19: Conditional Branch Wiring and Evidence Activation
**Goal:** Ensure conditional wizard progression and conditional evidence requirements activate from real user inputs, not only from synthetic test context.
**Depends on:** Phase 18
**Requirements:** FLOW-03, EVID-02, EVID-03, EVID-04
**Gap Closure:** Closes blocking milestone audit findings for missing branch-input wiring and broken setup -> wizard -> conditional evidence flow.
**Plans:** 1/2 plans executed

Plans:
- [x] 19-conditional-branch-wiring-and-evidence-activation-01-PLAN.md - Normalize canonical branch-flag contract and persistence/decode boundaries so resume-time branching uses strict, durable context.
- [ ] 19-conditional-branch-wiring-and-evidence-activation-02-PLAN.md - Wire live branch-input capture through setup/wizard/resume and prove conditional evidence activation/readiness parity end-to-end.

### Phase 20: PDF Mapping Completeness and Identity Contract Reconciliation
**Goal:** Validate and enforce PDF mapped-content completeness against requirement breadth and reconcile the AUTH-04 profile/license contract as explicit consumer wiring or explicit policy-bound non-consumer.
**Depends on:** Phase 19
**Requirements:** PDF-02, AUTH-04
**Gap Closure:** Closes non-blocking but high-risk map-coverage integration warning and identity contract consumer-path ambiguity from milestone audit.
**Plans:** 0 plans

## Notes

- Milestone v1.0 was closed with one known carried gap: `FLOW-03` (wizard conditional branching remains pending in requirements traceability).
- Historical audit snapshots are archived under `.planning/milestones/`.
