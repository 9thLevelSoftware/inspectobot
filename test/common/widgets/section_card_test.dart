import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/common/widgets/section_card.dart';
import 'package:inspectobot/theme/theme.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(body: child),
  );
}

void main() {
  group('SectionCard', () {
    testWidgets('renders a Card widget', (tester) async {
      await tester.pumpWidget(_wrap(
        const SectionCard(child: Text('content')),
      ));

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('displays title when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        const SectionCard(title: 'My Section', child: Text('body')),
      ));

      expect(find.text('My Section'), findsOneWidget);
      expect(find.text('body'), findsOneWidget);
    });

    testWidgets('child is rendered inside the Card', (tester) async {
      await tester.pumpWidget(_wrap(
        const SectionCard(child: Text('inside')),
      ));

      final card = find.byType(Card);
      final text = find.text('inside');

      expect(card, findsOneWidget);
      expect(text, findsOneWidget);

      // Verify text is a descendant of card
      expect(
        find.descendant(of: card, matching: text),
        findsOneWidget,
      );
    });

    testWidgets('applies custom padding when provided', (tester) async {
      const customPadding = EdgeInsets.all(32);

      await tester.pumpWidget(_wrap(
        const SectionCard(
          padding: customPadding,
          child: Text('padded'),
        ),
      ));

      // Find the Padding widget that wraps our content text
      final paddingFinder = find.ancestor(
        of: find.text('padded'),
        matching: find.byType(Padding),
      );

      // The first ancestor Padding of the text is our custom padding
      final padding = tester.widget<Padding>(paddingFinder.first);
      expect(padding.padding, customPadding);
    });

    testWidgets('uses default card padding when none provided', (tester) async {
      await tester.pumpWidget(_wrap(
        const SectionCard(child: Text('default')),
      ));

      final paddingFinder = find.ancestor(
        of: find.text('default'),
        matching: find.byType(Padding),
      );

      final padding = tester.widget<Padding>(paddingFinder.first);
      expect(padding.padding, AppEdgeInsets.cardPadding);
    });

    testWidgets('omits Column when title is null', (tester) async {
      await tester.pumpWidget(_wrap(
        const SectionCard(child: Text('no title')),
      ));

      expect(
        find.descendant(of: find.byType(Card), matching: find.byType(Column)),
        findsNothing,
      );
    });
  });
}
