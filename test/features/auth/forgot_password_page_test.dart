import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:inspectobot/app/auth_notifier.dart';
import 'package:inspectobot/app/navigation_service.dart';
import 'package:inspectobot/app/routes.dart';
import 'package:inspectobot/app/service_locator.dart';
import 'package:inspectobot/features/auth/data/auth_repository.dart';
import 'package:inspectobot/features/auth/presentation/forgot_password_page.dart';
import 'package:inspectobot/theme/app_theme.dart';

class _MockNavigationService extends Mock implements NavigationService {}

class _MockAuthNotifier extends Mock implements AuthNotifier {}

void main() {
  late _MockNavigationService mockNav;
  late _MockAuthNotifier mockAuthNotifier;

  setUp(() {
    mockNav = _MockNavigationService();
    mockAuthNotifier = _MockAuthNotifier();
    setupTestServiceLocator(
      navigationService: mockNav,
      authNotifier: mockAuthNotifier,
    );
  });

  tearDown(() async {
    await resetServiceLocator();
  });

  Widget buildSubject({_ForgotFakeAuthGateway? gateway}) {
    final gw = gateway ?? _ForgotFakeAuthGateway();
    return MaterialApp(
      theme: AppTheme.dark(),
      home: ForgotPasswordPage(repository: AuthRepository(gw)),
    );
  }

  testWidgets('renders forgot-password form with email field', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text('Forgot Password'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Send Recovery Link'), findsOneWidget);
  });

  testWidgets('shows validation error on empty email submit', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(find.text('Send Recovery Link'));
    await tester.pump();

    expect(find.text('Enter a valid email address.'), findsOneWidget);
  });

  testWidgets('shows success message on successful submit', (tester) async {
    final gateway = _ForgotFakeAuthGateway();

    await tester.pumpWidget(buildSubject(gateway: gateway));

    await tester.enterText(
      find.byType(TextFormField),
      'user@example.com',
    );
    await tester.tap(find.text('Send Recovery Link'));
    await tester.pumpAndSettle();

    expect(find.text('Password reset email sent.'), findsOneWidget);
  });

  testWidgets('shows error message when AuthFailure is thrown', (
    tester,
  ) async {
    final gateway = _ForgotFakeAuthGateway(
      resetError: AuthFailure(
        AuthFailureCode.invalidEmail,
        'Please enter a valid email address.',
      ),
    );

    await tester.pumpWidget(buildSubject(gateway: gateway));

    await tester.enterText(
      find.byType(TextFormField),
      'user@example.com',
    );
    await tester.tap(find.text('Send Recovery Link'));
    await tester.pumpAndSettle();

    expect(
      find.text('Please enter a valid email address.'),
      findsOneWidget,
    );
  });

  testWidgets('calls resetPasswordForEmail with correct email', (
    tester,
  ) async {
    final gateway = _ForgotFakeAuthGateway();

    await tester.pumpWidget(buildSubject(gateway: gateway));

    await tester.enterText(
      find.byType(TextFormField),
      'user@example.com',
    );
    await tester.tap(find.text('Send Recovery Link'));
    await tester.pumpAndSettle();

    expect(gateway.resetCalls, 1);
    expect(gateway.lastEmail, 'user@example.com');
  });

  testWidgets('helper text is displayed', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(
      find.text(
        'Check your email for the recovery link before proceeding.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('recovery link action is rendered', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(
      find.text('Already have a recovery link? Reset password'),
      findsOneWidget,
    );
  });

  testWidgets('recovery link navigates to reset-password route', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(
      find.text('Already have a recovery link? Reset password'),
    );
    await tester.pump();

    verify(() => mockNav.go(AppRoutes.resetPassword)).called(1);
  });
}

class _ForgotFakeAuthGateway implements AuthGateway {
  _ForgotFakeAuthGateway({this.resetError});

  final AuthFailure? resetError;
  final _controller = StreamController<AuthStateChange>.broadcast();
  int resetCalls = 0;
  String? lastEmail;

  @override
  AuthSession? get currentSession => null;

  @override
  Stream<AuthStateChange> get onAuthStateChange => _controller.stream;

  @override
  Future<AuthSession?> resolveCurrentSession() async => null;

  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signUp({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> resetPasswordForEmail({
    required String email,
    required String redirectTo,
  }) async {
    resetCalls += 1;
    lastEmail = email;
    if (resetError != null) {
      throw resetError!;
    }
  }

  @override
  Future<void> updatePassword({required String newPassword}) async {}
}
