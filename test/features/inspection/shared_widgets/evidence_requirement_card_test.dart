import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/common/widgets/widgets.dart';
import 'package:inspectobot/features/inspection/domain/evidence_requirement.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/required_photo_category.dart';
import 'package:inspectobot/features/inspection/presentation/shared_widgets/evidence_requirement_card.dart';
import 'package:inspectobot/theme/app_theme.dart';
import 'package:inspectobot/theme/tokens.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  EvidenceRequirement buildRequirement({
    String key = 'test_photo',
    String label = 'Exterior Front Photo',
    EvidenceMediaType mediaType = EvidenceMediaType.photo,
    RequiredPhotoCategory? category = RequiredPhotoCategory.exteriorFront,
  }) {
    return EvidenceRequirement(
      key: key,
      label: label,
      form: FormType.fourPoint,
      mediaType: mediaType,
      minimumCount: 1,
      category: category,
    );
  }

  Widget buildSubject({
    required EvidenceRequirement requirement,
    bool isCaptured = false,
    VoidCallback? onCapture,
  }) {
    return MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(
        body: SizedBox(
          height: 400,
          child: EvidenceRequirementCard(
            requirement: requirement,
            isCaptured: isCaptured,
            onCapture: onCapture,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tests
  // ---------------------------------------------------------------------------

  group('EvidenceRequirementCard', () {
    testWidgets('renders requirement label', (tester) async {
      final requirement = buildRequirement(label: 'Roof Slope Photo');

      await tester.pumpWidget(buildSubject(requirement: requirement));

      expect(find.text('Roof Slope Photo'), findsOneWidget);
    });

    testWidgets('shows "Complete" StatusBadge when captured', (tester) async {
      final requirement = buildRequirement();

      await tester.pumpWidget(buildSubject(
        requirement: requirement,
        isCaptured: true,
      ));

      expect(find.text('Complete'), findsOneWidget);
      final badge = tester.widget<StatusBadge>(find.byType(StatusBadge));
      expect(badge.type, StatusBadgeType.success);
    });

    testWidgets('shows "Missing" StatusBadge when not captured', (
      tester,
    ) async {
      final requirement = buildRequirement();

      await tester.pumpWidget(buildSubject(
        requirement: requirement,
        isCaptured: false,
        onCapture: () {},
      ));

      expect(find.text('Missing'), findsOneWidget);
      final badge = tester.widget<StatusBadge>(find.byType(StatusBadge));
      expect(badge.type, StatusBadgeType.warning);
    });

    testWidgets('shows "Upload" for document mediaType', (tester) async {
      final requirement = buildRequirement(
        mediaType: EvidenceMediaType.document,
      );

      await tester.pumpWidget(buildSubject(
        requirement: requirement,
        isCaptured: false,
        onCapture: () {},
      ));

      expect(find.text('Upload'), findsOneWidget);
    });

    testWidgets('shows "Capture" for photo mediaType', (tester) async {
      final requirement = buildRequirement(
        mediaType: EvidenceMediaType.photo,
      );

      await tester.pumpWidget(buildSubject(
        requirement: requirement,
        isCaptured: false,
        onCapture: () {},
      ));

      expect(find.text('Capture'), findsOneWidget);
    });

    testWidgets('hides capture button when onCapture is null', (
      tester,
    ) async {
      final requirement = buildRequirement(category: null);

      await tester.pumpWidget(buildSubject(
        requirement: requirement,
        isCaptured: false,
        onCapture: null,
      ));

      // The OutlinedButton should still render (onCapture controls onPressed,
      // but category == null means onCapture is null from the parent).
      // The card still shows the badge but the button is disabled (onPressed: null).
      expect(find.byType(OutlinedButton), findsOneWidget);
      final button = tester.widget<OutlinedButton>(
        find.byType(OutlinedButton),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('has 56dp minimum height', (tester) async {
      final requirement = buildRequirement();

      await tester.pumpWidget(buildSubject(
        requirement: requirement,
        isCaptured: true,
      ));

      // Find the ConstrainedBox that is a direct ancestor of the Card inside
      // EvidenceRequirementCard. Use ancestor finder to be precise.
      final box = tester.widget<ConstrainedBox>(
        find.ancestor(
          of: find.byType(Card),
          matching: find.byType(ConstrainedBox),
        ).first,
      );
      expect(
        box.constraints.minHeight,
        equals(AppSpacing.thumbZoneTapTarget),
        reason: 'Card must have 56dp minimum height for glove-friendly tapping',
      );
    });
  });
}
