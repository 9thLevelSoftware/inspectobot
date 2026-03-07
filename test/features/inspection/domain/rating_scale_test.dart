import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/rating_scale.dart';

void main() {
  group('RatingScale', () {
    test('has all 7 enum values', () {
      expect(RatingScale.values.length, 7);
      expect(RatingScale.values, contains(RatingScale.satisfactory));
      expect(RatingScale.values, contains(RatingScale.marginal));
      expect(RatingScale.values, contains(RatingScale.deficient));
      expect(RatingScale.values, contains(RatingScale.failed));
      expect(RatingScale.values, contains(RatingScale.notApplicable));
      expect(RatingScale.values, contains(RatingScale.notVisible));
      expect(RatingScale.values, contains(RatingScale.missing));
    });

    group('fromFormValue', () {
      test('fourPoint: Satisfactory -> satisfactory, Unsatisfactory -> deficient', () {
        expect(RatingScale.fromFormValue('Satisfactory', FormType.fourPoint),
            RatingScale.satisfactory);
        expect(RatingScale.fromFormValue('Unsatisfactory', FormType.fourPoint),
            RatingScale.deficient);
      });

      test('generalInspection: Good -> satisfactory, Fair -> marginal, Poor -> deficient', () {
        expect(RatingScale.fromFormValue('Good', FormType.generalInspection),
            RatingScale.satisfactory);
        expect(RatingScale.fromFormValue('Fair', FormType.generalInspection),
            RatingScale.marginal);
        expect(RatingScale.fromFormValue('Poor', FormType.generalInspection),
            RatingScale.deficient);
      });

      test('roofCondition: Failed -> failed', () {
        expect(RatingScale.fromFormValue('Failed', FormType.roofCondition),
            RatingScale.failed);
      });
    });

    group('toFormString round-trips', () {
      test('fourPoint: satisfactory round-trips', () {
        expect(RatingScale.satisfactory.toFormString(FormType.fourPoint),
            'Satisfactory');
      });

      test('roofCondition: deficient -> Poor', () {
        expect(RatingScale.deficient.toFormString(FormType.roofCondition),
            'Poor');
      });

      test('generalInspection: marginal -> Fair', () {
        expect(RatingScale.marginal.toFormString(FormType.generalInspection),
            'Fair');
      });
    });

    group('fromJsonValue / toJsonValue round-trip', () {
      test('round-trips all values', () {
        for (final value in RatingScale.values) {
          final json = value.toJsonValue();
          final restored = RatingScale.fromJsonValue(json);
          expect(restored, value);
        }
      });

      test('fromJsonValue returns null for unknown string', () {
        expect(RatingScale.fromJsonValue('bogus'), isNull);
      });

      test('fromJsonValue returns null for null', () {
        expect(RatingScale.fromJsonValue(null), isNull);
      });
    });

    group('semantic helpers', () {
      test('isDeficient', () {
        expect(RatingScale.deficient.isDeficient, isTrue);
        expect(RatingScale.failed.isDeficient, isTrue);
        expect(RatingScale.satisfactory.isDeficient, isFalse);
      });

      test('isAcceptable', () {
        expect(RatingScale.satisfactory.isAcceptable, isTrue);
        expect(RatingScale.marginal.isAcceptable, isTrue);
        expect(RatingScale.deficient.isAcceptable, isFalse);
      });

      test('isNonAnswer', () {
        expect(RatingScale.notApplicable.isNonAnswer, isTrue);
        expect(RatingScale.notVisible.isNonAnswer, isTrue);
        expect(RatingScale.missing.isNonAnswer, isTrue);
        expect(RatingScale.satisfactory.isNonAnswer, isFalse);
      });

      test('severityOrdinal', () {
        expect(RatingScale.satisfactory.severityOrdinal, 0);
        expect(RatingScale.marginal.severityOrdinal, 1);
        expect(RatingScale.deficient.severityOrdinal, 2);
        expect(RatingScale.failed.severityOrdinal, 3);
        expect(RatingScale.notApplicable.severityOrdinal, isNull);
      });
    });
  });
}
