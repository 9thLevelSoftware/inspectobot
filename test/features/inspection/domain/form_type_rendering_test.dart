import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';

void main() {
  group('FormTypeRendering.isNarrative', () {
    test('moldAssessment is narrative', () {
      expect(FormType.moldAssessment.isNarrative, isTrue);
    });

    test('generalInspection is narrative', () {
      expect(FormType.generalInspection.isNarrative, isTrue);
    });

    test('fourPoint is not narrative', () {
      expect(FormType.fourPoint.isNarrative, isFalse);
    });

    test('roofCondition is not narrative', () {
      expect(FormType.roofCondition.isNarrative, isFalse);
    });

    test('windMitigation is not narrative', () {
      expect(FormType.windMitigation.isNarrative, isFalse);
    });

    test('wdo is not narrative', () {
      expect(FormType.wdo.isNarrative, isFalse);
    });

    test('sinkholeInspection is not narrative', () {
      expect(FormType.sinkholeInspection.isNarrative, isFalse);
    });

    test('all FormType values return expected result', () {
      final narrativeTypes = {
        FormType.moldAssessment,
        FormType.generalInspection,
      };

      for (final formType in FormType.values) {
        expect(
          formType.isNarrative,
          narrativeTypes.contains(formType),
          reason: '${formType.name}.isNarrative should be '
              '${narrativeTypes.contains(formType)}',
        );
      }
    });
  });
}
