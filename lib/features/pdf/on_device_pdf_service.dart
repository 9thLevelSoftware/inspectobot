import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pdf_generation_input.dart';

class OnDevicePdfService {
  const OnDevicePdfService();

  Future<File> generate(PdfGenerationInput input) async {
    final document = pw.Document();

    document.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(24),
          pageFormat: PdfPageFormat.letter,
        ),
        build: (context) => [
          pw.Header(level: 0, child: pw.Text('InspectoBot Inspection Report')),
          pw.Text('Client: ${input.clientName}'),
          pw.Text('Property: ${input.propertyAddress}'),
          pw.SizedBox(height: 12),
          pw.Text('Enabled forms:'),
          pw.Bullet(text: input.enabledForms.map((f) => f.label).join(', ')),
          pw.SizedBox(height: 12),
          pw.Text('Captured required categories:'),
          ...input.capturedCategories
              .map((category) => pw.Bullet(text: category.label)),
        ],
      ),
    );

    final directory = await getTemporaryDirectory();
    final filename = 'inspectobot_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${directory.path}/$filename');

    final bytes = await document.save();
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}
