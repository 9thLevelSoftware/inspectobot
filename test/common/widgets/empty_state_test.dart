import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/common/widgets/empty_state.dart';
import 'package:inspectobot/theme/theme.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(body: child),
  );
}

void main() {
  group('EmptyState', () {
    testWidgets('displays message text', (tester) async {
      await tester.pumpWidget(_wrap(
        const EmptyState(message: 'No items yet'),
      ));

      expect(find.text('No items yet'), findsOneWidget);
    });

    testWidgets('displays icon when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        const EmptyState(
          message: 'Empty',
          icon: Icons.inbox,
        ),
      ));

      expect(find.byIcon(Icons.inbox), findsOneWidget);
    });

    testWidgets('does not display icon when not provided', (tester) async {
      await tester.pumpWidget(_wrap(
        const EmptyState(message: 'Empty'),
      ));

      // No Icon widget should be present
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('displays action button when label and callback provided',
        (tester) async {
      await tester.pumpWidget(_wrap(
        EmptyState(
          message: 'No data',
          actionLabel: 'Retry',
          onAction: () {},
        ),
      ));

      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('action button not shown when only label provided',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const EmptyState(
          message: 'No data',
          actionLabel: 'Retry',
        ),
      ));

      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('action callback fires when button tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(_wrap(
        EmptyState(
          message: 'Empty',
          actionLabel: 'Add',
          onAction: () => tapped = true,
        ),
      ));

      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
