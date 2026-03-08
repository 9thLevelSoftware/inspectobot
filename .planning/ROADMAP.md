# InspectoBot Form Expansion & Unified Schema — Roadmap

## Phases

- [x] Phase 1: Ground Truth Extraction (SCHEMA-01)
- [ ] Phase 2: Unified Property Schema Design (SCHEMA-02)
- [ ] Phase 3: Data Model Evolution (DATA-01)
- [ ] Phase 4: WDO Form Implementation (FORM-01)
- [ ] Phase 5: Sinkhole Form Implementation (FORM-02)
- [ ] Phase 6: Narrative Report Engine (PDF-02)
- [ ] Phase 7: Mold Assessment Implementation (FORM-03)
- [ ] Phase 8: General Inspection Implementation (FORM-04)
- [ ] Phase 9: Cross-Form Integration (WIZARD-02, INTEG-01)
- [ ] Phase 10: Testing, Migration & Polish

## Phase Details

### Phase 1: Ground Truth Extraction
**Goal**: Analyze all docs/ folder documents to create a comprehensive field inventory — every checkbox, text field, dropdown, and narrative section across all 7 form types mapped and cataloged.
**Requirements**: SCHEMA-01
**Recommended Agents**: Senior Developer, Technical Writer, Legal Compliance Checker, Evidence Collector, UX Researcher
**Success Criteria**:
- Every field on existing 3 PDF templates (4-Point, Roof Condition, Wind Mit) inventoried with field name, type, position, and validation rules
- Every field on WDO form (FDACS-13645) inventoried from docs/
- Every field on Sinkhole forms (Citizens + FGS) inventoried from docs/
- Mold assessment statutory requirements (Chapter 468) mapped to narrative sections
- General inspection statutory requirements (Rule 61-30.801) mapped to narrative sections
- Cross-form field overlap identified (shared fields like address, year built, client info)
- Field inventory document written to .planning/phases/01/FIELD_INVENTORY.md
**Plans**: 5

### Phase 2: Unified Property Schema Design
**Goal**: Design the master JSON schema that normalizes all 7 form types into a single property model with shared and form-specific namespaces.
**Requirements**: SCHEMA-02
**Recommended Agents**: Backend Architect, Senior Developer, Data Analytics Reporter, UX Architect, Legal Compliance Checker
**Success Criteria**:
- Master JSON schema defined with shared property namespace (address, client, inspector, dates)
- Per-form namespaces for form-specific fields (wdo/, sinkhole/, mold/, general/, fourPoint/, roofCondition/, windMit/)
- Field-to-schema mapping document: every field from Phase 1 inventory maps to a schema path
- Validation rules defined per field (required, optional, conditional, type constraints)
- Schema supports branching logic (conditional fields based on inspector answers)
- Backward compatibility spec: how existing InspectionDraft data maps to new schema
- Schema versioning strategy defined
- Schema document written as Dart model specification
**Plans**: 5

### Phase 3: Data Model Evolution
**Goal**: Extend the existing data model to support the unified schema and 4 new form types while maintaining backward compatibility with existing inspections.
**Requirements**: DATA-01
**Recommended Agents**: Senior Developer, Backend Architect, Mobile App Builder, Evidence Collector, API Tester
**Success Criteria**:
- FormType enum extended with 4 new values: wdo, moldAssessment, sinkholeInspection, generalInspection
- InspectionDraft refactored to carry unified schema data structure
- FormRequirements extended with evidence rules for all 4 new form types
- WizardProgressSnapshot compatible with both fillable-PDF and narrative form workflows
- Existing inspections (4-Point, Roof, Wind) continue working without data migration
- All existing tests pass without modification (or with minimal, backward-compatible updates)
- New model unit tests for each new FormType's requirements and validation
**Plans**: 5

### Phase 4: WDO Form Implementation
**Goal**: Implement the FDACS-13645 wood-destroying organism inspection form — the first new fillable PDF form type, proving the expansion pattern.
**Requirements**: FORM-01
**Recommended Agents**: Senior Developer, Mobile App Builder, UI Designer, Legal Compliance Checker, Evidence Collector
**Success Criteria**:
- PDF template asset created for FDACS-13645 form
- JSON field map defining all field coordinates, types, and mappings to unified schema
- WDO-specific evidence requirements defined (infestation photos, treatment records, damage documentation)
- Wizard steps defined for WDO inspection flow
- Branch logic implemented (active infestation → additional requirements, previous treatment → documentation requirements)
- PDF generation produces compliant FDACS-13645 output
- PdfFieldMap coverage test verifies all template fields are mapped
- Widget tests for WDO wizard steps
- End-to-end test: create WDO inspection → fill wizard → generate PDF
**Plans**: 5

### Phase 5: Sinkhole Form Implementation
**Goal**: Implement the Citizens Sinkhole Form and FGS Subsidence Incident Report — proving multi-template form types (one inspection, multiple output documents).
**Requirements**: FORM-02
**Recommended Agents**: Senior Developer, Mobile App Builder, Legal Compliance Checker, Evidence Collector, Backend Architect
**Success Criteria**:
- PDF template assets created for both Citizens Sinkhole Form and FGS Subsidence Incident Report
- JSON field maps for both templates, both mapping to unified schema sinkhole namespace
- Sinkhole-specific evidence requirements (geological photos, foundation cracks, ground depression documentation)
- Wizard steps for sinkhole inspection flow
- Branch logic (geological indicators → FGS report required, insurance claim → Citizens form required)
- Single wizard completion generates both PDFs when applicable
- PdfFieldMap coverage tests for both templates
- Widget tests for sinkhole wizard steps
**Plans**: 5

### Phase 6: Narrative Report Engine
**Goal**: Build the template-based narrative PDF generation subsystem for non-fillable form types (Mold, General), distinct from the existing coordinate-based field placement pipeline.
**Requirements**: PDF-02
**Recommended Agents**: Senior Developer, Backend Architect, Technical Writer, UI Designer, Evidence Collector
**Success Criteria**:
- NarrativeReportEngine abstraction defined alongside existing PdfRenderer
- Template model: boilerplate sections + injectable findings + photo embedding
- Section types: header, narrative paragraph, photo grid, checklist summary, signature block
- Template loading from structured Dart definitions (not PDF assets — generated from scratch)
- Styling consistent with app design system (dark theme tokens translate to print-appropriate palette)
- Photo embedding with captions and category labels
- Engine produces valid, multi-page PDF output from template + inspection data
- Unit tests for template rendering, section composition, photo embedding
- Integration test: sample narrative data → complete PDF output
**Plans**: 5

### Phase 7: Mold Assessment Implementation
**Goal**: Implement the mold assessment report per Florida Chapter 468, Part XVI, F.S. — the first narrative-based form type, using the Phase 6 engine.
**Requirements**: FORM-03
**Recommended Agents**: Senior Developer, Mobile App Builder, Legal Compliance Checker, Technical Writer, Evidence Collector
**Success Criteria**:
- Mold assessment narrative template defined with all required statutory sections
- Required sections: MRSA license display, scope of assessment, moisture source identification, mold type/location documentation, remediation protocol recommendations, limitations and disclaimers
- Evidence requirements: moisture readings, mold growth photos, affected area documentation, air sample results (optional)
- Wizard steps for mold assessment flow (structured data collection for narrative generation)
- Branch logic (remediation recommended → protocol section required, air samples taken → results section)
- Narrative PDF generation produces Chapter 468-compliant output
- Widget tests for mold wizard steps
- Compliance validation: required statutory elements checklist
**Plans**: 5

### Phase 8: General Inspection Implementation
**Goal**: Implement the full home inspection report per Florida Rule 61-30.801 — the most comprehensive narrative form type, covering structural, electrical, plumbing, HVAC, and more.
**Requirements**: FORM-04
**Recommended Agents**: Senior Developer, Mobile App Builder, Legal Compliance Checker, Technical Writer, UX Architect
**Success Criteria**:
- General inspection narrative template with all Rule 61-30.801 required sections
- Required sections: structural components, exterior, roofing, plumbing, electrical, HVAC, insulation/ventilation, built-in appliances, life safety
- Per-section inspection model: condition rating (satisfactory/marginal/deficient), narrative findings, photo references
- Evidence requirements per section (exterior photos, electrical panel, plumbing fixtures, HVAC data plates, etc.)
- Wizard organized by inspection section (not linear — section-based navigation)
- Branch logic per section (deficient rating → detailed findings required, safety hazard → immediate action recommendation)
- Narrative PDF generation produces Rule 61-30.801-compliant output
- Widget tests for general inspection wizard
- Largest form type — verify PDF generation performance within acceptable limits
**Plans**: 6

### Phase 9: Cross-Form Integration
**Goal**: Enable multi-form inspection sessions with cross-form evidence sharing and unified progress tracking across all 7 form types.
**Requirements**: WIZARD-02, INTEG-01
**Recommended Agents**: Senior Developer, UX Architect, Mobile App Builder, Backend Architect, Evidence Collector
**Success Criteria**:
- Inspector can select any combination of 7 form types per property visit
- Shared property data (address, year built, client info) entered once, flows to all selected forms
- Cross-form evidence sharing: one photo satisfies requirements on multiple forms (e.g., exterior photo counts for 4-Point AND General)
- Evidence sharing UI: when capturing a photo, system shows which forms it satisfies
- Unified progress indicator showing completion across all selected forms
- Per-form wizard independence: each form's wizard completes independently
- Dashboard updates: inspection cards show all selected form types with per-form status
- FormTypeCard selection updated for 7 form types (scrollable, grouped by category)
- Performance: selecting all 7 forms doesn't degrade wizard/PDF generation performance
- Widget tests for multi-form selection, evidence sharing, progress tracking
**Plans**: 5

### Phase 10: Testing, Migration & Polish
**Goal**: Comprehensive testing across all 7 form types, migration path for existing inspections, performance optimization, and documentation.
**Requirements**: All
**Recommended Agents**: Evidence Collector, Reality Checker, Performance Benchmarker, Technical Writer, Senior Developer
**Success Criteria**:
- All existing tests pass without regression
- New form type tests achieve 80%+ coverage
- Integration test suite: create inspection with each form type → complete wizard → generate PDF → verify output
- Cross-form integration tests: multi-form sessions with evidence sharing
- Performance benchmarks: PDF generation time for single form, multi-form (3, 5, 7 forms)
- Migration validation: existing inspections (4-Point, Roof, Wind) load correctly with new data model
- Offline scenario testing: capture + queue + sync for all new form types
- Documentation: updated CLAUDE.md, form type reference guide, schema documentation
- App size impact assessment (new PDF templates + assets)
- Final compliance review: each form type's output verified against regulatory requirements
**Plans**: 5

## Progress

| Phase | Plans | Completed | Status |
|-------|-------|-----------|--------|
| 1. Ground Truth Extraction | 5 | 5 | Complete (reviewed) |
| 2. Unified Schema Design | 5 | 5 | Complete (reviewed) |
| 3. Data Model Evolution | 3 | 3 | Complete (reviewed) |
| 4. WDO Form | 5 | 5 | Complete |
| 5. Sinkhole Form | 5 | 0 | Pending |
| 6. Narrative Report Engine | 5 | 0 | Pending |
| 7. Mold Assessment | 5 | 0 | Pending |
| 8. General Inspection | 6 | 0 | Pending |
| 9. Cross-Form Integration | 5 | 0 | Pending |
| 10. Testing & Polish | 5 | 0 | Pending |
| **Total** | **49** | **18** | **37%** |
