import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/common/widgets/section_header.dart';
import 'package:inspectobot/theme/theme.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(body: child),
  );
}

void main() {
  group('SectionHeader', () {
    testWidgets('displays title text', (tester) async {
      await tester.pumpWidget(_wrap(
        const SectionHeader(title: 'General Info'),
      ));

      expect(find.text('General Info'), findsOneWidget);
    });

    testWidgets('uses sectionHeader text style from tokens', (tester) async {
      await tester.pumpWidget(_wrap(
        const SectionHeader(title: 'Details'),
      ));

      final text = tester.widget<Text>(find.text('Details'));
      expect(text.style, isNotNull);
      // sectionHeader style is w700, 16sp
      expect(text.style!.fontWeight, FontWeight.w700);
      expect(text.style!.fontSize, 16);
    });

    testWidgets('trailing widget is shown when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        SectionHeader(
          title: 'Photos',
          trailing: TextButton(
            onPressed: () {},
            child: const Text('View All'),
          ),
        ),
      ));

      expect(find.text('Photos'), findsOneWidget);
      expect(find.text('View All'), findsOneWidget);
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('no Row when trailing is absent', (tester) async {
      await tester.pumpWidget(_wrap(
        const SectionHeader(title: 'Solo'),
      ));

      expect(find.text('Solo'), findsOneWidget);
      // Should not have a Row -- just a Padding > Text
      expect(find.byType(Row), findsNothing);
    });

    testWidgets('wrapped in Padding with sectionGap', (tester) async {
      await tester.pumpWidget(_wrap(
        const SectionHeader(title: 'Spaced'),
      ));

      final padding = tester.widget<Padding>(find.byType(Padding).first);
      expect(padding.padding, equals(AppEdgeInsets.sectionGap));
    });
  });
}
