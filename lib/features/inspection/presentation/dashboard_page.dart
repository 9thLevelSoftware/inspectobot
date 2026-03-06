import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:inspectobot/app/navigation_service.dart';
import 'package:inspectobot/app/routes.dart';
import 'package:inspectobot/features/inspection/data/inspection_repository.dart';
import 'package:inspectobot/features/inspection/domain/inspection_draft.dart';
import 'package:inspectobot/features/inspection/domain/inspection_wizard_state.dart';
import 'package:inspectobot/features/media/media_sync_remote_store.dart';
import 'package:inspectobot/features/media/pending_media_sync_store.dart';
import 'package:inspectobot/features/sync/sync_scheduler.dart';

class DashboardPage extends StatefulWidget {
  DashboardPage({
    super.key,
    required this.organizationId,
    required this.userId,
    InspectionRepository? repository,
    SyncScheduler? syncScheduler,
    this.mediaSyncRemoteStore,
    this.pendingMediaSyncStore,
  })  : repository = repository ?? InspectionRepository.live(),
        syncScheduler = syncScheduler;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('InspectoBot')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Florida Insurance Inspection Workflow',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text('Start a new inspection to capture required items.'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () async {
                await GetIt.I<NavigationService>().push<void>(
                  AppRoutes.newInspection,
                );
                if (!mounted) {
                  return;
                }
                _refresh();
              },
              icon: const Icon(Icons.add),
              label: const Text('New Inspection'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                GetIt.I<NavigationService>().go(AppRoutes.inspectorIdentity);
              },
              icon: const Icon(Icons.badge_outlined),
              label: const Text('Inspector Identity'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Resume In-Progress Inspections',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<InspectionWizardProgress>>(
                future: _inProgressFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Unable to load in-progress inspections.'),
                    );
                  }
                  final inspections = snapshot.data ?? const <InspectionWizardProgress>[];
                  if (inspections.isEmpty) {
                    return const Center(
                      child: Text('No in-progress inspections yet.'),
                    );
                  }
                  return ListView.builder(
                    itemCount: inspections.length,
                    itemBuilder: (context, index) {
                      final inspection = inspections[index];
                      final wizardState = InspectionWizardState(
                        enabledForms: inspection.enabledForms,
                        snapshot: inspection.snapshot,
                      );
                      final resumeStep = wizardState.resolveNextIncompleteStep();
                      return Card(
                        child: ListTile(
                          title: Text(inspection.clientName),
                          subtitle: Text(
                            '${inspection.propertyAddress}\nResume at last incomplete step ${resumeStep + 1}',
                          ),
                          isThreeLine: true,
                          trailing: FilledButton(
                            onPressed: () => _resumeInspection(inspection),
                            child: const Text('Resume'),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}