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
      final cloudResult = await _cloud.generate(input);
      if (cloudResult != null) {
        return cloudResult;
      }
    }

    try {
      return await _onDevice.generate(input);
    } catch (_) {
      final cloudResult = await _cloud.generate(input);
      if (cloudResult != null) {
        return cloudResult;
      }
      rethrow;
    }
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

