# 02-01: RatingScale Enum Design + Bidirectional Validation Matrix

> **Plan**: 02-01 Core Shared Models
> **Task**: 3 of 3
> **Date**: 2026-03-07
> **Source**: FIELD_INVENTORY Section 5 + Spec Section 3.5

---

## 1. Rating Systems Inventory

Three distinct rating systems are in use across the 7 form types (from FIELD_INVENTORY Section 5):

| System | Scale | Values | Forms |
|--------|-------|--------|-------|
| 4-Point | 2-tier | Satisfactory, Unsatisfactory | 4-Point (electrical, plumbing fixtures, roof, HVAC) |
| General Inspection | 4-tier | Good, Fair, Poor, N/A | General (all 12 section checkpoint tables) |
| HUD Report | 8-code | Y, N, S, U, MR, MG, NA, NV | HUD (checkpoint codes) |

Additionally, the RCF-1 Roof Condition form uses a 4-tier scale for roof condition: **Good, Fair, Poor, Failed**. This is close to the General Inspection scale but uses "Failed" instead of "N/A" -- a significant semantic difference ("Failed" means the roof has failed; "N/A" means not applicable).

**Total distinct rating systems: 4** (4-Point 2-tier, General 4-tier, HUD 8-code, RCF-1 4-tier).

---

## 2. Complete Dart Enum Specification

```dart
/// Normalized rating scale that maps across 4-Point (2-tier),
/// General Inspection (4-tier), RCF-1 (4-tier with Failed), and
/// HUD Report (8-code) systems.
///
/// Source: FIELD_INVENTORY Section 5 (Rating Scale Normalization)
/// File: lib/features/inspection/domain/rating_scale.dart
enum RatingScale {
  /// Component is in acceptable condition.
  ///
  /// 4-Point: "Satisfactory" | General: "Good" | RCF-1: "Good" | HUD: "Y", "S"
  satisfactory,

  /// Component has minor issues but is functional.
  ///
  /// 4-Point: -- (no equivalent) | General: "Fair" | RCF-1: "Fair" | HUD: "MR"
  marginal,

  /// Component has significant issues requiring attention.
  ///
  /// 4-Point: "Unsatisfactory" | General: "Poor" | RCF-1: "Poor" | HUD: "U", "N"
  deficient,

  /// Component has completely failed and requires immediate replacement.
  ///
  /// 4-Point: -- | General: -- | RCF-1: "Failed" | HUD: --
  /// Note: RCF-1 specific. More severe than deficient. Indicates the roof
  /// covering has reached end of life and is no longer providing protection.
  failed,

  /// Component is not applicable to this inspection.
  ///
  /// 4-Point: -- | General: "N/A" | RCF-1: -- | HUD: "NA"
  notApplicable,

  /// Component was not visible/accessible during inspection.
  ///
  /// 4-Point: -- | General: -- | RCF-1: -- | HUD: "NV"
  notVisible,

  /// Component is missing from the property.
  ///
  /// 4-Point: -- | General: -- | RCF-1: -- | HUD: "MG"
  missing;

  /// Schema version for serialized rating values.
  static const int version = 1;
}
```

**Design decision -- added `failed` value**: The spec document (Section 3.5) listed 6 values. However, RCF-1 uses "Failed" as a distinct rating that is more severe than "Poor"/"deficient". Mapping "Failed" to `deficient` would lose severity information. Adding `failed` as a 7th enum value preserves the RCF-1 semantics without lossy conversion. The 4-Point and General systems have no "Failed" equivalent, so this value only round-trips through RCF-1.

---

## 3. Normalization Mapping Table

| RatingScale | 4-Point source strings | General source strings | RCF-1 source strings | HUD source strings |
|-------------|----------------------|----------------------|---------------------|-------------------|
| `satisfactory` | `"Satisfactory"`, `"S"` | `"Good"`, `"G"` | `"Good"`, `"G"` | `"Y"`, `"S"` |
| `marginal` | -- | `"Fair"`, `"F"` | `"Fair"`, `"F"` | `"MR"` |
| `deficient` | `"Unsatisfactory"`, `"U"` | `"Poor"`, `"P"` | `"Poor"`, `"P"` | `"U"`, `"N"` |
| `failed` | -- | -- | `"Failed"` | -- |
| `notApplicable` | -- | `"N/A"`, `"NA"` | -- | `"NA"` |
| `notVisible` | -- | -- | -- | `"NV"` |
| `missing` | -- | -- | -- | `"MG"` |

---

## 4. Extension Methods

```dart
/// Extension methods for RatingScale conversion across form types.
///
/// File: lib/features/inspection/domain/rating_scale.dart
extension RatingScaleConversion on RatingScale {

  // -------------------------------------------------------------------------
  // Form Value -> RatingScale (Ingestion)
  // -------------------------------------------------------------------------

  /// Converts a form-specific raw value to a normalized RatingScale.
  ///
  /// [formValue] is the string as it appears on the original form.
  /// [formType] determines which mapping table to use.
  /// Returns null if the value does not map to any known rating.
  ///
  /// Example:
  ///   fromFormValue("Satisfactory", FormType.fourPoint) => satisfactory
  ///   fromFormValue("Good", FormType.generalInspection) => satisfactory
  ///   fromFormValue("Failed", FormType.roofCondition) => failed
  ///   fromFormValue("MR", FormType.hudReport) => marginal
  static RatingScale? fromFormValue(String formValue, FormType formType) {
    final normalized = formValue.trim();
    final table = _ingestTables[formType];
    if (table == null) return null;
    return table[normalized] ?? table[normalized.toUpperCase()];
  }

  /// Per-form lookup tables for ingestion (form string -> RatingScale).
  static const _ingestTables = <FormType, Map<String, RatingScale>>{
    FormType.fourPoint: {
      'Satisfactory': RatingScale.satisfactory,
      'S': RatingScale.satisfactory,
      'Unsatisfactory': RatingScale.deficient,
      'U': RatingScale.deficient,
    },
    FormType.roofCondition: {
      'Good': RatingScale.satisfactory,
      'G': RatingScale.satisfactory,
      'Fair': RatingScale.marginal,
      'F': RatingScale.marginal,
      'Poor': RatingScale.deficient,
      'P': RatingScale.deficient,
      'Failed': RatingScale.failed,
    },
    FormType.generalInspection: {
      'Good': RatingScale.satisfactory,
      'G': RatingScale.satisfactory,
      'Fair': RatingScale.marginal,
      'F': RatingScale.marginal,
      'Poor': RatingScale.deficient,
      'P': RatingScale.deficient,
      'N/A': RatingScale.notApplicable,
      'NA': RatingScale.notApplicable,
    },
    FormType.hudReport: {
      'Y': RatingScale.satisfactory,
      'S': RatingScale.satisfactory,
      'MR': RatingScale.marginal,
      'U': RatingScale.deficient,
      'N': RatingScale.deficient,
      'NA': RatingScale.notApplicable,
      'NV': RatingScale.notVisible,
      'MG': RatingScale.missing,
    },
  };

  // -------------------------------------------------------------------------
  // RatingScale -> Form Value (Emission)
  // -------------------------------------------------------------------------

  /// Converts back to the form-specific display string for a given form type.
  ///
  /// Returns null if this rating value has no representation on the
  /// specified form (e.g., `marginal` on 4-Point, or `failed` on General).
  ///
  /// Example:
  ///   satisfactory.toFormString(FormType.fourPoint) => "Satisfactory"
  ///   satisfactory.toFormString(FormType.generalInspection) => "Good"
  ///   failed.toFormString(FormType.roofCondition) => "Failed"
  ///   marginal.toFormString(FormType.fourPoint) => null  // LOSSY
  String? toFormString(FormType formType) {
    final table = _emitTables[formType];
    if (table == null) return null;
    return table[this];
  }

  /// Per-form lookup tables for emission (RatingScale -> canonical form string).
  /// Each RatingScale value maps to exactly one canonical string per form,
  /// or is absent if the form has no representation for that value.
  static const _emitTables = <FormType, Map<RatingScale, String>>{
    FormType.fourPoint: {
      RatingScale.satisfactory: 'Satisfactory',
      RatingScale.deficient: 'Unsatisfactory',
    },
    FormType.roofCondition: {
      RatingScale.satisfactory: 'Good',
      RatingScale.marginal: 'Fair',
      RatingScale.deficient: 'Poor',
      RatingScale.failed: 'Failed',
    },
    FormType.generalInspection: {
      RatingScale.satisfactory: 'Good',
      RatingScale.marginal: 'Fair',
      RatingScale.deficient: 'Poor',
      RatingScale.notApplicable: 'N/A',
    },
    FormType.hudReport: {
      RatingScale.satisfactory: 'S',
      RatingScale.marginal: 'MR',
      RatingScale.deficient: 'U',
      RatingScale.notApplicable: 'NA',
      RatingScale.notVisible: 'NV',
      RatingScale.missing: 'MG',
    },
  };

  // -------------------------------------------------------------------------
  // Normalized / Canonical Accessors
  // -------------------------------------------------------------------------

  /// Returns the normalized display string (form-independent).
  ///
  /// Example: RatingScale.satisfactory.toNormalizedString() => "Satisfactory"
  /// Example: RatingScale.notApplicable.toNormalizedString() => "Not Applicable"
  String toNormalizedString() {
    switch (this) {
      case RatingScale.satisfactory: return 'Satisfactory';
      case RatingScale.marginal: return 'Marginal';
      case RatingScale.deficient: return 'Deficient';
      case RatingScale.failed: return 'Failed';
      case RatingScale.notApplicable: return 'Not Applicable';
      case RatingScale.notVisible: return 'Not Visible';
      case RatingScale.missing: return 'Missing';
    }
  }

  /// Serialization key for JSON storage. Uses the enum name directly.
  String toJsonValue() => name;

  /// Deserialization from JSON.
  static RatingScale? fromJsonValue(String? value) {
    if (value == null) return null;
    return RatingScale.values.where((v) => v.name == value).firstOrNull;
  }

  // -------------------------------------------------------------------------
  // Semantic Helpers
  // -------------------------------------------------------------------------

  /// Whether this rating indicates a problem that may require action.
  bool get isDeficient =>
      this == RatingScale.deficient || this == RatingScale.failed;

  /// Whether this rating is a non-answer (N/A, not visible, missing).
  bool get isNonAnswer =>
      this == RatingScale.notApplicable ||
      this == RatingScale.notVisible ||
      this == RatingScale.missing;

  /// Whether this rating indicates acceptable condition.
  bool get isAcceptable =>
      this == RatingScale.satisfactory || this == RatingScale.marginal;

  /// Ordinal severity (lower = better). Useful for worst-case aggregation.
  /// Returns null for non-answer ratings.
  int? get severityOrdinal {
    switch (this) {
      case RatingScale.satisfactory: return 0;
      case RatingScale.marginal: return 1;
      case RatingScale.deficient: return 2;
      case RatingScale.failed: return 3;
      case RatingScale.notApplicable: return null;
      case RatingScale.notVisible: return null;
      case RatingScale.missing: return null;
    }
  }
}
```

---

## 5. Bidirectional Validation Matrix (Round-Trip Verification)

This matrix verifies that every form-specific rating value round-trips correctly through the normalization pipeline:

**Pipeline**: `formString` -> `fromFormValue()` -> `RatingScale` -> `toFormString()` -> output string

### 5.1 Four-Point (2-tier)

| Form String (input) | fromFormValue() | RatingScale | toFormString() (output) | Round-Trip | Notes |
|---------------------|-----------------|-------------|------------------------|------------|-------|
| `"Satisfactory"` | satisfactory | `satisfactory` | `"Satisfactory"` | EXACT | |
| `"S"` | satisfactory | `satisfactory` | `"Satisfactory"` | CANONICAL | Short form normalizes to long form |
| `"Unsatisfactory"` | deficient | `deficient` | `"Unsatisfactory"` | EXACT | |
| `"U"` | deficient | `deficient` | `"Unsatisfactory"` | CANONICAL | Short form normalizes to long form |

**Lossy conversions INTO 4-Point**:

| RatingScale | toFormString(fourPoint) | Loss | Mitigation |
|-------------|------------------------|------|------------|
| `marginal` | `null` | YES - 4-Point has no "Fair" | UI must prevent selecting marginal for 4-Point fields. If data originates from General/RCF-1, it cannot be represented on 4-Point. |
| `failed` | `null` | YES - 4-Point has no "Failed" | Same as above. RCF-1 "Failed" has no 4-Point equivalent. |
| `notApplicable` | `null` | YES | 4-Point does not use N/A for system ratings (uses it only in plumbing fixture matrix as "N/A"). |
| `notVisible` | `null` | YES | HUD-only concept. |
| `missing` | `null` | YES | HUD-only concept. |

### 5.2 Roof Condition RCF-1 (4-tier)

| Form String (input) | fromFormValue() | RatingScale | toFormString() (output) | Round-Trip | Notes |
|---------------------|-----------------|-------------|------------------------|------------|-------|
| `"Good"` | satisfactory | `satisfactory` | `"Good"` | EXACT | |
| `"G"` | satisfactory | `satisfactory` | `"Good"` | CANONICAL | |
| `"Fair"` | marginal | `marginal` | `"Fair"` | EXACT | |
| `"F"` | marginal | `marginal` | `"Fair"` | CANONICAL | |
| `"Poor"` | deficient | `deficient` | `"Poor"` | EXACT | |
| `"P"` | deficient | `deficient` | `"Poor"` | CANONICAL | |
| `"Failed"` | failed | `failed` | `"Failed"` | EXACT | |

**Lossy conversions INTO RCF-1**:

| RatingScale | toFormString(roofCondition) | Loss | Mitigation |
|-------------|---------------------------|------|------------|
| `notApplicable` | `null` | YES | RCF-1 does not use N/A |
| `notVisible` | `null` | YES | HUD-only concept |
| `missing` | `null` | YES | HUD-only concept |

### 5.3 General Inspection (4-tier)

| Form String (input) | fromFormValue() | RatingScale | toFormString() (output) | Round-Trip | Notes |
|---------------------|-----------------|-------------|------------------------|------------|-------|
| `"Good"` | satisfactory | `satisfactory` | `"Good"` | EXACT | |
| `"G"` | satisfactory | `satisfactory` | `"Good"` | CANONICAL | |
| `"Fair"` | marginal | `marginal` | `"Fair"` | EXACT | |
| `"F"` | marginal | `marginal` | `"Fair"` | CANONICAL | |
| `"Poor"` | deficient | `deficient` | `"Poor"` | EXACT | |
| `"P"` | deficient | `deficient` | `"Poor"` | CANONICAL | |
| `"N/A"` | notApplicable | `notApplicable` | `"N/A"` | EXACT | |
| `"NA"` | notApplicable | `notApplicable` | `"N/A"` | CANONICAL | |

**Lossy conversions INTO General**:

| RatingScale | toFormString(generalInspection) | Loss | Mitigation |
|-------------|-------------------------------|------|------------|
| `failed` | `null` | YES | RCF-1 specific. Closest would be "Poor" but we do NOT silently downgrade -- return null to force explicit handling. |
| `notVisible` | `null` | YES | HUD-only concept |
| `missing` | `null` | YES | HUD-only concept |

### 5.4 HUD Report (8-code)

| Form String (input) | fromFormValue() | RatingScale | toFormString() (output) | Round-Trip | Notes |
|---------------------|-----------------|-------------|------------------------|------------|-------|
| `"Y"` | satisfactory | `satisfactory` | `"S"` | LOSSY | "Y" (Yes) normalizes to "S" (Satisfactory). Both mean acceptable but are different HUD codes. See Section 5.5. |
| `"S"` | satisfactory | `satisfactory` | `"S"` | EXACT | |
| `"MR"` | marginal | `marginal` | `"MR"` | EXACT | |
| `"U"` | deficient | `deficient` | `"U"` | EXACT | |
| `"N"` | deficient | `deficient` | `"U"` | LOSSY | "N" (No) normalizes to "U" (Unsatisfactory). Both indicate deficiency but are different HUD codes. See Section 5.5. |
| `"NA"` | notApplicable | `notApplicable` | `"NA"` | EXACT | |
| `"NV"` | notVisible | `notVisible` | `"NV"` | EXACT | |
| `"MG"` | missing | `missing` | `"MG"` | EXACT | |

**Lossy conversions INTO HUD**:

| RatingScale | toFormString(hudReport) | Loss | Mitigation |
|-------------|------------------------|------|------------|
| `failed` | `null` | YES | RCF-1 specific. No HUD equivalent. |

### 5.5 Documented Lossy Conversions (HUD Y/N vs S/U Collapse)

The HUD system has two pairs of codes that map to the same semantic meaning:
- **Y (Yes) and S (Satisfactory)** both map to `satisfactory`. On round-trip, both emit as `"S"`.
- **N (No) and U (Unsatisfactory)** both map to `deficient`. On round-trip, both emit as `"U"`.

This is acceptable because:
1. Y/S and N/U are used in different contexts on the HUD form (Y/N for binary questions, S/U for condition assessments) but carry the same semantic weight for cross-form normalization.
2. The original form-specific value is preserved in `formData` as-is. The `RatingScale` normalization is for cross-form comparison only.
3. PDF output uses the value from `formData`, not from `RatingScale.toFormString()`.

---

## 6. Cross-Form Conversion Feasibility Matrix

This matrix shows which conversions are lossless, lossy, or impossible:

| Source -> Target | 4-Point | RCF-1 | General | HUD |
|-----------------|---------|-------|---------|-----|
| **4-Point** | -- | Lossless (S->Good, U->Poor) | Lossless (S->Good, U->Poor) | Lossless (S->S, U->U) |
| **RCF-1** | LOSSY (Fair, Failed have no equiv) | -- | LOSSY (Failed has no equiv) | LOSSY (Failed has no equiv) |
| **General** | LOSSY (Fair, N/A have no equiv) | LOSSY (N/A has no equiv) | -- | Lossless |
| **HUD** | LOSSY (MR, NA, NV, MG have no equiv) | LOSSY (NA, NV, MG have no equiv) | LOSSY (NV, MG have no equiv) | -- |

**Key insight**: 4-Point is the most restrictive (2 values). Converting TO 4-Point from any other system is lossy. Converting FROM 4-Point to any other system is always lossless because S and U map cleanly to every other system.

---

## 7. Response Pattern Taxonomy Reference

From FIELD_INVENTORY Section 5.2, the 14 distinct input patterns include Pattern #1 (Rating Scale) and Pattern #6 (Matrix). These are the patterns that use `RatingScale`:

| Pattern | Description | RatingScale Usage |
|---------|-------------|-------------------|
| #1: Rating scale | Ordinal quality assessment on a fixed scale | Direct use of RatingScale enum values |
| #6: Matrix (item x rating) | Grid of items each rated on a shared scale | Each cell value is a RatingScale enum value |

**Pattern #1 usage by form**:
- 4-Point: `enum.electrical_general_condition` (S/U), `enum.roof_primary_overall_condition` (S/U)
- General: All checkpoint ratings across 12 sections (G/F/P/NA)
- RCF-1: `enum.roof_condition_rating` (Good/Fair/Poor/Failed)
- HUD: All checkpoint codes (S/U/MR/MG/NA/NV)

**Pattern #6 usage by form**:
- 4-Point: Plumbing fixture matrix (10 items x S/U/NA)
- General: Checkpoint tables (N items x G/F/P/NA) across all 12 sections

**Pattern #3 (Yes/No/NA ternary)**: Used by Sinkhole (19 items). This is NOT a RatingScale -- it is a tri-state indicator for presence/absence of a condition. Stored as string `"yes"` / `"no"` / `"na"` in formData.

---

## 8. 4-Point Plumbing Fixture Matrix: Special Handling

The 4-Point form has a fixture condition matrix with 10 items rated S/U/NA. The "N/A" here means "Not Applicable" (the fixture does not exist), which maps to `RatingScale.notApplicable`. However, the 4-Point system overall is 2-tier (S/U). The N/A option exists only in this fixture matrix.

This means:
- `fromFormValue("N/A", FormType.fourPoint)` should return `notApplicable`
- `toFormString(FormType.fourPoint)` for `notApplicable` should return `"N/A"`

Updated ingestion table for 4-Point to include N/A:

```dart
FormType.fourPoint: {
  'Satisfactory': RatingScale.satisfactory,
  'S': RatingScale.satisfactory,
  'Unsatisfactory': RatingScale.deficient,
  'U': RatingScale.deficient,
  'N/A': RatingScale.notApplicable,  // Fixture matrix only
  'NA': RatingScale.notApplicable,
},
```

Updated emission table for 4-Point:

```dart
FormType.fourPoint: {
  RatingScale.satisfactory: 'Satisfactory',
  RatingScale.deficient: 'Unsatisfactory',
  RatingScale.notApplicable: 'N/A',  // Fixture matrix only
},
```

Updated round-trip for 4-Point:

| Form String (input) | fromFormValue() | RatingScale | toFormString() (output) | Round-Trip |
|---------------------|-----------------|-------------|------------------------|------------|
| `"N/A"` | notApplicable | `notApplicable` | `"N/A"` | EXACT |
| `"NA"` | notApplicable | `notApplicable` | `"N/A"` | CANONICAL |

This reduces the lossy conversions INTO 4-Point by one entry.

---

## 9. Summary of Lossy Conversions

| Conversion | Lost Information | Impact | Mitigation |
|------------|-----------------|--------|------------|
| HUD `"Y"` -> `satisfactory` -> `"S"` | Y/S distinction | Low | Original value in formData |
| HUD `"N"` -> `deficient` -> `"U"` | N/U distinction | Low | Original value in formData |
| `marginal` -> 4-Point | No "Fair" equivalent | Medium | UI prevents; cross-form comparison notes the gap |
| `failed` -> 4-Point | No "Failed" equivalent | Medium | UI prevents; `failed` is RCF-1 specific |
| `failed` -> General | No "Failed" equivalent | Medium | `null` returned; explicit handling required |
| `failed` -> HUD | No "Failed" equivalent | Medium | `null` returned; explicit handling required |
| `notVisible` -> non-HUD | HUD-only concept | Low | `null` returned; only relevant for HUD forms |
| `missing` -> non-HUD | HUD-only concept | Low | `null` returned; only relevant for HUD forms |

**Critical invariant**: The original form-specific rating string is ALWAYS preserved in `formData` alongside the normalized `RatingScale` value. PDF output uses `formData`, not the normalized value. `RatingScale` is for cross-form analytics, worst-case aggregation, and UI display only.
