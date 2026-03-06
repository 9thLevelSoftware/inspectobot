import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/theme/palette.dart';
import 'package:inspectobot/theme/typography.dart';

void main() {
  group('AppTypography.textTheme', () {
    final theme = AppTypography.textTheme;

    test('all 15 type roles are non-null', () {
      expect(theme.displayLarge, isNotNull);
      expect(theme.displayMedium, isNotNull);
      expect(theme.displaySmall, isNotNull);
      expect(theme.headlineLarge, isNotNull);
      expect(theme.headlineMedium, isNotNull);
      expect(theme.headlineSmall, isNotNull);
      expect(theme.titleLarge, isNotNull);
      expect(theme.titleMedium, isNotNull);
      expect(theme.titleSmall, isNotNull);
      expect(theme.bodyLarge, isNotNull);
      expect(theme.bodyMedium, isNotNull);
      expect(theme.bodySmall, isNotNull);
      expect(theme.labelLarge, isNotNull);
      expect(theme.labelMedium, isNotNull);
      expect(theme.labelSmall, isNotNull);
    });

    test('bodyMedium fontSize >= 14 for field readability', () {
      expect(theme.bodyMedium!.fontSize, greaterThanOrEqualTo(14));
    });

    test('headlineLarge and headlineMedium use FontWeight.w700', () {
      expect(theme.headlineLarge!.fontWeight, equals(FontWeight.w700));
      expect(theme.headlineMedium!.fontWeight, equals(FontWeight.w700));
    });

    test('headlineSmall uses FontWeight.w600 per spec', () {
      expect(theme.headlineSmall!.fontWeight, equals(FontWeight.w600));
    });

    test('no TextStyle has a null fontSize', () {
      final roles = <TextStyle?>[
        theme.displayLarge,
        theme.displayMedium,
        theme.displaySmall,
        theme.headlineLarge,
        theme.headlineMedium,
        theme.headlineSmall,
        theme.titleLarge,
        theme.titleMedium,
        theme.titleSmall,
        theme.bodyLarge,
        theme.bodyMedium,
        theme.bodySmall,
        theme.labelLarge,
        theme.labelMedium,
        theme.labelSmall,
      ];
      for (final style in roles) {
        expect(style!.fontSize, isNotNull, reason: '$style has null fontSize');
      }
    });
  });

  group('AppTypography helper constants', () {
    test('sectionHeader has w700 weight and onSurface color', () {
      final style = AppTypography.sectionHeader;
      expect(style.fontWeight, equals(FontWeight.w700));
      expect(style.fontSize, equals(16));
      expect(style.color, equals(Palette.onSurface));
    });

    test('fieldLabel has onSurfaceVariant color and bodyMedium size', () {
      final style = AppTypography.fieldLabel;
      expect(style.color, equals(Palette.onSurfaceVariant));
      expect(style.fontSize, equals(14));
      expect(style.fontWeight, equals(FontWeight.w400));
    });

    test('statusBadge has w600 weight and labelMedium size', () {
      final style = AppTypography.statusBadge;
      expect(style.fontWeight, equals(FontWeight.w600));
      expect(style.fontSize, equals(12));
    });

    test('timestamp has onSurfaceVariant color and bodySmall size', () {
      final style = AppTypography.timestamp;
      expect(style.color, equals(Palette.onSurfaceVariant));
      expect(style.fontSize, equals(12));
      expect(style.fontWeight, equals(FontWeight.w400));
    });
  });
}
