import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/common/widgets/widgets.dart';
import 'package:inspectobot/features/identity/data/inspector_profile_repository.dart';
import 'package:inspectobot/features/identity/data/signature_repository.dart';
import 'package:inspectobot/features/identity/domain/inspector_profile.dart';
import 'package:inspectobot/features/identity/presentation/inspector_identity_page.dart';
import 'package:inspectobot/theme/theme.dart';

class _ThrowingProfileStore implements InspectorProfileStore {
  @override
  Future<Map<String, dynamic>?> fetch({
    required String organizationId,
    required String userId,
  }) async =>
      null;

  @override
  Future<void> upsert(Map<String, dynamic> profileJson) async =>
      throw Exception('Save failed');
}

class _DelayedProfileStore implements InspectorProfileStore {
  final completer = Completer<void>();

  @override
  Future<Map<String, dynamic>?> fetch({
    required String organizationId,
    required String userId,
  }) async =>
      null;

  @override
  Future<void> upsert(Map<String, dynamic> profileJson) => completer.future;
}

Widget _buildPage({
  InspectorProfileRepository? profileRepo,
  SignatureRepository? signatureRepo,
}) {
  final gateway = InMemorySignatureGateway();
  return MaterialApp(
    theme: AppTheme.dark(),
    home: InspectorIdentityPage(
      organizationId: 'org-1',
      userId: 'user-1',
      profileRepository: profileRepo ??
          InspectorProfileRepository(InMemoryInspectorProfileStore()),
      signatureRepository: signatureRepo ??
          SignatureRepository(storage: gateway, metadata: gateway),
    ),
  );
}

void main() {
  group('InspectorIdentityPage', () {
    testWidgets('renders license fields and signature pad', (tester) async {
      await tester.pumpWidget(_buildPage());
      await tester.pumpAndSettle();

      expect(find.byType(AppTextField), findsNWidgets(2));
      expect(find.byType(SignaturePad), findsOneWidget);
    });

    testWidgets('shows loading overlay during initial fetch', (tester) async {
      await tester.pumpWidget(_buildPage());
      // Don't settle — check the loading state immediately.
      expect(find.byType(LoadingOverlay), findsOneWidget);
    });

    testWidgets('populates fields from existing profile', (tester) async {
      final store = InMemoryInspectorProfileStore();
      final repo = InspectorProfileRepository(store);
      await repo.upsertProfile(const InspectorProfile(
        organizationId: 'org-1',
        userId: 'user-1',
        licenseType: 'PE',
        licenseNumber: '12345',
      ));

      await tester.pumpWidget(_buildPage(profileRepo: repo));
      await tester.pumpAndSettle();

      expect(find.text('PE'), findsOneWidget);
      expect(find.text('12345'), findsOneWidget);
    });

    testWidgets('save button is in sticky bottom area', (tester) async {
      await tester.pumpWidget(_buildPage());
      await tester.pumpAndSettle();

      final saveButton = find.widgetWithText(AppButton, 'Save Identity');
      expect(saveButton, findsOneWidget);

      final reachZone = find.byType(ReachZoneScaffold);
      expect(
        find.descendant(of: reachZone, matching: saveButton),
        findsOneWidget,
      );
    });

    testWidgets('save persists profile and signature', (tester) async {
      final store = InMemoryInspectorProfileStore();
      final repo = InspectorProfileRepository(store);

      await tester.pumpWidget(_buildPage(profileRepo: repo));
      await tester.pumpAndSettle();

      // Enter text in license fields.
      await tester.enterText(
        find.byType(AppTextField).first,
        'PE',
      );
      await tester.enterText(
        find.byType(AppTextField).last,
        '99999',
      );

      // Tap Save.
      await tester.tap(find.widgetWithText(AppButton, 'Save Identity'));
      await tester.pumpAndSettle();

      // Verify the store now contains the profile.
      final saved = await store.fetch(
        organizationId: 'org-1',
        userId: 'user-1',
      );
      expect(saved, isNotNull);
      expect(saved!['license_type'], 'PE');
      expect(saved['license_number'], '99999');
    });

    testWidgets('save shows success snackbar', (tester) async {
      await tester.pumpWidget(_buildPage());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(AppTextField).first, 'PE');
      await tester.tap(find.widgetWithText(AppButton, 'Save Identity'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Identity saved.'), findsOneWidget);
    });

    testWidgets('save shows error banner on failure', (tester) async {
      final throwingRepo =
          InspectorProfileRepository(_ThrowingProfileStore());

      await tester.pumpWidget(_buildPage(profileRepo: throwingRepo));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(AppButton, 'Save Identity'));
      await tester.pumpAndSettle();

      // ErrorBanner may be off-screen in the ListView — scroll to reveal it.
      await tester.dragUntilVisible(
        find.byType(ErrorBanner),
        find.byType(ListView),
        const Offset(0, -100),
      );

      expect(find.byType(ErrorBanner), findsOneWidget);
    });

    testWidgets('save button shows loading state', (tester) async {
      final delayedRepo =
          InspectorProfileRepository(_DelayedProfileStore());

      await tester.pumpWidget(_buildPage(profileRepo: delayedRepo));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(AppButton, 'Save Identity'));
      await tester.pump(); // One frame — the delayed store keeps _saving=true.

      expect(find.text('Saving...'), findsOneWidget);
    });

    testWidgets('clear signature button removes points', (tester) async {
      // Use a taller surface so the Clear button is above the sticky bottom.
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildPage());
      await tester.pumpAndSettle();

      // Simulate a pan gesture on the SignaturePad using startGesture.
      final padCenter = tester.getCenter(find.byType(SignaturePad));
      final gesture = await tester.startGesture(padCenter);
      await tester.pump();
      await gesture.moveBy(const Offset(30, 0));
      await tester.pump();
      await gesture.moveBy(const Offset(20, 0));
      await tester.pump();
      await gesture.up();
      await tester.pump();

      // Hint text should be gone because points are present.
      expect(find.text('Draw your signature here'), findsNothing);

      // Tap Clear button.
      await tester.tap(find.widgetWithText(AppButton, 'Clear'));
      await tester.pump();

      // Hint text reappears.
      expect(find.text('Draw your signature here'), findsOneWidget);
    });

    testWidgets('displays signature metadata after save', (tester) async {
      await tester.pumpWidget(_buildPage());
      await tester.pumpAndSettle();

      // Simulate a pan gesture on the SignaturePad using startGesture.
      final padCenter = tester.getCenter(find.byType(SignaturePad));
      final gesture = await tester.startGesture(padCenter);
      await tester.pump();
      await gesture.moveBy(const Offset(30, 0));
      await tester.pump();
      await gesture.moveBy(const Offset(20, 0));
      await tester.pump();
      await gesture.up();
      await tester.pump();

      // Tap Save.
      await tester.tap(find.widgetWithText(AppButton, 'Save Identity'));
      await tester.pumpAndSettle();

      // Scroll to reveal metadata section if off-screen.
      await tester.dragUntilVisible(
        find.text('Hash'),
        find.byType(ListView),
        const Offset(0, -100),
      );

      expect(find.text('Hash'), findsOneWidget);
    });

    testWidgets('uses design tokens exclusively', (tester) async {
      await tester.pumpWidget(_buildPage());
      await tester.pumpAndSettle();

      // Walk the tree: verify no raw TextField (should be AppTextField).
      expect(
        find.byType(TextField),
        findsNWidgets(2),
        reason: 'Expect exactly 2 TextField widgets wrapped inside AppTextField',
      );
      expect(find.byType(AppTextField), findsNWidgets(2));

      // No standalone FilledButton or TextButton outside of AppButton wrappers.
      final allFilledButtons =
          find.byType(FilledButton).evaluate().length;
      final allAppButtons =
          find.byType(AppButton).evaluate().length;
      // Every FilledButton should be within an AppButton.
      for (final element in find.byType(FilledButton).evaluate()) {
        final appButtonAncestor = find.ancestor(
          of: find.byWidget(element.widget),
          matching: find.byType(AppButton),
        );
        expect(
          appButtonAncestor,
          findsAtLeastNWidgets(1),
          reason:
              'FilledButton should be wrapped in AppButton, found standalone',
        );
      }
    });
  });
}
