import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_print_theme.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_section.dart';

import '../helpers/test_render_context.dart';

void main() {
  late NarrativePrintTheme theme;

  setUp(() {
    theme = NarrativePrintTheme.standard();
  });

  group('ConditionRating', () {
    test('parses standard values', () {
      expect(
        ConditionRating.parse('satisfactory'),
        equals(ConditionRating.satisfactory),
      );
      expect(
        ConditionRating.parse('marginal'),
        equals(ConditionRating.marginal),
      );
      expect(
        ConditionRating.parse('deficient'),
        equals(ConditionRating.deficient),
      );
      expect(
        ConditionRating.parse('not_inspected'),
        equals(ConditionRating.notInspected),
      );
    });

    test('parses alternative values', () {
      expect(ConditionRating.parse('good'), equals(ConditionRating.satisfactory));
      expect(ConditionRating.parse('fair'), equals(ConditionRating.marginal));
      expect(ConditionRating.parse('poor'), equals(ConditionRating.deficient));
      expect(ConditionRating.parse('n/a'), equals(ConditionRating.notInspected));
    });

    test('falls back to notInspected for unknown values', () {
      expect(ConditionRating.parse('unknown'), equals(ConditionRating.notInspected));
      expect(ConditionRating.parse(null), equals(ConditionRating.notInspected));
      expect(ConditionRating.parse(''), equals(ConditionRating.notInspected));
    });

    test('displayLabel returns human-readable text', () {
      expect(ConditionRating.satisfactory.displayLabel, equals('Satisfactory'));
      expect(ConditionRating.marginal.displayLabel, equals('Marginal'));
      expect(ConditionRating.deficient.displayLabel, equals('Deficient'));
      expect(ConditionRating.notInspected.displayLabel, equals('Not Inspected'));
    });
  });

  group('ConditionRatingSection', () {
    test('renders system with rating badge and findings', () {
      const section = ConditionRatingSection(
        systemName: 'Electrical System',
        ratingKey: 'electrical_rating',
        findingsKey: 'electrical_findings',
      );
      final context = buildTestRenderContext(
        formData: {
          'electrical_rating': 'satisfactory',
          'electrical_findings': 'All circuits tested and functioning.',
        },
      );

      final widgets = section.render(theme: theme, context: context);

      expect(widgets, isNotEmpty);
      // heading row + spacing + findings + spacing + section spacing
      expect(widgets.length, greaterThanOrEqualTo(4));
    });

    test('renders with inline photos', () {
      final section = ConditionRatingSection(
        systemName: 'Roof',
        ratingKey: 'roof_rating',
        findingsKey: 'roof_findings',
        photoKeys: ['roof_overview'],
      );
      final context = buildTestRenderContext(
        formData: {
          'roof_rating': 'marginal',
          'roof_findings': 'Minor wear observed.',
        },
        resolvedPhotos: {
          'roof_overview': [buildResolvedPhoto(sourceKey: 'roof_overview')],
        },
      );

      final widgets = section.render(theme: theme, context: context);

      expect(widgets, isNotEmpty);
    });

    test('renders with sub-systems', () {
      final section = ConditionRatingSection(
        systemName: 'Plumbing',
        ratingKey: 'plumbing_rating',
        findingsKey: 'plumbing_findings',
        subSystems: [
          ConditionRatingSubSystem(
            name: 'Supply Lines',
            ratingKey: 'supply_rating',
            findingsKey: 'supply_findings',
          ),
          ConditionRatingSubSystem(
            name: 'Drain Lines',
            ratingKey: 'drain_rating',
            findingsKey: 'drain_findings',
          ),
        ],
      );
      final context = buildTestRenderContext(
        formData: {
          'plumbing_rating': 'deficient',
          'plumbing_findings': 'Multiple issues found.',
          'supply_rating': 'satisfactory',
          'supply_findings': 'Supply lines in good condition.',
          'drain_rating': 'deficient',
          'drain_findings': 'Slow drains in master bath.',
        },
      );

      final widgets = section.render(theme: theme, context: context);

      expect(widgets, isNotEmpty);
      // Should include sub-system indented entries
      expect(widgets.length, greaterThanOrEqualTo(5));
    });

    test('handles missing rating key gracefully', () {
      const section = ConditionRatingSection(
        systemName: 'HVAC',
        ratingKey: 'hvac_rating',
        findingsKey: 'hvac_findings',
      );
      final context = buildTestRenderContext();

      final widgets = section.render(theme: theme, context: context);

      expect(widgets, isNotEmpty);
      // Should default to notInspected
    });
  });
}
