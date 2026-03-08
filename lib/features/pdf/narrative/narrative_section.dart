import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:inspectobot/features/inspection/domain/condition_rating.dart';

export 'package:inspectobot/features/inspection/domain/condition_rating.dart';

import 'narrative_print_theme.dart';
import 'narrative_render_context.dart';

part 'narrative_section_complex.dart';

// ---------------------------------------------------------------------------
// Supporting data classes
// ---------------------------------------------------------------------------

/// A label-value pair for property information display.
class PropertyInfoField {
  const PropertyInfoField({required this.label, required this.value});

  final String label;
  final String value;
}

/// An entry in the table of contents.
class TocEntry {
  const TocEntry({required this.number, required this.title});

  final int number;
  final String title;
}

/// A row in a checklist summary table.
class ChecklistSummaryItem {
  const ChecklistSummaryItem({
    required this.label,
    required this.status,
    this.notes = '',
  });

  final String label;
  final String status;
  final String notes;
}

/// A sub-system within a condition rating section.
class ConditionRatingSubSystem {
  const ConditionRatingSubSystem({
    required this.name,
    required this.ratingKey,
    required this.findingsKey,
  });

  final String name;
  final String ratingKey;
  final String findingsKey;
}

// ---------------------------------------------------------------------------
// Sealed section hierarchy
// ---------------------------------------------------------------------------

/// Base class for all narrative report sections.
///
/// Each section knows how to render itself into a list of [pw.Widget]s
/// that can be consumed by a [pw.MultiPage] build callback.
sealed class NarrativeSection {
  const NarrativeSection();

  /// Renders this section into PDF widgets.
  List<pw.Widget> render({
    required NarrativePrintTheme theme,
    required NarrativeRenderContext context,
  });
}

// ---------------------------------------------------------------------------
// Simple sections
// ---------------------------------------------------------------------------

/// Report header with title, subtitle, form label, and optional accent bar.
class HeaderSection extends NarrativeSection {
  const HeaderSection({
    required this.title,
    this.subtitle,
    this.formLabel,
    this.logoBytes,
  });

  final String title;
  final String? subtitle;
  final String? formLabel;
  final Uint8List? logoBytes;

  @override
  List<pw.Widget> render({
    required NarrativePrintTheme theme,
    required NarrativeRenderContext context,
  }) {
    final widgets = <pw.Widget>[];

    // Accent bar at the top
    widgets.add(
      pw.Container(
        height: 4,
        color: theme.accentPrimary,
        margin: const pw.EdgeInsets.only(bottom: 12),
      ),
    );

    // Logo + title row
    final titleWidget = pw.Text(title, style: theme.titleStyle);

    if (logoBytes != null) {
      widgets.add(
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(child: titleWidget),
            pw.Image(pw.MemoryImage(logoBytes!), width: 80, height: 40),
          ],
        ),
      );
    } else {
      widgets.add(titleWidget);
    }

    if (subtitle != null) {
      widgets.add(pw.SizedBox(height: 4));
      widgets.add(pw.Text(subtitle!, style: theme.heading2Style));
    }

    if (formLabel != null) {
      widgets.add(pw.SizedBox(height: 2));
      widgets.add(
        pw.Text(formLabel!, style: theme.captionStyle),
      );
    }

    widgets.add(pw.SizedBox(height: theme.sectionSpacing));

    return widgets;
  }
}

/// Two-column key-value grid of property information fields.
class PropertyInfoSection extends NarrativeSection {
  const PropertyInfoSection({required this.fields});

  final List<PropertyInfoField> fields;

  @override
  List<pw.Widget> render({
    required NarrativePrintTheme theme,
    required NarrativeRenderContext context,
  }) {
    if (fields.isEmpty) {
      return [];
    }

    final rows = <pw.TableRow>[];
    for (final field in fields) {
      rows.add(
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                vertical: 3,
                horizontal: 4,
              ),
              child: pw.Text(field.label, style: theme.heading3Style),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                vertical: 3,
                horizontal: 4,
              ),
              child: pw.Text(field.value, style: theme.bodyStyle),
            ),
          ],
        ),
      );
    }

    return [
      pw.Table(
        border: pw.TableBorder.all(color: theme.tableBorder, width: 0.5),
        columnWidths: const {
          0: pw.FlexColumnWidth(2),
          1: pw.FlexColumnWidth(3),
        },
        children: rows,
      ),
      pw.SizedBox(height: theme.sectionSpacing),
    ];
  }
}

/// A narrative text paragraph with a heading.
///
/// Looks up [bodyKey] in the render context's form data. Falls back to
/// [fallbackBody] if the key is missing or empty.
class NarrativeParagraphSection extends NarrativeSection {
  const NarrativeParagraphSection({
    required this.heading,
    required this.bodyKey,
    this.headingLevel = 2,
    this.fallbackBody,
  });

  final String heading;
  final String bodyKey;
  final int headingLevel;
  final String? fallbackBody;

  @override
  List<pw.Widget> render({
    required NarrativePrintTheme theme,
    required NarrativeRenderContext context,
  }) {
    final headingStyle = switch (headingLevel) {
      1 => theme.heading1Style,
      3 => theme.heading3Style,
      _ => theme.heading2Style,
    };

    final bodyText = _resolveBody(context);

    return [
      pw.Text(heading, style: headingStyle),
      pw.SizedBox(height: theme.paragraphSpacing),
      pw.Text(bodyText, style: theme.bodyStyle),
      pw.SizedBox(height: theme.sectionSpacing),
    ];
  }

  String _resolveBody(NarrativeRenderContext context) {
    final value = context.formData[bodyKey];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return fallbackBody ?? '';
  }
}

/// Forces a page break in the PDF output.
class PageBreakSection extends NarrativeSection {
  const PageBreakSection();

  @override
  List<pw.Widget> render({
    required NarrativePrintTheme theme,
    required NarrativeRenderContext context,
  }) {
    return [pw.NewPage()];
  }
}

/// Legal disclaimer text rendered in a muted, small style.
class DisclaimerSection extends NarrativeSection {
  const DisclaimerSection({
    required this.heading,
    required this.paragraphs,
  });

  final String heading;
  final List<String> paragraphs;

  @override
  List<pw.Widget> render({
    required NarrativePrintTheme theme,
    required NarrativeRenderContext context,
  }) {
    final widgets = <pw.Widget>[
      pw.Divider(color: theme.divider, thickness: 0.5),
      pw.SizedBox(height: theme.paragraphSpacing),
      pw.Text(heading, style: theme.heading3Style),
      pw.SizedBox(height: theme.paragraphSpacing / 2),
    ];

    for (final paragraph in paragraphs) {
      widgets.add(pw.Text(paragraph, style: theme.disclaimerStyle));
      widgets.add(pw.SizedBox(height: theme.paragraphSpacing / 2));
    }

    widgets.add(pw.SizedBox(height: theme.sectionSpacing));

    return widgets;
  }
}

/// Numbered list of section titles for navigation.
class TableOfContentsSection extends NarrativeSection {
  const TableOfContentsSection({required this.entries});

  final List<TocEntry> entries;

  @override
  List<pw.Widget> render({
    required NarrativePrintTheme theme,
    required NarrativeRenderContext context,
  }) {
    if (entries.isEmpty) {
      return [];
    }

    final widgets = <pw.Widget>[
      pw.Text('Table of Contents', style: theme.heading1Style),
      pw.SizedBox(height: theme.paragraphSpacing),
    ];

    for (final entry in entries) {
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Text(
            '${entry.number}. ${entry.title}',
            style: theme.bodyStyle,
          ),
        ),
      );
    }

    widgets.add(pw.SizedBox(height: theme.sectionSpacing));

    return widgets;
  }
}
