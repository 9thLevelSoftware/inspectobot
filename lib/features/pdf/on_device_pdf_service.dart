import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'data/pdf_media_resolver.dart';
import 'data/pdf_size_budget_config_store.dart';
import 'data/pdf_template_asset_loader.dart';
import 'domain/pdf_size_budget.dart';
import 'models/pdf_field_map.dart';
import 'pdf_generation_input.dart';
import 'services/pdf_renderer.dart';

typedef PdfOutputDirectoryProvider = Future<Directory> Function();

class OnDevicePdfService {
  OnDevicePdfService({
    PdfTemplateAssetLoader? templateAssetLoader,
    PdfMediaResolver? mediaResolver,
    PdfSizeBudgetConfigStore? sizeBudgetStore,
    PdfRenderer? renderer,
    PdfOutputDirectoryProvider? outputDirectoryProvider,
  })  : _templateAssetLoader = templateAssetLoader ?? PdfTemplateAssetLoader(),
        _mediaResolver = mediaResolver ?? const PdfMediaResolver(),
        _sizeBudgetStore = sizeBudgetStore ?? PdfSizeBudgetConfigStore(),
        _renderer = renderer ?? const PdfRenderer(),
        _outputDirectoryProvider =
            outputDirectoryProvider ?? getTemporaryDirectory;

  final PdfTemplateAssetLoader _templateAssetLoader;
  final PdfMediaResolver _mediaResolver;
  final PdfSizeBudgetConfigStore _sizeBudgetStore;
  final PdfRenderer _renderer;
  final PdfOutputDirectoryProvider _outputDirectoryProvider;

  Future<File> generate(PdfGenerationInput input) async {
    final budget = _sizeBudgetStore.load();
    if (budget.retrySteps.isEmpty) {
      throw const PdfSizeBudgetConfigError('retry_steps must not be empty');
    }

    for (var attemptIndex = 0; attemptIndex < budget.retrySteps.length; attemptIndex += 1) {
      final retryStep = budget.retrySteps[attemptIndex];
      final formRequests = <PdfRenderFormRequest>[];
      final forms = input.enabledForms.toList(growable: false)
        ..sort((a, b) => a.code.compareTo(b.code));

      for (final formType in forms) {
        final templateBundle = await _templateAssetLoader.load(formType);
        final resolved = await _mediaResolver.resolve(
          input: input,
          fieldMap: templateBundle.fieldMap,
        );
        _ensureRequiredEvidenceResolved(
          input: input,
          fieldMap: templateBundle.fieldMap,
          resolved: resolved,
        );

        formRequests.add(
          PdfRenderFormRequest(
            manifestEntry: templateBundle.manifestEntry,
            fieldMap: templateBundle.fieldMap,
            resolved: resolved,
            templateBytes: templateBundle.templateBytes,
          ),
        );
      }

      final bytes = await _renderer.render(
        PdfRenderRequest(forms: formRequests, retryStep: retryStep),
      );
      final budgetDecision = budget.evaluate(
        generatedBytes: bytes.length,
        attemptIndex: attemptIndex,
      );

      if (budgetDecision.outcome == PdfSizeBudgetOutcome.withinBudget) {
        return _writeOutput(bytes);
      }

      if (budgetDecision.outcome == PdfSizeBudgetOutcome.overBudget) {
        throw PdfGenerationSizeBudgetExceeded(
          message:
              'PDF exceeded configured size budget (bytes=${bytes.length}, '
              'max=${budget.maxBytes}, attempts=${attemptIndex + 1}).',
          generatedBytes: bytes.length,
          maxBytes: budget.maxBytes,
          attempts: attemptIndex + 1,
        );
      }
    }

    throw PdfGenerationSizeBudgetExceeded(
      message: 'PDF exceeded configured size budget (bytes=unknown).',
      generatedBytes: -1,
      maxBytes: budget.maxBytes,
      attempts: budget.retrySteps.length,
    );
  }

  void _ensureRequiredEvidenceResolved({
    required PdfGenerationInput input,
    required PdfFieldMap fieldMap,
    required ResolvedPdfFieldData resolved,
  }) {
    final unresolvedRequiredEvidence = <String, String>{};

    for (final field in fieldMap.fields) {
      if (field.type != PdfFieldType.image) {
        continue;
      }
      if (input.wizardCompletion[field.sourceKey] != true) {
        continue;
      }
      if (resolved.imageByFieldKey.containsKey(field.key)) {
        continue;
      }

      unresolvedRequiredEvidence[field.key] =
          resolved.unresolvedMediaByFieldKey[field.key] ??
          'No bytes resolved for required source ${field.sourceKey}';
    }

    if (unresolvedRequiredEvidence.isNotEmpty) {
      throw PdfGenerationException(
        message:
            'Required evidence media could not be resolved for ${fieldMap.formType.code}.',
        unresolvedRequiredEvidence: unresolvedRequiredEvidence,
      );
    }
  }

  Future<File> _writeOutput(List<int> bytes) async {
    final directory = await _outputDirectoryProvider();
    final filename = 'inspectobot_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${directory.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}

class PdfGenerationSizeBudgetExceeded implements Exception {
  const PdfGenerationSizeBudgetExceeded({
    required this.message,
    required this.generatedBytes,
    required this.maxBytes,
    required this.attempts,
  });

  final String message;
  final int generatedBytes;
  final int maxBytes;
  final int attempts;

  @override
  String toString() => message;
}

class PdfGenerationException implements Exception {
  const PdfGenerationException({
    required this.message,
    this.unresolvedRequiredEvidence = const <String, String>{},
  });

  final String message;
  final Map<String, String> unresolvedRequiredEvidence;

  @override
  String toString() => message;
}
