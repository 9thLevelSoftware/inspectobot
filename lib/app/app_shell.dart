import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'navigation_service.dart';
import 'routes.dart';

/// Authenticated app shell with persistent bottom navigation.
///
/// Wraps shell route children with a [Scaffold] containing a
/// [BottomNavigationBar] with two tabs: Inspections and Identity.
/// Styling uses theme-provided values exclusively (no hardcoded colors).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex(context),
        onTap: (index) => _onTap(context, index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Inspections',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Identity',
          ),
        ],
      ),
    );
  }

  /// Determine selected tab index from the current route path.
  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(AppRoutes.inspectorIdentity)) {
      return 1;
    }
    return 0; // Default to Inspections tab
  }

  /// Navigate to the appropriate route based on tab index.
  void _onTap(BuildContext context, int index) {
    final nav = GetIt.I<NavigationService>();
    switch (index) {
      case 0:
        nav.go(AppRoutes.dashboard);
      case 1:
        nav.go(AppRoutes.inspectorIdentity);
    }
  }
}
