import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:inspectobot/app/navigation_service.dart';
import 'package:inspectobot/app/routes.dart';
import 'package:inspectobot/app/service_locator.dart';
import 'package:inspectobot/features/auth/data/auth_repository.dart';
import 'package:inspectobot/features/auth/presentation/reset_password_page.dart';
import 'package:inspectobot/features/auth/presentation/sign_in_page.dart';

class _MockNavigationService extends Mock implements NavigationService {}

void main() {
  late _MockNavigationService mockNav;

  setUp(() {
    mockNav = _MockNavigationService();
    setupTestServiceLocator(navigationService: mockNav);
  });

  tearDown(() async {
    await resetServiceLocator();
  });

  testWidgets('successful update navigates to sign-in with success message', (
    tester,
  ) async {
    final gateway = _ResetFakeAuthGateway();
    final repository = AuthRepository(gateway);

    await tester.pumpWidget(
      MaterialApp(home: ResetPasswordPage(repository: repository)),
    );

    await tester.enterText(find.byType(TextFormField), 'Password123!');
    await tester.tap(find.text('Update Password'));
    await tester.pump();
    await tester.tap(find.text('Updating...'));
    await tester.pump();

    expect(gateway.updatePasswordCalls, 1);

    gateway.completeUpdate();
    await tester.pumpAndSettle();

    verify(
      () => mockNav.go(
        AppRoutes.signIn,
        extra: any(
          named: 'extra',
          that: isA<SignInPageArgs>().having(
            (a) => a.infoMessage,
            'infoMessage',
            AppRoutes.resetPasswordSuccessMessage,
          ),
        ),
      ),
    ).called(1);
  });

  testWidgets('failed update shows auth failure and stays on reset page', (
    tester,
  ) async {
    final gateway = _ResetFakeAuthGateway(
      updatePasswordError: AuthFailure(
        AuthFailureCode.weakPassword,
        'Password must be stronger.',
      ),
    );
    final repository = AuthRepository(gateway);

    await tester.pumpWidget(
      MaterialApp(home: ResetPasswordPage(repository: repository)),
    );

    await tester.enterText(find.byType(TextFormField), 'Password123!');
    await tester.tap(find.text('Update Password'));
    await tester.pumpAndSettle();

    expect(find.text('Password must be stronger.'), findsOneWidget);
    expect(find.text('Update Password'), findsOneWidget);
    verifyNever(() => mockNav.go(any(), extra: any(named: 'extra')));
  });
}

class _ResetFakeAuthGateway implements AuthGateway {
  _ResetFakeAuthGateway({this.updatePasswordError});

  final AuthFailure? updatePasswordError;
  final _controller = StreamController<AuthStateChange>.broadcast();
  final Completer<void> _updateCompleter = Completer<void>();
  int updatePasswordCalls = 0;

  void completeUpdate() {
    if (!_updateCompleter.isCompleted) {
      _updateCompleter.complete();
    }
  }

  @override
  AuthSession? get currentSession => null;

  @override
  Stream<AuthStateChange> get onAuthStateChange => _controller.stream;

  @override
  Future<AuthSession?> resolveCurrentSession() async => null;

  @override
  Future<void> resetPasswordForEmail({
    required String email,
    required String redirectTo,
  }) async {}

  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> signUp({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> updatePassword({required String newPassword}) async {
    updatePasswordCalls += 1;
    if (updatePasswordError != null) {
      throw updatePasswordError!;
    }
    return _updateCompleter.future;
  }
}
