import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/common/widgets/app_date_picker.dart';
import 'package:inspectobot/theme/app_theme.dart';

void main() {
  Widget buildApp({required Widget child}) {
    return MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(
        body: Form(child: child),
      ),
    );
  }

  group('AppDatePicker', () {
    testWidgets('label is displayed', (tester) async {
      await tester.pumpWidget(
        buildApp(child: const AppDatePicker(label: 'Start Date')),
      );

      expect(find.text('Start Date'), findsOneWidget);
    });

    testWidgets('calendar icon is present', (tester) async {
      await tester.pumpWidget(
        buildApp(child: const AppDatePicker(label: 'Date')),
      );

      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('tapping the field opens date picker dialog', (tester) async {
      await tester.pumpWidget(
        buildApp(
          child: AppDatePicker(
            label: 'Date',
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
          ),
        ),
      );

      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();

      // The date picker dialog should be shown
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('displays formatted date when value provided', (tester) async {
      final date = DateTime(2025, 3, 15);

      await tester.pumpWidget(
        buildApp(child: AppDatePicker(label: 'Date', value: date)),
      );

      expect(find.text('3/15/2025'), findsOneWidget);
    });
  });
}
