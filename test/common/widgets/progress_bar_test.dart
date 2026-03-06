import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/common/widgets/progress_bar.dart';
import 'package:inspectobot/theme/theme.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('AppProgressBar', () {
    testWidgets('renders LinearProgressIndicator by default', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppProgressBar(),
      ));

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('renders CircularProgressIndicator when isCircular is true',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const AppProgressBar(isCircular: true),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('indeterminate when value is null', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppProgressBar(),
      ));

      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, isNull);
    });

    testWidgets('determinate when value is provided', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppProgressBar(value: 0.5),
      ));

      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, 0.5);
    });

    testWidgets('circular respects size parameter', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppProgressBar(isCircular: true, size: 32),
      ));

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, 32.0);
      expect(sizedBox.height, 32.0);
    });

    testWidgets('linear respects size parameter for height', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppProgressBar(size: 8),
      ));

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.height, 8.0);
    });

    testWidgets('circular determinate with value', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppProgressBar(isCircular: true, value: 0.75),
      ));

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.value, 0.75);
    });
  });
}
