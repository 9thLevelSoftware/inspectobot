# Plan 02-03 Summary: Form-Specific Namespaces + Key Constants

> Phase: 02-unified-property-schema | Plan: 02-03 | Agent: Technical Writer
> Date: 2026-03-07 | Status: Complete

---

## Deliverables

| File | Content |
|------|---------|
| `02-03-FORM-DATA-KEYS.md` | Key naming convention, FormDataKeys constants for all 7 form types (333 constants), repeating group deep dives (4 patterns), 7 example data payloads, 10 design decisions |

---

## Key Decisions

### 1. Keys Do NOT Include Form Prefix

Per the 02-02 decision to use `Map<FormType, Map<String, dynamic>>`, the FormType enum key already provides form identity. Key values use `{section}.{fieldName}` format only. The `branchContext` getter reconstructs prefixed keys when needed.

### 2. Semantic Section Names for WDO and Sinkhole

Replaced opaque names (`section1`, `section2`) with meaningful names (`findings`, `inaccessible`, `treatment` for WDO; `exterior`, `interior`, `garage`, `appurtenant`, `additional`, `scheduling` for Sinkhole). Original FIELD_INVENTORY section numbers preserved in doc comments for traceability.

### 3. Repeating Group Strategy (Mixed Approach)

| Pattern | Strategy | Rationale |
|---------|----------|-----------|
| WDO inaccessible areas (5x3) | Flat named keys (`inaccessible.attic.flag`) | Fixed areas with regulatory names; named keys more readable |
| Sinkhole scheduling (4x4) | Flat indexed keys (`scheduling.attempts.0.date`) | Fixed slots, no semantic distinction between attempts |
| General checkpoints (Nx3) | `List<Map<String, dynamic>>` | Semi-dynamic, extensible without new constants |
| 4-Point fixtures (10x1) | Named individual keys (`plumbing.fixtureDishwasher`) | Fixed named appliances; direct access without list iteration |

### 4. Photo/Evidence Fields Excluded

All image, photo, and document evidence fields are managed by the media module (`capturedPhotoPaths`, `capturedEvidencePaths`), not FormDataKeys. This avoids creating a parallel key system.

### 5. General Inspection Checkpoint Compression

The ~150+ General Inspection fields compress to 79 constants because checkpoint tables (e.g., 12 Electrical items) are stored as a single `List<Map>` key per section rather than individual constants per item. This keeps the constant count manageable and makes the schema extensible.

---

## Verification Checklist

- [x] Key naming convention documented with format rules and examples (Section 1.1)
- [x] All 14 input patterns from FIELD_INVENTORY Section 5.2 have corresponding key conventions (Section 1.5)
- [x] FormDataKeys constants cover all form-specific fields from FIELD_INVENTORY Sections 4.1-4.7 (Section 2.1-2.7)
- [x] No universal or shared fields duplicated in FormDataKeys (exclusions documented per form type)
- [x] Key count per form reconciled against FIELD_INVENTORY field counts (Section 2.8)
- [x] 7 example data payloads provided, one per form type (Section 3.1-3.7)
- [x] Repeating group key convention handles WDO inaccessible areas, Sinkhole scheduling, General checkpoints (Sections 1.4.1-1.4.3)
- [x] Complete JSON examples for all 4 repeating group cases with Dart type annotations (Section 1.4)
- [x] Helper method signatures shown for accessing repeating group entries (Section 1.4)
- [x] JSON serialization round-trip verified for repeating groups (Section 1.4, each subsection)

---

## Constants Summary

| Form Type | Prefix | Constants | Notes |
|-----------|--------|-----------|-------|
| 4-Point | `fp_` | 111 | Largest form: 4 building systems + secondary roof |
| Roof Condition | `rc_` | 15 | Compact: roof assessment only |
| Wind Mitigation | `wm_` | 16 | Q1-Q8 questions + inspector |
| WDO | `wdo_` | 40 | Includes 15 inaccessible area fields |
| Sinkhole | `sk_` | 59 | 19 checklist items + 16 scheduling fields |
| Mold Assessment | `ma_` | 16 | Narrative report; many fields are lists |
| General Inspection | `gi_` | 76 | 12 sections; checkpoints stored as List<Map> |
| **Total** | | **333** | |

---

## Downstream Dependencies

- **02-04 (Conditional Logic)**: Needs FormDataKeys constants to define conditional visibility rules (e.g., `fp_electricalHazardOtherDesc` visible only when `fp_electricalHazardOther` is true).
- **02-05 (Field-to-Schema Mapping)**: Needs the complete key catalog to create the field-to-schema mapping and validation rules.
- **Phase 3+ (Form Implementations)**: Each form implementation will reference these constants for data access via `PropertyData.getFormValue()` and `PropertyData.setFormValue()`.

---

## Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| General Inspection rule-derived sections (6 of 12) have incomplete checkpoint lists | Medium | `List<Map>` storage is extensible; new items can be added without new constants. When actual templates are obtained, checkpoint lists can be expanded without schema changes. |
| 330 constants in a single class may be unwieldy | Low | Organized by form prefix (`fp_`, `rc_`, etc.) with section comments. IDE search/autocomplete works well with the `{prefix}_{section}{Field}` convention. Could split into per-form classes later if needed. |
| Mold Assessment fields based on statutory knowledge, not verified template | Medium | All 17 fields sourced from Chapter 468 Part XVI requirements. May need additions when a MRSA-compliant template is obtained (GAP-04). |
| Sinkhole form page 1 missing (8 inferred fields) | Low | All 8 inferred fields map to universal/shared; no form-specific constants affected. |
