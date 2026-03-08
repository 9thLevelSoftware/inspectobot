import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_pdf_renderer.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_print_theme.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_section.dart';
import 'package:inspectobot/features/pdf/narrative/templates/mold_assessment_template.dart';

import '../helpers/test_render_context.dart';

void main() {
  late MoldAssessmentTemplate template;
  late Map<String, dynamic> formData;
  late Map<String, dynamic> branchContext;

  setUp(() {
    template = const MoldAssessmentTemplate();
    formData = <String, dynamic>{};
    branchContext = <String, dynamic>{};
  });

  group('MoldAssessmentTemplate', () {
    test('buildSections returns correct section count', () {
      final sections = template.buildSections(
        formData: formData,
        branchContext: branchContext,
      );

      expect(sections.length, 14);
    });

    test('buildSections returns correct section types in order', () {
      final sections = template.buildSections(
        formData: formData,
        branchContext: branchContext,
      );

      expect(sections[0], isA<HeaderSection>());
      expect(sections[1], isA<PropertyInfoSection>());
      expect(sections[2], isA<TableOfContentsSection>());
      expect(sections[3], isA<NarrativeParagraphSection>());
      expect(sections[4], isA<NarrativeParagraphSection>());
      expect(sections[5], isA<NarrativeParagraphSection>());
      expect(sections[6], isA<PhotoGridSection>());
      expect(sections[7], isA<NarrativeParagraphSection>());
      expect(sections[8], isA<PhotoGridSection>());
      expect(sections[9], isA<PhotoGridSection>());
      expect(sections[10], isA<NarrativeParagraphSection>());
      expect(sections[11], isA<NarrativeParagraphSection>());
      expect(sections[12], isA<DisclaimerSection>());
      expect(sections[13], isA<SignatureBlockSection>());
    });

    test('requiredPhotoKeys returns 3 mold photo categories', () {
      final photoKeys = template.requiredPhotoKeys;

      expect(photoKeys.length, 3);
      expect(photoKeys, contains('mold_moisture_readings'));
      expect(photoKeys, contains('mold_growth_evidence'));
      expect(photoKeys, contains('mold_affected_areas'));
    });

    test('referencedFormDataKeys returns all expected keys', () {
      final keys = template.referencedFormDataKeys;

      expect(keys, contains('scope_of_assessment'));
      expect(keys, contains('visual_observations'));
      expect(keys, contains('moisture_sources'));
      expect(keys, contains('mold_type_location'));
      expect(keys, contains('remediation_recommendations'));
      expect(keys, contains('additional_findings'));
      expect(keys.length, 6);
    });

    test('DisclaimerSection contains statutory boilerplate', () {
      final sections = template.buildSections(
        formData: formData,
        branchContext: branchContext,
      );

      final disclaimer = sections[12] as DisclaimerSection;
      expect(disclaimer.heading, 'Limitations and Disclaimers');
      expect(disclaimer.paragraphs.length, 1);
      expect(
        disclaimer.paragraphs.first,
        contains('Florida Statutes Chapter 468, Part XVI'),
      );
      expect(
        disclaimer.paragraphs.first,
        contains('does not constitute a remediation protocol'),
      );
    });

    test('SignatureBlockSection has MRSA certification text', () {
      final sections = template.buildSections(
        formData: formData,
        branchContext: branchContext,
      );

      final signature = sections[13] as SignatureBlockSection;
      expect(signature.title, 'Certification');
      expect(
        signature.certificationText,
        contains('Florida Statutes Chapter 468, Part XVI'),
      );
      expect(
        signature.certificationText,
        contains('mold assessment was conducted'),
      );
    });

    test('HeaderSection uses subtitle from formData when provided', () {
      formData['report_subtitle'] = 'Custom Subtitle';
      final sections = template.buildSections(
        formData: formData,
        branchContext: branchContext,
      );

      final header = sections[0] as HeaderSection;
      expect(header.subtitle, 'Custom Subtitle');
    });

    test('HeaderSection uses default subtitle when not in formData', () {
      final sections = template.buildSections(
        formData: formData,
        branchContext: branchContext,
      );

      final header = sections[0] as HeaderSection;
      expect(header.subtitle, 'Comprehensive Mold Assessment');
    });

    test('end-to-end: renders valid PDF bytes', () async {
      final renderer = const NarrativePdfRenderer();
      final theme = NarrativePrintTheme.standard();
      final context = buildTestRenderContext();

      final pdfBytes = await renderer.render(
        template: template,
        theme: theme,
        context: context,
        formData: formData,
        branchContext: branchContext,
      );

      expect(pdfBytes, isNotEmpty);
      // PDF files start with %PDF
      expect(pdfBytes[0], 0x25); // %
      expect(pdfBytes[1], 0x50); // P
      expect(pdfBytes[2], 0x44); // D
      expect(pdfBytes[3], 0x46); // F
    });
  });
}
