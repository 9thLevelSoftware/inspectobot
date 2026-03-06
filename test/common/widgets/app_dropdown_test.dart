import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/common/widgets/app_dropdown.dart';
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

  group('AppDropdown', () {
    final items = [
      const DropdownMenuItem(value: 'a', child: Text('Alpha')),
      const DropdownMenuItem(value: 'b', child: Text('Beta')),
      const DropdownMenuItem(value: 'c', child: Text('Gamma')),
    ];

    testWidgets('dropdown items are displayed', (tester) async {
      await tester.pumpWidget(
        buildApp(
          child: AppDropdown<String>(
            items: items,
            label: 'Pick one',
            onChanged: (_) {},
          ),
        ),
      );

      // Open the dropdown
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      expect(find.text('Alpha'), findsWidgets);
      expect(find.text('Beta'), findsWidgets);
      expect(find.text('Gamma'), findsWidgets);
    });

    testWidgets('selection triggers onChanged', (tester) async {
      String? selected;

      await tester.pumpWidget(
        buildApp(
          child: AppDropdown<String>(
            items: items,
            label: 'Pick one',
            onChanged: (value) => selected = value,
          ),
        ),
      );

      // Open dropdown
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Select "Beta"
      await tester.tap(find.text('Beta').last);
      await tester.pumpAndSettle();

      expect(selected, 'b');
    });

    testWidgets('label is displayed', (tester) async {
      await tester.pumpWidget(
        buildApp(
          child: AppDropdown<String>(
            items: items,
            label: 'Category',
          ),
        ),
      );

      expect(find.text('Category'), findsOneWidget);
    });
  });
}
