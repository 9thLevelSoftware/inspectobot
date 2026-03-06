import 'package:flutter/material.dart';

import 'package:inspectobot/theme/theme.dart';

import '../../../audit/domain/audit_event.dart';

/// Renders the audit event timeline with loading, error, empty, and
/// populated states.
///
/// Pure [StatelessWidget] -- receives all data from the parent.
class AuditTimelineView extends StatelessWidget {
  const AuditTimelineView({
    super.key,
    required this.auditEvents,
    required this.isLoading,
    this.errorMessage,
  });

  final List<AuditEvent> auditEvents;
  final bool isLoading;
  final String? errorMessage;

  /// Max events displayed in the timeline.
  static const int maxDisplayedEvents = 12;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Card(
        child: ListTile(
          title: Text('Loading audit timeline...'),
          subtitle: Text('Fetching immutable inspection events.'),
        ),
      );
    }

    if (errorMessage != null) {
      return Card(
        child: ListTile(
          leading: Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
          title: const Text('Audit timeline unavailable'),
          subtitle: Text(errorMessage!),
        ),
      );
    }

    if (auditEvents.isEmpty) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.timeline_outlined),
          title: Text('No audit events recorded yet'),
          subtitle: Text(
            'Timeline entries appear after progress, signing, or delivery actions.',
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Audit Timeline',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: AppSpacing.spacingSm),
        ...auditEvents.take(maxDisplayedEvents).map(
              (event) => Card(
                child: ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(event.timelineLabel),
                  subtitle: Text(formatAuditTimestamp(event.occurredAt)),
                ),
              ),
            ),
      ],
    );
  }

  /// Formats a [DateTime] for display in the audit timeline.
  static String formatAuditTimestamp(DateTime value) {
    final local = value.toLocal();
    String twoDigits(int number) => number.toString().padLeft(2, '0');
    return '${local.year}-${twoDigits(local.month)}-${twoDigits(local.day)} '
        '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
  }
}
