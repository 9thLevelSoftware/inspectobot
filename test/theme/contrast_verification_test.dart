import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/common/utils/contrast_helpers.dart';
import 'package:inspectobot/theme/palette.dart';
import 'package:inspectobot/theme/tokens.dart';

void main() {
  // ---------------------------------------------------------------------------
  // AAA Normal (7.0:1) — body text on surfaces
  // ---------------------------------------------------------------------------
  group('WCAG AAA Normal text (7.0:1)', () {
    test('onSurface on background meets AAA Normal', () {
      final ratio = ContrastHelpers.contrastRatio(
        Palette.onSurface,
        Palette.background,
      );
      expect(ratio, greaterThanOrEqualTo(AppFieldUsability.wcagAAANormal));
      expect(
        ContrastHelpers.meetsAAANormal(Palette.onSurface, Palette.background),
        isTrue,
        reason: 'onSurface/background ratio $ratio must be >= 7.0',
      );
    });

    test('onSurface on surface meets AAA Normal', () {
      final ratio = ContrastHelpers.contrastRatio(
        Palette.onSurface,
        Palette.surface,
      );
      expect(ratio, greaterThanOrEqualTo(AppFieldUsability.wcagAAANormal));
      expect(
        ContrastHelpers.meetsAAANormal(Palette.onSurface, Palette.surface),
        isTrue,
        reason: 'onSurface/surface ratio $ratio must be >= 7.0',
      );
    });

    test('onSurface on surfaceVariant meets AAA Normal', () {
      final ratio = ContrastHelpers.contrastRatio(
        Palette.onSurface,
        Palette.surfaceVariant,
      );
      expect(ratio, greaterThanOrEqualTo(AppFieldUsability.wcagAAANormal));
      expect(
        ContrastHelpers.meetsAAANormal(
          Palette.onSurface,
          Palette.surfaceVariant,
        ),
        isTrue,
        reason: 'onSurface/surfaceVariant ratio $ratio must be >= 7.0',
      );
    });
  });

  // ---------------------------------------------------------------------------
  // AAA Large (4.5:1) — badges, buttons, headers, semantic colors
  // ---------------------------------------------------------------------------
  group('WCAG AAA Large text (4.5:1)', () {
    test('primary on surface meets AAA Large', () {
      final ratio = ContrastHelpers.contrastRatio(
        Palette.primary,
        Palette.surface,
      );
      expect(ratio, greaterThanOrEqualTo(AppFieldUsability.wcagAAALarge));
      expect(
        ContrastHelpers.meetsAAALarge(Palette.primary, Palette.surface),
        isTrue,
        reason: 'primary/surface ratio $ratio must be >= 4.5',
      );
    });

    test('primary on background meets AAA Large', () {
      final ratio = ContrastHelpers.contrastRatio(
        Palette.primary,
        Palette.background,
      );
      expect(ratio, greaterThanOrEqualTo(AppFieldUsability.wcagAAALarge));
      expect(
        ContrastHelpers.meetsAAALarge(Palette.primary, Palette.background),
        isTrue,
        reason: 'primary/background ratio $ratio must be >= 4.5',
      );
    });

    test('success on surface meets AAA Large', () {
      final ratio = ContrastHelpers.contrastRatio(
        Palette.success,
        Palette.surface,
      );
      expect(ratio, greaterThanOrEqualTo(AppFieldUsability.wcagAAALarge));
      expect(
        ContrastHelpers.meetsAAALarge(Palette.success, Palette.surface),
        isTrue,
        reason: 'success/surface ratio $ratio must be >= 4.5',
      );
    });

    test('warning on surface meets AAA Large', () {
      final ratio = ContrastHelpers.contrastRatio(
        Palette.warning,
        Palette.surface,
      );
      expect(ratio, greaterThanOrEqualTo(AppFieldUsability.wcagAAALarge));
      expect(
        ContrastHelpers.meetsAAALarge(Palette.warning, Palette.surface),
        isTrue,
        reason: 'warning/surface ratio $ratio must be >= 4.5',
      );
    });

    test('error on surface meets AAA Large', () {
      final ratio = ContrastHelpers.contrastRatio(
        Palette.error,
        Palette.surface,
      );
      expect(ratio, greaterThanOrEqualTo(AppFieldUsability.wcagAAALarge));
      expect(
        ContrastHelpers.meetsAAALarge(Palette.error, Palette.surface),
        isTrue,
        reason: 'error/surface ratio $ratio must be >= 4.5',
      );
    });

    test('info on surface meets AAA Large', () {
      final ratio = ContrastHelpers.contrastRatio(
        Palette.info,
        Palette.surface,
      );
      expect(ratio, greaterThanOrEqualTo(AppFieldUsability.wcagAAALarge));
      expect(
        ContrastHelpers.meetsAAALarge(Palette.info, Palette.surface),
        isTrue,
        reason: 'info/surface ratio $ratio must be >= 4.5',
      );
    });

    test('onPrimary on primary meets AAA Large', () {
      final ratio = ContrastHelpers.contrastRatio(
        Palette.onPrimary,
        Palette.primary,
      );
      expect(ratio, greaterThanOrEqualTo(AppFieldUsability.wcagAAALarge));
      expect(
        ContrastHelpers.meetsAAALarge(Palette.onPrimary, Palette.primary),
        isTrue,
        reason: 'onPrimary/primary ratio $ratio must be >= 4.5',
      );
    });

    test('onError on error meets AAA Large (after fix)', () {
      final ratio = ContrastHelpers.contrastRatio(
        Palette.onError,
        Palette.error,
      );
      expect(ratio, greaterThanOrEqualTo(AppFieldUsability.wcagAAALarge));
      expect(
        ContrastHelpers.meetsAAALarge(Palette.onError, Palette.error),
        isTrue,
        reason: 'onError/error ratio $ratio must be >= 4.5 '
            '(was 3.38 with white, now dark)',
      );
    });

    test('onSecondary on secondary meets AAA Large', () {
      final ratio = ContrastHelpers.contrastRatio(
        Palette.onSecondary,
        Palette.secondary,
      );
      expect(ratio, greaterThanOrEqualTo(AppFieldUsability.wcagAAALarge));
      expect(
        ContrastHelpers.meetsAAALarge(Palette.onSecondary, Palette.secondary),
        isTrue,
        reason: 'onSecondary/secondary ratio $ratio must be >= 4.5',
      );
    });
  });

  // ---------------------------------------------------------------------------
  // AA Normal (4.5:1) — secondary text
  // ---------------------------------------------------------------------------
  group('WCAG AA Normal text (4.5:1)', () {
    test('onSurfaceVariant on background meets AA Normal', () {
      final ratio = ContrastHelpers.contrastRatio(
        Palette.onSurfaceVariant,
        Palette.background,
      );
      expect(ratio, greaterThanOrEqualTo(AppFieldUsability.wcagAANormal));
      expect(
        ContrastHelpers.meetsAANormal(
          Palette.onSurfaceVariant,
          Palette.background,
        ),
        isTrue,
        reason: 'onSurfaceVariant/background ratio $ratio must be >= 4.5',
      );
    });

    test('onSurfaceVariant on surface meets AA Normal', () {
      final ratio = ContrastHelpers.contrastRatio(
        Palette.onSurfaceVariant,
        Palette.surface,
      );
      expect(ratio, greaterThanOrEqualTo(AppFieldUsability.wcagAANormal));
      expect(
        ContrastHelpers.meetsAANormal(
          Palette.onSurfaceVariant,
          Palette.surface,
        ),
        isTrue,
        reason: 'onSurfaceVariant/surface ratio $ratio must be >= 4.5',
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Summary: prints all computed ratios for documentation
  // ---------------------------------------------------------------------------
  test('Contrast ratio summary (documentation)', () {
    final pairs = <String, List<dynamic>>{
      'onSurface / background': [Palette.onSurface, Palette.background],
      'onSurface / surface': [Palette.onSurface, Palette.surface],
      'onSurface / surfaceVariant': [
        Palette.onSurface,
        Palette.surfaceVariant,
      ],
      'onSurfaceVariant / background': [
        Palette.onSurfaceVariant,
        Palette.background,
      ],
      'onSurfaceVariant / surface': [
        Palette.onSurfaceVariant,
        Palette.surface,
      ],
      'primary / surface': [Palette.primary, Palette.surface],
      'primary / background': [Palette.primary, Palette.background],
      'success / surface': [Palette.success, Palette.surface],
      'warning / surface': [Palette.warning, Palette.surface],
      'error / surface': [Palette.error, Palette.surface],
      'info / surface': [Palette.info, Palette.surface],
      'onPrimary / primary': [Palette.onPrimary, Palette.primary],
      'onError / error': [Palette.onError, Palette.error],
      'onSecondary / secondary': [Palette.onSecondary, Palette.secondary],
    };

    for (final entry in pairs.entries) {
      final ratio = ContrastHelpers.contrastRatio(
        entry.value[0],
        entry.value[1],
      );
      // All pairs must be at least AA (4.5:1).
      expect(
        ratio,
        greaterThanOrEqualTo(AppFieldUsability.wcagAANormal),
        reason: '${entry.key} ratio $ratio must be >= 4.5:1 (AA)',
      );
    }
  });
}
