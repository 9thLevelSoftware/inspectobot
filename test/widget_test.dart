import 'package:flutter_test/flutter_test.dart';

import 'package:inspectobot/app/app.dart';
import 'package:inspectobot/app/routes.dart';

void main() {
  testWidgets('auth gate starts signed-out user in auth flow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const InspectoBotApp());

    expect(find.text('InspectoBot Access'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('auth routes navigate sign-in to sign-up and forgot flows', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const InspectoBotApp());

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    expect(find.text('Forgot password?'), findsOneWidget);

    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(find.text('Create Account'), findsWidgets);

    await tester.tap(find.text('Already have an account? Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Forgot password?'), findsOneWidget);

    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    expect(find.text('Send Recovery Link'), findsOneWidget);
  });

  test('recovery callback URI matches reset-password deep-link contract', () {
    expect(AppRoutes.recoveryCallbackUri, 'inspectobot://auth/reset-password');
  });
}
