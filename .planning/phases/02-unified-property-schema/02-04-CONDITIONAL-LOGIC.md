# 02-04: Conditional Logic Model for All 7 Form Types

> **Plan**: 02-04
> **Phase**: 2 -- Unified Property Schema Design
> **Date**: 2026-03-07
> **Agent**: Senior Developer

---

## 1. Overview

This document defines all branch predicates (conditional logic flags) for the 4 new form types (WDO, Sinkhole, Mold Assessment, General Inspection) and documents the existing 3 form types' branch predicates for completeness. Each predicate maps a trigger condition to affected schema paths, evidence requirements, and regulatory citations.

Branch predicates operate on `WizardProgressSnapshot.branchContext` (`Map<String, dynamic>`). The controller layer derives boolean flags from form data values and writes them to `branchContext`. `FormRequirements` evaluates evidence requirements against these flags via `EvidencePredicate` functions.

---

## 2. Existing Branch Predicates (3 Forms -- Unchanged)

These are already implemented in `form_requirements.dart` and documented here for cross-reference.

### 2.1 Four-Point Inspection (Insp4pt 03-25)

| # | Branch Flag | Trigger Condition | Affected Fields | Schema Path (Trigger) | Regulatory Citation |
|---|------------|-------------------|-----------------|----------------------|---------------------|
| E1 | `hazard_present` | Inspector identifies a hazard during inspection | `photo:hazard_photo` evidence requirement becomes active | `fourPoint.hazards.present` (bool) | OIR-accepted industry standard; photo documentation required for underwriting |

**Additional implicit branches** (not currently modeled as flags -- field-level conditionals):

| # | Condition | Affected Fields | Schema Path | Notes |
|---|-----------|-----------------|-------------|-------|
| E1.a | Second electrical panel exists | 6 second panel fields (type, amps, sufficiency, age, year updated, brand) | `fourPoint.electrical.secondPanel*` | UI shows/hides second panel section |
| E1.b | Secondary roof covering present | All secondary roof fields (mirror of primary) | `fourPoint.roof.secondary*` | UI shows/hides secondary roof section |
| E1.c | Any plumbing fixture rated Unsatisfactory | Comments field for fixtures | `fourPoint.plumbing.fixtureUnsatisfactoryComments` | Requires explanation text |
| E1.d | Aluminum branch wiring present | COPALUM and AlumiConn checkbox fields | `fourPoint.electrical.copalumCrimp`, `fourPoint.electrical.alumiconn` | Sub-branch of aluminum wiring detection |
| E1.e | Space heater as primary heat source | Portable heat source question | `fourPoint.hvac.hazardSourcePortable` | Sub-branch of space heater hazard |
| E1.f | Roof updated (full or partial) | Replacement percentage field | `fourPoint.roof.primaryReplacementPct` | Only when partial replacement selected |

### 2.2 Roof Condition (RCF-1 03-25)

| # | Branch Flag | Trigger Condition | Affected Fields | Schema Path (Trigger) | Regulatory Citation |
|---|------------|-------------------|-----------------|----------------------|---------------------|
| E2 | `roof_defect_present` | Inspector identifies a roof defect | `photo:roof_defect` evidence requirement becomes active | `roofCondition.roof.defectPresent` (bool) | Florida insurance industry standard |

### 2.3 Wind Mitigation (OIR-B1-1802)

| # | Branch Flag | Trigger Condition | Affected Fields | Schema Path (Trigger) | Regulatory Citation |
|---|------------|-------------------|-----------------|----------------------|---------------------|
| E3 | `wind_roof_deck_document_required` | Inspector needs to provide supporting documentation for roof deck attachment | `document:wind_roof_deck` evidence requirement | `windMit.q3.documentRequired` (bool) | OIR-B1-1802 Rev 04/26 |
| E4 | `wind_opening_document_required` | Inspector needs to provide supporting documentation for opening protection | `document:wind_opening_protection` evidence requirement | `windMit.q7.documentRequired` (bool) | OIR-B1-1802 Rev 04/26 |
| E5 | `wind_permit_document_required` | Inspector needs to provide supporting documentation for permit/age | `document:wind_permit_year` evidence requirement | `windMit.q2.documentRequired` (bool) | OIR-B1-1802 Rev 04/26 |

---

## 3. New Branch Predicates: WDO (FDACS-13645)

**Regulatory Authority**: Rule 5E-14.142, F.A.C.; Chapter 482, F.S.

### 3.1 Primary Branch Flags

| # | Branch Flag | Trigger Condition | Affected Fields | Schema Path (Trigger) | Regulatory Citation |
|---|------------|-------------------|-----------------|----------------------|---------------------|
| W1 | `wdo_visible_evidence` | Section 2.B selected (VISIBLE evidence of WDOs observed) -- mutually exclusive with 2.A (no visible signs) | Sub-checks B.1, B.2, B.3 become available; at least one must be checked | `wdo.findings.visibleEvidence` (bool) | FDACS-13645 Section 2; Rule 5E-14.142 |
| W2 | `wdo_live_wdo` | Section 2.B.1 checked (LIVE WDOs found) | Description field: common name + location | `wdo.findings.liveWdo` (bool) | FDACS-13645 Section 2.B.1 |
| W3 | `wdo_evidence_of_wdo` | Section 2.B.2 checked (EVIDENCE of WDOs found) | Description field: common name + description + location | `wdo.findings.evidenceOfWdo` (bool) | FDACS-13645 Section 2.B.2 |
| W4 | `wdo_damage_by_wdo` | Section 2.B.3 checked (DAMAGE caused by WDOs) | Description field: common name + description + location of damage | `wdo.findings.damageByWdo` (bool) | FDACS-13645 Section 2.B.3 |
| W5 | `wdo_previous_treatment` | Section 4.1 = Yes (evidence of previous treatment observed) | Previous treatment description field | `wdo.treatment.previousTreatment` (bool) | FDACS-13645 Section 4.1; Chapter 482, F.S. |
| W6 | `wdo_treated_at_inspection` | Section 4.3 = Yes (company treated structure at time of inspection) | Organism, pesticide, terms, method, treatment notice location fields | `wdo.treatment.treatedAtInspection` (bool) | FDACS-13645 Section 4.3; Chapter 482, F.S. |

### 3.2 Inaccessible Area Flags (5 independent toggles)

| # | Branch Flag | Trigger Condition | Affected Fields | Schema Path (Trigger) | Regulatory Citation |
|---|------------|-------------------|-----------------|----------------------|---------------------|
| W7 | `wdo_attic_inaccessible` | Section 3.1 checked | Specific areas + reason text fields | `wdo.inaccessible.attic.flag` (bool) | FDACS-13645 Section 3 |
| W8 | `wdo_interior_inaccessible` | Section 3.2 checked | Specific areas + reason text fields | `wdo.inaccessible.interior.flag` (bool) | FDACS-13645 Section 3 |
| W9 | `wdo_exterior_inaccessible` | Section 3.3 checked | Specific areas + reason text fields | `wdo.inaccessible.exterior.flag` (bool) | FDACS-13645 Section 3 |
| W10 | `wdo_crawlspace_inaccessible` | Section 3.4 checked | Specific areas + reason text fields | `wdo.inaccessible.crawlspace.flag` (bool) | FDACS-13645 Section 3 |
| W11 | `wdo_other_inaccessible` | Section 3.5 checked | Specific areas + reason text fields | `wdo.inaccessible.other.flag` (bool) | FDACS-13645 Section 3 |

### 3.3 Treatment Method Sub-Branch

| # | Branch Flag | Trigger Condition | Affected Fields | Schema Path (Trigger) | Regulatory Citation |
|---|------------|-------------------|-----------------|----------------------|---------------------|
| W12 | `wdo_spot_treatment` | Section 4.3e checked (spot treatment selected; mutually exclusive with 4.3d whole structure) | Spot treatment description field | `wdo.treatment.methodSpotTreatment` (bool) | FDACS-13645 Section 4.3e |

### 3.4 Branch Hierarchy

```
Section 2 Findings:
  +-- [2.A] No visible signs    --> W1 = false --> Skip B.1/B.2/B.3
  +-- [2.B] Visible evidence    --> W1 = true
       +-- [B.1] Live WDOs?     --> W2 = true --> description field required
       +-- [B.2] Evidence?      --> W3 = true --> description field required
       +-- [B.3] Damage?        --> W4 = true --> description field required
       (at least one of W2/W3/W4 must be true when W1 is true)

Section 3 Inaccessible Areas (all independent):
  +-- Attic?       --> W7  = true --> specific areas + reason required
  +-- Interior?    --> W8  = true --> specific areas + reason required
  +-- Exterior?    --> W9  = true --> specific areas + reason required
  +-- Crawlspace?  --> W10 = true --> specific areas + reason required
  +-- Other?       --> W11 = true --> specific areas + reason required

Section 4 Treatment:
  +-- Previous treatment?        --> W5 = true --> description required
  +-- Treated at inspection?     --> W6 = true
       +-- Whole structure?      --> W12 = false
       +-- Spot treatment?       --> W12 = true --> scope description required
```

### 3.5 Validation Rules

| Rule | Enforcement | Citation |
|------|-------------|----------|
| Exactly one of 2.A or 2.B must be selected | Mutex validation: `wdo.findings.noVisibleSigns` XOR `wdo.findings.visibleEvidence` | FDACS-13645 Section 2 |
| If 2.B selected, at least one of B.1/B.2/B.3 | `W1 == true` implies `W2 OR W3 OR W4` | FDACS-13645 Section 2.B |
| Each checked sub-item requires non-empty description | `W2 == true` implies `liveWdoDescription` non-empty | FDACS-13645 Section 2.B.1a-B.3a |
| Treatment method is mutex | `wdo.treatment.methodWholeStructure` XOR `wdo.treatment.methodSpotTreatment` | FDACS-13645 Section 4.3d/4.3e |
| Form integrity: no additional disclaimers allowed | Enforced at PDF generation; no user-facing field | Rule 5E-14.142 |
| Notice of Inspection location always required (field 4.2) | Not conditional; always present | Chapter 482, F.S. |

---

## 4. New Branch Predicates: Sinkhole (Citizens)

**Regulatory Authority**: Citizens Property Insurance Corporation; FL Stat 627.706-627.7074

### 4.1 Checklist Item Branches (19 yes/no/NA items)

Each of the 19 checklist items across Sections 1-4 follows the same pattern: a "Yes" answer activates a detail text field. Rather than modeling 19 individual branch flags, the predicate system uses a **pattern-based approach**: the branch flag is derived from the item's tri-state value.

| # | Branch Flag Pattern | Trigger Condition | Affected Fields | Schema Path Pattern | Regulatory Citation |
|---|---------------------|-------------------|-----------------|---------------------|---------------------|
| S1 | `sinkhole_item_{section}_{number}_yes` | Checklist item answered "Yes" | Detail text field for that item | `sinkhole.{section}.item{M}` = "yes" | Citizens Sinkhole Form ver. 2, Ed. 6/2012 |

**Concrete instances (19 items)**:

| Section | Items | Branch Flags (derived from item value) | Detail Fields Activated |
|---------|-------|---------------------------------------|------------------------|
| 1: Exterior | 1.1-1.5 (5 items) | `sinkhole_item_1_1_yes` through `sinkhole_item_1_5_yes` | `sinkhole.exterior.item1Detail` through `sinkhole.exterior.item5Detail` |
| 2: Interior | 2.1-2.8 (8 items) | `sinkhole_item_2_1_yes` through `sinkhole_item_2_8_yes` | `sinkhole.interior.item1Detail` through `sinkhole.interior.item8Detail` |
| 3: Garage | 3.1-3.2 (2 items) | `sinkhole_item_3_1_yes` through `sinkhole_item_3_2_yes` | `sinkhole.garage.item1Detail` through `sinkhole.garage.item2Detail` |
| 4: Appurtenant | 4.1-4.4 (4 items) | `sinkhole_item_4_1_yes` through `sinkhole_item_4_4_yes` | `sinkhole.appurtenant.item1Detail` through `sinkhole.appurtenant.item4Detail` |

**Design decision**: Rather than register all 19 flags in `canonicalBranchFlags`, use a **predicate function** that reads the item value directly from `branchContext`. This avoids canonicalBranchFlags bloat while maintaining the existing pattern. The controller derives detail-field visibility from the item's tri-state value without needing a separate boolean flag.

### 4.2 Section-Level Aggregate Flags

These higher-level flags aggregate across checklist items for evidence requirement purposes:

| # | Branch Flag | Trigger Condition | Affected Fields | Schema Path (Trigger) | Regulatory Citation |
|---|------------|-------------------|-----------------|----------------------|---------------------|
| S2 | `sinkhole_any_exterior_yes` | Any Section 1 item (1.1-1.5) = "Yes" | Per-item close-up + perspective photos | Derived: any `sinkhole.exterior.item{N}` == "yes" | Citizens form instructions |
| S3 | `sinkhole_any_interior_yes` | Any Section 2 item (2.1-2.8) = "Yes" | Per-item close-up + perspective photos | Derived: any `sinkhole.interior.item{N}` == "yes" | Citizens form instructions |
| S4 | `sinkhole_any_garage_yes` | Any Section 3 item (3.1-3.2) = "Yes" | Per-item photos showing crack pattern | Derived: any `sinkhole.garage.item{N}` == "yes" | Citizens form instructions |
| S5 | `sinkhole_any_appurtenant_yes` | Any Section 4 item (4.1-4.4) = "Yes" | Per-item photos | Derived: any `sinkhole.appurtenant.item{N}` == "yes" | Citizens form instructions |
| S6 | `sinkhole_any_yes` | Any checklist item across all sections = "Yes" | General finding documentation | Derived: S2 OR S3 OR S4 OR S5 | FL Stat 627.706 |

### 4.3 Additional Conditional Flags

| # | Branch Flag | Trigger Condition | Affected Fields | Schema Path (Trigger) | Regulatory Citation |
|---|------------|-------------------|-----------------|----------------------|---------------------|
| S7 | `sinkhole_townhouse` | Property type is townhouse or row house | Adjacent building description (Section 5.2) + photo of adjoining structures within 1/4 mile | `sinkhole.additional.propertyType` == "townhouse" or "row_house" | Citizens form Section 5.2 |
| S8 | `sinkhole_unable_to_schedule` | Inspection could not be completed | Scheduling attempts section (Section 6), explanation field (Section 5.5) | `sinkhole.additional.unableToSchedule` (bool) | Citizens form Section 5.5/6 |
| S9 | `sinkhole_crack_significant` | Any crack >= 1/8 inch | Owner interview fields: first occurrence date, change timeline | Derived from detail fields where crack width >= 0.125 | FL Stat 627.7072 |

### 4.4 Branch Hierarchy

```
Sections 1-4 Checklist:
  For each of 19 items:
    +-- "Yes"  --> Detail text field required
    |            +-- If crack: width + length measurements required
    |            +-- If crack >= 1/8": owner interview (first occurrence, timeline) [S9]
    |            +-- Close-up + perspective photos required
    +-- "No"   --> No detail required
    +-- "N/A"  --> No detail required

Section 5 Additional Information:
  +-- General condition (5.1)    --> Always required
  +-- Townhouse/row house? [S7]  --> Adjacent building description + photo
  +-- Nearest sinkhole (5.3)     --> Always required
  +-- Other findings (5.4)       --> Always required
  +-- Unable to schedule? [S8]   --> Explanation + scheduling attempts

Section 6 Scheduling Attempts:
  +-- Only shown when S8 = true
  +-- 4 attempt blocks (date, time, number called, result)
```

### 4.5 Validation Rules

| Rule | Enforcement | Citation |
|------|-------------|----------|
| Every checklist item must have a response (Yes/No/NA) | All 19 items required | Citizens form instructions |
| "Yes" items require non-empty detail text | Field-level validation | Citizens form instructions |
| Cracks require width and length measurements | Detail text validation/prompting | Citizens form instructions |
| N/A is appropriate when component does not exist (e.g., no pool for pool items) | UI guidance | Citizens form (inferred -- GAP-5 from 01-03) |

---

## 5. New Branch Predicates: Mold Assessment (Chapter 468, Part XVI)

**Regulatory Authority**: Florida Statutes Chapter 468, Part XVI (MRSA); DBPR

**Confidence Level**: Statutory knowledge -- requires external verification against actual statute text.

### 5.1 Primary Branch Flags

| # | Branch Flag | Trigger Condition | Affected Fields | Schema Path (Trigger) | Regulatory Citation |
|---|------------|-------------------|-----------------|----------------------|---------------------|
| M1 | `mold_visible_found` | Visible mold growth identified during assessment | Mold locations, extent, materials affected documentation | `mold.findings.visibleMoldFound` (bool) | s. 468.8414, F.S. |
| M2 | `mold_moisture_source_found` | Moisture source identified | Moisture source list: location, type, severity | `mold.findings.moistureSourceFound` (bool) | s. 468.8414, F.S. |
| M3 | `mold_samples_taken` | Air, surface, or bulk samples collected | Lab results section: lab name, report number, species ID, chain of custody | `mold.sampling.samplesTaken` (bool) | s. 468.8414, F.S. |
| M4 | `mold_air_samples_taken` | Air samples specifically collected | Air sample lab results | `mold.sampling.airSamplesTaken` (bool) | s. 468.8414, F.S. |
| M5 | `mold_surface_samples_taken` | Surface samples collected | Surface sample lab results, species identification | `mold.sampling.surfaceSamplesTaken` (bool) | s. 468.8414, F.S. |
| M6 | `mold_bulk_samples_taken` | Bulk material samples collected | Bulk sample lab results, material analysis | `mold.sampling.bulkSamplesTaken` (bool) | s. 468.8414, F.S. |
| M7 | `mold_remediation_recommended` | Assessor recommends remediation | Full remediation protocol section (containment, PPE, removal method, waste disposal, HVAC isolation, clearance criteria) | `mold.remediation.recommended` (bool) | s. 468.8414, F.S. |
| M8 | `mold_post_remediation` | Post-remediation assessment being performed (remediation was previously completed) | Re-sampling plan, visual re-inspection criteria, clearance standards | `mold.remediation.postRemediation` (bool) | s. 468.8414, F.S. |

### 5.2 Branch Hierarchy

```
Visual Inspection:
  +-- Visible mold found? [M1]
  |    +-- Yes --> Document locations, extent, materials
  |    +-- No  --> Document negative findings
  |
  +-- Moisture source found? [M2]
       +-- Yes --> Document sources (location, type, severity)
       +-- No  --> Document no moisture sources found

Sampling:
  +-- Samples taken? [M3]
       +-- No  --> Note "no sampling performed" with rationale
       +-- Yes --> Which types?
            +-- Air samples? [M4]     --> Lab results, chain of custody
            +-- Surface samples? [M5] --> Lab results, species ID
            +-- Bulk samples? [M6]    --> Lab results, material analysis
            +-- Lab name + report number required for all

Conclusion:
  +-- Remediation recommended? [M7]
       +-- No  --> Document rationale
       +-- Yes --> Remediation Protocol REQUIRED:
            |     - Containment requirements
            |     - PPE requirements
            |     - Removal methodology
            |     - Waste disposal procedures
            |     - HVAC isolation requirements
            |     - Post-remediation verification plan
            |     - Clearance criteria
            |     - Re-occupancy criteria
            v
  +-- Post-remediation assessment? [M8]
       +-- Yes --> Re-sampling plan, visual criteria, clearance
       +-- No  --> N/A (first assessment)
```

### 5.3 Validation Rules

| Rule | Enforcement | Citation |
|------|-------------|----------|
| MRSA license number required on every page/cover | Always required; not conditional | s. 468.8419, F.S. |
| Assessor and remediator must be different entities | Informational constraint; UI warning | s. 468.8415, F.S. |
| Moisture readings required for all assessed areas | Always required regardless of findings | s. 468.8414, F.S. |
| Areas not assessed must be documented with reason | Always required (list field) | s. 468.8414, F.S. |
| If samples taken, lab must be AIHA-accredited | Lab name validation/advisory | s. 468.8414, F.S. |
| If remediation recommended, full protocol required | M7 = true implies all protocol fields | s. 468.8414, F.S. |

---

## 6. New Branch Predicates: General Home Inspection (Rule 61-30.801)

**Regulatory Authority**: Rule 61-30.801, F.A.C. (Standards of Practice for Home Inspectors)

### 6.1 Per-Section Rating-Based Flags

The General Inspection has 12 sections, each with a checkpoint table using Good/Fair/Poor/N/A ratings. The primary conditional logic is rating-driven:

| # | Branch Flag Pattern | Trigger Condition | Affected Fields | Schema Path Pattern | Regulatory Citation |
|---|---------------------|-------------------|-----------------|---------------------|---------------------|
| G1 | `general_{section}_has_poor` | Any checkpoint in section rated "Poor" | Section-level narrative explanation required in Notes/Comments/Recommendations | Derived: any `general.{section}.checkpoints[*].rating` == "poor" | Rule 61-30.801; fullinspection.doc Section C.8 |
| G2 | `general_{section}_has_na` | Any checkpoint in section marked "N/A" | Reason for N/A required (component not present or not accessible) | Derived: any `general.{section}.checkpoints[*].rating` == "na" | Rule 61-30.801 |

**Concrete section instances** (12 sections):

| Section | Flag Prefix | Checkpoint Count | Source |
|---------|-------------|------------------|--------|
| Roof/Deck | `general_roof_` | 9 | fullinspection.doc (confirmed) |
| Electrical | `general_electrical_` | 12 | fullinspection.doc (confirmed) |
| Plumbing | `general_plumbing_` | 13 | fullinspection.doc (confirmed) |
| Water Heater | `general_waterheater_` | 12 | fullinspection.doc (confirmed) |
| Heating | `general_heating_` | 8 | fullinspection.doc (confirmed) |
| Air Conditioning | `general_ac_` | 6 | fullinspection.doc (confirmed) |
| Structure/Foundation | `general_structure_` | 5 | Rule 61-30.801(1) (rule-derived) |
| Exterior | `general_exterior_` | 8 | Rule 61-30.801(2) (rule-derived) |
| Interior | `general_interior_` | 7 | Rule 61-30.801(3) (rule-derived) |
| Insulation/Ventilation | `general_insulation_` | 3 | Rule 61-30.801(7) (rule-derived) |
| Built-in Appliances | `general_appliances_` | 6 | Rule 61-30.801(8) (rule-derived) |
| Life Safety | `general_safety_` | 3 | Rule 61-30.801(9) (rule-derived) |

**Design decision**: Like the Sinkhole pattern, section-level "has poor" flags are **derived at runtime** by scanning the checkpoint array rather than stored as individual canonical branch flags. This avoids 24+ branch flags (12 sections x 2 flag types) in `canonicalBranchFlags`.

### 6.2 Cross-Section Aggregate Flags

| # | Branch Flag | Trigger Condition | Affected Fields | Schema Path (Trigger) | Regulatory Citation |
|---|------------|-------------------|-----------------|----------------------|---------------------|
| G3 | `general_safety_hazard` | Any safety hazard identified in any section | Immediate action recommendation in report | Derived: any checkpoint flagged as safety hazard, or Life Safety section has "Poor" items | Rule 61-30.801(9) |
| G4 | `general_not_accessible` | Any component marked as not accessible in any section | Documented in Limitations/Exclusions; recommend specialist evaluation | Derived: any checkpoint with rating "N/A" and reason = "not accessible" | Rule 61-30.801 |
| G5 | `general_moisture_mold_evidence` | Visible moisture, water damage, or mold evidence observed | Specialist referral recommendation; note as excluded from home inspection scope | `general.findings.moistureMoldEvidence` (bool) | Rule 61-30.801; fullinspection.doc C.8 |
| G6 | `general_pest_evidence` | Evidence of pest or wood-destroying organism activity | Specialist referral recommendation (WDO inspector); note as excluded from scope | `general.findings.pestEvidence` (bool) | Rule 61-30.801; fullinspection.doc C.8 |
| G7 | `general_structural_concern` | Significant structural issue identified (foundation, framing, load-bearing) | Structural engineer evaluation recommendation | `general.findings.structuralConcern` (bool) | Rule 61-30.801(1); fullinspection.doc C.8 |

### 6.3 Branch Hierarchy

```
For each of 12 sections:
  For each checkpoint item:
    +-- "Good"  --> No additional action
    +-- "Fair"  --> Comment recommended (not required)
    +-- "Poor"  --> G1: Narrative explanation REQUIRED in Notes section
    +-- "N/A"   --> G2: Reason required (not present vs not accessible)
                     +-- If not accessible --> G4 aggregate flag set

Cross-section findings:
  +-- Safety hazard? [G3]    --> Immediate recommendation
  +-- Moisture/mold? [G5]    --> Specialist referral
  +-- Pest evidence? [G6]    --> WDO inspector referral
  +-- Structural concern? [G7] --> Engineer referral
```

### 6.4 Validation Rules

| Rule | Enforcement | Citation |
|------|-------------|----------|
| Every checkpoint must have a rating | All items required (Good/Fair/Poor/N/A) | Rule 61-30.801 |
| "Poor" rating requires narrative in Notes section | G1 flag triggers validation | fullinspection.doc C.8 |
| Safety hazard requires immediate recommendation | G3 flag triggers recommendation field | Rule 61-30.801(9) |
| Components not inspected (unsafe) require reason + specialist recommendation | G4 flag | Rule 61-30.801 |
| Smoke detector absence is a life safety finding | Automatic G3 trigger | Rule 61-30.801(9) |
| GFCI absence where required is a safety finding | Automatic G3 trigger | Rule 61-30.801(5) |

---

## 7. Complete Branch Flag Registry

### 7.1 Canonical Branch Flags (Registered in FormRequirements.canonicalBranchFlags)

These are the flags that `_canonicalizeBranchContext()` will recognize and preserve:

| # | Flag Name | Form | Type |
|---|-----------|------|------|
| 1 | `hazard_present` | 4-Point | Existing |
| 2 | `roof_defect_present` | RCF-1 | Existing |
| 3 | `wind_roof_deck_document_required` | Wind Mit | Existing |
| 4 | `wind_opening_document_required` | Wind Mit | Existing |
| 5 | `wind_permit_document_required` | Wind Mit | Existing |
| 6 | `wdo_visible_evidence` | WDO | New |
| 7 | `wdo_live_wdo` | WDO | New |
| 8 | `wdo_evidence_of_wdo` | WDO | New |
| 9 | `wdo_damage_by_wdo` | WDO | New |
| 10 | `wdo_previous_treatment` | WDO | New |
| 11 | `wdo_treated_at_inspection` | WDO | New |
| 12 | `wdo_attic_inaccessible` | WDO | New |
| 13 | `wdo_interior_inaccessible` | WDO | New |
| 14 | `wdo_exterior_inaccessible` | WDO | New |
| 15 | `wdo_crawlspace_inaccessible` | WDO | New |
| 16 | `wdo_other_inaccessible` | WDO | New |
| 17 | `wdo_spot_treatment` | WDO | New |
| 18 | `sinkhole_any_exterior_yes` | Sinkhole | New |
| 19 | `sinkhole_any_interior_yes` | Sinkhole | New |
| 20 | `sinkhole_any_garage_yes` | Sinkhole | New |
| 21 | `sinkhole_any_appurtenant_yes` | Sinkhole | New |
| 22 | `sinkhole_any_yes` | Sinkhole | New |
| 23 | `sinkhole_townhouse` | Sinkhole | New |
| 24 | `sinkhole_unable_to_schedule` | Sinkhole | New |
| 25 | `sinkhole_crack_significant` | Sinkhole | New |
| 26 | `mold_visible_found` | Mold | New |
| 27 | `mold_moisture_source_found` | Mold | New |
| 28 | `mold_samples_taken` | Mold | New |
| 29 | `mold_air_samples_taken` | Mold | New |
| 30 | `mold_surface_samples_taken` | Mold | New |
| 31 | `mold_bulk_samples_taken` | Mold | New |
| 32 | `mold_remediation_recommended` | Mold | New |
| 33 | `mold_post_remediation` | Mold | New |
| 34 | `general_safety_hazard` | General | New |
| 35 | `general_moisture_mold_evidence` | General | New |
| 36 | `general_pest_evidence` | General | New |
| 37 | `general_structural_concern` | General | New |

**Total: 37 canonical branch flags** (5 existing + 32 new)

### 7.2 Derived Flags (Not in canonicalBranchFlags -- computed at runtime)

These flags are derived from form data values and do NOT need to be stored in `branchContext`. The predicate functions read the relevant data directly:

| Flag Pattern | Form | Derivation | Count |
|-------------|------|------------|-------|
| `sinkhole_item_{s}_{n}_yes` | Sinkhole | Item value == "yes" | 19 |
| `general_{section}_has_poor` | General | Any checkpoint rating == "poor" | 12 |
| `general_{section}_has_na` | General | Any checkpoint rating == "na" | 12 |
| `general_not_accessible` | General | Any checkpoint N/A reason == "not accessible" | 1 |
| 4-Point implicit branches (E1.a-E1.f) | 4-Point | Field-level conditionals | 6 |

**Total derived: ~50 flags** -- computed, not stored.

### 7.3 branchFlagsByForm Extension

The existing `FormRequirements.branchFlagsByForm` map will be extended:

```dart
static const Map<FormType, List<String>> branchFlagsByForm = {
  FormType.fourPoint: [hazardPresentBranchFlag],
  FormType.roofCondition: [roofDefectPresentBranchFlag],
  FormType.windMitigation: [
    windRoofDeckDocumentRequiredBranchFlag,
    windOpeningDocumentRequiredBranchFlag,
    windPermitDocumentRequiredBranchFlag,
  ],
  FormType.wdo: [
    wdoVisibleEvidenceBranchFlag,
    wdoLiveWdoBranchFlag,
    wdoEvidenceOfWdoBranchFlag,
    wdoDamageByWdoBranchFlag,
    wdoPreviousTreatmentBranchFlag,
    wdoTreatedAtInspectionBranchFlag,
    wdoAtticInaccessibleBranchFlag,
    wdoInteriorInaccessibleBranchFlag,
    wdoExteriorInaccessibleBranchFlag,
    wdoCrawlspaceInaccessibleBranchFlag,
    wdoOtherInaccessibleBranchFlag,
    wdoSpotTreatmentBranchFlag,
  ],
  FormType.sinkholeInspection: [
    sinkholeAnyExteriorYesBranchFlag,
    sinkholeAnyInteriorYesBranchFlag,
    sinkholeAnyGarageYesBranchFlag,
    sinkholeAnyAppurtenantYesBranchFlag,
    sinkholeAnyYesBranchFlag,
    sinkholeTownhouseBranchFlag,
    sinkholeUnableToScheduleBranchFlag,
    sinkholeCrackSignificantBranchFlag,
  ],
  FormType.moldAssessment: [
    moldVisibleFoundBranchFlag,
    moldMoistureSourceFoundBranchFlag,
    moldSamplesTakenBranchFlag,
    moldAirSamplesTakenBranchFlag,
    moldSurfaceSamplesTakenBranchFlag,
    moldBulkSamplesTakenBranchFlag,
    moldRemediationRecommendedBranchFlag,
    moldPostRemediationBranchFlag,
  ],
  FormType.generalInspection: [
    generalSafetyHazardBranchFlag,
    generalMoistureMoldEvidenceBranchFlag,
    generalPestEvidenceBranchFlag,
    generalStructuralConcernBranchFlag,
  ],
};
```

---

## 8. Predicate Implementation Patterns

### 8.1 Simple Boolean Flag (existing pattern)

```dart
// Used for: W1-W12, M1-M8, S7-S8, G3, G5-G7, E1-E5
static EvidencePredicate _boolFlag(String key) {
  return (Map<String, dynamic> branchContext) => branchContext[key] == true;
}
```

### 8.2 Compound Predicate (new pattern for Sinkhole section aggregates)

```dart
// Used for: S2-S6 (aggregate "any yes" flags)
// The controller computes these aggregates and stores them as canonical flags.
// Alternative: could be computed inline, but storing as flags is simpler
// and consistent with the existing pattern.
static EvidencePredicate _boolFlag(String key) {
  return (Map<String, dynamic> branchContext) => branchContext[key] == true;
}
// Same function -- the aggregate flag is pre-computed by the controller.
```

### 8.3 Derived Rating Predicate (new pattern for General Inspection)

```dart
// Used for: G1, G2 (section-level rating checks)
// These are NOT stored as branch flags. Instead, evidence requirements
// for narrative sections use a predicate that checks formData directly.
//
// In FormRequirements, the predicate for "section notes required" would be:
static EvidencePredicate _sectionHasPoor(String sectionKey) {
  return (Map<String, dynamic> branchContext) {
    // The controller pre-computes this as a convenience flag
    return branchContext['general_${sectionKey}_has_poor'] == true;
  };
}
```

**Design decision**: For General Inspection, the controller pre-computes `general_{section}_has_poor` flags and writes them to `branchContext` as regular boolean entries. This keeps the `FormRequirements` predicate evaluation uniform (all predicates check boolean flags) while the complexity of scanning checkpoint arrays stays in the controller. These pre-computed flags are NOT registered in `canonicalBranchFlags` because they are ephemeral (recomputed on every formData change).

---

## 9. Impact on InspectionWizardState._canonicalizeBranchContext()

The `_canonicalizeBranchContext()` method (line 220 of `inspection_wizard_state.dart`) currently filters to only keys present in `FormRequirements.canonicalBranchFlags`. This method will need to be updated to include the 32 new canonical flags.

No structural change is needed -- only the `canonicalBranchFlags` set grows from 5 to 37 entries. The method's filtering logic remains the same.

Additionally, the method should allow pass-through of derived flags (those not in `canonicalBranchFlags`) when they are present in `branchContext`. This is needed for the pre-computed General Inspection section-level flags. Two approaches:

**Option A (recommended)**: Add derived flags to the pass-through. The `_canonicalizeBranchContext()` method retains only canonical flags AND any keys matching known derived flag patterns (e.g., `general_*_has_poor`).

**Option B**: Skip canonicalization for derived flags by having the controller write them to a separate "derived" map. This adds complexity without clear benefit.

**Selected**: Option A. The `_canonicalizeBranchContext()` method will be updated to also pass through keys matching `general_*_has_poor` and `general_*_has_na` patterns.
