import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/common/widgets/wizard_progress_indicator.dart';
import 'package:inspectobot/theme/theme.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: child)),
  );
}

void main() {
  group('WizardProgressIndicator', () {
    testWidgets('displays "Step 2 of 5" text', (tester) async {
      await tester.pumpWidget(_wrap(
        const WizardProgressIndicator(
          currentStep: 2,
          totalSteps: 5,
          completionPercent: 40,
        ),
      ));

      expect(find.text('Step 2 of 5'), findsOneWidget);
    });

    testWidgets('displays "40%" text', (tester) async {
      await tester.pumpWidget(_wrap(
        const WizardProgressIndicator(
          currentStep: 2,
          totalSteps: 5,
          completionPercent: 40,
        ),
      ));

      expect(find.text('40%'), findsOneWidget);
    });

    testWidgets('LinearProgressIndicator has correct value (0.4)',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const WizardProgressIndicator(
          currentStep: 2,
          totalSteps: 5,
          completionPercent: 40,
        ),
      ));

      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, closeTo(0.4, 0.001));
    });

    testWidgets('step 1 of 1 at 100% renders correctly', (tester) async {
      await tester.pumpWidget(_wrap(
        const WizardProgressIndicator(
          currentStep: 1,
          totalSteps: 1,
          completionPercent: 100,
        ),
      ));

      expect(find.text('Step 1 of 1'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);

      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, closeTo(1.0, 0.001));
    });

    testWidgets('0% completion renders empty bar', (tester) async {
      await tester.pumpWidget(_wrap(
        const WizardProgressIndicator(
          currentStep: 1,
          totalSteps: 3,
          completionPercent: 0,
        ),
      ));

      expect(find.text('0%'), findsOneWidget);

      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, closeTo(0.0, 0.001));
    });
  });
}
