import 'dart:io';

import 'pdf_generation_input.dart';

class CloudPdfService {
  const CloudPdfService();

  Future<CloudPdfGenerationOutcome> generate(PdfGenerationInput input) async {
    return const CloudPdfGenerationOutcome.unavailable(
      reason: 'Cloud PDF generation is not configured.',
    );
  }
}

enum CloudPdfGenerationOutcomeType {
  generated,
  unavailable,
  terminalFailure,
}

class CloudPdfGenerationOutcome {
  const CloudPdfGenerationOutcome._({
    required this.type,
    this.file,
    this.reason,
    this.error,
  });

  const CloudPdfGenerationOutcome.generated(File file)
    : this._(type: CloudPdfGenerationOutcomeType.generated, file: file);

  const CloudPdfGenerationOutcome.unavailable({String? reason})
    : this._(
        type: CloudPdfGenerationOutcomeType.unavailable,
        reason: reason,
      );

  const CloudPdfGenerationOutcome.terminalFailure({
    required Object error,
    String? reason,
  }) : this._(
         type: CloudPdfGenerationOutcomeType.terminalFailure,
         error: error,
         reason: reason,
       );

  final CloudPdfGenerationOutcomeType type;
  final File? file;
  final String? reason;
  final Object? error;
}

