# Consolidated Field Inventory

> **Plan**: 01-05 Cross-Form Consolidation
> **Date**: 2026-03-07
> **Source Inventories**: 01-01 (Existing Forms), 01-02 (WDO), 01-03 (Sinkhole), 01-04 (Narrative Forms)

---

## 1. Summary

### 1.1 Form Types Covered

| # | Form Type | Regulatory Reference | Format | Source Inventory | Field Count | Confidence |
|---|-----------|---------------------|--------|-----------------|-------------|------------|
| 1 | 4-Point Inspection | Insp4pt 03-25 | Fillable PDF | 01-01 | 27 mapped + ~99 gap = ~126 | Mapped: Confirmed; Gap: Inferred from reference images |
| 2 | Roof Condition (RCF-1) | RCF-1 03-25 | Fillable PDF | 01-01 | 8 mapped + ~18 gap = ~26 | Mapped: Confirmed; Gap: Inferred from reference images |
| 3 | Wind Mitigation | OIR-B1-1802 Rev 04/26 | Fillable PDF | 01-01 | 22 mapped + ~23 gap = ~45 | Mapped: Confirmed; Gap: Inferred from reference images |
| 4 | WDO (Wood-Destroying Organisms) | FDACS-13645, Rev. 05/21 | Fillable PDF | 01-02 | 51 (49 unique + 2 repeats) | Confirmed (from official FDACS form) |
| 5 | Sinkhole (Citizens) | Citizens ver. 2, Ed. 6/2012 | Fillable PDF (checklist) | 01-03 | 67 (59 confirmed + 8 inferred) | 59 fields: Confirmed; 8 fields: Inferred |
| 6 | Mold Assessment | Chapter 468, Part XVI (MRSA) | Narrative report | 01-04 | 21 | Statutory (unverified -- no template in docs/) |
| 7 | General Home Inspection | Rule 61-30.801, F.A.C. | Narrative report | 01-04 | ~150+ (12 sections x checkpoints + general info) | 6 sections: Confirmed (from fullinspection.doc); 6 sections: Statutory (from Rule 61-30.801) |

**Total unique data fields across all 7 forms: ~486** (approximate; exact count varies by how checkpoint tables are counted in narrative forms and whether secondary roof fields are counted individually).

### 1.2 Overlap Statistics

| Category | Count | Description |
|----------|-------|-------------|
| Universal fields | 8 | Present on all or nearly all 7 forms |
| Shared fields (2-4 forms) | 13 | Present on 2-4 forms with name/format variations |
| Form-specific fields | ~465 | Unique to one form type |

### 1.3 Current Implementation Status

| Form | JSON Map Fields | Gap Fields (not mapped) | Implementation State |
|------|----------------|------------------------|---------------------|
| 4-Point | 27 | ~99 | Photo overlays only; all data fields missing |
| Roof Condition | 8 | ~18 | Photo overlays only; all data fields missing |
| Wind Mitigation | 22 | ~23 | Photo overlays only; Q1-Q8 answers missing |
| WDO | 0 | 51 | Not implemented |
| Sinkhole | 0 | 67 | Not implemented |
| Mold Assessment | 0 | 21 | Not implemented |
| General Inspection | 0 | 150+ | Not implemented |

### 1.4 Field Type Distribution

Count of each field type across all 7 form inventories (from Sections 4.1-4.7):

| Type | 4-Point | RCF-1 | Wind Mit | WDO | Sinkhole | Mold | General | Total |
|------|---------|-------|----------|-----|----------|------|---------|-------|
| text | 30 | 10 | 8 | 18 | 10 | 8 | 12 | 96 |
| checkbox | 38 | 6 | 10 | 14 | 0 | 0 | 0 | 68 |
| radio | 2 | 1 | 9 | 2 | 0 | 0 | 0 | 14 |
| yes_no_na | 0 | 0 | 0 | 0 | 19 | 0 | 0 | 19 |
| date | 3 | 3 | 3 | 3 | 5 | 1 | 1 | 19 |
| time | 0 | 0 | 0 | 0 | 4 | 0 | 1 | 5 |
| signature | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 7 |
| image | 12 | 3 | 10 | 0 | 0 | 0 | 0 | 25 |
| enum | 4 | 4 | 1 | 0 | 0 | 2 | 12 | 23 |
| rating | 10 | 0 | 0 | 0 | 0 | 0 | ~95 | ~105 |
| numeric | 0 | 1 | 4 | 0 | 0 | 0 | 2 | 7 |
| multi_line_text | 2 | 1 | 1 | 10 | 7 | 5 | 12 | 38 |
| currency | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 1 |
| list | 0 | 0 | 0 | 0 | 0 | 4 | 0 | 4 |
| matrix | 1 | 0 | 0 | 0 | 0 | 0 | 12 | 13 |
| boolean | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 1 |
| **Total** | **~103** | **~30** | **~47** | **~48** | **~46** | **~22** | **~149** | **~445** |

Notes:
- General Inspection rating count (~95) includes all checkpoint items across 12 sections rated on Good/Fair/Poor/N/A scale.
- Matrix count reflects grouped checkpoint tables (4-Point plumbing fixtures = 1, General Inspection = 12 section tables).
- Totals are approximate because some fields have compound types (e.g., `checkbox + text`), counted under their primary type.

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
| `comments` | text (multi-line) | All 7 | "Additional Comments/Observations" (4-Pt, RCF-1), "Comments" (WDO 5.1, Wind Mit), "Other relevant information" (Sinkhole 5.4), narrative sections (Mold, General) | Universal concept but form-specific prompt text varies |

### 2.2 Shared Fields (Present on 2-4 Forms)

| Normalized Name | Type | Forms Using It | Name Variations | Semantic Differences |
|----------------|------|---------------|-----------------|---------------------|
| `policy_number` | text | 4-Pt, RCF-1, Wind Mit, Sinkhole | "Application / Policy #" (4-Pt), "Policy Number" (RCF-1, Wind Mit, Sinkhole 0.3) | Identical concept; insurance-specific forms only |
| `year_built` | text/integer | 4-Pt, RCF-1, Wind Mit, Mold, General | "Actual Year Built" (4-Pt), "Year Built" (RCF-1, Wind Mit), "Building Age" (Mold), "Structure Age" (HUD) | Mold/HUD may use age-in-years rather than year |
| `inspector_phone` | text | WDO, Sinkhole, Wind Mit, General | "Phone Number" (WDO 1.4), "Inspector Phone" (Sinkhole 0.8, Wind Mit), varies (General) | WDO captures company phone; others may capture personal |
| `signature_date` | date | 4-Pt, RCF-1, Wind Mit, WDO | "Date Signed" (4-Pt, RCF-1, Wind Mit), "Signature Date" (WDO 5.4) | May differ from inspection_date |
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

### 2.4 Building System Overlap

The 4-Point Inspection and General Home Inspection both assess the same four building systems but at different granularity levels. The 4-Point form uses specific data-entry fields (text, checkbox, enum) designed for underwriting, while the General Inspection uses checkpoint rating tables (Good/Fair/Poor/N/A + comments) designed for buyer advisory.

| Building System | 4-Point Fields | General Inspection Section | Overlap Notes |
|----------------|---------------|---------------------------|---------------|
| **Electrical** | Main/Second Panel Type, Amps, Sufficiency; Wiring indicators (cloth, knob-and-tube, aluminum); 13 hazard checkboxes; Panel age/brand; Wiring type; General condition (S/U) | Electrical section: Service Line, Conductors, Panel Location/Capacity/Type, Branch Conductor, Sub-Panel, GFCI, System Ground; 12 checkpoint ratings (Service Line, Main Panel, Breakers, Fuses, Conductors, Sub-Panel, Wiring, GFCI, Grounding, Lights, Outlets, Switches) | 4-Point captures specific hazard indicators as checkboxes; General rates overall component health. Panel type and capacity overlap directly. Hazard checkboxes (4-Pt) map loosely to Wiring/Grounding/Breaker checkpoint ratings (General). |
| **Plumbing** | TPR valve, Active/Prior leaks, Water heater location; 10 fixture condition ratings (S/U/N/A); Piping age/re-pipe status; Pipe material types | Plumbing section: Main Line Material, Diameter, Valve Location, Hose Bibs, Waste Line, Fuel System, Pressure Test; 13 checkpoint ratings (Main Line, Water Line, Shut-Off, Pressure, Regulator, Relief Valve, Waste Disposal, Waste Line, Sump Pump, Softener, Anti-Siphon, Hose Bib, Fuel Lines) | Pipe material overlaps directly. 4-Point fixture matrix is more granular per appliance; General has broader plumbing infrastructure checkpoints. Water Heater is a separate General section but part of 4-Point Plumbing. |
| **HVAC** | Central AC/Heat (Y/N), Primary heat source/fuel, Working order (Y/N), Last service date; 4 hazard checkboxes; System age/year updated | Heating section: Location, Type, Fuel Type; 8 checkpoint ratings (Burner, Venting, Combustion Air, Duct Work, Filters, Thermostat, Distribution, Gas Valves). AC section: Location, Type, Power, Disconnect, Defects; 6 checkpoint ratings (Compressor, Filter, Blower, Duct Work, Electrical, Base) | 4-Point captures system-level summary (type, fuel, age, hazards); General breaks into component-level checkpoint ratings. HVAC type/fuel overlaps directly. General splits heating and AC into separate sections. |
| **Roof** | Covering material, Age, Remaining useful life, Permit date, Update status (full/partial/%); Condition (S/U); 8 damage checkboxes; Leak indicators (3 locations); Secondary roof (mirrors all) | Roof/Deck section: Roof Style, Covering, Flashing, Gutters/Downspouts, Observation Method; 9 checkpoint ratings (Condition, Flashing, Truss/rafter, Estimated age, Downspouts, Chimney, Flat/Low Slope, Vents, Skylights) | Covering material and age overlap directly. 4-Point provides specific damage type checkboxes; General uses overall condition ratings. 4-Point also overlaps with Roof Condition (RCF-1) form which has its own rating scale (Good/Fair/Poor/Failed). |

**Key granularity differences:**
- **4-Point**: Binary/specific data fields optimized for insurance underwriting decisions (yes/no hazards, specific materials, age in years).
- **General Inspection**: Multi-tier rating scale (Good/Fair/Poor/N/A) with narrative comments, optimized for buyer advisory and deficiency documentation.
- **Implication for Phase 2**: The shared schema should model building system data at the 4-Point granularity level (it is the more specific superset), with General Inspection checkpoint ratings as a separate assessment layer that references the same underlying system components.

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

| # | Field Key | Field Name | Type | Required | Conditional On | Shared | Source |
|---|-----------|------------|------|----------|---------------|--------|--------|
| 1 | `text.client_name` | Client Name | text | Yes | -- | Y | Confirmed |
| 2 | `text.property_address` | Property Address | text | Yes | -- | Y | Confirmed |
| 3 | `checkbox.photo_exterior_front` | Photo: Exterior Front (checkbox) | checkbox | Yes | -- | N | Confirmed |
| 4 | `image.photo_exterior_front` | Photo: Exterior Front | image | Yes | -- | N | Confirmed |
| 5 | `signature.inspector` | Inspector Signature | signature | Yes | -- | Y | Confirmed |
| 6 | `checkbox.photo_exterior_rear` | Photo: Exterior Rear (checkbox) | checkbox | Yes | -- | N | Confirmed |
| 7 | `image.photo_exterior_rear` | Photo: Exterior Rear | image | Yes | -- | N | Confirmed |
| 8 | `checkbox.photo_exterior_left` | Photo: Exterior Left (checkbox) | checkbox | Yes | -- | N | Confirmed |
| 9 | `image.photo_exterior_left` | Photo: Exterior Left | image | Yes | -- | N | Confirmed |
| 10 | `checkbox.photo_exterior_right` | Photo: Exterior Right (checkbox) | checkbox | Yes | -- | N | Confirmed |
| 11 | `image.photo_exterior_right` | Photo: Exterior Right | image | Yes | -- | N | Confirmed |
| 12 | `checkbox.photo_roof_slope_main` | Photo: Roof Main Slope (checkbox) | checkbox | Yes | -- | N | Confirmed |
| 13 | `image.photo_roof_slope_main` | Photo: Roof Main Slope | image | Yes | -- | N | Confirmed |
| 14 | `checkbox.photo_roof_slope_secondary` | Photo: Roof Secondary Slope (checkbox) | checkbox | Yes | -- | N | Confirmed |
| 15 | `image.photo_roof_slope_secondary` | Photo: Roof Secondary Slope | image | Yes | -- | N | Confirmed |
| 16 | `checkbox.photo_water_heater_tpr_valve` | Photo: Water Heater TPR Valve (checkbox) | checkbox | Yes | -- | N | Confirmed |
| 17 | `image.photo_water_heater_tpr_valve` | Photo: Water Heater TPR Valve | image | Yes | -- | N | Confirmed |
| 18 | `checkbox.photo_plumbing_under_sink` | Photo: Plumbing Under Sink (checkbox) | checkbox | Yes | -- | N | Confirmed |
| 19 | `image.photo_plumbing_under_sink` | Photo: Plumbing Under Sink | image | Yes | -- | N | Confirmed |
| 20 | `checkbox.photo_electrical_panel_label` | Photo: Electrical Panel Label (checkbox) | checkbox | Yes | -- | N | Confirmed |
| 21 | `image.photo_electrical_panel_label` | Photo: Electrical Panel Label | image | Yes | -- | N | Confirmed |
| 22 | `checkbox.photo_electrical_panel_open` | Photo: Electrical Panel Open (checkbox) | checkbox | Yes | -- | N | Confirmed |
| 23 | `image.photo_electrical_panel_open` | Photo: Electrical Panel Open | image | Yes | -- | N | Confirmed |
| 24 | `checkbox.photo_hvac_data_plate` | Photo: HVAC Data Plate (checkbox) | checkbox | Yes | -- | N | Confirmed |
| 25 | `image.photo_hvac_data_plate` | Photo: HVAC Data Plate | image | Yes | -- | N | Confirmed |
| 26 | `checkbox.photo_hazard_photo` | Photo: Hazard (checkbox) | checkbox | Conditional | `hazard_present == true` | N | Confirmed |
| 27 | `image.photo_hazard_photo` | Photo: Hazard | image | Conditional | `hazard_present == true` | N | Confirmed |

#### 4.1.2 Gap Fields (Not Mapped -- From Reference Form Analysis)

**Header / Property Info**:

| # | Field Key | Field Name | Type | Required | Conditional On | Shared | Source |
|---|-----------|------------|------|----------|---------------|--------|--------|
| 1 | `text.header_policy_number` | Application / Policy # | text | Yes | -- | Y | Inferred |
| 2 | `text.header_year_built` | Actual Year Built | text | Yes | -- | Y | Inferred |
| 3 | `date.header_date_inspected` | Date Inspected | date | Yes | -- | Y | Inferred |

**Electrical System** (33 individual fields, expanded from grouped entries):

| # | Field Key | Field Name | Type | Required | Conditional On | Shared | Source |
|---|-----------|------------|------|----------|---------------|--------|--------|
| 1 | `radio.electrical_main_panel_type` | Main Panel Type (Circuit breaker / Fuse) | checkbox/radio | Yes | -- | Y | Inferred |
| 2 | `text.electrical_main_panel_amps` | Main Panel Total Amps | text | Yes | -- | Y | Inferred |
| 3 | `checkbox.electrical_main_amps_sufficient` | Is amperage sufficient (Yes/No) | checkbox | Yes | -- | N | Inferred |
| 4 | `radio.electrical_second_panel_type` | Second Panel Type | checkbox/radio | Conditional | Second panel exists | N | Inferred |
| 5 | `text.electrical_second_panel_amps` | Second Panel Total Amps | text | Conditional | Second panel exists | N | Inferred |
| 6 | `checkbox.electrical_second_amps_sufficient` | Second Panel amperage sufficient | checkbox | Conditional | Second panel exists | N | Inferred |
| 7 | `checkbox.electrical_cloth_wiring` | Cloth wiring | checkbox | Yes | -- | N | Inferred |
| 8 | `checkbox.electrical_knob_and_tube` | Active knob and tube | checkbox | Yes | -- | N | Inferred |
| 9 | `checkbox.electrical_aluminum_branch_wiring` | Branch circuit aluminum wiring | checkbox + text | Yes | -- | N | Inferred |
| 10 | `text.electrical_aluminum_branch_details` | Single strand aluminum branch wiring details | text | Conditional | Aluminum wiring present | N | Inferred |
| 11 | `checkbox.electrical_copalum_crimp` | COPALUM crimp connections | checkbox | Conditional | Aluminum wiring present | N | Inferred |
| 12 | `checkbox.electrical_alumiconn` | AlumiConn connections | checkbox | Conditional | Aluminum wiring present | N | Inferred |
| 13 | `checkbox.electrical_hazard_blowing_fuses` | Hazard: Blowing fuses | checkbox | Yes | -- | N | Inferred |
| 14 | `checkbox.electrical_hazard_tripping_breakers` | Hazard: Tripping breakers | checkbox | Yes | -- | N | Inferred |
| 15 | `checkbox.electrical_hazard_empty_sockets` | Hazard: Empty sockets | checkbox | Yes | -- | N | Inferred |
| 16 | `checkbox.electrical_hazard_loose_wiring` | Hazard: Loose wiring | checkbox | Yes | -- | N | Inferred |
| 17 | `checkbox.electrical_hazard_improper_grounding` | Hazard: Improper grounding | checkbox | Yes | -- | N | Inferred |
| 18 | `checkbox.electrical_hazard_corrosion` | Hazard: Corrosion | checkbox | Yes | -- | N | Inferred |
| 19 | `checkbox.electrical_hazard_over_fusing` | Hazard: Over fusing | checkbox | Yes | -- | N | Inferred |
| 20 | `checkbox.electrical_hazard_double_taps` | Hazard: Double taps | checkbox | Yes | -- | N | Inferred |
| 21 | `checkbox.electrical_hazard_exposed_wiring` | Hazard: Exposed wiring | checkbox | Yes | -- | N | Inferred |
| 22 | `checkbox.electrical_hazard_unsafe_wiring` | Hazard: Unsafe wiring | checkbox | Yes | -- | N | Inferred |
| 23 | `checkbox.electrical_hazard_improper_breaker_size` | Hazard: Improper breaker size | checkbox | Yes | -- | N | Inferred |
| 24 | `checkbox.electrical_hazard_scorching` | Hazard: Scorching | checkbox | Yes | -- | N | Inferred |
| 25 | `checkbox.electrical_hazard_other` / `text.electrical_hazard_other_desc` | Hazard: Other (explain) | checkbox + text | Yes | -- | N | Inferred |
| 26 | `enum.electrical_general_condition` | General condition (Satisfactory/Unsatisfactory) | enum | Yes | -- | N | Inferred |
| 27 | `text.electrical_main_panel_age` | Main Panel age | text | Yes | -- | N | Inferred |
| 28 | `text.electrical_main_panel_year_updated` | Main Panel year last updated | text | Yes | -- | N | Inferred |
| 29 | `text.electrical_main_panel_brand` | Main Panel brand/model | text | Yes | -- | N | Inferred |
| 30 | `text.electrical_second_panel_age` | Second Panel age | text | Conditional | Second panel exists | N | Inferred |
| 31 | `text.electrical_second_panel_year_updated` | Second Panel year last updated | text | Conditional | Second panel exists | N | Inferred |
| 32 | `text.electrical_second_panel_brand` | Second Panel brand/model | text | Conditional | Second panel exists | N | Inferred |
| 33 | `checkbox.electrical_wiring_type` | Wiring Type (Copper / MN,BX,Conduit) | checkbox | Yes | -- | N | Inferred |

**HVAC System** (11 fields):

| # | Field Key | Field Name | Type | Required | Conditional On | Shared | Source |
|---|-----------|------------|------|----------|---------------|--------|--------|
| 1 | `checkbox.hvac_central_ac` | Central AC (Yes/No) | checkbox | Yes | -- | N | Inferred |
| 2 | `checkbox.hvac_central_heat` | Central Heat (Yes/No) | checkbox | Yes | -- | N | Inferred |
| 3 | `text.hvac_primary_heat_source` | Primary heat source and fuel type | text | Yes | -- | Y | Inferred |
| 4 | `checkbox.hvac_good_working_order` | HVAC in good working order (Yes/No) | checkbox | Yes | -- | N | Inferred |
| 5 | `date.hvac_last_service_date` | Date of last HVAC servicing | date/text | Yes | -- | N | Inferred |
| 6 | `checkbox.hvac_hazard_wood_stove_fireplace` | Hazard: Wood-burning stove or gas fireplace not professionally installed (Yes/No) | checkbox | Yes | -- | N | Inferred |
| 7 | `checkbox.hvac_hazard_space_heater_primary` | Hazard: Space heater used as primary heat source (Yes/No) | checkbox | Yes | -- | N | Inferred |
| 8 | `checkbox.hvac_hazard_source_portable` | Hazard: Is the source portable (Yes/No) | checkbox | Conditional | Space heater = Yes | N | Inferred |
| 9 | `checkbox.hvac_hazard_air_handler_blockage` | Hazard: Air handler/condensate line/drain pan blockage or leakage (Yes/No) | checkbox | Yes | -- | N | Inferred |
| 10 | `text.hvac_system_age` | Age of system | text | Yes | -- | N | Inferred |
| 11 | `text.hvac_year_updated` | Year last updated | text | Yes | -- | N | Inferred |

**Plumbing System** (24 fields):

| # | Field Key | Field Name | Type | Required | Conditional On | Shared | Source |
|---|-----------|------------|------|----------|---------------|--------|--------|
| 1 | `checkbox.plumbing_tpr_valve` | TPR valve on water heater (Yes/No) | checkbox | Yes | -- | N | Inferred |
| 2 | `checkbox.plumbing_active_leak` | Active leak indication (Yes/No) | checkbox | Yes | -- | N | Inferred |
| 3 | `checkbox.plumbing_prior_leak` | Prior leak indication (Yes/No) | checkbox | Yes | -- | N | Inferred |
| 4 | `text.plumbing_water_heater_location` | Water heater location | text | Yes | -- | N | Inferred |
| 5 | `rating.plumbing_fixture_dishwasher` | Fixture condition: Dishwasher | rating (S/U/NA) | Yes | -- | N | Inferred |
| 6 | `rating.plumbing_fixture_refrigerator` | Fixture condition: Refrigerator | rating (S/U/NA) | Yes | -- | N | Inferred |
| 7 | `rating.plumbing_fixture_washing_machine` | Fixture condition: Washing machine | rating (S/U/NA) | Yes | -- | N | Inferred |
| 8 | `rating.plumbing_fixture_water_heater` | Fixture condition: Water heater | rating (S/U/NA) | Yes | -- | N | Inferred |
| 9 | `rating.plumbing_fixture_showers_tubs` | Fixture condition: Showers/Tubs | rating (S/U/NA) | Yes | -- | N | Inferred |
| 10 | `rating.plumbing_fixture_toilets` | Fixture condition: Toilets | rating (S/U/NA) | Yes | -- | N | Inferred |
| 11 | `rating.plumbing_fixture_sinks` | Fixture condition: Sinks | rating (S/U/NA) | Yes | -- | N | Inferred |
| 12 | `rating.plumbing_fixture_sump_pump` | Fixture condition: Sump pump | rating (S/U/NA) | Yes | -- | N | Inferred |
| 13 | `rating.plumbing_fixture_main_shutoff` | Fixture condition: Main shut off valve | rating (S/U/NA) | Yes | -- | N | Inferred |
| 14 | `rating.plumbing_fixture_all_other` | Fixture condition: All other visible | rating (S/U/NA) | Yes | -- | N | Inferred |
| 15 | `text.plumbing_fixture_unsatisfactory_comments` | If unsatisfactory, comments | text | Conditional | Any fixture = Unsatisfactory | N | Inferred |
| 16 | `text.plumbing_piping_age` | Age of piping system | text | Yes | -- | N | Inferred |
| 17 | `checkbox.plumbing_completely_repiped` | Completely re-piped | checkbox | Conditional | Re-pipe applicable | N | Inferred |
| 18 | `checkbox.plumbing_partially_repiped` | Partially re-piped | checkbox | Conditional | Re-pipe applicable | N | Inferred |
| 19 | `text.plumbing_repipe_details` | Re-pipe renovation details | text | Conditional | Re-piped checked | N | Inferred |
| 20 | `checkbox.plumbing_pipe_copper` | Type of pipes: Copper | checkbox | Yes | -- | Y | Inferred |
| 21 | `checkbox.plumbing_pipe_pvc_cpvc` | Type of pipes: PVC/CPVC | checkbox | Yes | -- | Y | Inferred |
| 22 | `checkbox.plumbing_pipe_galvanized` | Type of pipes: Galvanized | checkbox | Yes | -- | Y | Inferred |
| 23 | `checkbox.plumbing_pipe_pex` | Type of pipes: PEX | checkbox | Yes | -- | Y | Inferred |
| 24 | `checkbox.plumbing_pipe_polybutylene` | Type of pipes: Polybutylene | checkbox | Yes | -- | Y | Inferred |
| 25 | `checkbox.plumbing_pipe_other` / `text.plumbing_pipe_other_desc` | Type of pipes: Other (specify) | checkbox + text | Yes | -- | Y | Inferred |

**Roof** (22 fields for predominant roof; secondary roof mirrors all with `secondary_` prefix):

| # | Field Key | Field Name | Type | Required | Conditional On | Shared | Source |
|---|-----------|------------|------|----------|---------------|--------|--------|
| 1 | `text.roof_primary_covering_material` | Predominant Roof: Covering material | text | Yes | -- | Y | Inferred |
| 2 | `text.roof_primary_age` | Predominant Roof: Age (years) | text | Yes | -- | Y | Inferred |
| 3 | `text.roof_primary_remaining_life` | Predominant Roof: Remaining useful life (years) | text | Yes | -- | Y | Inferred |
| 4 | `text.roof_primary_last_permit_date` | Date of last roofing permit | text | Yes | -- | N | Inferred |
| 5 | `text.roof_primary_last_update` | Date of last update | text | Yes | -- | N | Inferred |
| 6 | `checkbox.roof_primary_full_replacement` | Updated: Full replacement | checkbox | Conditional | Roof updated | N | Inferred |
| 7 | `checkbox.roof_primary_partial_replacement` | Updated: Partial replacement | checkbox | Conditional | Roof updated | N | Inferred |
| 8 | `text.roof_primary_replacement_pct` | Updated: % of replacement | text | Conditional | Partial replacement | N | Inferred |
| 9 | `enum.roof_primary_overall_condition` | Overall condition (Satisfactory/Unsatisfactory) | enum | Yes | -- | Y | Inferred |
| 10 | `checkbox.roof_primary_damage_cracking` | Visible damage: Cracking | checkbox | Yes | -- | N | Inferred |
| 11 | `checkbox.roof_primary_damage_cupping_curling` | Visible damage: Cupping/curling | checkbox | Yes | -- | N | Inferred |
| 12 | `checkbox.roof_primary_damage_granule_loss` | Visible damage: Excessive granule loss | checkbox | Yes | -- | N | Inferred |
| 13 | `checkbox.roof_primary_damage_exposed_asphalt` | Visible damage: Exposed asphalt | checkbox | Yes | -- | N | Inferred |
| 14 | `checkbox.roof_primary_damage_exposed_felt` | Visible damage: Exposed felt | checkbox | Yes | -- | N | Inferred |
| 15 | `checkbox.roof_primary_damage_missing_tabs_tiles` | Visible damage: Missing/loose/cracked tabs or tiles | checkbox | Yes | -- | N | Inferred |
| 16 | `checkbox.roof_primary_damage_soft_spots` | Visible damage: Soft spots in decking | checkbox | Yes | -- | N | Inferred |
| 17 | `checkbox.roof_primary_damage_hail` | Visible damage: Visible hail damage | checkbox | Yes | -- | N | Inferred |
| 18 | `checkbox.roof_primary_leaks` | Signs of leaks (Yes/No) | checkbox | Yes | -- | Y | Inferred |
| 19 | `checkbox.roof_primary_attic_underside_leaks` | Attic/underside of decking (Yes/No) | checkbox | Yes | -- | N | Inferred |
| 20 | `checkbox.roof_primary_interior_ceiling_leaks` | Interior ceilings (Yes/No) | checkbox | Yes | -- | N | Inferred |
| 21 | -- | Secondary Roof (mirror of all above) | all above types | Conditional | Multiple roof coverings | N | Inferred |
| 22 | `text.roof_additional_comments` | Additional Comments/Observations | text (multi-line) | No | -- | Y | Inferred |

**Inspector Certification** (6 fields):

| # | Field Key | Field Name | Type | Required | Conditional On | Shared | Source |
|---|-----------|------------|------|----------|---------------|--------|--------|
| 1 | `text.inspector_title` | Title | text | Yes | -- | N | Inferred |
| 2 | `text.inspector_license_number` | License Number | text | Yes | -- | Y | Inferred |
| 3 | `date.inspector_signature_date` | Date | date | Yes | -- | Y | Inferred |
| 4 | `text.inspector_company_name` | Company Name | text | Yes | -- | Y | Inferred |
| 5 | `text.inspector_license_type` | License Type | text | Yes | -- | N | Inferred |
| 6 | `text.inspector_work_phone` | Work Phone | text | Yes | -- | Y | Inferred |

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

| # | Field Key | Field Name | Type | Required | Conditional On | Shared | Source |
|---|-----------|------------|------|----------|---------------|--------|--------|
| 1 | `text.client_name` | Client Name | text | Yes | -- | Y | Confirmed |
| 2 | `checkbox.photo_roof_condition_main_slope` | Photo: Roof Main Slope (checkbox) | checkbox | Yes | -- | N | Confirmed |
| 3 | `image.photo_roof_condition_main_slope` | Photo: Roof Main Slope | image | Yes | -- | N | Confirmed |
| 4 | `checkbox.photo_roof_condition_secondary_slope` | Photo: Roof Secondary Slope (checkbox) | checkbox | Yes | -- | N | Confirmed |
| 5 | `image.photo_roof_condition_secondary_slope` | Photo: Roof Secondary Slope | image | Yes | -- | N | Confirmed |
| 6 | `checkbox.photo_roof_defect` | Photo: Roof Defect (checkbox) | checkbox | Conditional | `roof_defect_present == true` | N | Confirmed |
| 7 | `image.photo_roof_defect` | Photo: Roof Defect | image | Conditional | `roof_defect_present == true` | N | Confirmed |
| 8 | `signature.inspector` | Inspector Signature | signature | Yes | -- | Y | Confirmed |

#### 4.2.2 Gap Fields (Not Mapped)

| # | Field Key | Field Name | Type | Required | Conditional On | Shared | Source |
|---|-----------|------------|------|----------|---------------|--------|--------|
| 1 | `text.header_property_address` | Property Address | text | Yes | -- | Y | Inferred |
| 2 | `text.header_policy_number` | Policy Number | text | Yes | -- | Y | Inferred |
| 3 | `date.header_inspection_date` | Inspection Date | date | Yes | -- | Y | Inferred |
| 4 | `text.header_year_built` | Year Built | text | Yes | -- | Y | Inferred |
| 5 | `text.roof_covering_material` | Roof Type / Covering Material | text | Yes | -- | Y | Inferred |
| 6 | `text.roof_age` | Roof Age (years) | text | Yes | -- | Y | Inferred |
| 7 | `text.roof_remaining_life` | Remaining Useful Life (years) | text | Yes | -- | Y | Inferred |
| 8 | `enum.roof_condition_rating` | Roof Condition Rating (Good/Fair/Poor/Failed) | radio/enum | Yes | -- | Y | Inferred |
| 9 | `checkbox.roof_prior_repairs` / `text.roof_prior_repairs_desc` | Evidence of Prior Repairs | checkbox + text | Yes | -- | N | Inferred |
| 10 | `checkbox.roof_leaks` / `text.roof_leaks_desc` | Evidence of Leaks | checkbox + text | Yes | -- | Y | Inferred |
| 11 | `checkbox.roof_wind_damage` / `text.roof_wind_damage_desc` | Evidence of Wind Damage | checkbox + text | Yes | -- | N | Inferred |
| 12 | `checkbox.roof_hail_damage` / `text.roof_hail_damage_desc` | Evidence of Hail Damage | checkbox + text | Yes | -- | N | Inferred |
| 13 | `text.roof_number_of_layers` | Number of Layers | text | Yes | -- | N | Inferred |
| 14 | `enum.roof_flashing_condition` | Flashing Condition | enum | Yes | -- | N | Inferred |
| 15 | `enum.roof_soffit_fascia_condition` | Soffit/Fascia Condition | enum | Yes | -- | N | Inferred |
| 16 | `enum.roof_gutters_downspouts` | Gutters/Downspouts | enum | Yes | -- | N | Inferred |
| 17 | `text.inspector_license_number` | Inspector License # | text | Yes | -- | Y | Inferred |
| 18 | `text.inspector_company` | Inspector Company | text | Yes | -- | Y | Inferred |
| 19 | `date.inspector_signature_date` | Date Signed | date | Yes | -- | Y | Inferred |
| 20 | `text.roof_comments` | Comments/Observations | text (multi-line) | No | -- | Y | Inferred |

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

| # | Field Key | Field Name | Type | Required | Conditional On | Shared | Source |
|---|-----------|------------|------|----------|---------------|--------|--------|
| 1 | `text.client_name` | Client Name | text | Yes | -- | Y | Confirmed |
| 2 | `checkbox.photo_wind_roof_deck` | Photo: Roof Deck (checkbox) | checkbox | Yes | -- | N | Confirmed |
| 3 | `image.photo_wind_roof_deck` | Photo: Roof Deck | image | Yes | -- | N | Confirmed |
| 4 | `signature.inspector` | Inspector Signature | signature | Yes | -- | Y | Confirmed |
| 5 | `checkbox.photo_wind_roof_to_wall` | Photo: Roof-to-Wall (checkbox) | checkbox | Yes | -- | N | Confirmed |
| 6 | `image.photo_wind_roof_to_wall` | Photo: Roof-to-Wall | image | Yes | -- | N | Confirmed |
| 7 | `checkbox.photo_wind_roof_shape` | Photo: Roof Shape (checkbox) | checkbox | Yes | -- | N | Confirmed |
| 8 | `image.photo_wind_roof_shape` | Photo: Roof Shape | image | Yes | -- | N | Confirmed |
| 9 | `checkbox.photo_wind_secondary_water_resistance` | Photo: Secondary Water Resistance (checkbox) | checkbox | Yes | -- | N | Confirmed |
| 10 | `image.photo_wind_secondary_water_resistance` | Photo: Secondary Water Resistance | image | Yes | -- | N | Confirmed |
| 11 | `checkbox.photo_wind_opening_protection` | Photo: Opening Protection (checkbox) | checkbox | Yes | -- | N | Confirmed |
| 12 | `image.photo_wind_opening_protection` | Photo: Opening Protection | image | Yes | -- | N | Confirmed |
| 13 | `checkbox.photo_wind_opening_type` | Photo: Opening Type (checkbox) | checkbox | Yes | -- | N | Confirmed |
| 14 | `image.photo_wind_opening_type` | Photo: Opening Type | image | Yes | -- | N | Confirmed |
| 15 | `checkbox.photo_wind_permit_year` | Photo: Permit Year (checkbox) | checkbox | Yes | -- | N | Confirmed |
| 16 | `image.photo_wind_permit_year` | Photo: Permit Year | image | Yes | -- | N | Confirmed |
| 17 | `checkbox.document_wind_roof_deck` | Document: Roof Deck (checkbox) | checkbox | Conditional | `wind_roof_deck_document_required` | N | Confirmed |
| 18 | `image.document_wind_roof_deck` | Document: Roof Deck | image | Conditional | `wind_roof_deck_document_required` | N | Confirmed |
| 19 | `checkbox.document_wind_opening_protection` | Document: Opening Protection (checkbox) | checkbox | Conditional | `wind_opening_document_required` | N | Confirmed |
| 20 | `image.document_wind_opening_protection` | Document: Opening Protection | image | Conditional | `wind_opening_document_required` | N | Confirmed |
| 21 | `checkbox.document_wind_permit_year` | Document: Permit Year (checkbox) | checkbox | Conditional | `wind_permit_document_required` | N | Confirmed |
| 22 | `image.document_wind_permit_year` | Document: Permit Year | image | Conditional | `wind_permit_document_required` | N | Confirmed |

#### 4.3.2 Gap Fields (Not Mapped)

**Header / Property Info**:

| # | Field Key | Field Name | Type | Required | Conditional On | Shared | Source |
|---|-----------|------------|------|----------|---------------|--------|--------|
| 1 | `text.header_property_address` | Property Address | text | Yes | -- | Y | Inferred |
| 2 | `text.header_policy_number` | Policy Number | text | Yes | -- | Y | Inferred |
| 3 | `date.header_inspection_date` | Date of Inspection | date | Yes | -- | Y | Inferred |
| 4 | `text.header_year_built` | Year Built | text | Yes | -- | Y | Inferred |

**Q1-Q8 Answer Selections (Core of form -- all MISSING)**:

| # | Field Key | Field Name | Type | Required | Conditional On | Shared | Source |
|---|-----------|------------|------|----------|---------------|--------|--------|
| 1 | `radio.wind_q1_building_code` / `text.wind_q1_year` | Q1: Building Code (year built, FBC compliance) | radio + text | Yes | -- | N | Inferred |
| 2 | `radio.wind_q2_roof_covering` / `text.wind_q2_permit_date` | Q2: Roof Covering (FBC-equivalent, permit date, product approval) | radio + text | Yes | -- | N | Inferred |
| 3 | `radio.wind_q3_roof_deck_attachment` | Q3: Roof Deck Attachment (A/B/C/D) | radio | Yes | -- | N | Inferred |
| 4 | `radio.wind_q4_roof_wall_attachment` | Q4: Roof-to-Wall Attachment (Toe nails/Clips/Single wraps/Double wraps/Structural) | radio | Yes | -- | N | Inferred |
| 5 | `radio.wind_q5_roof_geometry` | Q5: Roof Geometry (Hip/Non-hip/Flat) | radio | Yes | -- | N | Inferred |
| 6 | `radio.wind_q6_secondary_water_resistance` | Q6: Secondary Water Resistance (Yes/No/Other) | radio | Yes | -- | N | Inferred |
| 7 | `radio.wind_q7_opening_protection` | Q7: Opening Protection (categories A/B/C/N) | radio | Yes | -- | N | Inferred |
| 8 | `numeric.wind_q7_window_count` | Q7 Glazed openings: Window count | numeric | Yes | -- | N | Inferred |
| 9 | `numeric.wind_q7_door_count` | Q7 Glazed openings: Door count | numeric | Yes | -- | N | Inferred |
| 10 | `numeric.wind_q7_skylight_count` | Q7 Glazed openings: Skylight count | numeric | Yes | -- | N | Inferred |
| 11 | `numeric.wind_q7_garage_door_count` | Q7 Glazed openings: Garage door count | numeric | Yes | -- | N | Inferred |
| 12 | `radio.wind_q8_opening_protection_scope` | Q8: Opening Protection scope (All/None/Partial) | radio | Yes | -- | N | Inferred |

**Inspector Certification**:

| # | Field Key | Field Name | Type | Required | Conditional On | Shared | Source |
|---|-----------|------------|------|----------|---------------|--------|--------|
| 1 | `text.inspector_name` | Inspector Name | text | Yes | -- | Y | Inferred |
| 2 | `text.inspector_license_number` | Inspector License Number | text | Yes | -- | Y | Inferred |
| 3 | `date.inspector_signature_date` | Date Signed | date | Yes | -- | Y | Inferred |
| 4 | `text.inspector_company` | Inspector Company | text | Yes | -- | Y | Inferred |
| 5 | `text.inspector_phone` | Inspector Phone | text | Yes | -- | Y | Inferred |
| 6 | `checkbox.wind_reinspection` | Reinspection (Yes/No) | checkbox | Yes | -- | N | Inferred |
| 7 | `text.wind_comments` | Comments | text (multi-line) | No | -- | Y | Inferred |

**Branch Logic Summary**: 3 document-required flags (`wind_roof_deck_document_required`, `wind_opening_document_required`, `wind_permit_document_required`). Q1-Q8 each have internal conditional logic not yet documented in the field map.

**Evidence Requirements**: 10 items (7 photos always required, 3 documents conditional).

---

### 4.4 WDO Inspection (FDACS-13645)

**Regulatory Reference**: Rule 5E-14.142, F.A.C.; Chapter 482, F.S.
**Form Type**: Fillable PDF (2 pages)
**Issuing Agency**: FDACS (Florida Dept. of Agriculture and Consumer Services)
**Implementation Status**: Not implemented; form not in docs/ (available at https://forms.fdacs.gov/13645.pdf)

#### 4.4.1 Complete Field Inventory (51 fields: 49 unique + 2 repeats)

**Section 1 -- General Information (12 fields)**:

| # | Field Key | Field Name | Type | Required | Conditional On | Shared | Source |
|---|-----------|------------|------|----------|---------------|--------|--------|
| 1.1 | `text.wdo_company_name` | Inspection Company Name | text | Yes | -- | Y | Confirmed |
| 1.2 | `text.wdo_business_license` | Business License Number | text | Yes | -- | N | Confirmed |
| 1.3 | `text.wdo_company_address` | Company Address | text | Yes | -- | N | Confirmed |
| 1.4 | `text.wdo_phone` | Phone Number | text | Yes | -- | Y | Confirmed |
| 1.5 | `text.wdo_company_city_state_zip` | Company City, State and Zip Code | text | Yes | -- | N | Confirmed |
| 1.6 | `date.wdo_inspection_date` | Date of Inspection | date | Yes | -- | Y | Confirmed |
| 1.7 | `text.wdo_inspector_name` | Inspector's Name (Print) | text | Yes | -- | Y | Confirmed |
| 1.8 | `text.wdo_inspector_id_card` | Inspector's ID Card Number | text | Yes | -- | Y | Confirmed |
| 1.9 | `text.wdo_property_address` | Address of Property Inspected | text | Yes | -- | Y | Confirmed |
| 1.10 | `text.wdo_structures_inspected` | Structure(s) on Property Inspected | text | Yes | -- | N | Confirmed |
| 1.11 | `text.wdo_requested_by` | Inspection and Report requested by | text | Yes | -- | Y | Confirmed |
| 1.12 | `text.wdo_report_sent_to` | Report Sent to Requestor and to | text | No | Different from requestor | N | Confirmed |

**Section 2 -- Inspection Findings (8 fields)**:

| # | Field Key | Field Name | Type | Required | Conditional On | Shared | Source |
|---|-----------|------------|------|----------|---------------|--------|--------|
| 2.A | `checkbox.wdo_no_visible_signs` | NO visible signs of WDO(s) | checkbox | Yes (mutex with 2.B) | -- | N | Confirmed |
| 2.B | `checkbox.wdo_visible_evidence` | VISIBLE evidence of WDO(s) | checkbox | Yes (mutex with 2.A) | -- | N | Confirmed |
| 2.B.1 | `checkbox.wdo_live_wdo` | LIVE WDO(s) | checkbox | Conditional | 2.B checked | N | Confirmed |
| 2.B.1a | `text.wdo_live_wdo_description` | Live WDO(s) Description | text (multi-line) | Yes | 2.B.1 checked | N | Confirmed |
| 2.B.2 | `checkbox.wdo_evidence_of_wdo` | EVIDENCE of WDO(s) | checkbox | Conditional | 2.B checked | N | Confirmed |
| 2.B.2a | `text.wdo_evidence_description` | Evidence Description | text (multi-line) | Yes | 2.B.2 checked | N | Confirmed |
| 2.B.3 | `checkbox.wdo_damage_by_wdo` | DAMAGE caused by WDO(s) | checkbox | Conditional | 2.B checked | N | Confirmed |
| 2.B.3a | `text.wdo_damage_description` | Damage Description | text (multi-line) | Yes | 2.B.3 checked | N | Confirmed |

**Section 3 -- Obstructions and Inaccessible Areas (15 fields, 5 area categories x 3)**:

| # | Field Key | Field Name | Type | Required | Conditional On | Shared | Source |
|---|-----------|------------|------|----------|---------------|--------|--------|
| 3.1 | `checkbox.wdo_attic_inaccessible` | Attic (inaccessible) | checkbox | No | -- | N | Confirmed |
| 3.1a | `text.wdo_attic_specific_areas` | Attic - Specific Areas | text (multi-line) | Yes | 3.1 checked | N | Confirmed |
| 3.1b | `text.wdo_attic_reason` | Attic - Reason | text (multi-line) | Yes | 3.1 checked | N | Confirmed |
| 3.2 | `checkbox.wdo_interior_inaccessible` | Interior (inaccessible) | checkbox | No | -- | N | Confirmed |
| 3.2a | `text.wdo_interior_specific_areas` | Interior - Specific Areas | text (multi-line) | Yes | 3.2 checked | N | Confirmed |
| 3.2b | `text.wdo_interior_reason` | Interior - Reason | text (multi-line) | Yes | 3.2 checked | N | Confirmed |
| 3.3 | `checkbox.wdo_exterior_inaccessible` | Exterior (inaccessible) | checkbox | No | -- | N | Confirmed |
| 3.3a | `text.wdo_exterior_specific_areas` | Exterior - Specific Areas | text (multi-line) | Yes | 3.3 checked | N | Confirmed |
| 3.3b | `text.wdo_exterior_reason` | Exterior - Reason | text (multi-line) | Yes | 3.3 checked | N | Confirmed |
| 3.4 | `checkbox.wdo_crawlspace_inaccessible` | Crawlspace (inaccessible) | checkbox | No | -- | N | Confirmed |
| 3.4a | `text.wdo_crawlspace_specific_areas` | Crawlspace - Specific Areas | text (multi-line) | Yes | 3.4 checked | N | Confirmed |
| 3.4b | `text.wdo_crawlspace_reason` | Crawlspace - Reason | text (multi-line) | Yes | 3.4 checked | N | Confirmed |
| 3.5 | `checkbox.wdo_other_inaccessible` | Other (inaccessible) | checkbox | No | -- | N | Confirmed |
| 3.5a | `text.wdo_other_specific_areas` | Other - Specific Areas | text (multi-line) | Yes | 3.5 checked | N | Confirmed |
| 3.5b | `text.wdo_other_reason` | Other - Reason | text (multi-line) | Yes | 3.5 checked | N | Confirmed |

**Section 4 -- Treatment Information (11 fields)**:

| # | Field Key | Field Name | Type | Required | Conditional On | Shared | Source |
|---|-----------|------------|------|----------|---------------|--------|--------|
| 4.1 | `radio.wdo_previous_treatment` | Previous treatment evidence | radio (Yes/No) | Yes | -- | N | Confirmed |
| 4.1a | `text.wdo_previous_treatment_desc` | Previous treatment description | text (multi-line) | Yes | 4.1 = Yes | N | Confirmed |
| 4.2 | `text.wdo_notice_location` | Notice of Inspection location | text | Yes | -- | N | Confirmed |
| 4.3 | `radio.wdo_treated_at_inspection` | Company treated at time of inspection | radio (Yes/No) | Yes | -- | N | Confirmed |
| 4.3a | `text.wdo_organism_treated` | Organism treated | text | Yes | 4.3 = Yes | N | Confirmed |
| 4.3b | `text.wdo_pesticide_used` | Pesticide Used | text | Yes | 4.3 = Yes | N | Confirmed |
| 4.3c | `text.wdo_terms_conditions` | Terms and Conditions | text | Yes | 4.3 = Yes | N | Confirmed |
| 4.3d | `checkbox.wdo_method_whole_structure` | Method - Whole structure | checkbox | Conditional | 4.3 = Yes | N | Confirmed |
| 4.3e | `checkbox.wdo_method_spot_treatment` | Method - Spot treatment | checkbox | Conditional | 4.3 = Yes | N | Confirmed |
| 4.3e-desc | `text.wdo_spot_treatment_desc` | Spot treatment description | text | Yes | 4.3e checked | N | Confirmed |
| 4.3f | `text.wdo_treatment_notice_location` | Treatment Notice Location | text | Yes | 4.3 = Yes | N | Confirmed |

**Section 5 -- Comments and Signature (3 unique fields + 2 repeats)**:

| # | Field Key | Field Name | Type | Required | Conditional On | Shared | Source |
|---|-----------|------------|------|----------|---------------|--------|--------|
| 5.1 | `text.wdo_comments` | Comments | text (multi-line) | No | -- | Y | Confirmed |
| 5.3 | `signature.wdo_licensee` | Signature of Licensee or Agent | signature | Yes | -- | Y | Confirmed |
| 5.4 | `date.wdo_signature_date` | Signature Date | date | Yes | -- | Y | Confirmed |
| 5.5 | `text.wdo_property_address_repeat` | Address of Property (repeat) | text | Yes | -- | Y | Confirmed |
| 5.6 | `date.wdo_inspection_date_repeat` | Inspection Date (repeat) | date | Yes | -- | Y | Confirmed |

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

| # | Field Key | Field Name | Type | Required | Conditional On | Shared | Source |
|---|-----------|------------|------|----------|---------------|--------|--------|
| 0.1 | `text.sk_insured_name` | Insured/Applicant Name | text | Yes | -- | Y | Inferred |
| 0.2 | `text.sk_property_address` | Property Address | text | Yes | -- | Y | Inferred |
| 0.3 | `text.sk_policy_number` | Policy Number | text | Yes | -- | Y | Inferred |
| 0.4 | `date.sk_inspection_date` | Date of Inspection | date | Yes | -- | Y | Inferred |
| 0.5 | `text.sk_inspector_name` | Inspector Name | text | Yes | -- | Y | Inferred |
| 0.6 | `text.sk_inspector_license` | Inspector License Number | text | Yes | -- | Y | Inferred |
| 0.7 | `text.sk_inspector_company` | Inspector Company | text | Yes | -- | Y | Inferred |
| 0.8 | `text.sk_inspector_phone` | Inspector Phone | text | Yes | -- | Y | Inferred |

**Section 1 -- Exterior (10 fields: 5 checklist + 5 detail)**:

| # | Field Key | Field Name | Type | Required | Conditional On | Shared | Source |
|---|-----------|------------|------|----------|---------------|--------|--------|
| 1.1 | `yes_no_na.sk_1_1` | Any depression in yard? | yes_no_na | Yes | -- | N | Confirmed |
| 1.2 | `yes_no_na.sk_1_2` | Sinkholes/depressions on adjacent properties? | yes_no_na | Yes | -- | N | Confirmed |
| 1.3 | `yes_no_na.sk_1_3` | Soil erosion around foundation? | yes_no_na | Yes | -- | N | Confirmed |
| 1.4 | `yes_no_na.sk_1_4` | Cracks in foundation? | yes_no_na | Yes | -- | Y | Confirmed |
| 1.5 | `yes_no_na.sk_1_5` | Cracks in exterior wall? | yes_no_na | Yes | -- | N | Confirmed |
| 1.1d-1.5d | `text.sk_1_Nd` | Details (per "Yes" item) | text | Conditional | Item = Yes | N | Confirmed |

**Section 2 -- Interior (16 fields: 8 checklist + 8 detail)**:

| # | Field Key | Field Name | Type | Required | Conditional On | Shared | Source |
|---|-----------|------------|------|----------|---------------|--------|--------|
| 2.1 | `yes_no_na.sk_2_1` | Interior doors out of plumb? | yes_no_na | Yes | -- | N | Confirmed |
| 2.2 | `yes_no_na.sk_2_2` | Doors/windows out of square? | yes_no_na | Yes | -- | N | Confirmed |
| 2.3 | `yes_no_na.sk_2_3` | Compression cracks in windows/doors/frames? | yes_no_na | Yes | -- | N | Confirmed |
| 2.4 | `yes_no_na.sk_2_4` | Floors out of level? | yes_no_na | Yes | -- | N | Confirmed |
| 2.5 | `yes_no_na.sk_2_5` | Attached cabinets pulled from wall? | yes_no_na | Yes | -- | N | Confirmed |
| 2.6 | `yes_no_na.sk_2_6` | Cracks on interior walls? | yes_no_na | Yes | -- | N | Confirmed |
| 2.7 | `yes_no_na.sk_2_7` | Cracks on interior ceiling? | yes_no_na | Yes | -- | N | Confirmed |
| 2.8 | `yes_no_na.sk_2_8` | Cracks on flooring/floor tile? | yes_no_na | Yes | -- | N | Confirmed |
| 2.1d-2.8d | `text.sk_2_Nd` | Details (per "Yes" item) | text | Conditional | Item = Yes | N | Confirmed |

**Section 3 -- Garage (4 fields: 2 checklist + 2 detail)**:

| # | Field Key | Field Name | Type | Required | Conditional On | Shared | Source |
|---|-----------|------------|------|----------|---------------|--------|--------|
| 3.1 | `yes_no_na.sk_3_1` | Wall-to-slab cracks? | yes_no_na | Yes | -- | N | Confirmed |
| 3.2 | `yes_no_na.sk_3_2` | Floor cracks radiate to wall? | yes_no_na | Yes | -- | N | Confirmed |
| 3.1d-3.2d | `text.sk_3_Nd` | Details (per "Yes" item) | text | Conditional | Item = Yes | N | Confirmed |

**Section 4 -- Appurtenant Structures (8 fields: 4 checklist + 4 detail)**:

| # | Field Key | Field Name | Type | Required | Conditional On | Shared | Source |
|---|-----------|------------|------|----------|---------------|--------|--------|
| 4.1 | `yes_no_na.sk_4_1` | Cracks noted? | yes_no_na | Yes | -- | N | Confirmed |
| 4.2 | `yes_no_na.sk_4_2` | Uplift noted? | yes_no_na | Yes | -- | N | Confirmed |
| 4.3 | `yes_no_na.sk_4_3` | Cracks/damage in pool? | yes_no_na | Yes | -- | N | Confirmed |
| 4.4 | `yes_no_na.sk_4_4` | Cracks in pool deck/patio? | yes_no_na | Yes | -- | N | Confirmed |
| 4.1d-4.4d | `text.sk_4_Nd` | Details (per "Yes" item) | text | Conditional | Item = Yes | N | Confirmed |

**Section 5 -- Additional Information (5 fields)**:

| # | Field Key | Field Name | Type | Required | Conditional On | Shared | Source |
|---|-----------|------------|------|----------|---------------|--------|--------|
| 5.1 | `text.sk_general_condition` | General condition overview | text (multi-line) | Yes | -- | N | Confirmed |
| 5.2 | `text.sk_adjacent_building` | Adjacent building description | text (multi-line) | Conditional | Townhouse/row house | N | Confirmed |
| 5.3 | `text.sk_nearest_sinkhole` | Distance to nearest known sinkhole | text | Yes | -- | N | Confirmed |
| 5.4 | `text.sk_other_findings` | Other relevant findings | text (multi-line) | Yes | -- | N | Confirmed |
| 5.5 | `text.sk_unable_to_schedule` | Unable to schedule explanation | text (multi-line) | Conditional | Inspection not completed | N | Confirmed |

**Section 6 -- Scheduling Attempts (16 fields: 4 attempts x 4 fields)**:

| # | Field Key | Field Name | Type | Required | Conditional On | Shared | Source |
|---|-----------|------------|------|----------|---------------|--------|--------|
| 6.1a-6.4a | `date.sk_attempt_N_date` | Attempt Date (x4) | date | Conditional | Unable to schedule | N | Confirmed |
| 6.1b-6.4b | `time.sk_attempt_N_time` | Attempt Time (x4) | time | Conditional | Unable to schedule | N | Confirmed |
| 6.1c-6.4c | `text.sk_attempt_N_number` | Number Called (x4) | text | Conditional | Unable to schedule | N | Confirmed |
| 6.1d-6.4d | `text.sk_attempt_N_result` | Result (x4) | text | Conditional | Unable to schedule | N | Confirmed |

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

| # | Field Key | Field Name | Type | Required | Conditional On | Shared | Source |
|---|-----------|------------|------|----------|---------------|--------|--------|
| 1 | `text.mold_assessor_name` | Assessor Name | text | Yes | -- | Y | Statutory |
| 2 | `text.mold_mrsa_license` | MRSA License Number | text | Yes | -- | Y | Statutory |
| 3 | `text.mold_company_name` | Company Name | text | Yes | -- | Y | Statutory |
| 4 | `text.mold_client_name` | Client Name | text | Yes | -- | Y | Statutory |
| 5 | `text.mold_property_address` | Property Address | text | Yes | -- | Y | Statutory |
| 6 | `date.mold_assessment_dates` | Assessment Date(s) | date | Yes | -- | Y | Statutory |
| 7 | `text.mold_weather_conditions` | Weather Conditions | text | Yes | -- | N | Statutory |
| 8 | `text.mold_building_type` | Building Type | text | Yes | -- | N | Statutory |
| 9 | `text.mold_building_age` | Building Age | text | Yes | -- | Y | Statutory |
| 10 | `enum.mold_hvac_status` | HVAC Operating Status | enum | Yes | -- | N | Statutory |
| 11 | `list.mold_areas_assessed` | Areas Assessed | list | Yes | -- | N | Statutory |
| 12 | `list.mold_areas_not_assessed` | Areas Not Assessed | list | Yes | -- | N | Statutory |
| 13 | `list.mold_moisture_sources` | Moisture Source(s) | list | Conditional | Moisture found | N | Statutory |
| 14 | `list.mold_moisture_readings` | Moisture Readings | list | Yes | -- | N | Statutory |
| 15 | `list.mold_visible_locations` | Visible Mold Locations | list | Conditional | Mold found | N | Statutory |
| 16 | `list.mold_sample_locations` | Sample Locations | list | Conditional | Samples taken | N | Statutory |
| 17 | `text.mold_lab_name` | Lab Name | text | Conditional | Samples taken | N | Statutory |
| 18 | `text.mold_lab_report_number` | Lab Report Number | text | Conditional | Samples taken | N | Statutory |
| 19 | `boolean.mold_remediation_recommended` | Remediation Recommended | boolean | Yes | -- | N | Statutory |
| 20 | `text.mold_remediation_scope` | Remediation Scope | text | Conditional | Remediation recommended | N | Statutory |
| 21 | `text.mold_reoccupancy_criteria` | Re-occupancy Criteria | text | Conditional | Remediation recommended | N | Statutory |

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

| # | Field Key | Field Name | Type | Required | Conditional On | Shared | Source |
|---|-----------|------------|------|----------|---------------|--------|--------|
| 1 | `text.gi_property_address` | Property Address | text | Yes | -- | Y | Confirmed |
| 2 | `text.gi_property_description` | Property Description | text | No | -- | N | Confirmed |
| 3 | `date.gi_inspection_date` | Inspection Date | date | Yes | -- | Y | Confirmed |
| 4 | `time.gi_inspection_time` | Inspection Time | time | Yes | -- | N | Confirmed |
| 5 | `text.gi_report_number` | Report Number | text | Yes | -- | N | Confirmed |
| 6 | `text.gi_customer_names` | Customer Name(s) | text | Yes | -- | Y | Confirmed |
| 7 | `text.gi_inspector_company` | Inspector Company | text | Yes | -- | Y | Confirmed |
| 8 | `text.gi_inspector_name` | Inspector Name | text | Yes | -- | Y | Confirmed |
| 9 | `currency.gi_inspection_fee` | Inspection Fee | currency | Yes | -- | N | Confirmed |
| 10 | `enum.gi_payment_method` | Payment Method | enum | Yes | -- | N | Confirmed |

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

**Section Completeness Summary**:

| Section | Source | Status |
|---------|--------|--------|
| Roof/Deck | fullinspection.doc | **Complete** -- checkpoints and general info fully extracted |
| Electrical | fullinspection.doc | **Complete** -- checkpoints and general info fully extracted |
| Plumbing | fullinspection.doc | **Complete** -- checkpoints and general info fully extracted |
| Water Heater | fullinspection.doc | **Complete** -- checkpoints and general info fully extracted |
| Heating | fullinspection.doc | **Complete** -- checkpoints and general info fully extracted |
| Air Conditioning | fullinspection.doc | **Complete** -- checkpoints and general info fully extracted |
| Structure/Foundation | Rule 61-30.801(1) | **Rule-derived** -- checkpoint items from statute, not template |
| Exterior | Rule 61-30.801(2) | **Rule-derived** -- checkpoint items from statute, not template |
| Interior | Rule 61-30.801(3) | **Rule-derived** -- checkpoint items from statute, not template |
| Insulation/Ventilation | Rule 61-30.801(7) | **Rule-derived** -- checkpoint items from statute, not template |
| Built-in Appliances | Rule 61-30.801(8) | **Rule-derived** -- checkpoint items from statute, not template |
| Life Safety | Rule 61-30.801(9) | **Rule-derived** -- checkpoint items from statute, not template |

**Note**: The 6 rule-derived sections were not fully extracted from fullinspection.doc due to document formatting issues. The checkpoint items listed are derived from the rule requirements. Phase 2 should design schema with extension points for additional checkpoints that may exist in the actual template.

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

### 5.2 Response Pattern Taxonomy

All distinct input patterns found across the 7 form types. This catalog is critical for Phase 2 input model design.

| # | Pattern | Description | Input Widget Implication | Forms Using It | Example Fields |
|---|---------|-------------|-------------------------|---------------|----------------|
| 1 | Rating scale | Ordinal quality assessment on a fixed scale (Good/Fair/Poor, Satisfactory/Unsatisfactory, S/U/MR, etc.) | SegmentedButton or custom rating bar with form-specific labels | 4-Point, General, HUD | `enum.electrical_general_condition` (S/U), General checkpoint ratings (G/F/P/NA), HUD checkpoint codes (S/U/MR/MG) |
| 2 | Yes/No binary | Simple boolean selection, one of two mutually exclusive options | Toggle switch or two-option SegmentedButton | WDO (Section 2.A/2.B mutually exclusive) | `checkbox.wdo_no_visible_signs` vs `checkbox.wdo_visible_evidence` |
| 3 | Yes/No/NA ternary with conditional detail | Checklist item with three states; "Yes" triggers a detail text field for measurements, photos, and history | Custom tri-state toggle + expandable detail TextFormField | Sinkhole (all 19 checklist items in Sections 1-4) | `yes_no_na.sinkhole_1_1` (depression in yard) + `text.sinkhole_1_1d` (details) |
| 4 | Mutually-exclusive radio selection | Select exactly one of N predefined options | RadioListTile group or dropdown | WDO Section 2 (A vs B), Wind Mit Q1-Q8 | `radio.wind_q3_roof_deck_attachment` (A/B/C/D), `radio.wdo_4_1` (previous treatment Y/N) |
| 5 | Independent checkbox group | Select all that apply from a set of options | Column of CheckboxListTile widgets | 4-Point electrical hazards, WDO Section 2.B sub-checks (B.1/B.2/B.3) | `checkbox.electrical_hazard_*` (13 hazard items), WDO 2.B.1/2.B.2/2.B.3 |
| 6 | Matrix (item x rating) | Grid of items each independently rated on a shared scale | DataTable or custom grid with rating widgets per row | 4-Point plumbing fixtures (10 items x S/U/NA), General checkpoint tables (N items x G/F/P/NA) | `rating.plumbing_fixture_*` (10 fixtures), General Electrical checkpoints (12 items) |
| 7 | Free text / narrative | Open-ended single-line or short text input | TextFormField (single line) | Mold assessment fields, General findings, WDO treatment descriptions | `text.inspector_company_name`, `text.mold_weather_conditions` |
| 8 | Multi-line text with structure | Narrative text area with expected sub-content (descriptions, measurements, explanations) | TextFormField with maxLines > 3, optional structured sub-prompts | WDO damage descriptions (2.B.1a-3a), Sinkhole additional info (5.1-5.5), Mold remediation scope | `text.wdo_live_wdo_description`, `text.sinkhole_5_1`, `text.mold_remediation_scope` |
| 9 | Signature | Ink or digital signature capture | Custom SignaturePad widget (already implemented in identity module) | All 7 forms (inspector); WDO (licensee/agent) | `signature.inspector`, `signature.wdo_licensee` |
| 10 | Image/photo | Captured photo evidence with optional annotation | Camera capture + image preview (already implemented in media module) | All 7 forms | `image.photo_exterior_front`, `image.photo_roof_slope_main` |
| 11 | Date | Calendar date selection | showDatePicker or DateFormField | All 7 forms (inspection date, report date, signature date) | `date.header_date_inspected`, `date.inspector_signature_date` |
| 12 | Time | Time of day selection | showTimePicker or TimeFormField | Sinkhole scheduling attempts (Section 6), General (inspection time) | `time.sinkhole_6_1b`, General header inspection time |
| 13 | Numeric | Integer or decimal value input | TextFormField with numeric keyboard + validation | Sinkhole crack measurements, Wind Mit opening counts (Q7), General PSI readings | `numeric.wind_q7_window_count`, `numeric.wind_q7_door_count` |
| 14 | Repeating group | Same field set repeated N times (dynamic or fixed count) | ListView.builder with add/remove controls, or fixed-count card list | Sinkhole scheduling attempts (x4 fixed), WDO inaccessible areas (x5), General checkpoint sections | Sinkhole 6.1a-6.4a/b/c/d (4 attempts x 4 fields), WDO Section 3 (5 areas x 3 fields) |

---

## 6. Gaps and Recommendations

### 6.1 Missing Forms / Documents

| ID | Missing Item | Severity | Recommended Action |
|----|-------------|----------|--------------------|
| GAP-01 | WDO form (FDACS-13645) not in `docs/` | High | **PENDING ACTION**: Download from https://forms.fdacs.gov/13645.pdf to `docs/fdacs-13645-wdo.pdf`. Inventory complete from retrieved form; local copy needed for reference. |
| GAP-02 | FGS Subsidence Incident Report | ~~Medium~~ Descoped | **Formally descoped** -- geologist-facing (P.G. licensed), not inspector-facing. Downstream document triggered by sinkhole findings, not an inspection form. Not available as standardized fillable form. See 01-03 Resolution section. |
| GAP-03 | Sinkhole form page 1 missing from `docs/sinkhole.pdf` | High | Obtain complete Citizens Sinkhole Inspection Form ver. 2 from Citizens Property Insurance. 8 fields currently inferred. |
| GAP-04 | Dedicated Mold Assessment template | High | No MRSA-compliant mold assessment form found in docs. Source a template from DBPR or industry. All 21 fields based on statutory knowledge. |
| GAP-05 | Insurance company variant PDFs not analyzed | Medium | `citizens4point.pdf`, `statefarm4point.pdf` could not be rendered (PDF tools unavailable). May contain different field layouts. |
| GAP-06 | Sinkhole form is from 2012 (14 years old) | Medium | Verify with Citizens whether a newer version exists. |
| GAP-07 | `docs/4point50.doc` not analyzed | Low | Binary .doc file; likely a 4-Point form variant. Requires conversion to extract and compare fields against primary Insp4pt 03-25 template. |
| GAP-08 | `docs/2012spreedsheet.xls` not analyzed | Low | Binary .xls file; likely inspection pricing/scope spreadsheet (not a form). Requires Excel to verify. |

### 6.2 Implementation Gaps in Existing Forms

| ID | Gap | Severity | Impact |
|----|-----|----------|--------|
| IMP-01 | 4-Point: ~99 data fields missing from JSON map | P0 | Cannot produce valid 4-Point PDF without electrical, HVAC, plumbing, roof data fields |
| IMP-02 | Wind Mit: Q1-Q8 answer selections missing | P0 | Cannot produce valid OIR-B1-1802 without these; they determine insurance premium credits |
| IMP-03 | All 3 maps: shared header fields (address, date, year built) missing from RCF-1 and Wind Mit | P0 | Basic form completeness |
| IMP-04 | All 3 maps: inspector identity fields not mapped | P1 | Inspector certification block required on all forms |
| IMP-05 | RCF-1: all roof condition data fields missing | P1 | Cannot produce valid RCF-1 |
| IMP-06 | All 3 maps: no date fields | P1 | Required on all official forms |

### 6.3 Schema Design Recommendations for Phase 2

Ordered by dependency (earlier items must be completed before later items that depend on them):

| # | Recommendation | Rationale | Depends On |
|---|---------------|-----------|------------|
| 1 | **Create a shared `PropertyProfile` model** containing the 8 universal fields (address, date, inspector name/company/license/signature, client name, comments) | Eliminates redundancy; single source of truth across all forms. Foundation model that all other recommendations build on. | None (foundation) |
| 2 | **Design form sections as composable modules** (e.g., "Electrical Section", "Roof Section") that can be reused across 4-Point and General Inspection | Significant field overlap between 4-Point system sections and General Inspection sections. Sections reference PropertyProfile for shared fields. | #1 |
| 3 | **Support repeating field groups** for: WDO inaccessible areas (5x3), Sinkhole checklist items (N x checkbox+detail), General Inspection checkpoints (N x item+rating+comment) | Multiple forms use repeating patterns that should be modeled as list structures. Repeating groups are a property of the field model established in #1. | #1 |
| 4 | **Define conditional/branch logic model** to express field visibility and validation rules declaratively | WDO Section 2 mutex, Sinkhole Yes->detail, Wind Mit Q1-Q8 internal branching all need a shared conditional logic layer. Operates on composable sections from #2. | #2 |
| 5 | **Normalize rating scales into a single enum** with per-form mapping functions | Three incompatible scales in use; normalization enables cross-form analytics. Rating fields live inside composable sections from #2. | #2 |
| 6 | **Design evidence requirements as cross-form links** tying photo/document evidence to specific fields and sections | Each form has different evidence requirements tied to specific sections and conditional states. Requires composable sections (#2) and the shared property model (#1) to define attachment points. | #1, #2 |
| 7 | **Plan migration path for existing 3 forms** (4-Point, RCF-1, Wind Mit) from current photo-only maps to full field coverage | Must account for PropertyProfile (#1), composable sections (#2), repeating groups (#3), conditional logic (#4), normalized ratings (#5), and evidence links (#6). | #1, #2, #3, #4, #5, #6 |

Previously listed recommendations folded into the above:
- "Create a shared `InspectorProfile` model" is now part of #1 (PropertyProfile includes inspector group with multi-license support).
- "Add a `FormVariant` concept" is addressed as part of #7 (migration planning).
- "Track field provenance" is a metadata concern addressed across #1-#3 (Source column now standardized in all field tables).

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
| 01-01: 4-Point gaps | ~99 | ~99 enumerated (Section 4.1.2) | Complete (all grouped fields expanded to individual rows). **Note**: The 01-01 estimate of "~80+ data fields visible in reference images" was approximate, based on visual scanning. The FIELD_INVENTORY enumeration of ~99 includes fully expanded grouped fields (13 electrical hazards, 10 plumbing fixtures, and 8 roof damage items were originally counted as 3 group entries in 01-01). The higher count reflects greater precision from individual field enumeration, not the discovery of additional fields. |
| 01-01: RCF-1 mapped | 8 | 8 (Section 4.2.1) | Complete |
| 01-01: RCF-1 gaps | ~18 | 20 (Section 4.2.2) | Complete |
| 01-01: Wind Mit mapped | 22 | 22 (Section 4.3.1) | Complete |
| 01-01: Wind Mit gaps | ~23 | ~23 (Section 4.3.2) | Complete (Q7 glazed openings expanded) |
| 01-02: WDO | 51 | 49 unique + 2 repeats (Section 4.4.1) | Complete |
| 01-03: Sinkhole | 67 (59+8) | 67 (59+8) (Section 4.5.1) | Complete |
| 01-04: Mold Assessment | 21 | 21 (Section 4.6.1) | Complete |
| 01-04: General Inspection | ~150+ | Header (10) + 12 sections with checkpoints (Section 4.7) | Complete (checkpoint items listed per section) |
