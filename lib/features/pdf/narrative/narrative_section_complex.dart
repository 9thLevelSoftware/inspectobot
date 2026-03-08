part of 'narrative_section.dart';

// ---------------------------------------------------------------------------
// Complex section types
// ---------------------------------------------------------------------------

/// Renders a grid of photos with optional category labels and captions.
class PhotoGridSection extends NarrativeSection {
  const PhotoGridSection({
    required this.heading,
    required this.photoKeys,
    this.columns = 2,
    this.captionKeys,
    this.categoryLabels,
  });

  final String heading;
  final List<String> photoKeys;
  final int columns;

  /// Maps photoKey -> formData key for caption text.
  final Map<String, String>? captionKeys;

  /// Maps photoKey -> display label for the category badge.
  final Map<String, String>? categoryLabels;

  @override
  List<pw.Widget> render({
    required NarrativePrintTheme theme,
    required NarrativeRenderContext context,
  }) {
    if (photoKeys.isEmpty) {
      return [];
    }

    final widgets = <pw.Widget>[
      pw.Text(heading, style: theme.heading2Style),
      pw.SizedBox(height: theme.paragraphSpacing),
    ];

    final cells = <pw.Widget>[];
    for (final key in photoKeys) {
      cells.add(_buildPhotoCell(key, theme, context));
    }

    // Build rows of `columns` cells each
    final rows = <pw.TableRow>[];
    for (var i = 0; i < cells.length; i += columns) {
      final rowCells = <pw.Widget>[];
      for (var j = 0; j < columns; j++) {
        if (i + j < cells.length) {
          rowCells.add(
            pw.Padding(
              padding: pw.EdgeInsets.all(theme.photoGridSpacing / 2),
              child: cells[i + j],
            ),
          );
        } else {
          // Empty cell to fill the row
          rowCells.add(pw.SizedBox());
        }
      }
      rows.add(pw.TableRow(children: rowCells));
    }

    final columnWidths = <int, pw.TableColumnWidth>{};
    for (var i = 0; i < columns; i++) {
      columnWidths[i] = const pw.FlexColumnWidth(1);
    }

    widgets.add(
      pw.Table(
        columnWidths: columnWidths,
        children: rows,
      ),
    );

    widgets.add(pw.SizedBox(height: theme.sectionSpacing));

    return widgets;
  }

  pw.Widget _buildPhotoCell(
    String photoKey,
    NarrativePrintTheme theme,
    NarrativeRenderContext context,
  ) {
    final photos = context.resolvedPhotos[photoKey];
    final photo = (photos != null && photos.isNotEmpty) ? photos.first : null;

    final cellChildren = <pw.Widget>[];

    // Category label badge
    final categoryLabel = categoryLabels?[photoKey];
    if (categoryLabel != null) {
      cellChildren.add(
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          margin: const pw.EdgeInsets.only(bottom: 2),
          decoration: pw.BoxDecoration(
            color: theme.accentSecondary,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
          ),
          child: pw.Text(categoryLabel, style: theme.badgeStyle),
        ),
      );
    }

    // Photo or placeholder
    if (photo != null && photo.isResolved) {
      cellChildren.add(
        pw.Image(
          pw.MemoryImage(photo.bytes!),
          width: theme.photoMaxWidth,
          height: theme.photoMaxHeight,
          fit: pw.BoxFit.contain,
        ),
      );
    } else {
      cellChildren.add(
        pw.Container(
          width: theme.photoMaxWidth,
          height: theme.photoMaxHeight,
          decoration: pw.BoxDecoration(
            color: theme.photoPlaceholderBackground,
            border: pw.Border.all(color: theme.divider, width: 0.5),
          ),
          alignment: pw.Alignment.center,
          child: pw.Text(
            'Photo unavailable',
            style: theme.captionStyle,
          ),
        ),
      );
    }

    // Caption
    final captionKey = captionKeys?[photoKey];
    if (captionKey != null) {
      final captionText = context.formData[captionKey];
      if (captionText is String && captionText.isNotEmpty) {
        cellChildren.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 2),
            child: pw.Text(captionText, style: theme.captionStyle),
          ),
        );
      }
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: cellChildren,
    );
  }
}

/// Table summarizing checklist items with status and notes columns.
class ChecklistSummarySection extends NarrativeSection {
  const ChecklistSummarySection({
    required this.heading,
    required this.items,
  });

  final String heading;
  final List<ChecklistSummaryItem> items;

  @override
  List<pw.Widget> render({
    required NarrativePrintTheme theme,
    required NarrativeRenderContext context,
  }) {
    if (items.isEmpty) {
      return [];
    }

    final widgets = <pw.Widget>[
      pw.Text(heading, style: theme.heading2Style),
      pw.SizedBox(height: theme.paragraphSpacing),
    ];

    // Header row
    final headerRow = pw.TableRow(
      decoration: pw.BoxDecoration(color: theme.tableHeaderBackground),
      children: [
        _headerCell('Item', theme),
        _headerCell('Status', theme),
        _headerCell('Notes', theme),
      ],
    );

    // Data rows
    final dataRows = items.map((item) {
      return pw.TableRow(
        children: [
          _dataCell(pw.Text(item.label, style: theme.bodyStyle), theme),
          _dataCell(
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 1,
              ),
              decoration: pw.BoxDecoration(
                color: _statusColor(item.status, theme),
                borderRadius:
                    const pw.BorderRadius.all(pw.Radius.circular(2)),
              ),
              child: pw.Text(item.status, style: theme.badgeStyle),
            ),
            theme,
          ),
          _dataCell(pw.Text(item.notes, style: theme.captionStyle), theme),
        ],
      );
    }).toList();

    widgets.add(
      pw.Table(
        border: pw.TableBorder.all(color: theme.tableBorder, width: 0.5),
        columnWidths: const {
          0: pw.FlexColumnWidth(3),
          1: pw.FlexColumnWidth(2),
          2: pw.FlexColumnWidth(3),
        },
        children: [headerRow, ...dataRows],
      ),
    );

    widgets.add(pw.SizedBox(height: theme.sectionSpacing));

    return widgets;
  }

  pw.Widget _headerCell(String text, NarrativePrintTheme theme) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: pw.Text(
        text,
        style: theme.heading3Style,
      ),
    );
  }

  pw.Widget _dataCell(pw.Widget child, NarrativePrintTheme theme) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 4),
      child: child,
    );
  }

  PdfColor _statusColor(String status, NarrativePrintTheme theme) {
    switch (status.trim().toLowerCase()) {
      case 'satisfactory':
      case 'good':
      case 'pass':
        return theme.ratingGood;
      case 'marginal':
      case 'fair':
      case 'caution':
        return theme.ratingCaution;
      case 'deficient':
      case 'poor':
      case 'fail':
        return theme.ratingDeficient;
      default:
        return theme.ratingNA;
    }
  }
}

/// System condition rating with color-coded badge, findings, and photos.
class ConditionRatingSection extends NarrativeSection {
  const ConditionRatingSection({
    required this.systemName,
    required this.ratingKey,
    required this.findingsKey,
    this.photoKeys = const [],
    this.subSystems,
  });

  final String systemName;
  final String ratingKey;
  final String findingsKey;
  final List<String> photoKeys;
  final List<ConditionRatingSubSystem>? subSystems;

  @override
  List<pw.Widget> render({
    required NarrativePrintTheme theme,
    required NarrativeRenderContext context,
  }) {
    final widgets = <pw.Widget>[];

    // System heading with rating badge
    final ratingValue = context.formData[ratingKey]?.toString();
    final rating = ConditionRating.parse(ratingValue);

    widgets.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(systemName, style: theme.heading2Style),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 3,
            ),
            decoration: pw.BoxDecoration(
              color: rating.color(theme),
              borderRadius:
                  const pw.BorderRadius.all(pw.Radius.circular(3)),
            ),
            child: pw.Text(rating.displayLabel, style: theme.badgeStyle),
          ),
        ],
      ),
    );

    widgets.add(pw.SizedBox(height: theme.paragraphSpacing));

    // Findings paragraph
    final findings = context.formData[findingsKey];
    if (findings is String && findings.isNotEmpty) {
      widgets.add(pw.Text(findings, style: theme.bodyStyle));
      widgets.add(pw.SizedBox(height: theme.paragraphSpacing));
    }

    // Inline photo grid (single row)
    if (photoKeys.isNotEmpty) {
      final photoCells = <pw.Widget>[];
      for (final key in photoKeys) {
        final photos = context.resolvedPhotos[key];
        final photo =
            (photos != null && photos.isNotEmpty) ? photos.first : null;

        if (photo != null && photo.isResolved) {
          photoCells.add(
            pw.Padding(
              padding:
                  pw.EdgeInsets.only(right: theme.photoGridSpacing),
              child: pw.Image(
                pw.MemoryImage(photo.bytes!),
                width: theme.photoMaxWidth / 2,
                height: theme.photoMaxHeight / 2,
                fit: pw.BoxFit.contain,
              ),
            ),
          );
        } else {
          photoCells.add(
            pw.Padding(
              padding:
                  pw.EdgeInsets.only(right: theme.photoGridSpacing),
              child: pw.Container(
                width: theme.photoMaxWidth / 2,
                height: theme.photoMaxHeight / 2,
                decoration: pw.BoxDecoration(
                  color: theme.photoPlaceholderBackground,
                  border: pw.Border.all(color: theme.divider, width: 0.5),
                ),
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'Photo unavailable',
                  style: theme.captionStyle,
                ),
              ),
            ),
          );
        }
      }

      widgets.add(pw.Row(children: photoCells));
      widgets.add(pw.SizedBox(height: theme.paragraphSpacing));
    }

    // Sub-systems
    if (subSystems != null) {
      for (final sub in subSystems!) {
        final subRatingValue = context.formData[sub.ratingKey]?.toString();
        final subRating = ConditionRating.parse(subRatingValue);
        final subFindings = context.formData[sub.findingsKey];

        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 16),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Text(sub.name, style: theme.heading3Style),
                    pw.SizedBox(width: 8),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: pw.BoxDecoration(
                        color: subRating.color(theme),
                        borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(2),
                        ),
                      ),
                      child: pw.Text(
                        subRating.displayLabel,
                        style: theme.badgeStyle,
                      ),
                    ),
                  ],
                ),
                if (subFindings is String && subFindings.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(subFindings, style: theme.bodyStyle),
                ],
                pw.SizedBox(height: theme.paragraphSpacing),
              ],
            ),
          ),
        );
      }
    }

    widgets.add(pw.SizedBox(height: theme.sectionSpacing));

    return widgets;
  }
}

/// Inspector signature block with certification text.
class SignatureBlockSection extends NarrativeSection {
  const SignatureBlockSection({
    required this.title,
    required this.certificationText,
  });

  final String title;
  final String certificationText;

  @override
  List<pw.Widget> render({
    required NarrativePrintTheme theme,
    required NarrativeRenderContext context,
  }) {
    final widgets = <pw.Widget>[
      pw.Text(title, style: theme.heading2Style),
      pw.SizedBox(height: theme.paragraphSpacing),
      pw.Text(certificationText, style: theme.bodyStyle),
      pw.SizedBox(height: theme.paragraphSpacing * 2),
      pw.Divider(color: theme.divider, thickness: 0.5),
      pw.SizedBox(height: 4),
    ];

    // Signature image or fallback text
    if (context.signatureBytes != null &&
        context.signatureBytes!.isNotEmpty) {
      widgets.add(
        pw.Image(
          pw.MemoryImage(context.signatureBytes!),
          width: 200,
          height: 60,
          fit: pw.BoxFit.contain,
        ),
      );
    } else {
      widgets.add(
        pw.Text(
          'Signed',
          style: theme.bodyStyle.copyWith(
            fontStyle: pw.FontStyle.italic,
            color: theme.textMuted,
          ),
        ),
      );
    }

    widgets.add(pw.SizedBox(height: theme.paragraphSpacing));

    // Inspector details
    widgets.add(
      pw.Text(context.inspectorName, style: theme.heading3Style),
    );
    if (context.inspectorLicense.isNotEmpty) {
      widgets.add(
        pw.Text(
          'License: ${context.inspectorLicense}',
          style: theme.captionStyle,
        ),
      );
    }
    widgets.add(
      pw.Text(
        'Date: ${context.inspectionDate.month}/${context.inspectionDate.day}/${context.inspectionDate.year}',
        style: theme.captionStyle,
      ),
    );

    widgets.add(pw.SizedBox(height: theme.sectionSpacing));

    return widgets;
  }
}
