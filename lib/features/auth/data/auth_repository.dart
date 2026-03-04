import 'dart:async';

import 'package:inspectobot/data/supabase/supabase_client_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthFailureCode {
  invalidCredentials,
  emailInUse,
  weakPassword,
  invalidEmail,
  missingRecoveryRedirect,
  unknown,
}

class AuthFailure implements Exception {
  AuthFailure(this.code, this.message);

  final AuthFailureCode code;
  final String message;

  @override
  String toString() => 'AuthFailure($code): $message';
}

class AuthSession {
  const AuthSession({required this.userId});

  final String userId;
}

abstract class AuthGateway {
  AuthSession? get currentSession;

  Stream<AuthSession?> get onAuthStateChange;

  Future<void> signUp({required String email, required String password});

  Future<void> signInWithPassword({required String email, required String password});

  Future<void> signOut();

  Future<void> resetPasswordForEmail({
    required String email,
    required String redirectTo,
  });

  Future<void> updatePassword({required String newPassword});
}

class AuthRepository {
  AuthRepository(this._gateway);

  factory AuthRepository.live() {
    if (SupabaseClientProvider.isConfigured) {
      return AuthRepository(SupabaseAuthGateway(SupabaseClientProvider.client));
    }
    return AuthRepository(InMemoryAuthGateway());
  }

  final AuthGateway _gateway;

  AuthSession? get currentSession => _gateway.currentSession;

  Stream<AuthSession?> get authStateChanges => _gateway.onAuthStateChange;

  Future<void> signUp({required String email, required String password}) async {
    await _runMapped(
      () => _gateway.signUp(email: email.trim(), password: password),
    );
  }

  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    await _runMapped(
      () => _gateway.signInWithPassword(email: email.trim(), password: password),
    );
  }

  Future<void> signOut() async {
    await _runMapped(_gateway.signOut);
  }

  Future<void> resetPasswordForEmail({
    required String email,
    required String redirectTo,
  }) async {
    if (redirectTo.trim().isEmpty) {
      throw AuthFailure(
        AuthFailureCode.missingRecoveryRedirect,
        'Password recovery redirect URL is required.',
      );
    }

    await _runMapped(
      () => _gateway.resetPasswordForEmail(
        email: email.trim(),
        redirectTo: redirectTo.trim(),
      ),
    );
  }

  Future<void> updatePassword({required String newPassword}) async {
    await _runMapped(
      () => _gateway.updatePassword(newPassword: newPassword),
    );
  }

  Future<void> _runMapped(Future<void> Function() operation) async {
    try {
      await operation();
    } on AuthFailure {
      rethrow;
    } on AuthException catch (error) {
      throw _mapAuthException(error);
    } catch (_) {
      throw AuthFailure(
        AuthFailureCode.unknown,
        'Something went wrong. Please try again.',
      );
    }
  }

  AuthFailure _mapAuthException(AuthException exception) {
    final message = exception.message.toLowerCase();
    if (message.contains('invalid login') || message.contains('invalid credentials')) {
      return AuthFailure(
        AuthFailureCode.invalidCredentials,
        'Email or password is incorrect.',
      );
    }
    if (message.contains('already registered') || message.contains('already exists')) {
      return AuthFailure(
        AuthFailureCode.emailInUse,
        'An account already exists for this email.',
      );
    }
    if (message.contains('password') && message.contains('weak')) {
      return AuthFailure(
        AuthFailureCode.weakPassword,
        'Password must be stronger.',
      );
    }
    if (message.contains('email')) {
      return AuthFailure(
        AuthFailureCode.invalidEmail,
        'Please enter a valid email address.',
      );
    }
    return AuthFailure(
      AuthFailureCode.unknown,
      'Authentication failed. Please try again.',
    );
  }
}

class SupabaseAuthGateway implements AuthGateway {
  SupabaseAuthGateway(this._client);

  final SupabaseClient _client;

  @override
  AuthSession? get currentSession {
    final session = _client.auth.currentSession;
    if (session == null) {
      return null;
    }
    return AuthSession(userId: session.user.id);
  }

  @override
  Stream<AuthSession?> get onAuthStateChange {
    return _client.auth.onAuthStateChange.map((event) {
      final session = event.session;
      if (session == null) {
        return null;
      }
      return AuthSession(userId: session.user.id);
    });
  }

  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() {
    return _client.auth.signOut();
  }

  @override
  Future<void> signUp({required String email, required String password}) {
    return _client.auth.signUp(email: email, password: password);
  }

  @override
  Future<void> resetPasswordForEmail({
    required String email,
    required String redirectTo,
  }) {
    return _client.auth.resetPasswordForEmail(email, redirectTo: redirectTo);
  }

  @override
  Future<void> updatePassword({required String newPassword}) {
    return _client.auth.updateUser(UserAttributes(password: newPassword));
  }
}

class InMemoryAuthGateway implements AuthGateway {
  final StreamController<AuthSession?> _controller =
      StreamController<AuthSession?>.broadcast();
  AuthSession? _session;

  @override
  AuthSession? get currentSession => _session;

  @override
  Stream<AuthSession?> get onAuthStateChange => _controller.stream;

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
    _session = const AuthSession(userId: 'local-user');
    _controller.add(_session);
  }

  @override
  Future<void> signOut() async {
    _session = null;
    _controller.add(null);
  }

  @override
  Future<void> signUp({required String email, required String password}) async {
    _session = const AuthSession(userId: 'local-user');
    _controller.add(_session);
  }

  @override
  Future<void> updatePassword({required String newPassword}) async {}
}
