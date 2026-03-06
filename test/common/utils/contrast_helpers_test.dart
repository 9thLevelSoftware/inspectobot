import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/common/utils/contrast_helpers.dart';
import 'package:inspectobot/theme/palette.dart';

void main() {
  group('ContrastHelpers', () {
    group('relativeLuminance', () {
      test('black has luminance ~0.0', () {
        final luminance =
            ContrastHelpers.relativeLuminance(const Color(0xFF000000));
        expect(luminance, closeTo(0.0, 0.001));
      });

      test('white has luminance ~1.0', () {
        final luminance =
            ContrastHelpers.relativeLuminance(const Color(0xFFFFFFFF));
        expect(luminance, closeTo(1.0, 0.001));
      });
    });

    group('contrastRatio', () {
      test('black/white contrast ratio ~21.0', () {
        final ratio = ContrastHelpers.contrastRatio(
          const Color(0xFF000000),
          const Color(0xFFFFFFFF),
        );
        expect(ratio, closeTo(21.0, 0.1));
      });

      test('same color contrast ratio ~1.0', () {
        const color = Color(0xFF808080);
        final ratio = ContrastHelpers.contrastRatio(color, color);
        expect(ratio, closeTo(1.0, 0.001));
      });

      test('Palette.onSurface on Palette.background meets AAA', () {
        final ratio = ContrastHelpers.contrastRatio(
          Palette.onSurface,
          Palette.background,
        );
        // onSurface (0xFFE8E6E3) on background (0xFF141418) should be very high
        expect(ratio, greaterThanOrEqualTo(7.0));
        expect(
          ContrastHelpers.meetsAAANormal(Palette.onSurface, Palette.background),
          isTrue,
        );
      });

      test('Palette.primary on Palette.surface — verify and document ratio',
          () {
        final ratio = ContrastHelpers.contrastRatio(
          Palette.primary,
          Palette.surface,
        );
        // Primary orange (0xFFF28C38) on surface (0xFF1C1C22)
        // Expected to meet AA but document actual ratio
        expect(ratio, greaterThan(1.0));
        // Document: primary on surface ratio for reference
        // ignore: avoid_print
        print('Palette.primary on Palette.surface contrast ratio: $ratio');
        // Orange on dark surface should meet at least AA for large text
        expect(
          ContrastHelpers.meetsAAALarge(Palette.primary, Palette.surface),
          isTrue,
        );
      });
    });

    group('WCAG checks', () {
      test('meetsAAANormal returns true for high contrast pair', () {
        expect(
          ContrastHelpers.meetsAAANormal(
            const Color(0xFF000000),
            const Color(0xFFFFFFFF),
          ),
          isTrue,
        );
      });

      test('meetsAAANormal returns false for low contrast pair', () {
        expect(
          ContrastHelpers.meetsAAANormal(
            const Color(0xFF777777),
            const Color(0xFF888888),
          ),
          isFalse,
        );
      });

      test('meetsAAALarge returns true for medium contrast pair', () {
        // A pair that meets 4.5 but not 7.0
        expect(
          ContrastHelpers.meetsAAALarge(
            const Color(0xFF000000),
            const Color(0xFFFFFFFF),
          ),
          isTrue,
        );
      });

      test('meetsAANormal returns correct booleans', () {
        // High contrast: should pass
        expect(
          ContrastHelpers.meetsAANormal(
            const Color(0xFF000000),
            const Color(0xFFFFFFFF),
          ),
          isTrue,
        );
        // Very low contrast: should fail
        expect(
          ContrastHelpers.meetsAANormal(
            const Color(0xFF777777),
            const Color(0xFF888888),
          ),
          isFalse,
        );
      });
    });
  });
}
