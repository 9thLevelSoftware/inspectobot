enum FormType {
  fourPoint(code: 'four_point', label: 'Insp4pt 03-25'),
  roofCondition(code: 'roof_condition', label: 'RCF-1 03-25'),
  windMitigation(code: 'wind_mitigation', label: 'OIR-B1-1802 Rev 04/26'),
  wdo(code: 'wdo', label: 'WDO Inspection'),
  sinkholeInspection(code: 'sinkhole_inspection', label: 'Sinkhole Inspection'),
  moldAssessment(code: 'mold_assessment', label: 'Mold Assessment'),
  generalInspection(code: 'general_inspection', label: 'General Inspection');

  const FormType({required this.code, required this.label});

  final String code;
  final String label;

  static FormType fromCode(String code) {
    return values.firstWhere(
      (formType) => formType.code == code,
      orElse: () => throw ArgumentError.value(code, 'code', 'Unsupported form code'),
    );
  }

  static Set<FormType> fromCodes(Iterable<String> codes) {
    return codes.map(fromCode).toSet();
  }
}

/// Rendering-related extensions on [FormType].
extension FormTypeRendering on FormType {
  /// Whether this form type uses narrative-style PDF rendering
  /// (free-form report) rather than a structured form overlay.
  bool get isNarrative =>
      this == FormType.moldAssessment ||
      this == FormType.generalInspection;
}

