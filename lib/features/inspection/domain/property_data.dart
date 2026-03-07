import 'form_type.dart';
// Circular import: inspection_draft.dart also imports this file.
// Acceptable during Strategy B coexistence (Phases 3-10) because PropertyData
// needs InspectionDraft for factory constructors and InspectionDraft holds an
// optional PropertyData field. Dart handles this without issue at compile time.
import 'inspection_draft.dart';
import 'inspection_wizard_state.dart';
import 'property_data_migrations.dart';
import 'required_photo_category.dart';
import 'shared_building_system_fields.dart';
import 'universal_property_fields.dart';

/// Aggregate that unifies all property-level data for an inspection session.
///
/// Replaces the flat field layout of [InspectionDraft] with typed sub-objects
/// ([UniversalPropertyFields], [SharedBuildingSystemFields]) and per-form data
/// maps keyed by [FormType].
class PropertyData {
  PropertyData({
    required this.inspectionId,
    required this.organizationId,
    required this.userId,
    this.clientEmail = '',
    this.clientPhone = '',
    required this.enabledForms,
    this.wizardSnapshot = WizardProgressSnapshot.empty,
    this.initialStepIndex = 0,
    required this.universal,
    this.shared = const SharedBuildingSystemFields(),
    this.formData = const <FormType, Map<String, dynamic>>{},
    this.capturedCategories = const <RequiredPhotoCategory>{},
    this.capturedPhotoPaths = const <RequiredPhotoCategory, String>{},
    this.capturedEvidencePaths = const <String, List<String>>{},
    this.schemaVersion = 1,
  });

  // ---------------------------------------------------------------------------
  // Identity (from InspectionDraft)
  // ---------------------------------------------------------------------------

  final String inspectionId;
  final String organizationId;
  final String userId;

  // ---------------------------------------------------------------------------
  // App-only (not on paper forms)
  // ---------------------------------------------------------------------------

  final String clientEmail;
  final String clientPhone;

  // ---------------------------------------------------------------------------
  // Workflow state
  // ---------------------------------------------------------------------------

  final Set<FormType> enabledForms;
  final WizardProgressSnapshot wizardSnapshot;
  final int initialStepIndex;

  // ---------------------------------------------------------------------------
  // Typed shared data
  // ---------------------------------------------------------------------------

  final UniversalPropertyFields universal;
  final SharedBuildingSystemFields shared;

  // ---------------------------------------------------------------------------
  // Form-specific data (keyed by FormType)
  // ---------------------------------------------------------------------------

  final Map<FormType, Map<String, dynamic>> formData;

  // ---------------------------------------------------------------------------
  // Media state
  // ---------------------------------------------------------------------------

  final Set<RequiredPhotoCategory> capturedCategories;
  final Map<RequiredPhotoCategory, String> capturedPhotoPaths;
  final Map<String, List<String>> capturedEvidencePaths;

  // ---------------------------------------------------------------------------
  // Schema metadata
  // ---------------------------------------------------------------------------

  final int schemaVersion;

  // ---------------------------------------------------------------------------
  // Form prefix mapping for branchContext
  // ---------------------------------------------------------------------------

  static const _formPrefixes = <FormType, String>{
    FormType.fourPoint: 'fourPoint',
    FormType.roofCondition: 'roofCondition',
    FormType.windMitigation: 'windMit',
    FormType.wdo: 'wdo',
    FormType.sinkholeInspection: 'sinkhole',
    FormType.moldAssessment: 'mold',
    FormType.generalInspection: 'general',
  };

  // ---------------------------------------------------------------------------
  // Factory constructors
  // ---------------------------------------------------------------------------

  /// Creates a [PropertyData] from an existing [InspectionDraft].
  ///
  /// Inspector identity fields are left empty -- use
  /// [fromInspectionDraftWithProfile] to fill them.
  factory PropertyData.fromInspectionDraft(InspectionDraft draft) {
    return PropertyData._fromDraft(
      draft,
      inspectorName: '',
      inspectorCompany: '',
      inspectorLicenseNumber: '',
    );
  }

  /// Creates a [PropertyData] from an [InspectionDraft] and fills inspector
  /// identity fields from the provided named parameters.
  factory PropertyData.fromInspectionDraftWithProfile(
    InspectionDraft draft, {
    required String inspectorName,
    required String inspectorCompany,
    required String inspectorLicenseNumber,
  }) {
    return PropertyData._fromDraft(
      draft,
      inspectorName: inspectorName,
      inspectorCompany: inspectorCompany,
      inspectorLicenseNumber: inspectorLicenseNumber,
    );
  }

  factory PropertyData._fromDraft(
    InspectionDraft draft, {
    required String inspectorName,
    required String inspectorCompany,
    required String inspectorLicenseNumber,
  }) {
    return PropertyData(
      inspectionId: draft.inspectionId,
      organizationId: draft.organizationId,
      userId: draft.userId,
      clientEmail: draft.clientEmail,
      clientPhone: draft.clientPhone,
      enabledForms: Set<FormType>.of(draft.enabledForms),
      wizardSnapshot: draft.wizardSnapshot,
      initialStepIndex: draft.initialStepIndex,
      universal: UniversalPropertyFields(
        propertyAddress: draft.propertyAddress,
        inspectionDate: draft.inspectionDate,
        inspectorName: inspectorName,
        inspectorCompany: inspectorCompany,
        inspectorLicenseNumber: inspectorLicenseNumber,
        clientName: draft.clientName,
      ),
      shared: SharedBuildingSystemFields(yearBuilt: draft.yearBuilt),
      formData: const <FormType, Map<String, dynamic>>{},
      capturedCategories:
          Set<RequiredPhotoCategory>.of(draft.capturedCategories),
      capturedPhotoPaths:
          Map<RequiredPhotoCategory, String>.of(draft.capturedPhotoPaths),
      capturedEvidencePaths: Map<String, List<String>>.of(
        draft.capturedEvidencePaths
            .map((key, value) => MapEntry(key, List<String>.of(value))),
      ),
      schemaVersion: PropertyDataMigrations.currentVersion,
    );
  }

  // ---------------------------------------------------------------------------
  // Backward compatibility accessors
  // ---------------------------------------------------------------------------

  String get clientName => universal.clientName;
  String get propertyAddress => universal.propertyAddress;
  DateTime get inspectionDate => universal.inspectionDate;
  int get yearBuilt => shared.yearBuilt ?? 0;

  // ---------------------------------------------------------------------------
  // Computed getter: branchContext
  // ---------------------------------------------------------------------------

  /// Merges universal, shared, and form-specific data into a single flat map.
  ///
  /// Precedence (lowest to highest):
  /// 1. Universal fields (snake_case keys)
  /// 2. Shared fields (snake_case keys, only non-null)
  /// 3. Form-specific entries, prefixed with `{formPrefix}.`
  ///
  /// **Note**: Form-specific keys are prefixed (e.g., `fourPoint.hazard_present`).
  /// This format is for external consumers and cross-form data views. It is NOT
  /// directly compatible with [FormRequirements] predicates, which expect
  /// unprefixed keys (e.g., `hazard_present`). The wizard uses
  /// [WizardProgressSnapshot.branchContext] for predicate evaluation.
  Map<String, dynamic> get branchContext {
    final context = <String, dynamic>{};

    // Layer 1: universal
    context.addAll(universal.toJson());

    // Layer 2: shared (toJson omits nulls)
    context.addAll(shared.toJson());

    // Layer 3: form-specific
    for (final entry in formData.entries) {
      final prefix = _formPrefixes[entry.key] ?? entry.key.code;
      for (final kv in entry.value.entries) {
        context['$prefix.${kv.key}'] = kv.value;
      }
    }

    return context;
  }

  // ---------------------------------------------------------------------------
  // Helper methods
  // ---------------------------------------------------------------------------

  /// Returns a typed value from [formData] for the given [form] and [key].
  T? getFormValue<T>(FormType form, String key) {
    return formData[form]?[key] as T?;
  }

  /// Returns a new [PropertyData] with a single form value updated.
  PropertyData setFormValue(FormType form, String key, dynamic value) {
    final currentFormMap =
        formData[form] ?? const <String, dynamic>{};
    final updatedFormMap = Map<String, dynamic>.of(currentFormMap)..[key] = value;
    final updatedFormData = Map<FormType, Map<String, dynamic>>.of(formData)
      ..[form] = updatedFormMap;
    return copyWith(formData: updatedFormData);
  }

  /// Returns a new [PropertyData] with multiple form values updated at once.
  PropertyData setFormValues(FormType form, Map<String, dynamic> values) {
    final currentFormMap =
        formData[form] ?? const <String, dynamic>{};
    final updatedFormMap = Map<String, dynamic>.of(currentFormMap)..addAll(values);
    final updatedFormData = Map<FormType, Map<String, dynamic>>.of(formData)
      ..[form] = updatedFormMap;
    return copyWith(formData: updatedFormData);
  }

  // ---------------------------------------------------------------------------
  // Serialization
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'inspection_id': inspectionId,
      'organization_id': organizationId,
      'user_id': userId,
      'client_email': clientEmail,
      'client_phone': clientPhone,
      'enabled_forms': enabledForms.map((f) => f.code).toList(),
      'wizard_snapshot': <String, dynamic>{
        'last_step_index': wizardSnapshot.lastStepIndex,
        'completion': wizardSnapshot.completion,
        'branch_context': wizardSnapshot.branchContext,
        'status': wizardSnapshot.status.name,
      },
      'initial_step_index': initialStepIndex,
      'universal': universal.toJson(),
      'shared': shared.toJson(),
      'form_data': formData.map(
        (form, data) => MapEntry(form.code, data),
      ),
      'captured_categories':
          capturedCategories.map((c) => c.name).toList(),
      'captured_photo_paths': capturedPhotoPaths.map(
        (category, path) => MapEntry(category.name, path),
      ),
      'captured_evidence_paths': capturedEvidencePaths.map(
        (key, value) => MapEntry(key, List<String>.of(value)),
      ),
      'schema_version': schemaVersion,
    };
  }

  static PropertyData fromJson(Map<String, dynamic> json) {
    final migrated = PropertyDataMigrations.migrate(json);

    // Parse enabled forms, skipping unknown codes gracefully.
    final enabledForms = <FormType>{};
    for (final code in (migrated['enabled_forms'] as List<dynamic>)) {
      try {
        enabledForms.add(FormType.fromCode(code as String));
      } on ArgumentError {
        // Skip unknown form codes for forward compatibility.
      }
    }

    // Parse wizard snapshot.
    final snapshotJson =
        migrated['wizard_snapshot'] as Map<String, dynamic>?;
    final wizardSnapshot = snapshotJson != null
        ? WizardProgressSnapshot(
            lastStepIndex: snapshotJson['last_step_index'] as int? ?? 0,
            completion: (snapshotJson['completion'] as Map<String, dynamic>?)
                    ?.map((k, v) => MapEntry(k, v as bool)) ??
                const <String, bool>{},
            branchContext:
                (snapshotJson['branch_context'] as Map<String, dynamic>?) ??
                    const <String, dynamic>{},
            status: WizardProgressStatus.values.firstWhere(
              (s) => s.name == (snapshotJson['status'] as String?),
              orElse: () => WizardProgressStatus.inProgress,
            ),
          )
        : WizardProgressSnapshot.empty;

    // Parse form data, skipping unknown form codes.
    final rawFormData =
        migrated['form_data'] as Map<String, dynamic>? ??
            const <String, dynamic>{};
    final formData = <FormType, Map<String, dynamic>>{};
    for (final entry in rawFormData.entries) {
      try {
        final form = FormType.fromCode(entry.key);
        formData[form] = Map<String, dynamic>.from(entry.value as Map);
      } on ArgumentError {
        // Skip unknown form codes for forward compatibility.
      }
    }

    // Parse captured categories.
    final capturedCategories = <RequiredPhotoCategory>{};
    for (final name
        in (migrated['captured_categories'] as List<dynamic>? ?? const [])) {
      final match = _photoCategoryByName(name as String);
      if (match != null) capturedCategories.add(match);
    }

    // Parse captured photo paths.
    final capturedPhotoPaths = <RequiredPhotoCategory, String>{};
    final rawPhotoPaths =
        migrated['captured_photo_paths'] as Map<String, dynamic>? ??
            const <String, dynamic>{};
    for (final entry in rawPhotoPaths.entries) {
      final match = _photoCategoryByName(entry.key);
      if (match != null) capturedPhotoPaths[match] = entry.value as String;
    }

    // Parse captured evidence paths.
    final rawEvidencePaths =
        migrated['captured_evidence_paths'] as Map<String, dynamic>? ??
            const <String, dynamic>{};
    final capturedEvidencePaths = rawEvidencePaths.map(
      (key, value) => MapEntry(
        key,
        (value as List<dynamic>).map((e) => e as String).toList(),
      ),
    );

    return PropertyData(
      inspectionId: migrated['inspection_id'] as String,
      organizationId: migrated['organization_id'] as String,
      userId: migrated['user_id'] as String,
      clientEmail: migrated['client_email'] as String? ?? '',
      clientPhone: migrated['client_phone'] as String? ?? '',
      enabledForms: enabledForms,
      wizardSnapshot: wizardSnapshot,
      initialStepIndex: migrated['initial_step_index'] as int? ?? 0,
      universal: UniversalPropertyFields.fromJson(
        migrated['universal'] as Map<String, dynamic>,
      ),
      shared: migrated['shared'] != null
          ? SharedBuildingSystemFields.fromJson(
              migrated['shared'] as Map<String, dynamic>,
            )
          : const SharedBuildingSystemFields(),
      formData: formData,
      capturedCategories: capturedCategories,
      capturedPhotoPaths: capturedPhotoPaths,
      capturedEvidencePaths: capturedEvidencePaths,
      schemaVersion: migrated['schema_version'] as int? ?? 1,
    );
  }

  static RequiredPhotoCategory? _photoCategoryByName(String name) {
    for (final value in RequiredPhotoCategory.values) {
      if (value.name == name) return value;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Reverse factory: back to InspectionDraft (lossy)
  // ---------------------------------------------------------------------------

  /// Converts this [PropertyData] back to an [InspectionDraft].
  ///
  /// This is lossy -- only fields present on [InspectionDraft] are preserved.
  /// Inspector identity, shared building system fields beyond yearBuilt, and
  /// per-form data are discarded.
  InspectionDraft toInspectionDraft() {
    final draft = InspectionDraft(
      inspectionId: inspectionId,
      organizationId: organizationId,
      userId: userId,
      clientName: universal.clientName,
      clientEmail: clientEmail,
      clientPhone: clientPhone,
      propertyAddress: universal.propertyAddress,
      inspectionDate: universal.inspectionDate,
      yearBuilt: shared.yearBuilt ?? 0,
      enabledForms: Set<FormType>.of(enabledForms),
      wizardSnapshot: wizardSnapshot,
      initialStepIndex: initialStepIndex,
    );

    // Copy mutable media state.
    draft.capturedCategories.addAll(capturedCategories);
    draft.capturedPhotoPaths.addAll(capturedPhotoPaths);
    for (final entry in capturedEvidencePaths.entries) {
      draft.capturedEvidencePaths[entry.key] = List<String>.of(entry.value);
    }

    return draft;
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  PropertyData copyWith({
    String? inspectionId,
    String? organizationId,
    String? userId,
    String? clientEmail,
    String? clientPhone,
    Set<FormType>? enabledForms,
    WizardProgressSnapshot? wizardSnapshot,
    int? initialStepIndex,
    UniversalPropertyFields? universal,
    SharedBuildingSystemFields? shared,
    Map<FormType, Map<String, dynamic>>? formData,
    Set<RequiredPhotoCategory>? capturedCategories,
    Map<RequiredPhotoCategory, String>? capturedPhotoPaths,
    Map<String, List<String>>? capturedEvidencePaths,
    int? schemaVersion,
  }) {
    return PropertyData(
      inspectionId: inspectionId ?? this.inspectionId,
      organizationId: organizationId ?? this.organizationId,
      userId: userId ?? this.userId,
      clientEmail: clientEmail ?? this.clientEmail,
      clientPhone: clientPhone ?? this.clientPhone,
      enabledForms: enabledForms ?? Set<FormType>.of(this.enabledForms),
      wizardSnapshot: wizardSnapshot ?? this.wizardSnapshot,
      initialStepIndex: initialStepIndex ?? this.initialStepIndex,
      universal: universal ?? this.universal,
      shared: shared ?? this.shared,
      formData: formData ??
          this.formData.map(
            (k, v) => MapEntry(k, Map<String, dynamic>.of(v)),
          ),
      capturedCategories: capturedCategories ??
          Set<RequiredPhotoCategory>.of(this.capturedCategories),
      capturedPhotoPaths: capturedPhotoPaths ??
          Map<RequiredPhotoCategory, String>.of(this.capturedPhotoPaths),
      capturedEvidencePaths: capturedEvidencePaths ??
          this.capturedEvidencePaths.map(
            (k, v) => MapEntry(k, List<String>.of(v)),
          ),
      schemaVersion: schemaVersion ?? this.schemaVersion,
    );
  }
}
