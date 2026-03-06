import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/common/widgets/snackbar_helper.dart';
import 'package:inspectobot/theme/theme.dart';

Widget _wrap(Widget Function(BuildContext) builder) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: builder(context),
        ),
      ),
    ),
  );
}

void main() {
  group('AppSnackBar', () {
    testWidgets('show displays a SnackBar with message', (tester) async {
      await tester.pumpWidget(_wrap(
        (context) => FilledButton(
          onPressed: () => AppSnackBar.show(context, 'Hello'),
          child: const Text('Trigger'),
        ),
      ));

      await tester.tap(find.text('Trigger'));
      await tester.pumpAndSettle();

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('error convenience method shows SnackBar', (tester) async {
      await tester.pumpWidget(_wrap(
        (context) => FilledButton(
          onPressed: () => AppSnackBar.error(context, 'Failed'),
          child: const Text('Trigger'),
        ),
      ));

      await tester.tap(find.text('Trigger'));
      await tester.pumpAndSettle();

      expect(find.text('Failed'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('success convenience method shows SnackBar', (tester) async {
      await tester.pumpWidget(_wrap(
        (context) => FilledButton(
          onPressed: () => AppSnackBar.success(context, 'Saved'),
          child: const Text('Trigger'),
        ),
      ));

      await tester.tap(find.text('Trigger'));
      await tester.pumpAndSettle();

      expect(find.text('Saved'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('info convenience method shows SnackBar', (tester) async {
      await tester.pumpWidget(_wrap(
        (context) => FilledButton(
          onPressed: () => AppSnackBar.info(context, 'Note'),
          child: const Text('Trigger'),
        ),
      ));

      await tester.tap(find.text('Trigger'));
      await tester.pumpAndSettle();

      expect(find.text('Note'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('warning convenience method shows SnackBar', (tester) async {
      await tester.pumpWidget(_wrap(
        (context) => FilledButton(
          onPressed: () => AppSnackBar.warning(context, 'Caution'),
          child: const Text('Trigger'),
        ),
      ));

      await tester.tap(find.text('Trigger'));
      await tester.pumpAndSettle();

      expect(find.text('Caution'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
    });

    testWidgets('hides current SnackBar before showing new one',
        (tester) async {
      await tester.pumpWidget(_wrap(
        (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton(
              onPressed: () => AppSnackBar.info(context, 'Message A'),
              child: const Text('Btn1'),
            ),
            FilledButton(
              onPressed: () => AppSnackBar.info(context, 'Message B'),
              child: const Text('Btn2'),
            ),
          ],
        ),
      ));

      await tester.tap(find.text('Btn1'));
      await tester.pumpAndSettle();
      expect(find.text('Message A'), findsOneWidget);

      await tester.tap(find.text('Btn2'));
      await tester.pumpAndSettle();
      expect(find.text('Message B'), findsOneWidget);
    });
  });
}
