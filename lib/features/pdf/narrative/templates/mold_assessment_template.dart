import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_section.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_template.dart';

/// Narrative report template for Florida mold assessment reports.
///
/// Generates a report compliant with Florida Statutes Chapter 468, Part XVI,
/// covering visual observations, moisture source identification, mold type
/// documentation, and remediation protocol recommendations.
class MoldAssessmentTemplate extends NarrativeTemplate {
  const MoldAssessmentTemplate()
      : super(
          formType: FormType.moldAssessment,
          revisionLabel: 'Mold Assessment per Ch. 468 Part XVI F.S.',
          title: 'Mold Assessment Report',
        );

  @override
  List<NarrativeSection> buildSections({
    required Map<String, dynamic> formData,
    required Map<String, dynamic> branchContext,
  }) {
    final subtitle = formData['report_subtitle'] as String? ??
        'Comprehensive Mold Assessment';

    return [
      // 1. Header
      HeaderSection(
        title: 'Mold Assessment Report',
        subtitle: subtitle,
        formLabel: revisionLabel,
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
            label: 'Inspector MRSA License',
            value: formData['mrsa_license'] as String? ?? '',
          ),
          PropertyInfoField(
            label: 'Assessment Date',
            value: formData['assessment_date'] as String? ?? '',
          ),
        ],
      ),

      // 3. Table of contents
      const TableOfContentsSection(
        entries: [
          TocEntry(number: 1, title: 'Scope of Assessment'),
          TocEntry(number: 2, title: 'Visual Observations'),
          TocEntry(number: 3, title: 'Moisture Source Identification'),
          TocEntry(number: 4, title: 'Moisture Reading Documentation'),
          TocEntry(number: 5, title: 'Mold Type and Location Documentation'),
          TocEntry(number: 6, title: 'Mold Growth Evidence'),
          TocEntry(number: 7, title: 'Affected Area Documentation'),
          TocEntry(number: 8, title: 'Remediation Protocol Recommendations'),
          TocEntry(number: 9, title: 'Additional Findings'),
          TocEntry(number: 10, title: 'Limitations and Disclaimers'),
          TocEntry(number: 11, title: 'Certification'),
        ],
      ),

      // 4. Scope of Assessment
      const NarrativeParagraphSection(
        heading: 'Scope of Assessment',
        bodyKey: 'scope_of_assessment',
      ),

      // 5. Visual Observations
      const NarrativeParagraphSection(
        heading: 'Visual Observations',
        bodyKey: 'visual_observations',
      ),

      // 6. Moisture Source Identification
      const NarrativeParagraphSection(
        heading: 'Moisture Source Identification',
        bodyKey: 'moisture_sources',
      ),

      // 7. Moisture Reading Documentation (photo grid)
      const PhotoGridSection(
        heading: 'Moisture Reading Documentation',
        photoKeys: ['mold_moisture_readings'],
      ),

      // 8. Mold Type and Location Documentation
      const NarrativeParagraphSection(
        heading: 'Mold Type and Location Documentation',
        bodyKey: 'mold_type_location',
      ),

      // 9. Mold Growth Evidence (photo grid)
      const PhotoGridSection(
        heading: 'Mold Growth Evidence',
        photoKeys: ['mold_growth_evidence'],
      ),

      // 10. Affected Area Documentation (photo grid)
      const PhotoGridSection(
        heading: 'Affected Area Documentation',
        photoKeys: ['mold_affected_areas'],
      ),

      // 11. Remediation Protocol Recommendations
      const NarrativeParagraphSection(
        heading: 'Remediation Protocol Recommendations',
        bodyKey: 'remediation_recommendations',
      ),

      // 12. Additional Findings
      const NarrativeParagraphSection(
        heading: 'Additional Findings',
        bodyKey: 'additional_findings',
      ),

      // 13. Disclaimer
      const DisclaimerSection(
        heading: 'Limitations and Disclaimers',
        paragraphs: [
          'This mold assessment report was prepared in accordance with Florida '
              'Statutes Chapter 468, Part XVI. This assessment is limited to the '
              'areas that were accessible and visually inspectable at the time of '
              'the assessment. Concealed or inaccessible areas were not assessed. '
              'The assessor makes no warranty as to the condition of areas not '
              'assessed. This report does not constitute a remediation protocol. '
              'A separate remediation plan should be developed by a licensed mold '
              'remediator if remediation is recommended.',
        ],
      ),

      // 14. Signature block
      const SignatureBlockSection(
        title: 'Certification',
        certificationText:
            'I certify that this mold assessment was conducted in accordance '
            'with the requirements of Florida Statutes Chapter 468, Part XVI, '
            'and that the findings reported herein are accurate to the best of '
            'my professional knowledge and belief.',
      ),
    ];
  }

  @override
  Set<String> get requiredPhotoKeys => const {
        'mold_moisture_readings',
        'mold_growth_evidence',
        'mold_affected_areas',
      };

  @override
  Set<String> get referencedFormDataKeys => const {
        'scope_of_assessment',
        'visual_observations',
        'moisture_sources',
        'mold_type_location',
        'remediation_recommendations',
        'additional_findings',
      };
}
