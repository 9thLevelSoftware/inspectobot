# Plan 02-04 Summary: Conditional Logic + FormRequirements

> Phase: 02-unified-property-schema | Plan: 02-04 | Agent: Senior Developer
> Date: 2026-03-07 | Status: Complete

---

## Deliverables

| File | Content |
|------|---------|
| `02-04-CONDITIONAL-LOGIC.md` | Branch predicates for all 7 form types (5 existing + 32 new canonical flags), derived flag patterns, branch hierarchies, validation rules, predicate implementation patterns |
| `02-04-FORM-REQUIREMENTS.md` | FormRequirements extension patterns for 4 new forms, 20 new RequiredPhotoCategory values, evidence-to-schema path mapping, cross-form evidence sharing matrix |

---

## Key Decisions

### 1. Canonical vs Derived Branch Flags

Split branch flags into two categories:

- **Canonical flags** (37 total): Stored in `branchContext`, registered in `canonicalBranchFlags`, processed by `_canonicalizeBranchContext()`. Used for flags that directly gate evidence requirements.
- **Derived flags** (~50 total): Computed at runtime from form data values. Not stored in `branchContext`. Used for fine-grained field visibility (e.g., each of 19 sinkhole checklist items, per-section "has poor" in General Inspection).

**Rationale**: Registering all ~87 possible flags in `canonicalBranchFlags` would create unnecessary bloat. Derived flags are ephemeral and recomputed on every form data change, so persisting them adds no value.

### 2. Sinkhole Checklist Items Use Pattern-Based Predicates

Rather than creating 19 individual branch flags for sinkhole checklist items, the detail fields are gated by reading the item's tri-state value directly. Section-level aggregate flags (e.g., `sinkhole_any_exterior_yes`) are canonical because they gate evidence requirements.

### 3. General Inspection Section-Level Flags Are Pre-Computed by Controller

The controller pre-computes `general_{section}_has_poor` and similar flags from checkpoint arrays and writes them to `branchContext`. This keeps `FormRequirements` predicate evaluation uniform (always checking boolean flags) while checkpoint scanning logic stays in the controller layer. These pre-computed flags pass through `_canonicalizeBranchContext()` via pattern matching, but are not registered in `canonicalBranchFlags`.

### 4. WDO Evidence Requirements Are Industry Practice, Not Form-Mandated

FDACS-13645 does not specify photo requirements on the form itself. Evidence requirements defined here follow industry practice (per 01-02-WDO-FORM.md "Photo Requirements" section). The property exterior and notice posting photos are marked as always-required for app purposes.

### 5. Cross-Form Evidence Sharing Uses Reference-Based Model

Multiple evidence keys can point to the same file path. Each form maintains independent completion tracking. A photo captured for one form can be "shared" by copying the file path to another form's evidence key. Full implementation deferred to Phase 9.

### 6. One New Predicate Function

Only one new predicate function (`_anyWdoInaccessible`) is needed beyond the existing `_boolFlag` pattern. All other predicates use the standard `_boolFlag(flagName)` approach. This keeps the predicate system simple and uniform.

---

## Verification Checklist

- [x] All WDO branch predicates match FDACS-13645 form structure (Section 2 A/B mutex, B.1/B.2/B.3 sub-branches, Section 3 inaccessible areas x5, Section 4 treatment branches)
- [x] All Sinkhole branch predicates match Citizens form checklist logic (19 yes/no/NA items with detail fields, section aggregates, townhouse conditional, scheduling attempts)
- [x] All Mold branch predicates match Chapter 468 MRSA requirements (visible mold, moisture source, sampling types, remediation protocol, post-remediation assessment)
- [x] All General Inspection branch predicates match Rule 61-30.801 standards (per-section Poor rating -> narrative, safety hazard, not accessible, moisture/mold/pest evidence, structural concern)
- [x] FormRequirements extension follows existing code pattern (same _photo/_document helpers, same _boolFlag predicate, same EvidenceRequirement structure)
- [x] Every evidence requirement maps to a valid schema path (trigger path and storage path documented in tables)
- [x] Cross-form evidence sharing opportunities identified and documented (8 sharing groups across 5 priority levels)
- [x] Regulatory citations provided for each conditional logic rule (FDACS-13645, Citizens form, s. 468.8414/8415/8419 F.S., Rule 61-30.801)

---

## Metrics

| Metric | Count |
|--------|-------|
| Canonical branch flags (existing) | 5 |
| Canonical branch flags (new) | 32 |
| Canonical branch flags (total) | 37 |
| Derived flags (computed at runtime) | ~50 |
| New RequiredPhotoCategory values | 20 |
| Total RequiredPhotoCategory values | 40 |
| New evidence requirements (across 4 forms) | 19 |
| Total evidence requirements (all 7 forms) | 44 |
| Cross-form sharing groups | 5 |
| New predicate functions needed | 1 |
| Structural changes to existing classes | 0 |

---

## Downstream Dependencies

Plans 02-05 (Field-to-Schema Mapping + Validation) depends on this design:
- Uses the branch flag registry to validate that every conditional field has a corresponding predicate
- Uses the evidence-to-schema path mapping to verify complete field coverage
- Uses the cross-form sharing matrix for validation rule cross-references

Phase 3 (Implementation Foundation) will implement:
- `FormType` enum extension with 4 new values
- `RequiredPhotoCategory` enum extension with 20 new values
- `canonicalBranchFlags` expansion to 37 entries

Phases 4-7 (per-form implementation) will implement:
- `_requirementsByForm` entries for each new form
- Controller-layer branch flag derivation logic
- UI conditional field visibility

Phase 9 (Cross-Form Integration) will implement:
- Evidence sharing infrastructure based on the sharing matrix

---

## Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| Mold assessment requirements based on statutory knowledge, not verified template | Medium | All mold fields flagged as "Statutory (unverified)" in FIELD_INVENTORY; external verification recommended before Phase 6 implementation |
| 6 General Inspection sections derived from Rule 61-30.801, not fullinspection.doc | Medium | Schema designed with extension points for additional checkpoints; checkpoint counts may increase when complete template is obtained |
| Sinkhole form is from 2012 (14 years old) | Low | Verify with Citizens whether newer version exists; current design accommodates checklist additions |
| Sinkhole page 1 missing -- 8 inferred fields | Low | Property ID fields follow standard Citizens pattern; low risk of significant deviation |
| 37 canonical branch flags may approach scaling concerns | Low | Pattern-based derived flags keep canonical count manageable; existing architecture handles any count |
