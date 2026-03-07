# Plan 02-05 Summary: Field-to-Schema Mapping + Validation Report

> Phase: 02-unified-property-schema | Plan: 02-05 | Agent: Senior Developer
> Date: 2026-03-07 | Status: Complete

---

## Deliverables

| File | Content |
|------|---------|
| `SCHEMA_MAPPING.md` | Complete field-to-schema mapping for all 7 form types: every field from FIELD_INVENTORY mapped to UniversalPropertyFields, SharedBuildingSystemFields, or FormDataKeys with schema paths, types, and required/conditional status |
| `02-05-VALIDATION-REPORT.md` | Validation rules matrix for all fields across all 7 forms, ROADMAP Phase 2 success criteria verification (8/8 PASS), gap analysis with remediation plans |

---

## Key Results

### Field-to-Schema Mapping

| Form Type | FIELD_INVENTORY Fields | Universal | Shared | Form-Specific | Media | Schema Slots |
|-----------|----------------------|-----------|--------|---------------|-------|-------------|
| 4-Point | ~126 | 8 | 11 | 111 | 27 | 157 |
| Roof Condition | ~28 | 8 | 6 | 15 | 6 | 35 |
| Wind Mitigation | ~45 | 8 | 4 | 16 | 20 | 48 |
| WDO | 51 | 8 | 2 | 40 | 0 | 50 |
| Sinkhole | 67 | 8 | 3 | 59 | 0 | 70 |
| Mold Assessment | 21 | 8 (6 used) | 1 | 16 | 0 | 23 |
| General Inspection | ~150+ | 8 (6 used) | 11 | 76 | 0 | 95 |

**Totals**: 8 universal fields + 13 shared fields + 333 form-specific constants = **354 unique schema fields**

### Count Verification

- FIELD_INVENTORY reports ~486 total fields
- Schema accounts for all ~486 via: 354 unique fields + ~55 media-managed fields + 2 WDO repeat fields + ~75 fields compressed into List<Map> checkpoint structures
- No unmapped fields remain (excluding descoped FGS)

### Success Criteria

All 8 ROADMAP Phase 2 success criteria verified as PASS:

| # | Criterion | Status |
|---|-----------|--------|
| 1 | Master JSON schema with shared namespace | PASS |
| 2 | Per-form namespaces | PASS |
| 3 | Field-to-schema mapping document | PASS |
| 4 | Validation rules per field | PASS |
| 5 | Branching logic support | PASS |
| 6 | Backward compatibility spec | PASS |
| 7 | Schema versioning strategy | PASS |
| 8 | Dart model specification | PASS |

---

## Decisions

### 1. Inspector Phone on 4-Point

The 4-Point Inspector Certification block includes a "Work Phone" field. Although FIELD_INVENTORY Section 2.3 shows `inspector_phone` as shared across Wind Mit, WDO, Sinkhole, and General (not 4-Point), the certification block phone field maps naturally to `SharedBuildingSystemFields.inspectorPhone`. This is documented as a minor deviation from the overlap matrix, with no functional impact since the shared field is nullable.

### 2. Dual-Location Fields

Several fields appear in both shared and form-specific locations (e.g., `roofCondition` in `SharedBuildingSystemFields.roofCondition` AND `FormDataKeys.rc_roofConditionRating`). This is by design: the shared field stores the normalized `RatingScale` value for cross-form use, while the form-specific field stores the original form string for PDF output. This pattern was established in 02-01-RATING-SCALE.md.

### 3. Media Fields Excluded from FormDataKeys

All photo/evidence fields (checkbox + image pairs) are managed by the existing media module, not FormDataKeys. This avoids creating a parallel key system and aligns with the existing `capturedPhotoPaths` and `capturedEvidencePaths` architecture.

### 4. General Inspection Checkpoint Compression

~95 individual checkpoint items across 12 sections are stored as `List<Map<String, dynamic>>` values under single keys rather than individual constants. This reduces 95+ potential constants to 12 checkpoint keys while keeping the schema extensible for additional checkpoint items discovered when complete templates are obtained.

---

## Verification Checklist

- [x] Every field from FIELD_INVENTORY Sections 4.1-4.7 mapped to a schema location
- [x] Total mapped field count reconciled: 354 unique schema fields account for ~486 inventory fields (with documented delta for media, repeats, and checkpoint compression)
- [x] Validation rules defined for all required and conditional fields (Sections 1.1-1.9 of validation report)
- [x] All 8 ROADMAP success criteria verified with evidence (Section 2 of validation report)
- [x] Gap analysis identifies 6 known data gaps with remediation plans (Section 3.2 of validation report)
- [x] No unmapped fields (FGS formally descoped; HUD documented as non-form-type)
- [x] Cross-form field sharing correctly documented (Section 9 of SCHEMA_MAPPING.md: 55 universal + 38 shared field-form mappings)

---

## Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| 6 General Inspection sections derived from statute, not template | Medium | List<Map> storage extensible; checkpoint counts can grow without schema changes |
| Mold Assessment fields statutory (unverified) | Medium | External verification recommended before Phase 7 implementation |
| Sinkhole form is 14 years old | Low | Schema extensible; verify with Citizens for newer version |
| 333 constants in single class | Low | Organized by prefix; can split per-form if needed |

---

## Phase 2 Completion Status

This plan (02-05) is the final plan of Phase 2. With all 5 plans complete, Phase 2 deliverables are:

| Plan | Title | Status | Deliverables |
|------|-------|--------|-------------|
| 02-01 | Core Shared Models | Complete | UniversalPropertyFields, SharedBuildingSystemFields, RatingScale |
| 02-02 | PropertyData + Backward Compat | Complete | PropertyData aggregate, migration strategy, versioning |
| 02-03 | Form-Specific Namespaces | Complete | FormDataKeys (333 constants), repeating group patterns |
| 02-04 | Conditional Logic | Complete | 37 canonical + ~50 derived branch flags, FormRequirements extensions |
| 02-05 | Field-to-Schema Mapping | Complete | SCHEMA_MAPPING.md, validation report, gap analysis |

**Phase 2 is ready for review.**
