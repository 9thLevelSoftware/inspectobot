import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inspectobot/common/widgets/repeating_group_card.dart';
import 'package:inspectobot/theme/app_theme.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  group('RepeatingGroupCard', () {
    testWidgets('renders label with index number', (tester) async {
      await tester.pumpWidget(_wrap(
        const RepeatingGroupCard(
          label: 'Attempt',
          index: 3,
          child: Text('Child Content'),
        ),
      ));

      expect(find.text('Attempt 3'), findsOneWidget);
    });

    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(_wrap(
        const RepeatingGroupCard(
          label: 'Attempt',
          index: 1,
          child: Text('Some form fields here'),
        ),
      ));

      expect(find.text('Some form fields here'), findsOneWidget);
    });

    testWidgets('applies Card styling with Divider', (tester) async {
      await tester.pumpWidget(_wrap(
        const RepeatingGroupCard(
          label: 'Attempt',
          index: 2,
          child: Text('Content'),
        ),
      ));

      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
    });
  });
}
