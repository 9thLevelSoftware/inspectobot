# 01-02: WDO Form Inventory (FDACS-13645)

## Form Metadata

| Attribute | Value |
|-----------|-------|
| Form Number | FDACS-13645 |
| Full Title | Wood-Destroying Organisms Inspection Report |
| Issuing Agency | Florida Department of Agriculture and Consumer Services (FDACS), Division of Agricultural Environmental Services |
| Regulatory Authority | Rule 5E-14.142, Florida Administrative Code; Chapter 482, F.S. |
| Revision | Rev. 05/21 |
| Pages | 2 |
| Bureau Contact | Bureau of Inspection and Incident Response, (850) 617-7996 |
| Commissioner (on form) | Wilton Simpson |
| Source URL | https://forms.fdacs.gov/13645.pdf |

## Document Classification: All docs/ PDFs

| File | Classification | Form ID | Notes |
|------|---------------|---------|-------|
| `52580.pdf` | HUD Housing Quality Standards Inspection Checklist | HUD-52580 (4/2015) | Federal HUD Section 8 Housing Choice Voucher Program. 8 pages. NOT a Florida insurance inspection form. Not relevant to InspectoBot scope. |
| `e8c41965-f225-37fc-b451-4d360ee30b77.pdf` | 4-Point Inspection Form | Sample Form Insp4pt 03 25 | Already cataloged as the primary 4-Point form. 4 pages. |
| `b684cd08-e1ee-8092-f475-772a210fa127.pdf` | Roof Condition Inspection Form | Sample Form RCF-1 03 25 | Already cataloged as the primary Roof Condition form. 2 pages. |
| `contract.pdf` | Home Inspection Agreement/Contract | N/A | Generic NACHI-style inspector-client agreement. 2 pages. Covers liability limitation, hold harmless, scope of inspection. No WDO-specific content. |

### WDO Form Status: NOT PRESENT in docs/

The FDACS-13645 WDO inspection form is **not among the existing docs/ files**. However, the form was successfully retrieved from the official FDACS website (https://forms.fdacs.gov/13645.pdf) and is fully inventoried below.

**Recommended action:** Download `https://forms.fdacs.gov/13645.pdf` to `docs/fdacs-13645-wdo.pdf` for local reference.

---

## WDO Form Structure: Section-by-Section Field Inventory

### SECTION 1 -- GENERAL INFORMATION

| # | Field Name | Type | Required | Conditional On | Validation | Notes |
|---|-----------|------|----------|---------------|------------|-------|
| 1.1 | Inspection Company Name | text | Yes | -- | Non-empty | Company performing the inspection |
| 1.2 | Business License Number | text | Yes | -- | Valid FL pest control license format | FDACS business license |
| 1.3 | Company Address | text | Yes | -- | Non-empty | Street address |
| 1.4 | Phone Number | text | Yes | -- | Phone format | Company phone |
| 1.5 | Company City, State and Zip Code | text | Yes | -- | Non-empty | City/State/Zip |
| 1.6 | Date of Inspection | date | Yes | -- | Valid date, not future | Date inspection was performed |
| 1.7 | Inspector's Name (Print) | text | Yes | -- | Non-empty | Printed name of individual inspector |
| 1.8 | Inspector's ID Card Number | text | Yes | -- | Valid FDACS ID card number | State-issued identification card for pest control |
| 1.9 | Address of Property Inspected | text | Yes | -- | Non-empty, valid FL address | Full property address |
| 1.10 | Structure(s) on Property Inspected | text | Yes | -- | Non-empty | Describes which structures (e.g., "Main dwelling", "Main dwelling and detached garage") |
| 1.11 | Inspection and Report requested by | text | Yes | -- | Non-empty | Name and contact information of requestor |
| 1.12 | Report Sent to Requestor and to | text | Optional | Different from requestor | -- | Name and contact info if different from requestor (e.g., lender, buyer, seller) |

### SECTION 2 -- INSPECTION FINDINGS

This section contains the core findings and has a primary branch between "no WDO found" and "WDO found" paths.

| # | Field Name | Type | Required | Conditional On | Validation | Notes |
|---|-----------|------|----------|---------------|------------|-------|
| 2.A | NO visible signs of WDO(s) observed | checkbox | Yes (mutually exclusive with 2.B) | -- | Exactly one of A or B must be checked | "NO visible signs of WDO(s) (live, evidence or damage) observed" |
| 2.B | VISIBLE evidence of WDO(s) observed | checkbox | Yes (mutually exclusive with 2.A) | -- | Exactly one of A or B must be checked | Triggers sub-fields B.1, B.2, B.3 |
| 2.B.1 | LIVE WDO(s) | checkbox | Conditional | 2.B is checked | -- | Check if live organisms found |
| 2.B.1a | Live WDO(s) Description | text (multi-line) | Yes | 2.B.1 is checked | Non-empty | "Common Name of Organism and Location -- use additional page, if needed" |
| 2.B.2 | EVIDENCE of WDO(s) | checkbox | Conditional | 2.B is checked | -- | Dead insects, insect parts, frass, shelter tubes, exit holes, or other evidence |
| 2.B.2a | Evidence Description | text (multi-line) | Yes | 2.B.2 is checked | Non-empty | "Common Name, Description and Location -- Describe evidence" |
| 2.B.3 | DAMAGE caused by WDO(s) | checkbox | Conditional | 2.B is checked | -- | Check if damage observed |
| 2.B.3a | Damage Description | text (multi-line) | Yes | 2.B.3 is checked | Non-empty | "Common Name, Description and Location of all visible damage -- Describe damage". Has extensive multi-line space (~8 lines on form). |

**Regulatory disclaimers embedded in Section 2 (pre-printed, not fillable):**
- Report based on what was visible and readily accessible at time of inspection
- Does not constitute guarantee of absence of WDOs unless specifically stated
- Does not cover enclosed, inaccessible, concealed areas
- Not inspected for fungi other than wood-decaying fungi
- NOT a structural damage report
- Definition: "A wood-destroying organism (WDO) means an arthropod or plant life which damages and can reinfest seasoned wood in a structure, namely, termites, powder post beetles, old house borers, and wood-decaying fungi."

### SECTION 3 -- OBSTRUCTIONS AND INACCESSIBLE AREAS

This section documents areas that could not be inspected. Each area has a checkbox, a specific-areas text field, and a reason text field.

| # | Field Name | Type | Required | Conditional On | Validation | Notes |
|---|-----------|------|----------|---------------|------------|-------|
| 3.1 | Attic (inaccessible) | checkbox | Optional | -- | -- | Check if attic had inaccessible areas |
| 3.1a | Attic - Specific Areas | text (multi-line) | Yes | 3.1 is checked | Non-empty | Describe which parts of attic were inaccessible |
| 3.1b | Attic - Reason | text (multi-line) | Yes | 3.1 is checked | Non-empty | Explain why inaccessible |
| 3.2 | Interior (inaccessible) | checkbox | Optional | -- | -- | Check if interior had inaccessible areas |
| 3.2a | Interior - Specific Areas | text (multi-line) | Yes | 3.2 is checked | Non-empty | Describe which interior areas |
| 3.2b | Interior - Reason | text (multi-line) | Yes | 3.2 is checked | Non-empty | Explain why inaccessible |
| 3.3 | Exterior (inaccessible) | checkbox | Optional | -- | -- | Check if exterior had inaccessible areas |
| 3.3a | Exterior - Specific Areas | text (multi-line) | Yes | 3.3 is checked | Non-empty | Describe which exterior areas |
| 3.3b | Exterior - Reason | text (multi-line) | Yes | 3.3 is checked | Non-empty | Explain why inaccessible |
| 3.4 | Crawlspace (inaccessible) | checkbox | Optional | -- | -- | Check if crawlspace had inaccessible areas |
| 3.4a | Crawlspace - Specific Areas | text (multi-line) | Yes | 3.4 is checked | Non-empty | Describe which crawlspace areas |
| 3.4b | Crawlspace - Reason | text (multi-line) | Yes | 3.4 is checked | Non-empty | Explain why inaccessible |
| 3.5 | Other (inaccessible) | checkbox | Optional | -- | -- | Check for any other inaccessible areas |
| 3.5a | Other - Specific Areas | text (multi-line) | Yes | 3.5 is checked | Non-empty | Describe areas |
| 3.5b | Other - Reason | text (multi-line) | Yes | 3.5 is checked | Non-empty | Explain why |

### SECTION 4 -- NOTICE OF INSPECTION AND TREATMENT INFORMATION

| # | Field Name | Type | Required | Conditional On | Validation | Notes |
|---|-----------|------|----------|---------------|------------|-------|
| 4.1 | Evidence of previous treatment observed | radio (Yes/No) | Yes | -- | Must select one | Yes or No checkbox pair |
| 4.1a | Previous treatment evidence description | text (multi-line) | Yes | 4.1 = Yes | Non-empty | "State what visible evidence was observed to suggest possible previous treatment" |
| 4.2 | Notice of Inspection affixed location | text | Yes | -- | Non-empty | Per Ch. 482, F.S., notice must be posted "immediately adjacent to the access to the attic or crawl space or other readily accessible area" |
| 4.3 | Company treated structure at time of inspection | radio (Yes/No) | Yes | -- | Must select one | Yes or No checkbox pair |
| 4.3a | Common name of organism treated | text | Yes | 4.3 = Yes | Non-empty | Common name only |
| 4.3b | Name of Pesticide Used | text | Yes | 4.3 = Yes | Non-empty | Specific pesticide product |
| 4.3c | Terms and Conditions of Treatment | text | Yes | 4.3 = Yes | Non-empty | Treatment terms |
| 4.3d | Method of treatment - Whole structure | checkbox | Conditional | 4.3 = Yes | Exactly one of Whole/Spot | Mutually exclusive with Spot treatment |
| 4.3e | Method of treatment - Spot treatment | checkbox | Conditional | 4.3 = Yes | Exactly one of Whole/Spot | If Spot, additional text field to describe scope |
| 4.3e-desc | Spot treatment description | text | Yes | 4.3e is checked | Non-empty | Describe area of spot treatment |
| 4.3f | Treatment Notice Location | text | Yes | 4.3 = Yes | Non-empty | Where treatment notice was posted |

### SECTION 5 -- COMMENTS AND FINANCIAL DISCLOSURE

| # | Field Name | Type | Required | Conditional On | Validation | Notes |
|---|-----------|------|----------|---------------|------------|-------|
| 5.1 | Comments | text (multi-line) | Optional | -- | -- | "Use additional pages, if necessary." General comments area. |
| 5.2 | Financial Disclosure Statement | pre-printed | N/A | -- | -- | Non-editable: "Neither the company (licensee) nor the inspector has any financial interest in the property inspected or is associated in any way in the transaction or with any party to the transaction other than for inspection purposes." |
| 5.3 | Signature of Licensee or Agent | signature | Yes | -- | Must be signed | Legally binding signature |
| 5.4 | Signature Date | date | Yes | -- | Valid date | Date of signing |
| 5.5 | Address of Property Inspected (repeat) | text | Yes | -- | Must match 1.9 | Repeated for page 2 identification |
| 5.6 | Inspection Date (repeat) | date | Yes | -- | Must match 1.6 | Repeated for page 2 identification |

---

## Branch Logic Diagram

```
START: Section 1 (General Information)
  |
  v
SECTION 2: Inspection Findings
  |
  +-- [A] NO visible signs of WDO(s) -----> Skip B.1, B.2, B.3
  |                                          Proceed to Section 3
  |
  +-- [B] VISIBLE evidence of WDO(s) -----> Must complete at least one of:
       |
       +-- [B.1] LIVE WDO(s)?
       |    +-- Yes --> Enter: Common name + Location (2.B.1a)
       |    +-- No  --> Skip
       |
       +-- [B.2] EVIDENCE of WDO(s)?
       |    +-- Yes --> Enter: Common name + Description + Location (2.B.2a)
       |    +-- No  --> Skip
       |
       +-- [B.3] DAMAGE from WDO(s)?
            +-- Yes --> Enter: Common name + Description + Location (2.B.3a)
            +-- No  --> Skip
  |
  v
SECTION 3: Inaccessible Areas
  |
  For each area category [Attic, Interior, Exterior, Crawlspace, Other]:
    +-- Inaccessible?
         +-- Yes --> Enter: Specific Areas + Reason
         +-- No  --> Skip (leave unchecked)
  |
  v
SECTION 4: Treatment Information
  |
  +-- Previous treatment evidence?
  |    +-- Yes --> Describe what was observed (4.1a)
  |    +-- No  --> Skip description
  |
  +-- Notice of Inspection location (ALWAYS required) --> Enter location
  |
  +-- Company treated at time of inspection?
       +-- Yes --> Enter all of:
       |    - Organism treated (4.3a)
       |    - Pesticide used (4.3b)
       |    - Terms/conditions (4.3c)
       |    - Method: Whole structure OR Spot treatment (4.3d/e)
       |    - If Spot: describe scope (4.3e-desc)
       |    - Treatment notice location (4.3f)
       +-- No  --> Skip treatment details
  |
  v
SECTION 5: Comments + Signature (ALWAYS required)
```

---

## WDO-Specific Organisms Covered

Per the form definition and Rule 5E-14.142:

| Organism Type | Common Names | Evidence Types |
|--------------|-------------|---------------|
| Subterranean termites | Eastern subterranean termite, Formosan termite | Shelter/mud tubes, swarmers, wings, live insects, damaged wood |
| Drywood termites | West Indian drywood termite, Southeastern drywood termite | Frass (fecal pellets), kick-out holes, swarmers, damaged wood |
| Powder post beetles | Lyctid beetles, Anobiid beetles, Bostrichid beetles | Exit holes, fine powdery frass, damaged wood |
| Old house borers | Hylotrupes bajulus | Oval exit holes, boring dust, larvae, damaged wood |
| Wood-decaying fungi | White rot, brown rot, poria, cubical rot | Visible decay, soft/spongy wood, discoloration, fruiting bodies, mycelial growth |

**Explicitly excluded from reportable findings:**
- Surface molds (cladosporium, aspergillus)
- Plywood delamination from moisture
- Water-damaged trim without rot
- Damage to siding materials (T-111, Masonite)
- Deterioration from water/sunlight exposure alone
- Fungi other than wood-decaying fungi
- Health-related effects or indoor air quality assessments

---

## Evidence and Documentation Requirements

### Inspection Notice (Mandatory per Ch. 482, F.S.)
- A physical Notice of Inspection must be **affixed to the structure** at every WDO inspection
- Location: "immediately adjacent to the access to the attic or crawl space or other readily accessible area"
- The notice location must be recorded on the form (field 4.2)

### Photo Requirements
The FDACS-13645 form itself does **not specify photo requirements**. However:
- Photos are standard industry practice for documenting findings
- Insurance companies and lenders often require photographic evidence when WDO is found
- Recommended photos for InspectoBot implementation:
  - Active infestation evidence (shelter tubes, frass, live insects)
  - Damage areas with scale reference
  - Inaccessible areas (to document why they were inaccessible)
  - Notice of Inspection posting location
  - Treatment areas (if treatment performed)
  - Overall property exterior

### Record Retention (per Rule 5E-14.142)
- WDO inspection records: minimum **2 years** at licensed business location
- Subterranean termite preventive treatments (new construction): **3 years**

### Financial Requirements for WDO Inspectors
- Professional liability (E&O) insurance: minimum $500,000 aggregate / $250,000 per occurrence
- Specifically must cover WDO inspection reports
- Alternative: bond or CPA-notarized net worth statement >= $500,000

### Form Integrity Rule
Per Rule 5E-14.142: "The licensee shall **not** place any disclaimers or additional language on the Wood-Destroying Organisms Inspection Report." The form must be used as-is without modification.

---

## Field Overlap with Other InspectoBot Form Types

| Shared Field Concept | WDO (FDACS-13645) | 4-Point (Insp4pt 03 25) | Roof (RCF-1) | Wind Mit (OIR-B1-1802) |
|---------------------|-------------------|------------------------|--------------|----------------------|
| Property Address | Address of Property Inspected (1.9) | Address Inspected | Address Inspected | Address |
| Inspection Date | Date of Inspection (1.6) | Date Inspected | Date of Inspection | Date of Inspection |
| Inspector Name | Inspector's Name (1.7) | Inspector Signature block | Inspector Signature block | Inspector fields |
| Inspector License | ID Card Number (1.8) | License Number | License Number | License Number |
| Company Name | Inspection Company Name (1.1) | Company Name | Company Name | Company |
| Signature | Signature of Licensee or Agent (5.3) | Inspector Signature | Inspector Signature | Inspector Signature |
| Insured/Applicant | Inspection requested by (1.11) | Insured/Applicant Name | Applicant/Insured Name | Policyholder |

### Key Differences from Other Forms
- **Licensing:** WDO requires a pest control business license + individual ID card (FDACS), not a general contractor or home inspector license
- **Scope:** WDO is organism/pest-specific; other forms are building-system-specific
- **Regulatory body:** FDACS (agriculture), not OIR (insurance) or DBPR (construction)
- **Treatment recording:** WDO form uniquely includes treatment performed at time of inspection
- **Notice posting:** WDO uniquely requires physical notice affixed to structure
- **No photo mandate:** Unlike 4-Point and Roof forms which list minimum photo requirements, the FDACS-13645 has no photo section

---

## Implementation Notes for InspectoBot

### New FormType Required
The WDO form would need a new `FormType` enum value: `wdoInspection` (FDACS-13645).

### Inspector Licensing Difference
WDO inspections require a **pest control operator license** (FDACS Business License + individual ID Card), not the general/residential contractor or home inspector license used for 4-Point, Roof, and Wind Mitigation forms. The Inspector Identity module would need to support dual licensing profiles.

### Conditional UI Design
The Section 2 findings branch (A vs B, then B.1/B.2/B.3 sub-checkboxes) is the primary conditional logic driver. The UI should:
1. Present A/B as mutually exclusive radio-style selection
2. If B selected, show B.1, B.2, B.3 as independent checkboxes (at least one must be checked)
3. Each checked sub-item reveals its corresponding text description field

### Inaccessible Areas Pattern
Section 3 uses a repeating pattern of [checkbox] + [specific areas text] + [reason text] for 5 area categories. This maps well to a list of expandable tiles or a repeating form group.

### Treatment Section Complexity
Section 4 has two independent conditional branches:
1. Previous treatment evidence (Yes/No -> description)
2. Treatment performed at this inspection (Yes/No -> organism + pesticide + terms + method + location)

Both can be Yes simultaneously (inspector finds evidence of old treatment AND performs new treatment).
