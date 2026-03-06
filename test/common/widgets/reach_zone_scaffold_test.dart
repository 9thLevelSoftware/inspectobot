import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/common/widgets/reach_zone_scaffold.dart';
import 'package:inspectobot/theme/theme.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(body: child),
  );
}

void main() {
  group('ReachZoneScaffold', () {
    testWidgets('renders body and stickyBottom children', (tester) async {
      await tester.pumpWidget(_wrap(
        const ReachZoneScaffold(
          body: Text('body content'),
          stickyBottom: Text('sticky content'),
        ),
      ));

      expect(find.text('body content'), findsOneWidget);
      expect(find.text('sticky content'), findsOneWidget);
    });

    testWidgets('divider is present when showDivider is true', (tester) async {
      await tester.pumpWidget(_wrap(
        const ReachZoneScaffold(
          body: Text('body'),
          stickyBottom: Text('sticky'),
          showDivider: true,
        ),
      ));

      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('divider is absent when showDivider is false', (tester) async {
      await tester.pumpWidget(_wrap(
        const ReachZoneScaffold(
          body: Text('body'),
          stickyBottom: Text('sticky'),
          showDivider: false,
        ),
      ));

      expect(find.byType(Divider), findsNothing);
    });

    testWidgets('custom bottomPadding is applied', (tester) async {
      const customPadding = EdgeInsets.all(32);

      await tester.pumpWidget(_wrap(
        const ReachZoneScaffold(
          body: Text('body'),
          stickyBottom: Text('sticky'),
          bottomPadding: customPadding,
        ),
      ));

      final paddingFinder = find.ancestor(
        of: find.byType(SafeArea),
        matching: find.byType(Padding),
      );

      // The immediate Padding ancestor of SafeArea is our custom padding
      final padding = tester.widget<Padding>(paddingFinder.first);
      expect(padding.padding, customPadding);
    });

    testWidgets('SafeArea wraps stickyBottom', (tester) async {
      await tester.pumpWidget(_wrap(
        const ReachZoneScaffold(
          body: Text('body'),
          stickyBottom: Text('sticky'),
        ),
      ));

      final safeArea = tester.widget<SafeArea>(find.byType(SafeArea).last);
      expect(safeArea.top, isFalse);

      // stickyBottom is a descendant of SafeArea
      expect(
        find.descendant(
          of: find.byType(SafeArea).last,
          matching: find.text('sticky'),
        ),
        findsOneWidget,
      );
    });
  });
}
