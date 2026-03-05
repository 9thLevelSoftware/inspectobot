import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/auth/data/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('resetPasswordForEmail requires redirect URL', () async {
    final repository = AuthRepository(_FakeAuthGateway());

    await expectLater(
      () => repository.resetPasswordForEmail(
        email: 'inspector@example.com',
        redirectTo: '',
      ),
      throwsA(isA<AuthFailure>()),
    );
  });

  test('maps invalid credentials into a safe auth message', () async {
    final repository = AuthRepository(
      _FakeAuthGateway(
        signInError: const AuthException('Invalid login credentials'),
      ),
    );

    await expectLater(
      () => repository.signInWithPassword(
        email: 'bad@example.com',
        password: 'bad-password',
      ),
      throwsA(
        isA<AuthFailure>().having(
          (error) => error.code,
          'code',
          AuthFailureCode.invalidCredentials,
        ),
      ),
    );
  });

  test('sign-in and sign-out state changes update repository stream', () async {
    final gateway = _FakeAuthGateway();
    final repository = AuthRepository(gateway);
    final events = <AuthSession?>[];
    final subscription = repository.authStateChanges.listen(events.add);

    await repository.signInWithPassword(
      email: 'inspector@example.com',
      password: 'Password123!',
    );
    await repository.signOut();
    await Future<void>.delayed(Duration.zero);

    expect(events.first?.userId, 'fake-user');
    expect(events.first?.organizationId, 'fake-org');
    expect(events.last, isNull);

    await subscription.cancel();
  });

  test('resolveCurrentSession returns tenant-aware session context', () async {
    final gateway = _FakeAuthGateway();
    final repository = AuthRepository(gateway);

    await repository.signInWithPassword(
      email: 'inspector@example.com',
      password: 'Password123!',
    );
    final session = await repository.resolveCurrentSession();

    expect(session?.userId, 'fake-user');
    expect(session?.organizationId, 'fake-org');
    expect(session?.tenantContext?.organizationId, 'fake-org');
  });
}

class _FakeAuthGateway implements AuthGateway {
  _FakeAuthGateway({this.signInError});

  final AuthException? signInError;
  final StreamController<AuthSession?> _controller =
      StreamController<AuthSession?>.broadcast();
  AuthSession? _session;

  @override
  AuthSession? get currentSession => _session;

  @override
  Stream<AuthSession?> get onAuthStateChange => _controller.stream;

  @override
  Future<AuthSession?> resolveCurrentSession() async => _session;

  @override
  Future<void> resetPasswordForEmail({
    required String email,
    required String redirectTo,
  }) async {}

  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    if (signInError != null) {
      throw signInError!;
    }
    _session = const AuthSession(
      userId: 'fake-user',
      organizationId: 'fake-org',
    );
    _controller.add(_session);
  }

  @override
  Future<void> signOut() async {
    _session = null;
    _controller.add(null);
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> updatePassword({required String newPassword}) async {}
}
