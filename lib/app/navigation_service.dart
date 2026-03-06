import 'package:go_router/go_router.dart';

/// Abstract navigation interface that decouples widgets from go_router.
///
/// Widgets call [NavigationService] methods instead of direct `context.go()`
/// calls, enabling mock-based testing without rendering a full router.
abstract class NavigationService {
  /// Navigate to [location], replacing the current navigation stack entry.
  void go(String location, {Object? extra});

  /// Push [location] onto the navigation stack. Returns the value popped by
  /// the destination, supporting the await-push-refresh pattern used by
  /// DashboardPage.
  Future<T?> push<T>(String location, {Object? extra});

  /// Pop the top-most route, optionally returning [result] to the caller.
  void pop<T>([T? result]);

  /// Replace the current route with [location].
  void replace(String location, {Object? extra});
}

/// Production implementation backed by a [GoRouter] instance.
class GoRouterNavigationService implements NavigationService {
  GoRouterNavigationService(this._router);

  final GoRouter _router;

  @override
  void go(String location, {Object? extra}) {
    _router.go(location, extra: extra);
  }

  @override
  Future<T?> push<T>(String location, {Object? extra}) {
    return _router.push<T>(location, extra: extra);
  }

  @override
  void pop<T>([T? result]) {
    _router.pop<T>(result);
  }

  @override
  void replace(String location, {Object? extra}) {
    _router.pushReplacement(location, extra: extra);
  }
}
