import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_section.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_template.dart';

/// Minimal concrete template for testing the abstract base.
class _TestTemplate extends NarrativeTemplate {
  const _TestTemplate({
    super.formType = FormType.generalInspection,
    super.revisionLabel = 'Rev 1.0 — Test',
    super.title = 'Test Report',
  });

  @override
  List<NarrativeSection> buildSections({
    required Map<String, dynamic> formData,
    required Map<String, dynamic> branchContext,
  }) {
    return [
      HeaderSection(
        title: title,
        subtitle: branchContext['company_name'] as String?,
        formLabel: formType.label,
      ),
      NarrativeParagraphSection(
        heading: 'Overview',
        bodyKey: 'overview_text',
        fallbackBody: 'No overview provided.',
      ),
      const DisclaimerSection(
        heading: 'Disclaimer',
        paragraphs: ['This is a test disclaimer.'],
      ),
    ];
  }

  @override
  Set<String> get requiredPhotoKeys => {'exterior_front', 'exterior_rear'};

  @override
  Set<String> get referencedFormDataKeys => {'overview_text', 'notes'};
}

void main() {
  group('NarrativeTemplate', () {
    test('can be subclassed with concrete implementation', () {
      const template = _TestTemplate();

      expect(template.formType, FormType.generalInspection);
      expect(template.revisionLabel, 'Rev 1.0 — Test');
      expect(template.title, 'Test Report');
    });

    test('buildSections returns expected section types', () {
      const template = _TestTemplate();

      final sections = template.buildSections(
        formData: {'overview_text': 'Test overview'},
        branchContext: {'company_name': 'Acme Inspections'},
      );

      expect(sections, hasLength(3));
      expect(sections[0], isA<HeaderSection>());
      expect(sections[1], isA<NarrativeParagraphSection>());
      expect(sections[2], isA<DisclaimerSection>());
    });

    test('requiredPhotoKeys returns expected set', () {
      const template = _TestTemplate();

      expect(
        template.requiredPhotoKeys,
        equals({'exterior_front', 'exterior_rear'}),
      );
    });

    test('referencedFormDataKeys returns expected set', () {
      const template = _TestTemplate();

      expect(
        template.referencedFormDataKeys,
        equals({'overview_text', 'notes'}),
      );
    });

    test('accepts custom constructor parameters', () {
      const template = _TestTemplate(
        formType: FormType.moldAssessment,
        revisionLabel: 'Rev 2.0',
        title: 'Mold Report',
      );

      expect(template.formType, FormType.moldAssessment);
      expect(template.revisionLabel, 'Rev 2.0');
      expect(template.title, 'Mold Report');
    });
  });
}
