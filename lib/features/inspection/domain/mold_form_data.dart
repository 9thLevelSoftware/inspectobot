/// Typed data class for the Mold Assessment form.
///
/// Contains 6 text fields matching the [MoldAssessmentTemplate] formData keys
/// and 2 branch flag booleans for conditional logic.
class MoldFormData {
  const MoldFormData({
    this.scopeOfAssessment = '',
    this.visualObservations = '',
    this.moistureSources = '',
    this.moldTypeLocation = '',
    this.remediationRecommendations = '',
    this.additionalFindings = '',
    this.remediationRecommended = false,
    this.airSamplesTaken = false,
  });

  // Text fields (6)
  final String scopeOfAssessment;
  final String visualObservations;
  final String moistureSources;
  final String moldTypeLocation;
  final String remediationRecommendations;
  final String additionalFindings;

  // Branch flags (2)
  final bool remediationRecommended;
  final bool airSamplesTaken;

  // ---------------------------------------------------------------------------
  // empty factory
  // ---------------------------------------------------------------------------

  /// Creates an empty [MoldFormData] with all defaults.
  factory MoldFormData.empty() => const MoldFormData();

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  MoldFormData copyWith({
    String? scopeOfAssessment,
    String? visualObservations,
    String? moistureSources,
    String? moldTypeLocation,
    String? remediationRecommendations,
    String? additionalFindings,
    bool? remediationRecommended,
    bool? airSamplesTaken,
  }) {
    return MoldFormData(
      scopeOfAssessment: scopeOfAssessment ?? this.scopeOfAssessment,
      visualObservations: visualObservations ?? this.visualObservations,
      moistureSources: moistureSources ?? this.moistureSources,
      moldTypeLocation: moldTypeLocation ?? this.moldTypeLocation,
      remediationRecommendations:
          remediationRecommendations ?? this.remediationRecommendations,
      additionalFindings: additionalFindings ?? this.additionalFindings,
      remediationRecommended:
          remediationRecommended ?? this.remediationRecommended,
      airSamplesTaken: airSamplesTaken ?? this.airSamplesTaken,
    );
  }

  // ---------------------------------------------------------------------------
  // toFormDataMap — bridge to narrative engine
  // ---------------------------------------------------------------------------

  /// Returns form data keyed to match [MoldAssessmentTemplate.referencedFormDataKeys].
  Map<String, String> toFormDataMap() {
    return <String, String>{
      'scope_of_assessment': scopeOfAssessment,
      'visual_observations': visualObservations,
      'moisture_sources': moistureSources,
      'mold_type_location': moldTypeLocation,
      'remediation_recommendations': remediationRecommendations,
      'additional_findings': additionalFindings,
    };
  }

  // ---------------------------------------------------------------------------
  // Serialization
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'scopeOfAssessment': scopeOfAssessment,
      'visualObservations': visualObservations,
      'moistureSources': moistureSources,
      'moldTypeLocation': moldTypeLocation,
      'remediationRecommendations': remediationRecommendations,
      'additionalFindings': additionalFindings,
      'remediationRecommended': remediationRecommended,
      'airSamplesTaken': airSamplesTaken,
    };
  }

  factory MoldFormData.fromJson(Map<String, dynamic> json) {
    return MoldFormData(
      scopeOfAssessment: json['scopeOfAssessment'] as String? ?? '',
      visualObservations: json['visualObservations'] as String? ?? '',
      moistureSources: json['moistureSources'] as String? ?? '',
      moldTypeLocation: json['moldTypeLocation'] as String? ?? '',
      remediationRecommendations:
          json['remediationRecommendations'] as String? ?? '',
      additionalFindings: json['additionalFindings'] as String? ?? '',
      remediationRecommended:
          json['remediationRecommended'] as bool? ?? false,
      airSamplesTaken: json['airSamplesTaken'] as bool? ?? false,
    );
  }

  // ---------------------------------------------------------------------------
  // isEmpty
  // ---------------------------------------------------------------------------

  /// Returns true if all text fields are empty and both flags are false.
  bool get isEmpty =>
      scopeOfAssessment.isEmpty &&
      visualObservations.isEmpty &&
      moistureSources.isEmpty &&
      moldTypeLocation.isEmpty &&
      remediationRecommendations.isEmpty &&
      additionalFindings.isEmpty &&
      !remediationRecommended &&
      !airSamplesTaken;

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoldFormData &&
          runtimeType == other.runtimeType &&
          scopeOfAssessment == other.scopeOfAssessment &&
          visualObservations == other.visualObservations &&
          moistureSources == other.moistureSources &&
          moldTypeLocation == other.moldTypeLocation &&
          remediationRecommendations == other.remediationRecommendations &&
          additionalFindings == other.additionalFindings &&
          remediationRecommended == other.remediationRecommended &&
          airSamplesTaken == other.airSamplesTaken;

  @override
  int get hashCode => Object.hashAll(<Object>[
        scopeOfAssessment,
        visualObservations,
        moistureSources,
        moldTypeLocation,
        remediationRecommendations,
        additionalFindings,
        remediationRecommended,
        airSamplesTaken,
      ]);
}
