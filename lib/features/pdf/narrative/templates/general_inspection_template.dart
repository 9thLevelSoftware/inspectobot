import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_section.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_template.dart';

/// Narrative report template for Florida general home inspection reports.
///
/// Generates a report compliant with Florida Administrative Code Rule
/// 61-30.801, covering 9 major building systems with condition ratings,
/// findings, and photo documentation.
class GeneralInspectionTemplate extends NarrativeTemplate {
  const GeneralInspectionTemplate()
      : super(
          formType: FormType.generalInspection,
          revisionLabel: 'General Inspection per Rule 61-30.801',
          title: 'General Home Inspection Report',
        );

  @override
  List<NarrativeSection> buildSections({
    required Map<String, dynamic> formData,
    required Map<String, dynamic> branchContext,
  }) {
    return [
      // 1. Header
      const HeaderSection(
        title: 'General Home Inspection Report',
      ),

      // 2. Property info
      PropertyInfoSection(
        fields: [
          PropertyInfoField(
            label: 'Client',
            value: formData['client_name'] as String? ?? '',
          ),
          PropertyInfoField(
            label: 'Property Address',
            value: formData['property_address'] as String? ?? '',
          ),
          PropertyInfoField(
            label: 'Year Built',
            value: formData['year_built'] as String? ?? '',
          ),
          PropertyInfoField(
            label: 'Inspector',
            value: formData['inspector_name'] as String? ?? '',
          ),
          PropertyInfoField(
            label: 'Inspection Date',
            value: formData['inspection_date'] as String? ?? '',
          ),
        ],
      ),

      // 3. Table of contents
      const TableOfContentsSection(
        entries: [
          TocEntry(number: 1, title: 'Scope and Purpose'),
          TocEntry(number: 2, title: 'Structural Components'),
          TocEntry(number: 3, title: 'Exterior'),
          TocEntry(number: 4, title: 'Roofing'),
          TocEntry(number: 5, title: 'Plumbing'),
          TocEntry(number: 6, title: 'Electrical'),
          TocEntry(number: 7, title: 'HVAC'),
          TocEntry(number: 8, title: 'Insulation and Ventilation'),
          TocEntry(number: 9, title: 'Built-in Appliances'),
          TocEntry(number: 10, title: 'Life Safety'),
          TocEntry(number: 11, title: 'System Condition Summary'),
          TocEntry(number: 12, title: 'General Comments'),
          TocEntry(number: 13, title: 'Standards of Practice and Limitations'),
          TocEntry(number: 14, title: 'Certification'),
        ],
      ),

      // 4. Scope and Purpose
      const NarrativeParagraphSection(
        heading: 'Scope and Purpose',
        bodyKey: 'scope_and_purpose',
      ),

      // 5. Structural Components
      const ConditionRatingSection(
        systemName: 'Structural Components',
        ratingKey: 'structural_rating',
        findingsKey: 'structural_findings',
        photoKeys: ['structural_photos'],
        subSystems: [
          ConditionRatingSubSystem(
            name: 'Foundation',
            ratingKey: 'structural_foundation_rating',
            findingsKey: 'structural_foundation_findings',
          ),
          ConditionRatingSubSystem(
            name: 'Framing',
            ratingKey: 'structural_framing_rating',
            findingsKey: 'structural_framing_findings',
          ),
          ConditionRatingSubSystem(
            name: 'Roof Structure',
            ratingKey: 'structural_roof_structure_rating',
            findingsKey: 'structural_roof_structure_findings',
          ),
        ],
      ),

      // 6. Exterior
      const ConditionRatingSection(
        systemName: 'Exterior',
        ratingKey: 'exterior_rating',
        findingsKey: 'exterior_findings',
        photoKeys: ['exterior_photos'],
        subSystems: [
          ConditionRatingSubSystem(
            name: 'Siding',
            ratingKey: 'exterior_siding_rating',
            findingsKey: 'exterior_siding_findings',
          ),
          ConditionRatingSubSystem(
            name: 'Trim',
            ratingKey: 'exterior_trim_rating',
            findingsKey: 'exterior_trim_findings',
          ),
          ConditionRatingSubSystem(
            name: 'Porches',
            ratingKey: 'exterior_porches_rating',
            findingsKey: 'exterior_porches_findings',
          ),
          ConditionRatingSubSystem(
            name: 'Driveways',
            ratingKey: 'exterior_driveways_rating',
            findingsKey: 'exterior_driveways_findings',
          ),
        ],
      ),

      // 7. Roofing
      const ConditionRatingSection(
        systemName: 'Roofing',
        ratingKey: 'roofing_rating',
        findingsKey: 'roofing_findings',
        photoKeys: ['roofing_photos'],
        subSystems: [
          ConditionRatingSubSystem(
            name: 'Covering',
            ratingKey: 'roofing_covering_rating',
            findingsKey: 'roofing_covering_findings',
          ),
          ConditionRatingSubSystem(
            name: 'Flashing',
            ratingKey: 'roofing_flashing_rating',
            findingsKey: 'roofing_flashing_findings',
          ),
          ConditionRatingSubSystem(
            name: 'Drainage',
            ratingKey: 'roofing_drainage_rating',
            findingsKey: 'roofing_drainage_findings',
          ),
        ],
      ),

      // 8. Plumbing
      const ConditionRatingSection(
        systemName: 'Plumbing',
        ratingKey: 'plumbing_rating',
        findingsKey: 'plumbing_findings',
        photoKeys: ['plumbing_photos'],
        subSystems: [
          ConditionRatingSubSystem(
            name: 'Supply',
            ratingKey: 'plumbing_supply_rating',
            findingsKey: 'plumbing_supply_findings',
          ),
          ConditionRatingSubSystem(
            name: 'Drain/Waste',
            ratingKey: 'plumbing_drain_waste_rating',
            findingsKey: 'plumbing_drain_waste_findings',
          ),
          ConditionRatingSubSystem(
            name: 'Water Heater',
            ratingKey: 'plumbing_water_heater_rating',
            findingsKey: 'plumbing_water_heater_findings',
          ),
        ],
      ),

      // 9. Electrical
      const ConditionRatingSection(
        systemName: 'Electrical',
        ratingKey: 'electrical_rating',
        findingsKey: 'electrical_findings',
        photoKeys: ['electrical_photos'],
        subSystems: [
          ConditionRatingSubSystem(
            name: 'Service',
            ratingKey: 'electrical_service_rating',
            findingsKey: 'electrical_service_findings',
          ),
          ConditionRatingSubSystem(
            name: 'Panels',
            ratingKey: 'electrical_panels_rating',
            findingsKey: 'electrical_panels_findings',
          ),
          ConditionRatingSubSystem(
            name: 'Branch Circuits',
            ratingKey: 'electrical_branch_circuits_rating',
            findingsKey: 'electrical_branch_circuits_findings',
          ),
          ConditionRatingSubSystem(
            name: 'GFCI',
            ratingKey: 'electrical_gfci_rating',
            findingsKey: 'electrical_gfci_findings',
          ),
        ],
      ),

      // 10. HVAC
      const ConditionRatingSection(
        systemName: 'HVAC',
        ratingKey: 'hvac_rating',
        findingsKey: 'hvac_findings',
        photoKeys: ['hvac_photos'],
        subSystems: [
          ConditionRatingSubSystem(
            name: 'Heating',
            ratingKey: 'hvac_heating_rating',
            findingsKey: 'hvac_heating_findings',
          ),
          ConditionRatingSubSystem(
            name: 'Cooling',
            ratingKey: 'hvac_cooling_rating',
            findingsKey: 'hvac_cooling_findings',
          ),
          ConditionRatingSubSystem(
            name: 'Distribution',
            ratingKey: 'hvac_distribution_rating',
            findingsKey: 'hvac_distribution_findings',
          ),
        ],
      ),

      // 11. Insulation and Ventilation
      const ConditionRatingSection(
        systemName: 'Insulation and Ventilation',
        ratingKey: 'insulation_ventilation_rating',
        findingsKey: 'insulation_ventilation_findings',
        photoKeys: ['insulation_ventilation_photos'],
        subSystems: [
          ConditionRatingSubSystem(
            name: 'Attic',
            ratingKey: 'insulation_ventilation_attic_rating',
            findingsKey: 'insulation_ventilation_attic_findings',
          ),
          ConditionRatingSubSystem(
            name: 'Wall',
            ratingKey: 'insulation_ventilation_wall_rating',
            findingsKey: 'insulation_ventilation_wall_findings',
          ),
          ConditionRatingSubSystem(
            name: 'Crawlspace',
            ratingKey: 'insulation_ventilation_crawlspace_rating',
            findingsKey: 'insulation_ventilation_crawlspace_findings',
          ),
        ],
      ),

      // 12. Built-in Appliances (no sub-systems)
      const ConditionRatingSection(
        systemName: 'Built-in Appliances',
        ratingKey: 'appliances_rating',
        findingsKey: 'appliances_findings',
        photoKeys: ['appliances_photos'],
      ),

      // 13. Life Safety
      const ConditionRatingSection(
        systemName: 'Life Safety',
        ratingKey: 'life_safety_rating',
        findingsKey: 'life_safety_findings',
        photoKeys: ['life_safety_photos'],
        subSystems: [
          ConditionRatingSubSystem(
            name: 'Smoke Detectors',
            ratingKey: 'life_safety_smoke_detectors_rating',
            findingsKey: 'life_safety_smoke_detectors_findings',
          ),
          ConditionRatingSubSystem(
            name: 'CO Detectors',
            ratingKey: 'life_safety_co_detectors_rating',
            findingsKey: 'life_safety_co_detectors_findings',
          ),
          ConditionRatingSubSystem(
            name: 'Fire Sprinklers',
            ratingKey: 'life_safety_fire_sprinklers_rating',
            findingsKey: 'life_safety_fire_sprinklers_findings',
          ),
        ],
      ),

      // 14. Checklist Summary
      ChecklistSummarySection(
        heading: 'System Condition Summary',
        items: [
          ChecklistSummaryItem(
            label: 'Structural Components',
            status: _resolveStatus(formData, 'structural_rating'),
            notes: formData['structural_findings'] as String? ?? '',
          ),
          ChecklistSummaryItem(
            label: 'Exterior',
            status: _resolveStatus(formData, 'exterior_rating'),
            notes: formData['exterior_findings'] as String? ?? '',
          ),
          ChecklistSummaryItem(
            label: 'Roofing',
            status: _resolveStatus(formData, 'roofing_rating'),
            notes: formData['roofing_findings'] as String? ?? '',
          ),
          ChecklistSummaryItem(
            label: 'Plumbing',
            status: _resolveStatus(formData, 'plumbing_rating'),
            notes: formData['plumbing_findings'] as String? ?? '',
          ),
          ChecklistSummaryItem(
            label: 'Electrical',
            status: _resolveStatus(formData, 'electrical_rating'),
            notes: formData['electrical_findings'] as String? ?? '',
          ),
          ChecklistSummaryItem(
            label: 'HVAC',
            status: _resolveStatus(formData, 'hvac_rating'),
            notes: formData['hvac_findings'] as String? ?? '',
          ),
          ChecklistSummaryItem(
            label: 'Insulation and Ventilation',
            status: _resolveStatus(formData, 'insulation_ventilation_rating'),
            notes:
                formData['insulation_ventilation_findings'] as String? ?? '',
          ),
          ChecklistSummaryItem(
            label: 'Built-in Appliances',
            status: _resolveStatus(formData, 'appliances_rating'),
            notes: formData['appliances_findings'] as String? ?? '',
          ),
          ChecklistSummaryItem(
            label: 'Life Safety',
            status: _resolveStatus(formData, 'life_safety_rating'),
            notes: formData['life_safety_findings'] as String? ?? '',
          ),
        ],
      ),

      // 15. General Comments
      const NarrativeParagraphSection(
        heading: 'General Comments',
        bodyKey: 'general_comments',
      ),

      // 16. Disclaimer
      const DisclaimerSection(
        heading: 'Standards of Practice and Limitations',
        paragraphs: [
          'This inspection was conducted in accordance with the Standards of '
              'Practice set forth by the State of Florida, Rule 61-30.801, '
              'F.A.C. The inspection is a visual examination of the readily '
              'accessible systems and components of the home. It is not '
              'technically exhaustive. This inspection does not include: '
              'concealed or inaccessible items, environmental concerns (mold, '
              'asbestos, lead, radon), geological conditions, or cosmetic '
              'defects. The inspector is not required to determine the cause '
              'of conditions or offer solutions.',
        ],
      ),

      // 17. Signature block
      const SignatureBlockSection(
        title: 'Certification',
        certificationText:
            'I certify that this home inspection was conducted in accordance '
            'with the requirements of Florida Administrative Code Rule '
            '61-30.801, and that the findings reported herein are accurate to '
            'the best of my professional knowledge and belief.',
      ),
    ];
  }

  /// Resolves a rating status string from form data, defaulting to
  /// "Not Inspected" when the key is missing or empty.
  static String _resolveStatus(
    Map<String, dynamic> formData,
    String key,
  ) {
    final value = formData[key] as String?;
    if (value != null && value.isNotEmpty) {
      return ConditionRating.parse(value).displayLabel;
    }
    return ConditionRating.notInspected.displayLabel;
  }

  @override
  Set<String> get requiredPhotoKeys => const {
        'structural_photos',
        'exterior_photos',
        'roofing_photos',
        'plumbing_photos',
        'electrical_photos',
        'hvac_photos',
        'insulation_ventilation_photos',
        'appliances_photos',
        'life_safety_photos',
      };

  @override
  Set<String> get referencedFormDataKeys => const {
        // Narrative paragraphs
        'scope_and_purpose',
        'general_comments',
        // System-level ratings and findings
        'structural_rating',
        'structural_findings',
        'exterior_rating',
        'exterior_findings',
        'roofing_rating',
        'roofing_findings',
        'plumbing_rating',
        'plumbing_findings',
        'electrical_rating',
        'electrical_findings',
        'hvac_rating',
        'hvac_findings',
        'insulation_ventilation_rating',
        'insulation_ventilation_findings',
        'appliances_rating',
        'appliances_findings',
        'life_safety_rating',
        'life_safety_findings',
        // Structural sub-systems
        'structural_foundation_rating',
        'structural_foundation_findings',
        'structural_framing_rating',
        'structural_framing_findings',
        'structural_roof_structure_rating',
        'structural_roof_structure_findings',
        // Exterior sub-systems
        'exterior_siding_rating',
        'exterior_siding_findings',
        'exterior_trim_rating',
        'exterior_trim_findings',
        'exterior_porches_rating',
        'exterior_porches_findings',
        'exterior_driveways_rating',
        'exterior_driveways_findings',
        // Roofing sub-systems
        'roofing_covering_rating',
        'roofing_covering_findings',
        'roofing_flashing_rating',
        'roofing_flashing_findings',
        'roofing_drainage_rating',
        'roofing_drainage_findings',
        // Plumbing sub-systems
        'plumbing_supply_rating',
        'plumbing_supply_findings',
        'plumbing_drain_waste_rating',
        'plumbing_drain_waste_findings',
        'plumbing_water_heater_rating',
        'plumbing_water_heater_findings',
        // Electrical sub-systems
        'electrical_service_rating',
        'electrical_service_findings',
        'electrical_panels_rating',
        'electrical_panels_findings',
        'electrical_branch_circuits_rating',
        'electrical_branch_circuits_findings',
        'electrical_gfci_rating',
        'electrical_gfci_findings',
        // HVAC sub-systems
        'hvac_heating_rating',
        'hvac_heating_findings',
        'hvac_cooling_rating',
        'hvac_cooling_findings',
        'hvac_distribution_rating',
        'hvac_distribution_findings',
        // Insulation and Ventilation sub-systems
        'insulation_ventilation_attic_rating',
        'insulation_ventilation_attic_findings',
        'insulation_ventilation_wall_rating',
        'insulation_ventilation_wall_findings',
        'insulation_ventilation_crawlspace_rating',
        'insulation_ventilation_crawlspace_findings',
        // Life Safety sub-systems
        'life_safety_smoke_detectors_rating',
        'life_safety_smoke_detectors_findings',
        'life_safety_co_detectors_rating',
        'life_safety_co_detectors_findings',
        'life_safety_fire_sprinklers_rating',
        'life_safety_fire_sprinklers_findings',
      };
}
