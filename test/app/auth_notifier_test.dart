import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/app/auth_notifier.dart';
import 'package:inspectobot/features/auth/data/auth_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthChangeEvent;

// ---------------------------------------------------------------------------
// Mocks & Helpers
// ---------------------------------------------------------------------------

class MockAuthRepository extends Mock implements AuthRepository {}

/// A fake [AuthRepository] that exposes a stream controller for test-driven
/// auth state emission.
class FakeAuthRepository extends Fake implements AuthRepository {
  FakeAuthRepository({this.initialSession});

  final AuthSession? initialSession;
  final StreamController<AuthStateChange> controller =
      StreamController<AuthStateChange>.broadcast();
  AuthSession? _resolvedSession;
  int resolveCallCount = 0;
  Completer<AuthSession?>? resolveCompleter;

  @override
  AuthSession? get currentSession => initialSession;

  @override
  Stream<AuthStateChange> get authStateChanges => controller.stream;

  /// Set the session that [resolveCurrentSession] will return.
  set resolvedSession(AuthSession? session) => _resolvedSession = session;

  @override
  Future<AuthSession?> resolveCurrentSession() async {
    resolveCallCount++;
    if (resolveCompleter != null) {
      return resolveCompleter!.future;
    }
    return _resolvedSession;
  }

  void emit(AuthChangeEvent event, {AuthSession? session}) {
    controller.add(AuthStateChange(event: event, session: session));
  }

  void dispose() {
    controller.close();
  }
}

void main() {
  group('AuthNotifier', () {
    late FakeAuthRepository repository;

    setUp(() {
      repository = FakeAuthRepository();
    });

    tearDown(() {
      repository.dispose();
    });

    // -----------------------------------------------------------------------
    // Initial state
    // -----------------------------------------------------------------------

    test('initial state is signed out when repository has no session', () {
      final notifier = AuthNotifier(repository);
      addTearDown(notifier.dispose);

      expect(notifier.session, isNull);
      expect(notifier.isAuthenticated, isFalse);
      expect(notifier.isRecovery, isFalse);
      expect(notifier.isResolvingTenant, isFalse);
    });

    test('initial state resolves tenant when session lacks tenant context', () async {
      final sessionWithoutTenant = const AuthSession(userId: 'u1');
      final repo = FakeAuthRepository(initialSession: sessionWithoutTenant);
      repo.resolvedSession = const AuthSession(
        userId: 'u1',
        organizationId: 'org1',
      );

      final notifier = AuthNotifier(repo);
      addTearDown(notifier.dispose);

      // Initially resolving
      expect(notifier.isResolvingTenant, isTrue);

      // Wait for async resolution
      await Future<void>.delayed(Duration.zero);

      expect(notifier.isResolvingTenant, isFalse);
      expect(notifier.isAuthenticated, isTrue);
      expect(notifier.session?.tenantContext, isNotNull);
      expect(repo.resolveCallCount, 1);

      repo.dispose();
    });

    test('initial state is authenticated when session has tenant context', () {
      final sessionWithTenant = const AuthSession(
        userId: 'u1',
        organizationId: 'org1',
      );
      final repo = FakeAuthRepository(initialSession: sessionWithTenant);
      final notifier = AuthNotifier(repo);
      addTearDown(notifier.dispose);

      expect(notifier.isAuthenticated, isTrue);
      expect(notifier.isResolvingTenant, isFalse);

      repo.dispose();
    });

    // -----------------------------------------------------------------------
    // Sign-in flow
    // -----------------------------------------------------------------------

    test('notifies on sign-in event and resolves tenant', () async {
      final notifier = AuthNotifier(repository);
      addTearDown(notifier.dispose);

      final sessionNoTenant = const AuthSession(userId: 'u1');
      repository.resolvedSession = const AuthSession(
        userId: 'u1',
        organizationId: 'org1',
      );

      int notifyCount = 0;
      notifier.addListener(() => notifyCount++);

      repository.emit(AuthChangeEvent.signedIn, session: sessionNoTenant);
      await Future<void>.delayed(Duration.zero);

      // After stream event + tenant resolution
      expect(notifier.isAuthenticated, isTrue);
      expect(notifyCount, greaterThanOrEqualTo(2)); // auth event + resolve
    });

    // -----------------------------------------------------------------------
    // Sign-out flow
    // -----------------------------------------------------------------------

    test('notifies on sign-out event', () async {
      final notifier = AuthNotifier(repository);
      addTearDown(notifier.dispose);

      int notifyCount = 0;
      notifier.addListener(() => notifyCount++);

      repository.emit(AuthChangeEvent.signedOut, session: null);
      await Future<void>.delayed(Duration.zero);

      expect(notifier.session, isNull);
      expect(notifier.isAuthenticated, isFalse);
      expect(notifyCount, 1);
    });

    // -----------------------------------------------------------------------
    // Password recovery flow
    // -----------------------------------------------------------------------

    test('sets isRecovery on passwordRecovery event', () async {
      final notifier = AuthNotifier(repository);
      addTearDown(notifier.dispose);

      repository.emit(
        AuthChangeEvent.passwordRecovery,
        session: const AuthSession(userId: 'u1'),
      );
      await Future<void>.delayed(Duration.zero);

      expect(notifier.isRecovery, isTrue);
      expect(notifier.isResolvingTenant, isFalse); // Edge case 3
    });

    test('duplicate recovery events are ignored (edge case 2)', () async {
      final notifier = AuthNotifier(repository);
      addTearDown(notifier.dispose);

      int notifyCount = 0;
      notifier.addListener(() => notifyCount++);

      // First recovery event
      repository.emit(
        AuthChangeEvent.passwordRecovery,
        session: const AuthSession(userId: 'u1'),
      );
      await Future<void>.delayed(Duration.zero);
      expect(notifyCount, 1);

      // Second recovery event — should be ignored
      repository.emit(
        AuthChangeEvent.passwordRecovery,
        session: const AuthSession(userId: 'u1'),
      );
      await Future<void>.delayed(Duration.zero);
      expect(notifyCount, 1); // No additional notification
    });

    test('clearRecovery resets recovery state', () async {
      final notifier = AuthNotifier(repository);
      addTearDown(notifier.dispose);

      repository.emit(
        AuthChangeEvent.passwordRecovery,
        session: const AuthSession(userId: 'u1'),
      );
      await Future<void>.delayed(Duration.zero);
      expect(notifier.isRecovery, isTrue);

      int notifyCount = 0;
      notifier.addListener(() => notifyCount++);

      notifier.clearRecovery();
      expect(notifier.isRecovery, isFalse);
      expect(notifyCount, 1);
    });

    test('recovery events can be handled again after clearRecovery', () async {
      final notifier = AuthNotifier(repository);
      addTearDown(notifier.dispose);

      // First recovery
      repository.emit(
        AuthChangeEvent.passwordRecovery,
        session: const AuthSession(userId: 'u1'),
      );
      await Future<void>.delayed(Duration.zero);
      expect(notifier.isRecovery, isTrue);

      notifier.clearRecovery();
      expect(notifier.isRecovery, isFalse);

      // Second recovery should work again
      repository.emit(
        AuthChangeEvent.passwordRecovery,
        session: const AuthSession(userId: 'u1'),
      );
      await Future<void>.delayed(Duration.zero);
      expect(notifier.isRecovery, isTrue);
    });

    // -----------------------------------------------------------------------
    // Edge case 1: dispose safety
    // -----------------------------------------------------------------------

    test('does not notify after dispose (edge case 1)', () async {
      final notifier = AuthNotifier(repository);

      bool notified = false;
      notifier.addListener(() => notified = true);

      notifier.dispose();

      // Emit after dispose — should not throw or notify
      repository.emit(
        AuthChangeEvent.signedIn,
        session: const AuthSession(userId: 'u1'),
      );
      await Future<void>.delayed(Duration.zero);

      expect(notified, isFalse);
    });

    // -----------------------------------------------------------------------
    // Edge case: race condition in tenant resolution
    // -----------------------------------------------------------------------

    test('tenant resolution race condition is guarded by disposed check',
        () async {
      final repo = FakeAuthRepository(
        initialSession: const AuthSession(userId: 'u1'),
      );
      repo.resolveCompleter = Completer<AuthSession?>();

      final notifier = AuthNotifier(repo);
      expect(notifier.isResolvingTenant, isTrue);

      // Dispose before resolution completes
      notifier.dispose();

      // Complete the resolution — should not throw
      repo.resolveCompleter!.complete(
        const AuthSession(userId: 'u1', organizationId: 'org1'),
      );
      await Future<void>.delayed(Duration.zero);

      // Session was NOT updated because notifier is disposed
      // (accessing session after dispose is still safe — just stale)
      repo.dispose();
    });

    // -----------------------------------------------------------------------
    // Recovery skips tenant resolution (edge case 3)
    // -----------------------------------------------------------------------

    test('recovery event does not trigger tenant resolution (edge case 3)',
        () async {
      final notifier = AuthNotifier(repository);
      addTearDown(notifier.dispose);

      repository.emit(
        AuthChangeEvent.passwordRecovery,
        session: const AuthSession(userId: 'u1'),
      );
      await Future<void>.delayed(Duration.zero);

      expect(repository.resolveCallCount, 0);
      expect(notifier.isResolvingTenant, isFalse);
    });
  });
}
