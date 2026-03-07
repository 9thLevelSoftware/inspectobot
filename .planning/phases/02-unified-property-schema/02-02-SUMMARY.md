# Plan 02-02 Summary: PropertyData Aggregate + Backward Compat

> Phase: 02-unified-property-schema | Plan: 02-02 | Agent: Senior Developer
> Date: 2026-03-07 | Status: Complete

---

## Deliverables

| File | Content |
|------|---------|
| `02-02-PROPERTY-DATA.md` | Complete PropertyData class design with constructor, all fields, backward compat accessors, form data helpers, branchContext merge logic, copyWith, toJson/fromJson |
| `02-02-MIGRATION.md` | Binary decision on dual-format strategy, fromInspectionDraft/toInspectionDraft factories, JSON compatibility rules, migration timeline |
| `02-02-VERSIONING.md` | Schema version field, bump triggers, forward/backward compat, migration registry pattern, testing strategy |

---

## Key Decisions

### 1. Dual-Format Strategy: Strategy B (Time-Bound Coexistence)

PropertyData is optional on InspectionDraft for Phases 2-10. InspectionDraft scalar fields remain the source of truth for the existing 3-form flows. Full replacement deferred to post-Phase 10.

**Rationale**: Minimizes blast radius. Zero test breakage. Allows incremental adoption per-phase. Easy rollback (remove one optional field).

### 2. formData Map Shape: `Map<FormType, Map<String, dynamic>>`

Changed from the spec's `Map<String, dynamic>` (flat, with prefix in keys) to `Map<FormType, Map<String, dynamic>>` (two-level, FormType as outer key).

**Rationale**: Type-safe outer key prevents form prefix typos. Cleaner per-form access (`formData[FormType.fourPoint]` vs filtering by prefix). The spec's dot-notation prefix (`fourPoint.electrical.clothWiring`) is preserved in the branchContext getter for backward compat with branch predicates, but storage uses the two-level structure.

### 3. branchContext Merge: No Actual Collisions by Design

The merge precedence is: form-specific > shared > universal. However, namespace collisions between layers are structurally impossible because:
- Universal/shared keys use `snake_case` (no dots)
- Form-specific keys in branchContext are prefixed with `{formPrefix}.` (always contain a dot)

The precedence order matters only for the conceptual model and potential future evolution.

### 4. Reserved Key Documentation

21 reserved keys documented (8 universal + 13 shared) plus workflow keys (`enabled_forms`, 5 canonical branch flags). These must not appear in formData inner maps.

---

## Verification Checklist

- [x] PropertyData class accounts for every field in InspectionDraft (15 fields) and InspectionSetup (10 fields) -- verified in field coverage table
- [x] Backward compatibility accessors maintain existing API surface (clientName, propertyAddress, inspectionDate, yearBuilt)
- [x] formData Map uses FormType keys with Map<String, dynamic> values
- [x] branchContext getter has explicit merge precedence (form-specific > shared > universal) with 3 examples
- [x] Reserved key names documented (21 field keys + 6 workflow keys)
- [x] toJson/fromJson contract handles all nested types (FormType serialized via code strings, RequiredPhotoCategory via name, WizardProgressSnapshot inline, DateTime as ISO 8601)
- [x] Migration path from InspectionDraft to PropertyData is lossless for all InspectionDraft fields (inspector fields set to empty strings with documented resolution)
- [x] Binary decision made: Strategy B (Time-Bound Coexistence)
- [x] Source-of-truth is unambiguous: InspectionDraft scalars during coexistence, PropertyData post-Phase 10
- [x] Schema versioning handles loading pre-schema inspections (defaults to version 1 when schema_version absent)
- [x] No breaking changes to existing tests identified (PropertyData is purely additive; InspectionDraft gains one optional field in Phase 3)

---

## Downstream Dependencies

Plans 02-03 (Form-Specific Namespaces) and 02-04 (Conditional Logic) depend on this design:

- **02-03** needs the `formData` map structure to define FormDataKeys constants per form type.
- **02-04** needs the `branchContext` merge design to extend branch predicates for new form types.

---

## Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| Unknown FormType codes silently dropped during deserialization | Low | Documented trade-off; `_unknownFormData` field can be added if cross-version sync needed |
| Inspector fields empty on legacy migration | Low | Documented; Phase 3 provides enhanced factory with InspectorProfile |
| formData shape diverges from spec (Map<FormType,...> vs Map<String,...>) | Medium | branchContext getter reconstructs the flat prefixed format for branch predicate compatibility; downstream plans notified |
