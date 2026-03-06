import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:inspectobot/app/navigation_service.dart';
import 'package:inspectobot/app/routes.dart';
import 'package:inspectobot/common/widgets/app_button.dart';
import 'package:inspectobot/common/widgets/empty_state.dart';
import 'package:inspectobot/common/widgets/error_banner.dart';
import 'package:inspectobot/common/widgets/reach_zone_scaffold.dart';
import 'package:inspectobot/common/widgets/section_card.dart';
import 'package:inspectobot/common/widgets/section_header.dart';
import 'package:inspectobot/common/widgets/status_badge.dart';
import 'package:inspectobot/features/inspection/data/inspection_repository.dart';
import 'package:inspectobot/features/inspection/domain/inspection_draft.dart';
import 'package:inspectobot/features/inspection/domain/inspection_wizard_state.dart';
import 'package:inspectobot/features/media/media_sync_remote_store.dart';
import 'package:inspectobot/features/media/pending_media_sync_store.dart';
import 'package:inspectobot/features/sync/sync_scheduler.dart';
import 'package:inspectobot/theme/theme.dart';

class DashboardPage extends StatefulWidget {
  DashboardPage({
    super.key,
    required this.organizationId,
    required this.userId,
    InspectionRepository? repository,
    this.syncScheduler,
    this.mediaSyncRemoteStore,
    this.pendingMediaSyncStore,
  }) : repository = repository ?? InspectionRepository.live();

  final InspectionRepository repository;
  final SyncScheduler? syncScheduler;
  final MediaSyncRemoteStore? mediaSyncRemoteStore;
  final PendingMediaSyncStore? pendingMediaSyncStore;
  final String organizationId;
  final String userId;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<List<InspectionWizardProgress>> _inProgressFuture;

  InspectionRepository get _repository => widget.repository;

  @override
  void initState() {
    super.initState();
    _inProgressFuture = _loadInProgress();
    _triggerBackgroundSync();
  }

  Future<List<InspectionWizardProgress>> _loadInProgress() {
    return _repository.listInProgressInspections(
      organizationId: widget.organizationId,
      userId: widget.userId,
    );
  }

  void _refresh() {
    setState(() {
      _inProgressFuture = _loadInProgress();
    });
  }

  Future<void> _onRefresh() async {
    final future = _loadInProgress();
    setState(() {
      _inProgressFuture = future;
    });
    await future;
  }

  Future<void> _triggerBackgroundSync() async {
    final scheduler = widget.syncScheduler;
    if (scheduler != null) {
      await scheduler.runPending();
      return;
    }
    try {
      await SyncScheduler.instance.runPending();
    } catch (_) {
      // Background sync should not block dashboard rendering.
    }
  }

  Future<void> _resumeInspection(InspectionWizardProgress progress) async {
    final wizardState = InspectionWizardState(
      enabledForms: progress.enabledForms,
      snapshot: progress.snapshot,
    );
    final resumeStep = wizardState.resolveNextIncompleteStep();

    // InspectionWizardProgress does not carry the full setup fields
    // (email, phone, date, yearBuilt). Placeholders are used here because
    // the checklist page only needs inspectionId and enabledForms to resume.
    final draft = InspectionDraft(
      inspectionId: progress.inspectionId,
      organizationId: progress.organizationId,
      userId: progress.userId,
      clientName: progress.clientName,
      clientEmail: '',
      clientPhone: '',
      propertyAddress: progress.propertyAddress,
      inspectionDate: DateTime.now().toUtc(),
      yearBuilt: 0,
      enabledForms: progress.enabledForms,
      wizardSnapshot: progress.snapshot,
      initialStepIndex: resumeStep,
    );

    await GetIt.I<NavigationService>().push<void>(
      AppRoutes.inspectionChecklist(progress.inspectionId),
      extra: draft,
    );
    if (!mounted) {
      return;
    }
    _refresh();
  }

  Future<void> _navigateToNewInspection() async {
    await GetIt.I<NavigationService>().push<void>(
      AppRoutes.newInspection,
    );
    if (!mounted) {
      return;
    }
    _refresh();
  }

  /// Derives a display status for an inspection based on its wizard snapshot.
  ///
  /// Draft: snapshot has no meaningful progress (lastStepIndex == 0 and no
  /// completions). Otherwise delegates to [WizardProgressSnapshot.status].
  _InspectionDisplayStatus _inspectionStatus(
    InspectionWizardProgress progress,
  ) {
    final snapshot = progress.snapshot;
    if (snapshot.status == WizardProgressStatus.complete) {
      return _InspectionDisplayStatus.complete;
    }
    // Treat as draft when there is no meaningful progress.
    if (snapshot.lastStepIndex == 0 && snapshot.completion.isEmpty) {
      return _InspectionDisplayStatus.draft;
    }
    return _InspectionDisplayStatus.inProgress;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'InspectoBot',
          style: textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Inspector Identity',
            onPressed: () {
              GetIt.I<NavigationService>().go(AppRoutes.inspectorIdentity);
            },
          ),
        ],
      ),
      body: ReachZoneScaffold(
        stickyBottom: AppButton(
          label: 'New Inspection',
          icon: Icons.add,
          onPressed: _navigateToNewInspection,
          variant: AppButtonVariant.filled,
          isThumbZone: true,
        ),
        body: FutureBuilder<List<InspectionWizardProgress>>(
          future: _inProgressFuture,
          builder: (context, snapshot) {
            // Loading state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: colorScheme.primary,
                ),
              );
            }

            // Error state
            if (snapshot.hasError) {
              return Padding(
                padding: AppEdgeInsets.pagePadding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const ErrorBanner(
                      message: 'Unable to load inspections.',
                    ),
                    SizedBox(height: AppSpacing.spacingLg),
                    AppButton(
                      label: 'Retry',
                      onPressed: _refresh,
                      variant: AppButtonVariant.outlined,
                    ),
                  ],
                ),
              );
            }

            final inspections =
                snapshot.data ?? const <InspectionWizardProgress>[];

            // Empty state
            if (inspections.isEmpty) {
              return EmptyState(
                icon: Icons.assignment_outlined,
                message:
                    'No inspections yet.\nStart a new inspection to begin capturing required items.',
                actionLabel: 'New Inspection',
                onAction: _navigateToNewInspection,
              );
            }

            // Derive metric counts
            final totalCount = inspections.length;
            var inProgressCount = 0;
            var completedCount = 0;
            for (final inspection in inspections) {
              final status = _inspectionStatus(inspection);
              if (status == _InspectionDisplayStatus.complete) {
                completedCount += 1;
              } else {
                inProgressCount += 1;
              }
            }

            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView.builder(
                padding: AppEdgeInsets.pageHorizontal,
                itemCount: inspections.length + 2, // metrics + header + items
                itemBuilder: (context, index) {
                  // Metrics summary card
                  if (index == 0) {
                    return Padding(
                      padding: EdgeInsets.only(
                        top: AppSpacing.spacingLg,
                      ),
                      child: SectionCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: _MetricCell(
                                value: '$totalCount',
                                label: 'Total',
                              ),
                            ),
                            Expanded(
                              child: _MetricCell(
                                value: '$inProgressCount',
                                label: 'In Progress',
                              ),
                            ),
                            Expanded(
                              child: _MetricCell(
                                value: '$completedCount',
                                label: 'Completed',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Section header
                  if (index == 1) {
                    return const SectionHeader(title: 'Inspections');
                  }

                  // Inspection cards
                  final inspection = inspections[index - 2];
                  final displayStatus = _inspectionStatus(inspection);
                  final isComplete =
                      displayStatus == _InspectionDisplayStatus.complete;

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: AppSpacing.spacingMd,
                    ),
                    child: _InspectionListCard(
                      inspection: inspection,
                      displayStatus: displayStatus,
                      isComplete: isComplete,
                      onTap: () => _resumeInspection(inspection),
                      onAction: () => _resumeInspection(inspection),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Presentation-layer status for inspection cards.
enum _InspectionDisplayStatus { draft, inProgress, complete }

/// A single metric cell for the summary row.
class _MetricCell extends StatelessWidget {
  const _MetricCell({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: tokens.sectionHeader),
        SizedBox(height: AppSpacing.spacingXxs),
        Text(label, style: tokens.fieldLabel),
      ],
    );
  }
}

/// An inspection card built with [SectionCard] and [StatusBadge].
class _InspectionListCard extends StatelessWidget {
  const _InspectionListCard({
    required this.inspection,
    required this.displayStatus,
    required this.isComplete,
    required this.onTap,
    required this.onAction,
  });

  final InspectionWizardProgress inspection;
  final _InspectionDisplayStatus displayStatus;
  final bool isComplete;
  final VoidCallback onTap;
  final VoidCallback onAction;

  StatusBadge _buildBadge() {
    return switch (displayStatus) {
      _InspectionDisplayStatus.draft => const StatusBadge(
          label: 'Draft',
          type: StatusBadgeType.neutral,
          highContrast: true,
        ),
      _InspectionDisplayStatus.inProgress => const StatusBadge(
          label: 'In Progress',
          type: StatusBadgeType.warning,
          highContrast: true,
        ),
      _InspectionDisplayStatus.complete => const StatusBadge(
          label: 'Complete',
          type: StatusBadgeType.success,
          highContrast: true,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tokens = context.appTokens;

    return SectionCard(
      density: SectionCardDensity.compact,
      child: InkWell(
        borderRadius: AppRadii.md,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppSpacing.minTapTarget,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header row: client name + status badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      inspection.clientName,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: AppSpacing.spacingSm),
                  _buildBadge(),
                ],
              ),
              SizedBox(height: AppSpacing.spacingXs),

              // Body: property address
              Text(
                inspection.propertyAddress,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: AppSpacing.spacingSm),

              // Footer row: timestamp + action button
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'ID: ${inspection.inspectionId.length > 8 ? inspection.inspectionId.substring(0, 8) : inspection.inspectionId}',
                      style: tokens.timestamp,
                    ),
                  ),
                  isComplete
                      ? AppButton(
                          label: 'View',
                          onPressed: onAction,
                          variant: AppButtonVariant.text,
                        )
                      : AppButton(
                          label: 'Resume',
                          onPressed: onAction,
                          variant: AppButtonVariant.outlined,
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
