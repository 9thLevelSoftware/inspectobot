enum FormType {
  fourPoint(code: 'four_point', label: 'Insp4pt 03-25', abbreviation: '4PT'),
  roofCondition(code: 'roof_condition', label: 'RCF-1 03-25', abbreviation: 'ROOF'),
  windMitigation(code: 'wind_mitigation', label: 'OIR-B1-1802 Rev 04/26', abbreviation: 'WIND'),
  wdo(code: 'wdo', label: 'WDO Inspection', abbreviation: 'WDO'),
  sinkholeInspection(code: 'sinkhole_inspection', label: 'Sinkhole Inspection', abbreviation: 'SINK'),
  moldAssessment(code: 'mold_assessment', label: 'Mold Assessment', abbreviation: 'MOLD'),
  generalInspection(code: 'general_inspection', label: 'General Inspection', abbreviation: 'GEN');

  const FormType({required this.code, required this.label, required this.abbreviation});

  final String code;
  final String label;

  /// Two-to-four character abbreviation for compact display (e.g., chips, badges).
  final String abbreviation;

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

