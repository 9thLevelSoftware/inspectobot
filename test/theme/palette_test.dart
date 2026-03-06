import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/theme/palette.dart';

void main() {
  group('Palette color constants', () {
    // -------------------------------------------------------------------------
    // Surface
    // -------------------------------------------------------------------------
    test('background', () {
      expect(Palette.background.value, 0xFF141418);
    });

    test('surface', () {
      expect(Palette.surface.value, 0xFF1C1C22);
    });

    test('surfaceVariant', () {
      expect(Palette.surfaceVariant.value, 0xFF2A2A32);
    });

    test('surfaceContainerLowest', () {
      expect(Palette.surfaceContainerLowest.value, 0xFF111114);
    });

    test('surfaceContainerLow', () {
      expect(Palette.surfaceContainerLow.value, 0xFF1A1A1F);
    });

    test('surfaceContainer', () {
      expect(Palette.surfaceContainer.value, 0xFF222228);
    });

    test('surfaceContainerHigh', () {
      expect(Palette.surfaceContainerHigh.value, 0xFF2C2C34);
    });

    test('surfaceContainerHighest', () {
      expect(Palette.surfaceContainerHighest.value, 0xFF363640);
    });

    // -------------------------------------------------------------------------
    // Primary (Orange)
    // -------------------------------------------------------------------------
    test('primary', () {
      expect(Palette.primary.value, 0xFFF28C38);
    });

    test('onPrimary', () {
      expect(Palette.onPrimary.value, 0xFF1C1C22);
    });

    test('primaryContainer', () {
      expect(Palette.primaryContainer.value, 0xFF3D2A14);
    });

    test('onPrimaryContainer', () {
      expect(Palette.onPrimaryContainer.value, 0xFFF5B06A);
    });

    // -------------------------------------------------------------------------
    // Secondary (Yellow/Amber)
    // -------------------------------------------------------------------------
    test('secondary', () {
      expect(Palette.secondary.value, 0xFFF2C744);
    });

    test('onSecondary', () {
      expect(Palette.onSecondary.value, 0xFF1C1C22);
    });

    test('secondaryContainer', () {
      expect(Palette.secondaryContainer.value, 0xFF3D3414);
    });

    test('onSecondaryContainer', () {
      expect(Palette.onSecondaryContainer.value, 0xFFF5D97A);
    });

    // -------------------------------------------------------------------------
    // Tertiary (Blue-Gray)
    // -------------------------------------------------------------------------
    test('tertiary', () {
      expect(Palette.tertiary.value, 0xFF7AACBF);
    });

    test('onTertiary', () {
      expect(Palette.onTertiary.value, 0xFF141418);
    });

    test('tertiaryContainer', () {
      expect(Palette.tertiaryContainer.value, 0xFF1A2E36);
    });

    test('onTertiaryContainer', () {
      expect(Palette.onTertiaryContainer.value, 0xFFA3C8D6);
    });

    // -------------------------------------------------------------------------
    // Error
    // -------------------------------------------------------------------------
    test('error', () {
      expect(Palette.error.value, 0xFFF2564B);
    });

    test('onError', () {
      expect(Palette.onError.value, 0xFFFFFFFF);
    });

    test('errorContainer', () {
      expect(Palette.errorContainer.value, 0xFF3D1410);
    });

    test('onErrorContainer', () {
      expect(Palette.onErrorContainer.value, 0xFFF5897F);
    });

    // -------------------------------------------------------------------------
    // Text & outline
    // -------------------------------------------------------------------------
    test('onSurface', () {
      expect(Palette.onSurface.value, 0xFFE8E6E3);
    });

    test('onSurfaceVariant', () {
      expect(Palette.onSurfaceVariant.value, 0xFFA8A6A3);
    });

    test('outline', () {
      expect(Palette.outline.value, 0xFF444450);
    });

    test('outlineVariant', () {
      expect(Palette.outlineVariant.value, 0xFF2E2E38);
    });

    // -------------------------------------------------------------------------
    // Inverse & misc
    // -------------------------------------------------------------------------
    test('shadow', () {
      expect(Palette.shadow.value, 0xFF000000);
    });

    test('scrim', () {
      expect(Palette.scrim.value, 0xFF000000);
    });

    test('inverseSurface', () {
      expect(Palette.inverseSurface.value, 0xFFE8E6E3);
    });

    test('onInverseSurface', () {
      expect(Palette.onInverseSurface.value, 0xFF1C1C22);
    });

    test('inversePrimary', () {
      expect(Palette.inversePrimary.value, 0xFF8B5A1E);
    });

    test('surfaceTint', () {
      expect(Palette.surfaceTint.value, 0xFFF28C38);
    });

    // -------------------------------------------------------------------------
    // Custom semantic
    // -------------------------------------------------------------------------
    test('success', () {
      expect(Palette.success.value, 0xFF4CAF6A);
    });

    test('warning', () {
      expect(Palette.warning.value, 0xFFF2A83A);
    });

    test('info', () {
      expect(Palette.info.value, 0xFF5B9BD5);
    });

    test('disabled', () {
      expect(Palette.disabled.value, 0xFF6B6968);
    });
  });
}
