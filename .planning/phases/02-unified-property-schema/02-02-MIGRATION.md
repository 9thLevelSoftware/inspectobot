# Migration Strategy: InspectionDraft to PropertyData

> Plan: 02-02 | Phase: 02-unified-property-schema | Agent: Senior Developer
> Date: 2026-03-07

---

## 1. Binary Decision: Dual-Format Strategy

### Decision: Strategy B (Time-Bound Coexistence)

**PropertyData is optional on InspectionDraft for Phases 2-10. Full replacement occurs post-Phase 10.**

### Rationale

1. **Risk**: InspectionDraft is referenced in 10+ files across domain, data, and presentation layers. Immediate replacement (Strategy A) would require touching every consumer simultaneously, which is a large blast radius for a design phase.

2. **Existing tests**: 81 test files exist. Strategy A would require updating tests that reference InspectionDraft fields directly. Strategy B guarantees zero test breakage.

3. **Incremental adoption**: The 10-phase roadmap introduces form types incrementally (Phases 4-8). Strategy B lets each phase adopt PropertyData at its own pace. New form types use PropertyData from day one; existing 3-form flows continue using InspectionDraft scalars until explicitly migrated.

4. **Rollback**: If PropertyData design proves inadequate during implementation, Strategy B allows reverting without data loss since InspectionDraft scalar fields remain authoritative.

5. **Spec alignment**: The spec document (Section 7.2) explicitly describes PropertyData as "opt-in" and says "Eventually (post-Phase 10), the legacy scalar fields on InspectionDraft can be deprecated."

### Source of Truth During Coexistence

**InspectionDraft scalar fields remain the authoritative source of truth** for the existing 3-form flows until explicit migration.

- For existing code paths: Read from `draft.clientName`, `draft.propertyAddress`, etc.
- For new code paths: Read from `draft.propertyData.clientName`, `draft.propertyData.propertyAddress`, etc.
- The session controller (Phase 3 implementation) synchronizes both representations: when a scalar field changes, the corresponding PropertyData field is updated, and vice versa.

### Transition Tests

The following invariants must hold during the coexistence period and will be enforced by tests:

1. **Round-trip equivalence**: `PropertyData.fromInspectionDraft(draft).toInspectionDraft()` produces a draft with identical scalar field values.
2. **Accessor parity**: `draft.clientName == draft.propertyData.clientName` for all fields that exist on both.
3. **JSON round-trip**: `PropertyData.fromJson(propertyData.toJson())` is lossless for all field types.
4. **Legacy JSON compatibility**: `InspectionSetup.fromJson(legacyJson)` continues to work when `property_data` key is absent.
5. **New JSON compatibility**: `InspectionSetup.fromJson(newJson)` correctly hydrates `PropertyData` when `property_data` key is present.

### Rollback Plan

If PropertyData needs to be reverted:
1. Remove the `PropertyData? propertyData` field from InspectionDraft.
2. Remove PropertyData-related code from InspectionSetup.toJson/fromJson.
3. Existing scalar fields on InspectionDraft continue to work as before.
4. No data migration needed — scalar fields were never removed.
5. Estimated rollback effort: < 1 day of work.

---

## 2. Factory Constructor: fromInspectionDraft

```dart
/// Creates a PropertyData from an existing InspectionDraft.
/// Used for migrating inspections created before Phase 2.
///
/// Note: Inspector fields (inspectorName, inspectorCompany,
/// inspectorLicenseNumber) cannot be populated from InspectionDraft
/// alone — they require InspectorProfile from the identity module.
/// These are set to empty strings and should be populated separately.
factory PropertyData.fromInspectionDraft(InspectionDraft draft) {
  return PropertyData(
    schemaVersion: 1,
    inspectionId: draft.inspectionId,
    organizationId: draft.organizationId,
    userId: draft.userId,
    clientEmail: draft.clientEmail,
    clientPhone: draft.clientPhone,
    enabledForms: draft.enabledForms,
    wizardSnapshot: draft.wizardSnapshot,
    initialStepIndex: draft.initialStepIndex,
    universal: UniversalPropertyFields(
      propertyAddress: draft.propertyAddress,
      inspectionDate: draft.inspectionDate,
      inspectorName: '',       // Populated from InspectorProfile
      inspectorCompany: '',    // Populated from InspectorProfile
      inspectorLicenseNumber: '', // Populated from InspectorProfile
      clientName: draft.clientName,
    ),
    shared: SharedBuildingSystemFields(
      yearBuilt: draft.yearBuilt,
    ),
    formData: const <FormType, Map<String, dynamic>>{},
    capturedCategories: Set<RequiredPhotoCategory>.from(draft.capturedCategories),
    capturedPhotoPaths: Map<RequiredPhotoCategory, String>.from(draft.capturedPhotoPaths),
    capturedEvidencePaths: Map<String, List<String>>.from(draft.capturedEvidencePaths),
  );
}
```

### Fields Not Migratable from InspectionDraft Alone

| Field | Reason | Resolution |
|-------|--------|------------|
| `inspectorName` | Comes from InspectorProfile, not InspectionDraft | Set to `''`; populated in Phase 3 via identity module lookup |
| `inspectorCompany` | Comes from InspectorProfile | Set to `''`; same resolution |
| `inspectorLicenseNumber` | Comes from InspectorProfile | Set to `''`; same resolution |
| `inspectorSignaturePath` | Captured during wizard flow | Set to `null`; populated during wizard |
| `comments` | New field, not on InspectionDraft | Set to `null` |
| All SharedBuildingSystemFields except yearBuilt | Not present on InspectionDraft | Set to `null` |
| All formData | Not present on InspectionDraft | Set to empty map |

### Enhanced Factory with InspectorProfile

For Phase 3 implementation, a richer factory will be available:

```dart
/// Creates a PropertyData from an InspectionDraft with inspector profile.
factory PropertyData.fromInspectionDraftWithProfile(
  InspectionDraft draft,
  InspectorProfile profile,
) {
  return PropertyData.fromInspectionDraft(draft).copyWith(
    universal: UniversalPropertyFields(
      propertyAddress: draft.propertyAddress,
      inspectionDate: draft.inspectionDate,
      inspectorName: profile.fullName,
      inspectorCompany: profile.companyName,
      inspectorLicenseNumber: profile.licenseNumber,
      clientName: draft.clientName,
    ),
    shared: SharedBuildingSystemFields(
      yearBuilt: draft.yearBuilt,
      inspectorPhone: profile.phoneNumber,
    ),
  );
}
```

---

## 3. Reverse Conversion: toInspectionDraft

```dart
/// Converts PropertyData back to an InspectionDraft.
/// Used for backward compatibility with existing code paths.
///
/// This is a lossy conversion — PropertyData contains fields
/// (universal inspector fields, shared building fields, formData)
/// that have no representation on InspectionDraft.
InspectionDraft toInspectionDraft() {
  final draft = InspectionDraft(
    inspectionId: inspectionId,
    organizationId: organizationId,
    userId: userId,
    clientName: universal.clientName,
    clientEmail: clientEmail,
    clientPhone: clientPhone,
    propertyAddress: universal.propertyAddress,
    inspectionDate: universal.inspectionDate,
    yearBuilt: shared.yearBuilt ?? 0,
    enabledForms: enabledForms,
    wizardSnapshot: wizardSnapshot,
    initialStepIndex: initialStepIndex,
  );

  // Restore mutable media state
  draft.capturedCategories.addAll(capturedCategories);
  for (final entry in capturedPhotoPaths.entries) {
    draft.capturedPhotoPaths[entry.key] = entry.value;
  }
  for (final entry in capturedEvidencePaths.entries) {
    draft.capturedEvidencePaths[entry.key] = List<String>.from(entry.value);
  }

  return draft;
}
```

### Lossy Fields (PropertyData -> InspectionDraft)

The following PropertyData fields are lost when converting to InspectionDraft:

| Lost Field | Reason |
|-----------|--------|
| `universal.inspectorName` | No field on InspectionDraft |
| `universal.inspectorCompany` | No field on InspectionDraft |
| `universal.inspectorLicenseNumber` | No field on InspectionDraft |
| `universal.inspectorSignaturePath` | No field on InspectionDraft |
| `universal.comments` | No field on InspectionDraft |
| `shared.*` (except yearBuilt) | No fields on InspectionDraft |
| `formData` (entire map) | No field on InspectionDraft |
| `schemaVersion` | No field on InspectionDraft |

This is acceptable because:
1. During coexistence, the InspectionDraft scalar fields remain the source of truth.
2. The toInspectionDraft() method is used for backward compat with existing code, which never needed these fields.
3. New code paths that need inspector/shared/form data access PropertyData directly.

---

## 4. JSON Compatibility

### Existing JSON Format (InspectionSetup.toJson)

```json
{
  "id": "abc-123",
  "organization_id": "org-1",
  "user_id": "user-1",
  "client_name": "Jane Doe",
  "client_email": "jane@example.com",
  "client_phone": "305-555-1234",
  "property_address": "123 Main St",
  "inspection_date": "2026-03-07",
  "year_built": 1995,
  "forms_enabled": ["four_point", "roof_condition"]
}
```

### Extended JSON Format (Phase 3+)

```json
{
  "id": "abc-123",
  "...existing keys unchanged...",
  "property_data": {
    "schema_version": 1,
    "inspection_id": "abc-123",
    "organization_id": "org-1",
    "user_id": "user-1",
    "client_email": "jane@example.com",
    "client_phone": "305-555-1234",
    "forms_enabled": ["four_point", "roof_condition"],
    "wizard_snapshot": { "..." },
    "initial_step_index": 0,
    "universal": { "..." },
    "shared": { "..." },
    "form_data": { "..." },
    "captured_categories": [],
    "captured_photo_paths": {},
    "captured_evidence_paths": {}
  }
}
```

### Deserialization Rules

`InspectionSetup.fromJson()` behavior (Phase 3 update):

```dart
factory InspectionSetup.fromJson(Map<String, dynamic> json) {
  // ... existing parsing (unchanged) ...
  final setup = InspectionSetup(/* existing fields */);

  // NEW: If property_data key exists, hydrate PropertyData.
  // If absent, callers can construct PropertyData from scalar fields
  // via PropertyData.fromInspectionDraft().
  return setup;
}
```

### No-Breaking-Change Guarantees

1. `InspectionSetup.toJson()` output retains all existing keys with identical types.
2. `InspectionSetup.fromJson()` accepts payloads with or without `property_data`.
3. `InspectionWizardProgress.fromJson()` is unchanged.
4. Supabase `inspections` table requires no schema migration (JSONB is flexible).
5. SyncOperation payloads remain backward-compatible (property_data is additive).

---

## 5. InspectionDraft Modification (Phase 3)

When Phase 3 implements PropertyData in code, InspectionDraft gains one field:

```dart
class InspectionDraft {
  InspectionDraft({
    // ... all existing parameters unchanged ...
    this.propertyData,  // NEW: optional
  });

  // ... all existing fields unchanged ...

  /// Optional structured property data. Present for inspections created
  /// after Phase 3. For older inspections, construct via
  /// PropertyData.fromInspectionDraft(this).
  final PropertyData? propertyData;

  // ... existing mutable fields unchanged ...
}
```

No existing fields are removed, renamed, or made nullable. The `propertyData` field is purely additive.

---

## 6. Migration Timeline

| Phase | InspectionDraft | PropertyData | Source of Truth |
|-------|----------------|-------------|-----------------|
| 1-2 (current) | All fields, no propertyData | Design only (this document) | InspectionDraft |
| 3 (implementation) | Gains `propertyData?` field | Code implemented | InspectionDraft scalars (synced to PropertyData) |
| 4-8 (new forms) | Unchanged | New form types write to formData | InspectionDraft scalars for 3 existing forms; PropertyData for new forms |
| 9-10 (polish) | Unchanged | Full adoption | PropertyData (scalars maintained for compat) |
| Post-10 (future) | Scalar fields deprecated | Full authority | PropertyData |
