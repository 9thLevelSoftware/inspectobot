import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_print_theme.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_section.dart';

import '../helpers/test_render_context.dart';

void main() {
  late NarrativePrintTheme theme;

  setUp(() {
    theme = NarrativePrintTheme.standard();
  });

  group('HeaderSection', () {
    test('renders with title only', () {
      final section = HeaderSection(title: '4-Point Inspection Report');
      final context = buildTestRenderContext();

      final widgets = section.render(theme: theme, context: context);

      expect(widgets, isNotEmpty);
      // Should include accent bar, title, and spacing
      expect(widgets.length, greaterThanOrEqualTo(3));
    });

    test('renders with subtitle and form label', () {
      final section = HeaderSection(
        title: '4-Point Inspection Report',
        subtitle: 'Residential Property Assessment',
        formLabel: 'Form Insp4pt 03-25',
      );
      final context = buildTestRenderContext();

      final widgets = section.render(theme: theme, context: context);

      expect(widgets, isNotEmpty);
      // accent bar + title + subtitle spacing + subtitle + label spacing + label + section spacing
      expect(widgets.length, greaterThanOrEqualTo(5));
    });

    test('renders with logo bytes', () {
      final section = HeaderSection(
        title: '4-Point Inspection Report',
        logoBytes: buildTestPngBytes(),
      );
      final context = buildTestRenderContext();

      final widgets = section.render(theme: theme, context: context);

      expect(widgets, isNotEmpty);
    });
  });
}
