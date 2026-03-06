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

    testWidgets('density=compact uses compact padding', (tester) async {
      await tester.pumpWidget(_wrap(
        const SectionCard(
          density: SectionCardDensity.compact,
          child: Text('compact'),
        ),
      ));

      final paddingFinder = find.ancestor(
        of: find.text('compact'),
        matching: find.byType(Padding),
      );

      final padding = tester.widget<Padding>(paddingFinder.first);
      expect(padding.padding, AppEdgeInsets.cardPaddingCompact);
    });

    testWidgets('density=spacious uses 24dp padding', (tester) async {
      await tester.pumpWidget(_wrap(
        const SectionCard(
          density: SectionCardDensity.spacious,
          child: Text('spacious'),
        ),
      ));

      final paddingFinder = find.ancestor(
        of: find.text('spacious'),
        matching: find.byType(Padding),
      );

      final padding = tester.widget<Padding>(paddingFinder.first);
      expect(padding.padding, const EdgeInsets.all(24.0));
    });

    testWidgets('leadingBadge renders before title', (tester) async {
      await tester.pumpWidget(_wrap(
        const SectionCard(
          title: 'Section',
          leadingBadge: Icon(Icons.check_circle, key: Key('badge-icon')),
          child: Text('body'),
        ),
      ));

      // Badge icon is present
      expect(find.byKey(const Key('badge-icon')), findsOneWidget);
      // Title is still present
      expect(find.text('Section'), findsOneWidget);
      // Both are inside a Row
      expect(
        find.descendant(
          of: find.byType(Row),
          matching: find.byKey(const Key('badge-icon')),
        ),
        findsOneWidget,
      );
    });
  });
}
