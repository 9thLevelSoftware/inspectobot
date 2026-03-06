import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/common/widgets/app_checkbox_tile.dart';
import 'package:inspectobot/theme/app_theme.dart';

void main() {
  Widget buildApp({required Widget child}) {
    return MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(body: child),
    );
  }

  group('AppCheckboxTile', () {
    testWidgets('renders unchecked by default when value is false',
        (tester) async {
      await tester.pumpWidget(
        buildApp(
          child: AppCheckboxTile(
            title: 'Accept terms',
            value: false,
            onChanged: (_) {},
          ),
        ),
      );

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isFalse);
    });

    testWidgets('tapping toggles value via onChanged callback',
        (tester) async {
      bool? changedValue;

      await tester.pumpWidget(
        buildApp(
          child: AppCheckboxTile(
            title: 'Accept terms',
            value: false,
            onChanged: (value) => changedValue = value,
          ),
        ),
      );

      await tester.tap(find.byType(CheckboxListTile));
      expect(changedValue, isTrue);
    });

    testWidgets('title text is displayed', (tester) async {
      await tester.pumpWidget(
        buildApp(
          child: AppCheckboxTile(
            title: 'Notifications',
            value: false,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('subtitle is displayed when provided', (tester) async {
      await tester.pumpWidget(
        buildApp(
          child: AppCheckboxTile(
            title: 'Notifications',
            subtitle: 'Receive push alerts',
            value: false,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Receive push alerts'), findsOneWidget);
    });

    testWidgets('subtitle is absent when null', (tester) async {
      await tester.pumpWidget(
        buildApp(
          child: AppCheckboxTile(
            title: 'Notifications',
            value: false,
            onChanged: (_) {},
          ),
        ),
      );

      // Only one Text widget for title, no subtitle
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });
  });
}
