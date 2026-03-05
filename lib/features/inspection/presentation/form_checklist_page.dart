import 'package:flutter/material.dart';

import '../../media/media_capture_service.dart';
import '../../media/media_sync_task.dart';
import '../../delivery/domain/report_artifact.dart';
import '../../delivery/services/delivery_service.dart';
import '../../pdf/cloud_pdf_service.dart';
import '../../pdf/on_device_pdf_service.dart';
import '../../pdf/pdf_generation_input.dart';
import '../../pdf/pdf_orchestrator.dart';
import '../../signing/data/report_signature_evidence_repository.dart';
import '../../signing/domain/report_signature_evidence.dart';
import '../../identity/data/signature_repository.dart';
import '../data/inspection_repository.dart';
import '../domain/evidence_requirement.dart';
import '../domain/form_requirements.dart';
import '../domain/inspection_draft.dart';
import '../domain/inspection_wizard_state.dart';
import '../domain/report_readiness.dart';
import '../domain/required_photo_category.dart';

class FormChecklistPage extends StatefulWidget {
  FormChecklistPage({
    super.key,
    required this.draft,
    InspectionRepository? repository,
    SignatureRepository? signatureRepository,
    ReportSignatureEvidenceRepository? signatureEvidenceRepository,
    DeliveryService? deliveryService,
    PdfOrchestrator? pdfOrchestrator,
  })  : repository = repository ?? InspectionRepository.live(),
        signatureRepository = signatureRepository ?? SignatureRepository.live(),
        signatureEvidenceRepository =
            signatureEvidenceRepository ?? ReportSignatureEvidenceRepository.live(),
        deliveryService = deliveryService ?? DeliveryService.live(),
        pdfOrchestrator = pdfOrchestrator;

  final InspectionDraft draft;
  final InspectionRepository repository;
  final SignatureRepository signatureRepository;
  final ReportSignatureEvidenceRepository signatureEvidenceRepository;
  final DeliveryService deliveryService;
  final PdfOrchestrator? pdfOrchestrator;

  @override
  State<FormChecklistPage> createState() => _FormChecklistPageState();
}

class _FormChecklistPageState extends State<FormChecklistPage> {
  final _mediaCapture = MediaCaptureService();
  late final PdfOrchestrator _pdfOrchestrator;

  late WizardProgressSnapshot _snapshot;
  late int _currentStepIndex;
  bool _isGenerating = false;
  bool _isSavingProgress = false;
  String? _lastPdfPath;
  ReportReadiness? _persistedReadiness;
  ReportArtifact? _lastArtifact;

  InspectionRepository get _repository => widget.repository;
  SignatureRepository get _signatureRepository => widget.signatureRepository;
  ReportSignatureEvidenceRepository get _signatureEvidenceRepository =>
      widget.signatureEvidenceRepository;
  DeliveryService get _deliveryService => widget.deliveryService;

  InspectionWizardState get _wizardState => InspectionWizardState(
    enabledForms: widget.draft.enabledForms,
    snapshot: _snapshot,
  );

  @override
  void initState() {
    super.initState();
    _pdfOrchestrator = widget.pdfOrchestrator ??
        PdfOrchestrator(
          onDevice: OnDevicePdfService(),
          cloud: const CloudPdfService(),
          readinessLookup: (input) => _repository.fetchReportReadiness(
            inspectionId: input.inspectionId,
            organizationId: input.organizationId,
            userId: input.userId,
          ),
        );
    _snapshot = widget.draft.wizardSnapshot;
    _hydrateCapturedFromSnapshot();
    final requestedStep = widget.draft.initialStepIndex;
    final maxStep = _wizardState.steps.length - 1;
    _currentStepIndex = requestedStep.clamp(0, maxStep < 0 ? 0 : maxStep);
    _loadReadiness();
  }

  Future<void> _loadReadiness() async {
    final existing = await _repository.fetchReportReadiness(
      inspectionId: widget.draft.inspectionId,
      organizationId: widget.draft.organizationId,
      userId: widget.draft.userId,
    );
    if (existing != null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _persistedReadiness = existing;
      });
      return;
    }
    await _syncReadinessFromSnapshot();
  }

  Future<void> _syncReadinessFromSnapshot() async {
    final evaluated = _evaluateReadiness();
    final saved = await _repository.upsertReportReadiness(evaluated);
    if (!mounted) {
      return;
    }
    setState(() {
      _persistedReadiness = saved;
    });
  }

  ReportReadiness _evaluateReadiness() {
    return ReportReadiness.evaluate(
      inspectionId: widget.draft.inspectionId,
      organizationId: widget.draft.organizationId,
      userId: widget.draft.userId,
      enabledForms: widget.draft.enabledForms,
      completion: _snapshot.completion,
      branchContext: _snapshot.branchContext,
    );
  }

  void _hydrateCapturedFromSnapshot() {
    for (final entry in _snapshot.completion.entries) {
      if (entry.value != true) {
        continue;
      }
      final category = _categoryForRequirementKey(entry.key);
      if (category != null) {
        widget.draft.capturedCategories.add(category);
      }
    }
  }

  RequiredPhotoCategory? _categoryForRequirementKey(String key) {
    final normalizedKey = key.contains('#') ? key.substring(0, key.indexOf('#')) : key;
    for (final category in RequiredPhotoCategory.values) {
      final photoKey = FormRequirements.requirementKeyForPhoto(category);
      if (photoKey == normalizedKey) {
        return category;
      }
    }
    return null;
  }

  Future<void> _capture(EvidenceRequirement requirement) async {
    final category = requirement.category;
    if (category == null) {
      return;
    }
    final result = await _mediaCapture.captureRequiredPhoto(
      inspectionId: widget.draft.inspectionId,
      organizationId: widget.draft.organizationId,
      userId: widget.draft.userId,
      category: category,
      requirementKey: requirement.key,
      mediaType: requirement.mediaType == EvidenceMediaType.document
          ? CapturedMediaType.document
          : CapturedMediaType.photo,
      evidenceInstanceId: requirement.key,
    );
    if (!mounted || result == null) {
      return;
    }

    final completion = Map<String, bool>.from(_snapshot.completion)
      ..[requirement.key] = true;
    setState(() {
      widget.draft.capturedCategories.add(category);
      widget.draft.capturedPhotoPaths[category] = result.filePath;
      widget.draft.capturedEvidencePaths[requirement.key] = <String>[result.filePath];
      _snapshot = _snapshot.copyWith(completion: completion);
    });
    await _syncReadinessFromSnapshot();
  }

  Future<void> _saveProgress({required bool markComplete}) async {
    final updated = _snapshot.copyWith(
      lastStepIndex: _currentStepIndex,
      status: markComplete
          ? WizardProgressStatus.complete
          : WizardProgressStatus.inProgress,
      branchContext: <String, dynamic>{
        'enabled_forms': widget.draft.enabledForms
            .map((form) => form.code)
            .toList(growable: false),
      },
    );
    await _repository.updateWizardProgress(
      inspectionId: widget.draft.inspectionId,
      organizationId: widget.draft.organizationId,
      userId: widget.draft.userId,
      snapshot: updated,
    );
    await _repository.upsertReportReadiness(_evaluateReadiness());
    _snapshot = updated;
  }

  Future<void> _continueStep() async {
    if (_isSavingProgress) {
      return;
    }
    final state = _wizardState;
    if (!state.canAdvanceFrom(_currentStepIndex)) {
      final step = state.steps[_currentStepIndex];
      final missing = step.requirements
          .where((requirement) => _snapshot.completion[requirement.key] != true)
          .map((requirement) => requirement.label)
          .join(', ');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Complete required items before continuing: $missing')),
      );
      return;
    }

    setState(() => _isSavingProgress = true);
    try {
      final isLastStep = _currentStepIndex >= state.steps.length - 1;
      await _saveProgress(markComplete: isLastStep);
      if (!mounted) {
        return;
      }
      if (isLastStep) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inspection wizard complete.')), 
        );
        return;
      }
      setState(() {
        _currentStepIndex += 1;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to save progress. Please retry.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSavingProgress = false);
      }
    }
  }

  Future<void> _generatePdf() async {
    setState(() => _isGenerating = true);
    try {
      final input = PdfGenerationInput(
        inspectionId: widget.draft.inspectionId,
        organizationId: widget.draft.organizationId,
        userId: widget.draft.userId,
        clientName: widget.draft.clientName,
        propertyAddress: widget.draft.propertyAddress,
        enabledForms: widget.draft.enabledForms,
        capturedCategories: widget.draft.capturedCategories,
        wizardCompletion: _snapshot.completion,
        branchContext: _snapshot.branchContext,
      );
      final file = await _pdfOrchestrator.generate(input);
      final signature = await _signatureRepository.loadSignature(
        organizationId: widget.draft.organizationId,
        userId: widget.draft.userId,
      );
      if (signature == null) {
        throw StateError('Stored inspector signature metadata is required.');
      }
      await _signatureEvidenceRepository.persist(
        input: input,
        signerRole: 'inspector',
        signatureHash: signature.fileHash,
        signedAt: DateTime.now().toUtc(),
        attribution: const ReportSignatureAttribution(
          appVersion: null,
          device: null,
          sessionId: null,
          network: null,
        ),
      );
      final signatureHash = signature.fileHash;
      final length = await file.length();
      final artifact = await _deliveryService.persistGeneratedArtifact(
        input: input,
        localFilePath: file.path,
        sizeBytes: length,
        signatureHash: signatureHash,
      );
      final sizeKb = (length / 1024).toStringAsFixed(1);
      if (!mounted) {
        return;
      }
      setState(() {
        _lastPdfPath = file.path;
        _lastArtifact = artifact;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF generated (${sizeKb}KB) and delivery saved.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF generation failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _downloadLastArtifact() async {
    final artifact = _lastArtifact;
    if (artifact == null) {
      return;
    }
    try {
      final result = await _deliveryService.startDownload(artifact: artifact);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download link ready: ${result.url}')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $error')),
      );
    }
  }

  Future<void> _shareLastArtifact() async {
    final artifact = _lastArtifact;
    if (artifact == null) {
      return;
    }
    try {
      final result = await _deliveryService.startSecureShare(artifact: artifact);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Secure share link issued: ${result.url}')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Secure share failed: $error')),
      );
    }
  }

  Widget _buildStepContent(InspectionWizardState state) {
    final step = state.steps[_currentStepIndex];
    if (step.requirements.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Review the inspection details and continue through each required form step.',
        ),
      );
    }

    return Column(
      children: step.requirements.map((requirement) {
        final category = requirement.category;
        final captured = _snapshot.completion[requirement.key] == true;
        return Card(
          child: ListTile(
            title: Text(requirement.label),
            subtitle: Text(captured ? 'Captured' : 'Missing required item'),
            trailing: captured
                ? const Icon(Icons.check_circle, color: Colors.green)
                : OutlinedButton(
                    onPressed: category == null ? null : () => _capture(requirement),
                    child: Text(
                      requirement.mediaType == EvidenceMediaType.document
                          ? 'Upload'
                          : 'Capture',
                    ),
                  ),
          ),
        );
      }).toList(growable: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wizardState = _wizardState;
    final summaries = wizardState.buildFormSummaries();
    final currentStep = wizardState.steps[_currentStepIndex];
    final canContinue = wizardState.canAdvanceFrom(_currentStepIndex);
    final isComplete = wizardState.isComplete;
    final readiness = _persistedReadiness ?? _evaluateReadiness();
    final canGenerate = readiness.isReady;
    final isFinalStep = _currentStepIndex >= wizardState.steps.length - 1;

    return Scaffold(
      appBar: AppBar(title: const Text('Guided Inspection Wizard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Inspection for ${widget.draft.clientName}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(widget.draft.propertyAddress),
          const SizedBox(height: 16),
          Text(
            'Step ${_currentStepIndex + 1} of ${wizardState.steps.length}: ${currentStep.title}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildStepContent(wizardState),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: canContinue && !_isSavingProgress ? _continueStep : null,
            child: Text(
              isFinalStep
                  ? (_isSavingProgress ? 'Saving...' : 'Finish Wizard')
                  : (_isSavingProgress ? 'Saving...' : 'Continue to Next Step'),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Per-Form Summary',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...summaries.map((summary) {
            final missingText = summary.isComplete
                ? 'Complete'
                : 'Missing required: ${summary.missingRequirements.map((r) => r.label).join(', ')}';
            return Card(
              child: ListTile(
                title: Text(summary.form.label),
                subtitle: Text(missingText),
                trailing: summary.isComplete
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.error_outline, color: Colors.orange),
              ),
            );
          }),
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const ValueKey('generate-pdf-button'),
            onPressed: isComplete && canGenerate && !_isGenerating
                ? _generatePdf
                : null,
            icon: _isGenerating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.picture_as_pdf),
            label: Text(
              isComplete && canGenerate
                  ? 'Generate PDF'
                  : 'Readiness blocked: ${readiness.missingItems.join(', ')}',
            ),
          ),
          if (_lastPdfPath != null) ...[
            const SizedBox(height: 12),
            SelectableText('Last PDF: $_lastPdfPath'),
          ],
          if (_lastArtifact != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  key: const ValueKey('delivery-download-button'),
                  onPressed: _downloadLastArtifact,
                  icon: const Icon(Icons.download),
                  label: const Text('Download'),
                ),
                OutlinedButton.icon(
                  key: const ValueKey('delivery-secure-share-button'),
                  onPressed: _shareLastArtifact,
                  icon: const Icon(Icons.ios_share),
                  label: const Text('Secure Share'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
