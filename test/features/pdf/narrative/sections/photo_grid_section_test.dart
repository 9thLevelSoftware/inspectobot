import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_print_theme.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_section.dart';

import '../helpers/test_render_context.dart';

void main() {
  late NarrativePrintTheme theme;

  setUp(() {
    theme = NarrativePrintTheme.standard();
  });

  group('PhotoGridSection', () {
    test('renders heading and photo grid with resolved photos', () {
      final section = PhotoGridSection(
        heading: 'Exterior Photos',
        photoKeys: ['exterior_front', 'exterior_rear'],
      );
      final context = buildTestRenderContext(
        resolvedPhotos: {
          'exterior_front': [buildResolvedPhoto(sourceKey: 'exterior_front')],
          'exterior_rear': [buildResolvedPhoto(sourceKey: 'exterior_rear')],
        },
      );

      final widgets = section.render(theme: theme, context: context);

      expect(widgets, isNotEmpty);
      // heading + spacing + table + section spacing
      expect(widgets.length, equals(4));
    });

    test('renders placeholder for unresolved photos', () {
      final section = PhotoGridSection(
        heading: 'Exterior Photos',
        photoKeys: ['missing_photo'],
      );
      final context = buildTestRenderContext();

      final widgets = section.render(theme: theme, context: context);

      expect(widgets, isNotEmpty);
    });

    test('renders with category labels', () {
      final section = PhotoGridSection(
        heading: 'Roof Photos',
        photoKeys: ['roof_1'],
        categoryLabels: {'roof_1': 'Overview'},
      );
      final context = buildTestRenderContext(
        resolvedPhotos: {
          'roof_1': [buildResolvedPhoto(sourceKey: 'roof_1')],
        },
      );

      final widgets = section.render(theme: theme, context: context);

      expect(widgets, isNotEmpty);
    });

    test('renders with captions from form data', () {
      final section = PhotoGridSection(
        heading: 'Roof Photos',
        photoKeys: ['roof_1'],
        captionKeys: {'roof_1': 'roof_1_caption'},
      );
      final context = buildTestRenderContext(
        resolvedPhotos: {
          'roof_1': [buildResolvedPhoto(sourceKey: 'roof_1')],
        },
        formData: {'roof_1_caption': 'South-facing shingle detail'},
      );

      final widgets = section.render(theme: theme, context: context);

      expect(widgets, isNotEmpty);
    });

    test('returns empty list for empty photoKeys', () {
      const section = PhotoGridSection(
        heading: 'No Photos',
        photoKeys: [],
      );
      final context = buildTestRenderContext();

      final widgets = section.render(theme: theme, context: context);

      expect(widgets, isEmpty);
    });
  });
}
