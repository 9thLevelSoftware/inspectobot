import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:inspectobot/features/pdf/narrative/narrative_print_theme.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_section.dart';

import '../helpers/test_render_context.dart';

void main() {
  late NarrativePrintTheme theme;

  setUp(() {
    theme = NarrativePrintTheme.standard();
  });

  group('PageBreakSection', () {
    test('renders a single NewPage widget', () {
      const section = PageBreakSection();
      final context = buildTestRenderContext();

      final widgets = section.render(theme: theme, context: context);

      expect(widgets, hasLength(1));
      expect(widgets.first, isA<pw.NewPage>());
    });
  });

  group('DisclaimerSection', () {
    test('renders heading and paragraphs', () {
      const section = DisclaimerSection(
        heading: 'Disclaimer',
        paragraphs: [
          'This report is provided as-is.',
          'No warranty is expressed or implied.',
        ],
      );
      final context = buildTestRenderContext();

      final widgets = section.render(theme: theme, context: context);

      expect(widgets, isNotEmpty);
      // divider + spacing + heading + half-spacing + (para + half-spacing) * 2 + section spacing
      expect(widgets.length, greaterThanOrEqualTo(6));
    });
  });

  group('TableOfContentsSection', () {
    test('renders numbered entries', () {
      final section = TableOfContentsSection(
        entries: [
          TocEntry(number: 1, title: 'Roof'),
          TocEntry(number: 2, title: 'Plumbing'),
          TocEntry(number: 3, title: 'Electrical'),
        ],
      );
      final context = buildTestRenderContext();

      final widgets = section.render(theme: theme, context: context);

      expect(widgets, isNotEmpty);
      // heading + spacing + 3 entries + section spacing
      expect(widgets.length, equals(6));
    });

    test('returns empty list for empty entries', () {
      const section = TableOfContentsSection(entries: []);
      final context = buildTestRenderContext();

      final widgets = section.render(theme: theme, context: context);

      expect(widgets, isEmpty);
    });
  });
}
