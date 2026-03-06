import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inspectobot/theme/extensions.dart';
import 'package:inspectobot/theme/palette.dart';
import 'package:inspectobot/theme/tokens.dart';

void main() {
  late AppTokens tokens;

  setUp(() {
    tokens = AppTokens.dark();
  });

  group('AppTokens.dark() produces non-null values', () {
    test('spacing values are non-null and positive', () {
      expect(tokens.spacingXxs, isNotNull);
      expect(tokens.spacingXs, isNotNull);
      expect(tokens.spacingSm, isNotNull);
      expect(tokens.spacingMd, isNotNull);
      expect(tokens.spacingLg, isNotNull);
      expect(tokens.spacingXl, isNotNull);
      expect(tokens.spacingXxl, isNotNull);
      expect(tokens.spacing3xl, isNotNull);
      expect(tokens.spacing4xl, isNotNull);
    });

    test('edge insets are non-null', () {
      expect(tokens.pagePadding, isNotNull);
      expect(tokens.cardPadding, isNotNull);
      expect(tokens.sectionGap, isNotNull);
      expect(tokens.inputPadding, isNotNull);
    });

    test('border radii are non-null', () {
      expect(tokens.radiusNone, isNotNull);
      expect(tokens.radiusXs, isNotNull);
      expect(tokens.radiusSm, isNotNull);
      expect(tokens.radiusMd, isNotNull);
      expect(tokens.radiusLg, isNotNull);
      expect(tokens.radiusFull, isNotNull);
    });

    test('elevation values are non-null', () {
      expect(tokens.elevation0, isNotNull);
      expect(tokens.elevation1, isNotNull);
      expect(tokens.elevation2, isNotNull);
      expect(tokens.elevation3, isNotNull);
      expect(tokens.elevation4, isNotNull);
      expect(tokens.elevation5, isNotNull);
    });

    test('semantic colors are non-null', () {
      expect(tokens.success, isNotNull);
      expect(tokens.warning, isNotNull);
      expect(tokens.info, isNotNull);
      expect(tokens.disabled, isNotNull);
    });

    test('typography helpers are non-null', () {
      expect(tokens.sectionHeader, isNotNull);
      expect(tokens.fieldLabel, isNotNull);
      expect(tokens.statusBadge, isNotNull);
      expect(tokens.timestamp, isNotNull);
    });
  });

  group('Semantic colors match Palette', () {
    test('success matches Palette.success', () {
      expect(tokens.success, equals(Palette.success));
    });

    test('warning matches Palette.warning', () {
      expect(tokens.warning, equals(Palette.warning));
    });

    test('info matches Palette.info', () {
      expect(tokens.info, equals(Palette.info));
    });

    test('disabled matches Palette.disabled', () {
      expect(tokens.disabled, equals(Palette.disabled));
    });
  });

  group('Spacing values match AppSpacing constants', () {
    test('spacingXxs', () {
      expect(tokens.spacingXxs, equals(AppSpacing.spacingXxs));
    });

    test('spacingXs', () {
      expect(tokens.spacingXs, equals(AppSpacing.spacingXs));
    });

    test('spacingSm', () {
      expect(tokens.spacingSm, equals(AppSpacing.spacingSm));
    });

    test('spacingMd', () {
      expect(tokens.spacingMd, equals(AppSpacing.spacingMd));
    });

    test('spacingLg', () {
      expect(tokens.spacingLg, equals(AppSpacing.spacingLg));
    });

    test('spacingXl', () {
      expect(tokens.spacingXl, equals(AppSpacing.spacingXl));
    });

    test('spacingXxl', () {
      expect(tokens.spacingXxl, equals(AppSpacing.spacingXxl));
    });

    test('spacing3xl', () {
      expect(tokens.spacing3xl, equals(AppSpacing.spacing3xl));
    });

    test('spacing4xl', () {
      expect(tokens.spacing4xl, equals(AppSpacing.spacing4xl));
    });
  });

  group('Border radii match AppRadii constants', () {
    test('radiusNone', () {
      expect(tokens.radiusNone, equals(AppRadii.none));
    });

    test('radiusXs', () {
      expect(tokens.radiusXs, equals(AppRadii.xs));
    });

    test('radiusSm', () {
      expect(tokens.radiusSm, equals(AppRadii.sm));
    });

    test('radiusMd', () {
      expect(tokens.radiusMd, equals(AppRadii.md));
    });

    test('radiusLg', () {
      expect(tokens.radiusLg, equals(AppRadii.lg));
    });

    test('radiusFull', () {
      expect(tokens.radiusFull, equals(AppRadii.full));
    });
  });

  group('copyWith', () {
    test('overrides a color field', () {
      const newColor = Color(0xFF112233);
      final modified = tokens.copyWith(success: newColor);
      expect(modified.success, equals(newColor));
    });

    test('overrides a spacing value', () {
      final modified = tokens.copyWith(spacingMd: 99.0);
      expect(modified.spacingMd, equals(99.0));
    });

    test('preserves non-overridden fields when overriding color', () {
      const newColor = Color(0xFF112233);
      final modified = tokens.copyWith(success: newColor);
      // All other fields should remain unchanged.
      expect(modified.warning, equals(tokens.warning));
      expect(modified.info, equals(tokens.info));
      expect(modified.disabled, equals(tokens.disabled));
      expect(modified.spacingXxs, equals(tokens.spacingXxs));
      expect(modified.spacingLg, equals(tokens.spacingLg));
      expect(modified.pagePadding, equals(tokens.pagePadding));
      expect(modified.radiusMd, equals(tokens.radiusMd));
      expect(modified.elevation1, equals(tokens.elevation1));
      expect(modified.sectionHeader, equals(tokens.sectionHeader));
    });

    test('preserves non-overridden fields when overriding spacing', () {
      final modified = tokens.copyWith(spacingMd: 99.0);
      expect(modified.spacingXxs, equals(tokens.spacingXxs));
      expect(modified.spacingLg, equals(tokens.spacingLg));
      expect(modified.success, equals(tokens.success));
    });
  });

  group('lerp', () {
    late AppTokens start;
    late AppTokens end;

    setUp(() {
      start = AppTokens.dark();
      end = start.copyWith(
        success: const Color(0xFFFFFFFF),
        spacingMd: 100.0,
        elevation1: 50.0,
        pagePadding: const EdgeInsets.all(32.0),
        radiusMd: BorderRadius.circular(20.0),
      );
    });

    test('t=0 returns start values', () {
      final result = start.lerp(end, 0.0);
      expect(result.success, equals(start.success));
      expect(result.spacingMd, equals(start.spacingMd));
      expect(result.elevation1, equals(start.elevation1));
      expect(result.pagePadding, equals(start.pagePadding));
      expect(result.radiusMd, equals(start.radiusMd));
    });

    test('t=1 returns end values', () {
      final result = start.lerp(end, 1.0);
      expect(result.success, equals(end.success));
      expect(result.spacingMd, equals(end.spacingMd));
      expect(result.elevation1, equals(end.elevation1));
      expect(result.pagePadding, equals(end.pagePadding));
      expect(result.radiusMd, equals(end.radiusMd));
    });

    test('t=0.5 returns intermediate values', () {
      final result = start.lerp(end, 0.5);
      // Spacing: (12 + 100) / 2 = 56
      expect(result.spacingMd, closeTo(56.0, 0.01));
      // Elevation: (1 + 50) / 2 = 25.5
      expect(result.elevation1, closeTo(25.5, 0.01));
      // EdgeInsets: (16 + 32) / 2 = 24
      expect(result.pagePadding.left, closeTo(24.0, 0.01));
      // BorderRadius: (8 + 20) / 2 = 14
      expect(
        (result.radiusMd.topLeft).x,
        closeTo(14.0, 0.01),
      );
    });

    test('lerp with null returns this', () {
      final result = start.lerp(null, 0.5);
      expect(result.success, equals(start.success));
      expect(result.spacingMd, equals(start.spacingMd));
    });
  });
}
