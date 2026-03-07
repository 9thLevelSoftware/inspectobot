# PropertyData Aggregate Class Design

> Plan: 02-02 | Phase: 02-unified-property-schema | Agent: Senior Developer
> Date: 2026-03-07

---

## 1. Purpose

`PropertyData` is the top-level data envelope that wraps all property-related inspection data into a single aggregate. It combines:

- **Identity fields** from InspectionDraft (inspectionId, organizationId, userId)
- **App-only fields** not on any paper form (clientEmail, clientPhone)
- **Workflow state** from InspectionDraft (enabledForms, wizardSnapshot, initialStepIndex)
- **Typed shared data** via UniversalPropertyFields and SharedBuildingSystemFields
- **Form-specific data** via `Map<FormType, Map<String, dynamic>>`
- **Media state** from InspectionDraft (capturedCategories, capturedPhotoPaths, capturedEvidencePaths)
- **Schema metadata** for versioning

PropertyData is the schema-level successor to the property/client data currently scattered across `InspectionDraft` and `InspectionSetup`.

---

## 2. Complete Dart Class Design

```dart
/// Top-level property data aggregate. Wraps identity, workflow, typed shared
/// fields, and a per-form-type map for form-specific data.
///
/// File: lib/features/inspection/domain/property_data.dart
///
/// Relationship to InspectionDraft:
///   InspectionDraft holds both property data AND workflow state.
///   PropertyData absorbs the property/client data portion while
///   InspectionDraft retains an optional reference to it.
///   See Section 4 (Relationship to InspectionDraft) for details.
class PropertyData {
  PropertyData({
    // --- Core identity ---
    required this.inspectionId,
    required this.organizationId,
    required this.userId,

    // --- App-only fields ---
    this.clientEmail = '',
    this.clientPhone = '',

    // --- Workflow state ---
    required this.enabledForms,
    WizardProgressSnapshot? wizardSnapshot,
    int? initialStepIndex,

    // --- Typed shared data ---
    required this.universal,
    this.shared = const SharedBuildingSystemFields(),

    // --- Form-specific data ---
    this.formData = const <FormType, Map<String, dynamic>>{},

    // --- Media state ---
    Set<RequiredPhotoCategory>? capturedCategories,
    Map<RequiredPhotoCategory, String>? capturedPhotoPaths,
    Map<String, List<String>>? capturedEvidencePaths,

    // --- Schema metadata ---
    this.schemaVersion = 1,
  })  : wizardSnapshot = wizardSnapshot ?? WizardProgressSnapshot.empty,
        initialStepIndex = initialStepIndex ?? 0,
        capturedCategories = capturedCategories ?? <RequiredPhotoCategory>{},
        capturedPhotoPaths = capturedPhotoPaths ?? <RequiredPhotoCategory, String>{},
        capturedEvidencePaths = capturedEvidencePaths ?? <String, List<String>>{};

  // ---------------------------------------------------------------------------
  // Core identity (from InspectionDraft)
  // ---------------------------------------------------------------------------

  final String inspectionId;
  final String organizationId;
  final String userId;

  // ---------------------------------------------------------------------------
  // App-only fields (not on any paper form)
  // ---------------------------------------------------------------------------

  /// Client email for delivery/communication. Not printed on any form.
  final String clientEmail;

  /// Client phone for delivery/communication. Not printed on any form.
  final String clientPhone;

  // ---------------------------------------------------------------------------
  // Workflow state (from InspectionDraft)
  // ---------------------------------------------------------------------------

  /// Which inspection forms are active for this inspection.
  final Set<FormType> enabledForms;

  /// Current wizard progress: step index, completion map, branch context.
  final WizardProgressSnapshot wizardSnapshot;

  /// Initial wizard step to resume from.
  final int initialStepIndex;

  // ---------------------------------------------------------------------------
  // Typed shared data
  // ---------------------------------------------------------------------------

  /// The 8 universal fields (address, date, inspector, client, comments).
  /// Present on all/nearly all 7 form types.
  final UniversalPropertyFields universal;

  /// The 13 shared building-system fields (year built, roof, electrical, etc.).
  /// Present on 2-4 form types each.
  final SharedBuildingSystemFields shared;

  // ---------------------------------------------------------------------------
  // Form-specific data
  // ---------------------------------------------------------------------------

  /// Per-form-type map of form-specific fields.
  /// Keys are FormType enum values. Values are flat maps with dot-notation
  /// string keys (e.g., 'electrical.clothWiring', 'q3.roofDeckAttachment').
  ///
  /// Note: Keys within each form map use {section}.{fieldName} format,
  /// WITHOUT the form prefix. The form prefix is implicit via the FormType key.
  /// Example: formData[FormType.fourPoint]['electrical.clothWiring']
  ///   NOT: formData[FormType.fourPoint]['fourPoint.electrical.clothWiring']
  final Map<FormType, Map<String, dynamic>> formData;

  // ---------------------------------------------------------------------------
  // Media state (from InspectionDraft)
  // ---------------------------------------------------------------------------

  /// Categories of evidence that have been captured.
  final Set<RequiredPhotoCategory> capturedCategories;

  /// Map of category -> local file path for captured photos.
  final Map<RequiredPhotoCategory, String> capturedPhotoPaths;

  /// Map of requirement key -> list of local file paths for captured evidence.
  final Map<String, List<String>> capturedEvidencePaths;

  // ---------------------------------------------------------------------------
  // Schema metadata
  // ---------------------------------------------------------------------------

  /// Schema version for forward/backward compatibility.
  /// Current version: 1.
  /// See 02-02-VERSIONING.md for migration strategy.
  final int schemaVersion;

  // ---------------------------------------------------------------------------
  // Backward compatibility accessors
  // ---------------------------------------------------------------------------

  /// Shorthand for universal.clientName.
  /// Maintains API surface parity with InspectionDraft.clientName.
  String get clientName => universal.clientName;

  /// Shorthand for universal.propertyAddress.
  /// Maintains API surface parity with InspectionDraft.propertyAddress.
  String get propertyAddress => universal.propertyAddress;

  /// Shorthand for universal.inspectionDate.
  /// Maintains API surface parity with InspectionDraft.inspectionDate.
  DateTime get inspectionDate => universal.inspectionDate;

  /// Shorthand for shared.yearBuilt.
  /// Maintains API surface parity with InspectionDraft.yearBuilt.
  /// Returns 0 if yearBuilt is null (matching InspectionDraft's non-nullable int).
  int get yearBuilt => shared.yearBuilt ?? 0;

  // ---------------------------------------------------------------------------
  // Form data helpers
  // ---------------------------------------------------------------------------

  /// Gets a form-specific value by FormType and key.
  /// Returns null if the form has no data or the key does not exist.
  /// Returns null if the value is not of type T.
  ///
  /// Example:
  ///   final clothWiring = data.getFormValue<bool>(
  ///     FormType.fourPoint, 'electrical.clothWiring',
  ///   );
  T? getFormValue<T>(FormType form, String key) {
    final map = formData[form];
    if (map == null) return null;
    final value = map[key];
    return value is T ? value : null;
  }

  /// Returns a new PropertyData with the given form field updated.
  /// Creates the form map if it does not exist.
  ///
  /// Example:
  ///   final updated = data.setFormValue(
  ///     FormType.fourPoint, 'electrical.clothWiring', true,
  ///   );
  PropertyData setFormValue(FormType form, String key, dynamic value) {
    final updatedFormData = Map<FormType, Map<String, dynamic>>.from(formData);
    final formMap = Map<String, dynamic>.from(updatedFormData[form] ?? {});
    formMap[key] = value;
    updatedFormData[form] = formMap;
    return copyWith(formData: updatedFormData);
  }

  /// Returns a new PropertyData with multiple form fields updated.
  PropertyData setFormValues(FormType form, Map<String, dynamic> updates) {
    final updatedFormData = Map<FormType, Map<String, dynamic>>.from(formData);
    final formMap = Map<String, dynamic>.from(updatedFormData[form] ?? {});
    formMap.addAll(updates);
    updatedFormData[form] = formMap;
    return copyWith(formData: updatedFormData);
  }

  // ---------------------------------------------------------------------------
  // branchContext getter — merged view
  // ---------------------------------------------------------------------------

  /// Returns a merged view of universal, shared, and form-specific data
  /// suitable for passing to FormRequirements branch predicates.
  ///
  /// MERGE PRECEDENCE (highest to lowest):
  ///   1. Form-specific data from formData (all forms flattened, with prefix)
  ///   2. Shared fields (from SharedBuildingSystemFields, as snake_case keys)
  ///   3. Universal fields (from UniversalPropertyFields, as snake_case keys)
  ///
  /// If the same key appears at multiple levels, the higher-priority source wins.
  ///
  /// RESERVED KEY NAMES:
  ///   The following keys are reserved and MUST NOT be used in formData maps:
  ///   - 'property_address' (universal)
  ///   - 'inspection_date' (universal)
  ///   - 'inspector_name' (universal)
  ///   - 'inspector_company' (universal)
  ///   - 'inspector_license_number' (universal)
  ///   - 'client_name' (universal)
  ///   - 'inspector_signature_path' (universal)
  ///   - 'comments' (universal)
  ///   - 'year_built' (shared)
  ///   - 'policy_number' (shared)
  ///   - 'inspector_phone' (shared)
  ///   - 'signature_date' (shared)
  ///   - 'roof_covering_material' (shared)
  ///   - 'roof_age' (shared)
  ///   - 'roof_condition' (shared)
  ///   - 'electrical_panel_type' (shared)
  ///   - 'electrical_panel_amps' (shared)
  ///   - 'plumbing_pipe_material' (shared)
  ///   - 'water_heater_type' (shared)
  ///   - 'hvac_type' (shared)
  ///   - 'foundation_cracks' (shared)
  ///   - 'enabled_forms' (workflow — injected by existing controller logic)
  ///   - All keys in FormRequirements.canonicalBranchFlags
  ///
  /// EXAMPLES:
  ///
  /// Example 1 — Simple merge, no conflicts:
  ///   universal: { property_address: '123 Main St', client_name: 'Jane' }
  ///   shared:    { year_built: 1995, roof_age: 12 }
  ///   formData:  { FormType.fourPoint: { 'electrical.clothWiring': true } }
  ///   => branchContext: {
  ///        'property_address': '123 Main St',
  ///        'client_name': 'Jane',
  ///        'year_built': 1995,
  ///        'roof_age': 12,
  ///        'fourPoint.electrical.clothWiring': true,
  ///      }
  ///
  /// Example 2 — Shared overrides universal (year_built in both):
  ///   universal: { property_address: '456 Oak Ave' }
  ///   shared:    { year_built: 2001 }
  ///   formData:  {}
  ///   => branchContext: {
  ///        'property_address': '456 Oak Ave',
  ///        'year_built': 2001,
  ///      }
  ///
  /// Example 3 — Form-specific overrides shared:
  ///   shared:   { roof_condition: RatingScale.satisfactory }
  ///   formData: { FormType.roofCondition: { 'roof.conditionRating': 'poor' } }
  ///   => branchContext: {
  ///        'roof_condition': 'satisfactory',  // shared key (snake_case)
  ///        'roofCondition.roof.conditionRating': 'poor',  // form-specific (prefixed)
  ///      }
  ///   Note: These are DIFFERENT keys. The form-specific key uses the
  ///   {formPrefix}.{section}.{field} namespace, so no actual collision occurs.
  ///   This is by design — the dot-notation prefix prevents namespace collisions.
  ///
  Map<String, dynamic> get branchContext {
    final merged = <String, dynamic>{};

    // Layer 1 (lowest priority): Universal fields
    merged.addAll(universal.toJson());

    // Layer 2: Shared fields (overwrites universal on conflict)
    final sharedJson = shared.toJson();
    for (final entry in sharedJson.entries) {
      if (entry.value != null) {
        merged[entry.key] = entry.value;
      }
    }

    // Layer 3 (highest priority): Form-specific data (prefixed with form code)
    for (final entry in formData.entries) {
      final prefix = _formPrefix(entry.key);
      for (final field in entry.value.entries) {
        merged['$prefix.${field.key}'] = field.value;
      }
    }

    return merged;
  }

  /// Maps FormType to its dot-notation prefix for branchContext keys.
  static String _formPrefix(FormType form) {
    switch (form) {
      case FormType.fourPoint:
        return 'fourPoint';
      case FormType.roofCondition:
        return 'roofCondition';
      case FormType.windMitigation:
        return 'windMit';
      // Future form types will be added here:
      // case FormType.wdo: return 'wdo';
      // case FormType.sinkholeInspection: return 'sinkhole';
      // case FormType.moldAssessment: return 'mold';
      // case FormType.generalInspection: return 'general';
    }
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  PropertyData copyWith({
    String? inspectionId,
    String? organizationId,
    String? userId,
    String? clientEmail,
    String? clientPhone,
    Set<FormType>? enabledForms,
    WizardProgressSnapshot? wizardSnapshot,
    int? initialStepIndex,
    UniversalPropertyFields? universal,
    SharedBuildingSystemFields? shared,
    Map<FormType, Map<String, dynamic>>? formData,
    Set<RequiredPhotoCategory>? capturedCategories,
    Map<RequiredPhotoCategory, String>? capturedPhotoPaths,
    Map<String, List<String>>? capturedEvidencePaths,
    int? schemaVersion,
  }) {
    return PropertyData(
      inspectionId: inspectionId ?? this.inspectionId,
      organizationId: organizationId ?? this.organizationId,
      userId: userId ?? this.userId,
      clientEmail: clientEmail ?? this.clientEmail,
      clientPhone: clientPhone ?? this.clientPhone,
      enabledForms: enabledForms ?? this.enabledForms,
      wizardSnapshot: wizardSnapshot ?? this.wizardSnapshot,
      initialStepIndex: initialStepIndex ?? this.initialStepIndex,
      universal: universal ?? this.universal,
      shared: shared ?? this.shared,
      formData: formData ?? this.formData,
      capturedCategories: capturedCategories ?? this.capturedCategories,
      capturedPhotoPaths: capturedPhotoPaths ?? this.capturedPhotoPaths,
      capturedEvidencePaths: capturedEvidencePaths ?? this.capturedEvidencePaths,
      schemaVersion: schemaVersion ?? this.schemaVersion,
    );
  }

  // ---------------------------------------------------------------------------
  // Serialization
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      'schema_version': schemaVersion,

      // Identity
      'inspection_id': inspectionId,
      'organization_id': organizationId,
      'user_id': userId,

      // App-only
      'client_email': clientEmail,
      'client_phone': clientPhone,

      // Workflow
      'forms_enabled': enabledForms.map((f) => f.code).toList(growable: false),
      'wizard_snapshot': {
        'last_step_index': wizardSnapshot.lastStepIndex,
        'completion': wizardSnapshot.completion,
        'branch_context': wizardSnapshot.branchContext,
        'status': wizardSnapshot.status == WizardProgressStatus.complete
            ? 'complete'
            : 'in_progress',
      },
      'initial_step_index': initialStepIndex,

      // Typed shared data
      'universal': universal.toJson(),
      'shared': shared.toJson(),

      // Form-specific data
      'form_data': {
        for (final entry in formData.entries)
          entry.key.code: Map<String, dynamic>.from(entry.value),
      },

      // Media state
      'captured_categories': capturedCategories
          .map((c) => c.name)
          .toList(growable: false),
      'captured_photo_paths': {
        for (final entry in capturedPhotoPaths.entries)
          entry.key.name: entry.value,
      },
      'captured_evidence_paths': {
        for (final entry in capturedEvidencePaths.entries)
          entry.key: List<String>.from(entry.value),
      },
    };
  }

  factory PropertyData.fromJson(Map<String, dynamic> json) {
    // Apply migrations if needed
    final migrated = PropertyDataMigrations.migrate(json);

    // Parse enabled forms
    final formsRaw = (migrated['forms_enabled'] as List<dynamic>?)
        ?.cast<String>() ?? [];
    final enabledForms = FormType.fromCodes(formsRaw);

    // Parse wizard snapshot
    final snapshotJson = migrated['wizard_snapshot'] as Map<String, dynamic>?;
    final wizardSnapshot = snapshotJson != null
        ? _parseWizardSnapshot(snapshotJson)
        : WizardProgressSnapshot.empty;

    // Parse form data (keyed by form code string -> convert to FormType)
    final formDataRaw = migrated['form_data'] as Map<String, dynamic>?;
    final formData = <FormType, Map<String, dynamic>>{};
    if (formDataRaw != null) {
      for (final entry in formDataRaw.entries) {
        try {
          final formType = FormType.fromCode(entry.key);
          formData[formType] = Map<String, dynamic>.from(
            entry.value as Map,
          );
        } on ArgumentError {
          // Unknown form code — preserve data in a best-effort way.
          // This supports forward compatibility (newer app wrote a form
          // type this version doesn't know about). Data is silently dropped
          // from the typed map but preserved in the raw JSON.
        }
      }
    }

    // Parse captured categories
    final categoriesRaw = (migrated['captured_categories'] as List<dynamic>?)
        ?.cast<String>() ?? [];
    final capturedCategories = <RequiredPhotoCategory>{};
    for (final name in categoriesRaw) {
      try {
        capturedCategories.add(
          RequiredPhotoCategory.values.firstWhere((c) => c.name == name),
        );
      } catch (_) {
        // Unknown category — skip (forward compat)
      }
    }

    // Parse captured photo paths
    final photoPathsRaw = migrated['captured_photo_paths'] as Map<String, dynamic>?;
    final capturedPhotoPaths = <RequiredPhotoCategory, String>{};
    if (photoPathsRaw != null) {
      for (final entry in photoPathsRaw.entries) {
        try {
          final category = RequiredPhotoCategory.values
              .firstWhere((c) => c.name == entry.key);
          capturedPhotoPaths[category] = entry.value as String;
        } catch (_) {
          // Unknown category — skip
        }
      }
    }

    // Parse captured evidence paths
    final evidencePathsRaw = migrated['captured_evidence_paths']
        as Map<String, dynamic>?;
    final capturedEvidencePaths = <String, List<String>>{};
    if (evidencePathsRaw != null) {
      for (final entry in evidencePathsRaw.entries) {
        capturedEvidencePaths[entry.key] = (entry.value as List<dynamic>)
            .cast<String>()
            .toList();
      }
    }

    return PropertyData(
      schemaVersion: migrated['schema_version'] as int? ?? 1,
      inspectionId: migrated['inspection_id'] as String,
      organizationId: migrated['organization_id'] as String,
      userId: migrated['user_id'] as String,
      clientEmail: (migrated['client_email'] as String?) ?? '',
      clientPhone: (migrated['client_phone'] as String?) ?? '',
      enabledForms: enabledForms,
      wizardSnapshot: wizardSnapshot,
      initialStepIndex: (migrated['initial_step_index'] as int?) ?? 0,
      universal: UniversalPropertyFields.fromJson(
        migrated['universal'] as Map<String, dynamic>,
      ),
      shared: migrated['shared'] != null
          ? SharedBuildingSystemFields.fromJson(
              migrated['shared'] as Map<String, dynamic>,
            )
          : const SharedBuildingSystemFields(),
      formData: formData,
      capturedCategories: capturedCategories,
      capturedPhotoPaths: capturedPhotoPaths,
      capturedEvidencePaths: capturedEvidencePaths,
    );
  }

  /// Parses a wizard snapshot from JSON.
  static WizardProgressSnapshot _parseWizardSnapshot(
    Map<String, dynamic> json,
  ) {
    final completion = <String, bool>{};
    final completionRaw = json['completion'];
    if (completionRaw is Map) {
      completionRaw.forEach((key, value) {
        if (key is String && value is bool) {
          completion[key] = value;
        }
      });
    }

    final branchContext = <String, dynamic>{};
    final branchRaw = json['branch_context'];
    if (branchRaw is Map) {
      branchRaw.forEach((key, value) {
        if (key is String) {
          branchContext[key] = value;
        }
      });
    }

    return WizardProgressSnapshot(
      lastStepIndex: (json['last_step_index'] as int?) ?? 0,
      completion: completion,
      branchContext: branchContext,
      status: json['status'] == 'complete'
          ? WizardProgressStatus.complete
          : WizardProgressStatus.inProgress,
    );
  }
}
```

---

## 3. Field Coverage Verification

### Fields from InspectionDraft — All Accounted For

| InspectionDraft Field | PropertyData Location | Notes |
|----------------------|----------------------|-------|
| `inspectionId` | `inspectionId` | Direct 1:1 |
| `organizationId` | `organizationId` | Direct 1:1 |
| `userId` | `userId` | Direct 1:1 |
| `clientName` | `universal.clientName` | Accessor: `propertyData.clientName` |
| `clientEmail` | `clientEmail` | Direct 1:1 (app-only field) |
| `clientPhone` | `clientPhone` | Direct 1:1 (app-only field) |
| `propertyAddress` | `universal.propertyAddress` | Accessor: `propertyData.propertyAddress` |
| `inspectionDate` | `universal.inspectionDate` | Accessor: `propertyData.inspectionDate` |
| `yearBuilt` | `shared.yearBuilt` | Accessor: `propertyData.yearBuilt` (returns 0 if null) |
| `enabledForms` | `enabledForms` | Direct 1:1 |
| `wizardSnapshot` | `wizardSnapshot` | Direct 1:1 |
| `initialStepIndex` | `initialStepIndex` | Direct 1:1 |
| `capturedCategories` | `capturedCategories` | Direct 1:1 |
| `capturedPhotoPaths` | `capturedPhotoPaths` | Direct 1:1 |
| `capturedEvidencePaths` | `capturedEvidencePaths` | Direct 1:1 |

### Fields from InspectionSetup — All Accounted For

| InspectionSetup Field | PropertyData Location | Notes |
|----------------------|----------------------|-------|
| `id` | `inspectionId` | Name normalized |
| `organizationId` | `organizationId` | Direct 1:1 |
| `userId` | `userId` | Direct 1:1 |
| `clientName` | `universal.clientName` | Via universal |
| `clientEmail` | `clientEmail` | Direct 1:1 |
| `clientPhone` | `clientPhone` | Direct 1:1 |
| `propertyAddress` | `universal.propertyAddress` | Via universal |
| `inspectionDate` | `universal.inspectionDate` | Via universal |
| `yearBuilt` | `shared.yearBuilt` | Via shared |
| `enabledForms` | `enabledForms` | Direct 1:1 |

---

## 4. Relationship to InspectionDraft

`InspectionDraft` currently holds both property data AND workflow state in flat fields. `PropertyData` absorbs all of these fields into a structured aggregate. The relationship is defined by the migration strategy in `02-02-MIGRATION.md`.

**Key design decision**: PropertyData is a **superset** of InspectionDraft. Every field on InspectionDraft has a corresponding location in PropertyData. PropertyData adds:
- `universal` (strongly typed shared fields across forms)
- `shared` (strongly typed building-system fields)
- `formData` (per-form-type map of form-specific fields)
- `schemaVersion` (for evolution)

**InspectionSessionController impact**: The session controller currently takes an `InspectionDraft` in its constructor and accesses `draft.inspectionId`, `draft.clientName`, `draft.propertyAddress`, etc. Under Strategy B (see 02-02-MIGRATION.md), these accessors continue to work unchanged. New code can additionally access typed data through `draft.propertyData`.

---

## 5. formData Map Design

### Structure

```dart
Map<FormType, Map<String, dynamic>> formData
```

The outer map is keyed by `FormType` enum values. Each inner map contains form-specific field values keyed by `{section}.{fieldName}` strings.

### Key Format

Keys within each form's map use `{section}.{fieldName}` format. The form prefix is NOT included in the key because it is implicit from the `FormType` map key.

| FormType | Section Examples | Full Key Example |
|----------|-----------------|-----------------|
| `fourPoint` | `electrical`, `hvac`, `plumbing`, `roof` | `electrical.clothWiring` |
| `roofCondition` | `roof`, `inspector` | `roof.conditionRating` |
| `windMitigation` | `q1` through `q8` | `q3.roofDeckAttachment` |

### Serialization

In JSON, the outer map keys become form code strings:

```json
{
  "form_data": {
    "four_point": {
      "electrical.clothWiring": true,
      "electrical.mainPanelAmps": 200
    },
    "wind_mitigation": {
      "q3.roofDeckAttachment": "B"
    }
  }
}
```

### Values

Values must be JSON-compatible:
- `String`, `int`, `double`, `bool`, `null`
- `List<dynamic>` (containing only the above or nested collections)
- `Map<String, dynamic>` (containing only the above or nested collections)

---

## 6. branchContext Merge — Detailed Design

### Purpose

The `branchContext` getter produces a flat `Map<String, dynamic>` that can be passed directly to `FormRequirements.forFormRequirements()` and evidence predicate functions. It merges data from all three layers of the PropertyData hierarchy.

### Merge Precedence

| Priority | Source | Key Format | Example |
|----------|--------|-----------|---------|
| 3 (highest) | Form-specific (`formData`) | `{formPrefix}.{section}.{field}` | `fourPoint.electrical.clothWiring` |
| 2 | Shared (`shared.toJson()`) | `{snake_case}` | `year_built` |
| 1 (lowest) | Universal (`universal.toJson()`) | `{snake_case}` | `property_address` |

### Namespace Collision Prevention

Form-specific keys are always prefixed with the form prefix (`fourPoint.`, `roofCondition.`, `windMit.`, etc.), which prevents collisions with universal and shared keys (which use `snake_case` without a dot prefix). This is inherent in the key naming convention and does not require runtime conflict resolution.

The only theoretical collision would be if a universal or shared key happened to contain a dot and match a form-prefixed key. This cannot happen because:
1. Universal and shared `toJson()` keys are all `snake_case` without dots
2. Form-specific keys always start with a form prefix containing a dot

### Reserved Keys

The following keys are reserved by the universal and shared layers and MUST NOT appear as keys in any `formData` map:

**Universal layer** (8 keys):
- `property_address`, `inspection_date`, `inspector_name`, `inspector_company`
- `inspector_license_number`, `client_name`, `inspector_signature_path`, `comments`

**Shared layer** (13 keys):
- `year_built`, `policy_number`, `inspector_phone`, `signature_date`
- `roof_covering_material`, `roof_age`, `roof_condition`
- `electrical_panel_type`, `electrical_panel_amps`
- `plumbing_pipe_material`, `water_heater_type`, `hvac_type`, `foundation_cracks`

**Workflow** (injected by controller, not by branchContext getter):
- `enabled_forms`
- All keys in `FormRequirements.canonicalBranchFlags` (`hazard_present`, `roof_defect_present`, `wind_roof_deck_document_required`, `wind_opening_document_required`, `wind_permit_document_required`)

### Merge Examples

**Example 1: Simple merge, no conflicts**

```
universal.toJson() => { 'property_address': '123 Main St', 'client_name': 'Jane' }
shared.toJson()    => { 'year_built': 1995 }
formData           => { FormType.fourPoint: { 'electrical.clothWiring': true } }

branchContext => {
  'property_address': '123 Main St',  // from universal
  'client_name': 'Jane',              // from universal
  'year_built': 1995,                 // from shared
  'fourPoint.electrical.clothWiring': true,  // from formData, prefixed
}
```

**Example 2: Multiple forms**

```
universal.toJson() => { 'client_name': 'Bob' }
shared.toJson()    => { 'roof_age': 15 }
formData => {
  FormType.fourPoint:      { 'roof.condition': 'satisfactory' },
  FormType.windMitigation: { 'q3.roofDeckAttachment': 'B' },
}

branchContext => {
  'client_name': 'Bob',
  'roof_age': 15,
  'fourPoint.roof.condition': 'satisfactory',
  'windMit.q3.roofDeckAttachment': 'B',
}
```

**Example 3: Shared field null-omission**

```
shared.toJson() => { 'year_built': 2001 }
// (other shared fields are null, omitted from toJson)

branchContext => {
  ...universal keys...,
  'year_built': 2001,
  // No other shared keys because they are null
}
```
