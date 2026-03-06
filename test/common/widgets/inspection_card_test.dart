import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/common/widgets/app_button.dart';
import 'package:inspectobot/common/widgets/inspection_card.dart';
import 'package:inspectobot/theme/theme.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(body: child),
  );
}

void main() {
  group('InspectionCard', () {
    testWidgets('displays clientName as title', (tester) async {
      await tester.pumpWidget(_wrap(
        InspectionCard(
          clientName: 'Acme Corp',
          address: '123 Main St',
        ),
      ));

      expect(find.text('Acme Corp'), findsOneWidget);
    });

    testWidgets('displays address in subtitle', (tester) async {
      await tester.pumpWidget(_wrap(
        InspectionCard(
          clientName: 'Acme Corp',
          address: '123 Main St',
        ),
      ));

      expect(find.text('123 Main St'), findsOneWidget);
    });

    testWidgets('shows resume step text when resumeStep is provided',
        (tester) async {
      await tester.pumpWidget(_wrap(
        InspectionCard(
          clientName: 'Acme Corp',
          address: '123 Main St',
          resumeStep: 2,
        ),
      ));

      // Step is 1-indexed in the display: resumeStep 2 -> "step 3"
      expect(find.textContaining('Resume at step 3'), findsOneWidget);
    });

    testWidgets('shows resume button when onResume is provided',
        (tester) async {
      await tester.pumpWidget(_wrap(
        InspectionCard(
          clientName: 'Acme Corp',
          address: '123 Main St',
          onResume: () {},
        ),
      ));

      // AppButton with variant filled renders a FilledButton
      expect(find.byType(AppButton), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.text('Resume'), findsOneWidget);
    });

    testWidgets('resume button uses custom label when resumeLabel is provided',
        (tester) async {
      await tester.pumpWidget(_wrap(
        InspectionCard(
          clientName: 'Acme Corp',
          address: '123 Main St',
          resumeLabel: 'Continue',
          onResume: () {},
        ),
      ));

      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Resume'), findsNothing);
    });

    testWidgets('does not show resume button when onResume is null',
        (tester) async {
      await tester.pumpWidget(_wrap(
        InspectionCard(
          clientName: 'Acme Corp',
          address: '123 Main St',
        ),
      ));

      expect(find.byType(AppButton), findsNothing);
    });

    testWidgets('onTap callback fires when card is tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(_wrap(
        InspectionCard(
          clientName: 'Acme Corp',
          address: '123 Main St',
          onTap: () => tapped = true,
        ),
      ));

      await tester.tap(find.byType(ListTile));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('isThreeLine is true when resumeStep is provided',
        (tester) async {
      await tester.pumpWidget(_wrap(
        InspectionCard(
          clientName: 'Acme Corp',
          address: '123 Main St',
          resumeStep: 0,
        ),
      ));

      final listTile = tester.widget<ListTile>(find.byType(ListTile));
      expect(listTile.isThreeLine, isTrue);
    });

    testWidgets('isThreeLine is false when resumeStep is null',
        (tester) async {
      await tester.pumpWidget(_wrap(
        InspectionCard(
          clientName: 'Acme Corp',
          address: '123 Main St',
        ),
      ));

      final listTile = tester.widget<ListTile>(find.byType(ListTile));
      expect(listTile.isThreeLine, isFalse);
    });
  });
}
