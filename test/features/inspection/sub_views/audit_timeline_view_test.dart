import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/audit/domain/audit_event.dart';
import 'package:inspectobot/features/inspection/presentation/sub_views/audit_timeline_view.dart';
import 'package:inspectobot/theme/app_theme.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Fixtures
  // ---------------------------------------------------------------------------

  AuditEvent makeEvent({
    required String id,
    required String eventType,
    required DateTime occurredAt,
  }) {
    return AuditEvent(
      id: id,
      inspectionId: 'insp-1',
      organizationId: 'org-1',
      userId: 'user-1',
      eventType: eventType,
      occurredAt: occurredAt,
      payload: const {},
      createdAt: DateTime.utc(2026, 3, 4),
    );
  }

  Widget buildSubject({
    List<AuditEvent> auditEvents = const [],
    bool isLoading = false,
    String? errorMessage,
  }) {
    return MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(
        body: SingleChildScrollView(
          child: AuditTimelineView(
            auditEvents: auditEvents,
            isLoading: isLoading,
            errorMessage: errorMessage,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tests
  // ---------------------------------------------------------------------------

  group('AuditTimelineView', () {
    testWidgets('loading state shows loading message', (tester) async {
      await tester.pumpWidget(buildSubject(isLoading: true));

      expect(find.text('Loading audit timeline...'), findsOneWidget);
      expect(
        find.text('Fetching immutable inspection events.'),
        findsOneWidget,
      );
    });

    testWidgets('error state shows error icon and message', (tester) async {
      await tester.pumpWidget(buildSubject(
        errorMessage: 'Unable to load audit timeline right now.',
      ));

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Audit timeline unavailable'), findsOneWidget);
      expect(
        find.text('Unable to load audit timeline right now.'),
        findsOneWidget,
      );
    });

    testWidgets('empty state shows "No audit events recorded yet"', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('No audit events recorded yet'), findsOneWidget);
      expect(find.byIcon(Icons.timeline_outlined), findsOneWidget);
    });

    testWidgets('populated state shows event cards with timeline labels', (
      tester,
    ) async {
      final events = [
        makeEvent(
          id: '1',
          eventType: 'inspection_progress_updated',
          occurredAt: DateTime.utc(2026, 3, 4, 10, 30),
        ),
        makeEvent(
          id: '2',
          eventType: 'signature_persisted',
          occurredAt: DateTime.utc(2026, 3, 4, 11, 0),
        ),
      ];

      await tester.pumpWidget(buildSubject(auditEvents: events));

      expect(find.text('Audit Timeline'), findsOneWidget);
      expect(find.text('Inspection progress updated'), findsOneWidget);
      expect(find.text('Inspector signature captured'), findsOneWidget);
      expect(find.byIcon(Icons.history), findsNWidgets(2));
    });

    testWidgets('max 12 events displayed', (tester) async {
      final events = List.generate(
        15,
        (i) => makeEvent(
          id: 'evt-$i',
          eventType: 'inspection_progress_updated',
          occurredAt: DateTime.utc(2026, 3, 4, i),
        ),
      );

      await tester.pumpWidget(buildSubject(auditEvents: events));

      // Should find exactly 12 history icons (one per displayed event)
      expect(find.byIcon(Icons.history), findsNWidgets(12));
    });

    testWidgets('timestamp formatting is correct', (tester) async {
      // Test the static helper directly
      final formatted = AuditTimelineView.formatAuditTimestamp(
        DateTime.utc(2026, 3, 4, 9, 5),
      );

      // The output depends on local timezone, but the format should be
      // YYYY-MM-DD HH:MM
      expect(formatted, matches(RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$')));
    });

    testWidgets('event cards display formatted timestamps', (tester) async {
      final event = makeEvent(
        id: '1',
        eventType: 'delivery_artifact_saved',
        occurredAt: DateTime.utc(2026, 3, 4, 14, 30),
      );

      await tester.pumpWidget(buildSubject(auditEvents: [event]));

      expect(find.text('Report artifact saved'), findsOneWidget);
      // Verify the timestamp text exists (format depends on local timezone)
      final expectedTimestamp = AuditTimelineView.formatAuditTimestamp(
        event.occurredAt,
      );
      expect(find.text(expectedTimestamp), findsOneWidget);
    });
  });
}
