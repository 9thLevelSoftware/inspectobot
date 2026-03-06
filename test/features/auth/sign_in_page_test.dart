import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:inspectobot/app/auth_notifier.dart';
import 'package:inspectobot/app/navigation_service.dart';
import 'package:inspectobot/app/routes.dart';
import 'package:inspectobot/app/service_locator.dart';
import 'package:inspectobot/features/auth/data/auth_repository.dart';
import 'package:inspectobot/features/auth/presentation/sign_in_page.dart';
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

  Widget buildSubject({
    _SignInFakeAuthGateway? gateway,
    SignInPageArgs? args,
  }) {
    final gw = gateway ?? _SignInFakeAuthGateway();
    return MaterialApp(
      theme: AppTheme.dark(),
      home: SignInPage(repository: AuthRepository(gw), args: args),
    );
  }

  testWidgets('renders sign-in form with email and password fields', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text('Sign In'), findsWidgets); // AppBar title + button
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('shows validation errors on empty submit', (tester) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(find.widgetWithText(FilledButton, 'Sign In'));
    await tester.pump();

    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(
      find.text('Password must be at least 8 characters.'),
      findsOneWidget,
    );
  });

  testWidgets('shows error message via ErrorBanner when AuthFailure is thrown', (
    tester,
  ) async {
    final gateway = _SignInFakeAuthGateway(
      signInError: AuthFailure(
        AuthFailureCode.invalidCredentials,
        'Email or password is incorrect.',
      ),
    );

    await tester.pumpWidget(buildSubject(gateway: gateway));

    // Fill valid email and password
    final textFields = find.byType(TextFormField);
    await tester.enterText(textFields.at(0), 'user@example.com');
    await tester.enterText(textFields.at(1), 'password123');
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, 'Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Email or password is incorrect.'), findsOneWidget);
  });

  testWidgets('shows info message when SignInPageArgs(infoMessage) is provided', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(args: const SignInPageArgs(infoMessage: 'Check your email')),
    );

    expect(find.text('Check your email'), findsOneWidget);
  });

  testWidgets('calls signInWithPassword on valid submit', (tester) async {
    final gateway = _SignInFakeAuthGateway();

    await tester.pumpWidget(buildSubject(gateway: gateway));

    final textFields = find.byType(TextFormField);
    await tester.enterText(textFields.at(0), 'user@example.com');
    await tester.enterText(textFields.at(1), 'password123');
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, 'Sign In'));
    await tester.pumpAndSettle();

    expect(gateway.signInCalls, 1);
  });

  testWidgets('Create account link is rendered', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text('Create account'), findsOneWidget);
  });

  testWidgets('Forgot password? link is rendered', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text('Forgot password?'), findsOneWidget);
  });

  testWidgets('Create account link navigates to sign-up route', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(find.text('Create account'));
    await tester.pump();

    verify(() => mockNav.go(AppRoutes.signUp)).called(1);
  });
}

class _SignInFakeAuthGateway implements AuthGateway {
  _SignInFakeAuthGateway({this.signInError});

  final AuthFailure? signInError;
  final _controller = StreamController<AuthStateChange>.broadcast();
  int signInCalls = 0;

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
  }) async {
    signInCalls += 1;
    if (signInError != null) {
      throw signInError!;
    }
  }

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
  }) async {}

  @override
  Future<void> updatePassword({required String newPassword}) async {}
}
