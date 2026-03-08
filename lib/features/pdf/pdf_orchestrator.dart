import 'dart:io';

import '../inspection/domain/form_type.dart';
import '../inspection/domain/report_readiness.dart';
import 'cloud_pdf_service.dart';
import 'data/pdf_size_budget_config_store.dart';
import 'domain/pdf_size_budget.dart';
import 'narrative/narrative_report_engine.dart';
import 'on_device_pdf_service.dart';
import 'pdf_generation_input.dart';
import 'pdf_strategy.dart';

typedef ReportReadinessLookup = Future<ReportReadiness?> Function(
  PdfGenerationInput input,
);

typedef PdfOutputDirectoryProvider = Future<Directory> Function();

class PdfOrchestrator {
  PdfOrchestrator({
    required OnDevicePdfService onDevice,
    required CloudPdfService cloud,
    this.primaryStrategy = PdfStrategy.onDevice,
    this.readinessLookup,
    NarrativeReportEngine? narrative,
    PdfSizeBudgetConfigStore? sizeBudgetStore,
    PdfOutputDirectoryProvider? outputDirectoryProvider,
  })  : _onDevice = onDevice,
        _cloud = cloud,
        _narrative = narrative,
        _sizeBudgetStore = sizeBudgetStore ?? PdfSizeBudgetConfigStore(),
        _outputDirectoryProvider = outputDirectoryProvider;

  final OnDevicePdfService _onDevice;
  final CloudPdfService _cloud;
  final NarrativeReportEngine? _narrative;
  final PdfSizeBudgetConfigStore _sizeBudgetStore;
  final PdfOutputDirectoryProvider? _outputDirectoryProvider;
  final PdfStrategy primaryStrategy;
  final ReportReadinessLookup? readinessLookup;

  Future<List<File>> generate(PdfGenerationInput input) async {
    if (readinessLookup != null) {
      final readiness = await readinessLookup!(input);
      if (readiness == null || !readiness.isReady) {
        throw StateError(_buildReadinessMessage(readiness));
      }
    }

    final overlayForms = <FormType>{};
    final narrativeForms = <FormType>{};
    for (final form in input.enabledForms) {
      if (form.isNarrative) {
        narrativeForms.add(form);
      } else {
        overlayForms.add(form);
      }
    }

    // Validate narrative engine availability
    if (narrativeForms.isNotEmpty && _narrative == null) {
      throw StateError(
        'Narrative forms requested (${narrativeForms.map((f) => f.code).join(', ')}) '
        'but no NarrativeReportEngine was provided.',
      );
    }

    final results = <File>[];

    // Generate overlay PDF for non-narrative forms
    if (overlayForms.isNotEmpty) {
      final overlayInput = _overlayInput(input, overlayForms);
      final overlayFile = await _generateOverlay(overlayInput);
      results.add(overlayFile);
    }

    // Generate narrative PDFs
    for (final formType in narrativeForms) {
      final narrativeFile = await _generateNarrative(input, formType);
      results.add(narrativeFile);
    }

    return results;
  }

  /// Builds a [PdfGenerationInput] scoped to overlay-only forms.
  PdfGenerationInput _overlayInput(
    PdfGenerationInput input,
    Set<FormType> overlayForms,
  ) {
    if (overlayForms.length == input.enabledForms.length) {
      return input; // All forms are overlay — no filtering needed.
    }
    return PdfGenerationInput(
      inspectionId: input.inspectionId,
      organizationId: input.organizationId,
      userId: input.userId,
      clientName: input.clientName,
      propertyAddress: input.propertyAddress,
      enabledForms: overlayForms,
      capturedCategories: input.capturedCategories,
      wizardCompletion: input.wizardCompletion,
      branchContext: input.branchContext,
      fieldValues: input.fieldValues,
      checkboxValues: input.checkboxValues,
      evidenceMediaPaths: input.evidenceMediaPaths,
      signatureBytes: input.signatureBytes,
      narrativeFormData: input.narrativeFormData,
    );
  }

  Future<File> _generateOverlay(PdfGenerationInput input) async {
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

  Future<File> _generateNarrative(
    PdfGenerationInput input,
    FormType formType,
  ) async {
    final budget = _sizeBudgetStore.load();
    if (budget.retrySteps.isEmpty) {
      throw const PdfSizeBudgetConfigError('retry_steps must not be empty');
    }

    final retryStep = budget.retrySteps.first;
    final bytes = await _narrative!.generate(
      input: input,
      formType: formType,
      retryStep: retryStep,
    );

    return _writeNarrativeOutput(bytes, formType);
  }

  Future<File> _writeNarrativeOutput(
    List<int> bytes,
    FormType formType,
  ) async {
    final Directory directory;
    final provider = _outputDirectoryProvider;
    if (provider != null) {
      directory = await provider();
    } else {
      directory = Directory.systemTemp;
    }
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = 'inspectobot_${formType.code}_$timestamp.pdf';
    final file = File('${directory.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file;
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
