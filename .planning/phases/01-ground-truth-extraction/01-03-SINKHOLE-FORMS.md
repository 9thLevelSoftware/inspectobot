# 01-03: Sinkhole Forms Inventory

> Plan: 01-03 | Agent: Technical Writer | Date: 2026-03-07
> Source: `docs/sinkhole.pdf` (3 pages), `docs/citizens4point.pdf` (reviewed for cross-references)

---

## Document Analysis Summary

### Forms Found

| Form | Present | Source File | Pages | Version |
|------|---------|-------------|-------|---------|
| Citizens Sinkhole Inspection Form | Yes | `docs/sinkhole.pdf` | 3 (labeled 2-3 in footer; page 1 missing from PDF) | ver. 2, Ed. 6/2012 |
| FGS Subsidence Incident Report | **No** | Not in `docs/` | N/A | N/A |

### Key Finding: Missing Page 1

The PDF begins at the form's own page 2 ("Citizens Sinkhole Inspection Form ver. 2 Ed. 6/2012 2 | Page"). Page 1 is absent from the document. Based on standard Citizens Insurance form patterns, page 1 almost certainly contains property identification fields (insured name, address, policy number, inspection date, inspector credentials). These fields are reconstructed as **inferred** in the inventory below.

### Citizens 4-Point Cross-Reference

`docs/citizens4point.pdf` is a FloridaContractor 2020 4-Point Inspection Form. It contains zero sinkhole-related sections, questions, or cross-references. No overlap beyond shared property header fields (insured name, address, year built, date inspected).

---

## Form 1: Citizens Sinkhole Inspection Form

**Issuing Entity**: Citizens Property Insurance Corporation
**Form Name**: Citizens Sinkhole Inspection Form
**Version**: ver. 2
**Edition Date**: June 2012
**Total Pages**: 3 (as printed; page 1 missing from PDF)
**Response Format**: Y/N/N-A for checklist items; free-text "Details" column for every "Yes" answer

### Document Structure

| Section | Page (form) | Item Count | Description |
|---------|-------------|------------|-------------|
| *Property Identification (inferred)* | 1 (missing) | ~6-8 fields | Insured name, address, policy, dates, inspector |
| Instructions | 2 | N/A | Detailed guidance for all checklist items |
| Exterior | 2 | 5 items | Yard depressions, adjacent sinkholes, erosion, foundation/wall cracks |
| Interior | 2 | 8 items | Doors, windows, floors, cabinets, walls, ceiling, flooring cracks |
| Garage | 2 | 2 items | Wall-to-slab cracks, floor crack propagation |
| Appurtenant Structures | 2 | 4 items | Sidewalks, driveways, pools, patios |
| Additional Information | 3 | 6 narrative fields | General condition, adjacent buildings, nearest sinkhole, other findings |
| Scheduling Attempts | 3 | 4 attempt blocks | Date, time, number called, result (x4) |

---

### Field Inventory: Section 0 -- Property Identification (INFERRED -- Page 1 Missing)

These fields are inferred from standard Citizens Insurance form patterns and from the form's own references to "insured" and "owner." They must be confirmed when the complete form is obtained.

| # | Field Name | Type | Required | Conditional On | Section | Notes |
|---|-----------|------|----------|----------------|---------|-------|
| 0.1 | Insured/Applicant Name | text | Yes | -- | Property ID | Standard Citizens header field |
| 0.2 | Property Address | text | Yes | -- | Property ID | Full street address of inspected property |
| 0.3 | Policy Number | text | Yes | -- | Property ID | Citizens policy or application number |
| 0.4 | Date of Inspection | date | Yes | -- | Property ID | Date inspector visited property |
| 0.5 | Inspector Name | text | Yes | -- | Property ID | Licensed inspector performing inspection |
| 0.6 | Inspector License Number | text | Yes | -- | Property ID | Florida license number |
| 0.7 | Inspector Company | text | Yes | -- | Property ID | Inspection firm name |
| 0.8 | Inspector Phone | text | Yes | -- | Property ID | Contact number |

> **GAP**: Page 1 of sinkhole.pdf is missing. These fields are best-guess reconstructions. Obtain the full form from Citizens to confirm.

---

### Field Inventory: Section 1 -- Exterior

| # | Field Name | Type | Required | Conditional On | Section | Notes |
|---|-----------|------|----------|----------------|---------|-------|
| 1.1 | Any depression in yard? | yes/no/na | Yes | -- | Exterior | If Yes: close-up + perspective photo; indicate if credible reason visible |
| 1.2 | Any sinkholes or depressions in yard on adjacent properties? | yes/no/na | Yes | -- | Exterior | Assesses neighborhood-level sinkhole activity |
| 1.3 | Any soil erosion around foundation? | yes/no/na | Yes | -- | Exterior | If Yes: indicate if credible reason for erosion visible |
| 1.4 | Cracks in foundation? | yes/no/na | Yes | -- | Exterior | If Yes: width + length measurements; penetration vs cosmetic; patch/re-crack history |
| 1.5 | Cracks in exterior wall? | yes/no/na | Yes | -- | Exterior | If Yes: same crack documentation as 1.4; indicate penetrating vs cosmetic |
| 1.1d-1.5d | Details (per item) | text | Conditional | Corresponding item = "Yes" | Exterior | Free-text per instructions; measurements, photos, history |

### Exterior -- Conditional Detail Requirements (from Instructions)

For any "Yes" answer in this section:

| Condition | Required Detail |
|-----------|----------------|
| Any crack | Width and length measurements |
| Crack patched and re-cracked | How often patched, how many times, how long before recurrence |
| Crack >= 1/8 inch | When first occurred/noted by owner; changes over what time frame |
| Exterior crack | Whether crack penetrates wall or is cosmetic |
| Home painted over cracks, re-cracking occurred | Paint-filled or not; when painted; how long before reappearance |
| Depression/erosion | Whether credible reason is visible |
| Any repair actions | Description of actions taken by insured or prior owner |

---

### Field Inventory: Section 2 -- Interior

| # | Field Name | Type | Required | Conditional On | Section | Notes |
|---|-----------|------|----------|----------------|---------|-------|
| 2.1 | Interior doors out of plumb, uneven, sticking, etc.? | yes/no/na | Yes | -- | Interior | Indicator of foundation movement or settlement |
| 2.2 | Doors/windows out of square? | yes/no/na | Yes | -- | Interior | Frame distortion from structural shift |
| 2.3 | Compression cracks/breaks in windows, doors, frames? | yes/no/na | Yes | -- | Interior | Compression damage from differential settlement |
| 2.4 | Floors out of level or sloped? | yes/no/na | Yes | -- | Interior | Foundation subsidence indicator |
| 2.5 | Attached cabinets pulled away from wall? | yes/no/na | Yes | -- | Interior | Wall movement indicator |
| 2.6 | Cracks on interior walls? | yes/no/na | Yes | -- | Interior | Crack documentation rules apply |
| 2.7 | Cracks on interior ceiling? | yes/no/na | Yes | -- | Interior | Crack documentation rules apply |
| 2.8 | Cracks on flooring or floor tile? | yes/no/na | Yes | -- | Interior | Crack documentation rules apply |
| 2.1d-2.8d | Details (per item) | text | Conditional | Corresponding item = "Yes" | Interior | Same crack measurement/history rules as Exterior |

---

### Field Inventory: Section 3 -- Garage

| # | Field Name | Type | Required | Conditional On | Section | Notes |
|---|-----------|------|----------|----------------|---------|-------|
| 3.1 | Wall-to-slab cracks? | yes/no/na | Yes | -- | Garage | Width + length measurements; photos showing localized vs radiating |
| 3.2 | Floor cracks radiate to wall? | yes/no/na | Yes | -- | Garage | Critical indicator: floor crack propagation to walls suggests subsurface movement |
| 3.1d-3.2d | Details (per item) | text | Conditional | Corresponding item = "Yes" | Garage | Measurements + photos illustrating extent |

---

### Field Inventory: Section 4 -- Appurtenant Structures, Sidewalks, Driveways, Pools, Pool Decks, Patios

| # | Field Name | Type | Required | Conditional On | Section | Notes |
|---|-----------|------|----------|----------------|---------|-------|
| 4.1 | Cracks noted? | yes/no/na | Yes | -- | Appurtenant | Any cracking in external structures |
| 4.2 | Uplift noted? | yes/no/na | Yes | -- | Appurtenant | Ground heave / uplift movement |
| 4.3 | Cracks or damage in pool itself? | yes/no/na | Yes | -- | Appurtenant | Pool shell cracking (sinkhole indicator) |
| 4.4 | Cracks in pool deck or patio? | yes/no/na | Yes | -- | Appurtenant | Surrounding hardscape cracking |
| 4.1d-4.4d | Details (per item) | text | Conditional | Corresponding item = "Yes" | Appurtenant | Same crack documentation rules |

---

### Field Inventory: Section 5 -- Additional Information

| # | Field Name | Type | Required | Conditional On | Section | Notes |
|---|-----------|------|----------|----------------|---------|-------|
| 5.1 | General condition overview | text (multi-line) | Yes | -- | Additional Info | Overall property condition; hazardous/adverse conditions (empty pools, unfenced pools, trampolines, ramps, animals, existing damage) |
| 5.2 | Townhouse/row house adjacent building description | text (multi-line) | Conditional | Property is townhouse or row house | Additional Info | Outside condition of continuous/adjacent buildings within 1/4 mile; photo of adjoining structures required |
| 5.3 | Distance to nearest known sinkhole activity | text | Yes | -- | Additional Info | Distance measurement or "unknown" |
| 5.4 | Other relevant information or findings | text (multi-line) | Yes | -- | Additional Info | Catch-all for anything discovered during inspection |
| 5.5 | Unable to schedule / inspection refused explanation | text (multi-line) | Conditional | Inspection not completed | Additional Info | Detailed explanation if refused |

---

### Field Inventory: Section 6 -- Scheduling Attempts

| # | Field Name | Type | Required | Conditional On | Section | Notes |
|---|-----------|------|----------|----------------|---------|-------|
| 6.1a | 1st Attempt -- Date | date | Conditional | Unable to schedule | Scheduling | |
| 6.1b | 1st Attempt -- Time | time | Conditional | Unable to schedule | Scheduling | |
| 6.1c | 1st Attempt -- Number Called | text | Conditional | Unable to schedule | Scheduling | |
| 6.1d | 1st Attempt -- Result | text | Conditional | Unable to schedule | Scheduling | |
| 6.2a | 2nd Attempt -- Date | date | Conditional | Unable to schedule | Scheduling | |
| 6.2b | 2nd Attempt -- Time | time | Conditional | Unable to schedule | Scheduling | |
| 6.2c | 2nd Attempt -- Number Called | text | Conditional | Unable to schedule | Scheduling | |
| 6.2d | 2nd Attempt -- Result | text | Conditional | Unable to schedule | Scheduling | |
| 6.3a | 3rd Attempt -- Date | date | Conditional | Unable to schedule | Scheduling | |
| 6.3b | 3rd Attempt -- Time | time | Conditional | Unable to schedule | Scheduling | |
| 6.3c | 3rd Attempt -- Number Called | text | Conditional | Unable to schedule | Scheduling | |
| 6.3d | 3rd Attempt -- Result | text | Conditional | Unable to schedule | Scheduling | |
| 6.4a | 4th Attempt -- Date | date | Conditional | Unable to schedule | Scheduling | |
| 6.4b | 4th Attempt -- Time | time | Conditional | Unable to schedule | Scheduling | |
| 6.4c | 4th Attempt -- Number Called | text | Conditional | Unable to schedule | Scheduling | |
| 6.4d | 4th Attempt -- Result | text | Conditional | Unable to schedule | Scheduling | |

---

## Field Count Summary

| Section | Checklist Items | Detail Fields | Scheduling Fields | Total |
|---------|----------------|---------------|-------------------|-------|
| Property ID (inferred) | 0 | 0 | 0 | ~8 (inferred) |
| Exterior | 5 | 5 | 0 | 10 |
| Interior | 8 | 8 | 0 | 16 |
| Garage | 2 | 2 | 0 | 4 |
| Appurtenant Structures | 4 | 4 | 0 | 8 |
| Additional Information | 0 | 5 | 0 | 5 |
| Scheduling Attempts | 0 | 0 | 16 | 16 |
| **Total** | **19** | **24** | **16** | **67 (59 confirmed + 8 inferred)** |

---

## Insurance Trigger Conditions

The Citizens Sinkhole Inspection Form is a claims-investigation tool. The form itself does not contain explicit pass/fail scoring, but the following findings trigger specific insurance actions based on Florida Statute 627.706-627.7074 and Citizens underwriting guidelines:

### Trigger Matrix

| Finding | Insurance Action | Statutory Basis |
|---------|-----------------|-----------------|
| Any "Yes" on Exterior items 1-5 | Requires detailed documentation (measurements, photos, history); may trigger further investigation | Citizens underwriting review |
| Foundation cracks >= 1/8 inch | Elevated concern; requires timeline from owner; may trigger professional geological assessment | FL Stat 627.7072 |
| Floor cracks radiating to walls (Garage 3.2) | Strong sinkhole indicator; likely triggers engineering/geological evaluation | Citizens claims protocol |
| Multiple "Yes" answers across Exterior + Interior + Garage | Cumulative indicator pattern; increases probability of sinkhole-related claim approval | Underwriting pattern analysis |
| Known sinkhole activity within proximity (field 5.3) | Heightened scrutiny; may trigger GPR (Ground Penetrating Radar) or core boring | FL Stat 627.7073 |
| Doors/windows out of square + floors out of level | Differential settlement pattern; strong indicator for subsurface void | Engineering assessment trigger |
| Patched cracks that re-crack repeatedly | Progressive movement indicator; suggests active subsidence | Claims escalation |
| Uplift noted in appurtenant structures (4.2) | Ground heave can indicate sinkhole-related soil displacement | Geological assessment trigger |

### Escalation Pathway

```
Initial Sinkhole Inspection (this form)
    |
    +-- No indicators found --> Claim denied or file closed
    |
    +-- Indicators found -->
         |
         +-- Minor/isolated indicators --> Monitor; possible re-inspection
         |
         +-- Significant indicators (multiple Yes, crack propagation, settlement) -->
              |
              +-- Professional Geological Assessment ordered
              |   (GPR, core borings, soil analysis)
              |
              +-- FGS Subsidence Incident Report filed (if confirmed)
              |
              +-- Engineering Remediation Plan required
              |
              +-- Insurance claim disposition
```

---

## Evidence Requirements

### Photo Requirements (Stated in Form Instructions)

| Evidence Type | When Required | Specifications |
|---------------|--------------|----------------|
| Front elevation photo | Always | General photo of home front |
| Rear elevation photo | Always | General photo of home rear |
| General photos of home | Always | Overall property documentation |
| Close-up photo of each "Yes" item | Any "Yes" answer | Detail view showing specific condition |
| Perspective photo of each "Yes" item | Any "Yes" answer | Context view showing location/extent |
| Garage crack photos | Garage cracks present | Must show if localized or if radiates/extends to walls |
| Adjoining structures photo | Townhouse/row house only | Photo of adjacent/continuous buildings |

### Measurement Requirements

| Measurement | When Required | Format |
|-------------|--------------|--------|
| Crack width | All cracks | Inches (1/8 inch threshold is significant) |
| Crack length | All cracks | Inches or feet |
| Distance to nearest sinkhole | Always | Distance units not specified; likely feet or miles |

### Owner Interview Requirements

| Information | When Required | Purpose |
|-------------|--------------|---------|
| Patch frequency | Patched and re-cracked | How often, how many times |
| Re-crack timeline | Patched and re-cracked | How long before cracking recurs |
| First occurrence date | Cracks >= 1/8 inch | When first occurred or noted |
| Change history | Cracks >= 1/8 inch | Changes occurred and over what time frame |
| Paint history | Home painted over cracks | When painted; how long before reappearance |
| Repair actions taken | Any visible damage | What repairs done by insured or prior owner |

---

## Branch Logic Map

```
START: Citizens Sinkhole Inspection
  |
  +-- Complete Property ID (page 1, inferred)
  |
  +-- Complete Exterior checklist (5 items)
  |     +-- IF any Yes --> provide Details per crack/depression rules
  |     +-- IF crack >= 1/8" --> collect first-occurrence date + change timeline from owner
  |     +-- IF patched/re-cracked --> collect patch frequency + recurrence interval
  |     +-- IF exterior crack --> indicate penetrating vs cosmetic
  |     +-- IF depression/erosion --> indicate credible reason visible
  |
  +-- Complete Interior checklist (8 items)
  |     +-- IF any Yes --> provide Details per same rules
  |
  +-- Complete Garage checklist (2 items)
  |     +-- IF floor cracks --> photos must show localized vs radiating to walls
  |
  +-- Complete Appurtenant Structures checklist (4 items)
  |     +-- IF any Yes --> provide Details
  |
  +-- Complete Additional Information
  |     +-- IF townhouse/row house --> describe adjacent buildings + photo within 1/4 mile
  |     +-- ALWAYS --> provide nearest sinkhole distance
  |
  +-- IF unable to schedule inspection:
        +-- Complete Scheduling Attempts (up to 4)
        +-- IF refused --> provide detailed explanation
```

---

## Shared Fields with Other Form Types

Fields that overlap with 4-Point, Roof Condition, and Wind Mitigation forms:

| Field | Sinkhole Form | 4-Point Form | Overlap Type |
|-------|---------------|--------------|--------------|
| Insured/Applicant Name | Yes (inferred) | Yes | Exact match |
| Property Address | Yes (inferred) | Yes | Exact match |
| Policy Number | Yes (inferred) | Yes (Application/Policy #) | Exact match |
| Date of Inspection | Yes (inferred) | Yes | Exact match |
| Inspector Name | Yes (inferred) | Yes (signature block) | Exact match |
| Inspector License Number | Yes (inferred) | Yes | Exact match |
| Inspector Company | Yes (inferred) | Yes | Exact match |
| General property condition | Yes (field 5.1) | Partial (Additional Comments) | Similar intent |
| Foundation cracks | Yes (Exterior 1.4) | No | Sinkhole-specific |
| Roof condition | No | Yes | 4-Point-specific |

---

## Form 2: FGS Subsidence Incident Report -- GAP DOCUMENTATION

### Status: NOT FOUND in `docs/`

The FGS (Florida Geological Survey) Subsidence Incident Report is not present in the project's document collection. No references to the FGS form appear within `docs/sinkhole.pdf`.

### What the FGS Subsidence Incident Report Should Contain

Based on Florida Geological Survey reporting requirements and Florida Statute 627.7065 (sinkhole reporting):

| Expected Section | Expected Fields | Purpose |
|------------------|----------------|---------|
| Incident Location | Latitude/longitude, street address, county, section/township/range | Precise geolocation for FGS database |
| Incident Date | Date subsidence first observed, date reported | Timeline tracking |
| Property Information | Owner name, parcel ID, land use type | Property identification |
| Subsidence Description | Type (cover-collapse, cover-subsidence, solution), dimensions (diameter, depth), shape | Geological classification |
| Geological Context | Underlying formation, soil type, depth to limestone, water table depth | Geological assessment data |
| Testing Performed | GPR results, core boring logs, soil analysis | Professional geological evaluation |
| Structural Impact | Buildings affected, damage descriptions, estimated cost | Impact assessment |
| Remediation | Grouting, compaction, underpinning performed | Repair documentation |
| Photographs | Aerial/satellite, ground-level, subsurface testing imagery | Visual documentation |
| Reporting Party | Geologist name, license, firm, contact | Professional accountability |

### Recommended Action

Obtain the FGS Subsidence Incident Report form (DEP Form 0520-065 or current equivalent) from the Florida Department of Environmental Protection / Florida Geological Survey. This form is typically filed by licensed professional geologists after a sinkhole is confirmed, not by the initial property inspector. The Citizens Sinkhole Inspection Form is the upstream trigger that may lead to an FGS report.

---

## Expected Commentary Examples (from Form)

The form provides these example commentary patterns that indicate the expected level of detail:

- "Depressions in yard appear to be caused by..."
- "Holes in yard filled several times by owner over past year..."
- "Cracks in structure first appear (approximate time frame)..."
- "Patching was completed and recracking appeared within (time frame)..."
- "Garage floor cracking radiates to exterior walls..."
- "Soil erosion or wash out present, appears to be caused by..."

These examples establish the documentation standard: inspectors must provide causal assessment, timeline, recurrence patterns, and extent/propagation descriptions.

---

## Gaps and Issues

| ID | Issue | Severity | Recommended Action |
|----|-------|----------|--------------------|
| GAP-1 | Page 1 of sinkhole.pdf is missing (property ID fields) | High | Obtain complete Citizens Sinkhole Inspection Form ver. 2 from Citizens Property Insurance |
| GAP-2 | FGS Subsidence Incident Report not in docs/ | Medium | Obtain from FL Dept of Environmental Protection; note this is a downstream form, not inspector-initiated |
| GAP-3 | Form is from 2012 -- may be superseded | Medium | Verify with Citizens whether a newer version exists (form is 14 years old) |
| GAP-4 | No explicit inspector credential requirements stated on visible pages | Low | Likely on missing page 1; Citizens typically requires FL-licensed inspector |
| GAP-5 | No explicit N/A handling rules | Low | Form says "Answer Yes / No / or N/A" but does not define when N/A is appropriate (e.g., no pool = N/A for pool items) |
