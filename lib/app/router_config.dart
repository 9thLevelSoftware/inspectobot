import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/forgot_password_page.dart';
import '../features/auth/presentation/reset_password_page.dart';
import '../features/auth/presentation/sign_in_page.dart';
import '../features/auth/presentation/sign_up_page.dart';
import '../features/identity/presentation/inspector_identity_page.dart';
import '../features/inspection/domain/inspection_draft.dart';
import '../features/inspection/presentation/dashboard_page.dart';
import '../features/inspection/presentation/form_checklist_page.dart';
import '../features/inspection/presentation/new_inspection_page.dart';
import 'app_shell.dart';
import 'auth_notifier.dart';
import 'routes.dart';

/// Creates the application [GoRouter] with auth-gated redirect logic.
///
/// Route tree:
/// - Auth routes (no bottom nav): /auth/sign-in, /auth/sign-up, etc.
/// - App shell (bottom nav): /dashboard, /inspector-identity
/// - Full-screen flows (no bottom nav): /inspections/new, /inspections/:id/checklist
GoRouter createRouter(AuthNotifier authNotifier) {
  return GoRouter(
    initialLocation: AppRoutes.signIn,
    refreshListenable: authNotifier,
    redirect: (context, state) => _redirect(authNotifier, state),
    routes: [
      // Auth routes — no bottom navigation
      GoRoute(
        path: AppRoutes.signIn,
        pageBuilder: (context, state) => _fadeTransitionPage(
          key: state.pageKey,
          child: SignInPage(args: state.extra as SignInPageArgs?),
        ),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        pageBuilder: (context, state) => _fadeTransitionPage(
          key: state.pageKey,
          child: const SignUpPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        pageBuilder: (context, state) => _fadeTransitionPage(
          key: state.pageKey,
          child: const ForgotPasswordPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        pageBuilder: (context, state) => _fadeTransitionPage(
          key: state.pageKey,
          child: const ResetPasswordPage(),
        ),
      ),

      // App shell — bottom navigation with 2 tabs
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            pageBuilder: (context, state) {
              final session = authNotifier.session;
              final tenant = session?.tenantContext;
              return _slideTransitionPage(
                key: state.pageKey,
                child: DashboardPage(
                  organizationId: tenant?.organizationId ?? '',
                  userId: tenant?.userId ?? '',
                ),
              );
            },
          ),
          GoRoute(
            path: AppRoutes.inspectorIdentity,
            pageBuilder: (context, state) {
              final session = authNotifier.session;
              final tenant = session?.tenantContext;
              return _slideTransitionPage(
                key: state.pageKey,
                child: InspectorIdentityPage(
                  organizationId: tenant?.organizationId ?? '',
                  userId: tenant?.userId ?? '',
                ),
              );
            },
          ),
        ],
      ),

      // Full-screen flows — no bottom navigation
      GoRoute(
        path: AppRoutes.newInspection,
        pageBuilder: (context, state) {
          final session = authNotifier.session;
          final tenant = session?.tenantContext;
          return _slideTransitionPage(
            key: state.pageKey,
            child: NewInspectionPage(
              organizationId: tenant?.organizationId ?? '',
              userId: tenant?.userId ?? '',
            ),
          );
        },
      ),
      GoRoute(
        path: '/inspections/:id/checklist',
        pageBuilder: (context, state) {
          final draft = state.extra as InspectionDraft?;
          return _slideTransitionPage(
            key: state.pageKey,
            child: FormChecklistPage(draft: draft!),
          );
        },
        redirect: (context, state) {
          // If extra is null (e.g. deep link without draft), redirect to dashboard
          if (state.extra == null) {
            return AppRoutes.dashboard;
          }
          return null;
        },
      ),
    ],
  );
}

/// Auth redirect logic.
///
/// Priority order:
/// 1. Recovery event + not already on reset-password => redirect to reset-password
/// 2. Resolving tenant => stay on current page (loading state)
/// 3. Not authenticated => redirect to sign-in (unless already on auth route)
/// 4. Authenticated + on auth route => redirect to dashboard
/// 5. Authenticated + on root => redirect to dashboard
String? _redirect(AuthNotifier authNotifier, GoRouterState state) {
  final currentPath = state.matchedLocation;
  final isOnAuthRoute = currentPath.startsWith('/auth');

  // 1. Recovery: redirect to reset-password unless already there (deep link guard)
  if (authNotifier.isRecovery) {
    if (currentPath == AppRoutes.resetPassword) {
      return null; // Already on reset-password — don't redirect again
    }
    return AppRoutes.resetPassword;
  }

  // 2. Resolving tenant — don't redirect, let the current page handle loading
  if (authNotifier.isResolvingTenant) {
    return null;
  }

  // 3. Not authenticated — must be on an auth route
  if (!authNotifier.isAuthenticated) {
    if (isOnAuthRoute) {
      return null; // Already on auth route
    }
    return AppRoutes.signIn;
  }

  // 4. Authenticated but on auth route — redirect to dashboard
  if (isOnAuthRoute) {
    return AppRoutes.dashboard;
  }

  // 5. Authenticated on root — redirect to dashboard
  if (currentPath == '/') {
    return AppRoutes.dashboard;
  }

  return null;
}

/// Fade transition for auth pages.
CustomTransitionPage<void> _fadeTransitionPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

/// Slide transition for app pages.
CustomTransitionPage<void> _slideTransitionPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOut));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}
