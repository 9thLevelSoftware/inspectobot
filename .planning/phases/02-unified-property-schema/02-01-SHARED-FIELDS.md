# 02-01: SharedBuildingSystemFields Class Design

> **Plan**: 02-01 Core Shared Models
> **Task**: 2 of 3
> **Date**: 2026-03-07
> **Source**: FIELD_INVENTORY Section 2.2, 2.3, 2.4 + Spec Section 3.2

---

## 1. Complete Dart Class Specification

```dart
/// Strongly-typed fields shared across 2-4 form types, organized by
/// building system.
///
/// All fields are nullable because no single form uses all 13. The
/// applicable subset is determined by which forms are enabled for a
/// given inspection.
///
/// Source: FIELD_INVENTORY Section 2.2 (Shared Fields) and Section 2.4
///         (Building System Overlap)
/// File: lib/features/inspection/domain/shared_building_system_fields.dart
class SharedBuildingSystemFields {
  const SharedBuildingSystemFields({
    // Property Identification
    this.yearBuilt,
    this.policyNumber,
    // Inspector Contact
    this.inspectorPhone,
    this.signatureDate,
    // Roof System
    this.roofCoveringMaterial,
    this.roofAge,
    this.roofCondition,
    // Electrical System
    this.electricalPanelType,
    this.electricalPanelAmps,
    // Plumbing System
    this.plumbingPipeMaterial,
    this.waterHeaterType,
    // HVAC System
    this.hvacType,
    // Foundation
    this.foundationCracks,
  });

  // =========================================================================
  // Property Identification Group
  // =========================================================================

  /// Actual year the structure was built.
  ///
  /// Present on: 4-Point, RCF-1, Wind Mit, Mold, General (5 of 7).
  /// Not on: WDO, Sinkhole.
  /// Name variations:
  ///   - "Actual Year Built" (4-Point)
  ///   - "Year Built" (RCF-1, Wind Mit)
  ///   - "Building Age" (Mold -- convert age-in-years to year at entry)
  ///   - "Structure Age" (General/HUD -- same conversion)
  /// Validation: 1800 <= value <= DateTime.now().year + 1.
  /// Backward compat: Maps to InspectionDraft.yearBuilt (int, required) and
  ///   InspectionSetup.yearBuilt (int, required).
  /// Semantic note: Mold/General may capture "building age" instead of year.
  ///   The UI layer converts age -> year at data entry time so this field
  ///   always stores the actual year.
  final int? yearBuilt;

  /// Insurance application or policy number.
  ///
  /// Present on: 4-Point, RCF-1, Wind Mit, Sinkhole (4 of 7).
  /// Not on: WDO, Mold, General.
  /// Name variations:
  ///   - "Application / Policy #" (4-Point)
  ///   - "Policy Number" (RCF-1, Wind Mit, Sinkhole 0.3)
  /// Validation: Non-empty when applicable (insurance forms).
  /// Semantic note: Only relevant for insurance-underwriting forms. Null
  ///   for non-insurance forms.
  final String? policyNumber;

  // =========================================================================
  // Inspector Contact Group
  // =========================================================================

  /// Inspector's phone number.
  ///
  /// Present on: Wind Mit, WDO, Sinkhole, General (4 of 7).
  /// Not on: 4-Point, RCF-1, Mold.
  /// Name variations:
  ///   - "Phone Number" (WDO 1.4)
  ///   - "Inspector Phone" (Sinkhole 0.8, Wind Mit)
  ///   - varies (General)
  /// Validation: Non-empty when present; no strict phone format enforcement.
  /// Populated from: InspectorProfile via identity module.
  /// Semantic note: WDO captures company phone specifically; others may
  ///   capture the inspector's personal or work phone.
  final String? inspectorPhone;

  /// Date the inspector signed the report.
  ///
  /// Present on: 4-Point, RCF-1, Wind Mit, WDO (4 of 7).
  /// Not on: Sinkhole, Mold, General.
  /// Name variations:
  ///   - "Date Signed" (4-Point, RCF-1, Wind Mit)
  ///   - "Signature Date" (WDO 5.4)
  /// Validation: Must not precede inspectionDate; not in the future by
  ///   more than 30 days.
  /// Semantic note: May differ from inspection_date (e.g., inspector signs
  ///   the report the day after the site visit).
  final DateTime? signatureDate;

  // =========================================================================
  // Roof System Group
  // =========================================================================

  /// Predominant roof covering material.
  ///
  /// Present on: 4-Point, RCF-1, General (3 of 7).
  /// Not on: Wind Mit, WDO, Sinkhole, Mold.
  /// Name variations:
  ///   - "Predominant Roof: Covering material" (4-Point)
  ///   - "Roof Type / Covering Material" (RCF-1)
  ///   - enum in General and HUD
  /// Type: Free text (String) to accommodate varying enum sets across forms.
  ///   Form-specific enum constraints are enforced at the UI layer.
  /// Validation: Non-empty when applicable.
  final String? roofCoveringMaterial;

  /// Age of the roof in years.
  ///
  /// Present on: 4-Point, RCF-1, General (3 of 7).
  /// Not on: Wind Mit, WDO, Sinkhole, Mold.
  /// Name variations:
  ///   - "Predominant Roof: Age" (4-Point)
  ///   - "Roof Age (years)" (RCF-1)
  ///   - "Estimated age" (General)
  /// Validation: 0 <= value <= 100.
  final int? roofAge;

  /// Normalized roof condition rating.
  ///
  /// Present on: 4-Point, RCF-1, General (3 of 7).
  /// Not on: Wind Mit, WDO, Sinkhole, Mold.
  /// Name variations:
  ///   - "Overall condition" (4-Point: Satisfactory/Unsatisfactory)
  ///   - "Roof Condition Rating" (RCF-1: Good/Fair/Poor/Failed)
  ///   - Checkpoint rating (General: Good/Fair/Poor/N/A)
  /// Uses: RatingScale enum for cross-form normalization (see 02-01-RATING-SCALE.md).
  /// Semantic note: Different rating scales require normalization. The
  ///   original form-specific value is preserved in formData for PDF output.
  final RatingScale? roofCondition;

  // =========================================================================
  // Electrical System Group
  // =========================================================================

  /// Main electrical panel type.
  ///
  /// Present on: 4-Point, General (2 of 7).
  /// Not on: RCF-1, Wind Mit, WDO, Sinkhole, Mold.
  /// Name variations:
  ///   - "Main Panel Type" (4-Point: Circuit breaker / Fuse)
  ///   - "Panel Type" (General)
  ///   - "Panel Box" (HUD)
  /// Values: "circuit_breaker", "fuse", "other".
  /// Type: Free text (String) to accommodate form-specific enum values.
  final String? electricalPanelType;

  /// Main electrical panel total amperage.
  ///
  /// Present on: 4-Point, General (2 of 7).
  /// Not on: RCF-1, Wind Mit, WDO, Sinkhole, Mold.
  /// Name variations:
  ///   - "Main Panel Total Amps" (4-Point)
  ///   - "Panel Capacity" (General: 70A-400A enum)
  ///   - "Capacity" (HUD)
  /// Validation: Positive integer when present. Typical values: 60-400.
  final int? electricalPanelAmps;

  // =========================================================================
  // Plumbing System Group
  // =========================================================================

  /// Primary water pipe material.
  ///
  /// Present on: 4-Point, General (2 of 7).
  /// Not on: RCF-1, Wind Mit, WDO, Sinkhole, Mold.
  /// Name variations:
  ///   - "Type of pipes" (4-Point: Copper/PVC/Galvanized/PEX/Polybutylene)
  ///   - "Main Line Material" (General)
  ///   - "Water Piping" (HUD)
  /// Type: Free text (String) to accommodate different enum value sets.
  /// Validation: Non-empty when applicable.
  /// Semantic note: 4-Point allows multi-select (checkbox group for pipe
  ///   types). This shared field stores the PRIMARY material. Multiple
  ///   selections are stored in formData as individual booleans
  ///   (e.g., fourPoint.plumbing.pipeCopper, fourPoint.plumbing.pipePvc).
  final String? plumbingPipeMaterial;

  /// Water heater fuel/energy type.
  ///
  /// Present on: 4-Point, General (2 of 7).
  /// Not on: RCF-1, Wind Mit, WDO, Sinkhole, Mold.
  /// Name variations:
  ///   - Plumbing section (4-Point)
  ///   - "Type" (General: Gas/Electric/Solar/LPG)
  ///   - "Water Heaters" (HUD)
  /// Values: "gas", "electric", "solar", "lpg", "other".
  /// Type: Free text (String) to accommodate form-specific values.
  final String? waterHeaterType;

  // =========================================================================
  // HVAC System Group
  // =========================================================================

  /// Primary HVAC system type.
  ///
  /// Present on: 4-Point, General (2 of 7).
  /// Not on: RCF-1, Wind Mit, WDO, Sinkhole, Mold.
  /// Name variations:
  ///   - "Primary heat source and fuel type" (4-Point)
  ///   - "Heating Type" (General)
  ///   - "Furnace System" (HUD)
  /// Type: Free text (String) to accommodate varying granularity.
  /// Semantic note: 4-Point and General differ in granularity. 4-Point
  ///   asks for system-level summary; General splits heating and AC into
  ///   separate sections with component-level checkpoint ratings.
  final String? hvacType;

  // =========================================================================
  // Foundation Group
  // =========================================================================

  /// Whether foundation cracks are present.
  ///
  /// Present on: Sinkhole, General (2 of 7).
  /// Not on: 4-Point, RCF-1, Wind Mit, WDO, Mold.
  /// Name variations:
  ///   - "Cracks in foundation?" (Sinkhole 1.4: yes_no_na)
  ///   - "Foundation" checkpoint (General: Good/Fair/Poor/N/A)
  /// Type: bool? -- captures the binary fact of cracks existing.
  /// Semantic note: Sinkhole requires detailed crack measurements (width,
  ///   length, location) stored in formData. General uses a rating scale
  ///   stored in formData. This shared field captures only the boolean
  ///   indicator.
  final bool? foundationCracks;

  // =========================================================================
  // Serialization
  // =========================================================================

  /// Serializes to JSON.
  ///
  /// Only non-null fields are included. JSON keys use snake_case.
  /// ```json
  /// {
  ///   "year_built": 1998,
  ///   "policy_number": "FPL-2024-00123",
  ///   "inspector_phone": "813-555-0100",
  ///   "signature_date": "2026-03-07",
  ///   "roof_covering_material": "Asphalt Shingle",
  ///   "roof_age": 12,
  ///   "roof_condition": "satisfactory",
  ///   "electrical_panel_type": "circuit_breaker",
  ///   "electrical_panel_amps": 200,
  ///   "plumbing_pipe_material": "PVC",
  ///   "water_heater_type": "electric",
  ///   "hvac_type": "Forced Air",
  ///   "foundation_cracks": false
  /// }
  /// ```
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (yearBuilt != null) json['year_built'] = yearBuilt;
    if (policyNumber != null) json['policy_number'] = policyNumber;
    if (inspectorPhone != null) json['inspector_phone'] = inspectorPhone;
    if (signatureDate != null) {
      json['signature_date'] =
          signatureDate!.toIso8601String().split('T').first;
    }
    if (roofCoveringMaterial != null) {
      json['roof_covering_material'] = roofCoveringMaterial;
    }
    if (roofAge != null) json['roof_age'] = roofAge;
    if (roofCondition != null) json['roof_condition'] = roofCondition!.name;
    if (electricalPanelType != null) {
      json['electrical_panel_type'] = electricalPanelType;
    }
    if (electricalPanelAmps != null) {
      json['electrical_panel_amps'] = electricalPanelAmps;
    }
    if (plumbingPipeMaterial != null) {
      json['plumbing_pipe_material'] = plumbingPipeMaterial;
    }
    if (waterHeaterType != null) json['water_heater_type'] = waterHeaterType;
    if (hvacType != null) json['hvac_type'] = hvacType;
    if (foundationCracks != null) {
      json['foundation_cracks'] = foundationCracks;
    }
    return json;
  }

  /// Deserializes from JSON.
  ///
  /// All fields are optional. Missing keys result in null values.
  factory SharedBuildingSystemFields.fromJson(Map<String, dynamic> json) {
    return SharedBuildingSystemFields(
      yearBuilt: json['year_built'] as int?,
      policyNumber: json['policy_number'] as String?,
      inspectorPhone: json['inspector_phone'] as String?,
      signatureDate: json['signature_date'] != null
          ? DateTime.parse(json['signature_date'] as String).toUtc()
          : null,
      roofCoveringMaterial: json['roof_covering_material'] as String?,
      roofAge: json['roof_age'] as int?,
      roofCondition: json['roof_condition'] != null
          ? RatingScale.values.where(
              (v) => v.name == json['roof_condition'] as String,
            ).firstOrNull
          : null,
      electricalPanelType: json['electrical_panel_type'] as String?,
      electricalPanelAmps: json['electrical_panel_amps'] as int?,
      plumbingPipeMaterial: json['plumbing_pipe_material'] as String?,
      waterHeaterType: json['water_heater_type'] as String?,
      hvacType: json['hvac_type'] as String?,
      foundationCracks: json['foundation_cracks'] as bool?,
    );
  }

  // =========================================================================
  // Copy
  // =========================================================================

  /// Returns a new instance with specified fields replaced.
  ///
  /// For nullable fields, pass a closure returning the new value (or null)
  /// to distinguish "set to null" from "leave unchanged".
  SharedBuildingSystemFields copyWith({
    int? Function()? yearBuilt,
    String? Function()? policyNumber,
    String? Function()? inspectorPhone,
    DateTime? Function()? signatureDate,
    String? Function()? roofCoveringMaterial,
    int? Function()? roofAge,
    RatingScale? Function()? roofCondition,
    String? Function()? electricalPanelType,
    int? Function()? electricalPanelAmps,
    String? Function()? plumbingPipeMaterial,
    String? Function()? waterHeaterType,
    String? Function()? hvacType,
    bool? Function()? foundationCracks,
  }) {
    return SharedBuildingSystemFields(
      yearBuilt: yearBuilt != null ? yearBuilt() : this.yearBuilt,
      policyNumber: policyNumber != null ? policyNumber() : this.policyNumber,
      inspectorPhone:
          inspectorPhone != null ? inspectorPhone() : this.inspectorPhone,
      signatureDate:
          signatureDate != null ? signatureDate() : this.signatureDate,
      roofCoveringMaterial: roofCoveringMaterial != null
          ? roofCoveringMaterial()
          : this.roofCoveringMaterial,
      roofAge: roofAge != null ? roofAge() : this.roofAge,
      roofCondition:
          roofCondition != null ? roofCondition() : this.roofCondition,
      electricalPanelType: electricalPanelType != null
          ? electricalPanelType()
          : this.electricalPanelType,
      electricalPanelAmps: electricalPanelAmps != null
          ? electricalPanelAmps()
          : this.electricalPanelAmps,
      plumbingPipeMaterial: plumbingPipeMaterial != null
          ? plumbingPipeMaterial()
          : this.plumbingPipeMaterial,
      waterHeaterType:
          waterHeaterType != null ? waterHeaterType() : this.waterHeaterType,
      hvacType: hvacType != null ? hvacType() : this.hvacType,
      foundationCracks:
          foundationCracks != null ? foundationCracks() : this.foundationCracks,
    );
  }
}
```

**Design decision -- all nullable with closure-based copyWith**: Since all 13 fields are nullable (no single form uses all 13), every `copyWith` parameter uses the `T? Function()?` pattern. This allows callers to explicitly set any field to `null` without ambiguity.

---

## 2. Field Cross-Check Against FIELD_INVENTORY Section 2.2

| # | FIELD_INVENTORY Normalized Name | Type in Inventory | Dart Field | Dart Type | Accounted |
|---|-------------------------------|-------------------|------------|-----------|-----------|
| 1 | `policy_number` | text | `policyNumber` | `String?` | YES |
| 2 | `year_built` | text/integer | `yearBuilt` | `int?` | YES |
| 3 | `inspector_phone` | text | `inspectorPhone` | `String?` | YES |
| 4 | `signature_date` | date | `signatureDate` | `DateTime?` | YES |
| 5 | `roof_type_material` | text/enum | `roofCoveringMaterial` | `String?` | YES |
| 6 | `roof_age` | text/integer | `roofAge` | `int?` | YES |
| 7 | `roof_condition_rating` | enum | `roofCondition` | `RatingScale?` | YES |
| 8 | `electrical_panel_type` | enum | `electricalPanelType` | `String?` | YES |
| 9 | `electrical_panel_capacity` | text/enum | `electricalPanelAmps` | `int?` | YES |
| 10 | `plumbing_pipe_material` | enum | `plumbingPipeMaterial` | `String?` | YES |
| 11 | `water_heater_type` | enum | `waterHeaterType` | `String?` | YES |
| 12 | `hvac_type` | enum | `hvacType` | `String?` | YES |
| 13 | `foundation_cracks` | yes/no + text | `foundationCracks` | `bool?` | YES |

**Result**: All 13 shared fields accounted for. Zero missing.

---

## 3. Field Type Verification

| Field | FIELD_INVENTORY Type | Dart Type | Match | Notes |
|-------|---------------------|-----------|-------|-------|
| `policy_number` | text | `String?` | YES | |
| `year_built` | text/integer | `int?` | YES | Inventory says "text/integer"; we normalize to int. UI handles text input and parsing. Mold "building age" converted at entry. |
| `inspector_phone` | text | `String?` | YES | |
| `signature_date` | date | `DateTime?` | YES | |
| `roof_type_material` | text/enum | `String?` | YES | Free text accommodates varying enum sets |
| `roof_age` | text/integer | `int?` | YES | Same rationale as year_built |
| `roof_condition_rating` | enum | `RatingScale?` | YES | Normalized via RatingScale enum |
| `electrical_panel_type` | enum | `String?` | YES | Free text; form-specific enums at UI layer |
| `electrical_panel_capacity` | text/enum | `int?` | YES | Stored as integer amps; text parsing at entry |
| `plumbing_pipe_material` | enum | `String?` | YES | Free text; form-specific enums at UI layer |
| `water_heater_type` | enum | `String?` | YES | Free text; form-specific enums at UI layer |
| `hvac_type` | enum | `String?` | YES | Free text; form-specific enums at UI layer |
| `foundation_cracks` | yes/no + text | `bool?` | YES | Binary indicator; detail text in formData |

**Decision -- enum fields as String**: Several fields are typed as `enum` in the inventory but stored as `String?` in Dart. This is intentional: the enum values differ across forms (e.g., pipe materials in 4-Point vs General), so form-specific enum constraints are enforced at the UI layer, not the model layer. The RatingScale enum is the exception because its cross-form normalization is the primary purpose.

---

## 4. Overlap Matrix Verification (vs FIELD_INVENTORY Section 2.3)

| Field | 4P | RC | WM | WDO | SK | MA | GI | Count | Matches Inventory |
|-------|----|----|-----|-----|----|----|-----|-------|-------------------|
| yearBuilt | x | x | x | . | . | x | x | 5 | YES |
| policyNumber | x | x | x | . | x | . | . | 4 | YES |
| inspectorPhone | . | . | x | x | x | . | x | 4 | YES |
| signatureDate | x | x | x | x | . | . | . | 4 | YES |
| roofCoveringMaterial | x | x | . | . | . | . | x | 3 | YES |
| roofAge | x | x | . | . | . | . | x | 3 | YES |
| roofCondition | x | x | . | . | . | . | x | 3 | YES |
| electricalPanelType | x | . | . | . | . | . | x | 2 | YES |
| electricalPanelAmps | x | . | . | . | . | . | x | 2 | YES |
| plumbingPipeMaterial | x | . | . | . | . | . | x | 2 | YES |
| waterHeaterType | x | . | . | . | . | . | x | 2 | YES |
| hvacType | x | . | . | . | . | . | x | 2 | YES |
| foundationCracks | . | . | . | . | x | . | x | 2 | YES |

**Result**: All 13 counts match FIELD_INVENTORY Section 2.3 exactly.

---

## 5. Building System Overlap Analysis

From FIELD_INVENTORY Section 2.4, the 4-Point Inspection and General Home Inspection both assess the same four building systems at different granularity levels:

### 5.1 Overlap by Building System

| Building System | Shared Fields | 4-Point Granularity | General Granularity |
|----------------|---------------|---------------------|---------------------|
| **Electrical** | `electricalPanelType`, `electricalPanelAmps` | Binary/specific: 33 fields including 13 hazard checkboxes, panel age/brand, wiring type, condition (S/U) | Checkpoint rating: 12 items rated G/F/P/NA + 9 general info fields |
| **Plumbing** | `plumbingPipeMaterial`, `waterHeaterType` | Per-fixture: 10 fixture conditions (S/U/NA), pipe age, re-pipe status, TPR valve | Checkpoint rating: 13 items rated G/F/P/NA + 7 general info fields |
| **HVAC** | `hvacType` | System-level: AC/heat Y/N, fuel type, working order, service date, 4 hazards | Checkpoint rating: heating (8 items) + AC (6 items) rated G/F/P/NA |
| **Roof** | `roofCoveringMaterial`, `roofAge`, `roofCondition` | Damage-specific: 8 damage checkboxes, leak indicators, permit info, remaining life | Checkpoint rating: 9 items rated G/F/P/NA + 5 general info fields |

### 5.2 Architectural Implication

The shared schema models building system data at the 4-Point granularity level (the more specific superset). General Inspection checkpoint ratings are a separate assessment layer stored in `formData['general.{section}.checkpoints']` as `Map<String, String>` (item name -> rating code).

This means:
- **Shared fields** capture the cross-form overlap (panel type, pipe material, etc.)
- **4-Point form-specific fields** capture the detailed hazard checkboxes and condition ratings
- **General form-specific fields** capture the checkpoint rating tables

Data flows one direction for shared fields: entered once in `SharedBuildingSystemFields`, rendered on all applicable forms.

### 5.3 Foundation System (Special Case)

Foundation assessment exists on Sinkhole and General only (not 4-Point). The shared `foundationCracks` boolean captures the binary indicator. The rich detail differs significantly:
- **Sinkhole**: 19 yes/no/NA checklist items with mandatory measurements for cracks >= 1/8 inch
- **General**: checkpoint rating (G/F/P/NA) with comments

These are stored entirely in formData with no further shared modeling.

---

## 6. Validation Rules Summary

| Field | Rule | Error Message Pattern |
|-------|------|-----------------------|
| `yearBuilt` | `1800 <= value <= DateTime.now().year + 1` | "Year built must be between 1800 and {currentYear+1}" |
| `policyNumber` | Non-empty when form requires it | "Policy number is required for this form type" |
| `inspectorPhone` | Non-empty when form requires it; no strict format | "Inspector phone is required" |
| `signatureDate` | `>= inspectionDate`; `<= now + 30 days` | "Signature date cannot precede inspection date" |
| `roofCoveringMaterial` | Non-empty when form includes roof section | "Roof covering material is required" |
| `roofAge` | `0 <= value <= 100` | "Roof age must be between 0 and 100 years" |
| `roofCondition` | Valid RatingScale value | "Invalid roof condition rating" |
| `electricalPanelType` | Non-empty when applicable | "Panel type is required" |
| `electricalPanelAmps` | Positive integer; typical 60-400 | "Panel amperage must be a positive number" |
| `plumbingPipeMaterial` | Non-empty when applicable | "Pipe material is required" |
| `waterHeaterType` | Non-empty when applicable | "Water heater type is required" |
| `hvacType` | Non-empty when applicable | "HVAC type is required" |
| `foundationCracks` | Valid bool when applicable | -- (tri-state: true/false/null) |

---

## 7. Backward Compatibility Mapping

| SharedBuildingSystemFields | InspectionDraft Field | InspectionSetup Field | Notes |
|---------------------------|----------------------|----------------------|-------|
| `yearBuilt` | `yearBuilt` (int, required) | `yearBuilt` (int, required) | Type change: required -> nullable. Existing inspections populate this from the required field. New inspections may leave it null for WDO/Sinkhole. |
| All other 12 fields | -- | -- | New fields with no backward mapping. |

**Migration note**: `yearBuilt` changes from required (`int`) to optional (`int?`). The migration factory `PropertyData.fromInspectionSetup()` will copy `setup.yearBuilt` into `shared.yearBuilt`. For forms that do not use year built (WDO, Sinkhole), the field is simply null.
