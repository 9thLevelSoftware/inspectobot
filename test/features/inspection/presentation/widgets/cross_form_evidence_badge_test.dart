import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/presentation/widgets/cross_form_evidence_badge.dart';
import 'package:inspectobot/theme/app_theme.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(body: child),
  );
}

void main() {
  group('CrossFormEvidenceBadge', () {
    testWidgets('renders form abbreviations for 2 shared forms',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const CrossFormEvidenceBadge(
          sharedForms: {FormType.fourPoint, FormType.generalInspection},
        ),
      ));

      expect(find.text('Also satisfies: 4PT, GEN'), findsOneWidget);
      expect(find.byIcon(Icons.link), findsOneWidget);
    });

    testWidgets('renders nothing when sharedForms is empty', (tester) async {
      await tester.pumpWidget(_wrap(
        const CrossFormEvidenceBadge(
          sharedForms: <FormType>{},
        ),
      ));

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.text('Also satisfies:'), findsNothing);
      expect(find.byIcon(Icons.link), findsNothing);
    });

    testWidgets('handles single shared form', (tester) async {
      await tester.pumpWidget(_wrap(
        const CrossFormEvidenceBadge(
          sharedForms: {FormType.roofCondition},
        ),
      ));

      expect(find.text('Also satisfies: ROOF'), findsOneWidget);
      expect(find.byIcon(Icons.link), findsOneWidget);
    });

    testWidgets('uses correct theme colors (secondary text)', (tester) async {
      await tester.pumpWidget(_wrap(
        const CrossFormEvidenceBadge(
          sharedForms: {FormType.windMitigation},
        ),
      ));

      final textWidget = tester.widget<Text>(
        find.text('Also satisfies: WIND'),
      );
      final theme = AppTheme.dark();
      final expectedColor = theme.colorScheme.onSurfaceVariant;

      expect(textWidget.style?.color, equals(expectedColor));
    });

    testWidgets('sorts abbreviations by FormType index', (tester) async {
      // generalInspection has a higher index than fourPoint
      await tester.pumpWidget(_wrap(
        const CrossFormEvidenceBadge(
          sharedForms: {FormType.generalInspection, FormType.fourPoint},
        ),
      ));

      // 4PT should come before GEN regardless of insertion order
      expect(find.text('Also satisfies: 4PT, GEN'), findsOneWidget);
    });
  });

  group('FormTypeAbbreviation', () {
    test('all form types have abbreviations', () {
      for (final form in FormType.values) {
        expect(form.abbreviation, isNotEmpty);
      }
    });

    test('abbreviation values match expected labels', () {
      expect(FormType.fourPoint.abbreviation, '4PT');
      expect(FormType.roofCondition.abbreviation, 'ROOF');
      expect(FormType.windMitigation.abbreviation, 'WIND');
      expect(FormType.wdo.abbreviation, 'WDO');
      expect(FormType.sinkholeInspection.abbreviation, 'SINK');
      expect(FormType.moldAssessment.abbreviation, 'MOLD');
      expect(FormType.generalInspection.abbreviation, 'GEN');
    });
  });
}
