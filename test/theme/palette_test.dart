import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/theme/palette.dart';

void main() {
  group('Palette color constants', () {
    // -------------------------------------------------------------------------
    // Surface
    // -------------------------------------------------------------------------
    test('background', () {
      expect(Palette.background.toARGB32(), 0xFF141418);
    });

    test('surface', () {
      expect(Palette.surface.toARGB32(), 0xFF1C1C22);
    });

    test('surfaceVariant', () {
      expect(Palette.surfaceVariant.toARGB32(), 0xFF2A2A32);
    });

    test('surfaceContainerLowest', () {
      expect(Palette.surfaceContainerLowest.toARGB32(), 0xFF111114);
    });

    test('surfaceContainerLow', () {
      expect(Palette.surfaceContainerLow.toARGB32(), 0xFF1A1A1F);
    });

    test('surfaceContainer', () {
      expect(Palette.surfaceContainer.toARGB32(), 0xFF222228);
    });

    test('surfaceContainerHigh', () {
      expect(Palette.surfaceContainerHigh.toARGB32(), 0xFF2C2C34);
    });

    test('surfaceContainerHighest', () {
      expect(Palette.surfaceContainerHighest.toARGB32(), 0xFF363640);
    });

    // -------------------------------------------------------------------------
    // Primary (Orange)
    // -------------------------------------------------------------------------
    test('primary', () {
      expect(Palette.primary.toARGB32(), 0xFFF28C38);
    });

    test('onPrimary', () {
      expect(Palette.onPrimary.toARGB32(), 0xFF1C1C22);
    });

    test('primaryContainer', () {
      expect(Palette.primaryContainer.toARGB32(), 0xFF3D2A14);
    });

    test('onPrimaryContainer', () {
      expect(Palette.onPrimaryContainer.toARGB32(), 0xFFF5B06A);
    });

    // -------------------------------------------------------------------------
    // Secondary (Yellow/Amber)
    // -------------------------------------------------------------------------
    test('secondary', () {
      expect(Palette.secondary.toARGB32(), 0xFFF2C744);
    });

    test('onSecondary', () {
      expect(Palette.onSecondary.toARGB32(), 0xFF1C1C22);
    });

    test('secondaryContainer', () {
      expect(Palette.secondaryContainer.toARGB32(), 0xFF3D3414);
    });

    test('onSecondaryContainer', () {
      expect(Palette.onSecondaryContainer.toARGB32(), 0xFFF5D97A);
    });

    // -------------------------------------------------------------------------
    // Tertiary (Blue-Gray)
    // -------------------------------------------------------------------------
    test('tertiary', () {
      expect(Palette.tertiary.toARGB32(), 0xFF7AACBF);
    });

    test('onTertiary', () {
      expect(Palette.onTertiary.toARGB32(), 0xFF141418);
    });

    test('tertiaryContainer', () {
      expect(Palette.tertiaryContainer.toARGB32(), 0xFF1A2E36);
    });

    test('onTertiaryContainer', () {
      expect(Palette.onTertiaryContainer.toARGB32(), 0xFFA3C8D6);
    });

    // -------------------------------------------------------------------------
    // Error
    // -------------------------------------------------------------------------
    test('error', () {
      expect(Palette.error.toARGB32(), 0xFFF2564B);
    });

    test('onError', () {
      expect(Palette.onError.toARGB32(), 0xFF1C1C22);
    });

    test('errorContainer', () {
      expect(Palette.errorContainer.toARGB32(), 0xFF3D1410);
    });

    test('onErrorContainer', () {
      expect(Palette.onErrorContainer.toARGB32(), 0xFFF5897F);
    });

    // -------------------------------------------------------------------------
    // Text & outline
    // -------------------------------------------------------------------------
    test('onSurface', () {
      expect(Palette.onSurface.toARGB32(), 0xFFE8E6E3);
    });

    test('onSurfaceVariant', () {
      expect(Palette.onSurfaceVariant.toARGB32(), 0xFFA8A6A3);
    });

    test('outline', () {
      expect(Palette.outline.toARGB32(), 0xFF444450);
    });

    test('outlineVariant', () {
      expect(Palette.outlineVariant.toARGB32(), 0xFF2E2E38);
    });

    // -------------------------------------------------------------------------
    // Inverse & misc
    // -------------------------------------------------------------------------
    test('shadow', () {
      expect(Palette.shadow.toARGB32(), 0xFF000000);
    });

    test('scrim', () {
      expect(Palette.scrim.toARGB32(), 0xFF000000);
    });

    test('inverseSurface', () {
      expect(Palette.inverseSurface.toARGB32(), 0xFFE8E6E3);
    });

    test('onInverseSurface', () {
      expect(Palette.onInverseSurface.toARGB32(), 0xFF1C1C22);
    });

    test('inversePrimary', () {
      expect(Palette.inversePrimary.toARGB32(), 0xFF8B5A1E);
    });

    test('surfaceTint', () {
      expect(Palette.surfaceTint.toARGB32(), 0xFFF28C38);
    });

    // -------------------------------------------------------------------------
    // Custom semantic
    // -------------------------------------------------------------------------
    test('success', () {
      expect(Palette.success.toARGB32(), 0xFF4CAF6A);
    });

    test('warning', () {
      expect(Palette.warning.toARGB32(), 0xFFF2A83A);
    });

    test('info', () {
      expect(Palette.info.toARGB32(), 0xFF5B9BD5);
    });

    test('disabled', () {
      expect(Palette.disabled.toARGB32(), 0xFF6B6968);
    });
  });
}
