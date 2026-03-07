# 02-01 Summary: Core Shared Models

> **Plan**: 02-01
> **Phase**: 2 -- Unified Property Schema Design
> **Status**: Complete
> **Date**: 2026-03-07
> **Agent**: Backend Architect

---

## Deliverables

| File | Content |
|------|---------|
| `02-01-UNIVERSAL-FIELDS.md` | UniversalPropertyFields class: 8 fields, full Dart signature, toJson/fromJson contracts, validation rules, backward compatibility mapping |
| `02-01-SHARED-FIELDS.md` | SharedBuildingSystemFields class: 13 fields organized by building system group, overlap matrix, validation rules, backward compatibility mapping |
| `02-01-RATING-SCALE.md` | RatingScale enum: 7 values (including `failed`), extension methods, bidirectional validation matrix for all 4 rating systems, lossy conversion documentation |

---

## Key Design Decisions

### 1. Added `failed` to RatingScale enum (7 values, not 6)

The spec document Section 3.5 defined 6 values. The RCF-1 form uses "Failed" as a roof condition rating that is semantically more severe than "Poor"/"deficient". Mapping "Failed" to `deficient` would lose severity information. Added `failed` as a 7th enum value. This is the only value unique to a single form type (RCF-1).

### 2. Enum fields stored as String in SharedBuildingSystemFields

Fields like `electricalPanelType`, `plumbingPipeMaterial`, `waterHeaterType`, and `hvacType` are typed as `enum` in the FIELD_INVENTORY but stored as `String?` in Dart. Rationale: the enum values differ across forms (e.g., 4-Point pipe materials vs General), so form-specific enum constraints are enforced at the UI layer. Only `roofCondition` uses the `RatingScale` enum because cross-form normalization is its primary purpose.

### 3. Closure-based copyWith for nullable fields

Both classes use `T? Function()?` parameters in `copyWith()` for nullable fields. This allows callers to explicitly set fields to `null` (by passing `() => null`) without ambiguity vs "leave unchanged" (by not passing the parameter).

### 4. 4-Point N/A in fixture matrix

The 4-Point system is documented as 2-tier (S/U), but the plumbing fixture matrix uses N/A as a third option. The ingestion/emission tables for 4-Point include `notApplicable` to support correct round-tripping.

### 5. HUD Y/N vs S/U collapse documented as acceptable

HUD uses Y/S and N/U in different contexts. Both pairs collapse to the same RatingScale value. This is acceptable because the original value is preserved in formData and PDF output uses formData, not RatingScale.

---

## Verification Checklist

- [x] All 8 universal fields from FIELD_INVENTORY Section 2.1 present in UniversalPropertyFields
- [x] All 13 shared fields from FIELD_INVENTORY Section 2.2 present in SharedBuildingSystemFields
- [x] Field types match FIELD_INVENTORY type column (with documented decisions for enum->String and text/integer->int)
- [x] Validation rules defined for all required fields
- [x] toJson/fromJson contracts defined for both classes (with JSON key names and example payloads)
- [x] RatingScale enum covers all 4 rating systems from FIELD_INVENTORY Section 5 (4-Point 2-tier, General 4-tier, RCF-1 4-tier, HUD 8-code)
- [x] Bidirectional validation matrix: every value round-trips correctly (17 form strings verified across 4 systems)
- [x] Lossy conversions explicitly documented (8 lossy scenarios with mitigation strategies)
- [x] Building system overlap analysis documented (4 systems: Electrical, Plumbing, HVAC, Roof + Foundation special case)
- [x] Backward compatibility mapping to InspectionDraft/InspectionSetup documented (3 direct 1:1 mappings, 1 type change, remaining fields are new)

---

## Risks and Follow-Ups

| Item | Type | Notes |
|------|------|-------|
| FormType enum needs 4 new values | Follow-up for 02-02 | `wdo`, `sinkholeInspection`, `moldAssessment`, `generalInspection` (and optionally `hudReport`) must be added to FormType enum before RatingScale ingestion tables can reference them |
| `failed` value not in original spec | Decision | Added based on RCF-1 analysis. Downstream plans (02-03, 02-04) should account for 7 RatingScale values, not 6 |
| HUD Report FormType | Open question | HUD is referenced in FIELD_INVENTORY Section 5 rating scales but is not listed as one of the 7 form types in Section 1.1. If HUD becomes a form type, its ingestion/emission tables are already designed. If not, the HUD mappings serve as documentation only. |
| 4-Point N/A scope | Clarification | N/A is only valid in the plumbing fixture matrix context. The ingestion table does not restrict by section -- callers must use appropriate values. Consider adding section-aware validation in 02-04. |
