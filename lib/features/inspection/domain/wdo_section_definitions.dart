import 'field_definition.dart';
import 'field_type.dart';
import 'form_requirements.dart';
import 'form_section_definition.dart';

/// FDACS-13645 WDO Inspection form section definitions.
///
/// Five sections covering General Information, Inspection Findings,
/// Inaccessible Areas, Treatment Information, and Comments/Signature.
class WdoSectionDefinitions {
  WdoSectionDefinitions._();

  // ---------------------------------------------------------------------------
  // Section 1: General Information
  // ---------------------------------------------------------------------------

  static final generalInfo = FormSectionDefinition(
    id: 'wdo_general_info',
    title: 'General Info',
    branchFlagKeys: const <String>[],
    fieldDefinitions: const <FieldDefinition>[
      FieldDefinition(
        key: 'gen_company_name',
        label: 'Inspection Company Name',
        type: FieldType.text,
        isRequired: true,
      ),
      FieldDefinition(
        key: 'gen_business_license',
        label: 'Business License Number',
        type: FieldType.text,
        isRequired: true,
        keyboardType: 'number',
      ),
      FieldDefinition(
        key: 'gen_company_address',
        label: 'Company Address',
        type: FieldType.text,
        isRequired: true,
      ),
      FieldDefinition(
        key: 'gen_phone',
        label: 'Phone Number',
        type: FieldType.text,
        isRequired: true,
        keyboardType: 'phone',
      ),
      FieldDefinition(
        key: 'gen_city_state_zip',
        label: 'City, State and Zip Code',
        type: FieldType.text,
        isRequired: true,
      ),
      FieldDefinition(
        key: 'gen_inspection_date',
        label: 'Date of Inspection',
        type: FieldType.date,
        isRequired: true,
      ),
      FieldDefinition(
        key: 'gen_inspector_name',
        label: "Inspector's Name (Print)",
        type: FieldType.text,
        isRequired: true,
      ),
      FieldDefinition(
        key: 'gen_inspector_id',
        label: "Inspector's ID Card Number",
        type: FieldType.text,
        isRequired: true,
      ),
      FieldDefinition(
        key: 'gen_property_address',
        label: 'Address of Property Inspected',
        type: FieldType.text,
        isRequired: true,
      ),
      FieldDefinition(
        key: 'gen_structures',
        label: 'Structure(s) on Property Inspected',
        type: FieldType.text,
        isRequired: true,
      ),
      FieldDefinition(
        key: 'gen_requested_by',
        label: 'Inspection Requested By',
        type: FieldType.text,
        isRequired: true,
      ),
      FieldDefinition(
        key: 'gen_report_sent_to',
        label: 'Report Sent To',
        type: FieldType.text,
        isRequired: false,
      ),
    ],
  );

  // ---------------------------------------------------------------------------
  // Section 2: Inspection Findings
  // ---------------------------------------------------------------------------

  static final findings = FormSectionDefinition(
    id: 'wdo_findings',
    title: 'Findings',
    branchFlagKeys: const <String>[
      FormRequirements.wdoVisibleEvidenceBranchFlag,
      FormRequirements.wdoLiveWdoBranchFlag,
      FormRequirements.wdoEvidenceOfWdoBranchFlag,
      FormRequirements.wdoDamageByWdoBranchFlag,
    ],
    evidenceRequirementKeys: const <String>[
      'photo:wdo_infestation_evidence',
      'photo:wdo_damage_area',
    ],
    fieldDefinitions: const <FieldDefinition>[
      FieldDefinition(
        key: 'find_live_description',
        label: 'Live WDO(s) — Common Name and Location',
        type: FieldType.textarea,
        isRequired: true,
        conditionalOn: FormRequirements.wdoLiveWdoBranchFlag,
        maxLines: 4,
      ),
      FieldDefinition(
        key: 'find_evidence_description',
        label: 'Evidence — Common Name, Description and Location',
        type: FieldType.textarea,
        isRequired: true,
        conditionalOn: FormRequirements.wdoEvidenceOfWdoBranchFlag,
        maxLines: 4,
      ),
      FieldDefinition(
        key: 'find_damage_description',
        label: 'Damage — Common Name, Description and Location',
        type: FieldType.textarea,
        isRequired: true,
        conditionalOn: FormRequirements.wdoDamageByWdoBranchFlag,
        maxLines: 8,
      ),
      FieldDefinition(
        key: 'find_notes',
        label: 'Findings Notes',
        type: FieldType.textarea,
        isRequired: false,
        maxLines: 4,
      ),
    ],
  );

  // ---------------------------------------------------------------------------
  // Section 3: Inaccessible Areas
  // ---------------------------------------------------------------------------

  static final inaccessibleAreas = FormSectionDefinition(
    id: 'wdo_inaccessible',
    title: 'Inaccessible',
    branchFlagKeys: const <String>[
      FormRequirements.wdoAtticInaccessibleBranchFlag,
      FormRequirements.wdoInteriorInaccessibleBranchFlag,
      FormRequirements.wdoExteriorInaccessibleBranchFlag,
      FormRequirements.wdoCrawlspaceInaccessibleBranchFlag,
      FormRequirements.wdoOtherInaccessibleBranchFlag,
    ],
    evidenceRequirementKeys: const <String>[
      'photo:wdo_inaccessible_area',
    ],
    fieldDefinitions: const <FieldDefinition>[
      // Attic
      FieldDefinition(
        key: 'attic_specific_areas',
        label: 'Specific Areas',
        type: FieldType.textarea,
        isRequired: true,
        conditionalOn: FormRequirements.wdoAtticInaccessibleBranchFlag,
        maxLines: 3,
      ),
      FieldDefinition(
        key: 'attic_reason',
        label: 'Reason',
        type: FieldType.textarea,
        isRequired: true,
        conditionalOn: FormRequirements.wdoAtticInaccessibleBranchFlag,
        maxLines: 3,
      ),
      // Interior
      FieldDefinition(
        key: 'interior_specific_areas',
        label: 'Specific Areas',
        type: FieldType.textarea,
        isRequired: true,
        conditionalOn: FormRequirements.wdoInteriorInaccessibleBranchFlag,
        maxLines: 3,
      ),
      FieldDefinition(
        key: 'interior_reason',
        label: 'Reason',
        type: FieldType.textarea,
        isRequired: true,
        conditionalOn: FormRequirements.wdoInteriorInaccessibleBranchFlag,
        maxLines: 3,
      ),
      // Exterior
      FieldDefinition(
        key: 'exterior_specific_areas',
        label: 'Specific Areas',
        type: FieldType.textarea,
        isRequired: true,
        conditionalOn: FormRequirements.wdoExteriorInaccessibleBranchFlag,
        maxLines: 3,
      ),
      FieldDefinition(
        key: 'exterior_reason',
        label: 'Reason',
        type: FieldType.textarea,
        isRequired: true,
        conditionalOn: FormRequirements.wdoExteriorInaccessibleBranchFlag,
        maxLines: 3,
      ),
      // Crawlspace
      FieldDefinition(
        key: 'crawlspace_specific_areas',
        label: 'Specific Areas',
        type: FieldType.textarea,
        isRequired: true,
        conditionalOn: FormRequirements.wdoCrawlspaceInaccessibleBranchFlag,
        maxLines: 3,
      ),
      FieldDefinition(
        key: 'crawlspace_reason',
        label: 'Reason',
        type: FieldType.textarea,
        isRequired: true,
        conditionalOn: FormRequirements.wdoCrawlspaceInaccessibleBranchFlag,
        maxLines: 3,
      ),
      // Other
      FieldDefinition(
        key: 'other_specific_areas',
        label: 'Specific Areas',
        type: FieldType.textarea,
        isRequired: true,
        conditionalOn: FormRequirements.wdoOtherInaccessibleBranchFlag,
        maxLines: 3,
      ),
      FieldDefinition(
        key: 'other_reason',
        label: 'Reason',
        type: FieldType.textarea,
        isRequired: true,
        conditionalOn: FormRequirements.wdoOtherInaccessibleBranchFlag,
        maxLines: 3,
      ),
    ],
  );

  // ---------------------------------------------------------------------------
  // Section 4: Treatment Information
  // ---------------------------------------------------------------------------

  static final treatment = FormSectionDefinition(
    id: 'wdo_treatment',
    title: 'Treatment',
    branchFlagKeys: const <String>[
      FormRequirements.wdoPreviousTreatmentBranchFlag,
      FormRequirements.wdoTreatedAtInspectionBranchFlag,
      FormRequirements.wdoSpotTreatmentBranchFlag,
    ],
    fieldDefinitions: const <FieldDefinition>[
      FieldDefinition(
        key: 'treat_prev_description',
        label: 'Previous Treatment Evidence Description',
        type: FieldType.textarea,
        isRequired: true,
        conditionalOn: FormRequirements.wdoPreviousTreatmentBranchFlag,
        maxLines: 4,
      ),
      FieldDefinition(
        key: 'treat_notice_location',
        label: 'Notice of Inspection Affixed Location',
        type: FieldType.text,
        isRequired: true,
      ),
      FieldDefinition(
        key: 'treat_organism',
        label: 'Common Name of Organism Treated',
        type: FieldType.text,
        isRequired: true,
        conditionalOn: FormRequirements.wdoTreatedAtInspectionBranchFlag,
      ),
      FieldDefinition(
        key: 'treat_pesticide',
        label: 'Name of Pesticide Used',
        type: FieldType.text,
        isRequired: true,
        conditionalOn: FormRequirements.wdoTreatedAtInspectionBranchFlag,
      ),
      FieldDefinition(
        key: 'treat_terms',
        label: 'Terms and Conditions of Treatment',
        type: FieldType.textarea,
        isRequired: true,
        conditionalOn: FormRequirements.wdoTreatedAtInspectionBranchFlag,
        maxLines: 4,
      ),
      FieldDefinition(
        key: 'treat_spot_description',
        label: 'Spot Treatment Area Description',
        type: FieldType.textarea,
        isRequired: true,
        conditionalOn: FormRequirements.wdoSpotTreatmentBranchFlag,
        maxLines: 3,
      ),
      FieldDefinition(
        key: 'treat_notice_treatment_location',
        label: 'Treatment Notice Location',
        type: FieldType.text,
        isRequired: true,
        conditionalOn: FormRequirements.wdoTreatedAtInspectionBranchFlag,
      ),
    ],
  );

  // ---------------------------------------------------------------------------
  // Section 5: Comments and Signature
  // ---------------------------------------------------------------------------

  static final comments = FormSectionDefinition(
    id: 'wdo_comments',
    title: 'Comments',
    branchFlagKeys: const <String>[],
    evidenceRequirementKeys: const <String>[
      'photo:wdo_property_exterior',
      'photo:wdo_notice_posting',
    ],
    fieldDefinitions: const <FieldDefinition>[
      FieldDefinition(
        key: 'comments',
        label: 'Comments',
        type: FieldType.textarea,
        isRequired: false,
        maxLines: 6,
      ),
      FieldDefinition(
        key: 'sig_date',
        label: 'Signature Date',
        type: FieldType.date,
        isRequired: true,
      ),
      FieldDefinition(
        key: 'repeat_property_address',
        label: 'Address of Property Inspected (Page 2)',
        type: FieldType.text,
        isRequired: true,
      ),
      FieldDefinition(
        key: 'repeat_inspection_date',
        label: 'Inspection Date (Page 2)',
        type: FieldType.date,
        isRequired: true,
      ),
    ],
  );

  // ---------------------------------------------------------------------------
  // Aggregate
  // ---------------------------------------------------------------------------

  static List<FormSectionDefinition> get all => [
        generalInfo,
        findings,
        inaccessibleAreas,
        treatment,
        comments,
      ];
}
