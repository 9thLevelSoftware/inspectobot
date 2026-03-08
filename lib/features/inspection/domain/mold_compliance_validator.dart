import 'mold_form_data.dart';

/// Result of a mold assessment compliance check against Florida Statutes
/// Chapter 468, Part XVI.
class ComplianceCheckResult {
  const ComplianceCheckResult({
    required this.isCompliant,
    required this.missingElements,
    required this.warnings,
  });

  final bool isCompliant;
  final List<String> missingElements;
  final List<String> warnings;
}

/// Validates a [MoldFormData] against statutory requirements for Florida mold
/// assessments (Chapter 468, Part XVI, F.S.).
class MoldComplianceValidator {
  const MoldComplianceValidator._();

  /// Validates [formData] for compliance with Florida mold assessment
  /// statutory requirements.
  ///
  /// [hasInspectorLicense] indicates whether the inspector has a valid MRSA
  /// license on file.
  ///
  /// [photoCounts] maps photo category keys to the number of photos captured
  /// for that category. Expected keys:
  /// - `mold_moisture_readings`
  /// - `mold_growth_evidence`
  /// - `mold_affected_areas`
  static ComplianceCheckResult validate(
    MoldFormData formData, {
    required bool hasInspectorLicense,
    required Map<String, int> photoCounts,
  }) {
    final missingElements = <String>[];
    final warnings = <String>[];

    // 1. MRSA license display
    if (!hasInspectorLicense) {
      missingElements.add('MRSA license is required');
    }

    // 2. Scope of assessment — must be non-empty
    if (formData.scopeOfAssessment.trim().isEmpty) {
      missingElements.add('Scope of assessment is required');
    }

    // 3. Visual observations — must be non-empty
    if (formData.visualObservations.trim().isEmpty) {
      missingElements.add('Visual observations is required');
    }

    // 4. Moisture source identification — must be non-empty
    if (formData.moistureSources.trim().isEmpty) {
      missingElements.add('Moisture source identification is required');
    }

    // 5. Mold type/location — must be non-empty
    if (formData.moldTypeLocation.trim().isEmpty) {
      missingElements.add('Mold type and location is required');
    }

    // 6. Remediation recommendations — conditional on branch flag
    if (formData.remediationRecommended &&
        formData.remediationRecommendations.trim().isEmpty) {
      missingElements.add(
        'Remediation recommendations required when remediation is recommended',
      );
    }

    // 7. Moisture readings photos
    if ((photoCounts['mold_moisture_readings'] ?? 0) < 1) {
      missingElements.add('At least 1 moisture readings photo is required');
    }

    // 8. Mold growth photos
    if ((photoCounts['mold_growth_evidence'] ?? 0) < 1) {
      missingElements.add('At least 1 mold growth evidence photo is required');
    }

    // 9. Affected area photos
    if ((photoCounts['mold_affected_areas'] ?? 0) < 1) {
      missingElements.add('At least 1 affected areas photo is required');
    }

    // Warnings (non-blocking)
    if (formData.additionalFindings.trim().isEmpty) {
      warnings.add('Additional findings section is empty (recommended)');
    }

    if (!formData.remediationRecommended &&
        (photoCounts['mold_growth_evidence'] ?? 0) > 0) {
      warnings.add(
        'Consider recommending remediation when mold growth is documented',
      );
    }

    return ComplianceCheckResult(
      isCompliant: missingElements.isEmpty,
      missingElements: missingElements,
      warnings: warnings,
    );
  }
}
