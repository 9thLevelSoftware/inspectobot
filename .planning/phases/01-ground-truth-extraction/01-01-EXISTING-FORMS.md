# 01-01: Existing Forms Inventory

**Date:** 2026-03-07
**Source files analyzed:**
- `assets/pdf/maps/insp4pt_03_25.v1.json` (26 fields)
- `assets/pdf/maps/rcf1_03_25.v1.json` (8 fields)
- `assets/pdf/maps/oir_b1_1802_rev_04_26.v1.json` (22 fields)
- `lib/features/inspection/domain/form_requirements.dart`
- `lib/features/inspection/domain/evidence_requirement.dart`
- `lib/features/inspection/domain/inspection_draft.dart`
- `lib/features/inspection/domain/required_photo_category.dart`
- `lib/features/pdf/pdf_generation_input.dart`
- `lib/features/pdf/data/pdf_media_resolver.dart`
- Reference images: `docs/4Point1-scaled.jpg` through `docs/4Point3.jpg`

---

## 1. 4-Point Inspection Form (Insp4pt 03-25)

**Form code:** `four_point`
**Template:** `assets/pdf/templates/insp4pt_03_25.pdf`
**Map:** `assets/pdf/maps/insp4pt_03_25.v1.json`
**Total fields in map:** 27
**Pages spanned:** 3

### 1.1 Field Map Inventory

| # | Field Key | Source Key | Type | Page | X | Y | W | H | Required | Condition |
|---|-----------|-----------|------|------|---|---|---|---|----------|-----------|
| 1 | `text.client_name` | `client_name` | text | 1 | 42 | 706 | 220 | 14 | Yes | Always |
| 2 | `text.property_address` | `property_address` | text | 1 | 42 | 688 | 320 | 14 | Yes | Always |
| 3 | `checkbox.photo_exterior_front` | `photo:exterior_front` | checkbox | 1 | 42 | 660 | 12 | 12 | Yes | Always |
| 4 | `image.photo_exterior_front` | `photo:exterior_front` | image | 1 | 42 | 520 | 150 | 110 | Yes | Always |
| 5 | `signature.inspector` | `inspector_signature` | signature | 1 | 360 | 86 | 170 | 36 | Yes | Always |
| 6 | `checkbox.photo_exterior_rear` | `photo:exterior_rear` | checkbox | 2 | 42 | 660 | 12 | 12 | Yes | Always |
| 7 | `image.photo_exterior_rear` | `photo:exterior_rear` | image | 2 | 42 | 520 | 150 | 110 | Yes | Always |
| 8 | `checkbox.photo_exterior_left` | `photo:exterior_left` | checkbox | 2 | 204 | 660 | 12 | 12 | Yes | Always |
| 9 | `image.photo_exterior_left` | `photo:exterior_left` | image | 2 | 204 | 520 | 150 | 110 | Yes | Always |
| 10 | `checkbox.photo_exterior_right` | `photo:exterior_right` | checkbox | 2 | 366 | 660 | 12 | 12 | Yes | Always |
| 11 | `image.photo_exterior_right` | `photo:exterior_right` | image | 2 | 366 | 520 | 150 | 110 | Yes | Always |
| 12 | `checkbox.photo_roof_slope_main` | `photo:roof_slope_main` | checkbox | 2 | 42 | 380 | 12 | 12 | Yes | Always |
| 13 | `image.photo_roof_slope_main` | `photo:roof_slope_main` | image | 2 | 42 | 240 | 150 | 110 | Yes | Always |
| 14 | `checkbox.photo_roof_slope_secondary` | `photo:roof_slope_secondary` | checkbox | 2 | 204 | 380 | 12 | 12 | Yes | Always |
| 15 | `image.photo_roof_slope_secondary` | `photo:roof_slope_secondary` | image | 2 | 204 | 240 | 150 | 110 | Yes | Always |
| 16 | `checkbox.photo_water_heater_tpr_valve` | `photo:water_heater_tpr_valve` | checkbox | 3 | 42 | 660 | 12 | 12 | Yes | Always |
| 17 | `image.photo_water_heater_tpr_valve` | `photo:water_heater_tpr_valve` | image | 3 | 42 | 520 | 150 | 110 | Yes | Always |
| 18 | `checkbox.photo_plumbing_under_sink` | `photo:plumbing_under_sink` | checkbox | 3 | 204 | 660 | 12 | 12 | Yes | Always |
| 19 | `image.photo_plumbing_under_sink` | `photo:plumbing_under_sink` | image | 3 | 204 | 520 | 150 | 110 | Yes | Always |
| 20 | `checkbox.photo_electrical_panel_label` | `photo:electrical_panel_label` | checkbox | 3 | 366 | 660 | 12 | 12 | Yes | Always |
| 21 | `image.photo_electrical_panel_label` | `photo:electrical_panel_label` | image | 3 | 366 | 520 | 150 | 110 | Yes | Always |
| 22 | `checkbox.photo_electrical_panel_open` | `photo:electrical_panel_open` | checkbox | 3 | 42 | 380 | 12 | 12 | Yes | Always |
| 23 | `image.photo_electrical_panel_open` | `photo:electrical_panel_open` | image | 3 | 42 | 240 | 150 | 110 | Yes | Always |
| 24 | `checkbox.photo_hvac_data_plate` | `photo:hvac_data_plate` | checkbox | 3 | 204 | 380 | 12 | 12 | Yes | Always |
| 25 | `image.photo_hvac_data_plate` | `photo:hvac_data_plate` | image | 3 | 204 | 240 | 150 | 110 | Yes | Always |
| 26 | `checkbox.photo_hazard_photo` | `photo:hazard_photo` | checkbox | 3 | 366 | 380 | 12 | 12 | Conditional | `hazard_present == true` |
| 27 | `image.photo_hazard_photo` | `photo:hazard_photo` | image | 3 | 366 | 240 | 150 | 110 | Conditional | `hazard_present == true` |

**Note:** The hazard photo pair (checkbox + image) is conditional on branch flag `hazard_present`.

### 1.2 Evidence Requirements (from FormRequirements)

| # | Requirement Key | Label | Media Type | Category | Condition | Group |
|---|----------------|-------|------------|----------|-----------|-------|
| 1 | `photo:exterior_front` | Exterior Front | photo | `exteriorFront` | Always | -- |
| 2 | `photo:exterior_rear` | Exterior Rear | photo | `exteriorRear` | Always | -- |
| 3 | `photo:exterior_left` | Exterior Left | photo | `exteriorLeft` | Always | -- |
| 4 | `photo:exterior_right` | Exterior Right | photo | `exteriorRight` | Always | -- |
| 5 | `photo:roof_slope_main` | Roof Slope Main | photo | `roofSlopeMain` | Always | `roof-slopes` |
| 6 | `photo:roof_slope_secondary` | Roof Slope Secondary | photo | `roofSlopeSecondary` | Always | `roof-slopes` |
| 7 | `photo:water_heater_tpr_valve` | Water Heater TPR Valve | photo | `waterHeaterTprValve` | Always | -- |
| 8 | `photo:plumbing_under_sink` | Plumbing Under Sink | photo | `plumbingUnderSink` | Always | -- |
| 9 | `photo:electrical_panel_label` | Electrical Panel Label | photo | `electricalPanelLabel` | Always | -- |
| 10 | `photo:electrical_panel_open` | Electrical Panel Open | photo | `electricalPanelOpen` | Always | -- |
| 11 | `photo:hvac_data_plate` | HVAC Data Plate | photo | `hvacDataPlate` | Always | -- |
| 12 | `photo:hazard_photo` | Hazard Photo | photo | `hazardPhoto` | `hazard_present` | -- |

**Branch flags:** `hazard_present`

### 1.3 Gap Analysis vs. Reference 4-Point Form (from images)

The reference 4-Point Inspection Form (docs/4Point1-4.jpg) contains the following sections and fields that are **NOT represented** in the current field map or evidence requirements:

#### Section: Header / Property Info
| Reference Field | Status | Notes |
|----------------|--------|-------|
| Insured/Applicant Name | **MAPPED** | `text.client_name` |
| Application / Policy # | **MISSING** | Not in field map |
| Address Inspected | **MAPPED** | `text.property_address` |
| Actual Year Built | **MISSING** | Available in `InspectionDraft.yearBuilt` but no field map entry |
| Date Inspected | **MISSING** | Available in `InspectionDraft.inspectionDate` but no field map entry |

#### Section: Minimum Photo Requirements Checklist
| Reference Field | Status | Notes |
|----------------|--------|-------|
| Dwelling: Each side | **MAPPED** | 4 exterior photos |
| Roof: Each slope | **MAPPED** | 2 roof slope photos |
| Plumbing: Water heater, under cabinet | **MAPPED** | 2 plumbing photos |
| Main electrical service panel w/ interior door label | **MAPPED** | 2 electrical photos |
| Electrical box with panel off | **MAPPED** | `photo:electrical_panel_open` |
| All hazards or deficiencies noted in this report | **MAPPED** | `photo:hazard_photo` (conditional) |

#### Section: Electrical System (Page 1)
| Reference Field | Status | Notes |
|----------------|--------|-------|
| Main Panel Type (Circuit breaker / Fuse) | **MISSING** | No checkbox/radio in map |
| Main Panel Total Amps | **MISSING** | No text field in map |
| Is amperage sufficient (Yes/No) | **MISSING** | No checkbox in map |
| Second Panel Type (Circuit breaker / Fuse) | **MISSING** | No checkbox/radio in map |
| Second Panel Total Amps | **MISSING** | No text field in map |
| Second Panel amperage sufficient (Yes/No) | **MISSING** | No checkbox in map |
| Cloth wiring | **MISSING** | Checkbox |
| Active knob and tube | **MISSING** | Checkbox |
| Branch circuit aluminum wiring | **MISSING** | Checkbox + text |
| Single strand aluminum branch wiring details | **MISSING** | Text |
| COPALUM crimp connections | **MISSING** | Checkbox |
| AlumiConn connections | **MISSING** | Checkbox |
| Hazards Present (12+ checkboxes) | **MISSING** | Double taps, Exposed wiring, Blowing fuses, etc. |
| General condition (Satisfactory/Unsatisfactory) | **MISSING** | Checkbox |
| Supplemental: Main Panel age, year updated, brand | **MISSING** | Text fields |
| Supplemental: Second Panel age, year updated, brand | **MISSING** | Text fields |
| Wiring Type (Copper / MN,BX,Conduit) | **MISSING** | Checkbox |

#### Section: HVAC System (Page 2)
| Reference Field | Status | Notes |
|----------------|--------|-------|
| Central AC (Yes/No) | **MISSING** | Checkbox |
| Central Heat (Yes/No) | **MISSING** | Checkbox |
| Primary heat source and fuel type | **MISSING** | Text |
| HVAC in good working order (Yes/No) | **MISSING** | Checkbox |
| Date of last HVAC servicing | **MISSING** | Text/Date |
| Hazards: Wood-burning stove / gas fireplace | **MISSING** | Checkbox |
| Space heater as primary heat | **MISSING** | Checkbox |
| Source portable? | **MISSING** | Checkbox |
| Air handler/condensate line blockage/leakage | **MISSING** | Checkbox |
| Supplemental: Age of system, Year last updated | **MISSING** | Text |

#### Section: Plumbing System (Page 2)
| Reference Field | Status | Notes |
|----------------|--------|-------|
| TPR valve on water heater (Yes/No) | **MISSING** | Checkbox |
| Active leak indication (Yes/No) | **MISSING** | Checkbox |
| Prior leak indication (Yes/No) | **MISSING** | Checkbox |
| Water heater location | **MISSING** | Text |
| Fixture conditions (Dishwasher, Refrigerator, Washing machine, etc.) | **MISSING** | Matrix: Satisfactory/Unsatisfactory/N/A x 12 fixtures |
| If unsatisfactory, comments | **MISSING** | Text |
| Supplemental: Age of piping, re-pipe status | **MISSING** | Text + Checkbox |
| Type of pipes (Copper/PVC/Galvanized/PEX/Polybutylene/Other) | **MISSING** | Checkboxes |

#### Section: Roof (Page 3)
| Reference Field | Status | Notes |
|----------------|--------|-------|
| Predominant Roof: Covering material | **MISSING** | Text |
| Predominant Roof: Age, Remaining useful life | **MISSING** | Text |
| Predominant Roof: Date of last roofing permit | **MISSING** | Text |
| Predominant Roof: Date of last update | **MISSING** | Text |
| Updated? Full/Partial replacement, % | **MISSING** | Checkbox + Text |
| Overall condition (Satisfactory/Unsatisfactory) | **MISSING** | Checkbox |
| Visible damage (8 checkboxes per roof) | **MISSING** | Cracking, Cupping/curling, Granule loss, etc. |
| Signs of leaks (Yes/No) | **MISSING** | Checkbox |
| Attic/underside of decking (Yes/No) | **MISSING** | Checkbox |
| Interior ceilings (Yes/No) | **MISSING** | Checkbox |
| Secondary Roof: Same set of fields | **MISSING** | Mirror of predominant roof |
| Additional Comments/Observations | **MISSING** | Text (multiline) |

#### Section: Inspector Certification (Page 3)
| Reference Field | Status | Notes |
|----------------|--------|-------|
| Inspector Signature | **MAPPED** | `signature.inspector` |
| Title | **MISSING** | Text |
| License Number | **MISSING** | Text |
| Date | **MISSING** | Text/Date (inspection date) |
| Company Name | **MISSING** | Text |
| License Type | **MISSING** | Text |
| Work Phone | **MISSING** | Text |

### 1.4 Insurance Company Variations

Based on reference document names (PDF reading unavailable on this system):

- **Standard 4-Point** (`4pointfill.pdf`, `4pointun.pdf`, `4pointsample.pdf`): The baseline form shown in the JPG images above.
- **Citizens 4-Point** (`citizens4point.pdf`): Citizens Property Insurance Corporation variant. Likely follows OIR standard with possible additional fields.
- **State Farm 4-Point** (`statefarm4point.pdf`): State Farm variant. May have simplified or different field layout.

**Note:** PDFs could not be rendered on this system (`pdftoppm` not available). Visual comparison of insurance company variants is deferred.

---

## 2. Roof Condition Form (RCF-1 03-25)

**Form code:** `roof_condition`
**Template:** `assets/pdf/templates/rcf1_03_25.pdf`
**Map:** `assets/pdf/maps/rcf1_03_25.v1.json`
**Total fields in map:** 8
**Pages spanned:** 1

### 2.1 Field Map Inventory

| # | Field Key | Source Key | Type | Page | X | Y | W | H | Required | Condition |
|---|-----------|-----------|------|------|---|---|---|---|----------|-----------|
| 1 | `text.client_name` | `client_name` | text | 1 | 42 | 706 | 220 | 14 | Yes | Always |
| 2 | `checkbox.photo_roof_condition_main_slope` | `photo:roof_condition_main_slope` | checkbox | 1 | 42 | 660 | 12 | 12 | Yes | Always |
| 3 | `image.photo_roof_condition_main_slope` | `photo:roof_condition_main_slope` | image | 1 | 42 | 520 | 150 | 110 | Yes | Always |
| 4 | `checkbox.photo_roof_condition_secondary_slope` | `photo:roof_condition_secondary_slope` | checkbox | 1 | 204 | 660 | 12 | 12 | Yes | Always |
| 5 | `image.photo_roof_condition_secondary_slope` | `photo:roof_condition_secondary_slope` | image | 1 | 204 | 520 | 150 | 110 | Yes | Always |
| 6 | `checkbox.photo_roof_defect` | `photo:roof_defect` | checkbox | 1 | 366 | 660 | 12 | 12 | Conditional | `roof_defect_present == true` |
| 7 | `image.photo_roof_defect` | `photo:roof_defect` | image | 1 | 366 | 520 | 150 | 110 | Conditional | `roof_defect_present == true` |
| 8 | `signature.inspector` | `inspector_signature` | signature | 1 | 360 | 86 | 170 | 36 | Yes | Always |

### 2.2 Evidence Requirements (from FormRequirements)

| # | Requirement Key | Label | Media Type | Category | Condition | Group |
|---|----------------|-------|------------|----------|-----------|-------|
| 1 | `photo:roof_condition_main_slope` | Roof Condition Main Slope | photo | `roofSlopeMain` | Always | `roof-condition` |
| 2 | `photo:roof_condition_secondary_slope` | Roof Condition Secondary Slope | photo | `roofSlopeSecondary` | Always | `roof-condition` |
| 3 | `photo:roof_defect` | Roof Defect | photo | `roofDefect` | `roof_defect_present` | -- |

**Branch flags:** `roof_defect_present`

### 2.3 Gap Analysis vs. Reference Roof Condition Form

Reference document `docs/ROOFINSPECT.pdf` could not be rendered (PDF reader unavailable). Based on the standard Florida Roof Condition form (RCF-1), the following fields are expected but **NOT in the field map:**

| Expected Field | Status | Notes |
|---------------|--------|-------|
| Property Address | **MISSING** | No `text.property_address` in map (present in 4-Point) |
| Insured Name | **MAPPED** | `text.client_name` |
| Policy Number | **MISSING** | Not in map |
| Inspection Date | **MISSING** | Not in map |
| Year Built | **MISSING** | Not in map |
| Roof Type / Covering Material | **MISSING** | Text |
| Roof Age (years) | **MISSING** | Text |
| Remaining Useful Life (years) | **MISSING** | Text |
| Roof Condition Rating | **MISSING** | Checkbox/Radio (Good/Fair/Poor/Failed) |
| Evidence of Prior Repairs | **MISSING** | Checkbox + Text |
| Evidence of Leaks | **MISSING** | Checkbox + Text |
| Evidence of Wind Damage | **MISSING** | Checkbox + Text |
| Evidence of Hail Damage | **MISSING** | Checkbox + Text |
| Number of Layers | **MISSING** | Text |
| Flashing Condition | **MISSING** | Checkbox |
| Soffit/Fascia Condition | **MISSING** | Checkbox |
| Gutters/Downspouts | **MISSING** | Checkbox |
| Inspector Signature | **MAPPED** | `signature.inspector` |
| Inspector License # | **MISSING** | Text |
| Inspector Company | **MISSING** | Text |
| Date Signed | **MISSING** | Text/Date |
| Comments/Observations | **MISSING** | Text (multiline) |

---

## 3. Wind Mitigation Form (OIR-B1-1802 Rev 04/26)

**Form code:** `wind_mitigation`
**Template:** `assets/pdf/templates/oir_b1_1802_rev_04_26.pdf`
**Map:** `assets/pdf/maps/oir_b1_1802_rev_04_26.v1.json`
**Total fields in map:** 22
**Pages spanned:** 3

### 3.1 Field Map Inventory

| # | Field Key | Source Key | Type | Page | X | Y | W | H | Required | Condition |
|---|-----------|-----------|------|------|---|---|---|---|----------|-----------|
| 1 | `text.client_name` | `client_name` | text | 1 | 42 | 706 | 220 | 14 | Yes | Always |
| 2 | `checkbox.photo_wind_roof_deck` | `photo:wind_roof_deck` | checkbox | 1 | 42 | 660 | 12 | 12 | Yes | Always |
| 3 | `image.photo_wind_roof_deck` | `photo:wind_roof_deck` | image | 1 | 42 | 520 | 150 | 110 | Yes | Always |
| 4 | `signature.inspector` | `inspector_signature` | signature | 1 | 360 | 86 | 170 | 36 | Yes | Always |
| 5 | `checkbox.photo_wind_roof_to_wall` | `photo:wind_roof_to_wall` | checkbox | 2 | 42 | 660 | 12 | 12 | Yes | Always |
| 6 | `image.photo_wind_roof_to_wall` | `photo:wind_roof_to_wall` | image | 2 | 42 | 520 | 150 | 110 | Yes | Always |
| 7 | `checkbox.photo_wind_roof_shape` | `photo:wind_roof_shape` | checkbox | 2 | 204 | 660 | 12 | 12 | Yes | Always |
| 8 | `image.photo_wind_roof_shape` | `photo:wind_roof_shape` | image | 2 | 204 | 520 | 150 | 110 | Yes | Always |
| 9 | `checkbox.photo_wind_secondary_water_resistance` | `photo:wind_secondary_water_resistance` | checkbox | 2 | 366 | 660 | 12 | 12 | Yes | Always |
| 10 | `image.photo_wind_secondary_water_resistance` | `photo:wind_secondary_water_resistance` | image | 2 | 366 | 520 | 150 | 110 | Yes | Always |
| 11 | `checkbox.photo_wind_opening_protection` | `photo:wind_opening_protection` | checkbox | 2 | 42 | 380 | 12 | 12 | Yes | Always |
| 12 | `image.photo_wind_opening_protection` | `photo:wind_opening_protection` | image | 2 | 42 | 240 | 150 | 110 | Yes | Always |
| 13 | `checkbox.photo_wind_opening_type` | `photo:wind_opening_type` | checkbox | 2 | 204 | 380 | 12 | 12 | Yes | Always |
| 14 | `image.photo_wind_opening_type` | `photo:wind_opening_type` | image | 2 | 204 | 240 | 150 | 110 | Yes | Always |
| 15 | `checkbox.photo_wind_permit_year` | `photo:wind_permit_year` | checkbox | 2 | 366 | 380 | 12 | 12 | Yes | Always |
| 16 | `image.photo_wind_permit_year` | `photo:wind_permit_year` | image | 2 | 366 | 240 | 150 | 110 | Yes | Always |
| 17 | `checkbox.document_wind_roof_deck` | `document:wind_roof_deck` | checkbox | 3 | 42 | 660 | 12 | 12 | Conditional | `wind_roof_deck_document_required` |
| 18 | `image.document_wind_roof_deck` | `document:wind_roof_deck` | image | 3 | 42 | 520 | 150 | 110 | Conditional | `wind_roof_deck_document_required` |
| 19 | `checkbox.document_wind_opening_protection` | `document:wind_opening_protection` | checkbox | 3 | 204 | 660 | 12 | 12 | Conditional | `wind_opening_document_required` |
| 20 | `image.document_wind_opening_protection` | `document:wind_opening_protection` | image | 3 | 204 | 520 | 150 | 110 | Conditional | `wind_opening_document_required` |
| 21 | `checkbox.document_wind_permit_year` | `document:wind_permit_year` | checkbox | 3 | 366 | 660 | 12 | 12 | Conditional | `wind_permit_document_required` |
| 22 | `image.document_wind_permit_year` | `document:wind_permit_year` | image | 3 | 366 | 520 | 150 | 110 | Conditional | `wind_permit_document_required` |

### 3.2 Evidence Requirements (from FormRequirements)

| # | Requirement Key | Label | Media Type | Category | Condition | Group |
|---|----------------|-------|------------|----------|-----------|-------|
| 1 | `photo:wind_roof_deck` | Wind: Roof Deck Attachment | photo | `windRoofDeck` | Always | -- |
| 2 | `photo:wind_roof_to_wall` | Wind: Roof To Wall Attachment | photo | `windRoofToWall` | Always | -- |
| 3 | `photo:wind_roof_shape` | Wind: Roof Geometry | photo | `windRoofShape` | Always | -- |
| 4 | `photo:wind_secondary_water_resistance` | Wind: Secondary Water Resistance | photo | `windSecondaryWaterResistance` | Always | -- |
| 5 | `photo:wind_opening_protection` | Wind: Opening Protection | photo | `windOpeningProtection` | Always | -- |
| 6 | `photo:wind_opening_type` | Wind: Opening Type | photo | `windOpeningType` | Always | -- |
| 7 | `photo:wind_permit_year` | Wind: Permit Year | photo | `windPermitYear` | Always | -- |
| 8 | `document:wind_roof_deck` | Wind Roof Deck Supporting Document | document | `windRoofDeck` | `wind_roof_deck_document_required` | -- |
| 9 | `document:wind_opening_protection` | Wind Opening Protection Document | document | `windOpeningProtection` | `wind_opening_document_required` | -- |
| 10 | `document:wind_permit_year` | Wind Permit/Age Document | document | `windPermitYear` | `wind_permit_document_required` | -- |

**Branch flags:** `wind_roof_deck_document_required`, `wind_opening_document_required`, `wind_permit_document_required`

### 3.3 Gap Analysis vs. OIR-B1-1802 Standard Form

The official OIR-B1-1802 (Uniform Mitigation Verification Inspection Form) contains the following sections. Based on the Citizens wind inspection reference (`docs/your-wind-inspection.htm`) and standard OIR form knowledge, the following fields are **NOT in the field map:**

| Expected Field / Section | Status | Notes |
|-------------------------|--------|-------|
| Policyholder Name | **MAPPED** | `text.client_name` |
| Property Address | **MISSING** | Not in wind mit map (present in 4-Point) |
| Policy Number | **MISSING** | Not in map |
| Date of Inspection | **MISSING** | Not in map |
| Year Built | **MISSING** | Not in map |
| **Q1: Building Code** | **MISSING** | Year built, FBC compliance, building code in effect at time of construction |
| **Q2: Roof Covering** | **MISSING** | FBC-equivalent roof covering (Yes/No), permit date, product approval |
| **Q3: Roof Deck Attachment** | PARTIAL | Photo captured but answer selection (A/B/C/D) is **MISSING** |
| **Q4: Roof-to-Wall Attachment** | PARTIAL | Photo captured but answer selection (Toe nails/Clips/Single wraps/Double wraps/Structural) is **MISSING** |
| **Q5: Roof Geometry** | PARTIAL | Photo captured but answer selection (Hip/Non-hip/Flat) is **MISSING** |
| **Q6: Secondary Water Resistance (SWR)** | PARTIAL | Photo captured but answer selection (Yes/No/Other) is **MISSING** |
| **Q7: Opening Protection** | PARTIAL | Photo captured but answer selection (categories A/B/C/N) is **MISSING** |
| Glazed opening types inventory | PARTIAL | Photo captured but window/door/skylight/garage counts are **MISSING** |
| **Q8: Opening Protection - All/None/Partial** | **MISSING** | Radio selection |
| Inspector Name | **MISSING** | Text |
| Inspector License Number | **MISSING** | Text |
| Inspector Signature | **MAPPED** | `signature.inspector` |
| Date Signed | **MISSING** | Text/Date |
| Inspector Company | **MISSING** | Text |
| Inspector Phone | **MISSING** | Text |
| Reinspection (Yes/No) | **MISSING** | Checkbox |
| Comments | **MISSING** | Text (multiline) |

---

## 4. Cross-Form Shared Fields Analysis

### 4.1 Fields Present Across All 3 Forms

| Field Concept | 4-Point | Roof Condition | Wind Mitigation | Source Key |
|--------------|---------|----------------|-----------------|-----------|
| Client/Insured Name | `text.client_name` | `text.client_name` | `text.client_name` | `client_name` |
| Inspector Signature | `signature.inspector` | `signature.inspector` | `signature.inspector` | `inspector_signature` |

### 4.2 Fields in InspectionDraft but NOT in Field Maps

These fields exist in `InspectionDraft` and/or `PdfGenerationInput` but have **no corresponding field map entries** in any form:

| InspectionDraft Property | PdfGenerationInput | In Any Field Map? |
|-------------------------|-------------------|-------------------|
| `clientName` | `clientName` | Yes (all 3 forms) |
| `clientEmail` | -- | No |
| `clientPhone` | -- | No |
| `propertyAddress` | `propertyAddress` | Yes (4-Point only) |
| `inspectionDate` | -- | No |
| `yearBuilt` | -- | No |
| `inspectionId` | `inspectionId` | No (resolved by `PdfMediaResolver` but no field map entry) |
| `organizationId` | `organizationId` | No (resolved by `PdfMediaResolver` but no field map entry) |
| `userId` | `userId` | No (resolved by `PdfMediaResolver` but no field map entry) |

### 4.3 Fields That SHOULD Be Shared (Gap for Unified Schema)

Based on reference document analysis, these fields appear on all 3 official forms but are only partially or not mapped:

| Shared Field | 4-Point Map | Roof Map | Wind Map | Action Needed |
|-------------|-------------|----------|----------|---------------|
| Property Address | Yes | **No** | **No** | Add to RCF-1 and OIR maps |
| Inspection Date | No | No | No | Add to all 3 maps |
| Year Built | No | No | No | Add to all 3 maps |
| Policy / Application # | No | No | No | Add to all 3 maps |
| Inspector Name | No | No | No | Add to all 3 maps |
| Inspector License # | No | No | No | Add to all 3 maps |
| Inspector Company | No | No | No | Add to all 3 maps |
| Inspector Phone | No | No | No | Add to all 3 maps |
| Date Signed | No | No | No | Add to all 3 maps |
| Comments/Observations | No | No | No | Add to all 3 maps |

---

## 5. Summary Statistics

| Metric | 4-Point | Roof Condition | Wind Mitigation | Total |
|--------|---------|----------------|-----------------|-------|
| Fields in JSON map | 27 | 8 | 22 | **57** |
| Unique source keys | 14 | 5 | 11 | **30** (27 unique across forms) |
| Text fields | 2 | 1 | 1 | 4 |
| Checkbox fields | 12 | 3 | 9 | 24 |
| Image fields | 11 | 3 | 9 | 23 |
| Signature fields | 1 | 1 | 1 | 3 |
| Evidence requirements | 12 | 3 | 10 | **25** |
| Branch flags | 1 | 1 | 3 | **5** |
| Conditional evidence items | 1 | 1 | 3 | 5 |
| Photo categories (enum) | 12 | 2 (+1 shared) | 7 | **21** total enum values |

### Field Type Distribution (all forms)

| Type | Count | % |
|------|-------|---|
| text | 4 | 7.1% |
| checkbox | 24 | 42.9% |
| image | 23 | 41.1% |
| signature | 3 | 5.4% |
| dropdown | 0 | 0% |
| date | 0 | 0% |
| radio | 0 | 0% |

---

## 6. Critical Gaps Summary

### 6.1 Architecture-Level Gaps

1. **Photo-only field maps.** The current JSON field maps are almost exclusively photo evidence placeholders (checkbox + image pairs) plus minimal header text. They do not contain the actual form data fields (text inputs, radio buttons, condition ratings, system specs) that make up the bulk of each official form.

2. **No form data fields.** The 4-Point form alone has ~80+ data fields (electrical specs, HVAC specs, plumbing fixtures, roof details) visible in the reference images. Zero of these are in the field map. The field maps currently serve only as photo/evidence overlay coordinates.

3. **Missing property address in 2 of 3 maps.** The `text.property_address` field exists only in the 4-Point map, not in Roof Condition or Wind Mitigation.

4. **No inspector identity fields in any map.** Inspector name, license number, company, phone, and license type are captured in the app's identity module but have no field map entries for PDF overlay.

5. **No date fields in any map.** Inspection date and signing date are not mapped despite being required on all official forms.

6. **Wind Mit answer selections missing.** The OIR-B1-1802 form's core value is the 8 question answers (Q1-Q8) that determine premium credits. Only photo evidence is mapped; the actual answer selections (A/B/C/D type choices) are entirely absent.

### 6.2 Recommended Remediation Priority

| Priority | Gap | Impact |
|----------|-----|--------|
| P0 | Add form data fields to 4-Point map (electrical, HVAC, plumbing, roof sections) | Cannot produce a valid 4-Point PDF without these |
| P0 | Add Q1-Q8 answer selections to Wind Mit map | Cannot produce a valid OIR-B1-1802 without these |
| P0 | Add shared header fields (address, date, year built) to all maps | Basic form completeness |
| P1 | Add inspector identity fields to all maps | Inspector certification block is required on all forms |
| P1 | Add roof condition data fields to RCF-1 map | Cannot produce valid RCF-1 without these |
| P2 | Add policy/application number field | Required by most insurance companies |
| P2 | Add comments/observations text areas | Standard on all 3 forms |
| P3 | Insurance company variant analysis | Deferred pending PDF rendering capability |
