import 'dart:async';

import 'package:inspectobot/data/supabase/supabase_client_provider.dart';
import 'package:inspectobot/features/auth/data/tenant_context_resolver.dart';
import 'package:inspectobot/features/auth/domain/tenant_context.dart';
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
  const AuthSession({required this.userId, this.organizationId});

  final String userId;
  final String? organizationId;

  TenantContext? get tenantContext {
    final orgId = organizationId;
    if (orgId == null || orgId.isEmpty) {
      return null;
    }
    return TenantContext(userId: userId, organizationId: orgId);
  }
}

class AuthStateChange {
  const AuthStateChange({required this.event, required this.session});

  final AuthChangeEvent event;
  final AuthSession? session;
}

abstract class AuthGateway {
  AuthSession? get currentSession;

  Stream<AuthStateChange> get onAuthStateChange;

  Future<AuthSession?> resolveCurrentSession();

  Future<void> signUp({required String email, required String password});

  Future<void> signInWithPassword({
    required String email,
    required String password,
  });

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

  Stream<AuthStateChange> get authStateChanges => _gateway.onAuthStateChange;

  Future<AuthSession?> resolveCurrentSession() =>
      _gateway.resolveCurrentSession();

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
      () =>
          _gateway.signInWithPassword(email: email.trim(), password: password),
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
    await _runMapped(() => _gateway.updatePassword(newPassword: newPassword));
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
    if (message.contains('invalid login') ||
        message.contains('invalid credentials')) {
      return AuthFailure(
        AuthFailureCode.invalidCredentials,
        'Email or password is incorrect.',
      );
    }
    if (message.contains('already registered') ||
        message.contains('already exists')) {
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
  SupabaseAuthGateway(
    this._client, {
    TenantContextResolver? tenantContextResolver,
  }) : _tenantContextResolver =
           tenantContextResolver ?? TenantContextResolver.live();

  final SupabaseClient _client;
  final TenantContextResolver _tenantContextResolver;

  @override
  AuthSession? get currentSession {
    final session = _client.auth.currentSession;
    if (session == null) {
      return null;
    }
    final cachedTenantContext = _tenantContextResolver.getCachedForUser(
      session.user.id,
    );
    return AuthSession(
      userId: session.user.id,
      organizationId: cachedTenantContext?.organizationId,
    );
  }

  @override
  Stream<AuthStateChange> get onAuthStateChange {
    return _client.auth.onAuthStateChange.asyncMap((event) async {
      final session = event.session;
      if (session == null) {
        return AuthStateChange(event: event.event, session: null);
      }
      if (event.event == AuthChangeEvent.passwordRecovery) {
        final cachedTenantContext = _tenantContextResolver.getCachedForUser(
          session.user.id,
        );
        return AuthStateChange(
          event: event.event,
          session: AuthSession(
            userId: session.user.id,
            organizationId: cachedTenantContext?.organizationId,
          ),
        );
      }
      return AuthStateChange(
        event: event.event,
        session: await _resolveSession(session.user.id),
      );
    });
  }

  @override
  Future<AuthSession?> resolveCurrentSession() async {
    final session = _client.auth.currentSession;
    if (session == null) {
      return null;
    }
    return _resolveSession(session.user.id);
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

  Future<AuthSession> _resolveSession(String userId) async {
    final context = await _tenantContextResolver.resolveForUser(userId);
    return AuthSession(
      userId: context.userId,
      organizationId: context.organizationId,
    );
  }
}

class InMemoryAuthGateway implements AuthGateway {
  final StreamController<AuthStateChange> _controller =
      StreamController<AuthStateChange>.broadcast();
  AuthSession? _session;

  @override
  AuthSession? get currentSession => _session;

  @override
  Stream<AuthStateChange> get onAuthStateChange => _controller.stream;

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
    _session = const AuthSession(
      userId: 'local-user',
      organizationId: 'org-local-local-user',
    );
    _controller.add(
      AuthStateChange(event: AuthChangeEvent.signedIn, session: _session),
    );
  }

  @override
  Future<void> signOut() async {
    _session = null;
    _controller.add(
      const AuthStateChange(event: AuthChangeEvent.signedOut, session: null),
    );
  }

  @override
  Future<void> signUp({required String email, required String password}) async {
    _session = const AuthSession(
      userId: 'local-user',
      organizationId: 'org-local-local-user',
    );
    _controller.add(
      AuthStateChange(event: AuthChangeEvent.signedIn, session: _session),
    );
  }

  @override
  Future<void> updatePassword({required String newPassword}) async {}
}
