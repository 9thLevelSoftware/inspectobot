import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:inspectobot/app/auth_notifier.dart';
import 'package:inspectobot/app/navigation_service.dart';
import 'package:inspectobot/app/service_locator.dart';
import 'package:inspectobot/features/auth/data/auth_repository.dart';
import 'package:mocktail/mocktail.dart';

// ---------------------------------------------------------------------------
// Mocks & Fakes
// ---------------------------------------------------------------------------

class _FakeAuthRepository extends Fake implements AuthRepository {
  final StreamController<AuthStateChange> _controller =
      StreamController<AuthStateChange>.broadcast();

  @override
  AuthSession? get currentSession => null;

  @override
  Stream<AuthStateChange> get authStateChanges => _controller.stream;

  @override
  Future<AuthSession?> resolveCurrentSession() async => null;

  void dispose() => _controller.close();
}

class MockAuthNotifier extends Mock implements AuthNotifier {}

class MockNavigationService extends Mock implements NavigationService {}

void main() {
  group('setupServiceLocator', () {
    late _FakeAuthRepository repo;

    setUp(() {
      repo = _FakeAuthRepository();
    });

    tearDown(() async {
      await resetServiceLocator();
      repo.dispose();
    });

    test('registers AuthNotifier, GoRouter, and NavigationService', () async {
      await setupServiceLocator(repo);

      expect(GetIt.I.isRegistered<AuthNotifier>(), isTrue);
      expect(GetIt.I.isRegistered<GoRouter>(), isTrue);
      expect(GetIt.I.isRegistered<NavigationService>(), isTrue);
    });

    test('NavigationService is GoRouterNavigationService', () async {
      await setupServiceLocator(repo);

      expect(GetIt.I<NavigationService>(), isA<GoRouterNavigationService>());
    });
  });

  group('resetServiceLocator', () {
    test('clears all registrations', () async {
      final repo = _FakeAuthRepository();
      await setupServiceLocator(repo);

      expect(GetIt.I.isRegistered<AuthNotifier>(), isTrue);

      await resetServiceLocator();

      expect(GetIt.I.isRegistered<AuthNotifier>(), isFalse);
      expect(GetIt.I.isRegistered<GoRouter>(), isFalse);
      expect(GetIt.I.isRegistered<NavigationService>(), isFalse);

      repo.dispose();
    });
  });

  group('setupTestServiceLocator', () {
    tearDown(() async {
      await resetServiceLocator();
    });

    test('registers mock AuthNotifier', () {
      final mockNotifier = MockAuthNotifier();
      setupTestServiceLocator(authNotifier: mockNotifier);

      expect(GetIt.I<AuthNotifier>(), same(mockNotifier));
    });

    test('registers mock NavigationService', () {
      final mockNav = MockNavigationService();
      setupTestServiceLocator(navigationService: mockNav);

      expect(GetIt.I<NavigationService>(), same(mockNav));
    });

    test('supports selective registration', () {
      final mockNotifier = MockAuthNotifier();
      setupTestServiceLocator(authNotifier: mockNotifier);

      expect(GetIt.I.isRegistered<AuthNotifier>(), isTrue);
      expect(GetIt.I.isRegistered<NavigationService>(), isFalse);
    });
  });
}
