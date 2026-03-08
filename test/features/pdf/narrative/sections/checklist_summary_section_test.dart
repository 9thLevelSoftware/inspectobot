import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_print_theme.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_section.dart';

import '../helpers/test_render_context.dart';

void main() {
  late NarrativePrintTheme theme;

  setUp(() {
    theme = NarrativePrintTheme.standard();
  });

  group('ChecklistSummarySection', () {
    test('renders table with items', () {
      final section = ChecklistSummarySection(
        heading: 'System Checklist',
        items: [
          ChecklistSummaryItem(
            label: 'Roof',
            status: 'Satisfactory',
            notes: 'No issues found',
          ),
          ChecklistSummaryItem(
            label: 'Plumbing',
            status: 'Deficient',
            notes: 'Leak detected',
          ),
        ],
      );
      final context = buildTestRenderContext();

      final widgets = section.render(theme: theme, context: context);

      expect(widgets, isNotEmpty);
      // heading + spacing + table + section spacing
      expect(widgets.length, equals(4));
    });

    test('returns empty list for empty items', () {
      const section = ChecklistSummarySection(
        heading: 'Empty Checklist',
        items: [],
      );
      final context = buildTestRenderContext();

      final widgets = section.render(theme: theme, context: context);

      expect(widgets, isEmpty);
    });

    test('handles various status values for color coding', () {
      final section = ChecklistSummarySection(
        heading: 'Mixed Statuses',
        items: [
          ChecklistSummaryItem(label: 'A', status: 'Good'),
          ChecklistSummaryItem(label: 'B', status: 'Fair'),
          ChecklistSummaryItem(label: 'C', status: 'Poor'),
          ChecklistSummaryItem(label: 'D', status: 'Unknown'),
        ],
      );
      final context = buildTestRenderContext();

      final widgets = section.render(theme: theme, context: context);

      expect(widgets, isNotEmpty);
    });
  });
}
