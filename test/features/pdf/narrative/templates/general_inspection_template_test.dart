import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_pdf_renderer.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_print_theme.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_section.dart';
import 'package:inspectobot/features/pdf/narrative/templates/general_inspection_template.dart';

import '../helpers/test_render_context.dart';

void main() {
  late GeneralInspectionTemplate template;
  late Map<String, dynamic> formData;
  late Map<String, dynamic> branchContext;

  setUp(() {
    template = const GeneralInspectionTemplate();
    formData = <String, dynamic>{};
    branchContext = <String, dynamic>{};
  });

  group('GeneralInspectionTemplate', () {
    test('buildSections returns correct section count', () {
      final sections = template.buildSections(
        formData: formData,
        branchContext: branchContext,
      );

      expect(sections.length, 17);
    });

    test('contains 9 ConditionRatingSection instances', () {
      final sections = template.buildSections(
        formData: formData,
        branchContext: branchContext,
      );

      final conditionSections =
          sections.whereType<ConditionRatingSection>().toList();
      expect(conditionSections.length, 9);
    });

    test('ConditionRatingSections are in correct order', () {
      final sections = template.buildSections(
        formData: formData,
        branchContext: branchContext,
      );

      final conditionSections =
          sections.whereType<ConditionRatingSection>().toList();

      expect(conditionSections[0].systemName, 'Structural Components');
      expect(conditionSections[1].systemName, 'Exterior');
      expect(conditionSections[2].systemName, 'Roofing');
      expect(conditionSections[3].systemName, 'Plumbing');
      expect(conditionSections[4].systemName, 'Electrical');
      expect(conditionSections[5].systemName, 'HVAC');
      expect(conditionSections[6].systemName, 'Insulation and Ventilation');
      expect(conditionSections[7].systemName, 'Built-in Appliances');
      expect(conditionSections[8].systemName, 'Life Safety');
    });

    test('requiredPhotoKeys covers all 9 system photo categories', () {
      final photoKeys = template.requiredPhotoKeys;

      expect(photoKeys.length, 9);
      expect(photoKeys, contains('structural_photos'));
      expect(photoKeys, contains('exterior_photos'));
      expect(photoKeys, contains('roofing_photos'));
      expect(photoKeys, contains('plumbing_photos'));
      expect(photoKeys, contains('electrical_photos'));
      expect(photoKeys, contains('hvac_photos'));
      expect(photoKeys, contains('insulation_ventilation_photos'));
      expect(photoKeys, contains('appliances_photos'));
      expect(photoKeys, contains('life_safety_photos'));
    });

    test('referencedFormDataKeys covers all system rating and findings keys',
        () {
      final keys = template.referencedFormDataKeys;

      // 9 systems x 2 (rating + findings) = 18 system-level keys
      // + 2 narrative paragraph keys (scope_and_purpose, general_comments)
      // + sub-system keys
      expect(keys, contains('scope_and_purpose'));
      expect(keys, contains('general_comments'));

      // System-level keys
      for (final system in [
        'structural',
        'exterior',
        'roofing',
        'plumbing',
        'electrical',
        'hvac',
        'insulation_ventilation',
        'appliances',
        'life_safety',
      ]) {
        expect(keys, contains('${system}_rating'));
        expect(keys, contains('${system}_findings'));
      }

      // Spot-check sub-system keys
      expect(keys, contains('structural_foundation_rating'));
      expect(keys, contains('structural_foundation_findings'));
      expect(keys, contains('electrical_gfci_rating'));
      expect(keys, contains('electrical_gfci_findings'));
      expect(keys, contains('life_safety_smoke_detectors_rating'));
      expect(keys, contains('life_safety_smoke_detectors_findings'));
    });

    test('ChecklistSummarySection tallies all 9 systems', () {
      final sections = template.buildSections(
        formData: formData,
        branchContext: branchContext,
      );

      final checklist = sections
          .whereType<ChecklistSummarySection>()
          .first;
      expect(checklist.heading, 'System Condition Summary');
      expect(checklist.items.length, 9);

      final labels = checklist.items.map((item) => item.label).toList();
      expect(labels, contains('Structural Components'));
      expect(labels, contains('Exterior'));
      expect(labels, contains('Roofing'));
      expect(labels, contains('Plumbing'));
      expect(labels, contains('Electrical'));
      expect(labels, contains('HVAC'));
      expect(labels, contains('Insulation and Ventilation'));
      expect(labels, contains('Built-in Appliances'));
      expect(labels, contains('Life Safety'));
    });

    test('ChecklistSummarySection resolves status from formData', () {
      formData['structural_rating'] = 'satisfactory';
      formData['exterior_rating'] = 'deficient';

      final sections = template.buildSections(
        formData: formData,
        branchContext: branchContext,
      );

      final checklist = sections
          .whereType<ChecklistSummarySection>()
          .first;

      final structural =
          checklist.items.firstWhere((i) => i.label == 'Structural Components');
      expect(structural.status, 'Satisfactory');

      final exterior =
          checklist.items.firstWhere((i) => i.label == 'Exterior');
      expect(exterior.status, 'Deficient');

      // Default when not provided
      final roofing =
          checklist.items.firstWhere((i) => i.label == 'Roofing');
      expect(roofing.status, 'Not Inspected');
    });

    test('DisclaimerSection contains Rule 61-30.801 reference', () {
      final sections = template.buildSections(
        formData: formData,
        branchContext: branchContext,
      );

      final disclaimer = sections.whereType<DisclaimerSection>().first;
      expect(
        disclaimer.heading,
        'Standards of Practice and Limitations',
      );
      expect(disclaimer.paragraphs.length, 1);
      expect(
        disclaimer.paragraphs.first,
        contains('Rule 61-30.801'),
      );
      expect(
        disclaimer.paragraphs.first,
        contains('not technically exhaustive'),
      );
    });

    test('SignatureBlockSection has certification text', () {
      final sections = template.buildSections(
        formData: formData,
        branchContext: branchContext,
      );

      final signature = sections.whereType<SignatureBlockSection>().first;
      expect(signature.title, 'Certification');
      expect(
        signature.certificationText,
        contains('Rule 61-30.801'),
      );
    });

    test('Built-in Appliances has no sub-systems', () {
      final sections = template.buildSections(
        formData: formData,
        branchContext: branchContext,
      );

      final appliances = sections
          .whereType<ConditionRatingSection>()
          .firstWhere((s) => s.systemName == 'Built-in Appliances');
      expect(appliances.subSystems, isNull);
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
