import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/common/widgets/widgets.dart';
import 'package:inspectobot/features/delivery/domain/report_artifact.dart';
import 'package:inspectobot/features/inspection/domain/report_readiness.dart';
import 'package:inspectobot/features/inspection/presentation/sub_views/pdf_delivery_view.dart';
import 'package:inspectobot/theme/app_theme.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Fixtures
  // ---------------------------------------------------------------------------

  ReportReadiness readyReadiness() => ReportReadiness(
        inspectionId: 'insp-1',
        organizationId: 'org-1',
        userId: 'user-1',
        status: ReportReadinessStatus.ready,
        missingItems: const [],
        computedAt: DateTime.utc(2026, 3, 4),
      );

  ReportReadiness blockedReadiness() => ReportReadiness(
        inspectionId: 'insp-1',
        organizationId: 'org-1',
        userId: 'user-1',
        status: ReportReadinessStatus.blocked,
        missingItems: const ['Exterior Front', 'Exterior Rear'],
        computedAt: DateTime.utc(2026, 3, 4),
      );

  ReportArtifact sampleArtifact() => ReportArtifact(
        id: 'art-1',
        inspectionId: 'insp-1',
        organizationId: 'org-1',
        userId: 'user-1',
        storageBucket: 'bucket',
        storagePath: 'path/to/report.pdf',
        fileName: 'report.pdf',
        contentType: 'application/pdf',
        sizeBytes: 12345,
        retainUntil: DateTime.utc(2027, 3, 4),
        createdAt: DateTime.utc(2026, 3, 4),
        updatedAt: DateTime.utc(2026, 3, 4),
      );

  Widget buildSubject({
    ReportReadiness? readiness,
    bool isComplete = true,
    bool isGenerating = false,
    String? lastPdfPath,
    ReportArtifact? lastArtifact,
    VoidCallback? onGeneratePdf,
    VoidCallback? onDownload,
    VoidCallback? onShare,
  }) {
    return MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(
        body: SingleChildScrollView(
          child: PdfDeliveryView(
            readiness: readiness ?? readyReadiness(),
            isComplete: isComplete,
            isGenerating: isGenerating,
            lastPdfPath: lastPdfPath,
            lastArtifact: lastArtifact,
            onGeneratePdf: onGeneratePdf ?? () {},
            onDownload: onDownload ?? () {},
            onShare: onShare ?? () {},
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tests
  // ---------------------------------------------------------------------------

  group('PdfDeliveryView', () {
    testWidgets('generate button disabled when not ready', (tester) async {
      await tester.pumpWidget(buildSubject(
        readiness: blockedReadiness(),
        isComplete: true,
      ));

      final appButton = tester.widget<AppButton>(
        find.byKey(const ValueKey('generate-pdf-button')),
      );
      expect(appButton.onPressed, isNull);
    });

    testWidgets('generate button enabled when ready and complete', (
      tester,
    ) async {
      var generateCalled = false;
      await tester.pumpWidget(buildSubject(
        readiness: readyReadiness(),
        isComplete: true,
        onGeneratePdf: () => generateCalled = true,
      ));

      final appButton = tester.widget<AppButton>(
        find.byKey(const ValueKey('generate-pdf-button')),
      );
      expect(appButton.onPressed, isNotNull);

      await tester.tap(find.byKey(const ValueKey('generate-pdf-button')));
      await tester.pump();
      expect(generateCalled, isTrue);
    });

    testWidgets('generate button disabled when not complete', (tester) async {
      await tester.pumpWidget(buildSubject(
        readiness: readyReadiness(),
        isComplete: false,
      ));

      final appButton = tester.widget<AppButton>(
        find.byKey(const ValueKey('generate-pdf-button')),
      );
      expect(appButton.onPressed, isNull);
    });

    testWidgets('generate button shows loading spinner when generating', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(
        isGenerating: true,
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // AppButton sets onPressed=null internally when isLoading=true
      final appButton = tester.widget<AppButton>(
        find.byKey(const ValueKey('generate-pdf-button')),
      );
      expect(appButton.isLoading, isTrue);
    });

    testWidgets('last PDF path displays as SelectableText', (tester) async {
      await tester.pumpWidget(buildSubject(
        lastPdfPath: '/path/to/report.pdf',
      ));

      expect(find.byType(SelectableText), findsOneWidget);
      expect(find.text('Last PDF: /path/to/report.pdf'), findsOneWidget);
    });

    testWidgets('download/share buttons appear when lastArtifact present', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(
        lastArtifact: sampleArtifact(),
      ));

      expect(
        find.byKey(const ValueKey('delivery-download-button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('delivery-secure-share-button')),
        findsOneWidget,
      );
      expect(find.text('Download'), findsOneWidget);
      expect(find.text('Secure Share'), findsOneWidget);
    });

    testWidgets('download/share buttons hidden when no artifact', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(
        lastArtifact: null,
      ));

      expect(
        find.byKey(const ValueKey('delivery-download-button')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('delivery-secure-share-button')),
        findsNothing,
      );
    });

    testWidgets('ValueKeys are present on all key widgets', (tester) async {
      await tester.pumpWidget(buildSubject(
        lastArtifact: sampleArtifact(),
        lastPdfPath: '/some/path.pdf',
      ));

      expect(
        find.byKey(const ValueKey('generate-pdf-button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('delivery-download-button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('delivery-secure-share-button')),
        findsOneWidget,
      );
    });

    testWidgets('download callback fires when tapped', (tester) async {
      var downloadCalled = false;
      await tester.pumpWidget(buildSubject(
        lastArtifact: sampleArtifact(),
        onDownload: () => downloadCalled = true,
      ));

      await tester.tap(find.byKey(const ValueKey('delivery-download-button')));
      await tester.pump();
      expect(downloadCalled, isTrue);
    });

    testWidgets('share callback fires when tapped', (tester) async {
      var shareCalled = false;
      await tester.pumpWidget(buildSubject(
        lastArtifact: sampleArtifact(),
        onShare: () => shareCalled = true,
      ));

      await tester.tap(
        find.byKey(const ValueKey('delivery-secure-share-button')),
      );
      await tester.pump();
      expect(shareCalled, isTrue);
    });
  });
}
