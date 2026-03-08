import 'package:flutter/material.dart';

import 'package:inspectobot/common/widgets/widgets.dart';
import 'package:inspectobot/theme/theme.dart';

import '../../media/media_capture_service.dart';
import '../../media/pending_media_sync_store.dart';
import '../../media/media_sync_remote_store.dart';
import '../../delivery/services/delivery_service.dart';
import '../../audit/data/audit_event_repository.dart';
import '../../pdf/cloud_pdf_service.dart';
import '../../pdf/pdf_orchestrator.dart';
import '../../signing/data/report_signature_evidence_repository.dart';
import '../../identity/data/signature_repository.dart';
import '../data/inspection_repository.dart';
import '../domain/evidence_requirement.dart';
import '../domain/form_type.dart';
import '../domain/inspection_draft.dart';
import 'controllers/inspection_session_controller.dart';
import 'sub_views/wizard_navigation_view.dart';
import 'sub_views/evidence_capture_view.dart';
import 'sub_views/pdf_delivery_view.dart';
import 'sub_views/audit_timeline_view.dart';

class FormChecklistPage extends StatefulWidget {
  FormChecklistPage({
    super.key,
    required this.draft,
    InspectionRepository? repository,
    SignatureRepository? signatureRepository,
    ReportSignatureEvidenceRepository? signatureEvidenceRepository,
    DeliveryService? deliveryService,
    this.mediaSyncRemoteStore,
    PendingMediaSyncStore? pendingMediaSyncStore,
    this.pdfOrchestrator,
    this.cloudPdfService,
    AuditEventRepository? auditRepository,
    this.mediaCapture,
  })  : repository = repository ?? InspectionRepository.live(),
        signatureRepository =
            signatureRepository ?? SignatureRepository.live(),
        signatureEvidenceRepository = signatureEvidenceRepository ??
            ReportSignatureEvidenceRepository.live(),
        deliveryService = deliveryService ?? DeliveryService.live(),
        auditRepository = auditRepository ?? AuditEventRepository.live(),
        pendingMediaSyncStore =
            pendingMediaSyncStore ?? PendingMediaSyncStore();

  final InspectionDraft draft;
  final InspectionRepository repository;
  final SignatureRepository signatureRepository;
  final ReportSignatureEvidenceRepository signatureEvidenceRepository;
  final DeliveryService deliveryService;
  final MediaSyncRemoteStore? mediaSyncRemoteStore;
  final PendingMediaSyncStore pendingMediaSyncStore;
  final PdfOrchestrator? pdfOrchestrator;
  final CloudPdfService? cloudPdfService;
  final AuditEventRepository auditRepository;
  final MediaCaptureService? mediaCapture;

  @override
  State<FormChecklistPage> createState() => _FormChecklistPageState();
}

class _FormChecklistPageState extends State<FormChecklistPage> {
  late final InspectionSessionController _controller;
  int _activeTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = InspectionSessionController(
      draft: widget.draft,
      repository: widget.repository,
      signatureRepository: widget.signatureRepository,
      signatureEvidenceRepository: widget.signatureEvidenceRepository,
      deliveryService: widget.deliveryService,
      mediaSyncRemoteStore: widget.mediaSyncRemoteStore,
      pendingMediaSyncStore: widget.pendingMediaSyncStore,
      pdfOrchestrator: widget.pdfOrchestrator,
      cloudPdfService: widget.cloudPdfService,
      auditRepository: widget.auditRepository,
      mediaCapture: widget.mediaCapture,
    );
    _controller.onStateChanged = () {
      if (mounted) setState(() {});
    };
    _controller.initialize();
  }

  // ---------------------------------------------------------------------------
  // Callback wiring
  // ---------------------------------------------------------------------------

  Future<void> _handleContinue() async {
    final result = await _controller.continueStep();
    if (!mounted) return;
    switch (result) {
      case ContinueStepResult.blocked:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Complete all required items before continuing.'),
          ),
        );
      case ContinueStepResult.finished:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inspection wizard complete.')),
        );
      case ContinueStepResult.error:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to save progress. Please retry.'),
          ),
        );
      case ContinueStepResult.advanced:
        break; // Normal advancement, no snackbar needed
    }
  }

  Future<void> _handleCapture(EvidenceRequirement requirement) async {
    await _controller.capture(requirement);
  }

  Future<void> _handleGeneratePdf() async {
    final result = await _controller.generatePdf();
    if (!mounted) return;
    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('PDF generated (${result.sizeKb}KB) and delivery saved.'),
        ),
      );
    } else if (result.isCloudTerminalFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cloud PDF generation failed and on-device fallback was not attempted.',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'PDF generation failed.'),
        ),
      );
    }
  }

  Future<void> _handleDownload() async {
    final result = await _controller.downloadArtifact();
    if (!mounted) return;
    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download link ready: ${result.url}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Download failed.'),
        ),
      );
    }
  }

  Future<void> _handleShare() async {
    final result = await _controller.shareArtifact();
    if (!mounted) return;
    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Secure share link issued: ${result.url}'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Secure share failed.'),
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Tab navigation
  // ---------------------------------------------------------------------------

  Widget _buildTabSelector() {
    return SegmentedButton<int>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment<int>(value: 0, label: Text('Steps')),
        ButtonSegment<int>(value: 1, label: Text('Summary')),
        ButtonSegment<int>(value: 2, label: Text('Report')),
        ButtonSegment<int>(value: 3, label: Text('Timeline')),
      ],
      selected: {_activeTabIndex},
      onSelectionChanged: (selection) {
        setState(() {
          _activeTabIndex = selection.first;
        });
      },
    );
  }

  Widget _buildActiveView() {
    switch (_activeTabIndex) {
      case 0:
        return WizardNavigationView(
          wizardState: _controller.wizardState,
          currentStepIndex: _controller.currentStepIndex,
          snapshot: _controller.snapshot,
          isSavingProgress: _controller.isSavingProgress,
          onCapture: _handleCapture,
          onContinue: _handleContinue,
          onSetBranchFlag: _controller.setBranchFlag,
          formData: _controller.draft.formData,
          onFieldChanged: (FormType form, String key, dynamic value) {
            _controller.setFormFieldValue(form, key, value);
            setState(() {});
          },
        );
      case 1:
        return EvidenceCaptureView(
          wizardState: _controller.wizardState,
        );
      case 2:
        return PdfDeliveryView(
          readiness: _controller.effectiveReadiness,
          isComplete: _controller.wizardState.isComplete,
          isGenerating: _controller.isGenerating,
          lastPdfPath: _controller.lastPdfPath,
          lastArtifact: _controller.lastArtifact,
          onGeneratePdf: _handleGeneratePdf,
          onDownload: _handleDownload,
          onShare: _handleShare,
        );
      case 3:
        return AuditTimelineView(
          auditEvents: _controller.auditEvents,
          isLoading: _controller.isLoadingAuditEvents,
          errorMessage: _controller.auditTimelineError,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guided Inspection Wizard')),
      body: Column(
        children: [
          // Fixed header section (doesn't scroll)
          Padding(
            padding: AppEdgeInsets.pageHorizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.spacingLg),
                Text(
                  'Inspection for ${widget.draft.clientName}',
                  style: AppTypography.subsectionTitle,
                ),
                Text(
                  widget.draft.propertyAddress,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: AppSpacing.spacingLg),
                WizardProgressIndicator(
                  currentStep: _controller.currentStepIndex + 1,
                  totalSteps: _controller.wizardState.steps.length,
                  completionPercent: _controller.completionPercent,
                ),
                const SizedBox(height: AppSpacing.spacingLg),
                _buildTabSelector(),
                const SizedBox(height: AppSpacing.spacingSm),
              ],
            ),
          ),
          const Divider(height: 1),
          // Active view with BOUNDED height
          Expanded(
            child: _buildActiveView(),
          ),
        ],
      ),
    );
  }
}
