# 02-05: Validation Report -- Phase 2 Success Criteria + Gap Analysis

> **Plan**: 02-05 Field-to-Schema Mapping + Validation Report
> **Phase**: 2 -- Unified Property Schema Design
> **Date**: 2026-03-07
> **Agent**: Senior Developer

---

## 1. Validation Rules Matrix

### 1.1 Universal Fields (8)

| Schema Path | Validation Rule | Error Message | Form(s) |
|-------------|----------------|---------------|---------|
| `universal.propertyAddress` | Required: `value.trim().isNotEmpty` | "Property address is required" | All 7 |
| `universal.inspectionDate` | Required: Not null. Range: not after `now + 365d`; not before `1900-01-01` | "Inspection date is out of valid range" | All 7 |
| `universal.inspectorName` | Required: `value.trim().isNotEmpty` | "Inspector name is required" | All 7 |
| `universal.inspectorCompany` | Required: `value.trim().isNotEmpty` | "Company name is required" | All 7 |
| `universal.inspectorLicenseNumber` | Required: `value.trim().isNotEmpty` | "License number is required" | All 7 (6 mandatory, General optional) |
| `universal.clientName` | Required: `value.trim().isNotEmpty` | "Client name is required" | All 7 |
| `universal.inspectorSignaturePath` | Conditional: If non-null, file must exist at path | "Signature file not found" | All 7 |
| `universal.comments` | Optional: No validation (free text, trimmed) | -- | All 7 |

### 1.2 Shared Building System Fields (13)

| Schema Path | Validation Rule | Error Message | Form(s) |
|-------------|----------------|---------------|---------|
| `shared.yearBuilt` | Range: `1800 <= value <= DateTime.now().year + 1` | "Year built must be between 1800 and {year+1}" | 4P, RC, WM, MA, GI |
| `shared.policyNumber` | Conditional-Required: Non-empty when form requires it (insurance forms) | "Policy number is required for this form type" | 4P, RC, WM, SK |
| `shared.inspectorPhone` | Conditional-Required: Non-empty when form includes it | "Inspector phone is required" | WM, WDO, SK, GI |
| `shared.signatureDate` | Cross-field: `>= inspectionDate`; `<= now + 30 days` | "Signature date cannot precede inspection date" | 4P, RC, WM, WDO |
| `shared.roofCoveringMaterial` | Conditional-Required: Non-empty when form includes roof section | "Roof covering material is required" | 4P, RC, GI |
| `shared.roofAge` | Range: `0 <= value <= 100` | "Roof age must be between 0 and 100 years" | 4P, RC, GI |
| `shared.roofCondition` | Enum: Valid RatingScale value | "Invalid roof condition rating" | 4P, RC, GI |
| `shared.electricalPanelType` | Conditional-Required: Non-empty when applicable | "Panel type is required" | 4P, GI |
| `shared.electricalPanelAmps` | Range: Positive integer, typical 60-400 | "Panel amperage must be a positive number" | 4P, GI |
| `shared.plumbingPipeMaterial` | Conditional-Required: Non-empty when applicable | "Pipe material is required" | 4P, GI |
| `shared.waterHeaterType` | Conditional-Required: Non-empty when applicable | "Water heater type is required" | 4P, GI |
| `shared.hvacType` | Conditional-Required: Non-empty when applicable | "HVAC type is required" | 4P, GI |
| `shared.foundationCracks` | Boolean: Valid bool when applicable (tri-state: true/false/null) | -- | SK, GI |

### 1.3 Four-Point Form-Specific Fields

| Schema Path | Validation Rule | Error Message | Form(s) |
|-------------|----------------|---------------|---------|
| `fourPoint.electrical.mainPanelType` | Enum: "circuit_breaker" or "fuse" | "Select panel type" | 4P |
| `fourPoint.electrical.mainPanelAmps` | Required: Positive integer | "Enter panel amperage" | 4P |
| `fourPoint.electrical.mainAmpsSufficient` | Required: bool | "Indicate if amperage is sufficient" | 4P |
| `fourPoint.electrical.secondPanelType` | Conditional: Required when second panel exists. Enum. | "Select second panel type" | 4P |
| `fourPoint.electrical.secondPanelAmps` | Conditional: Required when second panel exists. Positive int. | "Enter second panel amperage" | 4P |
| `fourPoint.electrical.secondAmpsSufficient` | Conditional: Required when second panel exists. bool. | "Indicate if second panel amperage sufficient" | 4P |
| `fourPoint.electrical.clothWiring` | Required: bool | -- | 4P |
| `fourPoint.electrical.knobAndTube` | Required: bool | -- | 4P |
| `fourPoint.electrical.aluminumBranchWiring` | Required: bool | -- | 4P |
| `fourPoint.electrical.aluminumBranchDetails` | Conditional: Non-empty when aluminum present | "Describe aluminum wiring details" | 4P |
| `fourPoint.electrical.copalumCrimp` | Conditional: bool when aluminum present | -- | 4P |
| `fourPoint.electrical.alumiconn` | Conditional: bool when aluminum present | -- | 4P |
| `fourPoint.electrical.hazard*` (13 items) | Required: bool per item | -- | 4P |
| `fourPoint.electrical.hazardOtherDesc` | Conditional: Non-empty when hazardOther = true | "Describe other hazard" | 4P |
| `fourPoint.electrical.generalCondition` | Enum: "satisfactory" or "unsatisfactory" | "Select electrical condition" | 4P |
| `fourPoint.electrical.mainPanelAge` | Required: Non-empty string | "Enter panel age" | 4P |
| `fourPoint.electrical.mainPanelYearUpdated` | Required: Non-empty string | "Enter year updated" | 4P |
| `fourPoint.electrical.mainPanelBrand` | Required: Non-empty string | "Enter panel brand" | 4P |
| `fourPoint.electrical.secondPanel{Age,YearUpdated,Brand}` | Conditional: Required when second panel exists | "Enter second panel {field}" | 4P |
| `fourPoint.electrical.wiringType` | Required: Non-empty string | "Select wiring type" | 4P |
| `fourPoint.hvac.centralAc` | Required: bool | -- | 4P |
| `fourPoint.hvac.centralHeat` | Required: bool | -- | 4P |
| `fourPoint.hvac.primaryHeatSource` | Required: Non-empty string | "Enter primary heat source" | 4P |
| `fourPoint.hvac.goodWorkingOrder` | Required: bool | -- | 4P |
| `fourPoint.hvac.lastServiceDate` | Required: Non-empty string | "Enter last service date" | 4P |
| `fourPoint.hvac.hazard*` (4 items) | Required: bool | -- | 4P |
| `fourPoint.hvac.hazardSourcePortable` | Conditional: bool when space heater primary | -- | 4P |
| `fourPoint.hvac.systemAge` | Required: Non-empty string | "Enter system age" | 4P |
| `fourPoint.hvac.yearUpdated` | Required: Non-empty string | "Enter year updated" | 4P |
| `fourPoint.plumbing.tprValve` | Required: bool | -- | 4P |
| `fourPoint.plumbing.activeLeak` | Required: bool | -- | 4P |
| `fourPoint.plumbing.priorLeak` | Required: bool | -- | 4P |
| `fourPoint.plumbing.waterHeaterLocation` | Required: Non-empty string | "Enter water heater location" | 4P |
| `fourPoint.plumbing.fixture*` (10 items) | Required: Enum "s"/"u"/"na" | "Rate each fixture" | 4P |
| `fourPoint.plumbing.fixtureUnsatisfactoryComments` | Conditional: Non-empty when any fixture = "u" | "Explain unsatisfactory fixtures" | 4P |
| `fourPoint.plumbing.pipingAge` | Required: Non-empty string | "Enter piping age" | 4P |
| `fourPoint.plumbing.{completely,partially}Repiped` | Required: bool | -- | 4P |
| `fourPoint.plumbing.repipeDetails` | Conditional: Non-empty when repiped | "Enter re-pipe details" | 4P |
| `fourPoint.plumbing.pipe{Copper,PvcCpvc,Galvanized,Pex,Polybutylene,Other}` | Required: bool per type | -- | 4P |
| `fourPoint.plumbing.pipeOtherDesc` | Conditional: Non-empty when pipeOther = true | "Describe other pipe type" | 4P |
| `fourPoint.roof.primary*` (18 fields) | Various: see Roof section | -- | 4P |
| `fourPoint.roofSecondary.*` (20 fields) | Conditional: All required when multiple roof coverings | -- | 4P |
| `fourPoint.inspector.title` | Required: Non-empty string | "Enter inspector title" | 4P |
| `fourPoint.inspector.licenseType` | Required: Non-empty string | "Enter license type" | 4P |

### 1.4 Roof Condition Form-Specific Fields

| Schema Path | Validation Rule | Error Message | Form(s) |
|-------------|----------------|---------------|---------|
| `roofCondition.roof.remainingLife` | Required: Non-empty string | "Enter remaining useful life" | RC |
| `roofCondition.roof.conditionRating` | Enum: "good"/"fair"/"poor"/"failed" | "Select roof condition rating" | RC |
| `roofCondition.roof.priorRepairs` | Required: bool | -- | RC |
| `roofCondition.roof.priorRepairsDesc` | Conditional: Non-empty when priorRepairs = true | "Describe prior repairs" | RC |
| `roofCondition.roof.leaks` | Required: bool | -- | RC |
| `roofCondition.roof.leaksDesc` | Conditional: Non-empty when leaks = true | "Describe leak evidence" | RC |
| `roofCondition.roof.windDamage` | Required: bool | -- | RC |
| `roofCondition.roof.windDamageDesc` | Conditional: Non-empty when windDamage = true | "Describe wind damage" | RC |
| `roofCondition.roof.hailDamage` | Required: bool | -- | RC |
| `roofCondition.roof.hailDamageDesc` | Conditional: Non-empty when hailDamage = true | "Describe hail damage" | RC |
| `roofCondition.roof.numberOfLayers` | Required: Non-empty string | "Enter number of roof layers" | RC |
| `roofCondition.roof.flashingCondition` | Required: Non-empty string (enum) | "Select flashing condition" | RC |
| `roofCondition.roof.soffitFasciaCondition` | Required: Non-empty string (enum) | "Select soffit/fascia condition" | RC |
| `roofCondition.roof.guttersDownspouts` | Required: Non-empty string (enum) | "Select gutters/downspouts status" | RC |
| `roofCondition.roof.comments` | Optional: Free text | -- | RC |

### 1.5 Wind Mitigation Form-Specific Fields

| Schema Path | Validation Rule | Error Message | Form(s) |
|-------------|----------------|---------------|---------|
| `windMit.q1.buildingCode` | Required: Non-empty string (radio) | "Select building code compliance" | WM |
| `windMit.q1.year` | Conditional: Required for certain Q1 selections | "Enter year" | WM |
| `windMit.q2.roofCovering` | Required: Non-empty string (radio) | "Select roof covering compliance" | WM |
| `windMit.q2.permitDate` | Conditional: Required for certain Q2 selections | "Enter permit date" | WM |
| `windMit.q3.roofDeckAttachment` | Required: Enum "A"/"B"/"C"/"D" | "Select roof deck attachment type" | WM |
| `windMit.q4.roofWallAttachment` | Required: Non-empty string | "Select roof-to-wall attachment" | WM |
| `windMit.q5.roofGeometry` | Required: Enum "hip"/"non_hip"/"flat" | "Select roof geometry" | WM |
| `windMit.q6.secondaryWaterResistance` | Required: Enum "yes"/"no"/"other" | "Select SWR status" | WM |
| `windMit.q7.openingProtection` | Required: Enum "A"/"B"/"C"/"N" | "Select opening protection" | WM |
| `windMit.q7.{window,door,skylight,garageDoor}Count` | Required: Non-negative integer | "Enter opening count" | WM |
| `windMit.q8.openingProtectionScope` | Required: Enum "all"/"none"/"partial" | "Select protection scope" | WM |
| `windMit.inspector.reinspection` | Required: bool | -- | WM |
| `windMit.inspector.comments` | Optional: Free text | -- | WM |

### 1.6 WDO Form-Specific Fields

| Schema Path | Validation Rule | Error Message | Form(s) |
|-------------|----------------|---------------|---------|
| `wdo.header.businessLicense` | Required: Non-empty | "Enter business license number" | WDO |
| `wdo.header.companyAddress` | Required: Non-empty | "Enter company address" | WDO |
| `wdo.header.companyCityStateZip` | Required: Non-empty | "Enter company city, state, zip" | WDO |
| `wdo.header.structuresInspected` | Required: Non-empty | "Enter structures inspected" | WDO |
| `wdo.header.reportSentTo` | Optional: Free text | -- | WDO |
| `wdo.findings.noVisibleSigns` XOR `wdo.findings.visibleEvidence` | Mutex: Exactly one must be true | "Select either no visible signs or visible evidence" | WDO |
| `wdo.findings.liveWdo` | Conditional: bool when visibleEvidence = true | -- | WDO |
| `wdo.findings.liveWdoDescription` | Conditional: Non-empty when liveWdo = true | "Describe live WDO findings" | WDO |
| `wdo.findings.evidenceOfWdo` | Conditional: bool when visibleEvidence = true | -- | WDO |
| `wdo.findings.evidenceDescription` | Conditional: Non-empty when evidenceOfWdo = true | "Describe WDO evidence" | WDO |
| `wdo.findings.damageByWdo` | Conditional: bool when visibleEvidence = true | -- | WDO |
| `wdo.findings.damageDescription` | Conditional: Non-empty when damageByWdo = true | "Describe WDO damage" | WDO |
| When visibleEvidence = true | Cross-field: At least one of liveWdo/evidenceOfWdo/damageByWdo must be true | "Select at least one finding type" | WDO |
| `wdo.inaccessible.{area}.flag` (5 areas) | Required: bool | -- | WDO |
| `wdo.inaccessible.{area}.specificAreas` | Conditional: Non-empty when flag = true | "Describe inaccessible areas" | WDO |
| `wdo.inaccessible.{area}.reason` | Conditional: Non-empty when flag = true | "Provide reason for inaccessibility" | WDO |
| `wdo.treatment.previousTreatment` | Required: bool | -- | WDO |
| `wdo.treatment.previousDesc` | Conditional: Non-empty when previousTreatment = true | "Describe previous treatment" | WDO |
| `wdo.treatment.noticeLocation` | Required: Non-empty | "Enter notice of inspection location" | WDO |
| `wdo.treatment.treatedAtInspection` | Required: bool | -- | WDO |
| `wdo.treatment.{organism,pesticide,terms}Treated` | Conditional: Non-empty when treatedAtInspection = true | "Enter treatment details" | WDO |
| `wdo.treatment.method{WholeStructure,SpotTreatment}` | Conditional-Mutex: When treatedAtInspection, exactly one method | "Select treatment method" | WDO |
| `wdo.treatment.spotTreatmentDesc` | Conditional: Non-empty when spotTreatment = true | "Describe spot treatment scope" | WDO |
| `wdo.treatment.treatmentNoticeLocation` | Conditional: Non-empty when treatedAtInspection = true | "Enter treatment notice location" | WDO |
| `wdo.certification.licenseeSigPath` | Conditional: If non-null, file must exist | "Signature file not found" | WDO |

### 1.7 Sinkhole Form-Specific Fields

| Schema Path | Validation Rule | Error Message | Form(s) |
|-------------|----------------|---------------|---------|
| `sinkhole.{section}.{item}` (19 items) | Required: Enum "yes"/"no"/"na" | "Answer each checklist item" | SK |
| `sinkhole.{section}.{item}Detail` (19 items) | Conditional: Non-empty when item = "yes" | "Provide details for Yes items" | SK |
| `sinkhole.additional.generalCondition` | Required: Non-empty (multi-line) | "Describe general condition" | SK |
| `sinkhole.additional.adjacentBuilding` | Conditional: Non-empty when townhouse/row house | "Describe adjacent building" | SK |
| `sinkhole.additional.nearestSinkhole` | Required: Non-empty | "Enter distance to nearest sinkhole" | SK |
| `sinkhole.additional.otherFindings` | Required: Non-empty (multi-line) | "Enter other relevant findings" | SK |
| `sinkhole.additional.unableToSchedule` | Conditional: Non-empty when inspection not completed | "Explain scheduling difficulty" | SK |
| `sinkhole.scheduling.attempts.{N}.*` (4x4) | Conditional: Required when unable to schedule | "Enter scheduling attempt details" | SK |

### 1.8 Mold Assessment Form-Specific Fields

| Schema Path | Validation Rule | Error Message | Form(s) |
|-------------|----------------|---------------|---------|
| `mold.header.assessmentEndDate` | Optional: Valid ISO date if present | "Invalid end date" | MA |
| `mold.header.weatherConditions` | Required: Non-empty | "Enter weather conditions" | MA |
| `mold.header.buildingType` | Required: Non-empty | "Enter building type" | MA |
| `mold.header.hvacStatus` | Required: Enum "operating"/"not_operating"/"unknown" | "Select HVAC status" | MA |
| `mold.header.licenseType` | Required: Non-empty (MRSA) | "Enter license type" | MA |
| `mold.scope.areasAssessed` | Required: Non-empty list | "Enter at least one assessed area" | MA |
| `mold.scope.areasNotAssessed` | Required: Non-empty list (even if empty assessment -- document with reason) | "Document areas not assessed" | MA |
| `mold.findings.moistureSources` | Conditional: Non-empty list when moisture found | "List moisture sources" | MA |
| `mold.findings.moistureReadings` | Required: Non-empty list (per s. 468.8414) | "Enter moisture readings" | MA |
| `mold.findings.visibleLocations` | Conditional: Non-empty list when mold found | "Document mold locations" | MA |
| `mold.sampling.sampleLocations` | Conditional: Non-empty list when samples taken | "Enter sample locations" | MA |
| `mold.sampling.labName` | Conditional: Non-empty when samples taken | "Enter lab name" | MA |
| `mold.sampling.labReportNumber` | Conditional: Non-empty when samples taken | "Enter lab report number" | MA |
| `mold.remediation.recommended` | Required: bool | -- | MA |
| `mold.remediation.scope` | Conditional: Non-empty when recommended = true | "Describe remediation scope" | MA |
| `mold.remediation.reoccupancyCriteria` | Conditional: Non-empty when recommended = true | "Specify re-occupancy criteria" | MA |

### 1.9 General Inspection Form-Specific Fields

| Schema Path | Validation Rule | Error Message | Form(s) |
|-------------|----------------|---------------|---------|
| `general.header.propertyDescription` | Optional: Free text | -- | GI |
| `general.header.inspectionTime` | Required: Valid time string | "Enter inspection time" | GI |
| `general.header.reportNumber` | Required: Non-empty | "Enter report number" | GI |
| `general.header.inspectionFee` | Required: Non-negative number | "Enter inspection fee" | GI |
| `general.header.paymentMethod` | Required: Non-empty (enum) | "Select payment method" | GI |
| `general.{section}.checkpoints` (12 sections) | Required: List with all expected items rated | "Rate all checkpoint items" | GI |
| `general.{section}.checkpoints[*].rating` | Enum: "good"/"fair"/"poor"/"na" | "Select rating for each item" | GI |
| `general.{section}.checkpoints[*].comment` | Conditional: Non-empty when rating = "poor" | "Explain poor rating" | GI |
| `general.{section}.notes` | Conditional: Non-empty when any checkpoint = "poor" | "Provide section recommendations" | GI |
| `general.{section}.{generalInfoField}` (confirmed sections) | Required: Non-empty per section | "Enter {field}" | GI |

---

## 2. ROADMAP Phase 2 Success Criteria Verification

### Criterion 1: Master JSON schema defined with shared property namespace

**Status**: PASS

**Evidence**:
- `02-01-UNIVERSAL-FIELDS.md`: 8 universal fields (address, client, inspector, dates) strongly typed in `UniversalPropertyFields` class with full Dart signatures, toJson/fromJson contracts.
- `02-01-SHARED-FIELDS.md`: 13 shared building-system fields in `SharedBuildingSystemFields` class.
- `02-02-PROPERTY-DATA.md`: `PropertyData` aggregate wraps universal + shared into a single schema envelope with JSON serialization.
- Shared property namespace (`universal.*`, `shared.*`) is the single source of truth for cross-form data.

### Criterion 2: Per-form namespaces for form-specific fields

**Status**: PASS

**Evidence**:
- `02-02-PROPERTY-DATA.md`: `formData` is `Map<FormType, Map<String, dynamic>>` -- each FormType enum value provides the namespace.
- `02-03-FORM-DATA-KEYS.md`: 333 constants across 7 form types with prefixes (`fp_`, `rc_`, `wm_`, `wdo_`, `sk_`, `ma_`, `gi_`). Section-based key format: `{section}.{fieldName}`.
- Namespaces: `fourPoint/`, `roofCondition/`, `windMitigation/`, `wdo/`, `sinkholeInspection/`, `moldAssessment/`, `generalInspection/` -- matches ROADMAP requirement for `wdo/`, `sinkhole/`, `mold/`, `general/`, `fourPoint/`, `roofCondition/`, `windMit/`.

### Criterion 3: Field-to-schema mapping document

**Status**: PASS

**Evidence**:
- `SCHEMA_MAPPING.md` (this plan's primary deliverable): Every field from FIELD_INVENTORY Sections 4.1-4.7 mapped to its schema location with table per form type.
- Count verification: 8 universal + 13 shared + 333 form-specific constants = 354 unique schema fields covering ~486 inventory fields (with documented delta for media fields, repeat fields, and checkpoint compression).

### Criterion 4: Validation rules defined per field

**Status**: PASS

**Evidence**:
- `02-05-VALIDATION-REPORT.md` (this document) Section 1: Complete validation rules matrix organized by form type.
- `02-01-UNIVERSAL-FIELDS.md` Section 4: Validation rules for all 8 universal fields.
- `02-01-SHARED-FIELDS.md` Section 6: Validation rules for all 13 shared fields.
- Validation types covered: Required, Conditional, Range, Format, Enum, Cross-field (mutex, cross-field date comparison).

### Criterion 5: Schema supports branching logic

**Status**: PASS

**Evidence**:
- `02-04-CONDITIONAL-LOGIC.md`: 37 canonical branch flags + ~50 derived flags across all 7 form types.
- Branch hierarchies documented for all forms: 4-Point (6 implicit branches), RCF-1 (1 flag), Wind Mit (3 flags), WDO (12 flags), Sinkhole (8 flags + 19 pattern-based), Mold (8 flags), General (per-section pattern-based).
- `02-02-PROPERTY-DATA.md`: `branchContext` getter merges all data layers for predicate evaluation.
- `02-04-FORM-REQUIREMENTS.md`: Evidence predicates use `_boolFlag()` pattern to evaluate branch conditions.

### Criterion 6: Backward compatibility spec

**Status**: PASS

**Evidence**:
- `02-02-MIGRATION.md`: Complete migration strategy with binary decision (Strategy B: Time-Bound Coexistence).
  - `fromInspectionDraft()` factory constructor maps all InspectionDraft fields.
  - `toInspectionDraft()` reverse conversion with documented lossy fields.
  - JSON compatibility: existing format preserved; `property_data` key is additive.
  - 5 transition invariant tests defined.
  - Rollback plan: < 1 day effort.
- `02-01-UNIVERSAL-FIELDS.md` Section 5: Backward compatibility mapping table (3 direct 1:1, 5 new fields).
- `02-01-SHARED-FIELDS.md` Section 7: yearBuilt type change (required -> nullable) documented.

### Criterion 7: Schema versioning strategy defined

**Status**: PASS

**Evidence**:
- `02-02-VERSIONING.md`: Complete versioning strategy.
  - `PropertyData.schemaVersion` integer field starting at 1.
  - Version bump trigger matrix (6 change types that require bumps, 4 that do not).
  - Forward compatibility: unknown keys preserved, higher version handled gracefully.
  - Backward compatibility: `PropertyDataMigrations` registry with sequential chain pattern.
  - Migration design constraints: pure functions, sequential application, idempotent-safe.
  - Testing strategy: unit tests for migrations, round-trip tests.

### Criterion 8: Schema document written as Dart model specification

**Status**: PASS

**Evidence**:
- All schema documents include complete Dart class specifications:
  - `02-01-UNIVERSAL-FIELDS.md`: Full `UniversalPropertyFields` class with constructor, fields, toJson/fromJson, copyWith.
  - `02-01-SHARED-FIELDS.md`: Full `SharedBuildingSystemFields` class.
  - `02-01-RATING-SCALE.md`: Full `RatingScale` enum with extension methods.
  - `02-02-PROPERTY-DATA.md`: Full `PropertyData` class with all helpers.
  - `02-02-VERSIONING.md`: `PropertyDataMigrations` abstract class.
  - `02-03-FORM-DATA-KEYS.md`: `FormDataKeys` abstract class with 333 constants.
- Spec Appendix A lists 7 new classes/files + 5 modified existing classes.

### Summary Table

| # | Success Criterion | Status | Primary Evidence |
|---|-------------------|--------|------------------|
| 1 | Master JSON schema with shared namespace | PASS | 02-01, 02-02 |
| 2 | Per-form namespaces | PASS | 02-02, 02-03 |
| 3 | Field-to-schema mapping document | PASS | SCHEMA_MAPPING.md |
| 4 | Validation rules per field | PASS | 02-05 Section 1 |
| 5 | Branching logic support | PASS | 02-04 |
| 6 | Backward compatibility spec | PASS | 02-02-MIGRATION.md |
| 7 | Schema versioning strategy | PASS | 02-02-VERSIONING.md |
| 8 | Dart model specification | PASS | 02-01, 02-02, 02-03 |

**Overall Phase 2 Verdict**: ALL 8 SUCCESS CRITERIA PASS.

---

## 3. Gap Analysis

### 3.1 Unmapped Fields

| ID | Gap | Severity | Status | Remediation |
|----|-----|----------|--------|-------------|
| GAP-FGS | FGS Subsidence Incident Report | N/A | Formally descoped | Not an inspection form; geologist-facing. Decision made in Phase 1 (01-03). |
| GAP-HUD | HUD Report form type | Low | Not a form type | Rating scale mappings documented in 02-01-RATING-SCALE.md. HUD is referenced in FIELD_INVENTORY Section 5 for rating normalization but is not one of the 7 form types. If HUD becomes a form type in the future, its ingestion/emission tables are already designed. |

**Result**: Zero unmapped fields from the 7 in-scope form types. All ~486 fields accounted for in SCHEMA_MAPPING.md.

### 3.2 Known Data Gaps (Inherited from Phase 1)

| ID | Gap | Severity | Impact on Schema | Remediation |
|----|-----|----------|-----------------|-------------|
| GAP-01 | WDO form (FDACS-13645) not in docs/ | High | Schema complete -- all 51 fields mapped from retrieved form | Download local copy for reference | **Phase 3 prerequisite** |
| GAP-03 | Sinkhole page 1 missing | High | 8 inferred fields all map to universal/shared -- low schema risk | Obtain complete form from Citizens | **Phase 4 prerequisite** (before Sinkhole impl) |
| GAP-04 | No Mold Assessment template | High | 21 fields based on statutory knowledge -- schema may need additions | Source MRSA-compliant template from DBPR | **Phase 6 prerequisite** (before Mold impl) |
| GAP-05 | Insurance variant PDFs not analyzed | Medium | May contain different field layouts for 4-Point | Analyze citizens4point.pdf, statefarm4point.pdf when tools available | **Phase 10** (testing & polish) |
| GAP-06 | Sinkhole form from 2012 | Medium | Schema extensible via List<Map> for checklist items | Verify with Citizens for newer version | **Phase 4 prerequisite** |
| GAP-07 | 4point50.doc not analyzed | Low | Likely a variant; primary form (Insp4pt 03-25) fully mapped | Convert and compare | **Phase 10** (testing & polish) |

### 3.3 Schema Design Risks

| Risk | Severity | Mitigation | Owner |
|------|----------|------------|-------|
| General Inspection checkpoint counts may be incomplete for 6 rule-derived sections | Medium | `List<Map>` storage allows adding items without schema changes. When complete templates are obtained, checkpoint lists can expand. | Phase 8 |
| Mold Assessment fields based on statutory knowledge, not verified template | Medium | All fields flagged as "Statutory (unverified)" in FIELD_INVENTORY. External verification needed before Phase 7. | Phase 7 |
| 333 constants in single FormDataKeys class | Low | Organized by prefix; IDE autocomplete works well. Can split into per-form classes if needed. | Phase 3 |
| Unknown FormType codes silently dropped during deserialization | Low | Documented trade-off in 02-02-VERSIONING.md. Can add `_unknownFormData` field if cross-version sync is critical. | Phase 10 |
| HUD Y/N vs S/U collapse in RatingScale normalization | Low | Original values preserved in formData. PDF output uses formData, not RatingScale. | N/A |
| 4-Point Inspector Work Phone mapped to shared.inspectorPhone despite 4-Point not being in the shared overlap matrix | Low | The phone field on 4-Point certification maps naturally to the shared inspector contact group. Per-form usage documented. | Phase 4 |

### 3.4 Phase 3 Recommendations

1. **Implement FormType enum extension**: Add `wdo`, `sinkholeInspection`, `moldAssessment`, `generalInspection` values before any schema code.
2. **Implement PropertyData class first**: Foundation for all other changes. Verify with round-trip tests against InspectionDraft.
3. **Implement FormDataKeys constants**: Start with the 3 existing form types (111 + 15 + 16 = 142 constants) and add new forms incrementally.
4. **Add RequiredPhotoCategory values**: 20 new values for the 4 new form types.
5. **Extend canonicalBranchFlags**: From 5 to 37 entries.
6. **Verify General Inspection checkpoint lists**: Obtain complete fullinspection.doc template to confirm checkpoint items for rule-derived sections.
7. **Source Mold Assessment template**: Obtain MRSA-compliant template from DBPR before implementing Phase 7.

---

## 4. Cross-Form Validation Rules

### 4.1 Cross-Field Validations

| Rule | Fields Involved | Enforcement |
|------|----------------|-------------|
| Signature date >= Inspection date | `shared.signatureDate`, `universal.inspectionDate` | `signatureDate >= inspectionDate` |
| Mold end date >= start date | `universal.inspectionDate`, `mold.header.assessmentEndDate` | End date >= start date when present |
| Year built <= current year + 1 | `shared.yearBuilt` | Range validation |
| Roof age + year built <= current year + tolerance | `shared.roofAge`, `shared.yearBuilt` | Advisory warning, not blocking |

### 4.2 Mutex Validations

| Rule | Fields | Form |
|------|--------|------|
| WDO findings: noVisibleSigns XOR visibleEvidence | `wdo.findings.noVisibleSigns`, `wdo.findings.visibleEvidence` | WDO |
| WDO treatment method: wholeStructure XOR spotTreatment | `wdo.treatment.methodWholeStructure`, `wdo.treatment.methodSpotTreatment` | WDO |
| WDO visible evidence requires at least one sub-check | `wdo.findings.{liveWdo,evidenceOfWdo,damageByWdo}` | WDO |
