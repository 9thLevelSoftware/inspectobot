# 01-04: Narrative Forms Inventory

> **Status**: Complete with Warnings
> **Date**: 2026-03-07
> **Sources**: `docs/HUDreport.doc`, `docs/fullinspection.doc`, `docs/residentialmanual.pdf`

## Important Notes

1. **HUDreport.doc** is a **HUD Property Condition Report** (REO/foreclosure inspection), not a mold assessment report. It follows HUD REO property disposition requirements (HUD Handbook 4310.5, RFP R-OPC-22505). It does contain a mold/radon notice section (Form HUD-9548-E) but is NOT a mold-specific assessment governed by Florida Chapter 468, Part XVI (MRSA).
2. **fullinspection.doc** is a general Residential Property Inspection Agreement and Report template. It aligns with Florida Rule 61-30.801 Standards of Practice for Home Inspectors.
3. **residentialmanual.pdf** is the HUD "Residential Rehabilitation Inspection Guide" (NIBS, 2000), a federal reference manual -- not Florida-specific but provides comprehensive technical inspection standards.
4. Chapter 468, Part XVI (MRSA) requirements are noted below but **require external verification** as no dedicated mold assessment form was found in the source documents.

---

## Section A: HUD Property Condition Report (HUDreport.doc)

### A.1 Document Structure

The HUD Property Condition Report is a structured narrative report with checkpoint tables per section. It follows a standardized format required under HUD RFP R-OPC-22505 for REO property disposition inspections.

| # | Section | Type | Description |
|---|---------|------|-------------|
| -- | Cover Page | Boilerplate + Data | Company info, case number, address, dates, inspector |
| -- | Notice | Boilerplate | Purchaser notice per HUD RFP 5.3.4 |
| 1 | Inspection Requirements | Boilerplate | Lists all systems/components to be inspected |
| 1.1 | Exclusions of Inspection | Boilerplate | Scope limitations |
| 1.2 | Exclusions and Limitations | Boilerplate | Visual-only disclaimer |
| 2 | Report Summary | Inspector-filled | Narrative summary per section with condition status |
| 3 | Directions to Property | Auto-generated | Google Maps directions |
| 4 | Property Information | Data fields | Address, age, access, bathrooms, sq ft, utilities |
| 5 | Additional Comments | Inspector-filled | Utility company info, meter numbers |
| 6 | Structure | Checkpoint table + narrative | Foundation, floors, walls, columns, ceilings |
| 7 | Exterior | Checkpoint table + narrative | Wall cladding, doors, decks, steps, eaves, etc. |
| 8 | Roof | Checkpoint table + narrative | Coverings, drainage, flashing, skylights, chimneys |
| 9 | Plumbing | Checkpoint table + narrative | Water supply, drains, vents, hot water, fuel, sump |
| 10 | Electrical | Checkpoint table + narrative | Service entrance, panels, voltage, GFCI, detectors |
| 11 | HVAC | Checkpoint table + narrative | Heating, AC, insulation, vapor barriers, ventilation |
| 12 | Interior | Checkpoint table + narrative | Walls, ceilings, floors, steps, cabinets, doors, windows |
| 13 | Appliances | Checkpoint table + narrative | Dishwasher, range, disposal, oven, microwave, etc. |
| 14 | HOA Information | Inspector-filled | HOA name and details |
| 15 | Code Violations | Inspector-filled | Known code violations |
| 16 | Pending Litigation | Inspector-filled | Known litigation |
| 17 | Demo Orders | Inspector-filled | Known demo orders |
| 18 | Radon Gas and Mold Notice | HUD form (HUD-9548-E) | Radon/mold release agreement, purchaser signatures |
| 19 | Environmental Issues | Inspector-filled | Known environmental issues |
| 20 | Environmental Compliance Record | HUD form (Handbook 4310.5 Att. 18) | Historic preservation, floodplain, airport zones |
| 21 | Report Images | Photo index | Numbered photo captions (up to 106+ photos observed) |

### A.2 Header / Cover Data Fields

| Field Name | Type | Required | Notes |
|------------|------|----------|-------|
| Company Name | String | Yes | Inspection company name |
| Company Address | String | Yes | Full address |
| Company Phone | String | Yes | Phone number |
| Case Number | String | Yes | HUD case number (e.g., 093-601378) |
| Full Address | String | Yes | Property street address, city, state, zip |
| Inspection Date | Date | Yes | Format: MM-DD-YYYY |
| Inspection Type | Enum | Yes | "Property Condition Inspection" |
| Prepared By | String | Yes | Inspector company name |

### A.3 Property Information Fields (Section 4)

| Field Name | Type | Required | Notes |
|------------|------|----------|-------|
| Address | String | Yes | Full property address |
| Structure Age | String | Yes | Age or "See Appr." |
| Access to Property | String | Yes | e.g., "HUD Key" |
| Number of Bathrooms | Decimal | Yes | e.g., 2.5 |
| Square Footage | Enum | Yes | Ranges: 501-1000, 1001-1500, etc. |
| Electric Status | Enum | Yes | Active / Inactive |
| Water Status | Enum | Yes | Active / Inactive |
| Gas Status | Enum | Yes | Active / Inactive / NA |
| Occupancy Status | Enum | Yes | Yes / No |

### A.4 Checkpoint Rating System

All inspection sections (6-13) use the same rating scale:

| Code | Meaning |
|------|---------|
| Y | Yes |
| N | No |
| S | Satisfactory |
| U | Unsatisfactory |
| MR | Marginal |
| MG | Missing |
| NA | Not Applicable |
| NV | Not Visible |

### A.5 Per-Section Data Model (Sections 6-13)

Each inspection section follows a consistent three-part structure:

1. **General Information** -- Section-specific metadata (e.g., foundation type, roof type, panel capacity)
2. **Checkpoints** -- Table of items with Rating code and optional Comment
3. **Comments** -- Free-text narrative findings

#### Section 6: Structure Checkpoints
- Basement Floor, Beam Supports, Ceilings, Cracks, Crawlspace Door, Floor, Footing Drain, Ground Grade, Insulation, Joists, Sill Plate, Structural, Sub-Flooring, Walls, Wood-Ground Distance

**General Info Fields**: Access Method, Foundation Type, Basement Type

#### Section 7: Exterior Checkpoints
- Balconies, Carports, Debris, Decks/Deck Steps, Driveway, Eaves, Entry Locks, Exterior Door/Locks, Fencing/Gates, Garage Door, Garage Door Opener, Landscape, Lawn Care, Leaf Removal, Patio, Pool/Spa, Porches, Railings, Retaining Walls, Sheds and Outbuildings, Sidewalks, Siding Condition, Snow Removal, Exterior Steps, Storm/Screen Windows, Storm/Screen Doors, Windows

**General Info Fields**: Exterior Siding, Lot Size, Weather Conditions, Wall Structure, Temperature

#### Section 8: Roof Checkpoints
- Shingle Cond., Flashing/Joints, Soffits/Fascias, Skylights, Vent Pipes, Chimney, Gutters, Downspouts, Attic Ventilation, Attic Water, Attic Insulation, *Structural Cond., *Sheathing Cond., Truss, Roof Exhaust Fan(s)

**General Info Fields**: Roof Type, Gutter Type, Method to Observe Attic, Method to Observe Roof, Number of Layers, Attic Vent Type, Roofing Material

#### Section 9: Plumbing Checkpoints
- Bar Sinks, Bath Fixtures, Connections, Interior Spa/Hot Tub, Interior Vent, Kitchen Sink, Laundry Tub, Main Shut Off, Pressure Relief Valve, Pressure Tank, Septic Location, Septic System, Sewer Drainage, Shower Pan, Sprinkler System, Storage Tanks, Vent System, Water Filter, Water Heaters, Water Meter, Water Softener, Water Supply, Well, Well Location, Well/Sump Pump

**General Info Fields**: Waste Disposal, Waste Piping, WH Size, WH Manufacturer, WH Model, Water Supply, Water Piping

#### Section 10: Electrical Checkpoints
- Appliance Wiring, Bath GFCI, Breaker Cond., Exterior GFCI, Exterior Wiring, Ground/Bonding, HVAC Wiring, Interior Wiring, Kitchen GFCI, Lighting Fixtures, Panel Box, Rec. Location, Service Attach, Service Meter, Sub Panel Box

**General Info Fields**: Additional Space Available, Box Location, Capacity, Conductor Type, General Wiring, Num. of Disconnects, Panel Manufacturer, Panel Type, Wiring

#### Section 11: HVAC Checkpoints
- A/C Component Cond., Boiler, Coil, Coil Fins, Condens. Pipe, Controls, Draft Device, Duct Work, Electric Heat, Evaporator, Fans, Filter, Fireplace, Flue Pipe/Draft, Furnace System, Gas Lines, Heat Exchanger, Heat Pump, Inside Fan Motor, Oil Tank, Oil Tank Vent, Refrigerant Line, Supply Returns, Temp. Drop Test, Thermostat, Vapor Barrier, Ventilation

**General Info Fields**: Inside Unit Brand, Outside Unit Brand, Inside Model No., Outside Model No., Inside Unit Type, Outside Unit Type

#### Section 12: Interior Checkpoints
- Cabinets, Ceilings, Closets, Countertops, Interior Debris, Detectors, Door Hardware, Doors, Dryer Vent, Floor, Mold, Railings, Stairwells, Steps, Walls, Windows

**General Info Fields**: None

#### Section 13: Appliances Checkpoints
- Dishwasher, Disposal, Dryer, Microwave, Oven, Range Hood, Range/Stove, Refrigerator, Washer, Other

**General Info Fields**: None

### A.6 Evidence Requirements (Photo Index)

The report includes a numbered photo index (Section 21) with 106+ captioned photos. Required photo categories observed:

| Category | Example Captions | Min Count |
|----------|-----------------|-----------|
| Exterior Elevations | Front Elevation, Side Elevation, Rear Elevation | 4 (all sides) |
| Address/Signage | Address, Subdivision Sign, PK Sign | 2+ |
| Electrical | Electrical Meter, Main Breaker, Electrical Panel, Electric Company Tag | 4+ |
| Plumbing | Shutoff, Water Meter, Water Heater, Relief Valve, Active Water | 4+ |
| HVAC | HVAC unit, HVAC Information plate | 2+ |
| Roof | Roof (multiple angles) | 2+ |
| Interior Rooms | Each room, each deficiency | All accessible rooms |
| Deficiencies | Damaged items (floor, wall, cabinet, door, fence, eave, etc.) | 1 per deficiency |
| Security | Garage Secured, Shed Secured, Sign-In Sheet | As applicable |
| Environmental | Septic Service, Irrigation | As applicable |

### A.7 Conditional Sections and Branch Logic

| Condition | Required Action |
|-----------|----------------|
| Checkpoint rated MR or U | Comment field required explaining deficiency |
| Checkpoint rated MG | Comment field required noting missing item |
| Remediation/repair needed | Summary section must reference the deficiency |
| Environmental issues present | Section 19 must detail issues |
| Property in floodplain | Section 20 floodplain checkbox + flood insurance note |
| Property is historic | Section 20 historic preservation checkbox + deed restriction note |
| Property in airport clear zone | Section 20 airport checkbox + signed disclaimer required |
| Radon/mold concerns | Section 18 (HUD-9548-E) must be completed with purchaser signatures |
| HOA present | Section 14 must identify HOA |
| Code violations known | Section 15 must detail violations |
| Pending litigation | Section 16 must detail litigation |
| Demo orders known | Section 17 must detail demo orders |

### A.8 Mold Assessment Elements within HUD Report

The HUD report contains mold-related elements but is NOT a dedicated mold assessment:

- **Section 12, Interior Checkpoints**: "Mold" checkpoint with standard rating (NV/S/U/MR)
- **Section 18**: HUD Form 9548-E "Radon Gas and Mold Notice and Release Agreement"
  - Boilerplate disclosure about radon and mold health risks
  - Purchaser acknowledgment of AS-IS condition
  - Recommendation to obtain qualified professional inspection
  - Release and indemnification of HUD/M&M Contractor
  - Purchaser signature lines, date

---

## Section B: Florida Chapter 468, Part XVI -- Mold Assessment Requirements

> **STATUTORY KNOWLEDGE ONLY**: These requirements are derived from knowledge of Chapter 468, Part XVI, F.S.,
> NOT from verified statute text or a physical form template. Phase 2 should treat these fields as **provisional**.
> Verification against actual statute text is required before finalizing the schema.
>
> The HUDreport.doc is NOT a MRSA-compliant mold assessment. A dedicated mold assessment form was not found in the provided documents. All items below require external verification against current Florida Statutes.

### B.1 Required Narrative Sections (Chapter 468, Part XVI)

| Section | Content Requirements | Statutory Reference | Conditional On |
|---------|---------------------|---------------------|----------------|
| Cover Page / Identification | Assessor name, MRSA license number, company, date | s. 468.8419, F.S. | Always required |
| Client Information | Client name, property address, assessment date(s) | s. 468.8419, F.S. | Always required |
| Scope of Assessment | Define assessment boundaries, areas included/excluded | s. 468.8414, F.S. | Always required |
| Visual Inspection Findings | Document visible mold growth by location, type, extent | s. 468.8414, F.S. | Always required |
| Moisture Source Investigation | Identify moisture sources (leaks, condensation, intrusion) | s. 468.8414, F.S. | Always required |
| Moisture Readings | Document moisture meter readings by location | s. 468.8414, F.S. | Always required |
| Air/Surface Sampling Results | Lab results for air and/or surface samples | s. 468.8414, F.S. | If samples taken |
| Affected Area Documentation | Square footage of affected areas, materials involved | s. 468.8414, F.S. | If mold found |
| Mold Type Identification | Species identification from lab analysis | s. 468.8414, F.S. | If samples taken |
| Remediation Protocol | Detailed remediation plan per IICRC S520 or equivalent | s. 468.8414, F.S. | If remediation recommended |
| Post-Remediation Verification | Clearance criteria and re-testing plan | s. 468.8414, F.S. | If remediation recommended |
| Limitations and Disclaimers | Scope limitations, areas not accessed, disclaimer | s. 468.8414, F.S. | Always required |
| Photographs | Photos of all affected areas, moisture sources, readings | s. 468.8414, F.S. | Always required |
| MRSA License Display | License number on every page or cover | s. 468.8419, F.S. | Always required |

### B.2 Mold Assessment Data Fields

| Field Name | Type | Required | Section | Notes |
|------------|------|----------|---------|-------|
| Assessor Name | String | Yes | Cover | Licensed mold assessor |
| MRSA License Number | String | Yes | Cover | Florida mold assessor license |
| Company Name | String | Yes | Cover | Licensed company |
| Client Name | String | Yes | Cover | Property owner or requestor |
| Property Address | String | Yes | Cover | Full address |
| Assessment Date(s) | Date | Yes | Cover | May span multiple days |
| Weather Conditions | String | Yes | Scope | Outdoor temp, humidity, recent rain |
| Building Type | String | Yes | Scope | Residential, commercial, etc. |
| Building Age | String | Yes | Scope | Approximate year built |
| HVAC Operating Status | Enum | Yes | Scope | On/Off during assessment |
| Areas Assessed | List[String] | Yes | Scope | Rooms/areas included |
| Areas Not Assessed | List[String] | Yes | Limitations | With reason for exclusion |
| Moisture Source(s) | List[Object] | Conditional | Findings | Location, type, severity |
| Moisture Readings | List[Object] | Yes | Findings | Location, value, material, instrument |
| Visible Mold Locations | List[Object] | Conditional | Findings | Location, area (sq ft), material, color/type |
| Sample Locations | List[Object] | Conditional | Sampling | Type (air/surface/bulk), location, lab ID |
| Lab Name | String | Conditional | Sampling | AIHA-accredited lab |
| Lab Report Number | String | Conditional | Sampling | Reference number |
| Remediation Recommended | Boolean | Yes | Conclusion | Triggers protocol section |
| Remediation Scope | Text | Conditional | Protocol | Required if remediation recommended |
| Re-occupancy Criteria | Text | Conditional | Protocol | Required if remediation recommended |

### B.3 Mold Assessment Branch Logic

```
START
  |
  v
[Visual Inspection] --> Document all visible mold + moisture sources
  |
  v
[Moisture Readings] --> Record readings for all assessed areas
  |
  v
[Mold Found?]
  |-- NO --> Document negative findings, photos, close report
  |-- YES --> Document locations, extent, materials affected
        |
        v
      [Sampling Taken?]
        |-- NO --> Note "no sampling performed" with rationale
        |-- YES --> [Air Samples?] --> Include lab results, chain of custody
        |           [Surface Samples?] --> Include lab results, species ID
        |           [Bulk Samples?] --> Include lab results, material analysis
        |
        v
      [Remediation Recommended?]
        |-- NO --> Document rationale for no remediation
        |-- YES --> [Remediation Protocol REQUIRED]
              |     - Containment requirements
              |     - PPE requirements
              |     - Removal methodology
              |     - Waste disposal procedures
              |     - HVAC isolation requirements
              |     - Post-remediation verification plan
              |     - Clearance criteria
              v
            [Post-Remediation Assessment Required]
              - Re-sampling plan
              - Visual re-inspection criteria
              - Clearance standards
```

### B.4 MRSA License Validation Requirements

| Requirement | Reference | Notes |
|-------------|-----------|-------|
| Mold assessor must hold active MRSA license | s. 468.8414, F.S. | Requires external verification |
| Mold assessor and remediator must be different entities | s. 468.8415, F.S. | Conflict of interest prohibition |
| License number displayed on all reports | s. 468.8419, F.S. | Requires external verification |
| Assessor must carry required insurance | s. 468.8420, F.S. | Requires external verification |
| Assessment must follow DBPR-approved standards | s. 468.8414, F.S. | Requires external verification |

---

## Section C: General Home Inspection Report (fullinspection.doc)

### C.1 Document Structure

The fullinspection.doc is a comprehensive Residential Property Inspection Agreement and Report template with the following structure:

| # | Section | Type | Description |
|---|---------|------|-------------|
| -- | Header | Data fields | Property address, date, time, report number, customer name |
| -- | Inspection Agreement | Boilerplate + customer data | Legally binding contract, scope, exclusions, indemnity |
| -- | Scope of Services | Boilerplate | Defines non-invasive visual inspection |
| -- | Exclusions (1-16) | Boilerplate | 16 detailed exclusion categories |
| -- | Inspector Qualifications | Boilerplate | Generalist disclaimer |
| -- | Indemnity | Boilerplate | Customer indemnification of inspector |
| -- | Severability | Boilerplate | Contract severability clause |
| -- | Copies/Confidentiality | Boilerplate | Report confidentiality terms |
| -- | Dispute Resolution | Boilerplate | 10-day written notice requirement |
| -- | Mediation | Boilerplate | Non-binding mediation first |
| -- | Arbitration | Boilerplate + initials | Binding arbitration under AAA rules |
| -- | Statute of Limitations | Boilerplate + initials | 1-year limitation period |
| -- | Waiver/Liquidated Damages | Boilerplate + initials | Liability capped at 4x inspection fee |
| -- | Acceptance/Signatures | Signature fields | Inspector and customer signatures |
| -- | Payment | Data fields | Fee, payment method, card info |
| R | Roof/Deck | Inspection table | Condition/Flashing/Truss/Age/Downspouts/Chimney/etc. |
| E | Electrical | Inspection table | Service Line/Panel/Breakers/GFCI/Grounding/etc. |
| P | Plumbing System | Inspection table | Main Line/Water Line/Shut-Off/Pressure/Waste/Fuel |
| WH | Water Heater | Inspection table | Heater/TPR Valve/Shut-Off/Seismic/Vent/etc. |
| H | Heating System | Inspection table | Burner/Venting/Duct/Filters/Thermostat/Distribution |
| AC | Air Conditioning | Inspection table | Compressor/Filter/Blower/Duct/Electrical/Base |

**Note**: The fullinspection.doc template appears to be incomplete -- it contains detailed sections for Roof, Electrical, Plumbing, Water Heater, and HVAC but the Structure/Exterior/Interior/Appliance inspection table sections were not fully extracted. The agreement portion is complete.

> **INCOMPLETE**: The following 6 sections have checkpoint items derived from Rule 61-30.801 requirements, NOT from the fullinspection.doc template itself (due to document formatting extraction issues):
> - Structure/Foundation (Rule 61-30.801(1))
> - Exterior (Rule 61-30.801(2))
> - Interior (Rule 61-30.801(3))
> - Insulation/Ventilation (Rule 61-30.801(7))
> - Built-in Appliances (Rule 61-30.801(8))
> - Life Safety (Rule 61-30.801(9))
>
> Phase 2 should design the schema with extension points for additional checkpoints that may be present in the actual template but were not extracted. The 6 complete sections (Roof, Electrical, Plumbing, Water Heater, Heating, Air Conditioning) were fully extracted from fullinspection.doc and are authoritative.

### C.2 Report Header Data Fields

| Field Name | Type | Required | Notes |
|------------|------|----------|-------|
| Property Address | String | Yes | Street, unit, city, state, zip |
| Property Description | String | No | Additional property details |
| Date | Date | Yes | Inspection date |
| Time | Time | Yes | With AM/PM |
| Inspection Report Number | String | Yes | Unique report identifier |
| Customer Name(s) | String | Yes | One or more customer names |
| Inspector Company | String | Yes | Inspection company name |
| Inspector Name | String | Yes | Individual inspector |
| Inspection Fee | Currency | Yes | Total fee amount |
| Payment Method | Enum | Yes | Cash / Check / Credit Card |

### C.3 Inspection Rating System

The fullinspection.doc uses a three-tier rating system (different from HUD's multi-code system):

| Code | Meaning | Description |
|------|---------|-------------|
| GOOD | Satisfactory | Component is in acceptable working condition |
| FAIR | Marginal | Component functions but shows wear or minor deficiency |
| POOR | Deficient | Component requires repair or replacement |
| N/A | Not Applicable | Component not present or not inspected |

### C.4 Required Inspection Sections per Rule 61-30.801

| Section | Subsections | Statutory Reference | Min Requirements |
|---------|-------------|---------------------|------------------|
| Roof/Deck | Condition, Flashing, Truss/rafter condition, Estimated age, Downspouts, Chimney, Flat/Low Slope, Vents/Vent Caps, Skylights | Rule 61-30.801(1) | Visual from ground, ladder, or traversed; method noted |
| Electrical | Service Line, Main Panel, Breakers, Fuses, Conductors, Sub-Panel(s), Wiring, GFCI, Grounding, Lights, Outlets, Switches | Rule 61-30.801(5) | Representative sample of outlets/switches |
| Plumbing System | Main Line, Water Line, Main Shut-Off, Water Pressure, Pressure Regulator, Pressure Relief Valve, Waste Disposal, Waste Line, Sump Pump, Water Softener, Anti-Siphon Device, Hose Bib, Fuel Line(s) | Rule 61-30.801(4) | Operate fixtures; note leaks |
| Water Heater | Water Heater, TPR Valve, Water Shut-Off Valve, Seismic Straps, Thermal Blanket, Vent Flue, Enclosure, Plumbing, Combustion Air, Venting, Base, Overflow Line | Rule 61-30.801(4) | Check safety devices |
| Heating System | Burner, Venting, Combustion Air, Duct Work, Air Filters, Thermostat/Controls, Distribution, Gas Valve(s) | Rule 61-30.801(6) | Operate if safe; note fuel type |
| Air Conditioning | Compressor(s), Air Filter, Blower, Duct Work, Electrical, Base | Rule 61-30.801(6) | Operate if safe; note capacity |
| Structure/Foundation | Foundation, basement/crawlspace, framing, floors, walls | Rule 61-30.801(1) | Visual observation |
| Exterior | Siding, windows, doors, trim, eaves, decks, fencing, paving | Rule 61-30.801(2) | Within 12 ft of structure |
| Interior | Walls, ceilings, floors, stairs, doors, windows, cabinets | Rule 61-30.801(3) | Representative sample |
| Insulation/Ventilation | Attic insulation, vapor barriers, kitchen/bath venting | Rule 61-30.801(7) | Visual observation |
| Built-in Appliances | Dishwasher, range, disposal, oven, microwave, ventilation | Rule 61-30.801(8) | Operate if possible |
| Life Safety | Smoke detectors, fire extinguishers, safety glass | Rule 61-30.801(9) | Presence and function |

### C.5 Per-Section Data Model

Each inspection section in fullinspection.doc follows this pattern:

```
Section Header
  |-- General Info Fields (type/material/manufacturer/capacity enums)
  |-- Inspection Checkpoint Table
  |     |-- ITEM / AREA
  |     |-- GOOD | FAIR | POOR | N/A (one selected per item)
  |     |-- COMMENTS (free text)
  |-- Limitations/Exclusions (boilerplate per section)
  |-- NOTES / COMMENTS / RECOMMENDATIONS (free text narrative)
```

### C.6 Section-Specific General Info Fields

**Roof**:
- Roof Style: Shed, Single Ply, Gable, Hip, Mansard, Flat/Low-Slope (enum)
- Roof Covering: Asphalt Shingles, Tar & Gravel, Metal Ribbed, Composition, Rolled, Wood Shake, Concrete, Clay, Tile, Slate, Metal, Vinyl, Copper (enum)
- Flashing: None observed, Other (enum)
- Gutters/Downspouts: Aluminum, Galv. steel, Copper, Vinyl, Built-In, Scupper Drain, Complete, Partial, None (enum)
- Method of Observation: Fully Traversed, Viewed from Ladder, Viewed from Ground (enum)

**Electrical**:
- Service Line: Overhead, Underground (enum)
- Number of Conductors: Integer
- Main Panel Location: Exterior, Interior + specific location (string)
- Panel Capacity: 70A, 125A, 150A, 200A, 400A, Undetermined (enum)
- Entrance Cable Conductor: Copper, Aluminum, Undetermined (enum)
- Branch Cable Conductor: Copper, Aluminum, Undetermined (enum)
- Sub-Panel(s): Number of 120V Circuits, Number of 240V Circuits
- GFCI: Present, None/N/A (enum)
- System Ground: Connect to water pipe, Connect to Ufer Rod (enum)

**Plumbing**:
- Main Line Material: Galvanized, Copper, PVC, Lead, Undetermined (enum)
- Diameter: 1/2-inch, 3/4-inch, 1-1/2-inch, Undetermined (enum)
- Main Valve Location: String
- Hose Bib Location(s): East, West, North, South (multi-select)
- Waste Line Material: Cast Iron, Galvanized, ABS, Not fully visible, Other (enum)
- Fuel System: Natural Gas, LPG Tank, Oil Tank + Location (enum)
- Pressure Test: PSI (numeric), Time (string)

**Water Heater**:
- Type: Gas, Electric, Solar, LPG, Undetermined (enum)
- Manufacturer: String
- Capacity: Gallons (numeric)
- Approx. Age: Years (numeric)
- Plumbing Type: Copper, Galvanized, Other (enum)
- Enclosure Type: Galvanized, Wood Frame, Stucco, N/A (enum)
- Fuel System: Natural Gas, Oil Tank/LPG, Electric (enum)
- Base: Concrete, Block, Wood, Metal (enum)

**Heating**:
- Location(s): Up to 3 locations + manufacturers
- Heating Type: Forced Air, Heat Pump, Radiant, Gravity, Wall, Floor Heater (enum)
- Fuel Type: Natural Gas, Electrical, LP-Propane, Undetermined, Solar, Not Inspected, Not Connected (enum)

**Air Conditioning**:
- Location(s): Up to 3 locations + manufacturers
- Type: Heat Pump, Fan Motor, Central Air, One Speed Only, Window/Wall, Swamp Cooler (enum)
- Power: 120V, 240V (enum)
- Electr. Disconnect: Yes/No
- Defects observed: Yes/No

### C.7 Evidence Requirements

| Section | Required Evidence | Notes |
|---------|------------------|-------|
| Overall | Report cover photo of property | Front elevation minimum |
| Roof | Method of observation noted; photos of deficiencies | Tile/slate/metal: perimeter only |
| Electrical | Panel photo; GFCI test results | Representative sample of outlets |
| Plumbing | Pressure test PSI reading; visible leak photos | Note shutoff locations |
| Water Heater | Data plate photo; TPR valve status | Manufacturer/capacity/age |
| HVAC | Unit data plates; filter condition | Both inside and outside units |
| Structure | Foundation type; visible damage photos | Access method noted |
| Exterior | All elevation photos; deficiency close-ups | Weather conditions noted |
| Interior | Room-by-room deficiency photos | Smoke detector presence |
| Appliances | Operating status of each appliance | Missing items noted |

### C.8 Branch Logic per Section

| Condition | Required Action |
|-----------|----------------|
| Rating = POOR | NOTES/COMMENTS/RECOMMENDATIONS section MUST detail the deficiency |
| Rating = FAIR | Comment recommended but not strictly required |
| Safety hazard identified | Immediate action recommendation in NOTES section |
| Component not accessible | Note in Limitations/Exclusions, mark N/A |
| Component not inspected (unsafe) | Note reason; recommend specialist evaluation |
| Smoke detector absent | Life safety finding -- immediate recommendation |
| GFCI absent where required | Safety finding -- recommend installation |
| Visible moisture/water damage | Recommend further evaluation by specialist |
| Evidence of pest/mold | Note as excluded from scope; recommend specialist |
| Structural concern | Recommend structural engineer evaluation |

---

## Section D: Residential Rehabilitation Inspection Guide (residentialmanual.pdf)

### D.1 Document Structure (HUD Reference Manual)

The manual is organized into 7 main chapters plus appendices:

| Chapter | Title | Coverage |
|---------|-------|----------|
| 1 | Site | Drainage, Site Improvements, Outbuildings, Yards/Courts, Flood Regions |
| 2 | Building Exterior | Foundation, Wall Cladding, Windows/Doors, Decks/Porches, Roof Coverings (pitched and low-slope), Skylights, Gutters/Downspouts, Chimneys, Parapets/Gables, Lightning Protection |
| 3 | Building Interior | Basement/Crawlspace, Interior Spaces, Bathrooms, Kitchens, Storage, Stairs/Hallways, Laundries, Fireplaces/Flues, Attics, Thermal Efficiency, Sound Transmission, Asbestos, Lead, Radon, Tornado Safe Room |
| 4 | Structural System | Seismic Resistance, Wind Resistance, Masonry (general, foundations, above-ground), Chimneys, Wood Components, Iron/Steel Components, Concrete Components |
| 5 | Electrical System | Service Entry, Main Panelboard, Branch Circuits |
| 6 | Plumbing System | Water Service Entry, Interior Distribution, DWV Piping, Tank Water Heaters, Tankless Heaters, Wells/Equipment, Septic Systems, Gas Supply |
| 7 | HVAC System | Thermostatic Controls, Fuel-Burning Units, Forced Warm Air, Hydronic, Steam, Electric Resistance, Central AC, Gas-Absorption, Heat Pumps, Evaporative Cooling, Humidifiers, Window AC, Whole House Fans |
| A | Appendix: Fire Effects | Effects of fire on structural systems |
| B | Appendix: Wood Organisms | Wood-inhabiting organisms (termites, fungi, etc.) |
| C | Appendix: Life Expectancy | Housing component life expectancy tables |
| D | Appendix: References | Reference materials |
| E | Appendix: Inspection Record | Blank inspection recording forms |

### D.2 Assessment Flow Charts Referenced

The manual includes capacity assessment flowcharts:
- Figure 4.1: Assessing Structural Capacity
- Figure 5.1: Assessing Electrical Service Capacity
- Figure 6.1: Assessing Water Supply Capacity
- Figure 6.2: Assessing DWV Capacity
- Figure 6.3: Assessing Hot Water Heater Capacity
- Figure 6.4: Assessing Well Capacity
- Figure 6.5: Assessing Septic Capacity
- Figure 7.1: Assessing Heating and Cooling Capacity

### D.3 Key Standards Referenced

| Standard | Application | Notes |
|----------|-------------|-------|
| Local Building Code | All sections | Primary compliance reference |
| NEC (National Electrical Code) | Electrical | Amperage, grounding, GFCI requirements |
| IRC (International Residential Code) | Structural, all systems | General residential standards |
| ASTM Standards | Various materials | Testing and evaluation methods |
| IICRC S520 | Mold remediation | Referenced for mold protocols |
| EPA Guidelines | Environmental hazards | Lead, radon, asbestos |

### D.4 Minimum Inspection Requirements (from manual)

Pre-inspection preparation:
- Check local zoning, setback, height, building coverage
- Determine seismic zone status
- Determine hurricane/tornado risk region
- Determine flood plain status
- Check for hazards in soil/water records

---

## Section E: Cross-Reference -- Fields Shared with Fillable PDF Forms

Fields common between narrative forms and the fillable PDF inspection forms (4-Point, Roof Condition, Wind Mitigation):

| Field | HUD Report | Full Inspection | 4-Point | Roof Condition | Wind Mit |
|-------|-----------|----------------|---------|---------------|----------|
| Property Address | Yes | Yes | Yes | Yes | Yes |
| Inspection Date | Yes | Yes | Yes | Yes | Yes |
| Inspector Name | Yes (Company) | Yes | Yes | Yes | Yes |
| Inspector License # | No (HUD case #) | No (implicit) | Yes | Yes | Yes |
| Client/Customer Name | No (HUD) | Yes | Yes | Yes | Yes |
| Roof Type/Material | Yes | Yes | Yes | Yes | Yes |
| Roof Age | No | Yes (estimated) | Yes | Yes | Yes |
| Electrical Panel Info | Yes | Yes | Yes | N/A | N/A |
| Electrical Capacity | Yes | Yes | Yes | N/A | N/A |
| Plumbing Material | Yes | Yes | Yes | N/A | N/A |
| Water Heater Info | Yes | Yes | Yes | N/A | N/A |
| HVAC Type/Info | Yes | Yes | Yes | N/A | N/A |
| Roof Condition Rating | Yes (S/U/MR) | Yes (Good/Fair/Poor) | Yes | Yes | N/A |
| Photo Evidence | Yes (indexed) | Yes (per section) | Yes | Yes | Yes |
| Building Construction | Yes (wall structure) | Yes | N/A | N/A | Yes |
| Year Built | Yes (see appr.) | No | Yes | Yes | Yes |

### E.1 Data Normalization Notes

- **Rating scales differ**: HUD uses 8-code system (Y/N/S/U/MR/MG/NA/NV); fullinspection.doc uses 4-tier (Good/Fair/Poor/N/A). Both map to a 3-tier normalized model: Satisfactory/Marginal/Deficient + N/A.
- **Inspector identification**: Fillable PDFs require Florida license numbers; HUD report uses company name and case number; fullinspection.doc uses company name with implicit licensing.
- **Property identification**: All forms use full street address. HUD adds case number. Fillable PDFs may add policy/file numbers.

---

## Verification

- [x] Inventory file exists at `.planning/phases/01-ground-truth-extraction/01-04-NARRATIVE-FORMS.md`
- [x] Mold assessment covers Chapter 468, Part XVI required elements (Section B, with external verification caveat)
- [x] General inspection covers Rule 61-30.801 required sections (Sections C.4, C.5)
- [x] Evidence requirements documented for both form types (Sections A.6, B.2, C.7)
- [x] Branch/conditional logic mapped for both (Sections A.7, B.3, C.8)

## Decisions

1. **HUDreport.doc reclassified**: The document is a HUD REO Property Condition Report, not a mold assessment. Documented as-is with mold-related elements noted separately.
2. **MRSA requirements sourced from statutory knowledge**: No dedicated mold assessment form was found in the provided docs. Chapter 468, Part XVI requirements are documented but flagged as requiring external verification.
3. **Rating scale normalization**: Documented the two different rating systems and proposed a 3-tier normalized model for the app's data layer.

## Issues

1. **Missing mold assessment template**: No document in `docs/` corresponds to a Florida MRSA-compliant mold assessment report. A dedicated template should be sourced for Phase 2 if mold assessments are in scope.
2. **Incomplete fullinspection.doc extraction**: The Structure, Exterior, Interior, and Appliances inspection table sections from fullinspection.doc were not fully rendered by antiword (the template's table formatting in these sections may use complex layouts). The Roof, Electrical, Plumbing, Water Heater, and HVAC sections extracted cleanly.
3. **residentialmanual.pdf is a federal reference**: It provides technical inspection guidance but does not define Florida-specific statutory requirements. Florida Rule 61-30.801 compliance should be verified against the actual rule text.

## Errors

- None (all documents were readable; limitations noted above are data gaps, not processing errors).
