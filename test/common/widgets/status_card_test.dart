import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/common/widgets/status_card.dart';
import 'package:inspectobot/theme/theme.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(body: child),
  );
}

void main() {
  group('StatusCard', () {
    testWidgets('displays title text', (tester) async {
      await tester.pumpWidget(_wrap(
        const StatusCard(title: 'Inspection A'),
      ));

      expect(find.text('Inspection A'), findsOneWidget);
    });

    testWidgets('displays subtitle when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        const StatusCard(title: 'Item', subtitle: 'Details here'),
      ));

      expect(find.text('Details here'), findsOneWidget);
    });

    testWidgets('complete status shows check_circle icon', (tester) async {
      await tester.pumpWidget(_wrap(
        const StatusCard(title: 'Done', status: StatusType.complete),
      ));

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('incomplete status shows warning_amber icon', (tester) async {
      await tester.pumpWidget(_wrap(
        const StatusCard(title: 'Pending', status: StatusType.incomplete),
      ));

      expect(find.byIcon(Icons.warning_amber), findsOneWidget);
    });

    testWidgets('error status shows error_outline icon', (tester) async {
      await tester.pumpWidget(_wrap(
        const StatusCard(title: 'Failed', status: StatusType.error),
      ));

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('none status shows no trailing icon', (tester) async {
      await tester.pumpWidget(_wrap(
        const StatusCard(title: 'Neutral', status: StatusType.none),
      ));

      // No icon should be rendered in trailing position
      final listTile = tester.widget<ListTile>(find.byType(ListTile));
      expect(listTile.trailing, isNull);
    });

    testWidgets('onTap callback fires', (tester) async {
      var tapped = false;

      await tester.pumpWidget(_wrap(
        StatusCard(title: 'Tappable', onTap: () => tapped = true),
      ));

      await tester.tap(find.byType(ListTile));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('custom trailing overrides status icon', (tester) async {
      await tester.pumpWidget(_wrap(
        const StatusCard(
          title: 'Custom',
          status: StatusType.complete,
          trailing: Icon(Icons.arrow_forward),
        ),
      ));

      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });
  });
}
