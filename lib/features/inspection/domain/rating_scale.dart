import 'package:inspectobot/features/inspection/domain/form_type.dart';

/// Unified rating scale that normalizes form-specific condition ratings
/// (4-Point Satisfactory/Unsatisfactory, RCF-1 Good/Fair/Poor/Failed, etc.)
/// into a single semantic enum.
enum RatingScale {
  satisfactory,
  marginal,
  deficient,
  failed,
  notApplicable,
  notVisible,
  missing;

  // ---------------------------------------------------------------------------
  // JSON serialization
  // ---------------------------------------------------------------------------

  String toJsonValue() => name;

  static RatingScale? fromJsonValue(String? value) {
    if (value == null) return null;
    return RatingScale.values.cast<RatingScale?>().firstWhere(
          (e) => e!.name == value,
          orElse: () => null,
        );
  }

  // ---------------------------------------------------------------------------
  // Canonical display string
  // ---------------------------------------------------------------------------

  String toNormalizedString() {
    switch (this) {
      case RatingScale.satisfactory:
        return 'Satisfactory';
      case RatingScale.marginal:
        return 'Marginal';
      case RatingScale.deficient:
        return 'Deficient';
      case RatingScale.failed:
        return 'Failed';
      case RatingScale.notApplicable:
        return 'Not Applicable';
      case RatingScale.notVisible:
        return 'Not Visible';
      case RatingScale.missing:
        return 'Missing';
    }
  }

  // ---------------------------------------------------------------------------
  // Semantic helpers
  // ---------------------------------------------------------------------------

  bool get isDeficient => this == deficient || this == failed;

  bool get isAcceptable => this == satisfactory || this == marginal;

  bool get isNonAnswer =>
      this == notApplicable || this == notVisible || this == missing;

  /// Severity ordinal: 0 (satisfactory) through 3 (failed).
  /// Returns null for non-answer values.
  int? get severityOrdinal {
    switch (this) {
      case RatingScale.satisfactory:
        return 0;
      case RatingScale.marginal:
        return 1;
      case RatingScale.deficient:
        return 2;
      case RatingScale.failed:
        return 3;
      case RatingScale.notApplicable:
      case RatingScale.notVisible:
      case RatingScale.missing:
        return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Per-form ingestion: form string -> RatingScale
  // ---------------------------------------------------------------------------

  static const _fourPointIngestion = <String, RatingScale>{
    'Satisfactory': satisfactory,
    'S': satisfactory,
    'Unsatisfactory': deficient,
    'U': deficient,
    'N/A': notApplicable,
    'NA': notApplicable,
  };

  static const _generalIngestion = <String, RatingScale>{
    'Good': satisfactory,
    'G': satisfactory,
    'Fair': marginal,
    'F': marginal,
    'Poor': deficient,
    'P': deficient,
    'N/A': notApplicable,
    'NA': notApplicable,
  };

  static const _roofConditionIngestion = <String, RatingScale>{
    'Good': satisfactory,
    'G': satisfactory,
    'Fair': marginal,
    'F': marginal,
    'Poor': deficient,
    'P': deficient,
    'Failed': failed,
  };

  /// Converts a form-specific rating string to a [RatingScale] value.
  ///
  /// Returns null for unrecognized values or form types that do not use
  /// rating tables (windMitigation, wdo, sinkholeInspection, moldAssessment).
  static RatingScale? fromFormValue(String value, FormType formType) {
    switch (formType) {
      case FormType.fourPoint:
        return _fourPointIngestion[value];
      case FormType.generalInspection:
        return _generalIngestion[value];
      case FormType.roofCondition:
        return _roofConditionIngestion[value];
      case FormType.windMitigation:
      case FormType.wdo:
      case FormType.sinkholeInspection:
      case FormType.moldAssessment:
        return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Per-form emission: RatingScale -> form string
  // ---------------------------------------------------------------------------

  static const _fourPointEmission = <RatingScale, String>{
    satisfactory: 'Satisfactory',
    deficient: 'Unsatisfactory',
    notApplicable: 'N/A',
  };

  static const _roofConditionEmission = <RatingScale, String>{
    satisfactory: 'Good',
    marginal: 'Fair',
    deficient: 'Poor',
    failed: 'Failed',
  };

  static const _generalEmission = <RatingScale, String>{
    satisfactory: 'Good',
    marginal: 'Fair',
    deficient: 'Poor',
    notApplicable: 'N/A',
  };

  /// Converts this [RatingScale] to the form-specific string representation.
  ///
  /// Returns null if the value is not applicable to the given form type.
  String? toFormString(FormType formType) {
    switch (formType) {
      case FormType.fourPoint:
        return _fourPointEmission[this];
      case FormType.roofCondition:
        return _roofConditionEmission[this];
      case FormType.generalInspection:
        return _generalEmission[this];
      case FormType.windMitigation:
      case FormType.wdo:
      case FormType.sinkholeInspection:
      case FormType.moldAssessment:
        return null;
    }
  }
}
