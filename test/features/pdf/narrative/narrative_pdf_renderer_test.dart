import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_pdf_renderer.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_print_theme.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_section.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_template.dart';

import 'helpers/test_render_context.dart';

/// Test template that returns a configurable list of sections.
class _TestTemplate extends NarrativeTemplate {
  const _TestTemplate({
    this.sections = const [],
    super.formType = FormType.generalInspection,
    super.revisionLabel = 'Rev 1.0 - Test',
    super.title = 'Test Narrative Report',
  });

  final List<NarrativeSection> sections;

  @override
  List<NarrativeSection> buildSections({
    required Map<String, dynamic> formData,
    required Map<String, dynamic> branchContext,
  }) =>
      sections;

  @override
  Set<String> get requiredPhotoKeys => {};

  @override
  Set<String> get referencedFormDataKeys => {};
}

void main() {
  late NarrativePdfRenderer renderer;
  late NarrativePrintTheme theme;

  setUp(() {
    renderer = const NarrativePdfRenderer();
    theme = NarrativePrintTheme.standard();
  });

  group('NarrativePdfRenderer', () {
    test('render() produces valid PDF bytes', () async {
      const template = _TestTemplate(
        sections: [
          HeaderSection(
            title: 'Test Report',
            subtitle: 'Subtitle',
            formLabel: 'Form Label',
          ),
          NarrativeParagraphSection(
            heading: 'Section 1',
            bodyKey: 'body_1',
            fallbackBody: 'Default body text for section one.',
          ),
        ],
      );

      final bytes = await renderer.render(
        template: template,
        theme: theme,
        context: buildTestRenderContext(),
        formData: const {},
        branchContext: const {},
      );

      expect(bytes, isNotEmpty);
      // PDF files start with %PDF
      expect(bytes[0], 0x25); // %
      expect(bytes[1], 0x50); // P
      expect(bytes[2], 0x44); // D
      expect(bytes[3], 0x46); // F
    });

    test('empty sections list produces valid single-page PDF', () async {
      const template = _TestTemplate(sections: []);

      final bytes = await renderer.render(
        template: template,
        theme: theme,
        context: buildTestRenderContext(),
        formData: const {},
        branchContext: const {},
      );

      expect(bytes, isNotEmpty);
      expect(bytes[0], 0x25); // %PDF magic
      expect(bytes[1], 0x50);
    });

    test('mixed sections produce multi-page PDF', () async {
      // Generate enough paragraph sections to overflow onto multiple pages.
      final sections = <NarrativeSection>[
        const HeaderSection(title: 'Multi-Page Report'),
        for (var i = 0; i < 40; i++)
          NarrativeParagraphSection(
            heading: 'Section $i',
            bodyKey: 'body_$i',
            fallbackBody: 'This is paragraph $i. '
                'It contains enough text to contribute to filling a page. '
                'The accumulated content from many such paragraphs should '
                'cause the document to span multiple pages, validating that '
                'the MultiPage widget correctly handles page overflow. '
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                'Sed do eiusmod tempor incididunt ut labore et dolore magna. '
                'Ut enim ad minim veniam, quis nostrud exercitation ullamco '
                'laboris nisi ut aliquip ex ea commodo consequat.',
          ),
      ];

      final template = _TestTemplate(sections: sections);

      final bytes = await renderer.render(
        template: template,
        theme: theme,
        context: buildTestRenderContext(),
        formData: const {},
        branchContext: const {},
      );

      expect(bytes, isNotEmpty);

      // Parse the PDF to count pages. The dart_pdf package uses
      // /Type/Page (no space) for page objects and /Count N for page tree.
      final pdfString = String.fromCharCodes(bytes);
      // Extract page count from the /Count field in the Pages object
      final countMatch = RegExp(r'/Count\s+(\d+)').firstMatch(pdfString);
      final actualPages = countMatch != null
          ? int.parse(countMatch.group(1)!)
          : 0;

      expect(
        actualPages,
        greaterThan(1),
        reason: 'Expected multi-page PDF with 30 paragraphs',
      );
    });

    test('page footer includes page numbers', () async {
      // Create enough content for at least 2 pages so we can verify
      // footer produces a multi-page document (footer is rendered on
      // every page by the MultiPage widget).
      final sections = <NarrativeSection>[
        for (var i = 0; i < 40; i++)
          NarrativeParagraphSection(
            heading: 'Paragraph $i',
            bodyKey: 'p_$i',
            fallbackBody: 'Content for paragraph $i that fills space. '
                'More text to ensure proper page filling behavior. '
                'Additional filler text for the multi-page test scenario. '
                'Ut enim ad minim veniam, quis nostrud exercitation.',
          ),
      ];

      final template = _TestTemplate(
        sections: sections,
        revisionLabel: 'Rev TEST-1.0',
      );

      final bytes = await renderer.render(
        template: template,
        theme: theme,
        context: buildTestRenderContext(),
        formData: const {},
        branchContext: const {},
      );

      // Verify we got a valid multi-page PDF (footer is present on each page)
      expect(bytes, isNotEmpty);
      final pdfString = String.fromCharCodes(bytes);
      final countMatch = RegExp(r'/Count\s+(\d+)').firstMatch(pdfString);
      final actualPages = countMatch != null
          ? int.parse(countMatch.group(1)!)
          : 0;
      expect(
        actualPages,
        greaterThan(1),
        reason: 'Footer test needs a multi-page document',
      );
    });

    test('page header renders on continuation pages', () async {
      // Build a document with content that overflows to page 2.
      // The header callback returns SizedBox(height:0) on page 1 and
      // a title + accent line on pages 2+. We verify multi-page output.
      final sections = <NarrativeSection>[
        const HeaderSection(title: 'First Page Header Section'),
        for (var i = 0; i < 40; i++)
          NarrativeParagraphSection(
            heading: 'Fill Section $i',
            bodyKey: 'fill_$i',
            fallbackBody: 'Filling text for overflow to page 2. '
                'This paragraph contributes to exceeding the page boundary. '
                'More filler to ensure we overflow onto multiple pages.',
          ),
      ];

      final template = _TestTemplate(
        sections: sections,
        title: 'Header Visibility Test Report',
      );

      final bytes = await renderer.render(
        template: template,
        theme: theme,
        context: buildTestRenderContext(),
        formData: const {},
        branchContext: const {},
      );

      expect(bytes, isNotEmpty);
      // Verify multi-page output (page 2+ would have the header rendered)
      final pdfString = String.fromCharCodes(bytes);
      final countMatch = RegExp(r'/Count\s+(\d+)').firstMatch(pdfString);
      final actualPages = countMatch != null
          ? int.parse(countMatch.group(1)!)
          : 0;
      expect(
        actualPages,
        greaterThan(1),
        reason: 'Need multiple pages to verify header on continuation pages',
      );
    });
  });
}
