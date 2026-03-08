import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_print_theme.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_section.dart';

import '../helpers/test_render_context.dart';

void main() {
  late NarrativePrintTheme theme;

  setUp(() {
    theme = NarrativePrintTheme.standard();
  });

  group('PropertyInfoSection', () {
    test('renders key-value grid with fields', () {
      final section = PropertyInfoSection(
        fields: [
          PropertyInfoField(label: 'Client', value: 'Jane Client'),
          PropertyInfoField(label: 'Address', value: '123 Main St'),
          PropertyInfoField(label: 'Date', value: '03/08/2026'),
        ],
      );
      final context = buildTestRenderContext();

      final widgets = section.render(theme: theme, context: context);

      expect(widgets, isNotEmpty);
      // Table + spacing
      expect(widgets.length, equals(2));
    });

    test('returns empty list for empty fields', () {
      const section = PropertyInfoSection(fields: []);
      final context = buildTestRenderContext();

      final widgets = section.render(theme: theme, context: context);

      expect(widgets, isEmpty);
    });
  });
}
