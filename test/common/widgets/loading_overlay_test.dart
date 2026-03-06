import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/common/widgets/loading_overlay.dart';
import 'package:inspectobot/theme/theme.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(
      body: SizedBox.expand(child: child),
    ),
  );
}

void main() {
  group('LoadingOverlay', () {
    testWidgets('child is visible', (tester) async {
      await tester.pumpWidget(_wrap(
        const LoadingOverlay(
          isLoading: false,
          child: Text('Content'),
        ),
      ));

      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('overlay appears when isLoading is true', (tester) async {
      await tester.pumpWidget(_wrap(
        const LoadingOverlay(
          isLoading: true,
          child: Text('Content'),
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Verify our scrim ColoredBox exists as a descendant of LoadingOverlay
      expect(
        find.descendant(
          of: find.byType(LoadingOverlay),
          matching: find.byType(ColoredBox),
        ),
        findsOneWidget,
      );
    });

    testWidgets('overlay hidden when isLoading is false', (tester) async {
      await tester.pumpWidget(_wrap(
        const LoadingOverlay(
          isLoading: false,
          child: Text('Content'),
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('message displayed when loading with message', (tester) async {
      await tester.pumpWidget(_wrap(
        const LoadingOverlay(
          isLoading: true,
          message: 'Please wait...',
          child: Text('Content'),
        ),
      ));

      expect(find.text('Please wait...'), findsOneWidget);
    });

    testWidgets('message not displayed when not loading', (tester) async {
      await tester.pumpWidget(_wrap(
        const LoadingOverlay(
          isLoading: false,
          message: 'Please wait...',
          child: Text('Content'),
        ),
      ));

      expect(find.text('Please wait...'), findsNothing);
    });

    testWidgets('child interaction blocked during loading', (tester) async {
      var tapped = false;

      await tester.pumpWidget(_wrap(
        LoadingOverlay(
          isLoading: true,
          child: GestureDetector(
            onTap: () => tapped = true,
            child: const Text('Tap me'),
          ),
        ),
      ));

      await tester.tap(find.text('Tap me'), warnIfMissed: false);
      await tester.pump();

      expect(tapped, isFalse);
    });
  });
}
