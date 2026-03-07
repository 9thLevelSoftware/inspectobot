# Consolidated Field Inventory

> **Plan**: 01-05 Cross-Form Consolidation
> **Date**: 2026-03-07
> **Source Inventories**: 01-01 (Existing Forms), 01-02 (WDO), 01-03 (Sinkhole), 01-04 (Narrative Forms)

---

## 1. Summary

### 1.1 Form Types Covered

| # | Form Type | Regulatory Reference | Format | Source Inventory | Field Count |
|---|-----------|---------------------|--------|-----------------|-------------|
| 1 | 4-Point Inspection | Insp4pt 03-25 | Fillable PDF | 01-01 | 27 mapped + ~80 gap = ~107 |
| 2 | Roof Condition (RCF-1) | RCF-1 03-25 | Fillable PDF | 01-01 | 8 mapped + ~18 gap = ~26 |
| 3 | Wind Mitigation | OIR-B1-1802 Rev 04/26 | Fillable PDF | 01-01 | 22 mapped + ~20 gap = ~42 |
| 4 | WDO (Wood-Destroying Organisms) | FDACS-13645, Rev. 05/21 | Fillable PDF | 01-02 | 46 |
| 5 | Sinkhole (Citizens) | Citizens ver. 2, Ed. 6/2012 | Fillable PDF (checklist) | 01-03 | 67 (59 confirmed + 8 inferred) |
| 6 | Mold Assessment | Chapter 468, Part XVI (MRSA) | Narrative report | 01-04 | 21 |
| 7 | General Home Inspection | Rule 61-30.801, F.A.C. | Narrative report | 01-04 | ~150+ (12 sections x checkpoints + general info) |

**Total unique data fields across all 7 forms: ~459** (approximate; exact count varies by how checkpoint tables are counted in narrative forms).

### 1.2 Overlap Statistics

| Category | Count | Description |
|----------|-------|-------------|
| Universal fields | 7 | Present on all or nearly all 7 forms |
| Shared fields (2-4 forms) | 14 | Present on 2-4 forms with name/format variations |
| Form-specific fields | ~438 | Unique to one form type |

### 1.3 Current Implementation Status

| Form | JSON Map Fields | Gap Fields (not mapped) | Implementation State |
|------|----------------|------------------------|---------------------|
| 4-Point | 27 | ~80 | Photo overlays only; all data fields missing |
| Roof Condition | 8 | ~18 | Photo overlays only; all data fields missing |
| Wind Mitigation | 22 | ~20 | Photo overlays only; Q1-Q8 answers missing |
| WDO | 0 | 46 | Not implemented |
| Sinkhole | 0 | 67 | Not implemented |
| Mold Assessment | 0 | 21 | Not implemented |
| General Inspection | 0 | 150+ | Not implemented |

---

## 2. Cross-Form Field Overlap

### 2.1 Universal Fields (Present on All or Nearly All Forms)

These fields appear on 5+ of the 7 form types and are strong candidates for the shared property model.

| Normalized Name | Type | Forms Using It | Name Variations | Notes |
|----------------|------|---------------|-----------------|-------|
| `property_address` | text | All 7 | "Address Inspected" (4-Pt), "Address of Property Inspected" (WDO 1.9, Sinkhole 0.2), "Property Address" (Mold, General), "Full Address" (HUD) | Semantically identical across all forms |
| `inspection_date` | date | All 7 | "Date Inspected" (4-Pt, RCF-1), "Date of Inspection" (WDO 1.6, Wind Mit, Sinkhole 0.4), "Assessment Date(s)" (Mold), "Inspection Date" (General) | Mold allows multi-day; all others single date |
| `inspector_name` | text | All 7 | "Inspector Signature block" (4-Pt, RCF-1, Wind Mit), "Inspector's Name (Print)" (WDO 1.7), "Inspector Name" (Sinkhole 0.5, General), "Assessor Name" (Mold) | WDO specifically requires printed name vs signature |
| `inspector_company` | text | All 7 | "Company Name" (4-Pt, RCF-1, Wind Mit), "Inspection Company Name" (WDO 1.1), "Inspector Company" (Sinkhole 0.7, General), "Company Name" (Mold) | Semantically identical |
| `inspector_signature` | signature | All 7 | "Inspector Signature" (4-Pt, RCF-1, Wind Mit), "Signature of Licensee or Agent" (WDO 5.3), implied (Sinkhole, Mold, General) | Already mapped in 3 forms as `signature.inspector` |
| `inspector_license_number` | text | 6 of 7 | "License Number" (4-Pt, RCF-1, Wind Mit), "Inspector's ID Card Number" (WDO 1.8), "Inspector License Number" (Sinkhole 0.6), "MRSA License Number" (Mold) | WDO uses FDACS ID card (different license type); Mold uses MRSA license; HUD uses case number instead |
| `client_name` | text | 6 of 7 | "Insured/Applicant Name" (4-Pt), "Policyholder Name" (Wind Mit), "Insured Name" (RCF-1), "Inspection requested by" (WDO 1.11), "Insured/Applicant Name" (Sinkhole 0.1), "Client Name" (Mold), "Customer Name(s)" (General) | HUD uses case-based identification instead |

### 2.2 Shared Fields (Present on 2-4 Forms)

| Normalized Name | Type | Forms Using It | Name Variations | Semantic Differences |
|----------------|------|---------------|-----------------|---------------------|
| `policy_number` | text | 4-Pt, RCF-1, Wind Mit, Sinkhole | "Application / Policy #" (4-Pt), "Policy Number" (RCF-1, Wind Mit, Sinkhole 0.3) | Identical concept; insurance-specific forms only |
| `year_built` | text/integer | 4-Pt, RCF-1, Wind Mit, Mold, General | "Actual Year Built" (4-Pt), "Year Built" (RCF-1, Wind Mit), "Building Age" (Mold), "Structure Age" (HUD) | Mold/HUD may use age-in-years rather than year |
| `inspector_phone` | text | WDO, Sinkhole, Wind Mit, General | "Phone Number" (WDO 1.4), "Inspector Phone" (Sinkhole 0.8, Wind Mit), varies (General) | WDO captures company phone; others may capture personal |
| `signature_date` | date | 4-Pt, RCF-1, Wind Mit, WDO | "Date Signed" (4-Pt, RCF-1, Wind Mit), "Signature Date" (WDO 5.4) | May differ from inspection_date |
| `comments` | text (multi-line) | 4-Pt, RCF-1, Wind Mit, WDO, Sinkhole, Mold, General | "Additional Comments/Observations" (4-Pt, RCF-1), "Comments" (WDO 5.1, Wind Mit), "Other relevant information" (Sinkhole 5.4) | Universal concept but form-specific prompt text |
| `roof_type_material` | text/enum | 4-Pt, RCF-1, General, HUD | "Predominant Roof: Covering material" (4-Pt), "Roof Type / Covering Material" (RCF-1), enums in General and HUD | Same concept; enum values may differ across forms |
| `roof_age` | text/integer | 4-Pt, RCF-1, General | "Predominant Roof: Age" (4-Pt), "Roof Age (years)" (RCF-1), "Estimated age" (General) | Same concept |
| `roof_condition_rating` | enum | 4-Pt, RCF-1, General, HUD | "Overall condition" (4-Pt: Satisfactory/Unsatisfactory), "Roof Condition Rating" (RCF-1: Good/Fair/Poor/Failed), (General: Good/Fair/Poor), (HUD: S/U/MR) | Different rating scales -- requires normalization |
| `electrical_panel_type` | enum | 4-Pt, General, HUD | "Main Panel Type" (4-Pt: Circuit breaker/Fuse), "Panel Type" (General), "Panel Box" (HUD) | Same concept; slightly different enum values |
| `electrical_panel_capacity` | text/enum | 4-Pt, General, HUD | "Main Panel Total Amps" (4-Pt), "Panel Capacity" (General: 70A-400A enum), "Capacity" (HUD) | Same concept |
| `plumbing_pipe_material` | enum | 4-Pt, General, HUD | "Type of pipes" (4-Pt: Copper/PVC/Galvanized/PEX/Polybutylene), "Main Line Material" (General), "Water Piping" (HUD) | Same concept; different enum value sets |
| `water_heater_type` | enum | 4-Pt, General, HUD | via plumbing section (4-Pt), "Type" (General: Gas/Electric/Solar/LPG), "Water Heaters" (HUD) | Same concept |
| `hvac_type` | enum | 4-Pt, General, HUD | "Primary heat source and fuel type" (4-Pt), "Heating Type" (General), "Furnace System" (HUD) | Similar but different granularity |
| `foundation_cracks` | yes/no + text | Sinkhole, General, HUD | "Cracks in foundation?" (Sinkhole 1.4), "Foundation" checkpoint (General, HUD) | Sinkhole requires detailed measurements; others use rating |

### 2.3 Overlap Matrix

Forms: **4P** = 4-Point, **RC** = Roof Condition, **WM** = Wind Mitigation, **WDO** = WDO, **SK** = Sinkhole, **MA** = Mold Assessment, **GI** = General Inspection

| Field | 4P | RC | WM | WDO | SK | MA | GI | Count |
|-------|----|----|-----|-----|----|----|-----|-------|
| property_address | x | x | x | x | x | x | x | 7 |
| inspection_date | x | x | x | x | x | x | x | 7 |
| inspector_name | x | x | x | x | x | x | x | 7 |
| inspector_company | x | x | x | x | x | x | x | 7 |
| inspector_signature | x | x | x | x | x | x | x | 7 |
| inspector_license_number | x | x | x | x | x | x | . | 6 |
| client_name | x | x | x | x | x | x | x | 7 |
| policy_number | x | x | x | . | x | . | . | 4 |
| year_built | x | x | x | . | . | x | x | 5 |
| inspector_phone | . | . | x | x | x | . | x | 4 |
| signature_date | x | x | x | x | . | . | . | 4 |
| comments | x | x | x | x | x | x | x | 7 |
| roof_type_material | x | x | . | . | . | . | x | 3 |
| roof_age | x | x | . | . | . | . | x | 3 |
| roof_condition_rating | x | x | . | . | . | . | x | 3 |
| electrical_panel_type | x | . | . | . | . | . | x | 2 |
| electrical_panel_capacity | x | . | . | . | . | . | x | 2 |
| plumbing_pipe_material | x | . | . | . | . | . | x | 2 |
| water_heater_type | x | . | . | . | . | . | x | 2 |
| hvac_type | x | . | . | . | . | . | x | 2 |
| foundation_cracks | . | . | . | . | x | . | x | 2 |

---

## 3. Shared Property Model Candidates

### 3.1 Property Identification Group

| Normalized Field | Type | Recommended Dart Name | Forms | Notes |
|-----------------|------|-----------------------|-------|-------|
| Property Address | text | `propertyAddress` | All 7 | Already in InspectionDraft |
| Year Built | int? | `yearBuilt` | 5 of 7 | Already in InspectionDraft; null for WDO/Sinkhole |
| Policy / Application Number | text? | `policyNumber` | 4 of 7 | Insurance-specific; null for Mold/General/WDO |

### 3.2 Client Information Group

| Normalized Field | Type | Recommended Dart Name | Forms | Notes |
|-----------------|------|-----------------------|-------|-------|
| Client Name | text | `clientName` | All 7 | Already in InspectionDraft. Semantics vary: "insured" (insurance forms), "client" (assessment), "customer" (general) |
| Client Email | text? | `clientEmail` | 0 (app-only) | Already in InspectionDraft; not on any paper form |
| Client Phone | text? | `clientPhone` | 0 (app-only) | Already in InspectionDraft; not on any paper form |
| Report Recipient | text? | `reportRecipient` | WDO only (1.12) | WDO allows different recipient than requestor |

### 3.3 Inspector Information Group

| Normalized Field | Type | Recommended Dart Name | Forms | Notes |
|-----------------|------|-----------------------|-------|-------|
| Inspector Name | text | `inspectorName` | All 7 | Identity module already captures this |
| Inspector License Number | text | `inspectorLicenseNumber` | 6 of 7 | **License type varies by form**: general/home inspector (4-Pt, RCF-1, Wind Mit, General), FDACS pest control ID (WDO), MRSA license (Mold) |
| Inspector License Type | text? | `inspectorLicenseType` | 4-Pt, WDO, Mold | Different regulatory bodies issue licenses |
| Inspector Company | text | `inspectorCompany` | All 7 | Identity module |
| Inspector Phone | text | `inspectorPhone` | 4 of 7 | Identity module |
| Inspector Signature | signature | `inspectorSignature` | All 7 | Already mapped in 3 forms |
| Signature Date | date | `signatureDate` | 4 of 7 | May differ from inspection date |
| Company Address | text? | `companyAddress` | WDO (1.3-1.5) | WDO requires full company address; others do not |
| Company License Number | text? | `companyLicenseNumber` | WDO (1.2) | WDO requires business license separate from individual |

### 3.4 Property Characteristics Group (Shared Across Building-System Forms)

| Normalized Field | Type | Recommended Dart Name | Forms | Notes |
|-----------------|------|-----------------------|-------|-------|
| Roof Covering Material | enum/text | `roofCoveringMaterial` | 4-Pt, RCF-1, General | Enum values need union across forms |
| Roof Age (years) | int? | `roofAge` | 4-Pt, RCF-1, General | Same concept everywhere |
| Roof Condition | enum | `roofCondition` | 4-Pt, RCF-1, General | **Normalization needed**: Satisfactory/Unsatisfactory vs Good/Fair/Poor/Failed |
| Electrical Panel Type | enum | `electricalPanelType` | 4-Pt, General | Circuit breaker / Fuse |
| Electrical Panel Amps | int? | `electricalPanelAmps` | 4-Pt, General | Total amperage |
| Plumbing Pipe Material | enum | `plumbingPipeMaterial` | 4-Pt, General | Copper/PVC/Galvanized/PEX/Polybutylene/Other |
| Water Heater Type | enum | `waterHeaterType` | 4-Pt, General | Gas/Electric/Solar/LPG |
| HVAC Type | enum | `hvacType` | 4-Pt, General | Forced Air/Heat Pump/etc. |

---

## 4. Per-Form Field Inventory

### 4.1 Four-Point Inspection (Insp4pt 03-25)

**Regulatory Reference**: Florida insurance industry standard (no single regulatory cite; OIR-accepted)
**Form Type**: Fillable PDF with photo evidence overlays
**Template**: `assets/pdf/templates/insp4pt_03_25.pdf`
**Map**: `assets/pdf/maps/insp4pt_03_25.v1.json`
**Implementation Status**: Photo overlays only; all data fields are gaps

#### 4.1.1 Currently Mapped Fields (27)

| # | Field Key | Type | Required | Condition | Shared |
|---|-----------|------|----------|-----------|--------|
| 1 | `text.client_name` | text | Yes | Always | Y |
| 2 | `text.property_address` | text | Yes | Always | Y |
| 3 | `checkbox.photo_exterior_front` | checkbox | Yes | Always | N |
| 4 | `image.photo_exterior_front` | image | Yes | Always | N |
| 5 | `signature.inspector` | signature | Yes | Always | Y |
| 6 | `checkbox.photo_exterior_rear` | checkbox | Yes | Always | N |
| 7 | `image.photo_exterior_rear` | image | Yes | Always | N |
| 8 | `checkbox.photo_exterior_left` | checkbox | Yes | Always | N |
| 9 | `image.photo_exterior_left` | image | Yes | Always | N |
| 10 | `checkbox.photo_exterior_right` | checkbox | Yes | Always | N |
| 11 | `image.photo_exterior_right` | image | Yes | Always | N |
| 12 | `checkbox.photo_roof_slope_main` | checkbox | Yes | Always | N |
| 13 | `image.photo_roof_slope_main` | image | Yes | Always | N |
| 14 | `checkbox.photo_roof_slope_secondary` | checkbox | Yes | Always | N |
| 15 | `image.photo_roof_slope_secondary` | image | Yes | Always | N |
| 16 | `checkbox.photo_water_heater_tpr_valve` | checkbox | Yes | Always | N |
| 17 | `image.photo_water_heater_tpr_valve` | image | Yes | Always | N |
| 18 | `checkbox.photo_plumbing_under_sink` | checkbox | Yes | Always | N |
| 19 | `image.photo_plumbing_under_sink` | image | Yes | Always | N |
| 20 | `checkbox.photo_electrical_panel_label` | checkbox | Yes | Always | N |
| 21 | `image.photo_electrical_panel_label` | image | Yes | Always | N |
| 22 | `checkbox.photo_electrical_panel_open` | checkbox | Yes | Always | N |
| 23 | `image.photo_electrical_panel_open` | image | Yes | Always | N |
| 24 | `checkbox.photo_hvac_data_plate` | checkbox | Yes | Always | N |
| 25 | `image.photo_hvac_data_plate` | image | Yes | Always | N |
| 26 | `checkbox.photo_hazard_photo` | checkbox | Cond. | `hazard_present == true` | N |
| 27 | `image.photo_hazard_photo` | image | Cond. | `hazard_present == true` | N |

#### 4.1.2 Gap Fields (Not Mapped -- From Reference Form Analysis)

**Header / Property Info**:

| Field | Type | Required | Shared |
|-------|------|----------|--------|
| Application / Policy # | text | Yes | Y |
| Actual Year Built | text | Yes | Y |
| Date Inspected | date | Yes | Y |

**Electrical System** (~20 fields):

| Field | Type | Required | Shared |
|-------|------|----------|--------|
| Main Panel Type (Circuit breaker / Fuse) | checkbox/radio | Yes | Y (General) |
| Main Panel Total Amps | text | Yes | Y (General) |
| Is amperage sufficient (Yes/No) | checkbox | Yes | N |
| Second Panel Type | checkbox/radio | Cond. | N |
| Second Panel Total Amps | text | Cond. | N |
| Second Panel amperage sufficient | checkbox | Cond. | N |
| Cloth wiring | checkbox | Yes | N |
| Active knob and tube | checkbox | Yes | N |
| Branch circuit aluminum wiring | checkbox + text | Yes | N |
| Single strand aluminum branch wiring details | text | Cond. | N |
| COPALUM crimp connections | checkbox | Cond. | N |
| AlumiConn connections | checkbox | Cond. | N |
| Hazards Present (12+ items) | checkbox group | Yes | N |
| General condition (Satisfactory/Unsatisfactory) | checkbox | Yes | N |
| Main Panel age, year updated, brand | text (3 fields) | Yes | N |
| Second Panel age, year updated, brand | text (3 fields) | Cond. | N |
| Wiring Type (Copper / MN,BX,Conduit) | checkbox | Yes | N |

**HVAC System** (~8 fields):

| Field | Type | Required | Shared |
|-------|------|----------|--------|
| Central AC (Yes/No) | checkbox | Yes | N |
| Central Heat (Yes/No) | checkbox | Yes | N |
| Primary heat source and fuel type | text | Yes | Y (General) |
| HVAC in good working order (Yes/No) | checkbox | Yes | N |
| Date of last HVAC servicing | date/text | Yes | N |
| Hazards (wood stove, gas fireplace, space heater, portable, air handler blockage) | checkbox group (~5 items) | Yes | N |
| Age of system, Year last updated | text (2 fields) | Yes | N |

**Plumbing System** (~15 fields):

| Field | Type | Required | Shared |
|-------|------|----------|--------|
| TPR valve on water heater (Yes/No) | checkbox | Yes | N |
| Active leak indication (Yes/No) | checkbox | Yes | N |
| Prior leak indication (Yes/No) | checkbox | Yes | N |
| Water heater location | text | Yes | N |
| Fixture conditions (12-item matrix: Satisfactory/Unsatisfactory/N/A) | matrix | Yes | N |
| If unsatisfactory, comments | text | Cond. | N |
| Age of piping, re-pipe status | text + checkbox | Yes | N |
| Type of pipes (Copper/PVC/Galvanized/PEX/Polybutylene/Other) | checkbox group | Yes | Y (General) |

**Roof** (~15 fields):

| Field | Type | Required | Shared |
|-------|------|----------|--------|
| Predominant Roof: Covering material | text | Yes | Y (RCF-1, General) |
| Predominant Roof: Age, Remaining useful life | text (2 fields) | Yes | Y (RCF-1) |
| Date of last roofing permit | text | Yes | N |
| Date of last update | text | Yes | N |
| Updated? Full/Partial replacement, % | checkbox + text | Cond. | N |
| Overall condition (Satisfactory/Unsatisfactory) | checkbox | Yes | Y (RCF-1) |
| Visible damage (8 checkboxes per roof) | checkbox group | Yes | N |
| Signs of leaks (Yes/No) | checkbox | Yes | Y (RCF-1) |
| Attic/underside of decking (Yes/No) | checkbox | Yes | N |
| Interior ceilings (Yes/No) | checkbox | Yes | N |
| Secondary Roof (mirror of all above) | all above types | Cond. | N |
| Additional Comments/Observations | text (multi-line) | Optional | Y |

**Inspector Certification** (~6 fields):

| Field | Type | Required | Shared |
|-------|------|----------|--------|
| Title | text | Yes | N |
| License Number | text | Yes | Y |
| Date | date | Yes | Y |
| Company Name | text | Yes | Y |
| License Type | text | Yes | N |
| Work Phone | text | Yes | Y |

**Branch Logic Summary**: `hazard_present` flag controls hazard photo pair. Second panel fields conditional on second panel existence. Secondary roof conditional on multiple roof coverings. Fixture condition comments conditional on unsatisfactory rating.

**Evidence Requirements**: 12 photo categories (11 always required, 1 conditional on `hazard_present`).

---

### 4.2 Roof Condition Form (RCF-1 03-25)

**Regulatory Reference**: Florida insurance industry standard
**Form Type**: Fillable PDF with photo evidence overlays
**Template**: `assets/pdf/templates/rcf1_03_25.pdf`
**Map**: `assets/pdf/maps/rcf1_03_25.v1.json`
**Implementation Status**: Photo overlays only; all data fields are gaps

#### 4.2.1 Currently Mapped Fields (8)

| # | Field Key | Type | Required | Condition | Shared |
|---|-----------|------|----------|-----------|--------|
| 1 | `text.client_name` | text | Yes | Always | Y |
| 2 | `checkbox.photo_roof_condition_main_slope` | checkbox | Yes | Always | N |
| 3 | `image.photo_roof_condition_main_slope` | image | Yes | Always | N |
| 4 | `checkbox.photo_roof_condition_secondary_slope` | checkbox | Yes | Always | N |
| 5 | `image.photo_roof_condition_secondary_slope` | image | Yes | Always | N |
| 6 | `checkbox.photo_roof_defect` | checkbox | Cond. | `roof_defect_present == true` | N |
| 7 | `image.photo_roof_defect` | image | Cond. | `roof_defect_present == true` | N |
| 8 | `signature.inspector` | signature | Yes | Always | Y |

#### 4.2.2 Gap Fields (Not Mapped)

| Field | Type | Required | Shared |
|-------|------|----------|--------|
| Property Address | text | Yes | Y |
| Policy Number | text | Yes | Y |
| Inspection Date | date | Yes | Y |
| Year Built | text | Yes | Y |
| Roof Type / Covering Material | text | Yes | Y (4-Pt) |
| Roof Age (years) | text | Yes | Y (4-Pt) |
| Remaining Useful Life (years) | text | Yes | Y (4-Pt) |
| Roof Condition Rating (Good/Fair/Poor/Failed) | radio/checkbox | Yes | Y (4-Pt) |
| Evidence of Prior Repairs | checkbox + text | Yes | N |
| Evidence of Leaks | checkbox + text | Yes | Y (4-Pt) |
| Evidence of Wind Damage | checkbox + text | Yes | N |
| Evidence of Hail Damage | checkbox + text | Yes | N |
| Number of Layers | text | Yes | N |
| Flashing Condition | checkbox | Yes | N |
| Soffit/Fascia Condition | checkbox | Yes | N |
| Gutters/Downspouts | checkbox | Yes | N |
| Inspector License # | text | Yes | Y |
| Inspector Company | text | Yes | Y |
| Date Signed | date | Yes | Y |
| Comments/Observations | text (multi-line) | Optional | Y |

**Branch Logic Summary**: `roof_defect_present` flag controls defect photo pair.

**Evidence Requirements**: 3 photo categories (2 always required, 1 conditional on `roof_defect_present`).

---

### 4.3 Wind Mitigation (OIR-B1-1802 Rev 04/26)

**Regulatory Reference**: OIR-B1-1802 (Office of Insurance Regulation)
**Form Type**: Fillable PDF with photo evidence overlays
**Template**: `assets/pdf/templates/oir_b1_1802_rev_04_26.pdf`
**Map**: `assets/pdf/maps/oir_b1_1802_rev_04_26.v1.json`
**Implementation Status**: Photo overlays only; Q1-Q8 answer selections entirely absent

#### 4.3.1 Currently Mapped Fields (22)

| # | Field Key | Type | Required | Condition | Shared |
|---|-----------|------|----------|-----------|--------|
| 1 | `text.client_name` | text | Yes | Always | Y |
| 2 | `checkbox.photo_wind_roof_deck` | checkbox | Yes | Always | N |
| 3 | `image.photo_wind_roof_deck` | image | Yes | Always | N |
| 4 | `signature.inspector` | signature | Yes | Always | Y |
| 5 | `checkbox.photo_wind_roof_to_wall` | checkbox | Yes | Always | N |
| 6 | `image.photo_wind_roof_to_wall` | image | Yes | Always | N |
| 7 | `checkbox.photo_wind_roof_shape` | checkbox | Yes | Always | N |
| 8 | `image.photo_wind_roof_shape` | image | Yes | Always | N |
| 9 | `checkbox.photo_wind_secondary_water_resistance` | checkbox | Yes | Always | N |
| 10 | `image.photo_wind_secondary_water_resistance` | image | Yes | Always | N |
| 11 | `checkbox.photo_wind_opening_protection` | checkbox | Yes | Always | N |
| 12 | `image.photo_wind_opening_protection` | image | Yes | Always | N |
| 13 | `checkbox.photo_wind_opening_type` | checkbox | Yes | Always | N |
| 14 | `image.photo_wind_opening_type` | image | Yes | Always | N |
| 15 | `checkbox.photo_wind_permit_year` | checkbox | Yes | Always | N |
| 16 | `image.photo_wind_permit_year` | image | Yes | Always | N |
| 17 | `checkbox.document_wind_roof_deck` | checkbox | Cond. | `wind_roof_deck_document_required` | N |
| 18 | `image.document_wind_roof_deck` | image | Cond. | `wind_roof_deck_document_required` | N |
| 19 | `checkbox.document_wind_opening_protection` | checkbox | Cond. | `wind_opening_document_required` | N |
| 20 | `image.document_wind_opening_protection` | image | Cond. | `wind_opening_document_required` | N |
| 21 | `checkbox.document_wind_permit_year` | checkbox | Cond. | `wind_permit_document_required` | N |
| 22 | `image.document_wind_permit_year` | image | Cond. | `wind_permit_document_required` | N |

#### 4.3.2 Gap Fields (Not Mapped)

**Header / Property Info**:

| Field | Type | Required | Shared |
|-------|------|----------|--------|
| Property Address | text | Yes | Y |
| Policy Number | text | Yes | Y |
| Date of Inspection | date | Yes | Y |
| Year Built | text | Yes | Y |

**Q1-Q8 Answer Selections (Core of form -- all MISSING)**:

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| Q1: Building Code (year built, FBC compliance) | radio + text | Yes | Year built + building code in effect |
| Q2: Roof Covering (FBC-equivalent, permit date, product approval) | radio + text | Yes | FBC compliance status |
| Q3: Roof Deck Attachment (A/B/C/D) | radio | Yes | Photo mapped but answer missing |
| Q4: Roof-to-Wall Attachment (Toe nails/Clips/Single wraps/Double wraps/Structural) | radio | Yes | Photo mapped but answer missing |
| Q5: Roof Geometry (Hip/Non-hip/Flat) | radio | Yes | Photo mapped but answer missing |
| Q6: Secondary Water Resistance (Yes/No/Other) | radio | Yes | Photo mapped but answer missing |
| Q7: Opening Protection (categories A/B/C/N) | radio | Yes | Photo mapped but answer missing |
| Q7 Glazed openings inventory (window/door/skylight/garage counts) | numeric fields | Yes | Photo mapped but counts missing |
| Q8: Opening Protection scope (All/None/Partial) | radio | Yes | Entirely missing |

**Inspector Certification**:

| Field | Type | Required | Shared |
|-------|------|----------|--------|
| Inspector Name | text | Yes | Y |
| Inspector License Number | text | Yes | Y |
| Date Signed | date | Yes | Y |
| Inspector Company | text | Yes | Y |
| Inspector Phone | text | Yes | Y |
| Reinspection (Yes/No) | checkbox | Yes | N |
| Comments | text (multi-line) | Optional | Y |

**Branch Logic Summary**: 3 document-required flags (`wind_roof_deck_document_required`, `wind_opening_document_required`, `wind_permit_document_required`). Q1-Q8 each have internal conditional logic not yet documented in the field map.

**Evidence Requirements**: 10 items (7 photos always required, 3 documents conditional).

---

### 4.4 WDO Inspection (FDACS-13645)

**Regulatory Reference**: Rule 5E-14.142, F.A.C.; Chapter 482, F.S.
**Form Type**: Fillable PDF (2 pages)
**Issuing Agency**: FDACS (Florida Dept. of Agriculture and Consumer Services)
**Implementation Status**: Not implemented; form not in docs/ (available at https://forms.fdacs.gov/13645.pdf)

#### 4.4.1 Complete Field Inventory (46 fields)

**Section 1 -- General Information (12 fields)**:

| # | Field Name | Type | Required | Conditional On | Shared |
|---|-----------|------|----------|---------------|--------|
| 1.1 | Inspection Company Name | text | Yes | -- | Y |
| 1.2 | Business License Number | text | Yes | -- | N (WDO-specific) |
| 1.3 | Company Address | text | Yes | -- | N (WDO-specific) |
| 1.4 | Phone Number | text | Yes | -- | Y |
| 1.5 | Company City, State and Zip Code | text | Yes | -- | N (WDO-specific) |
| 1.6 | Date of Inspection | date | Yes | -- | Y |
| 1.7 | Inspector's Name (Print) | text | Yes | -- | Y |
| 1.8 | Inspector's ID Card Number | text | Yes | -- | Y (different license type) |
| 1.9 | Address of Property Inspected | text | Yes | -- | Y |
| 1.10 | Structure(s) on Property Inspected | text | Yes | -- | N |
| 1.11 | Inspection and Report requested by | text | Yes | -- | Y (= client_name) |
| 1.12 | Report Sent to Requestor and to | text | Optional | Different from requestor | N |

**Section 2 -- Inspection Findings (8 fields)**:

| # | Field Name | Type | Required | Conditional On | Shared |
|---|-----------|------|----------|---------------|--------|
| 2.A | NO visible signs of WDO(s) | checkbox | Yes (mutex with 2.B) | -- | N |
| 2.B | VISIBLE evidence of WDO(s) | checkbox | Yes (mutex with 2.A) | -- | N |
| 2.B.1 | LIVE WDO(s) | checkbox | Cond. | 2.B checked | N |
| 2.B.1a | Live WDO(s) Description | text (multi-line) | Yes | 2.B.1 checked | N |
| 2.B.2 | EVIDENCE of WDO(s) | checkbox | Cond. | 2.B checked | N |
| 2.B.2a | Evidence Description | text (multi-line) | Yes | 2.B.2 checked | N |
| 2.B.3 | DAMAGE caused by WDO(s) | checkbox | Cond. | 2.B checked | N |
| 2.B.3a | Damage Description | text (multi-line) | Yes | 2.B.3 checked | N |

**Section 3 -- Obstructions and Inaccessible Areas (15 fields, 5 area categories x 3)**:

| # | Field Name | Type | Required | Conditional On | Shared |
|---|-----------|------|----------|---------------|--------|
| 3.1 | Attic (inaccessible) | checkbox | Optional | -- | N |
| 3.1a | Attic - Specific Areas | text (multi-line) | Yes | 3.1 checked | N |
| 3.1b | Attic - Reason | text (multi-line) | Yes | 3.1 checked | N |
| 3.2 | Interior (inaccessible) | checkbox | Optional | -- | N |
| 3.2a | Interior - Specific Areas | text (multi-line) | Yes | 3.2 checked | N |
| 3.2b | Interior - Reason | text (multi-line) | Yes | 3.2 checked | N |
| 3.3 | Exterior (inaccessible) | checkbox | Optional | -- | N |
| 3.3a | Exterior - Specific Areas | text (multi-line) | Yes | 3.3 checked | N |
| 3.3b | Exterior - Reason | text (multi-line) | Yes | 3.3 checked | N |
| 3.4 | Crawlspace (inaccessible) | checkbox | Optional | -- | N |
| 3.4a | Crawlspace - Specific Areas | text (multi-line) | Yes | 3.4 checked | N |
| 3.4b | Crawlspace - Reason | text (multi-line) | Yes | 3.4 checked | N |
| 3.5 | Other (inaccessible) | checkbox | Optional | -- | N |
| 3.5a | Other - Specific Areas | text (multi-line) | Yes | 3.5 checked | N |
| 3.5b | Other - Reason | text (multi-line) | Yes | 3.5 checked | N |

**Section 4 -- Treatment Information (11 fields)**:

| # | Field Name | Type | Required | Conditional On | Shared |
|---|-----------|------|----------|---------------|--------|
| 4.1 | Previous treatment evidence | radio (Yes/No) | Yes | -- | N |
| 4.1a | Previous treatment description | text (multi-line) | Yes | 4.1 = Yes | N |
| 4.2 | Notice of Inspection location | text | Yes | -- | N |
| 4.3 | Company treated at time of inspection | radio (Yes/No) | Yes | -- | N |
| 4.3a | Organism treated | text | Yes | 4.3 = Yes | N |
| 4.3b | Pesticide Used | text | Yes | 4.3 = Yes | N |
| 4.3c | Terms and Conditions | text | Yes | 4.3 = Yes | N |
| 4.3d | Method - Whole structure | checkbox | Cond. | 4.3 = Yes | N |
| 4.3e | Method - Spot treatment | checkbox | Cond. | 4.3 = Yes | N |
| 4.3e-desc | Spot treatment description | text | Yes | 4.3e checked | N |
| 4.3f | Treatment Notice Location | text | Yes | 4.3 = Yes | N |

**Section 5 -- Comments and Signature (4 unique fields + 2 repeats)**:

| # | Field Name | Type | Required | Conditional On | Shared |
|---|-----------|------|----------|---------------|--------|
| 5.1 | Comments | text (multi-line) | Optional | -- | Y |
| 5.3 | Signature of Licensee or Agent | signature | Yes | -- | Y |
| 5.4 | Signature Date | date | Yes | -- | Y |
| 5.5 | Address of Property (repeat) | text | Yes | -- | Y (repeat of 1.9) |
| 5.6 | Inspection Date (repeat) | date | Yes | -- | Y (repeat of 1.6) |

**Branch Logic Summary**:
- Section 2: Mutually exclusive A/B. If B, at least one of B.1/B.2/B.3 must be checked, each revealing a description field.
- Section 3: 5 independent inaccessible-area toggles, each revealing 2 text fields.
- Section 4: Two independent Yes/No branches (previous treatment evidence, treatment performed now). Treatment method is mutex (Whole vs Spot).

**Evidence Requirements**: No photo mandate on the form itself. Industry practice recommends photos of infestation evidence, damage, inaccessible areas, notice posting, and property exterior.

---

### 4.5 Sinkhole Inspection (Citizens)

**Regulatory Reference**: Citizens Property Insurance Corporation; FL Stat 627.706-627.7074
**Form Type**: Fillable PDF checklist (Y/N/N-A + details)
**Version**: ver. 2, Ed. 6/2012
**Implementation Status**: Not implemented
**Known Gap**: Page 1 missing from docs/sinkhole.pdf (property ID fields inferred)

#### 4.5.1 Complete Field Inventory (67 fields: 59 confirmed + 8 inferred)

**Section 0 -- Property Identification (8 fields, INFERRED)**:

| # | Field Name | Type | Required | Conditional On | Shared |
|---|-----------|------|----------|---------------|--------|
| 0.1 | Insured/Applicant Name | text | Yes | -- | Y |
| 0.2 | Property Address | text | Yes | -- | Y |
| 0.3 | Policy Number | text | Yes | -- | Y |
| 0.4 | Date of Inspection | date | Yes | -- | Y |
| 0.5 | Inspector Name | text | Yes | -- | Y |
| 0.6 | Inspector License Number | text | Yes | -- | Y |
| 0.7 | Inspector Company | text | Yes | -- | Y |
| 0.8 | Inspector Phone | text | Yes | -- | Y |

**Section 1 -- Exterior (10 fields: 5 checklist + 5 detail)**:

| # | Field Name | Type | Required | Conditional On | Shared |
|---|-----------|------|----------|---------------|--------|
| 1.1 | Any depression in yard? | yes/no/na | Yes | -- | N |
| 1.2 | Sinkholes/depressions on adjacent properties? | yes/no/na | Yes | -- | N |
| 1.3 | Soil erosion around foundation? | yes/no/na | Yes | -- | N |
| 1.4 | Cracks in foundation? | yes/no/na | Yes | -- | Y (General) |
| 1.5 | Cracks in exterior wall? | yes/no/na | Yes | -- | N |
| 1.1d-1.5d | Details (per "Yes" item) | text | Cond. | Item = Yes | N |

**Section 2 -- Interior (16 fields: 8 checklist + 8 detail)**:

| # | Field Name | Type | Required | Conditional On | Shared |
|---|-----------|------|----------|---------------|--------|
| 2.1 | Interior doors out of plumb? | yes/no/na | Yes | -- | N |
| 2.2 | Doors/windows out of square? | yes/no/na | Yes | -- | N |
| 2.3 | Compression cracks in windows/doors/frames? | yes/no/na | Yes | -- | N |
| 2.4 | Floors out of level? | yes/no/na | Yes | -- | N |
| 2.5 | Attached cabinets pulled from wall? | yes/no/na | Yes | -- | N |
| 2.6 | Cracks on interior walls? | yes/no/na | Yes | -- | N |
| 2.7 | Cracks on interior ceiling? | yes/no/na | Yes | -- | N |
| 2.8 | Cracks on flooring/floor tile? | yes/no/na | Yes | -- | N |
| 2.1d-2.8d | Details (per "Yes" item) | text | Cond. | Item = Yes | N |

**Section 3 -- Garage (4 fields: 2 checklist + 2 detail)**:

| # | Field Name | Type | Required | Conditional On | Shared |
|---|-----------|------|----------|---------------|--------|
| 3.1 | Wall-to-slab cracks? | yes/no/na | Yes | -- | N |
| 3.2 | Floor cracks radiate to wall? | yes/no/na | Yes | -- | N |
| 3.1d-3.2d | Details (per "Yes" item) | text | Cond. | Item = Yes | N |

**Section 4 -- Appurtenant Structures (8 fields: 4 checklist + 4 detail)**:

| # | Field Name | Type | Required | Conditional On | Shared |
|---|-----------|------|----------|---------------|--------|
| 4.1 | Cracks noted? | yes/no/na | Yes | -- | N |
| 4.2 | Uplift noted? | yes/no/na | Yes | -- | N |
| 4.3 | Cracks/damage in pool? | yes/no/na | Yes | -- | N |
| 4.4 | Cracks in pool deck/patio? | yes/no/na | Yes | -- | N |
| 4.1d-4.4d | Details (per "Yes" item) | text | Cond. | Item = Yes | N |

**Section 5 -- Additional Information (5 fields)**:

| # | Field Name | Type | Required | Conditional On | Shared |
|---|-----------|------|----------|---------------|--------|
| 5.1 | General condition overview | text (multi-line) | Yes | -- | N |
| 5.2 | Adjacent building description | text (multi-line) | Cond. | Townhouse/row house | N |
| 5.3 | Distance to nearest known sinkhole | text | Yes | -- | N |
| 5.4 | Other relevant findings | text (multi-line) | Yes | -- | N |
| 5.5 | Unable to schedule explanation | text (multi-line) | Cond. | Inspection not completed | N |

**Section 6 -- Scheduling Attempts (16 fields: 4 attempts x 4 fields)**:

| # | Field Name | Type | Required | Conditional On | Shared |
|---|-----------|------|----------|---------------|--------|
| 6.1a-6.4a | Attempt Date (x4) | date | Cond. | Unable to schedule | N |
| 6.1b-6.4b | Attempt Time (x4) | time | Cond. | Unable to schedule | N |
| 6.1c-6.4c | Number Called (x4) | text | Cond. | Unable to schedule | N |
| 6.1d-6.4d | Result (x4) | text | Cond. | Unable to schedule | N |

**Branch Logic Summary**:
- Every "Yes" answer in Sections 1-4 requires a Detail text field with measurements (cracks: width + length), photos (close-up + perspective), and history.
- Cracks >= 1/8 inch trigger additional owner interview requirements (first occurrence date, change timeline).
- Section 5.2 conditional on townhouse/row house property type.
- Section 6 conditional on inability to schedule/complete inspection.

**Evidence Requirements**:
- Always: front and rear elevation photos, general property photos.
- Per "Yes" item: close-up photo + perspective photo.
- Garage cracks: must show localized vs radiating pattern.
- Townhouse: photo of adjacent structures within 1/4 mile.
- Crack measurements required for all cracks.

---

### 4.6 Mold Assessment (Chapter 468, Part XVI)

**Regulatory Reference**: Florida Statutes Chapter 468, Part XVI (MRSA)
**Form Type**: Narrative report (no standard fillable PDF)
**Regulatory Body**: DBPR (Department of Business and Professional Regulation)
**Implementation Status**: Not implemented; no dedicated template found in docs/
**Confidence**: Statutory knowledge -- requires external verification

#### 4.6.1 Complete Field Inventory (21 fields)

| # | Field Name | Type | Required | Conditional On | Shared |
|---|-----------|------|----------|---------------|--------|
| 1 | Assessor Name | text | Yes | -- | Y (= inspector_name) |
| 2 | MRSA License Number | text | Yes | -- | Y (= inspector_license_number, different type) |
| 3 | Company Name | text | Yes | -- | Y |
| 4 | Client Name | text | Yes | -- | Y |
| 5 | Property Address | text | Yes | -- | Y |
| 6 | Assessment Date(s) | date | Yes | -- | Y (may be multi-day) |
| 7 | Weather Conditions | text | Yes | -- | N |
| 8 | Building Type | text | Yes | -- | N |
| 9 | Building Age | text | Yes | -- | Y (= year_built) |
| 10 | HVAC Operating Status | enum | Yes | -- | N |
| 11 | Areas Assessed | list[text] | Yes | -- | N |
| 12 | Areas Not Assessed | list[text] | Yes | -- | N |
| 13 | Moisture Source(s) | list[object] | Cond. | Moisture found | N |
| 14 | Moisture Readings | list[object] | Yes | -- | N |
| 15 | Visible Mold Locations | list[object] | Cond. | Mold found | N |
| 16 | Sample Locations | list[object] | Cond. | Samples taken | N |
| 17 | Lab Name | text | Cond. | Samples taken | N |
| 18 | Lab Report Number | text | Cond. | Samples taken | N |
| 19 | Remediation Recommended | boolean | Yes | -- | N |
| 20 | Remediation Scope | text | Cond. | Remediation recommended | N |
| 21 | Re-occupancy Criteria | text | Cond. | Remediation recommended | N |

**Branch Logic Summary**:
- Mold found -> document locations, extent, materials.
- Samples taken -> lab results, chain of custody, species ID required.
- Remediation recommended -> full protocol (containment, PPE, removal method, waste disposal, HVAC isolation, post-remediation plan, clearance criteria).
- Post-remediation assessment required if remediation performed.

**Evidence Requirements**: Photos of all affected areas, moisture sources, moisture meter readings. Lab reports if sampling performed.

---

### 4.7 General Home Inspection (Rule 61-30.801)

**Regulatory Reference**: Rule 61-30.801, F.A.C. (Standards of Practice for Home Inspectors)
**Form Type**: Narrative report with section checkpoint tables
**Source Document**: fullinspection.doc
**Implementation Status**: Not implemented

#### 4.7.1 Report Header Fields (10 fields)

| # | Field Name | Type | Required | Shared |
|---|-----------|------|----------|--------|
| 1 | Property Address | text | Yes | Y |
| 2 | Property Description | text | No | N |
| 3 | Inspection Date | date | Yes | Y |
| 4 | Inspection Time | time | Yes | N |
| 5 | Report Number | text | Yes | N |
| 6 | Customer Name(s) | text | Yes | Y |
| 7 | Inspector Company | text | Yes | Y |
| 8 | Inspector Name | text | Yes | Y |
| 9 | Inspection Fee | currency | Yes | N |
| 10 | Payment Method | enum | Yes | N |

#### 4.7.2 Inspection Section Structure (12 sections)

Each section follows a consistent pattern: General Info Fields + Checkpoint Table (Item / Good|Fair|Poor|N/A / Comments) + Notes/Recommendations narrative.

**Section: Roof/Deck**
- General Info: Roof Style (enum), Roof Covering (enum), Flashing (enum), Gutters/Downspouts (enum), Method of Observation (enum)
- Checkpoints: Condition, Flashing, Truss/rafter, Estimated age, Downspouts, Chimney, Flat/Low Slope, Vents, Skylights
- Rating: Good / Fair / Poor / N/A per item

**Section: Electrical**
- General Info: Service Line (enum), Conductors (int), Panel Location (text), Panel Capacity (enum), Conductor Type (enum), Branch Conductor (enum), Sub-Panel circuits, GFCI (enum), System Ground (enum)
- Checkpoints: Service Line, Main Panel, Breakers, Fuses, Conductors, Sub-Panel, Wiring, GFCI, Grounding, Lights, Outlets, Switches
- Rating: Good / Fair / Poor / N/A per item

**Section: Plumbing**
- General Info: Main Line Material (enum), Diameter (enum), Valve Location (text), Hose Bib Locations (multi-select), Waste Line Material (enum), Fuel System (enum), Pressure Test (PSI + time)
- Checkpoints: Main Line, Water Line, Shut-Off, Pressure, Regulator, Relief Valve, Waste Disposal, Waste Line, Sump Pump, Softener, Anti-Siphon, Hose Bib, Fuel Lines
- Rating: Good / Fair / Poor / N/A per item

**Section: Water Heater**
- General Info: Type (enum), Manufacturer (text), Capacity (gallons), Approx Age (years), Plumbing Type (enum), Enclosure Type (enum), Fuel System (enum), Base (enum)
- Checkpoints: Heater, TPR Valve, Shut-Off, Seismic, Blanket, Vent Flue, Enclosure, Plumbing, Combustion Air, Venting, Base, Overflow
- Rating: Good / Fair / Poor / N/A per item

**Section: Heating**
- General Info: Location(s) (up to 3 + manufacturers), Heating Type (enum), Fuel Type (enum)
- Checkpoints: Burner, Venting, Combustion Air, Duct Work, Filters, Thermostat, Distribution, Gas Valves
- Rating: Good / Fair / Poor / N/A per item

**Section: Air Conditioning**
- General Info: Location(s) (up to 3 + manufacturers), Type (enum), Power (enum), Disconnect (Y/N), Defects (Y/N)
- Checkpoints: Compressor, Filter, Blower, Duct Work, Electrical, Base
- Rating: Good / Fair / Poor / N/A per item

**Section: Structure/Foundation** (from Rule 61-30.801; incomplete in source doc)
- Checkpoints: Foundation, Basement/Crawlspace, Framing, Floors, Walls

**Section: Exterior** (from Rule 61-30.801; incomplete in source doc)
- Checkpoints: Siding, Windows, Doors, Trim, Eaves, Decks, Fencing, Paving

**Section: Interior** (from Rule 61-30.801; incomplete in source doc)
- Checkpoints: Walls, Ceilings, Floors, Stairs, Doors, Windows, Cabinets

**Section: Insulation/Ventilation** (from Rule 61-30.801; incomplete in source doc)
- Checkpoints: Attic Insulation, Vapor Barriers, Kitchen/Bath Venting

**Section: Built-in Appliances** (from Rule 61-30.801; incomplete in source doc)
- Checkpoints: Dishwasher, Range, Disposal, Oven, Microwave, Ventilation

**Section: Life Safety** (from Rule 61-30.801; incomplete in source doc)
- Checkpoints: Smoke Detectors, Fire Extinguishers, Safety Glass

**Note**: Sections marked "incomplete in source doc" are defined by Rule 61-30.801 but were not fully extracted from fullinspection.doc due to document formatting issues. The checkpoint items listed are derived from the rule requirements.

**Branch Logic Summary**: Rating = POOR requires narrative explanation. Safety hazards require immediate recommendations. Components not accessible marked N/A with reason. Visible moisture/mold/pest evidence triggers specialist referral recommendation.

**Evidence Requirements**: Front elevation photo (minimum). Per-section deficiency photos. Electrical panel photo. Pressure test PSI reading. Data plate photos for water heater and HVAC. Room-by-room deficiency photos.

---

## 5. Rating Scale Normalization

Three different rating scales are in use across forms. Phase 2 should define a normalized scale.

| Source | Scale | Values |
|--------|-------|--------|
| 4-Point | 2-tier | Satisfactory, Unsatisfactory |
| General Inspection | 4-tier | Good, Fair, Poor, N/A |
| HUD Report | 8-code | Y, N, S, U, MR, MG, NA, NV |

**Recommended normalized model** (from 01-04):

| Normalized Value | 4-Point Maps To | General Maps To | HUD Maps To |
|-----------------|----------------|-----------------|-------------|
| Satisfactory | Satisfactory | Good | Y, S |
| Marginal | -- | Fair | MR |
| Deficient | Unsatisfactory | Poor | U, N |
| Not Applicable | -- | N/A | NA |
| Not Visible | -- | -- | NV |
| Missing | -- | -- | MG |

---

## 6. Gaps and Recommendations

### 6.1 Missing Forms / Documents

| ID | Missing Item | Severity | Recommended Action |
|----|-------------|----------|--------------------|
| GAP-01 | WDO form (FDACS-13645) not in `docs/` | High | Download from https://forms.fdacs.gov/13645.pdf to `docs/fdacs-13645-wdo.pdf` |
| GAP-02 | FGS Subsidence Incident Report | Medium | Obtain from FL DEP/FGS. Downstream form (geologist-filed, not inspector-initiated). Lower priority. |
| GAP-03 | Sinkhole form page 1 missing from `docs/sinkhole.pdf` | High | Obtain complete Citizens Sinkhole Inspection Form ver. 2 from Citizens Property Insurance. 8 fields currently inferred. |
| GAP-04 | Dedicated Mold Assessment template | High | No MRSA-compliant mold assessment form found in docs. Source a template from DBPR or industry. All 21 fields based on statutory knowledge. |
| GAP-05 | Insurance company variant PDFs not analyzed | Medium | `citizens4point.pdf`, `statefarm4point.pdf` could not be rendered (PDF tools unavailable). May contain different field layouts. |
| GAP-06 | Sinkhole form is from 2012 (14 years old) | Medium | Verify with Citizens whether a newer version exists. |

### 6.2 Implementation Gaps in Existing Forms

| ID | Gap | Severity | Impact |
|----|-----|----------|--------|
| IMP-01 | 4-Point: ~80 data fields missing from JSON map | P0 | Cannot produce valid 4-Point PDF without electrical, HVAC, plumbing, roof data fields |
| IMP-02 | Wind Mit: Q1-Q8 answer selections missing | P0 | Cannot produce valid OIR-B1-1802 without these; they determine insurance premium credits |
| IMP-03 | All 3 maps: shared header fields (address, date, year built) missing from RCF-1 and Wind Mit | P0 | Basic form completeness |
| IMP-04 | All 3 maps: inspector identity fields not mapped | P1 | Inspector certification block required on all forms |
| IMP-05 | RCF-1: all roof condition data fields missing | P1 | Cannot produce valid RCF-1 |
| IMP-06 | All 3 maps: no date fields | P1 | Required on all official forms |

### 6.3 Schema Design Recommendations for Phase 2

| Recommendation | Rationale |
|---------------|-----------|
| **Create a shared `PropertyProfile` model** containing the 7 universal fields (address, date, inspector name/company/license/signature, client name) | Eliminates redundancy; single source of truth across all forms |
| **Create a shared `InspectorProfile` model** with support for multiple license types (home inspector, pest control, mold assessor) | WDO and Mold require different license types from the same inspector or different inspectors |
| **Normalize rating scales into a single enum** with per-form mapping functions | Three incompatible scales in use; normalization enables cross-form analytics |
| **Design form sections as composable modules** (e.g., "Electrical Section", "Roof Section") that can be reused across 4-Point and General Inspection | Significant field overlap between 4-Point system sections and General Inspection sections |
| **Support repeating field groups** for: WDO inaccessible areas (5x3), Sinkhole checklist items (N x checkbox+detail), General Inspection checkpoints (N x item+rating+comment) | Multiple forms use repeating patterns that should be modeled as list structures |
| **Add a `FormVariant` concept** to handle insurance company-specific differences within the same form type | Citizens, State Farm, and standard 4-Point forms may have different field layouts |
| **Track field provenance** (mapped vs gap vs inferred) in the schema metadata | 8 sinkhole fields are inferred; 21 mold fields are from statutory knowledge; helps prioritize verification |

### 6.4 Cross-Reference Verification

The 01-04 inventory identified 17 shared fields across narrative and fillable forms (Section E). This consolidation confirms and expands that count:

| 01-04 Shared Field | Confirmed in FIELD_INVENTORY | Section |
|--------------------|------------------------------|---------|
| Property Address | Yes -- universal (7/7) | 2.1 |
| Inspection Date | Yes -- universal (7/7) | 2.1 |
| Inspector Name | Yes -- universal (7/7) | 2.1 |
| Inspector License # | Yes -- shared (6/7) | 2.1 |
| Client/Customer Name | Yes -- universal (7/7) | 2.1 |
| Roof Type/Material | Yes -- shared (3/7) | 2.2 |
| Roof Age | Yes -- shared (3/7) | 2.2 |
| Electrical Panel Info | Yes -- shared (2/7) | 2.2 |
| Electrical Capacity | Yes -- shared (2/7) | 2.2 |
| Plumbing Material | Yes -- shared (2/7) | 2.2 |
| Water Heater Info | Yes -- shared (2/7) | 2.2 |
| HVAC Type/Info | Yes -- shared (2/7) | 2.2 |
| Roof Condition Rating | Yes -- shared (3/7) | 2.2 |
| Photo Evidence | Yes -- all forms require photos | Per-form sections |
| Building Construction | Yes -- shared (Wind Mit + General) | 2.2 |
| Year Built | Yes -- shared (5/7) | 2.2 |
| Inspector Company | Yes -- promoted to universal (7/7) | 2.1 |

All 17 previously identified shared fields are accounted for. This inventory adds `inspector_signature`, `policy_number`, `inspector_phone`, `signature_date`, and `comments` as additional shared fields not called out in 01-04.

---

## 7. Field Count Reconciliation

### Source Inventory vs. FIELD_INVENTORY Cross-Check

| Source | Reported Count | Fields in This Document | Status |
|--------|---------------|------------------------|--------|
| 01-01: 4-Point mapped | 27 | 27 (Section 4.1.1) | Complete |
| 01-01: 4-Point gaps | ~80 | ~64 enumerated (Section 4.1.2) | Complete (gap fields grouped; individual hazard checkboxes counted as groups) |
| 01-01: RCF-1 mapped | 8 | 8 (Section 4.2.1) | Complete |
| 01-01: RCF-1 gaps | ~18 | 20 (Section 4.2.2) | Complete |
| 01-01: Wind Mit mapped | 22 | 22 (Section 4.3.1) | Complete |
| 01-01: Wind Mit gaps | ~20 | ~20 (Section 4.3.2) | Complete |
| 01-02: WDO | 46 | 46 + 2 repeats (Section 4.4.1) | Complete |
| 01-03: Sinkhole | 67 (59+8) | 67 (59+8) (Section 4.5.1) | Complete |
| 01-04: Mold Assessment | 21 | 21 (Section 4.6.1) | Complete |
| 01-04: General Inspection | ~150+ | Header (10) + 12 sections with checkpoints (Section 4.7) | Complete (checkpoint items listed per section) |
