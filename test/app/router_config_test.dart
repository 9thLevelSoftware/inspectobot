import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:inspectobot/app/auth_notifier.dart';
import 'package:inspectobot/app/navigation_service.dart';
import 'package:inspectobot/app/router_config.dart';
import 'package:inspectobot/app/routes.dart';
import 'package:inspectobot/app/service_locator.dart';
import 'package:inspectobot/features/auth/data/auth_repository.dart';
import 'package:inspectobot/theme/theme.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthChangeEvent;

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeAuthRepository extends Fake implements AuthRepository {
  _FakeAuthRepository({this.initialSession});

  final AuthSession? initialSession;
  final StreamController<AuthStateChange> controller =
      StreamController<AuthStateChange>.broadcast();
  AuthSession? _resolvedSession;

  @override
  AuthSession? get currentSession => initialSession;

  @override
  Stream<AuthStateChange> get authStateChanges => controller.stream;

  set resolvedSession(AuthSession? s) => _resolvedSession = s;

  @override
  Future<AuthSession?> resolveCurrentSession() async => _resolvedSession;

  void emit(AuthChangeEvent event, {AuthSession? session}) {
    controller.add(AuthStateChange(event: event, session: session));
  }

  void dispose() => controller.close();
}

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class _MockNavigationService extends Mock implements NavigationService {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildApp(GoRouter router) {
  return MaterialApp.router(
    routerConfig: router,
    theme: AppTheme.dark(),
  );
}

void main() {
  late _MockNavigationService mockNav;

  setUp(() {
    mockNav = _MockNavigationService();
    when(() => mockNav.go(any(), extra: any(named: 'extra'))).thenReturn(null);
    when(() => mockNav.go(any())).thenReturn(null);
    when(() => mockNav.push<void>(any(), extra: any(named: 'extra')))
        .thenAnswer((_) async {});
    setupTestServiceLocator(navigationService: mockNav);
  });

  tearDown(() async {
    await resetServiceLocator();
  });

  group('createRouter redirect logic', () {
    late _FakeAuthRepository repo;
    late AuthNotifier notifier;

    setUp(() {
      repo = _FakeAuthRepository();
      notifier = AuthNotifier(repo);
    });

    tearDown(() {
      notifier.dispose();
      repo.dispose();
    });

    testWidgets('unauthenticated user is redirected to sign-in',
        (tester) async {
      final router = createRouter(notifier);
      // Initial location is sign-in; try going to dashboard
      router.go(AppRoutes.dashboard);
      await tester.pumpWidget(_buildApp(router));
      await tester.pumpAndSettle();
      // Should show sign-in page (redirected from dashboard)
      expect(find.text('Sign In'), findsWidgets);
    });

    testWidgets('unauthenticated user stays on sign-up', (tester) async {
      final router = createRouter(notifier);
      router.go(AppRoutes.signUp);
      await tester.pumpWidget(_buildApp(router));
      await tester.pumpAndSettle();
      expect(find.text('Create Account'), findsWidgets);
    });

    testWidgets('authenticated user is redirected from auth to dashboard',
        (tester) async {
      notifier.dispose();
      repo.dispose();
      repo = _FakeAuthRepository(
        initialSession:
            const AuthSession(userId: 'u1', organizationId: 'o1'),
      );
      notifier = AuthNotifier(repo);
      final router = createRouter(notifier);
      router.go(AppRoutes.signIn);
      await tester.pumpWidget(_buildApp(router));
      await tester.pumpAndSettle();
      // Should redirect to dashboard — look for the dashboard title
      expect(
        find.text('InspectoBot'),
        findsOneWidget,
      );
    });

    testWidgets('authenticated user can access dashboard', (tester) async {
      notifier.dispose();
      repo.dispose();
      repo = _FakeAuthRepository(
        initialSession:
            const AuthSession(userId: 'u1', organizationId: 'o1'),
      );
      notifier = AuthNotifier(repo);
      final router = createRouter(notifier);
      router.go(AppRoutes.dashboard);
      await tester.pumpWidget(_buildApp(router));
      await tester.pumpAndSettle();
      expect(
        find.text('InspectoBot'),
        findsOneWidget,
      );
    });

    testWidgets('root path redirects to dashboard for authenticated user',
        (tester) async {
      notifier.dispose();
      repo.dispose();
      repo = _FakeAuthRepository(
        initialSession:
            const AuthSession(userId: 'u1', organizationId: 'o1'),
      );
      notifier = AuthNotifier(repo);
      final router = createRouter(notifier);
      router.go('/');
      await tester.pumpWidget(_buildApp(router));
      await tester.pumpAndSettle();
      expect(
        find.text('InspectoBot'),
        findsOneWidget,
      );
    });

    testWidgets('recovery event redirects to reset-password', (tester) async {
      final router = createRouter(notifier);
      await tester.pumpWidget(_buildApp(router));
      await tester.pumpAndSettle();

      // Simulate recovery event
      repo.emit(
        AuthChangeEvent.passwordRecovery,
        session: const AuthSession(userId: 'u1'),
      );
      await tester.pumpAndSettle();

      // Should be on reset-password page
      expect(find.text('Reset Password'), findsWidgets);
    });

    testWidgets(
        'deep link guard: already on reset-password does not double redirect',
        (tester) async {
      final router = createRouter(notifier);
      await tester.pumpWidget(_buildApp(router));
      await tester.pumpAndSettle();

      // Trigger recovery
      repo.emit(
        AuthChangeEvent.passwordRecovery,
        session: const AuthSession(userId: 'u1'),
      );
      await tester.pumpAndSettle();

      // Should be on reset-password — verify it didn't redirect away
      expect(find.text('Reset Password'), findsWidgets);

      // Trigger another refresh (simulating Supabase re-firing the event)
      // The deep link guard should prevent re-redirect
      notifier.clearRecovery();
      repo.emit(
        AuthChangeEvent.passwordRecovery,
        session: const AuthSession(userId: 'u1'),
      );
      await tester.pumpAndSettle();
      // Still on reset-password
      expect(find.text('Reset Password'), findsWidgets);
    });

    testWidgets(
        'deep-link to /dashboard while isResolvingTenant redirects to sign-in',
        (tester) async {
      notifier.dispose();
      repo.dispose();
      // Session without org => isResolvingTenant = true, isAuthenticated = false
      repo = _FakeAuthRepository(
        initialSession: const AuthSession(userId: 'u1'),
      );
      notifier = AuthNotifier(repo);
      expect(notifier.isResolvingTenant, isTrue);
      expect(notifier.isAuthenticated, isFalse);

      final router = createRouter(notifier);
      router.go(AppRoutes.dashboard);
      await tester.pumpWidget(_buildApp(router));
      await tester.pumpAndSettle();

      // Should redirect to sign-in because tenant is not yet resolved
      expect(find.text('Sign In'), findsWidgets);
    });

    testWidgets('resolving tenant does not redirect', (tester) async {
      notifier.dispose();
      repo.dispose();
      // Session without org => isResolvingTenant = true
      repo = _FakeAuthRepository(
        initialSession: const AuthSession(userId: 'u1'),
      );
      notifier = AuthNotifier(repo);
      expect(notifier.isResolvingTenant, isTrue);

      final router = createRouter(notifier);
      await tester.pumpWidget(_buildApp(router));
      await tester.pumpAndSettle();

      // Should stay on initial route (sign-in) — not redirect
      expect(find.text('Sign In'), findsWidgets);
    });
  });

  group('createRouter route tree', () {
    late _FakeAuthRepository repo;
    late AuthNotifier notifier;
    late GoRouter router;

    setUp(() {
      repo = _FakeAuthRepository(
        initialSession:
            const AuthSession(userId: 'u1', organizationId: 'o1'),
      );
      notifier = AuthNotifier(repo);
      router = createRouter(notifier);
    });

    tearDown(() {
      notifier.dispose();
      repo.dispose();
    });

    testWidgets('dashboard route renders DashboardPage', (tester) async {
      router.go(AppRoutes.dashboard);
      await tester.pumpWidget(_buildApp(router));
      await tester.pumpAndSettle();
      expect(
        find.text('InspectoBot'),
        findsOneWidget,
      );
    });

    testWidgets('inspector-identity route renders InspectorIdentityPage',
        (tester) async {
      router.go(AppRoutes.inspectorIdentity);
      await tester.pumpWidget(_buildApp(router));
      await tester.pumpAndSettle();
      expect(find.text('Inspector Identity'), findsOneWidget);
    });

    testWidgets('new-inspection route renders NewInspectionPage',
        (tester) async {
      router.go(AppRoutes.newInspection);
      await tester.pumpWidget(_buildApp(router));
      await tester.pumpAndSettle();
      expect(find.text('New Inspection'), findsOneWidget);
    });

    testWidgets('checklist route with null extra redirects to dashboard',
        (tester) async {
      router.go('/inspections/test-id/checklist');
      await tester.pumpWidget(_buildApp(router));
      await tester.pumpAndSettle();
      // Should redirect to dashboard because extra is null
      expect(
        find.text('InspectoBot'),
        findsOneWidget,
      );
    });

    testWidgets('dashboard and identity are inside app shell (bottom nav)',
        (tester) async {
      router.go(AppRoutes.dashboard);
      await tester.pumpWidget(_buildApp(router));
      await tester.pumpAndSettle();
      // Should have bottom navigation bar
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('new-inspection is outside app shell (no bottom nav)',
        (tester) async {
      router.go(AppRoutes.newInspection);
      await tester.pumpWidget(_buildApp(router));
      await tester.pumpAndSettle();
      // Should NOT have bottom navigation bar
      expect(find.byType(BottomNavigationBar), findsNothing);
    });
  });

  group('createRouter security', () {
    late _FakeAuthRepository repo;
    late AuthNotifier notifier;

    setUp(() {
      repo = _FakeAuthRepository();
      notifier = AuthNotifier(repo);
    });

    tearDown(() {
      notifier.dispose();
      repo.dispose();
    });

    testWidgets('unauthenticated access to /inspections/new redirects to sign-in',
        (tester) async {
      final router = createRouter(notifier);
      router.go(AppRoutes.newInspection);
      await tester.pumpWidget(_buildApp(router));
      await tester.pumpAndSettle();
      // Should be redirected to sign-in
      expect(find.text('Sign In'), findsWidgets);
    });

    testWidgets('wrong type in state.extra does not crash checklist route',
        (tester) async {
      notifier.dispose();
      repo.dispose();
      repo = _FakeAuthRepository(
        initialSession:
            const AuthSession(userId: 'u1', organizationId: 'o1'),
      );
      notifier = AuthNotifier(repo);
      final router = createRouter(notifier);
      // Pass a String instead of InspectionDraft — should redirect, not crash
      router.go('/inspections/test-id/checklist', extra: 'not-a-draft');
      await tester.pumpWidget(_buildApp(router));
      await tester.pumpAndSettle();
      // Should redirect to dashboard because extra is wrong type
      expect(
        find.text('InspectoBot'),
        findsOneWidget,
      );
    });

    testWidgets('wrong type in state.extra does not crash sign-in route',
        (tester) async {
      final router = createRouter(notifier);
      // Pass an int instead of SignInPageArgs — should not crash
      router.go(AppRoutes.signIn, extra: 42);
      await tester.pumpWidget(_buildApp(router));
      await tester.pumpAndSettle();
      // Should render sign-in page normally (args treated as null)
      expect(find.text('Sign In'), findsWidgets);
    });

    testWidgets('clearRecovery breaks the recovery redirect loop',
        (tester) async {
      final router = createRouter(notifier);
      await tester.pumpWidget(_buildApp(router));
      await tester.pumpAndSettle();

      // Trigger recovery — user lands on reset-password
      repo.emit(
        AuthChangeEvent.passwordRecovery,
        session: const AuthSession(userId: 'u1'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Reset Password'), findsWidgets);

      // While recovery is active, navigating to sign-in should be blocked
      // (redirect sends back to reset-password)
      router.go(AppRoutes.signIn);
      await tester.pumpAndSettle();
      expect(find.text('Reset Password'), findsWidgets);

      // Clear recovery — simulates what happens after successful password update
      notifier.clearRecovery();
      await tester.pumpAndSettle();

      // Now navigating to sign-in should work (recovery redirect no longer fires)
      router.go(AppRoutes.signIn);
      await tester.pumpAndSettle();
      expect(find.text('Sign In'), findsWidgets);
    });
  });
}
