import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/condition_rating.dart';

void main() {
  group('ConditionRating', () {
    group('parse()', () {
      test('parses satisfactory aliases', () {
        expect(ConditionRating.parse('satisfactory'),
            ConditionRating.satisfactory);
        expect(ConditionRating.parse('good'), ConditionRating.satisfactory);
        expect(ConditionRating.parse('pass'), ConditionRating.satisfactory);
      });

      test('parses marginal aliases', () {
        expect(ConditionRating.parse('marginal'), ConditionRating.marginal);
        expect(ConditionRating.parse('fair'), ConditionRating.marginal);
        expect(ConditionRating.parse('caution'), ConditionRating.marginal);
      });

      test('parses deficient aliases', () {
        expect(ConditionRating.parse('deficient'), ConditionRating.deficient);
        expect(ConditionRating.parse('poor'), ConditionRating.deficient);
        expect(ConditionRating.parse('fail'), ConditionRating.deficient);
      });

      test('parses notInspected aliases', () {
        expect(ConditionRating.parse('not_inspected'),
            ConditionRating.notInspected);
        expect(ConditionRating.parse('notinspected'),
            ConditionRating.notInspected);
        expect(ConditionRating.parse('n/a'), ConditionRating.notInspected);
        expect(ConditionRating.parse('na'), ConditionRating.notInspected);
      });

      test('returns notInspected for null', () {
        expect(ConditionRating.parse(null), ConditionRating.notInspected);
      });

      test('returns notInspected for empty string', () {
        expect(ConditionRating.parse(''), ConditionRating.notInspected);
        expect(ConditionRating.parse('   '), ConditionRating.notInspected);
      });

      test('returns notInspected for unknown string', () {
        expect(ConditionRating.parse('unknown'), ConditionRating.notInspected);
        expect(
            ConditionRating.parse('excellent'), ConditionRating.notInspected);
      });

      test('is case-insensitive', () {
        expect(
            ConditionRating.parse('SATISFACTORY'),
            ConditionRating.satisfactory);
        expect(ConditionRating.parse('Marginal'), ConditionRating.marginal);
        expect(ConditionRating.parse('DEFICIENT'), ConditionRating.deficient);
      });

      test('trims whitespace', () {
        expect(ConditionRating.parse('  satisfactory  '),
            ConditionRating.satisfactory);
      });
    });

    group('displayLabel', () {
      test('returns non-empty string for all values', () {
        for (final rating in ConditionRating.values) {
          expect(rating.displayLabel, isNotEmpty,
              reason: '$rating should have a non-empty displayLabel');
        }
      });

      test('returns expected labels', () {
        expect(ConditionRating.satisfactory.displayLabel, 'Satisfactory');
        expect(ConditionRating.marginal.displayLabel, 'Marginal');
        expect(ConditionRating.deficient.displayLabel, 'Deficient');
        expect(ConditionRating.notInspected.displayLabel, 'Not Inspected');
      });
    });

    group('round-trip', () {
      test('parse(rating.name) returns original rating for all values', () {
        for (final rating in ConditionRating.values) {
          expect(ConditionRating.parse(rating.name), rating,
              reason: 'parse(${rating.name}) should return $rating');
        }
      });
    });
  });
}
