import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/pdf_media_resolver.dart';
import '../domain/pdf_size_budget.dart';
import '../models/pdf_field_map.dart';
import '../models/pdf_template_manifest.dart';

class PdfRenderFormRequest {
  const PdfRenderFormRequest({
    required this.manifestEntry,
    required this.fieldMap,
    required this.resolved,
    required this.templateBytes,
  });

  final PdfTemplateManifestEntry manifestEntry;
  final PdfFieldMap fieldMap;
  final ResolvedPdfFieldData resolved;
  final Uint8List templateBytes;
}

class PdfRenderRequest {
  const PdfRenderRequest({required this.forms, required this.retryStep});

  final List<PdfRenderFormRequest> forms;
  final PdfSizeRetryStep retryStep;
}

class PdfRenderer {
  const PdfRenderer();

  Future<Uint8List> render(PdfRenderRequest request) async {
    final document = pw.Document();

    for (final form in request.forms) {
      if (form.templateBytes.isEmpty) {
        throw StateError(
          'Template bytes missing for form ${form.manifestEntry.formType.code}',
        );
      }
      final pageNumbers = form.fieldMap.fields
          .map((field) => field.page)
          .toSet()
          .toList(growable: false)
        ..sort();

      for (final pageNumber in pageNumbers) {
        final pageFields = form.fieldMap.fields
            .where((field) => field.page == pageNumber)
            .toList(growable: false);

        document.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.letter,
            margin: pw.EdgeInsets.zero,
            build: (context) {
              final children = <pw.Widget>[
                pw.Positioned(
                  left: 24,
                  top: 20,
                  child: pw.Text(
                    '${form.manifestEntry.revisionLabel} — page $pageNumber',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
              ];

              for (final field in pageFields) {
                final top = PdfPageFormat.letter.height - field.y - field.height;
                switch (field.type) {
                  case PdfFieldType.text:
                    final value = form.resolved.textByFieldKey[field.key] ?? '';
                    if (value.isEmpty) {
                      continue;
                    }
                    children.add(
                      pw.Positioned(
                        left: field.x,
                        top: top,
                        child: pw.SizedBox(
                          width: field.width,
                          height: field.height,
                          child: pw.Text(
                            value,
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                    );
                  case PdfFieldType.checkbox:
                    final checked =
                        form.resolved.checkboxByFieldKey[field.key] == true;
                    if (!checked) {
                      continue;
                    }
                    children.add(
                      pw.Positioned(
                        left: field.x,
                        top: top,
                        child: pw.Text(
                          'X',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  case PdfFieldType.image:
                    final bytes = form.resolved.imageByFieldKey[field.key];
                    if (bytes == null || bytes.isEmpty) {
                      continue;
                    }
                    children.add(
                      pw.Positioned(
                        left: field.x,
                        top: top,
                        child: pw.Image(
                          pw.MemoryImage(bytes),
                          width: field.width,
                          height: field.height,
                          fit: pw.BoxFit.cover,
                        ),
                      ),
                    );
                  case PdfFieldType.signature:
                    final bytes = form.resolved.signatureByFieldKey[field.key];
                    if (bytes != null && bytes.isNotEmpty) {
                      children.add(
                        pw.Positioned(
                          left: field.x,
                          top: top,
                          child: pw.Image(
                            pw.MemoryImage(bytes),
                            width: field.width,
                            height: field.height,
                            fit: pw.BoxFit.contain,
                          ),
                        ),
                      );
                    } else {
                      children.add(
                        pw.Positioned(
                          left: field.x,
                          top: top,
                          child: pw.Text(
                            'Signed',
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        ),
                      );
                    }
                }
              }

              return pw.Stack(children: children);
            },
          ),
        );
      }
    }

    return document.save();
  }
}
