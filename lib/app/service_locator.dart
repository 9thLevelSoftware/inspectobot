import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/data/auth_repository.dart';
import 'auth_notifier.dart';
import 'navigation_service.dart';
import 'router_config.dart';

/// Production service locator setup.
///
/// Call this once during app startup, before [runApp].
/// Registers [AuthNotifier], [GoRouter], and [NavigationService].
Future<void> setupServiceLocator(AuthRepository authRepository) async {
  final getIt = GetIt.I;

  // AuthNotifier — singleton, owns the auth state lifecycle
  final authNotifier = AuthNotifier(authRepository);
  getIt.registerSingleton<AuthNotifier>(authNotifier);

  // GoRouter — singleton, depends on AuthNotifier
  final router = createRouter(authNotifier);
  getIt.registerSingleton<GoRouter>(router);

  // NavigationService — singleton, wraps GoRouter
  getIt.registerSingleton<NavigationService>(
    GoRouterNavigationService(router),
  );
}

/// Reset the service locator. Call in [tearDown] during tests.
Future<void> resetServiceLocator() async {
  await GetIt.I.reset();
}

/// Test-only service locator setup with optional mock overrides.
///
/// Registers provided mocks or creates minimal defaults.
/// Always call [resetServiceLocator] in tearDown.
void setupTestServiceLocator({
  AuthNotifier? authNotifier,
  NavigationService? navigationService,
  GoRouter? router,
}) {
  final getIt = GetIt.I;

  if (authNotifier != null) {
    getIt.registerSingleton<AuthNotifier>(authNotifier);
  }

  if (router != null) {
    getIt.registerSingleton<GoRouter>(router);
  }

  if (navigationService != null) {
    getIt.registerSingleton<NavigationService>(navigationService);
  }
}
