import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_exceptions.dart';

void main() {
  group('NarrativeRenderException', () {
    test('toString includes formType and message', () {
      const exception = NarrativeRenderException(
        message: 'Failed to render section',
        formType: FormType.moldAssessment,
      );

      final result = exception.toString();

      expect(result, contains('moldAssessment'));
      expect(result, contains('Failed to render section'));
      expect(result, startsWith('NarrativeRenderException('));
    });

    test('cause field is preserved when provided', () {
      final cause = FormatException('bad data');
      final exception = NarrativeRenderException(
        message: 'Render failed',
        formType: FormType.generalInspection,
        cause: cause,
      );

      expect(exception.cause, same(cause));
    });

    test('cause field is null when not provided', () {
      const exception = NarrativeRenderException(
        message: 'Render failed',
        formType: FormType.fourPoint,
      );

      expect(exception.cause, isNull);
    });
  });

  group('NarrativeTemplateNotFoundError', () {
    test('toString includes formType code', () {
      const error = NarrativeTemplateNotFoundError(FormType.moldAssessment);

      final result = error.toString();

      expect(result, contains('mold_assessment'));
      expect(result, contains('No narrative template registered'));
    });

    test('toString works for all form types', () {
      for (final formType in FormType.values) {
        final error = NarrativeTemplateNotFoundError(formType);
        expect(error.toString(), contains(formType.code));
      }
    });
  });
}
