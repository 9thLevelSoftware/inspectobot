import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/common/widgets/section_group.dart';
import 'package:inspectobot/theme/theme.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(
      body: SingleChildScrollView(child: child),
    ),
  );
}

void main() {
  group('SectionGroup', () {
    testWidgets('renders title when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        const SectionGroup(
          title: 'Group Title',
          children: [Text('child')],
        ),
      ));

      expect(find.text('Group Title'), findsOneWidget);
    });

    testWidgets('renders all children', (tester) async {
      await tester.pumpWidget(_wrap(
        const SectionGroup(
          children: [
            Text('child 1'),
            Text('child 2'),
            Text('child 3'),
          ],
        ),
      ));

      expect(find.text('child 1'), findsOneWidget);
      expect(find.text('child 2'), findsOneWidget);
      expect(find.text('child 3'), findsOneWidget);
    });

    testWidgets('dividers appear between children when showDividers is true',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const SectionGroup(
          showDividers: true,
          children: [
            Text('a'),
            Text('b'),
            Text('c'),
          ],
        ),
      ));

      // 2 dividers between 3 children
      expect(find.byType(Divider), findsNWidgets(2));
    });

    testWidgets('SizedBox gaps appear when showDividers is false',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const SectionGroup(
          showDividers: false,
          children: [
            Text('a'),
            Text('b'),
            Text('c'),
          ],
        ),
      ));

      expect(find.byType(Divider), findsNothing);
      // 2 SizedBox gaps between 3 children (plus possible other SizedBoxes)
      // We check that at least 2 SizedBox widgets exist as separators
      final sizedBoxes = find.byType(SizedBox);
      expect(sizedBoxes, findsAtLeastNWidgets(2));
    });

    testWidgets('custom spacing is applied', (tester) async {
      const customSpacing = 24.0;

      await tester.pumpWidget(_wrap(
        const SectionGroup(
          showDividers: false,
          spacing: customSpacing,
          children: [
            Text('a'),
            Text('b'),
          ],
        ),
      ));

      // Find the SizedBox separator (not the title gap)
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      final spacerBox = sizedBoxes.where((sb) => sb.height == customSpacing);
      expect(spacerBox, isNotEmpty);
    });

    testWidgets('no divider after last child', (tester) async {
      await tester.pumpWidget(_wrap(
        const SectionGroup(
          showDividers: true,
          children: [
            Text('a'),
            Text('b'),
          ],
        ),
      ));

      // 1 divider between 2 children, not 2
      expect(find.byType(Divider), findsOneWidget);
    });
  });
}
