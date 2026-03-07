# 02-03: FormDataKeys Constants -- Form-Specific Namespaces

> **Plan**: 02-03 Form-Specific Namespaces + Key Constants
> **Phase**: 2 -- Unified Property Schema Design
> **Agent**: Technical Writer
> **Date**: 2026-03-07
> **Source**: FIELD_INVENTORY Sections 4.1-4.7, 5.2 + Spec Sections 3.4, 5 + 02-01 + 02-02

---

## 1. Key Naming Convention

### 1.1 Format Rules

Every form-specific field stored in `PropertyData.formData` is addressed by a dot-notation string key. The key does NOT include a form prefix because the outer `Map<FormType, Map<String, dynamic>>` already provides form identity via the `FormType` enum key (see 02-02 decision).

**Key format**:

```
{section}.{fieldName}
```

**Rules**:

| Rule | Description | Example |
|------|-------------|---------|
| **Section names** | camelCase, match FIELD_INVENTORY section names (lowered to camelCase) | `electrical`, `hvac`, `plumbing`, `roof`, `section2`, `q3` |
| **Field names** | camelCase, match FIELD_INVENTORY normalized field names | `mainPanelType`, `clothWiring`, `depressionInYard` |
| **No form prefix** | The FormType enum key on the outer map provides form identity | `electrical.clothWiring` (not `fourPoint.electrical.clothWiring`) |
| **Nested fields** | Additional dot segments for sub-groups | `section3.attic.specificAreas` |
| **Repeating groups** | `List<Map<String, dynamic>>` stored as value; keys within each map entry are plain field names | See Section 1.3 |
| **Booleans** | Checkboxes and Yes/No fields map to `bool` | `electrical.hazardCorrosion` = `true` |
| **Enums** | Stored as `String` with documented valid values | `electrical.generalCondition` = `"satisfactory"` |
| **Dates** | ISO 8601 date string (`"2026-03-07"`) | `hvac.lastServiceDate` = `"2026-03-07"` |
| **Times** | ISO 8601 time string (`"14:30"`) | `header.inspectionTime` = `"14:30"` |
| **Nullable** | Conditional fields may be absent from the map | `electrical.secondPanelType` absent if no second panel |

### 1.2 Section Names by Form Type

| FormType | Sections | Source |
|----------|----------|--------|
| `fourPoint` | `header`, `electrical`, `hvac`, `plumbing`, `roof`, `roofSecondary`, `inspector` | FIELD_INVENTORY 4.1 |
| `roofCondition` | `header`, `roof`, `inspector` | FIELD_INVENTORY 4.2 |
| `windMitigation` | `header`, `q1`, `q2`, `q3`, `q4`, `q5`, `q6`, `q7`, `q8`, `inspector` | FIELD_INVENTORY 4.3 |
| `wdo` | `header`, `findings`, `inaccessible`, `treatment`, `certification` | FIELD_INVENTORY 4.4 |
| `sinkholeInspection` | `exterior`, `interior`, `garage`, `appurtenant`, `additional`, `scheduling` | FIELD_INVENTORY 4.5 |
| `moldAssessment` | `header`, `scope`, `findings`, `moisture`, `sampling`, `remediation` | FIELD_INVENTORY 4.6 |
| `generalInspection` | `header`, `roofDeck`, `electrical`, `plumbing`, `waterHeater`, `heating`, `airConditioning`, `structure`, `exterior`, `interior`, `insulation`, `appliances`, `lifeSafety` | FIELD_INVENTORY 4.7 |

**Design decision -- WDO section names**: The FIELD_INVENTORY uses `section1` through `section5` for WDO, but these are opaque. Renamed to semantically meaningful names: `header` (general info), `findings` (inspection findings), `inaccessible` (obstructions), `treatment` (treatment info), `certification` (comments + signature). This improves readability without losing traceability since each constant's doc comment references the original FIELD_INVENTORY field key.

**Design decision -- Sinkhole section names**: Similarly, Sinkhole `section0` through `section6` renamed to `exterior` (Section 1), `interior` (Section 2), `garage` (Section 3), `appurtenant` (Section 4), `additional` (Section 5), `scheduling` (Section 6). Section 0 (property ID) maps entirely to universal + shared fields.

### 1.3 Repeating Group Convention

Four repeating group patterns exist across the 7 form types:

| Pattern | Form | Fixed/Dynamic | Structure |
|---------|------|---------------|-----------|
| WDO inaccessible areas | WDO | Fixed (5 areas) | 5 areas x 3 fields each |
| Sinkhole scheduling attempts | Sinkhole | Fixed (4 attempts) | 4 attempts x 4 fields each |
| General Inspection checkpoints | General | Semi-fixed (per section) | N items x rating + comment |
| 4-Point plumbing fixtures | 4-Point | Fixed (10 fixtures) | 10 fixtures x 1 rating each |

**Decision: Flat indexed keys for fixed-count groups; `List<Map>` for checkpoints.**

Rationale:
- WDO inaccessible areas and Sinkhole scheduling attempts have a known, fixed number of entries defined by the regulatory form. Using flat indexed keys (`inaccessible.0.inaccessible`, `inaccessible.0.specificAreas`, `inaccessible.0.reason`) keeps them as simple string lookups with compile-time constants for every slot.
- 4-Point plumbing fixtures are a fixed set of 10 named appliances. Each gets its own dedicated constant key (e.g., `plumbing.fixtureDishwasher`). This is NOT an indexed repeating group -- it is a named fixture matrix.
- General Inspection checkpoints are semi-dynamic (the checkpoint list per section is defined by the form template, but extensions are possible per 6.3 Recommendation #3). These use `List<Map<String, dynamic>>` stored as the value for a single key (e.g., `electrical.checkpoints`).

### 1.4 Repeating Group Deep Dive

#### 1.4.1 WDO Inaccessible Areas (5 areas x 3 fields)

The WDO form (FDACS-13645) Section 3 defines 5 fixed area categories: Attic, Interior, Exterior, Crawlspace, Other. Each has 3 fields: a boolean (inaccessible?), specific areas text, and reason text.

**Storage approach**: Flat indexed keys. Each area gets a named constant.

```dart
// FormDataKeys constants
static const wdo_inaccessibleAtticFlag = 'inaccessible.attic.flag';           // bool
static const wdo_inaccessibleAtticAreas = 'inaccessible.attic.specificAreas'; // String
static const wdo_inaccessibleAtticReason = 'inaccessible.attic.reason';       // String
static const wdo_inaccessibleInteriorFlag = 'inaccessible.interior.flag';
static const wdo_inaccessibleInteriorAreas = 'inaccessible.interior.specificAreas';
static const wdo_inaccessibleInteriorReason = 'inaccessible.interior.reason';
// ... (Exterior, Crawlspace, Other follow the same pattern)
```

**JSON representation**:
```json
{
  "inaccessible.attic.flag": true,
  "inaccessible.attic.specificAreas": "Southeast corner above master bedroom",
  "inaccessible.attic.reason": "Insulation blocking access, HVAC ductwork",
  "inaccessible.interior.flag": false,
  "inaccessible.exterior.flag": true,
  "inaccessible.exterior.specificAreas": "North wall behind dense landscaping",
  "inaccessible.exterior.reason": "Dense vegetation within 6 inches of wall",
  "inaccessible.crawlspace.flag": false,
  "inaccessible.other.flag": false
}
```

**Helper method signatures**:
```dart
/// Returns true if the specified WDO area is marked inaccessible.
bool isWdoAreaInaccessible(PropertyData data, String area) {
  return data.getFormValue<bool>(
    FormType.wdo,
    'inaccessible.$area.flag',
  ) ?? false;
}

/// Returns all inaccessible WDO area names.
List<String> getInaccessibleWdoAreas(PropertyData data) {
  const areas = ['attic', 'interior', 'exterior', 'crawlspace', 'other'];
  return areas.where((a) => isWdoAreaInaccessible(data, a)).toList();
}
```

**JSON round-trip**: Each field is a simple scalar (`bool` or `String`) stored directly in the flat `Map<String, dynamic>`. `toJson()` writes them as-is; `fromJson()` reads them as-is. No special serialization logic needed.

#### 1.4.2 Sinkhole Scheduling Attempts (4 attempts x 4 fields)

Citizens Sinkhole form Section 6 defines 4 fixed scheduling attempt slots, each with date, time, number called, and result.

**Storage approach**: Flat indexed keys using attempt number (0-based index).

```dart
// FormDataKeys constants (attempt indices 0-3)
static const sk_schedulingAttempt0Date = 'scheduling.attempts.0.date';     // String (ISO date)
static const sk_schedulingAttempt0Time = 'scheduling.attempts.0.time';     // String (ISO time)
static const sk_schedulingAttempt0Number = 'scheduling.attempts.0.number'; // String
static const sk_schedulingAttempt0Result = 'scheduling.attempts.0.result'; // String
static const sk_schedulingAttempt1Date = 'scheduling.attempts.1.date';
// ... (attempts 1-3 follow the same pattern)
```

**JSON representation**:
```json
{
  "scheduling.attempts.0.date": "2026-02-15",
  "scheduling.attempts.0.time": "09:30",
  "scheduling.attempts.0.number": "813-555-0199",
  "scheduling.attempts.0.result": "No answer",
  "scheduling.attempts.1.date": "2026-02-17",
  "scheduling.attempts.1.time": "14:00",
  "scheduling.attempts.1.number": "813-555-0199",
  "scheduling.attempts.1.result": "Left voicemail",
  "scheduling.attempts.2.date": "2026-02-20",
  "scheduling.attempts.2.time": "10:15",
  "scheduling.attempts.2.number": "813-555-0199",
  "scheduling.attempts.2.result": "Scheduled for 2026-02-25"
}
```

**Helper method signatures**:
```dart
/// Returns the scheduling attempt data for a given index (0-3).
/// Returns null values for fields not yet populated.
({String? date, String? time, String? number, String? result})
    getSinkholeSchedulingAttempt(PropertyData data, int index) {
  assert(index >= 0 && index <= 3);
  return (
    date: data.getFormValue<String>(
      FormType.sinkholeInspection, 'scheduling.attempts.$index.date',
    ),
    time: data.getFormValue<String>(
      FormType.sinkholeInspection, 'scheduling.attempts.$index.time',
    ),
    number: data.getFormValue<String>(
      FormType.sinkholeInspection, 'scheduling.attempts.$index.number',
    ),
    result: data.getFormValue<String>(
      FormType.sinkholeInspection, 'scheduling.attempts.$index.result',
    ),
  );
}

/// Returns the number of populated scheduling attempts (0-4).
int getSinkholeAttemptCount(PropertyData data) {
  int count = 0;
  for (int i = 0; i < 4; i++) {
    if (data.getFormValue<String>(
      FormType.sinkholeInspection, 'scheduling.attempts.$i.date',
    ) != null) {
      count++;
    }
  }
  return count;
}
```

**JSON round-trip**: All values are simple strings. No special serialization. The indexed key pattern (`scheduling.attempts.0.date`) is a flat string key in the map, not actual nesting.

#### 1.4.3 General Inspection Checkpoint Tables (N items x rating + comment)

Each General Inspection section has a checkpoint table where N items are rated on Good/Fair/Poor/N/A with optional comments. The number of items per section is defined by the form template (see FIELD_INVENTORY 4.7.2).

**Storage approach**: `List<Map<String, dynamic>>` stored as a single key value.

```dart
// FormDataKeys constants
static const gi_electricalCheckpoints = 'electrical.checkpoints';   // List<Map<String, dynamic>>
static const gi_electricalNotes = 'electrical.notes';               // String (narrative)
static const gi_plumbingCheckpoints = 'plumbing.checkpoints';       // List<Map<String, dynamic>>
static const gi_plumbingNotes = 'plumbing.notes';                   // String
// ... (one pair per section)
```

Each entry in the list:
```dart
{
  'item': 'Service Line',     // String - checkpoint item name
  'rating': 'good',           // String - "good" | "fair" | "poor" | "na"
  'comment': 'No issues',     // String? - optional comment (required if "poor")
}
```

**JSON representation**:
```json
{
  "electrical.checkpoints": [
    { "item": "Service Line", "rating": "good", "comment": null },
    { "item": "Main Panel", "rating": "good", "comment": null },
    { "item": "Breakers", "rating": "fair", "comment": "Minor corrosion on 2 breakers" },
    { "item": "Fuses", "rating": "na", "comment": "No fuses - circuit breaker system" },
    { "item": "Conductors", "rating": "good", "comment": null },
    { "item": "Sub-Panel", "rating": "na", "comment": "No sub-panel present" },
    { "item": "Wiring", "rating": "good", "comment": null },
    { "item": "GFCI", "rating": "good", "comment": null },
    { "item": "Grounding", "rating": "good", "comment": null },
    { "item": "Lights", "rating": "good", "comment": null },
    { "item": "Outlets", "rating": "fair", "comment": "Missing cover plate in garage" },
    { "item": "Switches", "rating": "good", "comment": null }
  ],
  "electrical.notes": "Recommend replacing corroded breakers within 12 months."
}
```

**Helper method signatures**:
```dart
/// Returns all checkpoint entries for a General Inspection section.
List<Map<String, dynamic>> getCheckpoints(
  PropertyData data,
  String section,
) {
  final raw = data.getFormValue<List<dynamic>>(
    FormType.generalInspection,
    '$section.checkpoints',
  );
  if (raw == null) return [];
  return raw.cast<Map<String, dynamic>>();
}

/// Returns the rating for a specific checkpoint item in a section.
String? getCheckpointRating(
  PropertyData data,
  String section,
  String itemName,
) {
  final checkpoints = getCheckpoints(data, section);
  for (final cp in checkpoints) {
    if (cp['item'] == itemName) return cp['rating'] as String?;
  }
  return null;
}

/// Updates a checkpoint rating and returns a new PropertyData.
PropertyData setCheckpointRating(
  PropertyData data,
  String section,
  String itemName,
  String rating, {
  String? comment,
}) {
  final checkpoints = List<Map<String, dynamic>>.from(
    getCheckpoints(data, section),
  );
  final idx = checkpoints.indexWhere((cp) => cp['item'] == itemName);
  final entry = {'item': itemName, 'rating': rating, 'comment': comment};
  if (idx >= 0) {
    checkpoints[idx] = entry;
  } else {
    checkpoints.add(entry);
  }
  return data.setFormValue(
    FormType.generalInspection,
    '$section.checkpoints',
    checkpoints,
  );
}
```

**JSON round-trip**: The `List<Map<String, dynamic>>` is natively JSON-compatible. `toJson()` writes it directly. `fromJson()` reads it as `List<dynamic>` and casts each entry to `Map<String, dynamic>`. No custom serialization needed beyond the standard `PropertyData.toJson()`/`fromJson()` which already handles nested collections.

#### 1.4.4 4-Point Plumbing Fixture Matrix (10 fixtures x S/U/NA rating)

The 4-Point form has 10 named plumbing fixtures, each rated Satisfactory/Unsatisfactory/N-A. This is NOT a repeating group -- it is a fixed set of named fields.

**Storage approach**: Individual string constants for each fixture.

```dart
// FormDataKeys constants
static const fp_plumbingFixtureDishwasher = 'plumbing.fixtureDishwasher';          // String: "s"|"u"|"na"
static const fp_plumbingFixtureRefrigerator = 'plumbing.fixtureRefrigerator';      // String: "s"|"u"|"na"
static const fp_plumbingFixtureWashingMachine = 'plumbing.fixtureWashingMachine';  // String: "s"|"u"|"na"
static const fp_plumbingFixtureWaterHeater = 'plumbing.fixtureWaterHeater';        // String: "s"|"u"|"na"
static const fp_plumbingFixtureShowersTubs = 'plumbing.fixtureShowersTubs';        // String: "s"|"u"|"na"
static const fp_plumbingFixtureToilets = 'plumbing.fixtureToilets';                // String: "s"|"u"|"na"
static const fp_plumbingFixtureSinks = 'plumbing.fixtureSinks';                    // String: "s"|"u"|"na"
static const fp_plumbingFixtureSumpPump = 'plumbing.fixtureSumpPump';              // String: "s"|"u"|"na"
static const fp_plumbingFixtureMainShutoff = 'plumbing.fixtureMainShutoff';        // String: "s"|"u"|"na"
static const fp_plumbingFixtureAllOther = 'plumbing.fixtureAllOther';              // String: "s"|"u"|"na"
static const fp_plumbingFixtureUnsatisfactoryComments = 'plumbing.fixtureUnsatisfactoryComments'; // String?
```

**JSON representation**:
```json
{
  "plumbing.fixtureDishwasher": "s",
  "plumbing.fixtureRefrigerator": "s",
  "plumbing.fixtureWashingMachine": "u",
  "plumbing.fixtureWaterHeater": "s",
  "plumbing.fixtureShowersTubs": "s",
  "plumbing.fixtureToilets": "s",
  "plumbing.fixtureSinks": "s",
  "plumbing.fixtureSumpPump": "na",
  "plumbing.fixtureMainShutoff": "s",
  "plumbing.fixtureAllOther": "s",
  "plumbing.fixtureUnsatisfactoryComments": "Washing machine supply hoses show signs of wear, recommend replacement with braided steel lines"
}
```

**Helper method signatures**:
```dart
/// Returns a map of fixture name -> rating for the 4-Point plumbing section.
Map<String, String> getFixtureRatings(PropertyData data) {
  const fixtures = [
    'Dishwasher', 'Refrigerator', 'WashingMachine', 'WaterHeater',
    'ShowersTubs', 'Toilets', 'Sinks', 'SumpPump', 'MainShutoff', 'AllOther',
  ];
  final result = <String, String>{};
  for (final f in fixtures) {
    final rating = data.getFormValue<String>(
      FormType.fourPoint, 'plumbing.fixture$f',
    );
    if (rating != null) result[f] = rating;
  }
  return result;
}

/// Returns true if any fixture is rated unsatisfactory.
bool hasUnsatisfactoryFixture(PropertyData data) {
  return getFixtureRatings(data).values.any((r) => r == 'u');
}
```

**JSON round-trip**: Each fixture rating is a simple `String` value. No special serialization. The comment field is conditionally present only when any fixture is unsatisfactory.

### 1.5 Input Pattern Coverage

Cross-reference of all 14 input patterns from FIELD_INVENTORY Section 5.2 to their key convention:

| # | Pattern | Key Convention | Dart Value Type | Example Key |
|---|---------|---------------|-----------------|-------------|
| 1 | Rating scale | `{section}.{fieldName}` | `String` (rating code) | `electrical.generalCondition` |
| 2 | Yes/No binary | `{section}.{fieldName}` | `bool` | `findings.noVisibleSigns` |
| 3 | Yes/No/NA ternary | `{section}.{itemId}` + `{section}.{itemId}Detail` | `String` ("yes"/"no"/"na") + `String?` | `exterior.depressionInYard`, `exterior.depressionInYardDetail` |
| 4 | Radio selection | `{section}.{fieldName}` | `String` (selected option) | `q3.roofDeckAttachment` |
| 5 | Checkbox group | `{section}.{fieldName}` per checkbox | `bool` per item | `electrical.hazardCorrosion` |
| 6 | Matrix (item x rating) | Named keys (4-Pt fixtures) or `List<Map>` (General checkpoints) | `String` per fixture or `List<Map<String, dynamic>>` | `plumbing.fixtureSinks`, `electrical.checkpoints` |
| 7 | Free text | `{section}.{fieldName}` | `String` | `header.buildingType` |
| 8 | Multi-line text | `{section}.{fieldName}` | `String` | `findings.liveWdoDescription` |
| 9 | Signature | Stored in `UniversalPropertyFields.inspectorSignaturePath` or form-specific key | `String` (file path) | `certification.licenseeSigPath` |
| 10 | Image/photo | Managed by media module, not in formData | N/A (media manifest) | N/A |
| 11 | Date | `{section}.{fieldName}` | `String` (ISO 8601 date) | `hvac.lastServiceDate` |
| 12 | Time | `{section}.{fieldName}` | `String` (ISO 8601 time) | `header.inspectionTime` |
| 13 | Numeric | `{section}.{fieldName}` | `int` or `double` | `q7.windowCount` |
| 14 | Repeating group | Flat indexed keys (fixed) or `List<Map>` (semi-dynamic) | Mixed (see Section 1.4) | `scheduling.attempts.0.date`, `electrical.checkpoints` |

**Pattern 10 (Image/photo) note**: Photo and document evidence is managed by the existing media module (`capturedPhotoPaths`, `capturedEvidencePaths`) on `PropertyData`, not as formData keys. The checkbox fields that accompany photos on the current PDF maps (e.g., `checkbox.photo_exterior_front`) are also media-module concerns, not formData fields. FormDataKeys does not include image/photo constants.

---

## 2. FormDataKeys Constants -- All 7 Form Types

### Usage Pattern

```dart
// Reading a form-specific value:
final clothWiring = data.getFormValue<bool>(
  FormType.fourPoint,
  FormDataKeys.fp_electricalClothWiring,
);

// Writing a form-specific value:
final updated = data.setFormValue(
  FormType.fourPoint,
  FormDataKeys.fp_electricalClothWiring,
  true,
);
```

### Constant Naming Convention

Each constant follows the pattern: `{formPrefix}_{sectionFieldName}`

| FormType | Constant Prefix | Example |
|----------|----------------|---------|
| fourPoint | `fp_` | `fp_electricalClothWiring` |
| roofCondition | `rc_` | `rc_roofRemainingLife` |
| windMitigation | `wm_` | `wm_q3RoofDeckAttachment` |
| wdo | `wdo_` | `wdo_findingsVisibleEvidence` |
| sinkholeInspection | `sk_` | `sk_exteriorDepressionInYard` |
| moldAssessment | `ma_` | `ma_scopeAreasAssessed` |
| generalInspection | `gi_` | `gi_electricalServiceLine` |

### 2.1 Four-Point Inspection (FormType.fourPoint)

Source: FIELD_INVENTORY Section 4.1.2 (gap fields only -- mapped fields are photo/signature/shared).

**Excluded fields** (already in UniversalPropertyFields or SharedBuildingSystemFields):
- `property_address`, `inspection_date`, `inspector_name`, `inspector_company`, `inspector_license_number`, `client_name`, `inspector_signature`, `comments` (8 universal)
- `policy_number`, `year_built`, `signature_date`, `roof_covering_material`, `roof_age`, `roof_condition`, `electrical_panel_type`, `electrical_panel_amps`, `plumbing_pipe_material`, `water_heater_type`, `hvac_type` (11 of 13 shared; `inspector_phone` and `foundation_cracks` are not on 4-Point)

**Photo/evidence fields excluded**: All `checkbox.photo_*` and `image.photo_*` fields (27 mapped fields) are managed by the media module, not formData.

```dart
abstract final class FormDataKeys {
  // =========================================================================
  // 4-POINT INSPECTION (fp_)
  // Source: FIELD_INVENTORY Section 4.1.2
  // =========================================================================

  // --- Electrical System (33 fields) ---

  // Main Panel
  static const fp_electricalMainPanelType = 'electrical.mainPanelType';                 // String: "circuit_breaker" | "fuse"
  static const fp_electricalMainPanelAmps = 'electrical.mainPanelAmps';                 // int
  static const fp_electricalMainAmpsSufficient = 'electrical.mainAmpsSufficient';       // bool
  static const fp_electricalMainPanelAge = 'electrical.mainPanelAge';                   // String
  static const fp_electricalMainPanelYearUpdated = 'electrical.mainPanelYearUpdated';   // String
  static const fp_electricalMainPanelBrand = 'electrical.mainPanelBrand';               // String

  // Second Panel (conditional: second panel exists)
  static const fp_electricalSecondPanelType = 'electrical.secondPanelType';             // String?: "circuit_breaker" | "fuse"
  static const fp_electricalSecondPanelAmps = 'electrical.secondPanelAmps';             // int?
  static const fp_electricalSecondAmpsSufficient = 'electrical.secondAmpsSufficient';   // bool?
  static const fp_electricalSecondPanelAge = 'electrical.secondPanelAge';               // String?
  static const fp_electricalSecondPanelYearUpdated = 'electrical.secondPanelYearUpdated'; // String?
  static const fp_electricalSecondPanelBrand = 'electrical.secondPanelBrand';           // String?

  // Wiring Indicators
  static const fp_electricalClothWiring = 'electrical.clothWiring';                     // bool
  static const fp_electricalKnobAndTube = 'electrical.knobAndTube';                     // bool
  static const fp_electricalAluminumBranchWiring = 'electrical.aluminumBranchWiring';   // bool
  static const fp_electricalAluminumBranchDetails = 'electrical.aluminumBranchDetails'; // String? (conditional: aluminum present)
  static const fp_electricalCopalumCrimp = 'electrical.copalumCrimp';                   // bool? (conditional: aluminum present)
  static const fp_electricalAlumiconn = 'electrical.alumiconn';                         // bool? (conditional: aluminum present)
  static const fp_electricalWiringType = 'electrical.wiringType';                       // String: "copper" | "mn_bx_conduit"

  // Hazard Checkboxes (13 items)
  static const fp_electricalHazardBlowingFuses = 'electrical.hazardBlowingFuses';               // bool
  static const fp_electricalHazardTrippingBreakers = 'electrical.hazardTrippingBreakers';       // bool
  static const fp_electricalHazardEmptySockets = 'electrical.hazardEmptySockets';               // bool
  static const fp_electricalHazardLooseWiring = 'electrical.hazardLooseWiring';                 // bool
  static const fp_electricalHazardImproperGrounding = 'electrical.hazardImproperGrounding';     // bool
  static const fp_electricalHazardCorrosion = 'electrical.hazardCorrosion';                     // bool
  static const fp_electricalHazardOverFusing = 'electrical.hazardOverFusing';                   // bool
  static const fp_electricalHazardDoubleTaps = 'electrical.hazardDoubleTaps';                   // bool
  static const fp_electricalHazardExposedWiring = 'electrical.hazardExposedWiring';             // bool
  static const fp_electricalHazardUnsafeWiring = 'electrical.hazardUnsafeWiring';               // bool
  static const fp_electricalHazardImproperBreakerSize = 'electrical.hazardImproperBreakerSz';   // bool
  static const fp_electricalHazardScorching = 'electrical.hazardScorching';                     // bool
  static const fp_electricalHazardOther = 'electrical.hazardOther';                             // bool
  static const fp_electricalHazardOtherDesc = 'electrical.hazardOtherDesc';                     // String? (conditional: hazardOther)

  // Condition
  static const fp_electricalGeneralCondition = 'electrical.generalCondition';           // String: "satisfactory" | "unsatisfactory"

  // --- HVAC System (11 fields) ---
  static const fp_hvacCentralAc = 'hvac.centralAc';                                     // bool
  static const fp_hvacCentralHeat = 'hvac.centralHeat';                                 // bool
  static const fp_hvacPrimaryHeatSource = 'hvac.primaryHeatSource';                     // String
  static const fp_hvacGoodWorkingOrder = 'hvac.goodWorkingOrder';                       // bool
  static const fp_hvacLastServiceDate = 'hvac.lastServiceDate';                         // String (date or text)
  static const fp_hvacHazardWoodStoveFireplace = 'hvac.hazardWoodStoveFireplace';       // bool
  static const fp_hvacHazardSpaceHeaterPrimary = 'hvac.hazardSpaceHeaterPrimary';       // bool
  static const fp_hvacHazardSourcePortable = 'hvac.hazardSourcePortable';               // bool? (conditional: space heater)
  static const fp_hvacHazardAirHandlerBlockage = 'hvac.hazardAirHandlerBlockage';       // bool
  static const fp_hvacSystemAge = 'hvac.systemAge';                                     // String
  static const fp_hvacYearUpdated = 'hvac.yearUpdated';                                 // String

  // --- Plumbing System (19 fields, excludes 5 pipe-type checkboxes -> shared) ---
  static const fp_plumbingTprValve = 'plumbing.tprValve';                               // bool
  static const fp_plumbingActiveLeak = 'plumbing.activeLeak';                           // bool
  static const fp_plumbingPriorLeak = 'plumbing.priorLeak';                             // bool
  static const fp_plumbingWaterHeaterLocation = 'plumbing.waterHeaterLocation';         // String

  // Fixture Condition Matrix (10 fixtures x S/U/NA)
  static const fp_plumbingFixtureDishwasher = 'plumbing.fixtureDishwasher';             // String: "s" | "u" | "na"
  static const fp_plumbingFixtureRefrigerator = 'plumbing.fixtureRefrigerator';         // String: "s" | "u" | "na"
  static const fp_plumbingFixtureWashingMachine = 'plumbing.fixtureWashingMachine';     // String: "s" | "u" | "na"
  static const fp_plumbingFixtureWaterHeater = 'plumbing.fixtureWaterHeater';           // String: "s" | "u" | "na"
  static const fp_plumbingFixtureShowersTubs = 'plumbing.fixtureShowersTubs';           // String: "s" | "u" | "na"
  static const fp_plumbingFixtureToilets = 'plumbing.fixtureToilets';                   // String: "s" | "u" | "na"
  static const fp_plumbingFixtureSinks = 'plumbing.fixtureSinks';                       // String: "s" | "u" | "na"
  static const fp_plumbingFixtureSumpPump = 'plumbing.fixtureSumpPump';                 // String: "s" | "u" | "na"
  static const fp_plumbingFixtureMainShutoff = 'plumbing.fixtureMainShutoff';           // String: "s" | "u" | "na"
  static const fp_plumbingFixtureAllOther = 'plumbing.fixtureAllOther';                 // String: "s" | "u" | "na"
  static const fp_plumbingFixtureUnsatisfactoryComments = 'plumbing.fixtureUnsatisfactoryComments'; // String?

  // Piping
  static const fp_plumbingPipingAge = 'plumbing.pipingAge';                             // String
  static const fp_plumbingCompletelyRepiped = 'plumbing.completelyRepiped';             // bool
  static const fp_plumbingPartiallyRepiped = 'plumbing.partiallyRepiped';               // bool
  static const fp_plumbingRepipeDetails = 'plumbing.repipeDetails';                     // String? (conditional: repiped)

  // Pipe type checkboxes (form-specific detail; primary material is in shared)
  static const fp_plumbingPipeCopper = 'plumbing.pipeCopper';                           // bool
  static const fp_plumbingPipePvcCpvc = 'plumbing.pipePvcCpvc';                         // bool
  static const fp_plumbingPipeGalvanized = 'plumbing.pipeGalvanized';                   // bool
  static const fp_plumbingPipePex = 'plumbing.pipePex';                                 // bool
  static const fp_plumbingPipePolybutylene = 'plumbing.pipePolybutylene';               // bool
  static const fp_plumbingPipeOther = 'plumbing.pipeOther';                             // bool
  static const fp_plumbingPipeOtherDesc = 'plumbing.pipeOtherDesc';                     // String? (conditional: pipeOther)

  // --- Roof -- Primary (18 form-specific fields, excludes shared material/age/condition) ---
  static const fp_roofPrimaryRemainingLife = 'roof.primaryRemainingLife';                // String (years)
  static const fp_roofPrimaryLastPermitDate = 'roof.primaryLastPermitDate';             // String
  static const fp_roofPrimaryLastUpdate = 'roof.primaryLastUpdate';                     // String
  static const fp_roofPrimaryFullReplacement = 'roof.primaryFullReplacement';           // bool
  static const fp_roofPrimaryPartialReplacement = 'roof.primaryPartialReplacement';     // bool
  static const fp_roofPrimaryReplacementPct = 'roof.primaryReplacementPct';             // String? (conditional: partial)
  static const fp_roofPrimaryOverallCondition = 'roof.primaryOverallCondition';         // String: "satisfactory" | "unsatisfactory"
  static const fp_roofPrimaryDamageCracking = 'roof.primaryDamageCracking';             // bool
  static const fp_roofPrimaryDamageCuppingCurling = 'roof.primaryDamageCuppingCurling'; // bool
  static const fp_roofPrimaryDamageGranuleLoss = 'roof.primaryDamageGranuleLoss';       // bool
  static const fp_roofPrimaryDamageExposedAsphalt = 'roof.primaryDamageExposedAsphalt'; // bool
  static const fp_roofPrimaryDamageExposedFelt = 'roof.primaryDamageExposedFelt';       // bool
  static const fp_roofPrimaryDamageMissingTabsTiles = 'roof.primaryDamageMissingTabsTiles'; // bool
  static const fp_roofPrimaryDamageSoftSpots = 'roof.primaryDamageSoftSpots';           // bool
  static const fp_roofPrimaryDamageHail = 'roof.primaryDamageHail';                     // bool
  static const fp_roofPrimaryLeaks = 'roof.primaryLeaks';                               // bool
  static const fp_roofPrimaryAtticUndersideLeaks = 'roof.primaryAtticUndersideLeaks';   // bool
  static const fp_roofPrimaryInteriorCeilingLeaks = 'roof.primaryInteriorCeilingLeaks'; // bool

  // --- Roof -- Secondary (mirrors primary, conditional on multiple roof coverings) ---
  static const fp_roofSecondaryCoveringMaterial = 'roofSecondary.coveringMaterial';     // String
  static const fp_roofSecondaryAge = 'roofSecondary.age';                               // String
  static const fp_roofSecondaryRemainingLife = 'roofSecondary.remainingLife';           // String
  static const fp_roofSecondaryLastPermitDate = 'roofSecondary.lastPermitDate';         // String
  static const fp_roofSecondaryLastUpdate = 'roofSecondary.lastUpdate';                 // String
  static const fp_roofSecondaryFullReplacement = 'roofSecondary.fullReplacement';       // bool
  static const fp_roofSecondaryPartialReplacement = 'roofSecondary.partialReplacement'; // bool
  static const fp_roofSecondaryReplacementPct = 'roofSecondary.replacementPct';         // String?
  static const fp_roofSecondaryOverallCondition = 'roofSecondary.overallCondition';     // String: "satisfactory" | "unsatisfactory"
  static const fp_roofSecondaryDamageCracking = 'roofSecondary.damageCracking';         // bool
  static const fp_roofSecondaryDamageCuppingCurling = 'roofSecondary.damageCuppingCurling'; // bool
  static const fp_roofSecondaryDamageGranuleLoss = 'roofSecondary.damageGranuleLoss';   // bool
  static const fp_roofSecondaryDamageExposedAsphalt = 'roofSecondary.damageExposedAsphalt'; // bool
  static const fp_roofSecondaryDamageExposedFelt = 'roofSecondary.damageExposedFelt';   // bool
  static const fp_roofSecondaryDamageMissingTabsTiles = 'roofSecondary.damageMissingTabsTiles'; // bool
  static const fp_roofSecondaryDamageSoftSpots = 'roofSecondary.damageSoftSpots';       // bool
  static const fp_roofSecondaryDamageHail = 'roofSecondary.damageHail';                 // bool
  static const fp_roofSecondaryLeaks = 'roofSecondary.leaks';                           // bool
  static const fp_roofSecondaryAtticUndersideLeaks = 'roofSecondary.atticUndersideLeaks'; // bool
  static const fp_roofSecondaryInteriorCeilingLeaks = 'roofSecondary.interiorCeilingLeaks'; // bool

  // --- Inspector Certification (form-specific fields only) ---
  static const fp_inspectorTitle = 'inspector.title';                                   // String
  static const fp_inspectorLicenseType = 'inspector.licenseType';                       // String

  // --- 4-Point Totals ---
  // Electrical: 34 constants (FIELD_INVENTORY counts 33 fields; hazardOther checkbox+text = 2 constants)
  // HVAC: 11 constants
  // Plumbing: 26 constants (10 fixtures + 1 comments + 4 leak/valve + 4 piping + 7 pipe types)
  // Roof Primary: 18 constants
  // Roof Secondary: 20 constants
  // Inspector: 2 constants
  // TOTAL: 111 form-specific constants
```

### 2.2 Roof Condition Form (FormType.roofCondition)

Source: FIELD_INVENTORY Section 4.2.2 (gap fields only).

**Excluded fields**: 8 universal, plus shared: `policy_number`, `year_built`, `signature_date`, `roof_covering_material`, `roof_age`, `roof_condition`. Photo/evidence fields excluded (media module).

```dart
  // =========================================================================
  // ROOF CONDITION FORM (rc_)
  // Source: FIELD_INVENTORY Section 4.2.2
  // =========================================================================

  // --- Roof Assessment ---
  static const rc_roofRemainingLife = 'roof.remainingLife';                             // String (years)
  static const rc_roofConditionRating = 'roof.conditionRating';                         // String: "good" | "fair" | "poor" | "failed"
  static const rc_roofPriorRepairs = 'roof.priorRepairs';                               // bool
  static const rc_roofPriorRepairsDesc = 'roof.priorRepairsDesc';                       // String? (conditional: priorRepairs)
  static const rc_roofLeaks = 'roof.leaks';                                             // bool
  static const rc_roofLeaksDesc = 'roof.leaksDesc';                                     // String? (conditional: leaks)
  static const rc_roofWindDamage = 'roof.windDamage';                                   // bool
  static const rc_roofWindDamageDesc = 'roof.windDamageDesc';                           // String? (conditional: windDamage)
  static const rc_roofHailDamage = 'roof.hailDamage';                                   // bool
  static const rc_roofHailDamageDesc = 'roof.hailDamageDesc';                           // String? (conditional: hailDamage)
  static const rc_roofNumberOfLayers = 'roof.numberOfLayers';                           // String
  static const rc_roofFlashingCondition = 'roof.flashingCondition';                     // String (enum)
  static const rc_roofSoffitFasciaCondition = 'roof.soffitFasciaCondition';             // String (enum)
  static const rc_roofGuttersDownspouts = 'roof.guttersDownspouts';                     // String (enum)
  static const rc_roofComments = 'roof.comments';                                       // String? (multi-line)

  // TOTAL: 15 form-specific constants
```

### 2.3 Wind Mitigation (FormType.windMitigation)

Source: FIELD_INVENTORY Section 4.3.2 (gap fields only).

**Excluded fields**: 8 universal, plus shared: `policy_number`, `year_built`, `inspector_phone`, `signature_date`. Photo/document evidence excluded (media module).

```dart
  // =========================================================================
  // WIND MITIGATION (wm_)
  // Source: FIELD_INVENTORY Section 4.3.2
  // =========================================================================

  // --- Q1: Building Code ---
  static const wm_q1BuildingCode = 'q1.buildingCode';                                   // String (radio selection)
  static const wm_q1Year = 'q1.year';                                                   // String (conditional text)

  // --- Q2: Roof Covering ---
  static const wm_q2RoofCovering = 'q2.roofCovering';                                   // String (radio selection)
  static const wm_q2PermitDate = 'q2.permitDate';                                       // String (conditional)

  // --- Q3: Roof Deck Attachment ---
  static const wm_q3RoofDeckAttachment = 'q3.roofDeckAttachment';                       // String: "A" | "B" | "C" | "D"

  // --- Q4: Roof-to-Wall Attachment ---
  static const wm_q4RoofWallAttachment = 'q4.roofWallAttachment';                       // String: "toe_nails" | "clips" | "single_wraps" | "double_wraps" | "structural"

  // --- Q5: Roof Geometry ---
  static const wm_q5RoofGeometry = 'q5.roofGeometry';                                   // String: "hip" | "non_hip" | "flat"

  // --- Q6: Secondary Water Resistance ---
  static const wm_q6SecondaryWaterResistance = 'q6.secondaryWaterResistance';           // String: "yes" | "no" | "other"

  // --- Q7: Opening Protection ---
  static const wm_q7OpeningProtection = 'q7.openingProtection';                         // String: "A" | "B" | "C" | "N"
  static const wm_q7WindowCount = 'q7.windowCount';                                     // int
  static const wm_q7DoorCount = 'q7.doorCount';                                         // int
  static const wm_q7SkylightCount = 'q7.skylightCount';                                 // int
  static const wm_q7GarageDoorCount = 'q7.garageDoorCount';                             // int

  // --- Q8: Opening Protection Scope ---
  static const wm_q8OpeningProtectionScope = 'q8.openingProtectionScope';               // String: "all" | "none" | "partial"

  // --- Inspector ---
  static const wm_inspectorReinspection = 'inspector.reinspection';                     // bool
  static const wm_inspectorComments = 'inspector.comments';                             // String? (multi-line)

  // TOTAL: 16 form-specific constants
```

### 2.4 WDO Inspection (FormType.wdo)

Source: FIELD_INVENTORY Section 4.4.1.

**Excluded fields**: 8 universal (property_address -> `wdo_property_address`, inspection_date -> `wdo_inspection_date`, inspector_name -> `wdo_inspector_name`, inspector_company -> `wdo_company_name`, inspector_license_number -> `wdo_inspector_id_card`, client_name -> `wdo_requested_by`, inspector_signature -> `wdo_licensee`, comments -> `wdo_comments`), plus shared: `inspector_phone`, `signature_date`. Repeat fields (5.5, 5.6) excluded (handled by universal fields).

```dart
  // =========================================================================
  // WDO INSPECTION (wdo_)
  // Source: FIELD_INVENTORY Section 4.4.1
  // =========================================================================

  // --- Header / Company Info ---
  static const wdo_headerBusinessLicense = 'header.businessLicense';                     // String
  static const wdo_headerCompanyAddress = 'header.companyAddress';                       // String
  static const wdo_headerCompanyCityStateZip = 'header.companyCityStateZip';             // String
  static const wdo_headerStructuresInspected = 'header.structuresInspected';             // String
  static const wdo_headerReportSentTo = 'header.reportSentTo';                           // String? (conditional: different from requestor)

  // --- Section 2: Inspection Findings ---
  static const wdo_findingsNoVisibleSigns = 'findings.noVisibleSigns';                   // bool (mutually exclusive with visibleEvidence)
  static const wdo_findingsVisibleEvidence = 'findings.visibleEvidence';                 // bool
  static const wdo_findingsLiveWdo = 'findings.liveWdo';                                 // bool? (conditional: visibleEvidence)
  static const wdo_findingsLiveWdoDescription = 'findings.liveWdoDescription';           // String? (conditional: liveWdo)
  static const wdo_findingsEvidenceOfWdo = 'findings.evidenceOfWdo';                     // bool? (conditional: visibleEvidence)
  static const wdo_findingsEvidenceDescription = 'findings.evidenceDescription';         // String? (conditional: evidenceOfWdo)
  static const wdo_findingsDamageByWdo = 'findings.damageByWdo';                         // bool? (conditional: visibleEvidence)
  static const wdo_findingsDamageDescription = 'findings.damageDescription';             // String? (conditional: damageByWdo)

  // --- Section 3: Inaccessible Areas (5 areas x 3 fields = 15 fields) ---
  static const wdo_inaccessibleAtticFlag = 'inaccessible.attic.flag';                   // bool
  static const wdo_inaccessibleAtticAreas = 'inaccessible.attic.specificAreas';         // String? (conditional: flag)
  static const wdo_inaccessibleAtticReason = 'inaccessible.attic.reason';               // String? (conditional: flag)
  static const wdo_inaccessibleInteriorFlag = 'inaccessible.interior.flag';             // bool
  static const wdo_inaccessibleInteriorAreas = 'inaccessible.interior.specificAreas';   // String? (conditional: flag)
  static const wdo_inaccessibleInteriorReason = 'inaccessible.interior.reason';         // String? (conditional: flag)
  static const wdo_inaccessibleExteriorFlag = 'inaccessible.exterior.flag';             // bool
  static const wdo_inaccessibleExteriorAreas = 'inaccessible.exterior.specificAreas';   // String? (conditional: flag)
  static const wdo_inaccessibleExteriorReason = 'inaccessible.exterior.reason';         // String? (conditional: flag)
  static const wdo_inaccessibleCrawlspaceFlag = 'inaccessible.crawlspace.flag';         // bool
  static const wdo_inaccessibleCrawlspaceAreas = 'inaccessible.crawlspace.specificAreas'; // String? (conditional: flag)
  static const wdo_inaccessibleCrawlspaceReason = 'inaccessible.crawlspace.reason';     // String? (conditional: flag)
  static const wdo_inaccessibleOtherFlag = 'inaccessible.other.flag';                   // bool
  static const wdo_inaccessibleOtherAreas = 'inaccessible.other.specificAreas';         // String? (conditional: flag)
  static const wdo_inaccessibleOtherReason = 'inaccessible.other.reason';               // String? (conditional: flag)

  // --- Section 4: Treatment Information ---
  static const wdo_treatmentPreviousTreatment = 'treatment.previousTreatment';           // bool
  static const wdo_treatmentPreviousDesc = 'treatment.previousDesc';                     // String? (conditional: previousTreatment)
  static const wdo_treatmentNoticeLocation = 'treatment.noticeLocation';                 // String
  static const wdo_treatmentTreatedAtInspection = 'treatment.treatedAtInspection';       // bool
  static const wdo_treatmentOrganismTreated = 'treatment.organismTreated';               // String? (conditional: treatedAtInspection)
  static const wdo_treatmentPesticideUsed = 'treatment.pesticideUsed';                   // String? (conditional: treatedAtInspection)
  static const wdo_treatmentTermsConditions = 'treatment.termsConditions';               // String? (conditional: treatedAtInspection)
  static const wdo_treatmentMethodWholeStructure = 'treatment.methodWholeStructure';     // bool? (conditional: treatedAtInspection)
  static const wdo_treatmentMethodSpotTreatment = 'treatment.methodSpotTreatment';       // bool? (conditional: treatedAtInspection)
  static const wdo_treatmentSpotTreatmentDesc = 'treatment.spotTreatmentDesc';           // String? (conditional: spotTreatment)
  static const wdo_treatmentTreatmentNoticeLocation = 'treatment.treatmentNoticeLocation'; // String? (conditional: treatedAtInspection)

  // --- Certification (form-specific fields only) ---
  static const wdo_certificationLicenseeSigPath = 'certification.licenseeSigPath';       // String? (WDO licensee signature, separate from inspector)

  // TOTAL: 40 form-specific constants
```

### 2.5 Sinkhole Inspection (FormType.sinkholeInspection)

Source: FIELD_INVENTORY Section 4.5.1.

**Excluded fields**: 8 universal, plus shared: `policy_number`, `inspector_phone`, `foundation_cracks` (Section 1.4). Section 0 fields map entirely to universal/shared.

```dart
  // =========================================================================
  // SINKHOLE INSPECTION (sk_)
  // Source: FIELD_INVENTORY Section 4.5.1
  // =========================================================================

  // --- Section 1: Exterior (5 checklist items + 5 detail fields) ---
  static const sk_exteriorDepressionInYard = 'exterior.depressionInYard';               // String: "yes" | "no" | "na"
  static const sk_exteriorDepressionInYardDetail = 'exterior.depressionInYardDetail';   // String? (conditional: yes)
  static const sk_exteriorAdjacentDepressions = 'exterior.adjacentDepressions';         // String: "yes" | "no" | "na"
  static const sk_exteriorAdjacentDepressionsDetail = 'exterior.adjacentDepressionsDetail'; // String?
  static const sk_exteriorSoilErosion = 'exterior.soilErosion';                         // String: "yes" | "no" | "na"
  static const sk_exteriorSoilErosionDetail = 'exterior.soilErosionDetail';             // String?
  static const sk_exteriorFoundationCracks = 'exterior.foundationCracks';               // String: "yes" | "no" | "na"
  static const sk_exteriorFoundationCracksDetail = 'exterior.foundationCracksDetail';   // String?
  static const sk_exteriorWallCracks = 'exterior.wallCracks';                           // String: "yes" | "no" | "na"
  static const sk_exteriorWallCracksDetail = 'exterior.wallCracksDetail';               // String?

  // --- Section 2: Interior (8 checklist items + 8 detail fields) ---
  static const sk_interiorDoorsOutOfPlumb = 'interior.doorsOutOfPlumb';                 // String: "yes" | "no" | "na"
  static const sk_interiorDoorsOutOfPlumbDetail = 'interior.doorsOutOfPlumbDetail';     // String?
  static const sk_interiorDoorsWindowsOutOfSquare = 'interior.doorsWindowsOutOfSquare'; // String: "yes" | "no" | "na"
  static const sk_interiorDoorsWindowsOutOfSquareDetail = 'interior.doorsWindowsOutOfSquareDetail'; // String?
  static const sk_interiorCompressionCracks = 'interior.compressionCracks';             // String: "yes" | "no" | "na"
  static const sk_interiorCompressionCracksDetail = 'interior.compressionCracksDetail'; // String?
  static const sk_interiorFloorsOutOfLevel = 'interior.floorsOutOfLevel';               // String: "yes" | "no" | "na"
  static const sk_interiorFloorsOutOfLevelDetail = 'interior.floorsOutOfLevelDetail';   // String?
  static const sk_interiorCabinetsPulled = 'interior.cabinetsPulled';                   // String: "yes" | "no" | "na"
  static const sk_interiorCabinetsPulledDetail = 'interior.cabinetsPulledDetail';       // String?
  static const sk_interiorWallCracks = 'interior.wallCracks';                           // String: "yes" | "no" | "na"
  static const sk_interiorWallCracksDetail = 'interior.wallCracksDetail';               // String?
  static const sk_interiorCeilingCracks = 'interior.ceilingCracks';                     // String: "yes" | "no" | "na"
  static const sk_interiorCeilingCracksDetail = 'interior.ceilingCracksDetail';         // String?
  static const sk_interiorFlooringCracks = 'interior.flooringCracks';                   // String: "yes" | "no" | "na"
  static const sk_interiorFlooringCracksDetail = 'interior.flooringCracksDetail';       // String?

  // --- Section 3: Garage (2 checklist items + 2 detail fields) ---
  static const sk_garageWallToSlabCracks = 'garage.wallToSlabCracks';                   // String: "yes" | "no" | "na"
  static const sk_garageWallToSlabCracksDetail = 'garage.wallToSlabCracksDetail';       // String?
  static const sk_garageFloorCracksRadiate = 'garage.floorCracksRadiate';               // String: "yes" | "no" | "na"
  static const sk_garageFloorCracksRadiateDetail = 'garage.floorCracksRadiateDetail';   // String?

  // --- Section 4: Appurtenant Structures (4 checklist items + 4 detail fields) ---
  static const sk_appurtenantCracksNoted = 'appurtenant.cracksNoted';                   // String: "yes" | "no" | "na"
  static const sk_appurtenantCracksNotedDetail = 'appurtenant.cracksNotedDetail';       // String?
  static const sk_appurtenantUpliftNoted = 'appurtenant.upliftNoted';                   // String: "yes" | "no" | "na"
  static const sk_appurtenantUpliftNotedDetail = 'appurtenant.upliftNotedDetail';       // String?
  static const sk_appurtenantPoolCracks = 'appurtenant.poolCracks';                     // String: "yes" | "no" | "na"
  static const sk_appurtenantPoolCracksDetail = 'appurtenant.poolCracksDetail';         // String?
  static const sk_appurtenantPoolDeckCracks = 'appurtenant.poolDeckCracks';             // String: "yes" | "no" | "na"
  static const sk_appurtenantPoolDeckCracksDetail = 'appurtenant.poolDeckCracksDetail'; // String?

  // --- Section 5: Additional Information ---
  static const sk_additionalGeneralCondition = 'additional.generalCondition';           // String (multi-line)
  static const sk_additionalAdjacentBuilding = 'additional.adjacentBuilding';           // String? (conditional: townhouse/row house)
  static const sk_additionalNearestSinkhole = 'additional.nearestSinkhole';             // String
  static const sk_additionalOtherFindings = 'additional.otherFindings';                 // String (multi-line)
  static const sk_additionalUnableToSchedule = 'additional.unableToSchedule';           // String? (conditional: inspection not completed)

  // --- Section 6: Scheduling Attempts (4 attempts x 4 fields = 16 fields) ---
  static const sk_schedulingAttempt0Date = 'scheduling.attempts.0.date';                 // String? (ISO date)
  static const sk_schedulingAttempt0Time = 'scheduling.attempts.0.time';                 // String? (ISO time)
  static const sk_schedulingAttempt0Number = 'scheduling.attempts.0.number';             // String?
  static const sk_schedulingAttempt0Result = 'scheduling.attempts.0.result';             // String?
  static const sk_schedulingAttempt1Date = 'scheduling.attempts.1.date';                 // String?
  static const sk_schedulingAttempt1Time = 'scheduling.attempts.1.time';                 // String?
  static const sk_schedulingAttempt1Number = 'scheduling.attempts.1.number';             // String?
  static const sk_schedulingAttempt1Result = 'scheduling.attempts.1.result';             // String?
  static const sk_schedulingAttempt2Date = 'scheduling.attempts.2.date';                 // String?
  static const sk_schedulingAttempt2Time = 'scheduling.attempts.2.time';                 // String?
  static const sk_schedulingAttempt2Number = 'scheduling.attempts.2.number';             // String?
  static const sk_schedulingAttempt2Result = 'scheduling.attempts.2.result';             // String?
  static const sk_schedulingAttempt3Date = 'scheduling.attempts.3.date';                 // String?
  static const sk_schedulingAttempt3Time = 'scheduling.attempts.3.time';                 // String?
  static const sk_schedulingAttempt3Number = 'scheduling.attempts.3.number';             // String?
  static const sk_schedulingAttempt3Result = 'scheduling.attempts.3.result';             // String?

  // TOTAL: 59 form-specific constants
```

### 2.6 Mold Assessment (FormType.moldAssessment)

Source: FIELD_INVENTORY Section 4.6.1.

**Excluded fields**: 8 universal (assessor_name -> inspector_name, mrsa_license -> inspector_license_number, company_name -> inspector_company, client_name, property_address, assessment_date -> inspection_date, signature implied, comments implied), plus shared: `year_built` (building_age mapped to shared.yearBuilt with conversion).

```dart
  // =========================================================================
  // MOLD ASSESSMENT (ma_)
  // Source: FIELD_INVENTORY Section 4.6.1
  // =========================================================================

  // --- Header ---
  static const ma_headerAssessmentEndDate = 'header.assessmentEndDate';                 // String? (ISO date; multi-day assessments)
  static const ma_headerWeatherConditions = 'header.weatherConditions';                 // String
  static const ma_headerBuildingType = 'header.buildingType';                           // String
  static const ma_headerHvacStatus = 'header.hvacStatus';                               // String (enum: "operating" | "not_operating" | "unknown")
  static const ma_headerLicenseType = 'header.licenseType';                             // String (MRSA license type)

  // --- Scope ---
  static const ma_scopeAreasAssessed = 'scope.areasAssessed';                           // List<String>
  static const ma_scopeAreasNotAssessed = 'scope.areasNotAssessed';                     // List<String>

  // --- Findings ---
  static const ma_findingsMoistureSources = 'findings.moistureSources';                 // List<String>? (conditional: moisture found)
  static const ma_findingsMoistureReadings = 'findings.moistureReadings';               // List<String>
  static const ma_findingsVisibleLocations = 'findings.visibleLocations';               // List<String>? (conditional: mold found)

  // --- Sampling ---
  static const ma_samplingSampleLocations = 'sampling.sampleLocations';                 // List<String>? (conditional: samples taken)
  static const ma_samplingLabName = 'sampling.labName';                                 // String? (conditional: samples taken)
  static const ma_samplingLabReportNumber = 'sampling.labReportNumber';                 // String? (conditional: samples taken)

  // --- Remediation ---
  static const ma_remediationRecommended = 'remediation.recommended';                   // bool
  static const ma_remediationScope = 'remediation.scope';                               // String? (conditional: recommended)
  static const ma_remediationReoccupancyCriteria = 'remediation.reoccupancyCriteria';   // String? (conditional: recommended)

  // TOTAL: 16 form-specific constants
```

### 2.7 General Home Inspection (FormType.generalInspection)

Source: FIELD_INVENTORY Section 4.7.

**Excluded fields**: 8 universal, plus shared: `year_built`, `roof_covering_material`, `roof_age`, `roof_condition`, `electrical_panel_type`, `electrical_panel_amps`, `plumbing_pipe_material`, `water_heater_type`, `hvac_type`, `foundation_cracks`, `inspector_phone` (11 of 13 shared).

**Design note**: General Inspection has the most fields because each of 12 sections has both "general info" fields and a checkpoint table. The checkpoint tables use the `List<Map<String, dynamic>>` pattern described in Section 1.4.3.

```dart
  // =========================================================================
  // GENERAL HOME INSPECTION (gi_)
  // Source: FIELD_INVENTORY Section 4.7
  // =========================================================================

  // --- Header ---
  static const gi_headerPropertyDescription = 'header.propertyDescription';             // String?
  static const gi_headerInspectionTime = 'header.inspectionTime';                       // String (time)
  static const gi_headerReportNumber = 'header.reportNumber';                           // String
  static const gi_headerInspectionFee = 'header.inspectionFee';                         // double (currency)
  static const gi_headerPaymentMethod = 'header.paymentMethod';                         // String (enum)

  // --- Roof/Deck Section ---
  static const gi_roofDeckStyle = 'roofDeck.style';                                     // String (enum)
  static const gi_roofDeckCovering = 'roofDeck.covering';                               // String (enum)
  static const gi_roofDeckFlashing = 'roofDeck.flashing';                               // String (enum)
  static const gi_roofDeckGuttersDownspouts = 'roofDeck.guttersDownspouts';             // String (enum)
  static const gi_roofDeckObservationMethod = 'roofDeck.observationMethod';             // String (enum)
  static const gi_roofDeckCheckpoints = 'roofDeck.checkpoints';                         // List<Map<String, dynamic>>
  static const gi_roofDeckNotes = 'roofDeck.notes';                                     // String? (narrative)

  // --- Electrical Section ---
  static const gi_electricalServiceLine = 'electrical.serviceLine';                     // String (enum)
  static const gi_electricalConductors = 'electrical.conductors';                       // int
  static const gi_electricalPanelLocation = 'electrical.panelLocation';                 // String
  static const gi_electricalPanelCapacity = 'electrical.panelCapacity';                 // String (enum: "70A"-"400A")
  static const gi_electricalConductorType = 'electrical.conductorType';                 // String (enum)
  static const gi_electricalBranchConductor = 'electrical.branchConductor';             // String (enum)
  static const gi_electricalSubPanelCircuits = 'electrical.subPanelCircuits';           // int?
  static const gi_electricalGfci = 'electrical.gfci';                                   // String (enum)
  static const gi_electricalSystemGround = 'electrical.systemGround';                   // String (enum)
  static const gi_electricalCheckpoints = 'electrical.checkpoints';                     // List<Map<String, dynamic>>
  static const gi_electricalNotes = 'electrical.notes';                                 // String? (narrative)

  // --- Plumbing Section ---
  static const gi_plumbingMainLineMaterial = 'plumbing.mainLineMaterial';               // String (enum)
  static const gi_plumbingDiameter = 'plumbing.diameter';                               // String (enum)
  static const gi_plumbingValveLocation = 'plumbing.valveLocation';                     // String
  static const gi_plumbingHoseBibLocations = 'plumbing.hoseBibLocations';               // List<String>
  static const gi_plumbingWasteLineMaterial = 'plumbing.wasteLineMaterial';             // String (enum)
  static const gi_plumbingFuelSystem = 'plumbing.fuelSystem';                           // String (enum)
  static const gi_plumbingPressureTestPsi = 'plumbing.pressureTestPsi';                 // double?
  static const gi_plumbingPressureTestTime = 'plumbing.pressureTestTime';               // String? (duration)
  static const gi_plumbingCheckpoints = 'plumbing.checkpoints';                         // List<Map<String, dynamic>>
  static const gi_plumbingNotes = 'plumbing.notes';                                     // String? (narrative)

  // --- Water Heater Section ---
  static const gi_waterHeaterManufacturer = 'waterHeater.manufacturer';                 // String
  static const gi_waterHeaterCapacity = 'waterHeater.capacity';                         // int (gallons)
  static const gi_waterHeaterApproxAge = 'waterHeater.approxAge';                       // int (years)
  static const gi_waterHeaterPlumbingType = 'waterHeater.plumbingType';                 // String (enum)
  static const gi_waterHeaterEnclosureType = 'waterHeater.enclosureType';               // String (enum)
  static const gi_waterHeaterFuelSystem = 'waterHeater.fuelSystem';                     // String (enum)
  static const gi_waterHeaterBase = 'waterHeater.base';                                 // String (enum)
  static const gi_waterHeaterCheckpoints = 'waterHeater.checkpoints';                   // List<Map<String, dynamic>>
  static const gi_waterHeaterNotes = 'waterHeater.notes';                               // String? (narrative)

  // --- Heating Section ---
  static const gi_heatingLocation1 = 'heating.location1';                               // String?
  static const gi_heatingLocation1Manufacturer = 'heating.location1Manufacturer';       // String?
  static const gi_heatingLocation2 = 'heating.location2';                               // String?
  static const gi_heatingLocation2Manufacturer = 'heating.location2Manufacturer';       // String?
  static const gi_heatingLocation3 = 'heating.location3';                               // String?
  static const gi_heatingLocation3Manufacturer = 'heating.location3Manufacturer';       // String?
  static const gi_heatingType = 'heating.type';                                         // String (enum)
  static const gi_heatingFuelType = 'heating.fuelType';                                 // String (enum)
  static const gi_heatingCheckpoints = 'heating.checkpoints';                           // List<Map<String, dynamic>>
  static const gi_heatingNotes = 'heating.notes';                                       // String? (narrative)

  // --- Air Conditioning Section ---
  static const gi_acLocation1 = 'airConditioning.location1';                             // String?
  static const gi_acLocation1Manufacturer = 'airConditioning.location1Manufacturer';     // String?
  static const gi_acLocation2 = 'airConditioning.location2';                             // String?
  static const gi_acLocation2Manufacturer = 'airConditioning.location2Manufacturer';     // String?
  static const gi_acLocation3 = 'airConditioning.location3';                             // String?
  static const gi_acLocation3Manufacturer = 'airConditioning.location3Manufacturer';     // String?
  static const gi_acType = 'airConditioning.type';                                       // String (enum)
  static const gi_acPower = 'airConditioning.power';                                     // String (enum)
  static const gi_acDisconnect = 'airConditioning.disconnect';                           // bool
  static const gi_acDefects = 'airConditioning.defects';                                 // bool
  static const gi_acCheckpoints = 'airConditioning.checkpoints';                         // List<Map<String, dynamic>>
  static const gi_acNotes = 'airConditioning.notes';                                     // String? (narrative)

  // --- Structure/Foundation Section ---
  static const gi_structureCheckpoints = 'structure.checkpoints';                       // List<Map<String, dynamic>>
  static const gi_structureNotes = 'structure.notes';                                   // String? (narrative)

  // --- Exterior Section ---
  static const gi_exteriorCheckpoints = 'exterior.checkpoints';                         // List<Map<String, dynamic>>
  static const gi_exteriorNotes = 'exterior.notes';                                     // String? (narrative)

  // --- Interior Section ---
  static const gi_interiorCheckpoints = 'interior.checkpoints';                         // List<Map<String, dynamic>>
  static const gi_interiorNotes = 'interior.notes';                                     // String? (narrative)

  // --- Insulation/Ventilation Section ---
  static const gi_insulationCheckpoints = 'insulation.checkpoints';                     // List<Map<String, dynamic>>
  static const gi_insulationNotes = 'insulation.notes';                                 // String? (narrative)

  // --- Built-in Appliances Section ---
  static const gi_appliancesCheckpoints = 'appliances.checkpoints';                     // List<Map<String, dynamic>>
  static const gi_appliancesNotes = 'appliances.notes';                                 // String? (narrative)

  // --- Life Safety Section ---
  static const gi_lifeSafetyCheckpoints = 'lifeSafety.checkpoints';                     // List<Map<String, dynamic>>
  static const gi_lifeSafetyNotes = 'lifeSafety.notes';                                 // String? (narrative)

  // TOTAL: 76 form-specific constants
}
```

### 2.8 Field Count Summary

| Form Type | Form-Specific Constants | FIELD_INVENTORY Total | Universal | Shared | Photo/Media | Delta | Notes |
|-----------|------------------------|----------------------|-----------|--------|-------------|-------|-------|
| 4-Point | 111 | ~126 (27 mapped + ~99 gap) | 8 | 11 | 27 (photo pairs) | 126 - 8 - 11 + 27 photos excluded = ~107 expected. Actual: 111. | +4 from compound checkbox+text fields (aluminum details, hazard other desc) expanded to 2 constants each, plus inspector.title and inspector.licenseType |
| Roof Condition | 15 | ~26 (8 mapped + ~20 gap) | 8 | 6 | 6 (photo pairs) | 26 - 8 - 6 + 6 photos excluded = ~12 expected. Actual: 15. | +3 from expanded checkbox+text pairs (priorRepairs, windDamage, hailDamage each count as 2) |
| Wind Mitigation | 16 | ~45 (22 mapped + ~23 gap) | 8 | 4 | 22 (photo/doc) | 45 - 8 - 4 + 22 photos excluded = ~11 expected. Actual: 16. | Q7 expanded to 4 numeric counts + 1 selection; Q1/Q2 each have companion text |
| WDO | 40 | 51 (49 unique + 2 repeat) | 8 | 2 | 0 | 51 - 8 - 2 - 2 repeats = ~39. Actual: 40. | +1: compound checkbox+text for spot treatment expanded to 2 constants |
| Sinkhole | 59 | 67 (59 + 8 inferred) | 8 | 3 | 0 | 67 - 8 - 3 = ~56. Actual: 59. | The ternary `sk_exteriorFoundationCracks` (yes/no/na) is kept in formData alongside shared `foundationCracks` (bool, derived). +3 from each Yes->Detail pair counted as 2 constants while FIELD_INVENTORY counts them as 1 "conditional" entry. |
| Mold | 16 | 21 | 8 | 1 | 0 | 21 - 8 - 1 = ~12. Actual: 16. | +4 from expansion: assessmentEndDate, hvacStatus, licenseType (form-specific header fields), and scope split into 2 list keys |
| General | 76 | ~150+ | 8 | 11 | 0 | 150 - 8 - 11 = ~131. Actual: 76. | Checkpoint tables stored as single key each (12 sections x 1 checkpoint key + 1 notes key = 24); general info fields per section account for remainder. Rule-derived sections have only checkpoint + notes (no general info fields enumerated). |

**Grand total: 333 form-specific constants** defined in FormDataKeys.

**Note on General Inspection count**: The ~150+ field count in FIELD_INVENTORY includes each individual checkpoint item. In our design, checkpoint items are stored as `List<Map>` entries within a single key. For example, Electrical has 12 checkpoint items but uses 1 `checkpoints` key. This compression is intentional -- it makes the schema extensible (new checkpoint items can be added without new constants) while keeping the constant count manageable.

---

## 3. Example Data Payloads

All examples show the inner `Map<String, dynamic>` stored at `formData[FormType.xxx]`. The FormType key is not part of the JSON content.

### 3.1 Four-Point Inspection

```json
{
  "electrical.mainPanelType": "circuit_breaker",
  "electrical.mainPanelAmps": 200,
  "electrical.mainAmpsSufficient": true,
  "electrical.mainPanelAge": "15 years",
  "electrical.mainPanelYearUpdated": "2011",
  "electrical.mainPanelBrand": "Square D",
  "electrical.secondPanelType": "circuit_breaker",
  "electrical.secondPanelAmps": 100,
  "electrical.secondAmpsSufficient": true,
  "electrical.secondPanelAge": "15 years",
  "electrical.secondPanelYearUpdated": "2011",
  "electrical.secondPanelBrand": "Square D",
  "electrical.clothWiring": false,
  "electrical.knobAndTube": false,
  "electrical.aluminumBranchWiring": false,
  "electrical.wiringType": "copper",
  "electrical.hazardBlowingFuses": false,
  "electrical.hazardTrippingBreakers": false,
  "electrical.hazardEmptySockets": false,
  "electrical.hazardLooseWiring": false,
  "electrical.hazardImproperGrounding": false,
  "electrical.hazardCorrosion": false,
  "electrical.hazardOverFusing": false,
  "electrical.hazardDoubleTaps": true,
  "electrical.hazardExposedWiring": false,
  "electrical.hazardUnsafeWiring": false,
  "electrical.hazardImproperBreakerSz": false,
  "electrical.hazardScorching": false,
  "electrical.hazardOther": false,
  "electrical.generalCondition": "satisfactory",

  "hvac.centralAc": true,
  "hvac.centralHeat": true,
  "hvac.primaryHeatSource": "Electric heat pump",
  "hvac.goodWorkingOrder": true,
  "hvac.lastServiceDate": "2025-11-15",
  "hvac.hazardWoodStoveFireplace": false,
  "hvac.hazardSpaceHeaterPrimary": false,
  "hvac.hazardAirHandlerBlockage": false,
  "hvac.systemAge": "8 years",
  "hvac.yearUpdated": "2018",

  "plumbing.tprValve": true,
  "plumbing.activeLeak": false,
  "plumbing.priorLeak": false,
  "plumbing.waterHeaterLocation": "Garage",
  "plumbing.fixtureDishwasher": "s",
  "plumbing.fixtureRefrigerator": "s",
  "plumbing.fixtureWashingMachine": "s",
  "plumbing.fixtureWaterHeater": "s",
  "plumbing.fixtureShowersTubs": "s",
  "plumbing.fixtureToilets": "s",
  "plumbing.fixtureSinks": "s",
  "plumbing.fixtureSumpPump": "na",
  "plumbing.fixtureMainShutoff": "s",
  "plumbing.fixtureAllOther": "s",
  "plumbing.pipingAge": "25 years",
  "plumbing.completelyRepiped": false,
  "plumbing.partiallyRepiped": false,
  "plumbing.pipeCopper": true,
  "plumbing.pipePvcCpvc": true,
  "plumbing.pipeGalvanized": false,
  "plumbing.pipePex": false,
  "plumbing.pipePolybutylene": false,
  "plumbing.pipeOther": false,

  "roof.primaryRemainingLife": "10",
  "roof.primaryLastPermitDate": "2016-05-20",
  "roof.primaryLastUpdate": "2016-05-20",
  "roof.primaryFullReplacement": true,
  "roof.primaryPartialReplacement": false,
  "roof.primaryOverallCondition": "satisfactory",
  "roof.primaryDamageCracking": false,
  "roof.primaryDamageCuppingCurling": false,
  "roof.primaryDamageGranuleLoss": false,
  "roof.primaryDamageExposedAsphalt": false,
  "roof.primaryDamageExposedFelt": false,
  "roof.primaryDamageMissingTabsTiles": false,
  "roof.primaryDamageSoftSpots": false,
  "roof.primaryDamageHail": false,
  "roof.primaryLeaks": false,
  "roof.primaryAtticUndersideLeaks": false,
  "roof.primaryInteriorCeilingLeaks": false,

  "inspector.title": "Licensed Home Inspector",
  "inspector.licenseType": "Home Inspector"
}
```

### 3.2 Roof Condition Form

```json
{
  "roof.remainingLife": "8",
  "roof.conditionRating": "fair",
  "roof.priorRepairs": true,
  "roof.priorRepairsDesc": "Patched area on north slope, approx 4x6 ft",
  "roof.leaks": false,
  "roof.windDamage": false,
  "roof.hailDamage": true,
  "roof.hailDamageDesc": "Minor granule loss from 2024 hail event, southwest exposure",
  "roof.numberOfLayers": "1",
  "roof.flashingCondition": "good",
  "roof.soffitFasciaCondition": "fair",
  "roof.guttersDownspouts": "good",
  "roof.comments": "Overall roof in fair condition. Recommend monitoring hail-damaged area for further granule loss."
}
```

### 3.3 Wind Mitigation

```json
{
  "q1.buildingCode": "2002_or_later_fbc",
  "q1.year": "2005",
  "q2.roofCovering": "fbc_equivalent",
  "q2.permitDate": "2016-05-20",
  "q3.roofDeckAttachment": "B",
  "q4.roofWallAttachment": "clips",
  "q5.roofGeometry": "hip",
  "q6.secondaryWaterResistance": "no",
  "q7.openingProtection": "C",
  "q7.windowCount": 14,
  "q7.doorCount": 3,
  "q7.skylightCount": 0,
  "q7.garageDoorCount": 1,
  "q8.openingProtectionScope": "partial",
  "inspector.reinspection": false,
  "inspector.comments": "Hip roof with clips. Opening protection on most but not all openings."
}
```

### 3.4 WDO Inspection

```json
{
  "header.businessLicense": "JE-0012345",
  "header.companyAddress": "456 Pest Control Ave",
  "header.companyCityStateZip": "Tampa, FL 33601",
  "header.structuresInspected": "Main house, detached garage",
  "header.reportSentTo": "ABC Title Company, 789 Legal Blvd, Tampa FL 33602",

  "findings.noVisibleSigns": false,
  "findings.visibleEvidence": true,
  "findings.liveWdo": false,
  "findings.evidenceOfWdo": true,
  "findings.evidenceDescription": "Subterranean termite mud tubes found on north foundation wall, extending approximately 18 inches from grade to sill plate. Tubes are dry and appear inactive.",
  "findings.damageByWdo": true,
  "findings.damageDescription": "Wood damage observed in window frame on north wall, softwood damage consistent with drywood termite activity. Approximately 6 inches of baseboard affected.",

  "inaccessible.attic.flag": true,
  "inaccessible.attic.specificAreas": "Southeast corner above master bedroom",
  "inaccessible.attic.reason": "Insulation and HVAC ductwork blocking access",
  "inaccessible.interior.flag": false,
  "inaccessible.exterior.flag": false,
  "inaccessible.crawlspace.flag": false,
  "inaccessible.other.flag": false,

  "treatment.previousTreatment": true,
  "treatment.previousDesc": "Evidence of previous whole-structure fumigation (drill holes in stucco, capped).",
  "treatment.noticeLocation": "Front door frame, left side",
  "treatment.treatedAtInspection": false,

  "certification.licenseeSigPath": "/data/user/0/com.example.inspectobot/cache/wdo_sig_abc123.png"
}
```

### 3.5 Sinkhole Inspection

```json
{
  "exterior.depressionInYard": "yes",
  "exterior.depressionInYardDetail": "Shallow depression approximately 3 ft diameter, 4 inches deep, located 15 ft from southeast corner of structure. No water pooling observed.",
  "exterior.adjacentDepressions": "no",
  "exterior.soilErosion": "no",
  "exterior.foundationCracks": "yes",
  "exterior.foundationCracksDetail": "Hairline crack on north foundation wall, 0.5mm width x 24 inches length, horizontal orientation. First noticed by owner approximately 2 years ago, no observed change.",
  "exterior.wallCracks": "no",

  "interior.doorsOutOfPlumb": "no",
  "interior.doorsWindowsOutOfSquare": "no",
  "interior.compressionCracks": "no",
  "interior.floorsOutOfLevel": "no",
  "interior.cabinetsPulled": "no",
  "interior.wallCracks": "yes",
  "interior.wallCracksDetail": "Diagonal crack in living room, NE corner, 1mm width x 36 inches. Appears to follow drywall seam. Owner reports crack appeared 6 months ago.",
  "interior.ceilingCracks": "no",
  "interior.flooringCracks": "no",

  "garage.wallToSlabCracks": "no",
  "garage.floorCracksRadiate": "no",

  "appurtenant.cracksNoted": "no",
  "appurtenant.upliftNoted": "na",
  "appurtenant.poolCracks": "na",
  "appurtenant.poolDeckCracks": "na",

  "additional.generalCondition": "Property is a 2001 CBS construction single-family home in generally good condition. Minor cosmetic settling cracks observed. Depression in yard warrants monitoring.",
  "additional.nearestSinkhole": "Nearest reported sinkhole approximately 1.2 miles NW, per Florida DEP sinkhole database.",
  "additional.otherFindings": "No unusual well activity in area. Public water/sewer.",

  "scheduling.attempts.0.date": "2026-02-15",
  "scheduling.attempts.0.time": "09:00",
  "scheduling.attempts.0.number": "813-555-0199",
  "scheduling.attempts.0.result": "Scheduled inspection for 2026-02-25"
}
```

### 3.6 Mold Assessment

```json
{
  "header.assessmentEndDate": "2026-03-08",
  "header.weatherConditions": "Clear, 78F, 65% RH",
  "header.buildingType": "Single-family residential, 2-story CBS",
  "header.hvacStatus": "operating",
  "header.licenseType": "MRSA",

  "scope.areasAssessed": [
    "Master bathroom",
    "Master bedroom closet",
    "Hallway adjacent to master bath",
    "HVAC air handler closet",
    "Attic space above master bath"
  ],
  "scope.areasNotAssessed": [
    "Behind master bath shower wall (destructive testing not authorized)",
    "Second floor bedrooms (no visible indicators)"
  ],

  "findings.moistureSources": [
    "Slow leak at master bath supply line connection",
    "Condensation on HVAC supply duct in attic"
  ],
  "findings.moistureReadings": [
    "Master bath floor: 28% (elevated)",
    "Master closet wall: 22% (elevated)",
    "Hallway wall: 14% (normal)",
    "HVAC closet wall: 16% (normal)"
  ],
  "findings.visibleLocations": [
    "Master bath ceiling, NE corner, approximately 2 sq ft, dark grey/black",
    "Master closet baseboard, south wall, approximately 1 linear ft"
  ],

  "sampling.sampleLocations": [
    "Air sample: Master bathroom (affected area)",
    "Air sample: Living room (control/unaffected area)",
    "Surface sample: Master bath ceiling mold growth"
  ],
  "sampling.labName": "ProLab Diagnostics",
  "sampling.labReportNumber": "PLD-2026-04521",

  "remediation.recommended": true,
  "remediation.scope": "Remove and replace affected drywall in master bath ceiling (approx 4x4 ft section). Remove and replace affected baseboard in master closet. Repair supply line leak. HVAC duct insulation inspection and repair. Containment required during remediation.",
  "remediation.reoccupancyCriteria": "Post-remediation clearance air sampling required. Clearance criteria: spore counts in affected area must not exceed control area counts by more than 100 spores/m3, and no Stachybotrys or Chaetomium species detected."
}
```

### 3.7 General Home Inspection

```json
{
  "header.propertyDescription": "2-story CBS single-family residence, approximately 2,400 sq ft under air",
  "header.inspectionTime": "09:00",
  "header.reportNumber": "GHI-2026-0142",
  "header.inspectionFee": 425.00,
  "header.paymentMethod": "credit_card",

  "roofDeck.style": "hip",
  "roofDeck.covering": "asphalt_shingle",
  "roofDeck.flashing": "aluminum",
  "roofDeck.guttersDownspouts": "aluminum_seamless",
  "roofDeck.observationMethod": "ground_level",
  "roofDeck.checkpoints": [
    { "item": "Condition", "rating": "fair", "comment": "Minor granule loss on south slope" },
    { "item": "Flashing", "rating": "good", "comment": null },
    { "item": "Truss/rafter", "rating": "good", "comment": null },
    { "item": "Estimated age", "rating": "fair", "comment": "Approximately 12 years" },
    { "item": "Downspouts", "rating": "good", "comment": null },
    { "item": "Chimney", "rating": "na", "comment": "No chimney present" },
    { "item": "Flat/Low Slope", "rating": "na", "comment": "Not applicable" },
    { "item": "Vents", "rating": "good", "comment": null },
    { "item": "Skylights", "rating": "na", "comment": "No skylights present" }
  ],
  "roofDeck.notes": "Recommend monitoring south slope for continued granule loss. Consider re-roofing within 5-8 years.",

  "electrical.serviceLine": "underground",
  "electrical.conductors": 3,
  "electrical.panelLocation": "Garage, west wall",
  "electrical.panelCapacity": "200A",
  "electrical.conductorType": "copper",
  "electrical.branchConductor": "copper",
  "electrical.subPanelCircuits": null,
  "electrical.gfci": "present_kitchen_bath_exterior_garage",
  "electrical.systemGround": "ground_rod",
  "electrical.checkpoints": [
    { "item": "Service Line", "rating": "good", "comment": null },
    { "item": "Main Panel", "rating": "good", "comment": null },
    { "item": "Breakers", "rating": "good", "comment": null },
    { "item": "Fuses", "rating": "na", "comment": "Circuit breaker system" },
    { "item": "Conductors", "rating": "good", "comment": null },
    { "item": "Sub-Panel", "rating": "na", "comment": "No sub-panel" },
    { "item": "Wiring", "rating": "good", "comment": null },
    { "item": "GFCI", "rating": "good", "comment": null },
    { "item": "Grounding", "rating": "good", "comment": null },
    { "item": "Lights", "rating": "good", "comment": null },
    { "item": "Outlets", "rating": "fair", "comment": "Missing cover plate in garage" },
    { "item": "Switches", "rating": "good", "comment": null }
  ],
  "electrical.notes": "Recommend installing cover plate on exposed junction box in garage.",

  "plumbing.mainLineMaterial": "pvc",
  "plumbing.diameter": "3/4_inch",
  "plumbing.valveLocation": "Front yard, near sidewalk",
  "plumbing.hoseBibLocations": ["Front", "Rear", "Garage"],
  "plumbing.wasteLineMaterial": "pvc",
  "plumbing.fuelSystem": "none",
  "plumbing.pressureTestPsi": 55.0,
  "plumbing.pressureTestTime": "15 min",
  "plumbing.checkpoints": [
    { "item": "Main Line", "rating": "good", "comment": null },
    { "item": "Water Line", "rating": "good", "comment": null },
    { "item": "Shut-Off", "rating": "good", "comment": null },
    { "item": "Pressure", "rating": "good", "comment": "55 PSI, stable" },
    { "item": "Regulator", "rating": "na", "comment": "Not present" },
    { "item": "Relief Valve", "rating": "good", "comment": null },
    { "item": "Waste Disposal", "rating": "good", "comment": null },
    { "item": "Waste Line", "rating": "good", "comment": null },
    { "item": "Sump Pump", "rating": "na", "comment": "Not present" },
    { "item": "Softener", "rating": "na", "comment": "Not present" },
    { "item": "Anti-Siphon", "rating": "good", "comment": null },
    { "item": "Hose Bib", "rating": "good", "comment": null },
    { "item": "Fuel Lines", "rating": "na", "comment": "No gas service" }
  ],
  "plumbing.notes": null,

  "waterHeater.manufacturer": "Rheem",
  "waterHeater.capacity": 50,
  "waterHeater.approxAge": 6,
  "waterHeater.plumbingType": "pex",
  "waterHeater.enclosureType": "garage",
  "waterHeater.fuelSystem": "electric",
  "waterHeater.base": "concrete_pad",
  "waterHeater.checkpoints": [
    { "item": "Heater", "rating": "good", "comment": null },
    { "item": "TPR Valve", "rating": "good", "comment": null },
    { "item": "Shut-Off", "rating": "good", "comment": null },
    { "item": "Seismic", "rating": "na", "comment": "Not required in Florida" },
    { "item": "Blanket", "rating": "na", "comment": "Not applicable to this model" },
    { "item": "Vent Flue", "rating": "na", "comment": "Electric - no flue" },
    { "item": "Enclosure", "rating": "good", "comment": null },
    { "item": "Plumbing", "rating": "good", "comment": null },
    { "item": "Combustion Air", "rating": "na", "comment": "Electric unit" },
    { "item": "Venting", "rating": "na", "comment": "Electric unit" },
    { "item": "Base", "rating": "good", "comment": null },
    { "item": "Overflow", "rating": "good", "comment": "Drain pan with line to exterior" }
  ],
  "waterHeater.notes": null,

  "heating.location1": "Air handler closet, 2nd floor hallway",
  "heating.location1Manufacturer": "Trane",
  "heating.type": "heat_pump",
  "heating.fuelType": "electric",
  "heating.checkpoints": [
    { "item": "Burner", "rating": "na", "comment": "Heat pump - no burner" },
    { "item": "Venting", "rating": "na", "comment": "Heat pump - no venting" },
    { "item": "Combustion Air", "rating": "na", "comment": "Heat pump" },
    { "item": "Duct Work", "rating": "good", "comment": null },
    { "item": "Filters", "rating": "fair", "comment": "Filter dirty, recommend replacement" },
    { "item": "Thermostat", "rating": "good", "comment": "Smart thermostat, functioning" },
    { "item": "Distribution", "rating": "good", "comment": null },
    { "item": "Gas Valves", "rating": "na", "comment": "Electric system" }
  ],
  "heating.notes": "Replace air filter. System functioning normally.",

  "airConditioning.location1": "Exterior pad, north side",
  "airConditioning.location1Manufacturer": "Trane",
  "airConditioning.type": "split_system",
  "airConditioning.power": "240V",
  "airConditioning.disconnect": true,
  "airConditioning.defects": false,
  "airConditioning.checkpoints": [
    { "item": "Compressor", "rating": "good", "comment": null },
    { "item": "Filter", "rating": "fair", "comment": "See heating section" },
    { "item": "Blower", "rating": "good", "comment": null },
    { "item": "Duct Work", "rating": "good", "comment": null },
    { "item": "Electrical", "rating": "good", "comment": null },
    { "item": "Base", "rating": "good", "comment": "Level concrete pad" }
  ],
  "airConditioning.notes": null,

  "structure.checkpoints": [
    { "item": "Foundation", "rating": "good", "comment": null },
    { "item": "Basement/Crawlspace", "rating": "na", "comment": "Slab on grade" },
    { "item": "Framing", "rating": "good", "comment": null },
    { "item": "Floors", "rating": "good", "comment": null },
    { "item": "Walls", "rating": "good", "comment": null }
  ],
  "structure.notes": null,

  "exterior.checkpoints": [
    { "item": "Siding", "rating": "good", "comment": "Stucco, minor cosmetic hairline cracks" },
    { "item": "Windows", "rating": "good", "comment": "Impact-rated windows" },
    { "item": "Doors", "rating": "good", "comment": null },
    { "item": "Trim", "rating": "good", "comment": null },
    { "item": "Eaves", "rating": "good", "comment": null },
    { "item": "Decks", "rating": "na", "comment": "No deck" },
    { "item": "Fencing", "rating": "fair", "comment": "Minor wood rot on rear fence, 2 pickets" },
    { "item": "Paving", "rating": "good", "comment": null }
  ],
  "exterior.notes": "Recommend replacing rotted fence pickets.",

  "interior.checkpoints": [
    { "item": "Walls", "rating": "good", "comment": null },
    { "item": "Ceilings", "rating": "good", "comment": null },
    { "item": "Floors", "rating": "good", "comment": null },
    { "item": "Stairs", "rating": "good", "comment": null },
    { "item": "Doors", "rating": "good", "comment": null },
    { "item": "Windows", "rating": "good", "comment": null },
    { "item": "Cabinets", "rating": "good", "comment": null }
  ],
  "interior.notes": null,

  "insulation.checkpoints": [
    { "item": "Attic Insulation", "rating": "good", "comment": "R-30 blown-in fiberglass" },
    { "item": "Vapor Barriers", "rating": "na", "comment": "Not typical in Florida" },
    { "item": "Kitchen/Bath Venting", "rating": "good", "comment": null }
  ],
  "insulation.notes": null,

  "appliances.checkpoints": [
    { "item": "Dishwasher", "rating": "good", "comment": null },
    { "item": "Range", "rating": "good", "comment": null },
    { "item": "Disposal", "rating": "good", "comment": null },
    { "item": "Oven", "rating": "good", "comment": null },
    { "item": "Microwave", "rating": "good", "comment": null },
    { "item": "Ventilation", "rating": "good", "comment": "Microwave vent to exterior" }
  ],
  "appliances.notes": null,

  "lifeSafety.checkpoints": [
    { "item": "Smoke Detectors", "rating": "good", "comment": "Present in all bedrooms and hallways" },
    { "item": "Fire Extinguishers", "rating": "na", "comment": "None observed - not required" },
    { "item": "Safety Glass", "rating": "good", "comment": "Tempered glass in wet areas and doors" }
  ],
  "lifeSafety.notes": null
}
```

---

## 4. Design Decisions Log

| # | Decision | Rationale |
|---|----------|-----------|
| 1 | Key values do NOT include form prefix | 02-02 changed storage from flat `Map<String, dynamic>` to `Map<FormType, Map<String, dynamic>>`. The FormType enum key provides form identity; prefixing keys would be redundant. The `branchContext` getter adds the prefix when constructing the flat merged map. |
| 2 | WDO and Sinkhole section names made semantic | `section1`/`section2` etc. are opaque. Using `findings`/`inaccessible`/`treatment` and `exterior`/`interior`/`garage` etc. improves developer comprehension without losing traceability (FIELD_INVENTORY references in comments). |
| 3 | WDO inaccessible areas: flat named keys, not indexed | Fixed 5 areas with regulatory names (Attic, Interior, etc.). Named keys (`inaccessible.attic.flag`) are more readable than indexed keys (`inaccessible.0.flag`). No dynamic add/remove needed. |
| 4 | Sinkhole scheduling: flat indexed keys | Fixed 4 slots with no semantic distinction between attempts. Indexed keys (`scheduling.attempts.0.date`) are appropriate. |
| 5 | General checkpoints: `List<Map>` not flat keys | Semi-dynamic list that could grow (rule-derived sections have incomplete item lists). `List<Map>` is extensible without new constants. Single key per section keeps constant count manageable. |
| 6 | 4-Point fixtures: named keys, not matrix | 10 named appliances are fixed by the form. Individual constants enable direct access (`plumbing.fixtureDishwasher`) without list iteration. |
| 7 | Pipe type checkboxes kept in formData | Although `plumbingPipeMaterial` is a shared field (primary material), the 4-Point form has individual checkboxes for each pipe type (multi-select). These form-specific booleans are stored in formData alongside the shared primary material. |
| 8 | Photo/evidence fields excluded from FormDataKeys | All image/photo/document fields are managed by the media module via `capturedPhotoPaths` and `capturedEvidencePaths` on PropertyData. Including them in FormDataKeys would create a parallel key system. |
| 9 | Secondary roof as separate section (`roofSecondary`) | The 4-Point form mirrors all primary roof fields for a secondary roof. Using a separate section namespace keeps keys clean and allows the secondary section to be conditionally absent. |
| 10 | Mold assessmentEndDate in formData, not universal | Mold is the only form allowing multi-day inspections. The start date maps to `universal.inspectionDate`; the end date is form-specific. |
