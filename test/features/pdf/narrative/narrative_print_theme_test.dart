import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_print_theme.dart';

void main() {
  group('NarrativePrintTheme.standard()', () {
    late NarrativePrintTheme theme;

    setUp(() {
      theme = NarrativePrintTheme.standard();
    });

    test('creates a valid instance', () {
      expect(theme, isNotNull);
      expect(theme.pageFormat, PdfPageFormat.letter);
    });

    test('all PdfColor values are non-null', () {
      // Dart non-nullable types guarantee this at compile time,
      // but we verify the factory actually sets meaningful values.
      final colors = [
        theme.textPrimary,
        theme.textSecondary,
        theme.textMuted,
        theme.accentPrimary,
        theme.accentSecondary,
        theme.ratingGood,
        theme.ratingCaution,
        theme.ratingDeficient,
        theme.ratingNA,
        theme.divider,
        theme.tableBorder,
        theme.tableHeaderBackground,
        theme.photoPlaceholderBackground,
      ];

      for (final color in colors) {
        expect(color, isNotNull);
        // Verify they are actual colors with some channel data
        expect(color.toInt(), isNonZero);
      }
    });

    test('all TextStyle font sizes are positive', () {
      final styles = [
        ('titleStyle', theme.titleStyle),
        ('heading1Style', theme.heading1Style),
        ('heading2Style', theme.heading2Style),
        ('heading3Style', theme.heading3Style),
        ('bodyStyle', theme.bodyStyle),
        ('captionStyle', theme.captionStyle),
        ('badgeStyle', theme.badgeStyle),
        ('disclaimerStyle', theme.disclaimerStyle),
        ('footerStyle', theme.footerStyle),
      ];

      for (final (name, style) in styles) {
        expect(
          style.fontSize,
          isNotNull,
          reason: '$name fontSize should not be null',
        );
        expect(
          style.fontSize! > 0,
          isTrue,
          reason: '$name fontSize should be positive, got ${style.fontSize}',
        );
      }
    });

    test('spacing values are positive', () {
      expect(theme.sectionSpacing, greaterThan(0));
      expect(theme.paragraphSpacing, greaterThan(0));
      expect(theme.photoGridSpacing, greaterThan(0));
    });

    test('photoAspectRatio is positive', () {
      expect(theme.photoAspectRatio, greaterThan(0));
    });

    test('photo dimensions are positive', () {
      expect(theme.photoMaxWidth, greaterThan(0));
      expect(theme.photoMaxHeight, greaterThan(0));
    });

    test('title fontSize is largest, footer is smallest', () {
      expect(theme.titleStyle.fontSize!, greaterThan(theme.heading1Style.fontSize!));
      expect(theme.heading1Style.fontSize!, greaterThan(theme.heading2Style.fontSize!));
      expect(theme.heading2Style.fontSize!, greaterThan(theme.bodyStyle.fontSize!));
      expect(theme.bodyStyle.fontSize!, greaterThan(theme.footerStyle.fontSize!));
    });
  });
}
