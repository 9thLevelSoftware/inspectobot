import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_print_theme.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_section.dart';

import '../helpers/test_render_context.dart';

void main() {
  late NarrativePrintTheme theme;

  setUp(() {
    theme = NarrativePrintTheme.standard();
  });

  group('NarrativeParagraphSection', () {
    test('renders body from form data', () {
      final section = NarrativeParagraphSection(
        heading: 'Roof Assessment',
        bodyKey: 'roof_narrative',
      );
      final context = buildTestRenderContext(
        formData: {'roof_narrative': 'The roof is in good condition.'},
      );

      final widgets = section.render(theme: theme, context: context);

      expect(widgets, isNotEmpty);
      // heading + spacing + body + section spacing
      expect(widgets.length, equals(4));
    });

    test('uses fallback body when key is missing', () {
      final section = NarrativeParagraphSection(
        heading: 'Roof Assessment',
        bodyKey: 'nonexistent_key',
        fallbackBody: 'No assessment data available.',
      );
      final context = buildTestRenderContext();

      final widgets = section.render(theme: theme, context: context);

      expect(widgets, isNotEmpty);
    });

    test('uses empty string when key missing and no fallback', () {
      const section = NarrativeParagraphSection(
        heading: 'Roof Assessment',
        bodyKey: 'nonexistent_key',
      );
      final context = buildTestRenderContext();

      final widgets = section.render(theme: theme, context: context);

      expect(widgets, isNotEmpty);
    });

    test('respects headingLevel parameter', () {
      const section = NarrativeParagraphSection(
        heading: 'Sub Heading',
        bodyKey: 'test_key',
        headingLevel: 3,
      );
      final context = buildTestRenderContext(
        formData: {'test_key': 'Body text.'},
      );

      final widgets = section.render(theme: theme, context: context);

      expect(widgets, isNotEmpty);
    });
  });
}
