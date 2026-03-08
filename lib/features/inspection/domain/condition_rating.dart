/// Condition rating levels for system evaluations per Rule 61-30.801.
enum ConditionRating {
  satisfactory,
  marginal,
  deficient,
  notInspected;

  /// Parses a string value into a [ConditionRating].
  ///
  /// Accepts lowercase, uppercase, and common variations. Falls back to
  /// [notInspected] for unrecognized values.
  static ConditionRating parse(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ConditionRating.notInspected;
    }
    switch (value.trim().toLowerCase()) {
      case 'satisfactory':
      case 'good':
      case 'pass':
        return ConditionRating.satisfactory;
      case 'marginal':
      case 'fair':
      case 'caution':
        return ConditionRating.marginal;
      case 'deficient':
      case 'poor':
      case 'fail':
        return ConditionRating.deficient;
      case 'not_inspected':
      case 'notinspected':
      case 'n/a':
      case 'na':
        return ConditionRating.notInspected;
      default:
        return ConditionRating.notInspected;
    }
  }

  /// Human-readable display label.
  String get displayLabel {
    switch (this) {
      case ConditionRating.satisfactory:
        return 'Satisfactory';
      case ConditionRating.marginal:
        return 'Marginal';
      case ConditionRating.deficient:
        return 'Deficient';
      case ConditionRating.notInspected:
        return 'Not Inspected';
    }
  }

}
