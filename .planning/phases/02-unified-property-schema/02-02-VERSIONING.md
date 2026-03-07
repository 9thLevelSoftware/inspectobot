# Schema Versioning Strategy

> Plan: 02-02 | Phase: 02-unified-property-schema | Agent: Senior Developer
> Date: 2026-03-07

---

## 1. Version Field

`PropertyData.schemaVersion` is a non-negative integer that tracks the structural version of the PropertyData schema.

| Version | Description | Introduced In |
|---------|-------------|---------------|
| 1 | Initial schema: 8 universal + 13 shared + formData map | Phase 2/3 |

Starting at version 1 (not 0) to distinguish from "no version present" in legacy data.

---

## 2. Version Bump Triggers

A schema version bump is required when any of the following occur:

| Change Type | Bump Required? | Example |
|------------|---------------|---------|
| Adding a new optional field to UniversalPropertyFields | No | Adding `inspectorEmail` as `String?` |
| Adding a new optional field to SharedBuildingSystemFields | No | Adding `garageType` as `String?` |
| Adding new FormDataKeys constants | No | Adding `wdo.section2.visibleEvidence` |
| Adding new FormType enum values | No | Adding `FormType.wdo` |
| Renaming a field in UniversalPropertyFields | YES | `clientName` -> `insuredName` |
| Changing a field type | YES | `yearBuilt: int?` -> `yearBuilt: String?` |
| Removing a field | YES | Removing `foundationCracks` |
| Changing serialization key names | YES | `year_built` -> `construction_year` |
| Restructuring formData key format | YES | Changing from `section.field` to `section/field` |
| Changing the toJson/fromJson contract structure | YES | Moving `form_data` inside `shared` |

**Rule of thumb**: If `PropertyData.fromJson(oldJson)` would produce incorrect data without a migration function, bump the version.

---

## 3. Forward Compatibility

When `PropertyData.fromJson()` encounters data written by a newer app version:

### Unknown keys in formData

Unknown keys in the `form_data` map are preserved without validation. This allows:
- A newer app version to write form-specific keys that an older version does not understand.
- Cross-device sync where devices have different app versions.
- No data loss during round-trip serialization.

```dart
// Example: Newer app writes 'wdo.section2.visibleEvidence': true
// Older app that doesn't know FormType.wdo:
//   - The 'wdo' key in form_data fails FormType.fromCode() lookup
//   - Data is dropped from the typed Map<FormType, Map<String, dynamic>>
//   - BUT the raw JSON preserves it for re-serialization if needed

// IMPORTANT: The current implementation drops unknown form codes from the
// typed map. If full round-trip preservation is needed for unknown form
// codes, a separate _unknownFormData: Map<String, Map<String, dynamic>>
// field should be added. This is a known trade-off documented here.
```

### Unknown keys in universal/shared

`UniversalPropertyFields.fromJson()` and `SharedBuildingSystemFields.fromJson()` parse only known keys. Unknown keys in these sections are silently ignored. This is acceptable because:
1. These sections contain strongly-typed fields — unknown keys cannot be typed.
2. The `formData` map is the extensibility mechanism for new data.

### Higher schema_version

When `schema_version` is higher than `PropertyDataMigrations.currentVersion`:
1. Parse all known fields normally.
2. Preserve unknown formData keys.
3. Log a warning (not an error) via the audit system.
4. Continue normal operation with the fields the app understands.

---

## 4. Backward Compatibility

When `PropertyData.fromJson()` encounters a `schema_version` lower than current:

### Migration at Load Time

Migrations run at deserialization time, not at app startup. This means:
- No startup migration sweep needed.
- Each PropertyData instance is migrated when it is loaded.
- Migrated data is not automatically re-persisted (the caller decides when to save).

### Migration Flow

```
JSON loaded from storage/network
  |
  v
PropertyDataMigrations.migrate(json)
  |-- Read schema_version (default to 1 if absent)
  |-- Apply v1->v2 if version < 2
  |-- Apply v2->v3 if version < 3
  |-- ... sequential chain ...
  |-- Set schema_version to currentVersion
  |
  v
PropertyData.fromJson(migratedJson)
```

### Pre-Schema Data (Legacy)

Inspections created before PropertyData exists have no `schema_version` field. The migration handles this:

```dart
var version = json['schema_version'] as int? ?? 1;
```

Default to version 1 when absent. This is safe because:
- Version 1 is the initial schema.
- Legacy data that has been converted via `PropertyData.fromInspectionDraft()` already conforms to version 1 structure.

---

## 5. Migration Registry

```dart
/// Schema migration registry for PropertyData JSON.
///
/// Migrations are pure functions: Map<String, dynamic> -> Map<String, dynamic>.
/// They operate on raw JSON before type parsing, so they can rename keys,
/// restructure nesting, and adjust values.
///
/// File: lib/features/inspection/domain/property_data_migrations.dart
abstract final class PropertyDataMigrations {
  /// Current schema version. Increment when adding a new migration.
  static const int currentVersion = 1;

  /// Apply all necessary migrations to bring JSON to current version.
  ///
  /// Pure function: does not mutate the input map.
  /// Returns a new map with schema_version set to currentVersion.
  static Map<String, dynamic> migrate(Map<String, dynamic> json) {
    var version = json['schema_version'] as int? ?? 1;
    var data = Map<String, dynamic>.from(json);

    // Migration chain (add new migrations here as versions increment):
    //
    // if (version < 2) {
    //   data = _migrateV1ToV2(data);
    //   version = 2;
    // }
    // if (version < 3) {
    //   data = _migrateV2ToV3(data);
    //   version = 3;
    // }

    data['schema_version'] = currentVersion;
    return data;
  }

  // ---------------------------------------------------------------------------
  // Future migration functions go below. Each is a pure function.
  // ---------------------------------------------------------------------------

  // Example of what a future migration would look like:
  //
  // /// Migrate v1 to v2: Rename 'roof_condition' to 'roof_overall_condition'
  // /// in the shared section.
  // static Map<String, dynamic> _migrateV1ToV2(Map<String, dynamic> json) {
  //   final shared = json['shared'] as Map<String, dynamic>?;
  //   if (shared != null && shared.containsKey('roof_condition')) {
  //     shared['roof_overall_condition'] = shared.remove('roof_condition');
  //   }
  //   return json;
  // }
}
```

### Migration Design Constraints

1. **Pure functions**: Each migration takes a `Map<String, dynamic>` and returns a new `Map<String, dynamic>`. No side effects.

2. **Sequential application**: Migrations apply in strict version order. Skipping versions is not supported. A v1 document always goes v1->v2->v3, never v1->v3 directly.

3. **Idempotent-safe**: Each migration checks for the presence of the data it wants to transform before acting. If the expected key is absent, it no-ops.

4. **No external dependencies**: Migration functions do not call services, read files, or query databases. They operate purely on the JSON structure.

5. **Testable in isolation**: Each migration function can be unit-tested by providing input JSON at version N and asserting output JSON at version N+1.

---

## 6. Testing Strategy

### Unit Tests for Migrations

```dart
// test/features/inspection/domain/property_data_migrations_test.dart

void main() {
  group('PropertyDataMigrations', () {
    test('migrate sets currentVersion on data without schema_version', () {
      final input = <String, dynamic>{
        'universal': { 'property_address': '123 Main St', /* ... */ },
      };
      final result = PropertyDataMigrations.migrate(input);
      expect(result['schema_version'], PropertyDataMigrations.currentVersion);
    });

    test('migrate is no-op for current version', () {
      final input = <String, dynamic>{
        'schema_version': PropertyDataMigrations.currentVersion,
        'universal': { 'property_address': '123 Main St', /* ... */ },
      };
      final result = PropertyDataMigrations.migrate(input);
      expect(result['schema_version'], PropertyDataMigrations.currentVersion);
      // All other fields unchanged
    });

    test('migrate handles future version gracefully', () {
      final input = <String, dynamic>{
        'schema_version': 999,
        'universal': { 'property_address': '123 Main St', /* ... */ },
      };
      // Should not throw; sets to currentVersion
      final result = PropertyDataMigrations.migrate(input);
      expect(result['schema_version'], PropertyDataMigrations.currentVersion);
    });
  });
}
```

### Round-Trip Tests

```dart
test('PropertyData survives JSON round-trip', () {
  final original = PropertyData(/* fully populated */);
  final json = original.toJson();
  final restored = PropertyData.fromJson(json);
  // Assert all fields equal
});

test('PropertyData from InspectionDraft round-trips through toInspectionDraft', () {
  final draft = InspectionDraft(/* fully populated */);
  final propertyData = PropertyData.fromInspectionDraft(draft);
  final restoredDraft = propertyData.toInspectionDraft();
  expect(restoredDraft.inspectionId, draft.inspectionId);
  expect(restoredDraft.clientName, draft.clientName);
  // ... assert all scalar fields
});
```

---

## 7. Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Unknown FormType codes dropped from typed map | Data loss for form codes added by newer app | Document as known trade-off; add `_unknownFormData` field if cross-version sync becomes critical |
| Migration chain grows long over many versions | Slow deserialization | Batch migrations periodically (e.g., collapse v1-v5 into a single v1-v5 migration after v5 is stable) |
| Schema version not persisted after migration | Repeated migration on every load | Caller should re-persist after loading if version changed |
| Future migration introduces bug | Corrupts data silently | All migrations are pure functions with unit tests; migration output is validated by fromJson parsing |
