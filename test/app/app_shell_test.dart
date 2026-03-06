import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:inspectobot/app/app_shell.dart';
import 'package:inspectobot/app/routes.dart';
import 'package:inspectobot/theme/app_theme.dart';

/// Creates a test router with a ShellRoute wrapping AppShell and two child
/// routes, mimicking the production route tree.
GoRouter _createShellRouter({String initialLocation = '/dashboard'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) =>
                const Center(child: Text('Dashboard Content')),
          ),
          GoRoute(
            path: AppRoutes.inspectorIdentity,
            builder: (context, state) =>
                const Center(child: Text('Identity Content')),
          ),
        ],
      ),
    ],
  );
}

Widget _buildApp(GoRouter router) {
  return MaterialApp.router(
    theme: AppTheme.dark(),
    routerConfig: router,
  );
}

void main() {
  group('AppShell', () {
    testWidgets('renders bottom navigation bar with 2 items', (tester) async {
      final router = _createShellRouter();
      await tester.pumpWidget(_buildApp(router));
      await tester.pumpAndSettle();

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Inspections'), findsOneWidget);
      expect(find.text('Identity'), findsOneWidget);
      expect(find.byIcon(Icons.assignment), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('Inspections tab is selected on /dashboard', (tester) async {
      final router = _createShellRouter(initialLocation: AppRoutes.dashboard);
      await tester.pumpWidget(_buildApp(router));
      await tester.pumpAndSettle();

      final nav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(nav.currentIndex, 0);
      expect(find.text('Dashboard Content'), findsOneWidget);
    });

    testWidgets('Identity tab is selected on /inspector-identity',
        (tester) async {
      final router = _createShellRouter(
        initialLocation: AppRoutes.inspectorIdentity,
      );
      await tester.pumpWidget(_buildApp(router));
      await tester.pumpAndSettle();

      final nav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(nav.currentIndex, 1);
      expect(find.text('Identity Content'), findsOneWidget);
    });

    testWidgets('tapping Identity tab navigates to /inspector-identity',
        (tester) async {
      final router = _createShellRouter(initialLocation: AppRoutes.dashboard);
      await tester.pumpWidget(_buildApp(router));
      await tester.pumpAndSettle();

      // Tap the Identity tab
      await tester.tap(find.text('Identity'));
      await tester.pumpAndSettle();

      expect(find.text('Identity Content'), findsOneWidget);
      final nav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(nav.currentIndex, 1);
    });

    testWidgets('tapping Inspections tab navigates to /dashboard',
        (tester) async {
      final router = _createShellRouter(
        initialLocation: AppRoutes.inspectorIdentity,
      );
      await tester.pumpWidget(_buildApp(router));
      await tester.pumpAndSettle();

      // Tap the Inspections tab
      await tester.tap(find.text('Inspections'));
      await tester.pumpAndSettle();

      expect(find.text('Dashboard Content'), findsOneWidget);
      final nav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(nav.currentIndex, 0);
    });

    testWidgets('uses theme styling (no hardcoded colors)', (tester) async {
      final router = _createShellRouter();
      await tester.pumpWidget(_buildApp(router));
      await tester.pumpAndSettle();

      // BottomNavigationBar should exist and use theme from AppTheme.dark()
      final navBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      // Verify the widget exists and doesn't hardcode colors
      // (colors come from the theme's BottomNavigationBarTheme)
      expect(navBar.backgroundColor, isNull); // null = uses theme default
      expect(navBar.selectedItemColor, isNull); // null = uses theme default
      expect(navBar.unselectedItemColor, isNull); // null = uses theme default
    });
  });
}
