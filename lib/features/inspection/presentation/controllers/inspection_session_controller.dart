import 'dart:typed_data';

import '../../../media/media_capture_service.dart';
import '../../../media/media_sync_task.dart';
import '../../../media/pending_media_sync_store.dart';
import '../../../media/media_sync_remote_store.dart';
import '../../../delivery/domain/report_artifact.dart';
import '../../../delivery/services/delivery_service.dart';
import '../../../audit/data/audit_event_repository.dart';
import '../../../audit/domain/audit_event.dart';
import '../../../pdf/cloud_pdf_service.dart';
import '../../../pdf/data/pdf_media_resolver.dart';
import '../../../pdf/narrative/narrative_media_resolver.dart';
import '../../../pdf/narrative/narrative_print_theme.dart';
import '../../../pdf/narrative/narrative_report_engine.dart';
import '../../../pdf/narrative/narrative_template_registry.dart';
import '../../../pdf/narrative/templates/general_inspection_template.dart';
import '../../../pdf/narrative/templates/mold_assessment_template.dart';
import '../../../pdf/on_device_pdf_service.dart';
import '../../../pdf/pdf_generation_input.dart';
import '../../../pdf/pdf_orchestrator.dart';
import '../../../pdf/pdf_strategy.dart';
import '../../../signing/data/report_signature_evidence_repository.dart';
import '../../../signing/domain/report_signature_evidence.dart';
import '../../../identity/data/signature_repository.dart';
import '../../data/inspection_repository.dart';
import '../../domain/evidence_requirement.dart';
import '../../domain/evidence_sharing_matrix.dart';
import '../../domain/form_requirements.dart';
import '../../domain/form_type.dart';
import '../../domain/inspection_draft.dart';
import '../../domain/inspection_wizard_state.dart';
import '../../domain/report_readiness.dart';
import '../../domain/required_photo_category.dart';
import '../../domain/general_inspection_form_data.dart';
import '../../domain/mold_form_data.dart';
import '../../domain/sinkhole_form_data.dart';

// ---------------------------------------------------------------------------
// Result types
// ---------------------------------------------------------------------------

enum ContinueStepResult { advanced, finished, blocked, error }

enum CaptureResult { captured, cancelled, error }

class PdfGenerationResult {
  const PdfGenerationResult({
    required this.success,
    this.errorMessage,
    this.isCloudTerminalFailure = false,
    this.sizeKb,
  });

  final bool success;
  final String? errorMessage;
  final bool isCloudTerminalFailure;
  final String? sizeKb;
}

class DeliveryResult {
  const DeliveryResult({required this.success, this.url, this.errorMessage});

  final bool success;
  final String? url;
  final String? errorMessage;
}

// ---------------------------------------------------------------------------
// InspectionSessionController
// ---------------------------------------------------------------------------

/// Owns all business logic and mutable state extracted from
/// `_FormChecklistPageState`. Pure Dart -- no Flutter imports.
///
/// The parent `StatefulWidget` sets [onStateChanged] to
/// `() => setState(() {})` so that every state mutation triggers a rebuild.
class InspectionSessionController {
  InspectionSessionController({
    required this.draft,
    InspectionRepository? repository,
    SignatureRepository? signatureRepository,
    ReportSignatureEvidenceRepository? signatureEvidenceRepository,
    DeliveryService? deliveryService,
    MediaSyncRemoteStore? mediaSyncRemoteStore,
    PendingMediaSyncStore? pendingMediaSyncStore,
    PdfOrchestrator? pdfOrchestrator,
    CloudPdfService? cloudPdfService,
    AuditEventRepository? auditRepository,
    MediaCaptureService? mediaCapture,
  })  : _repository = repository ?? InspectionRepository.live(),
        _signatureRepository =
            signatureRepository ?? SignatureRepository.live(),
        _signatureEvidenceRepository = signatureEvidenceRepository ??
            ReportSignatureEvidenceRepository.live(),
        _deliveryService = deliveryService ?? DeliveryService.live(),
        _mediaSyncRemoteStore = mediaSyncRemoteStore,
        _pendingMediaSyncStore =
            pendingMediaSyncStore ?? PendingMediaSyncStore(),
        _auditRepository = auditRepository ?? AuditEventRepository.live(),
        _mediaCapture = mediaCapture ?? MediaCaptureService(),
        _providedPdfOrchestrator = pdfOrchestrator,
        _cloudPdfService = cloudPdfService;

  final InspectionDraft draft;

  // -- Dependencies ----------------------------------------------------------

  final InspectionRepository _repository;
  final SignatureRepository _signatureRepository;
  final ReportSignatureEvidenceRepository _signatureEvidenceRepository;
  final DeliveryService _deliveryService;
  final MediaSyncRemoteStore? _mediaSyncRemoteStore;
  final PendingMediaSyncStore _pendingMediaSyncStore;
  final AuditEventRepository _auditRepository;
  final MediaCaptureService _mediaCapture;
  final PdfOrchestrator? _providedPdfOrchestrator;
  final CloudPdfService? _cloudPdfService;

  late final PdfOrchestrator _pdfOrchestrator;

  // -- Callback hook ---------------------------------------------------------

  /// Parent sets this to `() => setState(() {})`.
  void Function()? onStateChanged;

  // -- State fields (public getters, private setters) ------------------------

  WizardProgressSnapshot _snapshot = WizardProgressSnapshot.empty;
  WizardProgressSnapshot get snapshot => _snapshot;

  int _currentStepIndex = 0;
  int get currentStepIndex => _currentStepIndex;

  bool _isGenerating = false;
  bool get isGenerating => _isGenerating;

  bool _isSavingProgress = false;
  bool get isSavingProgress => _isSavingProgress;

  String? _lastPdfPath;
  String? get lastPdfPath => _lastPdfPath;

  ReportReadiness? _persistedReadiness;
  ReportReadiness? get persistedReadiness => _persistedReadiness;

  ReportArtifact? _lastArtifact;
  ReportArtifact? get lastArtifact => _lastArtifact;

  List<AuditEvent> _auditEvents = const <AuditEvent>[];
  List<AuditEvent> get auditEvents => _auditEvents;

  bool _isLoadingAuditEvents = false;
  bool get isLoadingAuditEvents => _isLoadingAuditEvents;

  String? _auditTimelineError;
  String? get auditTimelineError => _auditTimelineError;

  MoldFormData _moldFormData = MoldFormData.empty();
  MoldFormData get moldFormData => _moldFormData;

  GeneralInspectionFormData _generalFormData = GeneralInspectionFormData.empty();
  GeneralInspectionFormData get generalFormData => _generalFormData;

  // -- Computed getters ------------------------------------------------------

  InspectionWizardState get wizardState => InspectionWizardState(
        enabledForms: draft.enabledForms,
        snapshot: _snapshot,
      );

  ReportReadiness get effectiveReadiness =>
      _persistedReadiness ?? _evaluateReadiness();

  /// Percentage of visible requirements that have been captured (0-100).
  ///
  /// The denominator is the total requirement count across all wizard steps,
  /// NOT the size of the completion map (which only tracks captured items).
  int get completionPercent {
    final totalRequirements = wizardState.steps
        .expand((step) => step.requirements)
        .length;
    if (totalRequirements == 0) return 0;
    final captured = snapshot.completion.values.where((v) => v == true).length;
    return ((captured / totalRequirements) * 100).round();
  }

  /// Whether the remediation protocol section should be shown.
  bool get shouldShowRemediationProtocol => _moldFormData.remediationRecommended;

  /// Whether the air sample results section should be shown.
  bool get shouldShowAirSampleResults => _moldFormData.airSamplesTaken;

  // -- Static maps (delegated to domain layer) --------------------------------

  static const Map<FormType, List<String>> branchFlagsByForm =
      FormRequirements.branchFlagsByForm;

  static const Map<String, String> branchFlagLabels =
      FormRequirements.branchFlagLabels;

  // -- Public methods --------------------------------------------------------

  /// Must be called once by parent in `initState`.
  ///
  /// Initialises the PDF orchestrator, hydrates captured state from the
  /// wizard snapshot, clamps the step index, and loads readiness + audit.
  void initialize() {
    final remoteStore = _mediaSyncRemoteStore;
    final PdfRemoteMediaReader? remoteReader = remoteStore == null
        ? null
        : (storagePath) => remoteStore.readBytesByStoragePath(
              storagePath: storagePath,
            );

    final narrativeEngine = NarrativeReportEngine(
      registry: const NarrativeTemplateRegistry(templates: {
        FormType.moldAssessment: MoldAssessmentTemplate(),
        FormType.generalInspection: GeneralInspectionTemplate(),
      }),
      mediaResolver: NarrativeMediaResolver(remoteReadBytes: remoteReader),
      theme: NarrativePrintTheme.standard(),
    );

    _pdfOrchestrator = _providedPdfOrchestrator ??
        PdfOrchestrator(
          onDevice: OnDevicePdfService(
            mediaResolver: PdfMediaResolver(
              remoteReadBytes: remoteReader,
            ),
          ),
          cloud: _cloudPdfService ?? const CloudPdfService(),
          primaryStrategy: PdfStrategy.cloudFallback,
          readinessLookup: (input) => _repository.fetchReportReadiness(
            inspectionId: input.inspectionId,
            organizationId: input.organizationId,
            userId: input.userId,
          ),
          narrative: narrativeEngine,
        );

    _snapshot = draft.wizardSnapshot;
    _hydrateMoldFormData();
    _hydrateGeneralFormData();
    _hydrateCapturedFromSnapshot();

    final requestedStep = draft.initialStepIndex;
    final maxStep = wizardState.steps.length - 1;
    _currentStepIndex = requestedStep.clamp(0, maxStep < 0 ? 0 : maxStep);

    _loadReadiness();
    _loadAuditEvents();
  }

  /// Advances the wizard to the next step or finishes it.
  ///
  /// Returns [ContinueStepResult.blocked] when current step requirements are
  /// incomplete, [ContinueStepResult.error] when save fails.
  Future<ContinueStepResult> continueStep() async {
    if (_isSavingProgress) {
      return ContinueStepResult.blocked;
    }

    final state = wizardState;
    if (!state.canAdvanceFrom(_currentStepIndex)) {
      return ContinueStepResult.blocked;
    }

    _isSavingProgress = true;
    _notify();
    try {
      final isLastStep = _currentStepIndex >= state.steps.length - 1;
      await _saveProgress(markComplete: isLastStep);
      if (isLastStep) {
        _isSavingProgress = false;
        _notify();
        return ContinueStepResult.finished;
      }
      _currentStepIndex += 1;
      _isSavingProgress = false;
      _notify();
      return ContinueStepResult.advanced;
    } catch (_) {
      _isSavingProgress = false;
      _notify();
      return ContinueStepResult.error;
    }
  }

  /// Captures evidence for [requirement] via the media capture service.
  Future<CaptureResult> capture(EvidenceRequirement requirement) async {
    final category = requirement.category;
    if (category == null) {
      return CaptureResult.cancelled;
    }
    final serviceResult = await _mediaCapture.captureRequiredPhoto(
      inspectionId: draft.inspectionId,
      organizationId: draft.organizationId,
      userId: draft.userId,
      category: category,
      requirementKey: requirement.key,
      mediaType: requirement.mediaType == EvidenceMediaType.document
          ? CapturedMediaType.document
          : CapturedMediaType.photo,
      evidenceInstanceId: requirement.key,
    );
    
    // Return cancelled for canceled captures, error for actual errors
    if (serviceResult.isError) {
      // Map capture canceled to cancelled result for backward compatibility
      if (serviceResult.error == MediaCaptureError.captureCanceled) {
        return CaptureResult.cancelled;
      }
      return CaptureResult.error;
    }
    
    if (!serviceResult.isSuccess || serviceResult.result == null) {
      return CaptureResult.cancelled;
    }

    final result = serviceResult.result!;
    final completion = Map<String, bool>.from(_snapshot.completion)
      ..[requirement.key] = true;

    draft.capturedCategories.add(category);
    draft.capturedPhotoPaths[category] = result.filePath;
    draft.capturedEvidencePaths[requirement.key] = <String>[result.filePath];
    _snapshot = _snapshot.copyWith(completion: completion);

    _markCrossFormCompletion(requirement, result.filePath);

    _notify();

    await _syncReadinessFromSnapshot();
    return CaptureResult.captured;
  }

  /// Generates a PDF report for the current inspection.
  ///
  /// State machine:
  /// ```
  /// isGenerating=true
  ///   -> load evidence media paths
  ///   -> validate no missing evidence
  ///   -> load signature
  ///   -> build PdfGenerationInput
  ///   -> orchestrator.generate()
  ///   -> persist signature evidence
  ///   -> persist delivery artifact
  ///   -> success: set lastArtifact, lastPdfPath, isGenerating=false
  ///   -> PdfCloudGenerationTerminalFailure: return cloudTerminalFailure
  ///   -> other error: return error with message
  /// ```
  Future<PdfGenerationResult> generatePdf() async {
    _isGenerating = true;
    _notify();
    try {
      final evidenceMediaPaths = await _loadEvidenceMediaPaths();
      final missingEvidenceKeys =
          _missingCompletedEvidenceKeys(evidenceMediaPaths);
      if (missingEvidenceKeys.isNotEmpty) {
        throw StateError(
          'Missing required evidence media paths for: '
          '${missingEvidenceKeys.join(', ')}',
        );
      }

      final loadedSignature =
          await _signatureRepository.loadSignatureForGeneration(
        organizationId: draft.organizationId,
        userId: draft.userId,
      );
      if (loadedSignature == null) {
        throw StateError('Stored inspector signature metadata is required.');
      }

      // Build fieldValues and checkboxValues from form data.
      final fieldValues = <String, String>{};
      final checkboxValues = <String, bool>{};

      if (draft.enabledForms.contains(FormType.wdo)) {
        // For WDO form, pass form data directly as field values.
        // Keys in draft.formData match PDF map source_keys (e.g. gen_company_name),
        // bypassing WdoFormData which uses different key names.
        final wdoRawData = draft.formData[FormType.wdo];
        if (wdoRawData != null) {
          for (final entry in wdoRawData.entries) {
            if (entry.value is String &&
                (entry.value as String).isNotEmpty) {
              fieldValues[entry.key] = entry.value as String;
            }
          }
        }
      }

      if (draft.enabledForms.contains(FormType.sinkholeInspection)) {
        final sinkholeRawData = draft.formData[FormType.sinkholeInspection];
        if (sinkholeRawData != null) {
          // Remap RepeatingFieldGroup keys (attempt_N_Key) to SinkholeFormData
          // camelCase keys (attemptNKey) before constructing the typed object.
          final remapped =
              SinkholeFormData.remapSchedulingKeys(sinkholeRawData);
          final sinkholeData = SinkholeFormData.fromJson(remapped);
          final pdfMaps = sinkholeData.toPdfMaps();
          fieldValues.addAll(pdfMaps.fieldValues);
          checkboxValues.addAll(pdfMaps.checkboxValues);
        }
      }

      // Merge branchContext booleans into checkboxValues.
      for (final entry in _snapshot.branchContext.entries) {
        if (entry.value is bool) {
          checkboxValues[entry.key] = entry.value as bool;
        }
      }

      // Extract narrative form data for narrative-style templates.
      // Storage uses camelCase (toJson) for hydration fidelity; the narrative
      // engine expects snake_case keys, so mold data is translated here.
      final narrativeFormData = <FormType, Map<String, dynamic>>{};
      for (final form in draft.enabledForms.where((f) => f.isNarrative)) {
        final rawData = draft.formData[form];
        if (rawData != null) {
          if (form == FormType.moldAssessment) {
            // Translate camelCase storage format to snake_case template keys.
            final moldData =
                MoldFormData.fromJson(Map<String, dynamic>.from(rawData));
            narrativeFormData[form] =
                Map<String, dynamic>.from(moldData.toFormDataMap());
          } else if (form == FormType.generalInspection) {
            final generalData = GeneralInspectionFormData.fromJson(
                Map<String, dynamic>.from(rawData));
            narrativeFormData[form] =
                Map<String, dynamic>.from(generalData.toFormDataMap());
          } else {
            narrativeFormData[form] = Map<String, dynamic>.from(rawData);
          }
        }
      }

      final input = PdfGenerationInput(
        inspectionId: draft.inspectionId,
        organizationId: draft.organizationId,
        userId: draft.userId,
        clientName: draft.clientName,
        propertyAddress: draft.propertyAddress,
        enabledForms: draft.enabledForms,
        capturedCategories: draft.capturedCategories,
        wizardCompletion: _snapshot.completion,
        branchContext: _snapshot.branchContext,
        fieldValues: fieldValues,
        checkboxValues: checkboxValues,
        evidenceMediaPaths: evidenceMediaPaths,
        signatureBytes: Uint8List.fromList(loadedSignature.bytes),
        narrativeFormData: narrativeFormData,
      );
      final files = await _pdfOrchestrator.generate(input);
      final file = files.first;
      final payloadHash =
          ReportSignatureEvidenceRepository.computePayloadHash(input);
      await _signatureEvidenceRepository.persist(
        input: input,
        signerRole: 'inspector',
        signatureHash: loadedSignature.record.fileHash,
        signedAt: DateTime.now().toUtc(),
        attribution: const ReportSignatureAttribution(
          appVersion: null,
          device: null,
          sessionId: null,
          network: null,
        ),
      );
      final bytes = await file.readAsBytes();
      final length = bytes.length;
      final artifact = await _deliveryService.persistGeneratedArtifact(
        input: input,
        localFilePath: file.path,
        bytes: bytes,
        sizeBytes: length,
        signatureHash: loadedSignature.record.fileHash,
        payloadHash: payloadHash,
      );
      final sizeKb = (length / 1024).toStringAsFixed(1);

      _lastPdfPath = file.path;
      _lastArtifact = artifact;
      _isGenerating = false;
      _notify();
      return PdfGenerationResult(success: true, sizeKb: sizeKb);
    } on PdfCloudGenerationTerminalFailure {
      _isGenerating = false;
      _notify();
      return const PdfGenerationResult(
        success: false,
        isCloudTerminalFailure: true,
        errorMessage:
            'Cloud PDF generation failed and on-device fallback was not attempted.',
      );
    } catch (error) {
      _isGenerating = false;
      _notify();
      return PdfGenerationResult(
        success: false,
        errorMessage: 'PDF generation failed: $error',
      );
    }
  }

  /// Downloads the last generated artifact.
  Future<DeliveryResult> downloadArtifact() async {
    final artifact = _lastArtifact;
    if (artifact == null) {
      return const DeliveryResult(
        success: false,
        errorMessage: 'No artifact available.',
      );
    }
    try {
      final result = await _deliveryService.startDownload(artifact: artifact);
      return DeliveryResult(success: true, url: result.url);
    } catch (error) {
      return DeliveryResult(
        success: false,
        errorMessage: 'Download failed: $error',
      );
    }
  }

  /// Shares the last generated artifact via secure share link.
  Future<DeliveryResult> shareArtifact() async {
    final artifact = _lastArtifact;
    if (artifact == null) {
      return const DeliveryResult(
        success: false,
        errorMessage: 'No artifact available.',
      );
    }
    try {
      final result =
          await _deliveryService.startSecureShare(artifact: artifact);
      return DeliveryResult(success: true, url: result.url);
    } catch (error) {
      return DeliveryResult(
        success: false,
        errorMessage: 'Secure share failed: $error',
      );
    }
  }

  /// Loads audit events for the current inspection.
  Future<void> loadAuditEvents() => _loadAuditEvents();

  /// Sets a form-specific field value. Mutates draft.formData directly.
  void setFormFieldValue(FormType form, String key, dynamic value) {
    draft.formData.putIfAbsent(form, () => <String, dynamic>{});
    draft.formData[form]![key] = value;
    _notify();
  }

  /// Gets a form-specific field value.
  T? getFormFieldValue<T>(FormType form, String key) {
    return draft.formData[form]?[key] as T?;
  }

  /// Gets all form data for a specific form type (unmodifiable copy).
  Map<String, dynamic> getFormData(FormType form) {
    return Map<String, dynamic>.unmodifiable(
      draft.formData[form] ?? const {},
    );
  }

  /// Updates the mold form data and persists it to [draft.formData].
  ///
  /// Stores using [MoldFormData.toJson] (camelCase) so that
  /// [_hydrateMoldFormData] can round-trip via [MoldFormData.fromJson].
  /// The snake_case translation for the narrative PDF engine happens at
  /// generation time in [generatePdf].
  void updateMoldFormData(MoldFormData data) {
    _moldFormData = data;
    draft.formData[FormType.moldAssessment] =
        Map<String, dynamic>.from(data.toJson());
    _notify();
  }

  /// Updates the general inspection form data and persists it to [draft.formData].
  void updateGeneralFormData(GeneralInspectionFormData data) {
    _generalFormData = data;
    draft.formData[FormType.generalInspection] =
        Map<String, dynamic>.from(data.toJson());
    _notify();
  }

  /// Updates a branch flag in the wizard snapshot.
  void setBranchFlag(String key, bool value) {
    final updatedContext = Map<String, dynamic>.from(_snapshot.branchContext)
      ..[key] = value;
    _snapshot = _snapshot.copyWith(branchContext: updatedContext);
    _notify();
    _syncReadinessFromSnapshot();
  }

  // -- Private helpers -------------------------------------------------------

  /// Marks evidence completion across all enabled forms that share the
  /// captured photo's category, using [EvidenceSharingMatrix].
  ///
  /// Handles two sharing modes:
  /// 1. **Semantic equivalents**: Different enum values representing the same
  ///    physical subject (e.g., exteriorFront ↔ generalFrontElevation).
  /// 2. **Native shares**: Same enum value used by multiple forms
  ///    (e.g., roofSlopeMain used by fourPoint + roofCondition).
  void _markCrossFormCompletion(
    EvidenceRequirement requirement,
    String filePath,
  ) {
    final category = requirement.category;
    if (category == null) return;

    final completion = Map<String, bool>.from(_snapshot.completion);
    final branchContext = _snapshot.branchContext;
    var changed = false;

    // --- Semantic equivalents ---
    final equivalents = EvidenceSharingMatrix.equivalentCategories(category);
    for (final equivCategory in equivalents) {
      // Find which enabled forms own this equivalent category.
      final owningForms = EvidenceSharingMatrix.formsAcceptingCategoryFiltered(
        equivCategory,
        draft.enabledForms,
      );
      for (final form in owningForms) {
        // Skip the original capture's form.
        if (form == requirement.form) continue;

        final formReqs = FormRequirements.forFormRequirements(
          form,
          branchContext: branchContext,
        );
        for (final req in formReqs) {
          if (req.category != equivCategory) continue;

          // Don't double-mark already-completed keys.
          if (completion[req.key] == true) continue;

          // For multi-capture requirements on other forms, only mark the
          // base key (satisfies 1 of N).
          completion[req.key] = true;
          changed = true;

          // Copy photo path so other form's PDF generation can find it.
          draft.capturedCategories.add(equivCategory);
          draft.capturedPhotoPaths[equivCategory] = filePath;
          draft.capturedEvidencePaths[req.key] = <String>[filePath];
        }
      }
    }

    // --- Native shares (same category enum, different form) ---
    final nativeForms = EvidenceSharingMatrix.formsAcceptingCategoryFiltered(
      category,
      draft.enabledForms,
    );
    for (final form in nativeForms) {
      if (form == requirement.form) continue;

      final formReqs = FormRequirements.forFormRequirements(
        form,
        branchContext: branchContext,
      );
      for (final req in formReqs) {
        if (req.category != category) continue;

        if (completion[req.key] == true) continue;

        completion[req.key] = true;
        changed = true;

        // Evidence paths for the other form's requirement key.
        draft.capturedEvidencePaths[req.key] = <String>[filePath];
      }
    }

    if (changed) {
      _snapshot = _snapshot.copyWith(completion: completion);
    }
  }

  void _notify() {
    onStateChanged?.call();
  }

  Future<void> _loadAuditEvents() async {
    _isLoadingAuditEvents = true;
    _auditTimelineError = null;
    _notify();
    try {
      final events = await _auditRepository.listByInspection(
        inspectionId: draft.inspectionId,
        organizationId: draft.organizationId,
        userId: draft.userId,
      );
      events.sort((a, b) {
        final occurredComparison = b.occurredAt.compareTo(a.occurredAt);
        if (occurredComparison != 0) {
          return occurredComparison;
        }
        final createdComparison = b.createdAt.compareTo(a.createdAt);
        if (createdComparison != 0) {
          return createdComparison;
        }
        return b.id.compareTo(a.id);
      });
      _auditEvents = events;
    } catch (_) {
      _auditTimelineError =
          'Unable to load audit timeline right now. Please retry shortly.';
    } finally {
      _isLoadingAuditEvents = false;
      _notify();
    }
  }

  Future<void> _loadReadiness() async {
    final existing = await _repository.fetchReportReadiness(
      inspectionId: draft.inspectionId,
      organizationId: draft.organizationId,
      userId: draft.userId,
    );
    if (existing != null) {
      _persistedReadiness = existing;
      _notify();
      return;
    }
    await _syncReadinessFromSnapshot();
  }

  Future<void> _syncReadinessFromSnapshot() async {
    final evaluated = _evaluateReadiness();
    final saved = await _repository.upsertReportReadiness(evaluated);
    _persistedReadiness = saved;
    _notify();
  }

  ReportReadiness _evaluateReadiness() {
    return ReportReadiness.evaluate(
      inspectionId: draft.inspectionId,
      organizationId: draft.organizationId,
      userId: draft.userId,
      enabledForms: draft.enabledForms,
      completion: _snapshot.completion,
      branchContext: _snapshot.branchContext,
    );
  }

  void _hydrateMoldFormData() {
    final moldRawData = draft.formData[FormType.moldAssessment];
    if (moldRawData != null && moldRawData.isNotEmpty) {
      _moldFormData = MoldFormData.fromJson(moldRawData);
    }
  }

  void _hydrateGeneralFormData() {
    final rawData = draft.formData[FormType.generalInspection];
    if (rawData != null && rawData.isNotEmpty) {
      _generalFormData = GeneralInspectionFormData.fromJson(rawData);
    }
  }

  void _hydrateCapturedFromSnapshot() {
    for (final entry in _snapshot.completion.entries) {
      if (entry.value != true) {
        continue;
      }
      final category = _categoryForRequirementKey(entry.key);
      if (category != null) {
        draft.capturedCategories.add(category);
      }
    }
  }

  RequiredPhotoCategory? _categoryForRequirementKey(String key) {
    final normalizedKey =
        key.contains('#') ? key.substring(0, key.indexOf('#')) : key;
    return FormRequirements.categoryForRequirementKey(normalizedKey);
  }

  Future<void> _saveProgress({required bool markComplete}) async {
    final branchContext = Map<String, dynamic>.from(_snapshot.branchContext)
      ..['enabled_forms'] = draft.enabledForms
          .map((form) => form.code)
          .toList(growable: false);
    final updated = _snapshot.copyWith(
      lastStepIndex: _currentStepIndex,
      status: markComplete
          ? WizardProgressStatus.complete
          : WizardProgressStatus.inProgress,
      branchContext: branchContext,
    );
    await _repository.updateWizardProgress(
      inspectionId: draft.inspectionId,
      organizationId: draft.organizationId,
      userId: draft.userId,
      snapshot: updated,
    );
    await _repository.upsertReportReadiness(_evaluateReadiness());
    _snapshot = updated;
  }

  Future<Map<String, List<String>>> _loadEvidenceMediaPaths() async {
    final evidence = <String, List<String>>{};

    for (final entry in draft.capturedEvidencePaths.entries) {
      _mergeEvidencePaths(evidence, entry.key, entry.value);
    }

    final pending = await _pendingMediaSyncStore.loadEvidenceMediaPaths(
      inspectionId: draft.inspectionId,
      organizationId: draft.organizationId,
      userId: draft.userId,
    );
    for (final entry in pending.entries) {
      _mergeEvidencePaths(evidence, entry.key, entry.value);
    }

    final remoteStore = _mediaSyncRemoteStore;
    if (remoteStore != null) {
      final persisted = await remoteStore.loadEvidenceMediaPaths(
        inspectionId: draft.inspectionId,
        organizationId: draft.organizationId,
        userId: draft.userId,
      );
      for (final entry in persisted.entries) {
        _mergeEvidencePaths(evidence, entry.key, entry.value);
      }
    }

    return evidence;
  }

  void _mergeEvidencePaths(
    Map<String, List<String>> evidence,
    String requirementKey,
    Iterable<String> candidatePaths,
  ) {
    if (requirementKey.trim().isEmpty) {
      return;
    }
    final existing = evidence.putIfAbsent(requirementKey, () => <String>[]);
    existing.addAll(
      candidatePaths
          .map((path) => path.trim())
          .where((path) => path.isNotEmpty),
    );
    evidence[requirementKey] =
        existing.toSet().toList(growable: false)..sort();
  }

  List<String> _missingCompletedEvidenceKeys(
    Map<String, List<String>> evidenceMediaPaths,
  ) {
    final requirements = FormRequirements.evaluate(
      draft.enabledForms,
      branchContext: _snapshot.branchContext,
    );
    final missing = <String>[];
    for (final requirement in requirements) {
      if (_snapshot.completion[requirement.key] != true) {
        continue;
      }
      final paths = evidenceMediaPaths[requirement.key];
      if (paths == null || paths.isEmpty) {
        missing.add(requirement.key);
      }
    }
    return missing;
  }
}
