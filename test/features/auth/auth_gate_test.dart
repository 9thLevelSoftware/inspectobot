import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/auth/data/auth_repository.dart';
import 'package:inspectobot/features/auth/presentation/auth_gate.dart';

void main() {
  testWidgets('shows signed-out shell when no active session', (tester) async {
    final repository = AuthRepository(
      _GateFakeAuthGateway(initialSession: null),
    );

    await tester.pumpWidget(
      MaterialApp(home: AuthGate(repository: repository)),
    );

    expect(find.text('InspectoBot Access'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('switches to dashboard after onAuthStateChange emits session', (
    tester,
  ) async {
    final gateway = _GateFakeAuthGateway(initialSession: null);
    final repository = AuthRepository(gateway);

    await tester.pumpWidget(
      MaterialApp(home: AuthGate(repository: repository)),
    );

    gateway.emit(const AuthSession(userId: '123', organizationId: 'org-123'));
    await tester.pumpAndSettle();

    expect(find.text('Florida Insurance Inspection Workflow'), findsOneWidget);
  });

  testWidgets('passes tenant context from resolved session to dashboard builder', (
    tester,
  ) async {
    final repository = AuthRepository(
      _GateFakeAuthGateway(
        initialSession: const AuthSession(
          userId: 'user-42',
          organizationId: 'org-42',
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AuthGate(
          repository: repository,
          dashboardBuilder: (_, organizationId, userId) {
            return Text('tenant:$organizationId user:$userId');
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('tenant:org-42 user:user-42'), findsOneWidget);
  });
}

class _GateFakeAuthGateway implements AuthGateway {
  _GateFakeAuthGateway({AuthSession? initialSession})
    : _session = initialSession;

  final _controller = StreamController<AuthSession?>.broadcast();
  AuthSession? _session;

  void emit(AuthSession? session) {
    _session = session;
    _controller.add(session);
  }

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
  }) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> signUp({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> updatePassword({required String newPassword}) async {}
}
