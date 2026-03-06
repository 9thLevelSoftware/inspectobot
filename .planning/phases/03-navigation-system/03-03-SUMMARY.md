# Plan 03-03 Summary: Screen Migration & Test Updates

## Status: Complete

## Changes Made

### Task 1: Auth Screen Navigation Migration
- **sign_in_page.dart**: Replaced `Navigator.pushNamedAndRemoveUntil` (sign-in success) with `NavigationService.go()`. Replaced `Navigator.pushNamed` for sign-up and forgot-password links with `NavigationService.go()`. Replaced `ModalRoute.of(context)` args reading with constructor `args` parameter (`SignInPageArgs?`). Removed `didChangeDependencies` + `_didLoadRouteArgs` in favor of `initState`.
- **sign_up_page.dart**: Replaced `Navigator.pushNamedAndRemoveUntil` with `NavigationService.go()`. Replaced `Navigator.pushReplacementNamed` with `NavigationService.replace()`.
- **forgot_password_page.dart**: Replaced `Navigator.pushNamed` with `NavigationService.go()`.
- **reset_password_page.dart**: Replaced `Navigator.pushNamedAndRemoveUntil` with `NavigationService.go(AppRoutes.signIn, extra: SignInPageArgs(...))` to pass the success message via GoRouter extra.
- **router_config.dart**: Updated sign-in route to pass `state.extra as SignInPageArgs?` to `SignInPage(args:)`.

### Task 2: Inspection Screen Navigation Migration
- **dashboard_page.dart**: Replaced 3 `Navigator.of(context).push(MaterialPageRoute(...))` calls:
  - New inspection: `NavigationService.push<void>(AppRoutes.newInspection)` with await-and-refresh preserved
  - Resume inspection: `NavigationService.push<void>(AppRoutes.inspectionChecklist(id), extra: draft)` with await-and-refresh preserved
  - Inspector identity: `NavigationService.go(AppRoutes.inspectorIdentity)`
  - Removed unused `_StaticDashboardRepositoryProvider` class
  - Removed imports for `form_checklist_page.dart`, `new_inspection_page.dart`, `inspector_identity_page.dart`
- **new_inspection_page.dart**: Replaced `Navigator.push(MaterialPageRoute(FormChecklistPage(...)))` with `NavigationService.go(AppRoutes.inspectionChecklist(id), extra: draft)`. Removed `form_checklist_page.dart` import.

### Task 3: AuthGate Removal & Route Cleanup
- Deleted `lib/features/auth/presentation/auth_gate.dart`
- Removed `authGate` constant and `authStack` set from `lib/app/routes.dart`
- No barrel exports referenced auth_gate -- no additional cleanup needed
- All AuthGate behavior is covered by AuthNotifier + GoRouter redirect (verified in router_config_test.dart)

### Task 4: Test File Updates
- **Deleted** `test/features/auth/auth_gate_test.dart` -- all behaviors covered by auth_notifier_test (12 tests) and router_config_test (14 tests)
- **Rewrote** `test/features/auth/reset_password_page_test.dart` -- uses `setupTestServiceLocator(navigationService: mockNav)` and `resetServiceLocator()`. Verifies `NavigationService.go()` was called with SignInPageArgs via mocktail.
- **Rewrote** `test/features/inspection/dashboard_page_test.dart` -- 3 tests: resume inspection verifies `NavigationService.push()` to checklist route, new inspection verifies `push()` to new-inspection route, inspector identity verifies `go()` to identity route. Uses mocktail mock of NavigationService.
- **Rewrote** `test/features/inspection/new_inspection_page_test.dart` -- 4 tests preserved (validation, form labels, at-least-one-form, successful submit). Successful submit verifies `NavigationService.go()` to checklist route via mocktail.
- **widget_test.dart** -- no changes needed (render-only tests don't trigger navigation)
- **router_config_test.dart** -- no changes needed (uses GoRouter directly, doesn't trigger page-level navigation)
- **form_checklist_page_test.dart** -- no changes needed (no Navigator calls found)

### Task 5: Final Verification Sweep
- `Navigator.` in lib/: **0 matches**
- `MaterialPageRoute` in lib/: **0 matches**
- `AuthGate` (word boundary) in lib/: only doc comments in auth_notifier.dart
- `AuthGate` in test/: **0 matches**
- `authStack` in lib/ and test/: **0 matches**
- `authGate` in all dart files: **0 matches**
- `dart analyze lib/`: 4 info-level hints (all pre-existing `prefer_initializing_formals`), 0 warnings, 0 errors
- `flutter test`: **391/391 passed**

## Files Created
- `.planning/phases/03-navigation-system/03-03-SUMMARY.md`

## Files Modified
- `lib/features/auth/presentation/sign_in_page.dart`
- `lib/features/auth/presentation/sign_up_page.dart`
- `lib/features/auth/presentation/forgot_password_page.dart`
- `lib/features/auth/presentation/reset_password_page.dart`
- `lib/features/inspection/presentation/dashboard_page.dart`
- `lib/features/inspection/presentation/new_inspection_page.dart`
- `lib/app/router_config.dart`
- `lib/app/routes.dart`
- `test/features/auth/reset_password_page_test.dart`
- `test/features/inspection/dashboard_page_test.dart`
- `test/features/inspection/new_inspection_page_test.dart`

## Files Deleted
- `lib/features/auth/presentation/auth_gate.dart`
- `test/features/auth/auth_gate_test.dart`

## Verification Results
- `dart analyze lib/` -- 0 errors, 0 warnings, 4 pre-existing infos
- `flutter test` -- 391/391 passed (395 original - 4 deleted AuthGate tests - 2 deleted dashboard branch tests + 2 new dashboard/identity nav tests = 391)

## Decisions Made
1. **DashboardPage unused fields**: `mediaSyncRemoteStore` and `pendingMediaSyncStore` constructor params remain on DashboardPage even though they are no longer used in the widget body (previously passed to NewInspectionPage/FormChecklistPage via MaterialPageRoute). Removing them would be a constructor API change that could affect other callers. Left for a follow-up cleanup task.
2. **_StaticDashboardRepositoryProvider removed**: This class was only used to wrap the repository when creating NewInspectionPage inline. Since navigation now goes through GoRouter (which creates NewInspectionPage in router_config.dart), the class is dead code and was removed.
3. **NewInspectionPage uses `go()` not `push()`**: After creating an inspection, the page navigates to the checklist with `go()` (replacing the stack) rather than `push()` (adding to stack). This is correct because the user shouldn't navigate back to the "create" form after starting the wizard.
4. **Dashboard branch context test removed**: The old test verified branch context was preserved through MaterialPageRoute constructor. Since DashboardPage now delegates to NavigationService.push (mock), we verify the route path instead. Branch context preservation is still tested via the router_config integration.

## Issues Encountered
1. **FilledButton.icon not found by `widgetWithText(FilledButton, ...)`**: Flutter's `FilledButton.icon()` constructor creates an internal `_FilledButtonWithIcon` widget, which doesn't match `find.byType(FilledButton)`. Fixed by using `find.text('New Inspection')` instead.

## Errors
- None.
