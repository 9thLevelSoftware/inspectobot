import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_print_theme.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_section.dart';

import '../helpers/test_render_context.dart';

void main() {
  late NarrativePrintTheme theme;

  setUp(() {
    theme = NarrativePrintTheme.standard();
  });

  group('SignatureBlockSection', () {
    test('renders with signature image', () {
      const section = SignatureBlockSection(
        title: 'Inspector Certification',
        certificationText:
            'I certify that this inspection was performed in accordance '
            'with applicable standards.',
      );
      final context = buildTestRenderContext(
        signatureBytes: buildTestPngBytes(),
      );

      final widgets = section.render(theme: theme, context: context);

      expect(widgets, isNotEmpty);
      // title + spacing + cert text + double spacing + divider + gap +
      // signature image + spacing + name + license + date + section spacing
      expect(widgets.length, greaterThanOrEqualTo(8));
    });

    test('renders fallback text when no signature', () {
      const section = SignatureBlockSection(
        title: 'Inspector Certification',
        certificationText: 'I certify this inspection.',
      );
      final context = buildTestRenderContext();

      final widgets = section.render(theme: theme, context: context);

      expect(widgets, isNotEmpty);
    });

    test('renders fallback for empty signature bytes', () {
      const section = SignatureBlockSection(
        title: 'Certification',
        certificationText: 'Certified.',
      );
      final context = buildTestRenderContext(
        signatureBytes: Uint8List(0),
      );

      final widgets = section.render(theme: theme, context: context);

      expect(widgets, isNotEmpty);
    });

    test('includes inspector details from context', () {
      const section = SignatureBlockSection(
        title: 'Certification',
        certificationText: 'Certified.',
      );
      final context = buildTestRenderContext(
        inspectorName: 'Bob Inspector',
        inspectorLicense: 'FL-99999',
      );

      final widgets = section.render(theme: theme, context: context);

      expect(widgets, isNotEmpty);
    });
  });
}
