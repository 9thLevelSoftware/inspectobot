import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/theme/palette.dart';
import 'package:inspectobot/theme/typography.dart';

void main() {
  group('Typography hierarchy', () {
    // -------------------------------------------------------------------------
    // Semantic styles have strictly decreasing font sizes
    // -------------------------------------------------------------------------
    test('semantic styles have strictly decreasing font sizes '
        '(24 > 18 > 16 > 14 > 12)', () {
      final sizes = [
        AppTypography.sectionTitle.fontSize!, // 24
        AppTypography.subsectionTitle.fontSize!, // 18
        AppTypography.fieldValue.fontSize!, // 16
        AppTypography.fieldLabelRequired.fontSize!, // 14
        AppTypography.statusBadge.fontSize!, // 12
      ];

      expect(sizes, equals([24, 18, 16, 14, 12]));

      // Verify strict decreasing order
      for (var i = 0; i < sizes.length - 1; i++) {
        expect(
          sizes[i],
          greaterThan(sizes[i + 1]),
          reason: 'Size at index $i (${sizes[i]}) must be > '
              'size at index ${i + 1} (${sizes[i + 1]})',
        );
      }
    });

    // -------------------------------------------------------------------------
    // At least 4 distinct font sizes in semantic styles
    // -------------------------------------------------------------------------
    test('at least 4 distinct font sizes in semantic styles', () {
      final distinctSizes = {
        AppTypography.sectionTitle.fontSize,
        AppTypography.subsectionTitle.fontSize,
        AppTypography.fieldValue.fontSize,
        AppTypography.fieldLabelRequired.fontSize,
        AppTypography.statusBadge.fontSize,
        AppTypography.sectionHeader.fontSize,
        AppTypography.fieldLabel.fontSize,
        AppTypography.timestamp.fontSize,
      };

      expect(
        distinctSizes.length,
        greaterThanOrEqualTo(4),
        reason: 'Must have at least 4 distinct font sizes, '
            'found ${distinctSizes.length}: $distinctSizes',
      );
    });

    // -------------------------------------------------------------------------
    // All semantic styles have minimum 11sp for outdoor legibility
    // -------------------------------------------------------------------------
    test('all semantic styles have minimum 11sp for outdoor legibility', () {
      const minLegibleSize = 11.0;
      final styles = <String, TextStyle>{
        'sectionTitle': AppTypography.sectionTitle,
        'subsectionTitle': AppTypography.subsectionTitle,
        'sectionHeader': AppTypography.sectionHeader,
        'fieldValue': AppTypography.fieldValue,
        'fieldLabel': AppTypography.fieldLabel,
        'fieldLabelRequired': AppTypography.fieldLabelRequired,
        'statusBadge': AppTypography.statusBadge,
        'timestamp': AppTypography.timestamp,
      };

      for (final entry in styles.entries) {
        expect(
          entry.value.fontSize,
          greaterThanOrEqualTo(minLegibleSize),
          reason: '${entry.key} fontSize ${entry.value.fontSize}sp '
              'must be >= ${minLegibleSize}sp',
        );
      }
    });

    // -------------------------------------------------------------------------
    // All textTheme styles also have minimum 11sp
    // -------------------------------------------------------------------------
    test('all textTheme styles have minimum 11sp', () {
      const minLegibleSize = 11.0;
      final tt = AppTypography.textTheme;
      final styles = <String, TextStyle?>{
        'displayLarge': tt.displayLarge,
        'displayMedium': tt.displayMedium,
        'displaySmall': tt.displaySmall,
        'headlineLarge': tt.headlineLarge,
        'headlineMedium': tt.headlineMedium,
        'headlineSmall': tt.headlineSmall,
        'titleLarge': tt.titleLarge,
        'titleMedium': tt.titleMedium,
        'titleSmall': tt.titleSmall,
        'bodyLarge': tt.bodyLarge,
        'bodyMedium': tt.bodyMedium,
        'bodySmall': tt.bodySmall,
        'labelLarge': tt.labelLarge,
        'labelMedium': tt.labelMedium,
        'labelSmall': tt.labelSmall,
      };

      for (final entry in styles.entries) {
        expect(
          entry.value?.fontSize,
          greaterThanOrEqualTo(minLegibleSize),
          reason: 'textTheme.${entry.key} fontSize '
              '${entry.value?.fontSize}sp must be >= ${minLegibleSize}sp',
        );
      }
    });

    // -------------------------------------------------------------------------
    // sectionTitle has w700 weight
    // -------------------------------------------------------------------------
    test('sectionTitle has w700 (bold) weight', () {
      expect(AppTypography.sectionTitle.fontWeight, FontWeight.w700);
    });

    // -------------------------------------------------------------------------
    // fieldLabelRequired uses Palette.primary color
    // -------------------------------------------------------------------------
    test('fieldLabelRequired uses Palette.primary color', () {
      expect(AppTypography.fieldLabelRequired.color, Palette.primary);
    });

    // -------------------------------------------------------------------------
    // fieldLabelRequired uses w700 for WCAG "large text" qualification
    // -------------------------------------------------------------------------
    test('fieldLabelRequired uses w700 to qualify as WCAG large text', () {
      expect(AppTypography.fieldLabelRequired.fontWeight, FontWeight.w700);
      expect(AppTypography.fieldLabelRequired.fontSize, 14.0);
    });
  });
}
