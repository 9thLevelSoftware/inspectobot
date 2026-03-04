import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/pdf/data/pdf_size_budget_config_store.dart';
import 'package:inspectobot/features/pdf/domain/pdf_size_budget.dart';

void main() {
  group('PdfSizeBudget', () {
    test('uses insurer-safe default max-bytes threshold and retry ordering', () {
      final budget = PdfSizeBudget.defaultPolicy();

      expect(budget.maxBytes, 10 * 1024 * 1024);
      expect(budget.retrySteps, hasLength(3));
      expect(
        budget.retrySteps
            .map((step) => '${step.jpegQuality}:${step.maxWidth}')
            .toList(growable: false),
        <String>['75:1280', '68:1152', '60:1024'],
      );
    });

    test('returns within-budget on first successful attempt', () {
      final budget = PdfSizeBudget.defaultPolicy();
      final decision = budget.evaluate(
        generatedBytes: budget.maxBytes - 1,
        attemptIndex: 0,
      );

      expect(decision.outcome, PdfSizeBudgetOutcome.withinBudget);
      expect(decision.isTerminalFailure, isFalse);
      expect(decision.nextRetryStep, isNull);
    });

    test('returns deterministic retry steps until one passes budget', () {
      final budget = PdfSizeBudget.defaultPolicy();
      final first = budget.evaluate(
        generatedBytes: budget.maxBytes + 2048,
        attemptIndex: 0,
      );

      expect(first.outcome, PdfSizeBudgetOutcome.retry);
      expect(first.nextRetryStep, budget.retrySteps[1]);

      final second = budget.evaluate(
        generatedBytes: budget.maxBytes - 128,
        attemptIndex: 1,
      );

      expect(second.outcome, PdfSizeBudgetOutcome.withinBudget);
      expect(second.nextRetryStep, isNull);
      expect(second.isTerminalFailure, isFalse);
    });

    test('returns explicit terminal failure when all retries exceed budget', () {
      final budget = PdfSizeBudget.defaultPolicy();

      final terminal = budget.evaluate(
        generatedBytes: budget.maxBytes + 4096,
        attemptIndex: budget.retrySteps.length - 1,
      );

      expect(terminal.outcome, PdfSizeBudgetOutcome.overBudget);
      expect(terminal.isTerminalFailure, isTrue);
      expect(terminal.nextRetryStep, isNull);
      expect(terminal.reason, contains('exceeds configured PDF size budget'));
    });
  });

  group('PdfSizeBudgetConfigStore', () {
    test('loads configured maxBytes and retry steps with validation', () {
      final store = PdfSizeBudgetConfigStore(
        readConfig: () => <String, dynamic>{
          'max_bytes': 6 * 1024 * 1024,
          'retry_steps': <Map<String, dynamic>>[
            <String, dynamic>{'jpeg_quality': 72, 'max_width': 1200},
            <String, dynamic>{'jpeg_quality': 66, 'max_width': 1080},
          ],
        },
      );

      final budget = store.load();
      expect(budget.maxBytes, 6 * 1024 * 1024);
      expect(budget.retrySteps, hasLength(2));
      expect(budget.retrySteps.first.jpegQuality, 72);
      expect(budget.retrySteps.last.maxWidth, 1080);
    });

    test('falls back to default policy when config missing', () {
      final store = PdfSizeBudgetConfigStore(readConfig: () => null);
      final budget = store.load();

      expect(budget.maxBytes, PdfSizeBudget.defaultPolicy().maxBytes);
      expect(budget.retrySteps, PdfSizeBudget.defaultPolicy().retrySteps);
    });

    test('throws deterministic validation errors for invalid configuration', () {
      final invalidThresholdStore = PdfSizeBudgetConfigStore(
        readConfig: () => <String, dynamic>{
          'max_bytes': 0,
        },
      );
      expect(
        invalidThresholdStore.load,
        throwsA(
          isA<PdfSizeBudgetConfigError>().having(
            (e) => e.message,
            'message',
            contains('max_bytes must be > 0'),
          ),
        ),
      );

      final invalidRetryStore = PdfSizeBudgetConfigStore(
        readConfig: () => <String, dynamic>{
          'max_bytes': 1024,
          'retry_steps': <Map<String, dynamic>>[],
        },
      );
      expect(
        invalidRetryStore.load,
        throwsA(
          isA<PdfSizeBudgetConfigError>().having(
            (e) => e.message,
            'message',
            contains('retry_steps must not be empty'),
          ),
        ),
      );

      final invalidOrderStore = PdfSizeBudgetConfigStore(
        readConfig: () => <String, dynamic>{
          'max_bytes': 1024,
          'retry_steps': <Map<String, dynamic>>[
            <String, dynamic>{'jpeg_quality': 60, 'max_width': 1024},
            <String, dynamic>{'jpeg_quality': 75, 'max_width': 1280},
          ],
        },
      );
      expect(
        invalidOrderStore.load,
        throwsA(
          isA<PdfSizeBudgetConfigError>().having(
            (e) => e.message,
            'message',
            contains('least to most aggressive compression'),
          ),
        ),
      );
    });
  });
}
