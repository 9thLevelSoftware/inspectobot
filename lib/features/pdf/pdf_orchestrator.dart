import 'dart:io';

import '../inspection/domain/report_readiness.dart';
import 'cloud_pdf_service.dart';
import 'on_device_pdf_service.dart';
import 'pdf_generation_input.dart';
import 'pdf_strategy.dart';

typedef ReportReadinessLookup = Future<ReportReadiness?> Function(
  PdfGenerationInput input,
);

class PdfOrchestrator {
  PdfOrchestrator({
    required OnDevicePdfService onDevice,
    required CloudPdfService cloud,
    this.primaryStrategy = PdfStrategy.onDevice,
    this.readinessLookup,
  })  : _onDevice = onDevice,
        _cloud = cloud;

  final OnDevicePdfService _onDevice;
  final CloudPdfService _cloud;
  final PdfStrategy primaryStrategy;
  final ReportReadinessLookup? readinessLookup;

  Future<File> generate(PdfGenerationInput input) async {
    if (readinessLookup != null) {
      final readiness = await readinessLookup!(input);
      if (readiness == null || !readiness.isReady) {
        throw StateError(_buildReadinessMessage(readiness));
      }
    }

    if (primaryStrategy == PdfStrategy.cloudFallback) {
      return _generateUsingCloudFallbackStrategy(input);
    }

    try {
      return await _onDevice.generate(input);
    } on PdfGenerationSizeBudgetExceeded {
      rethrow;
    } catch (error) {
      final cloudOutcome = await _cloud.generate(input);
      if (cloudOutcome.type == CloudPdfGenerationOutcomeType.generated) {
        return _requireGeneratedFile(cloudOutcome);
      }
      if (cloudOutcome.type == CloudPdfGenerationOutcomeType.terminalFailure) {
        throw PdfCloudGenerationTerminalFailure(
          message:
              cloudOutcome.reason ??
              'Cloud PDF generation failed with terminal outcome.',
          cause: cloudOutcome.error,
        );
      }
      rethrow;
    }
  }

  Future<File> _generateUsingCloudFallbackStrategy(PdfGenerationInput input) async {
    final cloudOutcome = await _cloud.generate(input);
    if (cloudOutcome.type == CloudPdfGenerationOutcomeType.generated) {
      return _requireGeneratedFile(cloudOutcome);
    }
    if (cloudOutcome.type == CloudPdfGenerationOutcomeType.unavailable) {
      return _onDevice.generate(input);
    }
    throw PdfCloudGenerationTerminalFailure(
      message:
          cloudOutcome.reason ?? 'Cloud PDF generation failed with terminal outcome.',
      cause: cloudOutcome.error,
    );
  }

  File _requireGeneratedFile(CloudPdfGenerationOutcome outcome) {
    final file = outcome.file;
    if (file == null) {
      throw const PdfCloudGenerationTerminalFailure(
        message: 'Cloud PDF generation produced no artifact file.',
      );
    }
    return file;
  }

  String _buildReadinessMessage(ReportReadiness? readiness) {
    if (readiness == null) {
      return 'Inspection is not generation-ready. Missing readiness snapshot.';
    }
    if (readiness.missingItems.isEmpty) {
      return 'Inspection is not generation-ready.';
    }
    return 'Inspection is not generation-ready. Missing: ${readiness.missingItems.join(', ')}';
  }
}

class PdfCloudGenerationTerminalFailure implements Exception {
  const PdfCloudGenerationTerminalFailure({
    required this.message,
    this.cause,
  });

  final String message;
  final Object? cause;

  @override
  String toString() {
    if (cause == null) {
      return message;
    }
    return '$message cause=$cause';
  }
}

