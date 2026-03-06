import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/common/widgets/error_banner.dart';
import 'package:inspectobot/theme/theme.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(body: child),
  );
}

void main() {
  group('ErrorBanner', () {
    testWidgets('displays message text', (tester) async {
      await tester.pumpWidget(_wrap(
        const ErrorBanner(message: 'Something went wrong'),
      ));

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('error type shows error_outline icon', (tester) async {
      await tester.pumpWidget(_wrap(
        const ErrorBanner(
          message: 'Error',
          type: ErrorBannerType.error,
        ),
      ));

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('success type shows check_circle_outline icon', (tester) async {
      await tester.pumpWidget(_wrap(
        const ErrorBanner(
          message: 'Saved',
          type: ErrorBannerType.success,
        ),
      ));

      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('info type shows info_outline icon', (tester) async {
      await tester.pumpWidget(_wrap(
        const ErrorBanner(
          message: 'Note',
          type: ErrorBannerType.info,
        ),
      ));

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('warning type shows warning_amber_outlined icon',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const ErrorBanner(
          message: 'Caution',
          type: ErrorBannerType.warning,
        ),
      ));

      expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
    });

    testWidgets('defaults to error type', (tester) async {
      await tester.pumpWidget(_wrap(
        const ErrorBanner(message: 'Default'),
      ));

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });
}
