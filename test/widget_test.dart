import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:inspectobot/app/app.dart';
import 'package:inspectobot/app/routes.dart';
import 'package:inspectobot/features/auth/presentation/sign_in_page.dart';
import 'package:inspectobot/features/auth/presentation/sign_up_page.dart';
import 'package:inspectobot/features/auth/presentation/forgot_password_page.dart';

/// Creates a test router with auth pages (no auth redirect, no GetIt).
GoRouter _createTestRouter({String initialLocation = '/auth/sign-in'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
    ],
  );
}

void main() {
  testWidgets('sign-in page renders when unauthenticated', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(InspectoBotApp(router: _createTestRouter()));
    await tester.pumpAndSettle();

    // SignInPage shows its AppBar title and sign-in button
    expect(find.text('Sign In'), findsWidgets);
    expect(find.text('Forgot password?'), findsOneWidget);
  });

  testWidgets('sign-up page renders via GoRouter navigation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      InspectoBotApp(router: _createTestRouter(initialLocation: AppRoutes.signUp)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Create Account'), findsWidgets);
  });

  testWidgets('forgot-password page renders via GoRouter navigation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      InspectoBotApp(
        router: _createTestRouter(initialLocation: AppRoutes.forgotPassword),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Send Recovery Link'), findsOneWidget);
  });

  test('recovery callback URI matches reset-password deep-link contract', () {
    expect(AppRoutes.recoveryCallbackUri, 'inspectobot://auth/reset-password');
  });
}
