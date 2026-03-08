/// PDF package API reference (pdf ^3.11.3, verified against source):
///
/// - [pw.MultiPage] accepts: `header` and `footer` (both `BuildCallback?`,
///   i.e. `Widget Function(Context context)`), and `build` (`BuildListCallback`,
///   i.e. `List<Widget> Function(Context context)`). Also accepts `pageFormat`,
///   `margin`, `theme`, `mainAxisAlignment`, `crossAxisAlignment`, `maxPages`.
///
/// - [pw.TextStyle] accepts `fontWeight` (`FontWeight.normal` | `FontWeight.bold`)
///   and `fontStyle` (`FontStyle.normal` | `FontStyle.italic`). Both are enums
///   defined in `package:pdf/widgets.dart`.
///
/// - Page breaks: Use `pw.NewPage()` widget. Constructor accepts optional
///   `freeSpace` (double?) -- if null, always breaks; if set, breaks only when
///   remaining space is less than the value.
///
/// - Standard font factories on `pw.Font`:
///   `helvetica()`, `helveticaBold()`, `helveticaOblique()`,
///   `helveticaBoldOblique()`, `times()`, `timesBold()`, `timesItalic()`,
///   `timesBoldItalic()`, `courier()`, `courierBold()`, etc.
///   All are factory constructors returning `Font.type1(Type1Fonts.xxx)`.
library;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Print-safe theme for narrative PDF reports.
///
/// All colors are chosen for high contrast on white paper. Uses only standard
/// PDF Type 1 fonts (Helvetica, Times) to avoid font embedding.
class NarrativePrintTheme {
  const NarrativePrintTheme({
    // Page layout
    required this.pageFormat,
    required this.pageMargin,
    // Colors
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accentPrimary,
    required this.accentSecondary,
    required this.ratingGood,
    required this.ratingCaution,
    required this.ratingDeficient,
    required this.ratingNA,
    required this.divider,
    required this.tableBorder,
    required this.tableHeaderBackground,
    required this.photoPlaceholderBackground,
    // Typography
    required this.titleStyle,
    required this.heading1Style,
    required this.heading2Style,
    required this.heading3Style,
    required this.bodyStyle,
    required this.captionStyle,
    required this.badgeStyle,
    required this.disclaimerStyle,
    required this.footerStyle,
    // Spacing
    required this.sectionSpacing,
    required this.paragraphSpacing,
    required this.photoGridSpacing,
    required this.photoAspectRatio,
    // Photo sizing
    required this.photoMaxWidth,
    required this.photoMaxHeight,
  });

  // ---------------------------------------------------------------------------
  // Page layout
  // ---------------------------------------------------------------------------

  /// Page size -- US Letter (8.5 x 11 in).
  final PdfPageFormat pageFormat;

  /// Page margins applied to all sides.
  final pw.EdgeInsets pageMargin;

  // ---------------------------------------------------------------------------
  // Colors (print-safe, high-contrast on white)
  // ---------------------------------------------------------------------------

  final PdfColor textPrimary;
  final PdfColor textSecondary;
  final PdfColor textMuted;
  final PdfColor accentPrimary;
  final PdfColor accentSecondary;
  final PdfColor ratingGood;
  final PdfColor ratingCaution;
  final PdfColor ratingDeficient;
  final PdfColor ratingNA;
  final PdfColor divider;
  final PdfColor tableBorder;
  final PdfColor tableHeaderBackground;
  final PdfColor photoPlaceholderBackground;

  // ---------------------------------------------------------------------------
  // Typography (standard PDF fonts only)
  // ---------------------------------------------------------------------------

  final pw.TextStyle titleStyle;
  final pw.TextStyle heading1Style;
  final pw.TextStyle heading2Style;
  final pw.TextStyle heading3Style;
  final pw.TextStyle bodyStyle;
  final pw.TextStyle captionStyle;
  final pw.TextStyle badgeStyle;
  final pw.TextStyle disclaimerStyle;
  final pw.TextStyle footerStyle;

  // ---------------------------------------------------------------------------
  // Spacing
  // ---------------------------------------------------------------------------

  /// Vertical space between major sections.
  final double sectionSpacing;

  /// Vertical space between paragraphs within a section.
  final double paragraphSpacing;

  /// Gap between photos in a grid layout.
  final double photoGridSpacing;

  /// Width-to-height ratio for photo containers.
  final double photoAspectRatio;

  // ---------------------------------------------------------------------------
  // Photo sizing
  // ---------------------------------------------------------------------------

  /// Maximum width for an embedded photo in points.
  final double photoMaxWidth;

  /// Maximum height for an embedded photo in points.
  final double photoMaxHeight;

  // ---------------------------------------------------------------------------
  // Standard factory
  // ---------------------------------------------------------------------------

  /// Creates a print-safe theme with colors derived from the app's Palette
  /// but adjusted for legibility on white paper.
  ///
  /// Color mappings from app dark theme to print-safe equivalents:
  /// - Palette.primary (#F28C38) -> darker orange (#C06A1A) for paper contrast
  /// - Palette.secondary (#F2C744) -> darker amber (#B8941A) for paper contrast
  /// - Palette.success (#4CAF6A) -> kept as-is (good contrast on white)
  /// - Palette.warning (#F2A83A) -> darker (#C08520) for paper contrast
  /// - Palette.error (#F2564B) -> kept as-is (good contrast on white)
  factory NarrativePrintTheme.standard() {
    // Print-safe colors (high contrast on white paper)
    const textPrimary = PdfColor.fromInt(0xFF1A1A1A);
    const textSecondary = PdfColor.fromInt(0xFF4A4A4A);
    const textMuted = PdfColor.fromInt(0xFF7A7A7A);
    const accentPrimary = PdfColor.fromInt(0xFFC06A1A); // Palette.primary print-safe
    const accentSecondary = PdfColor.fromInt(0xFFB8941A); // Palette.secondary print-safe
    const ratingGood = PdfColor.fromInt(0xFF4CAF6A); // Palette.success
    const ratingCaution = PdfColor.fromInt(0xFFC08520); // Palette.warning print-safe
    const ratingDeficient = PdfColor.fromInt(0xFFF2564B); // Palette.error
    const ratingNA = PdfColor.fromInt(0xFF9E9E9E);
    const divider = PdfColor.fromInt(0xFFCCCCCC);
    const tableBorder = PdfColor.fromInt(0xFFBBBBBB);
    const tableHeaderBg = PdfColor.fromInt(0xFFF0F0F0);
    const photoPlaceholderBg = PdfColor.fromInt(0xFFE8E8E8);

    // Standard fonts
    final helvetica = pw.Font.helvetica();
    final helveticaBold = pw.Font.helveticaBold();
    final times = pw.Font.times();
    final timesItalic = pw.Font.timesItalic();

    return NarrativePrintTheme(
      // Page
      pageFormat: PdfPageFormat.letter,
      pageMargin: const pw.EdgeInsets.symmetric(
        horizontal: 54, // 0.75 inch
        vertical: 54,
      ),

      // Colors
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      textMuted: textMuted,
      accentPrimary: accentPrimary,
      accentSecondary: accentSecondary,
      ratingGood: ratingGood,
      ratingCaution: ratingCaution,
      ratingDeficient: ratingDeficient,
      ratingNA: ratingNA,
      divider: divider,
      tableBorder: tableBorder,
      tableHeaderBackground: tableHeaderBg,
      photoPlaceholderBackground: photoPlaceholderBg,

      // Typography
      titleStyle: pw.TextStyle(
        font: helveticaBold,
        fontSize: 22,
        color: textPrimary,
        fontWeight: pw.FontWeight.bold,
      ),
      heading1Style: pw.TextStyle(
        font: helveticaBold,
        fontSize: 16,
        color: textPrimary,
        fontWeight: pw.FontWeight.bold,
      ),
      heading2Style: pw.TextStyle(
        font: helveticaBold,
        fontSize: 13,
        color: textPrimary,
        fontWeight: pw.FontWeight.bold,
      ),
      heading3Style: pw.TextStyle(
        font: helveticaBold,
        fontSize: 11,
        color: textSecondary,
        fontWeight: pw.FontWeight.bold,
      ),
      bodyStyle: pw.TextStyle(
        font: times,
        fontSize: 10,
        color: textPrimary,
        lineSpacing: 2,
      ),
      captionStyle: pw.TextStyle(
        font: timesItalic,
        fontSize: 8,
        color: textSecondary,
        fontStyle: pw.FontStyle.italic,
      ),
      badgeStyle: pw.TextStyle(
        font: helveticaBold,
        fontSize: 8,
        color: PdfColor.fromInt(0xFFFFFFFF),
        fontWeight: pw.FontWeight.bold,
      ),
      disclaimerStyle: pw.TextStyle(
        font: times,
        fontSize: 7,
        color: textMuted,
        fontStyle: pw.FontStyle.normal,
      ),
      footerStyle: pw.TextStyle(
        font: helvetica,
        fontSize: 7,
        color: textMuted,
      ),

      // Spacing
      sectionSpacing: 24,
      paragraphSpacing: 8,
      photoGridSpacing: 8,
      photoAspectRatio: 4 / 3,

      // Photo sizing
      photoMaxWidth: 240,
      photoMaxHeight: 180,
    );
  }
}
