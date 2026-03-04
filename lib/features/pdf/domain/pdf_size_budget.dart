enum PdfSizeBudgetOutcome {
  withinBudget,
  retry,
  overBudget,
}

class PdfSizeRetryStep {
  const PdfSizeRetryStep({required this.jpegQuality, required this.maxWidth});

  final int jpegQuality;
  final int maxWidth;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is PdfSizeRetryStep &&
        other.jpegQuality == jpegQuality &&
        other.maxWidth == maxWidth;
  }

  @override
  int get hashCode => Object.hash(jpegQuality, maxWidth);
}

class PdfSizeBudgetDecision {
  const PdfSizeBudgetDecision({
    required this.outcome,
    required this.generatedBytes,
    required this.maxBytes,
    required this.attemptIndex,
    required this.reason,
    this.nextRetryStep,
  });

  final PdfSizeBudgetOutcome outcome;
  final int generatedBytes;
  final int maxBytes;
  final int attemptIndex;
  final String reason;
  final PdfSizeRetryStep? nextRetryStep;

  bool get isTerminalFailure => outcome == PdfSizeBudgetOutcome.overBudget;
}

class PdfSizeBudget {
  const PdfSizeBudget({required this.maxBytes, required this.retrySteps});

  factory PdfSizeBudget.defaultPolicy() {
    return const PdfSizeBudget(
      maxBytes: 10 * 1024 * 1024,
      retrySteps: <PdfSizeRetryStep>[
        PdfSizeRetryStep(jpegQuality: 75, maxWidth: 1280),
        PdfSizeRetryStep(jpegQuality: 68, maxWidth: 1152),
        PdfSizeRetryStep(jpegQuality: 60, maxWidth: 1024),
      ],
    );
  }

  final int maxBytes;
  final List<PdfSizeRetryStep> retrySteps;

  PdfSizeBudgetDecision evaluate({
    required int generatedBytes,
    required int attemptIndex,
  }) {
    if (generatedBytes <= maxBytes) {
      return PdfSizeBudgetDecision(
        outcome: PdfSizeBudgetOutcome.withinBudget,
        generatedBytes: generatedBytes,
        maxBytes: maxBytes,
        attemptIndex: attemptIndex,
        reason: 'Generated PDF is within configured size budget.',
      );
    }

    if (attemptIndex < retrySteps.length - 1) {
      final nextAttempt = retrySteps[attemptIndex + 1];
      return PdfSizeBudgetDecision(
        outcome: PdfSizeBudgetOutcome.retry,
        generatedBytes: generatedBytes,
        maxBytes: maxBytes,
        attemptIndex: attemptIndex,
        nextRetryStep: nextAttempt,
        reason:
            'Generated PDF exceeds configured size budget. Retrying with tighter policy.',
      );
    }

    return PdfSizeBudgetDecision(
      outcome: PdfSizeBudgetOutcome.overBudget,
      generatedBytes: generatedBytes,
      maxBytes: maxBytes,
      attemptIndex: attemptIndex,
      reason:
          'Generated PDF exceeds configured PDF size budget after all retry steps.',
    );
  }
}

class PdfSizeBudgetConfigError implements Exception {
  const PdfSizeBudgetConfigError(this.message);

  final String message;

  @override
  String toString() => message;
}
