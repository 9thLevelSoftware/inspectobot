import '../domain/pdf_size_budget.dart';

typedef PdfBudgetConfigReader = Map<String, dynamic>? Function();

class PdfSizeBudgetConfigStore {
  PdfSizeBudgetConfigStore({PdfBudgetConfigReader? readConfig})
    : _readConfig = readConfig;

  final PdfBudgetConfigReader? _readConfig;

  PdfSizeBudget load() {
    final config = _readConfig?.call();
    if (config == null) {
      return PdfSizeBudget.defaultPolicy();
    }

    final maxBytesRaw = config['max_bytes'];
    if (maxBytesRaw == null) {
      return PdfSizeBudget.defaultPolicy();
    }
    if (maxBytesRaw is! int || maxBytesRaw <= 0) {
      throw const PdfSizeBudgetConfigError('max_bytes must be > 0');
    }

    final retryStepsRaw = config['retry_steps'];
    if (retryStepsRaw == null) {
      return PdfSizeBudget(
        maxBytes: maxBytesRaw,
        retrySteps: PdfSizeBudget.defaultPolicy().retrySteps,
      );
    }
    if (retryStepsRaw is! List || retryStepsRaw.isEmpty) {
      throw const PdfSizeBudgetConfigError('retry_steps must not be empty');
    }

    final retrySteps = <PdfSizeRetryStep>[];
    for (final step in retryStepsRaw) {
      if (step is! Map<String, dynamic>) {
        throw const PdfSizeBudgetConfigError(
          'retry_steps entries must be objects',
        );
      }
      final quality = step['jpeg_quality'];
      final maxWidth = step['max_width'];
      if (quality is! int || quality <= 0 || quality > 100) {
        throw const PdfSizeBudgetConfigError(
          'retry_steps[].jpeg_quality must be 1..100',
        );
      }
      if (maxWidth is! int || maxWidth <= 0) {
        throw const PdfSizeBudgetConfigError(
          'retry_steps[].max_width must be > 0',
        );
      }
      retrySteps.add(PdfSizeRetryStep(jpegQuality: quality, maxWidth: maxWidth));
    }

    for (var index = 1; index < retrySteps.length; index += 1) {
      final previous = retrySteps[index - 1];
      final current = retrySteps[index];
      if (current.jpegQuality > previous.jpegQuality ||
          current.maxWidth > previous.maxWidth) {
        throw const PdfSizeBudgetConfigError(
          'retry_steps must be ordered from least to most aggressive compression',
        );
      }
    }

    return PdfSizeBudget(maxBytes: maxBytesRaw, retrySteps: retrySteps);
  }
}
