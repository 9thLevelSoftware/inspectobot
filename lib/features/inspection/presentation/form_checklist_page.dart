import 'package:flutter/material.dart';

import '../../media/media_capture_service.dart';
import '../../pdf/cloud_pdf_service.dart';
import '../../pdf/on_device_pdf_service.dart';
import '../../pdf/pdf_generation_input.dart';
import '../../pdf/pdf_orchestrator.dart';
import '../data/inspection_repository.dart';
import '../domain/form_requirements.dart';
import '../domain/inspection_draft.dart';
import '../domain/inspection_wizard_state.dart';
import '../domain/required_photo_category.dart';

class FormChecklistPage extends StatefulWidget {
  FormChecklistPage({
    super.key,
    required this.draft,
    InspectionRepository? repository,
  }) : repository = repository ?? InspectionRepository.live();

  final InspectionDraft draft;
  final InspectionRepository repository;

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

  InspectionRepository get _repository => widget.repository;

  InspectionWizardState get _wizardState => InspectionWizardState(
    enabledForms: widget.draft.enabledForms,
    snapshot: _snapshot,
  );

  @override
  void initState() {
    super.initState();
    _pdfOrchestrator = PdfOrchestrator(
      onDevice: const OnDevicePdfService(),
      cloud: const CloudPdfService(),
    );
    _snapshot = widget.draft.wizardSnapshot;
    _hydrateCapturedFromSnapshot();
    final requestedStep = widget.draft.initialStepIndex;
    final maxStep = _wizardState.steps.length - 1;
    _currentStepIndex = requestedStep.clamp(0, maxStep < 0 ? 0 : maxStep);
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
    const prefix = 'photo:';
    if (!key.startsWith(prefix)) {
      return null;
    }
    final categoryName = key.substring(prefix.length);
    for (final category in RequiredPhotoCategory.values) {
      if (category.name == categoryName) {
        return category;
      }
    }
    return null;
  }

  Future<void> _capture(RequiredPhotoCategory category) async {
    final result = await _mediaCapture.captureRequiredPhoto(
      inspectionId: widget.draft.inspectionId,
      category: category,
    );
    if (!mounted || result == null) {
      return;
    }

    final completion = Map<String, bool>.from(_snapshot.completion)
      ..[FormRequirements.requirementKeyForPhoto(category)] = true;
    setState(() {
      widget.draft.capturedCategories.add(category);
      widget.draft.capturedPhotoPaths[category] = result.filePath;
      _snapshot = _snapshot.copyWith(completion: completion);
    });
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
    _snapshot = updated;
  }

  Future<void> _continueStep() async {
    if (_isSavingProgress) {
      return;
    }
    final state = _wizardState;
    if (!state.canAdvanceFrom(_currentStepIndex)) {
      final step = state.steps[_currentStepIndex];
      final missing = step.requiredCategories
          .where(
            (category) =>
                _snapshot
                    .completion[FormRequirements.requirementKeyForPhoto(category)] !=
                true,
          )
          .map((category) => category.label)
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
      final file = await _pdfOrchestrator.generate(
        PdfGenerationInput(
          clientName: widget.draft.clientName,
          propertyAddress: widget.draft.propertyAddress,
          enabledForms: widget.draft.enabledForms,
          capturedCategories: widget.draft.capturedCategories,
        ),
      );
      final length = await file.length();
      final sizeKb = (length / 1024).toStringAsFixed(1);
      if (!mounted) {
        return;
      }
      setState(() {
        _lastPdfPath = file.path;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF generated (${sizeKb}KB): ${file.path}')),
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

  Widget _buildStepContent(InspectionWizardState state) {
    final step = state.steps[_currentStepIndex];
    if (step.requiredCategories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Review the inspection details and continue through each required form step.',
        ),
      );
    }

    return Column(
      children: step.requiredCategories.map((category) {
        final captured = widget.draft.capturedCategories.contains(category);
        return Card(
          child: ListTile(
            title: Text(category.label),
            subtitle: Text(captured ? 'Captured' : 'Missing required item'),
            trailing: captured
                ? const Icon(Icons.check_circle, color: Colors.green)
                : OutlinedButton(
                    onPressed: () => _capture(category),
                    child: const Text('Capture'),
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
                : 'Missing required: ${summary.missingCategories.map((c) => c.label).join(', ')}';
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
            onPressed: isComplete && !_isGenerating ? _generatePdf : null,
            icon: _isGenerating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.picture_as_pdf),
            label: Text(
              isComplete
                  ? 'Generate PDF'
                  : 'Complete all required items before PDF',
            ),
          ),
          if (_lastPdfPath != null) ...[
            const SizedBox(height: 12),
            SelectableText('Last PDF: $_lastPdfPath'),
          ],
        ],
      ),
    );
  }
}
