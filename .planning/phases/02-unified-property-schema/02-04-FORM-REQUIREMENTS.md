# 02-04: FormRequirements Extension + Evidence-to-Schema Path Mapping

> **Plan**: 02-04
> **Phase**: 2 -- Unified Property Schema Design
> **Date**: 2026-03-07
> **Agent**: Senior Developer

---

## 1. Overview

This document defines the `FormRequirements` extension patterns for the 4 new form types (WDO, Sinkhole, Mold Assessment, General Inspection), maps evidence requirements to schema paths, and identifies cross-form evidence sharing opportunities.

All extensions follow the existing pattern established in `form_requirements.dart`:
- Evidence requirements listed in `_requirementsByForm` per `FormType`
- Each requirement has a `key`, `label`, `form`, `mediaType`, `category`, `group`, and optional `when` predicate
- Predicate functions evaluate `branchContext` to determine if a conditional requirement is active

---

## 2. New RequiredPhotoCategory Values

The following values must be added to the `RequiredPhotoCategory` enum to support the 4 new form types:

```dart
enum RequiredPhotoCategory {
  // --- Existing (20 values) ---
  exteriorFront('Exterior Front'),
  exteriorRear('Exterior Rear'),
  exteriorLeft('Exterior Left'),
  exteriorRight('Exterior Right'),
  roofSlopeMain('Roof Slope Main'),
  roofSlopeSecondary('Roof Slope Secondary'),
  roofDefect('Roof Defect'),
  waterHeaterTprValve('Water Heater TPR Valve'),
  plumbingUnderSink('Plumbing Under Sink'),
  electricalPanelLabel('Electrical Panel Label'),
  electricalPanelOpen('Electrical Panel Open'),
  hvacDataPlate('HVAC Data Plate'),
  hazardPhoto('Hazard Photo'),
  windRoofDeck('Wind Mit Roof Deck Attachment'),
  windRoofToWall('Wind Mit Roof To Wall Attachment'),
  windOpeningProtection('Wind Mit Opening Protection'),
  windRoofShape('Wind Mit Roof Shape'),
  windSecondaryWaterResistance('Wind Mit Secondary Water Resistance'),
  windOpeningType('Wind Mit Opening Type'),
  windPermitYear('Wind Mit Permit Year'),

  // --- WDO (new -- 5 values) ---
  wdoPropertyExterior('WDO Property Exterior'),
  wdoInfestationEvidence('WDO Infestation Evidence'),
  wdoDamageArea('WDO Damage Area'),
  wdoInaccessibleArea('WDO Inaccessible Area'),
  wdoNoticePosting('WDO Notice Posting'),

  // --- Sinkhole (new -- 5 values) ---
  sinkholeFrontElevation('Sinkhole Front Elevation'),
  sinkholeRearElevation('Sinkhole Rear Elevation'),
  sinkholeChecklistItem('Sinkhole Checklist Item'),
  sinkholeGarageCrack('Sinkhole Garage Crack Pattern'),
  sinkholeAdjacentStructure('Sinkhole Adjacent Structure'),

  // --- Mold Assessment (new -- 4 values) ---
  moldAffectedArea('Mold Affected Area'),
  moldMoistureSource('Mold Moisture Source'),
  moldMoistureReading('Mold Moisture Reading'),
  moldLabReport('Mold Lab Report'),

  // --- General Inspection (new -- 6 values) ---
  generalFrontElevation('General Front Elevation'),
  generalElectricalPanel('General Electrical Panel'),
  generalDataPlate('General Data Plate'),
  generalDeficiency('General Deficiency'),
  generalPressureTest('General Pressure Test'),
  generalRoomPhoto('General Room Photo');

  const RequiredPhotoCategory(this.label);
  final String label;
}
```

**Total**: 20 existing + 20 new = 40 values.

---

## 3. WDO FormRequirements Extension

### 3.1 Evidence Requirements

```dart
FormType.wdo: <EvidenceRequirement>[
  // Always required
  _photo(
    key: 'photo:wdo_property_exterior',
    label: 'WDO Property Exterior',
    form: FormType.wdo,
    category: RequiredPhotoCategory.wdoPropertyExterior,
  ),
  _photo(
    key: 'photo:wdo_notice_posting',
    label: 'WDO Notice of Inspection Posting',
    form: FormType.wdo,
    category: RequiredPhotoCategory.wdoNoticePosting,
  ),

  // Conditional on visible evidence (W1)
  _photo(
    key: 'photo:wdo_infestation_evidence',
    label: 'WDO Infestation Evidence',
    form: FormType.wdo,
    category: RequiredPhotoCategory.wdoInfestationEvidence,
    when: _boolFlag('wdo_visible_evidence'),
  ),
  _photo(
    key: 'photo:wdo_damage_area',
    label: 'WDO Damage Area',
    form: FormType.wdo,
    category: RequiredPhotoCategory.wdoDamageArea,
    when: _boolFlag('wdo_damage_by_wdo'),
  ),

  // Conditional on inaccessible areas (W7-W11, any)
  _photo(
    key: 'photo:wdo_inaccessible_area',
    label: 'WDO Inaccessible Area Documentation',
    form: FormType.wdo,
    category: RequiredPhotoCategory.wdoInaccessibleArea,
    when: _anyWdoInaccessible,
  ),
],
```

### 3.2 Schema Path Mapping

| Evidence Key | Schema Path (Trigger) | Schema Path (Evidence Storage) | Required/Conditional |
|-------------|----------------------|-------------------------------|---------------------|
| `photo:wdo_property_exterior` | -- (always) | `capturedEvidencePaths['photo:wdo_property_exterior']` | Required |
| `photo:wdo_notice_posting` | -- (always, per Ch. 482 F.S.) | `capturedEvidencePaths['photo:wdo_notice_posting']` | Required |
| `photo:wdo_infestation_evidence` | `wdo_visible_evidence` == true | `capturedEvidencePaths['photo:wdo_infestation_evidence']` | Conditional |
| `photo:wdo_damage_area` | `wdo_damage_by_wdo` == true | `capturedEvidencePaths['photo:wdo_damage_area']` | Conditional |
| `photo:wdo_inaccessible_area` | Any `wdo_*_inaccessible` == true | `capturedEvidencePaths['photo:wdo_inaccessible_area']` | Conditional |

### 3.3 New Predicate Functions

```dart
/// True when any WDO inaccessible area flag is set.
static bool _anyWdoInaccessible(Map<String, dynamic> branchContext) {
  return branchContext['wdo_attic_inaccessible'] == true ||
      branchContext['wdo_interior_inaccessible'] == true ||
      branchContext['wdo_exterior_inaccessible'] == true ||
      branchContext['wdo_crawlspace_inaccessible'] == true ||
      branchContext['wdo_other_inaccessible'] == true;
}
```

### 3.4 Branch Flag Labels

```dart
// New entries for branchFlagLabels:
wdoVisibleEvidenceBranchFlag: 'WDO visible evidence found?',
wdoLiveWdoBranchFlag: 'Live WDOs observed?',
wdoEvidenceOfWdoBranchFlag: 'Evidence of WDOs found?',
wdoDamageByWdoBranchFlag: 'Damage caused by WDOs?',
wdoPreviousTreatmentBranchFlag: 'Previous treatment evidence?',
wdoTreatedAtInspectionBranchFlag: 'Treatment performed at inspection?',
wdoAtticInaccessibleBranchFlag: 'Attic areas inaccessible?',
wdoInteriorInaccessibleBranchFlag: 'Interior areas inaccessible?',
wdoExteriorInaccessibleBranchFlag: 'Exterior areas inaccessible?',
wdoCrawlspaceInaccessibleBranchFlag: 'Crawlspace inaccessible?',
wdoOtherInaccessibleBranchFlag: 'Other areas inaccessible?',
wdoSpotTreatmentBranchFlag: 'Spot treatment performed?',
```

---

## 4. Sinkhole FormRequirements Extension

### 4.1 Evidence Requirements

```dart
FormType.sinkholeInspection: <EvidenceRequirement>[
  // Always required
  _photo(
    key: 'photo:sinkhole_front_elevation',
    label: 'Sinkhole Front Elevation',
    form: FormType.sinkholeInspection,
    category: RequiredPhotoCategory.sinkholeFrontElevation,
  ),
  _photo(
    key: 'photo:sinkhole_rear_elevation',
    label: 'Sinkhole Rear Elevation',
    form: FormType.sinkholeInspection,
    category: RequiredPhotoCategory.sinkholeRearElevation,
  ),

  // Conditional on any "Yes" in checklist (S6 aggregate)
  _photo(
    key: 'photo:sinkhole_checklist_item',
    label: 'Sinkhole Checklist Item (Close-up + Perspective)',
    form: FormType.sinkholeInspection,
    category: RequiredPhotoCategory.sinkholeChecklistItem,
    minimumCount: 2, // close-up + perspective per "Yes" item
    when: _boolFlag('sinkhole_any_yes'),
  ),

  // Conditional on garage cracks (S4)
  _photo(
    key: 'photo:sinkhole_garage_crack',
    label: 'Sinkhole Garage Crack Pattern',
    form: FormType.sinkholeInspection,
    category: RequiredPhotoCategory.sinkholeGarageCrack,
    when: _boolFlag('sinkhole_any_garage_yes'),
  ),

  // Conditional on townhouse/row house (S7)
  _photo(
    key: 'photo:sinkhole_adjacent_structure',
    label: 'Sinkhole Adjacent Structure',
    form: FormType.sinkholeInspection,
    category: RequiredPhotoCategory.sinkholeAdjacentStructure,
    when: _boolFlag('sinkhole_townhouse'),
  ),
],
```

### 4.2 Schema Path Mapping

| Evidence Key | Schema Path (Trigger) | Schema Path (Evidence Storage) | Required/Conditional |
|-------------|----------------------|-------------------------------|---------------------|
| `photo:sinkhole_front_elevation` | -- (always) | `capturedEvidencePaths['photo:sinkhole_front_elevation']` | Required |
| `photo:sinkhole_rear_elevation` | -- (always) | `capturedEvidencePaths['photo:sinkhole_rear_elevation']` | Required |
| `photo:sinkhole_checklist_item` | `sinkhole_any_yes` == true | `capturedEvidencePaths['photo:sinkhole_checklist_item']` | Conditional |
| `photo:sinkhole_garage_crack` | `sinkhole_any_garage_yes` == true | `capturedEvidencePaths['photo:sinkhole_garage_crack']` | Conditional |
| `photo:sinkhole_adjacent_structure` | `sinkhole_townhouse` == true | `capturedEvidencePaths['photo:sinkhole_adjacent_structure']` | Conditional |

### 4.3 Branch Flag Labels

```dart
sinkholeAnyExteriorYesBranchFlag: 'Exterior indicators found?',
sinkholeAnyInteriorYesBranchFlag: 'Interior indicators found?',
sinkholeAnyGarageYesBranchFlag: 'Garage indicators found?',
sinkholeAnyAppurtenantYesBranchFlag: 'Appurtenant structure indicators found?',
sinkholeAnyYesBranchFlag: 'Any sinkhole indicators found?',
sinkholeTownhouseBranchFlag: 'Property is townhouse/row house?',
sinkholeUnableToScheduleBranchFlag: 'Unable to schedule inspection?',
sinkholeCrackSignificantBranchFlag: 'Significant cracks (>= 1/8 inch) found?',
```

---

## 5. Mold Assessment FormRequirements Extension

### 5.1 Evidence Requirements

```dart
FormType.moldAssessment: <EvidenceRequirement>[
  // Always required
  _photo(
    key: 'photo:mold_affected_area',
    label: 'Mold Affected Area Photo',
    form: FormType.moldAssessment,
    category: RequiredPhotoCategory.moldAffectedArea,
  ),
  _photo(
    key: 'photo:mold_moisture_reading',
    label: 'Mold Moisture Meter Reading',
    form: FormType.moldAssessment,
    category: RequiredPhotoCategory.moldMoistureReading,
  ),

  // Conditional on moisture source found (M2)
  _photo(
    key: 'photo:mold_moisture_source',
    label: 'Mold Moisture Source Photo',
    form: FormType.moldAssessment,
    category: RequiredPhotoCategory.moldMoistureSource,
    when: _boolFlag('mold_moisture_source_found'),
  ),

  // Conditional on samples taken (M3)
  _document(
    key: 'document:mold_lab_report',
    label: 'Mold Lab Report',
    form: FormType.moldAssessment,
    category: RequiredPhotoCategory.moldLabReport,
    when: _boolFlag('mold_samples_taken'),
  ),
],
```

### 5.2 Schema Path Mapping

| Evidence Key | Schema Path (Trigger) | Schema Path (Evidence Storage) | Required/Conditional |
|-------------|----------------------|-------------------------------|---------------------|
| `photo:mold_affected_area` | -- (always) | `capturedEvidencePaths['photo:mold_affected_area']` | Required |
| `photo:mold_moisture_reading` | -- (always, per s. 468.8414) | `capturedEvidencePaths['photo:mold_moisture_reading']` | Required |
| `photo:mold_moisture_source` | `mold_moisture_source_found` == true | `capturedEvidencePaths['photo:mold_moisture_source']` | Conditional |
| `document:mold_lab_report` | `mold_samples_taken` == true | `capturedEvidencePaths['document:mold_lab_report']` | Conditional |

### 5.3 Branch Flag Labels

```dart
moldVisibleFoundBranchFlag: 'Visible mold growth found?',
moldMoistureSourceFoundBranchFlag: 'Moisture source identified?',
moldSamplesTakenBranchFlag: 'Samples collected?',
moldAirSamplesTakenBranchFlag: 'Air samples collected?',
moldSurfaceSamplesTakenBranchFlag: 'Surface samples collected?',
moldBulkSamplesTakenBranchFlag: 'Bulk samples collected?',
moldRemediationRecommendedBranchFlag: 'Remediation recommended?',
moldPostRemediationBranchFlag: 'Post-remediation assessment?',
```

---

## 6. General Inspection FormRequirements Extension

### 6.1 Evidence Requirements

```dart
FormType.generalInspection: <EvidenceRequirement>[
  // Always required
  _photo(
    key: 'photo:general_front_elevation',
    label: 'General Front Elevation',
    form: FormType.generalInspection,
    category: RequiredPhotoCategory.generalFrontElevation,
  ),
  _photo(
    key: 'photo:general_electrical_panel',
    label: 'General Electrical Panel',
    form: FormType.generalInspection,
    category: RequiredPhotoCategory.generalElectricalPanel,
  ),
  _photo(
    key: 'photo:general_data_plate',
    label: 'General Water Heater/HVAC Data Plate',
    form: FormType.generalInspection,
    category: RequiredPhotoCategory.generalDataPlate,
    minimumCount: 2, // water heater + HVAC
  ),
  _photo(
    key: 'photo:general_pressure_test',
    label: 'General Pressure Test Reading',
    form: FormType.generalInspection,
    category: RequiredPhotoCategory.generalPressureTest,
  ),

  // Conditional on any "Poor" rating across all sections
  _photo(
    key: 'photo:general_deficiency',
    label: 'General Deficiency Photo',
    form: FormType.generalInspection,
    category: RequiredPhotoCategory.generalDeficiency,
    when: _boolFlag('general_safety_hazard'),
    // Note: _boolFlag('general_safety_hazard') is used as a proxy.
    // The controller sets this when ANY section has a Poor rating
    // or safety hazard. More granular per-section evidence could
    // be implemented in Phase 7 when the General form is built.
  ),
],
```

### 6.2 Schema Path Mapping

| Evidence Key | Schema Path (Trigger) | Schema Path (Evidence Storage) | Required/Conditional |
|-------------|----------------------|-------------------------------|---------------------|
| `photo:general_front_elevation` | -- (always) | `capturedEvidencePaths['photo:general_front_elevation']` | Required |
| `photo:general_electrical_panel` | -- (always) | `capturedEvidencePaths['photo:general_electrical_panel']` | Required |
| `photo:general_data_plate` | -- (always, min 2) | `capturedEvidencePaths['photo:general_data_plate']` | Required |
| `photo:general_pressure_test` | -- (always) | `capturedEvidencePaths['photo:general_pressure_test']` | Required |
| `photo:general_deficiency` | `general_safety_hazard` == true | `capturedEvidencePaths['photo:general_deficiency']` | Conditional |

### 6.3 Branch Flag Labels

```dart
generalSafetyHazardBranchFlag: 'Safety hazard identified?',
generalMoistureMoldEvidenceBranchFlag: 'Moisture/mold evidence observed?',
generalPestEvidenceBranchFlag: 'Pest/WDO evidence observed?',
generalStructuralConcernBranchFlag: 'Structural concern identified?',
```

---

## 7. Cross-Form Evidence Sharing Opportunities

### 7.1 Identified Sharing Opportunities

When multiple forms are enabled for the same inspection, certain evidence photos serve multiple forms. This is the foundation for Phase 9 (Cross-Form Integration).

| Evidence Category | Forms Using It | Sharing Mechanism | Notes |
|------------------|---------------|-------------------|-------|
| **Exterior Front Photo** | 4-Point (`exteriorFront`), General (`generalFrontElevation`), Sinkhole (`sinkholeFrontElevation`) | Same photo can satisfy all three requirements | Same physical photo; different evidence keys per form |
| **Exterior Rear Photo** | 4-Point (`exteriorRear`), Sinkhole (`sinkholeRearElevation`) | Same photo can satisfy both requirements | Same physical photo |
| **Exterior Left/Right Photos** | 4-Point (`exteriorLeft`, `exteriorRight`) | 4-Point only currently | Potential future sharing with General exterior section |
| **Electrical Panel Photo** | 4-Point (`electricalPanelLabel`, `electricalPanelOpen`), General (`generalElectricalPanel`) | 4-Point requires both label and open views; General requires at least panel photo | 4-Point is superset; General can reuse either |
| **HVAC/Water Heater Data Plate** | 4-Point (`hvacDataPlate`), General (`generalDataPlate`) | Same data plate photo serves both | General requires both WH and HVAC plates |
| **Water Heater TPR Valve** | 4-Point (`waterHeaterTprValve`) | 4-Point only | No General equivalent (General uses checkpoint rating) |
| **Roof Slope Photos** | 4-Point (`roofSlopeMain`, `roofSlopeSecondary`), RCF-1 (same categories) | Already shared via same `RequiredPhotoCategory` values | Existing cross-form sharing |
| **Property Exterior** | WDO (`wdoPropertyExterior`), 4-Point (`exteriorFront`), General (`generalFrontElevation`), Sinkhole (`sinkholeFrontElevation`) | WDO exterior can reuse 4-Point or General front elevation | Different regulatory contexts but same physical photo |

### 7.2 Sharing Model Design

Cross-form evidence sharing will use a **reference-based model**:

```
capturedEvidencePaths:
  'photo:exterior_front' -> ['/path/to/front.jpg']       // 4-Point source
  'photo:general_front_elevation' -> ['/path/to/front.jpg']  // Same file, different key
  'photo:sinkhole_front_elevation' -> ['/path/to/front.jpg'] // Same file, different key
```

Each form maintains its own evidence key, but the underlying file path can be shared. This allows:
1. A single capture to satisfy multiple form requirements
2. Each form to independently track its own completion status
3. A form to be removed without affecting other forms' evidence

### 7.3 Cross-Form Evidence Matrix

| RequiredPhotoCategory | 4-Point | RCF-1 | Wind Mit | WDO | Sinkhole | Mold | General | Can Share With |
|----------------------|---------|-------|----------|-----|----------|------|---------|---------------|
| `exteriorFront` | x | | | | | | | General, Sinkhole, WDO |
| `exteriorRear` | x | | | | | | | Sinkhole |
| `exteriorLeft` | x | | | | | | | -- |
| `exteriorRight` | x | | | | | | | -- |
| `roofSlopeMain` | x | x | | | | | | Already shared |
| `roofSlopeSecondary` | x | x | | | | | | Already shared |
| `roofDefect` | | x | | | | | | -- |
| `waterHeaterTprValve` | x | | | | | | | -- |
| `plumbingUnderSink` | x | | | | | | | -- |
| `electricalPanelLabel` | x | | | | | | | General (panel) |
| `electricalPanelOpen` | x | | | | | | | General (panel) |
| `hvacDataPlate` | x | | | | | | | General (data plate) |
| `hazardPhoto` | x | | | | | | | -- |
| `windRoofDeck` | | | x | | | | | -- |
| `windRoofToWall` | | | x | | | | | -- |
| `windOpeningProtection` | | | x | | | | | -- |
| `windRoofShape` | | | x | | | | | -- |
| `windSecondaryWaterResistance` | | | x | | | | | -- |
| `windOpeningType` | | | x | | | | | -- |
| `windPermitYear` | | | x | | | | | -- |
| `wdoPropertyExterior` | | | | x | | | | 4-Point (front), General, Sinkhole |
| `wdoInfestationEvidence` | | | | x | | | | -- |
| `wdoDamageArea` | | | | x | | | | -- |
| `wdoInaccessibleArea` | | | | x | | | | -- |
| `wdoNoticePosting` | | | | x | | | | -- |
| `sinkholeFrontElevation` | | | | | x | | | 4-Point (front), General, WDO |
| `sinkholeRearElevation` | | | | | x | | | 4-Point (rear) |
| `sinkholeChecklistItem` | | | | | x | | | -- |
| `sinkholeGarageCrack` | | | | | x | | | -- |
| `sinkholeAdjacentStructure` | | | | | x | | | -- |
| `moldAffectedArea` | | | | | | x | | -- |
| `moldMoistureSource` | | | | | | x | | -- |
| `moldMoistureReading` | | | | | | x | | -- |
| `moldLabReport` | | | | | | x | | -- |
| `generalFrontElevation` | | | | | | | x | 4-Point (front), Sinkhole, WDO |
| `generalElectricalPanel` | | | | | | | x | 4-Point (panel label/open) |
| `generalDataPlate` | | | | | | | x | 4-Point (HVAC data plate) |
| `generalDeficiency` | | | | | | | x | -- |
| `generalPressureTest` | | | | | | | x | -- |
| `generalRoomPhoto` | | | | | | | x | -- |

### 7.4 Sharing Priority Groups

For Phase 9 implementation, evidence sharing should follow these priority groups:

| Priority | Sharing Group | Forms | Category Mapping |
|----------|--------------|-------|-----------------|
| 1 | Front Elevation | 4-Point, General, Sinkhole, WDO | `exteriorFront` <-> `generalFrontElevation` <-> `sinkholeFrontElevation` <-> `wdoPropertyExterior` |
| 2 | Rear Elevation | 4-Point, Sinkhole | `exteriorRear` <-> `sinkholeRearElevation` |
| 3 | Electrical Panel | 4-Point, General | `electricalPanelLabel`/`electricalPanelOpen` <-> `generalElectricalPanel` |
| 4 | Data Plates | 4-Point, General | `hvacDataPlate` <-> `generalDataPlate` |
| 5 | Roof Slopes | 4-Point, RCF-1 | Already shared (same category) |

---

## 8. Complete Evidence Requirements Summary

### 8.1 Requirements by Form (All 7 Forms)

| Form | Always Required | Conditional | Total |
|------|----------------|-------------|-------|
| 4-Point | 11 photos | 1 (hazard) | 12 |
| RCF-1 | 2 photos | 1 (defect) | 3 |
| Wind Mit | 7 photos | 3 documents | 10 |
| WDO | 2 photos | 3 photos | 5 |
| Sinkhole | 2 photos | 3 photos | 5 |
| Mold | 2 photos | 1 photo + 1 document | 4 |
| General | 4 photos | 1 photo | 5 |
| **Total** | **30** | **14** | **44** |

### 8.2 Requirements by Media Type

| Media Type | Always Required | Conditional | Total |
|-----------|----------------|-------------|-------|
| Photo | 30 | 10 | 40 |
| Document | 0 | 4 | 4 |
| **Total** | **30** | **14** | **44** |

---

## 9. Implementation Notes

### 9.1 FormType Enum Extension Required

Before implementing these requirements, the `FormType` enum must be extended with 4 new values:

```dart
enum FormType {
  fourPoint(code: 'four_point', label: 'Insp4pt 03-25'),
  roofCondition(code: 'roof_condition', label: 'RCF-1 03-25'),
  windMitigation(code: 'wind_mitigation', label: 'OIR-B1-1802 Rev 04/26'),
  wdo(code: 'wdo', label: 'FDACS-13645'),
  sinkholeInspection(code: 'sinkhole', label: 'Citizens Sinkhole'),
  moldAssessment(code: 'mold_assessment', label: 'Mold Assessment (MRSA)'),
  generalInspection(code: 'general', label: 'General Home Inspection');
  // ...
}
```

### 9.2 No Structural Changes to Existing Classes

The extensions require:
- Adding entries to `_requirementsByForm` map (data only)
- Adding entries to `canonicalBranchFlags` set (data only)
- Adding entries to `branchFlagsByForm` map (data only)
- Adding entries to `branchFlagLabels` map (data only)
- Adding new `RequiredPhotoCategory` enum values
- Adding one new predicate function (`_anyWdoInaccessible`)

No changes to `EvidenceRequirement`, `WizardStepDefinition`, `WizardProgressSnapshot`, or `InspectionWizardState` class structures. The existing architecture handles new form types through data extension, exactly as designed.

### 9.3 Backward Compatibility

All additions are purely additive:
- New `FormType` values do not affect existing values
- New `RequiredPhotoCategory` values do not affect existing values
- New `canonicalBranchFlags` entries do not affect existing flag processing
- Existing `_canonicalizeBranchContext()` continues to work (it iterates `canonicalBranchFlags`)

### 9.4 Implementation Phase Mapping

| Component | Implementation Phase | Dependency |
|-----------|---------------------|------------|
| `FormType` enum extension | Phase 3 (Implementation Foundation) | None |
| `RequiredPhotoCategory` extensions | Phase 3 | FormType |
| WDO `FormRequirements` entries | Phase 4 (WDO Form) | Phase 3 |
| Sinkhole `FormRequirements` entries | Phase 5 (Sinkhole Form) | Phase 3 |
| Mold `FormRequirements` entries | Phase 6 (Mold Form) | Phase 3 |
| General `FormRequirements` entries | Phase 7 (General Form) | Phase 3 |
| Cross-form evidence sharing | Phase 9 (Cross-Form Integration) | Phases 4-7 |
