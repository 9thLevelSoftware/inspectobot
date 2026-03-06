import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:inspectobot/app/auth_notifier.dart';
import 'package:inspectobot/app/navigation_service.dart';
import 'package:inspectobot/app/routes.dart';
import 'package:inspectobot/app/service_locator.dart';
import 'package:inspectobot/features/auth/data/auth_repository.dart';
import 'package:inspectobot/features/auth/presentation/sign_up_page.dart';
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

  Widget buildSubject({_SignUpFakeAuthGateway? gateway}) {
    final gw = gateway ?? _SignUpFakeAuthGateway();
    return MaterialApp(
      theme: AppTheme.dark(),
      home: SignUpPage(repository: AuthRepository(gw)),
    );
  }

  testWidgets('renders sign-up form with email and password fields', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text('Create Account'), findsWidgets); // AppBar + button
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('shows validation errors on empty submit', (tester) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(find.widgetWithText(FilledButton, 'Create Account'));
    await tester.pump();

    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(
      find.text('Password must be at least 8 characters.'),
      findsOneWidget,
    );
  });

  testWidgets('shows error message when AuthFailure is thrown', (
    tester,
  ) async {
    final gateway = _SignUpFakeAuthGateway(
      signUpError: AuthFailure(
        AuthFailureCode.emailInUse,
        'An account already exists for this email.',
      ),
    );

    await tester.pumpWidget(buildSubject(gateway: gateway));

    final textFields = find.byType(TextFormField);
    await tester.enterText(textFields.at(0), 'user@example.com');
    await tester.enterText(textFields.at(1), 'password123');
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, 'Create Account'));
    await tester.pumpAndSettle();

    expect(
      find.text('An account already exists for this email.'),
      findsOneWidget,
    );
  });

  testWidgets('calls signUp on valid submit', (tester) async {
    final gateway = _SignUpFakeAuthGateway();

    await tester.pumpWidget(buildSubject(gateway: gateway));

    final textFields = find.byType(TextFormField);
    await tester.enterText(textFields.at(0), 'user@example.com');
    await tester.enterText(textFields.at(1), 'password123');
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, 'Create Account'));
    await tester.pumpAndSettle();

    expect(gateway.signUpCalls, 1);
  });

  testWidgets('Already have an account link is rendered', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(
      find.text('Already have an account? Sign in'),
      findsOneWidget,
    );
  });

  testWidgets('Already have an account link uses replace navigation', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(find.text('Already have an account? Sign in'));
    await tester.pump();

    verify(() => mockNav.replace(AppRoutes.signIn)).called(1);
  });
}

class _SignUpFakeAuthGateway implements AuthGateway {
  _SignUpFakeAuthGateway({this.signUpError});

  final AuthFailure? signUpError;
  final _controller = StreamController<AuthStateChange>.broadcast();
  int signUpCalls = 0;

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
  }) async {
    signUpCalls += 1;
    if (signUpError != null) {
      throw signUpError!;
    }
  }

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
