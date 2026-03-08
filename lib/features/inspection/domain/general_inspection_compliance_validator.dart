import 'compliance_check_result.dart';
import 'condition_rating.dart';
import 'general_inspection_form_data.dart';
import 'system_inspection_data.dart';

/// Validates a [GeneralInspectionFormData] against statutory requirements for
/// Florida general home inspections (Rule 61-30.801, F.A.C.).
class GeneralInspectionComplianceValidator {
  const GeneralInspectionComplianceValidator._();

  // ---------------------------------------------------------------------------
  // Photo key constants matching GeneralInspectionTemplate.requiredPhotoKeys
  // ---------------------------------------------------------------------------

  static const String photoKeyStructural = 'structural_photos';
  static const String photoKeyExterior = 'exterior_photos';
  static const String photoKeyRoofing = 'roofing_photos';
  static const String photoKeyPlumbing = 'plumbing_photos';
  static const String photoKeyElectrical = 'electrical_photos';
  static const String photoKeyHvac = 'hvac_photos';
  static const String photoKeyInsulationVentilation =
      'insulation_ventilation_photos';
  static const String photoKeyAppliances = 'appliances_photos';
  static const String photoKeyLifeSafety = 'life_safety_photos';

  /// All photo key constants as a set, for alignment verification.
  static const Set<String> allPhotoKeys = {
    photoKeyStructural,
    photoKeyExterior,
    photoKeyRoofing,
    photoKeyPlumbing,
    photoKeyElectrical,
    photoKeyHvac,
    photoKeyInsulationVentilation,
    photoKeyAppliances,
    photoKeyLifeSafety,
  };

  /// Validates [formData] for compliance with Florida general home inspection
  /// statutory requirements.
  ///
  /// [hasInspectorLicense] indicates whether the inspector has a valid home
  /// inspector license on file.
  ///
  /// [photoCounts] maps photo category keys to the number of photos captured
  /// for that category.
  static ComplianceCheckResult validate(
    GeneralInspectionFormData formData, {
    required bool hasInspectorLicense,
    required Map<String, int> photoCounts,
  }) {
    final missingElements = <String>[];
    final warnings = <String>[];

    // 1. Inspector license
    if (!hasInspectorLicense) {
      missingElements.add('Inspector license is required');
    }

    // 2. Scope and purpose — must be non-empty
    if (formData.scopeAndPurpose.trim().isEmpty) {
      missingElements.add('Scope and purpose is required');
    }

    // 3. System-level ratings — each must not be notInspected
    _validateSystem(
      formData.structural,
      photoKeyStructural,
      photoCounts,
      missingElements,
      warnings,
    );
    _validateSystem(
      formData.exterior,
      photoKeyExterior,
      photoCounts,
      missingElements,
      warnings,
    );
    _validateSystem(
      formData.roofing,
      photoKeyRoofing,
      photoCounts,
      missingElements,
      warnings,
    );
    _validateSystem(
      formData.plumbing,
      photoKeyPlumbing,
      photoCounts,
      missingElements,
      warnings,
    );
    _validateSystem(
      formData.electrical,
      photoKeyElectrical,
      photoCounts,
      missingElements,
      warnings,
    );
    _validateSystem(
      formData.hvac,
      photoKeyHvac,
      photoCounts,
      missingElements,
      warnings,
    );
    _validateSystem(
      formData.insulationVentilation,
      photoKeyInsulationVentilation,
      photoCounts,
      missingElements,
      warnings,
    );
    _validateSystem(
      formData.appliances,
      photoKeyAppliances,
      photoCounts,
      missingElements,
      warnings,
    );
    _validateSystem(
      formData.lifeSafety,
      photoKeyLifeSafety,
      photoCounts,
      missingElements,
      warnings,
    );

    // 4. Branch flag conditionals
    if (formData.safetyHazard &&
        (photoCounts[photoKeyLifeSafety] ?? 0) < 2) {
      missingElements.add(
        'Safety hazard flagged — at least 2 life safety photos required',
      );
    }

    if (formData.moistureMoldEvidence &&
        formData.plumbing.findings.trim().isEmpty &&
        formData.roofing.findings.trim().isEmpty) {
      warnings.add(
        'Moisture/mold evidence flagged but no plumbing or roofing findings documented',
      );
    }

    if (formData.pestEvidence &&
        formData.exterior.findings.trim().isEmpty) {
      warnings.add(
        'Pest evidence flagged but no exterior findings documented',
      );
    }

    if (formData.structuralConcern &&
        formData.structural.findings.trim().isEmpty) {
      warnings.add(
        'Structural concern flagged but no structural findings documented',
      );
    }

    // 5. General comments warning
    if (formData.generalComments.trim().isEmpty) {
      warnings.add('General comments section is empty (recommended)');
    }

    return ComplianceCheckResult(
      isCompliant: missingElements.isEmpty,
      missingElements: missingElements,
      warnings: warnings,
    );
  }

  /// Validates a single system: rating must not be notInspected, deficient/
  /// marginal ratings require findings, and at least 1 photo is required.
  static void _validateSystem(
    SystemInspectionData system,
    String photoKey,
    Map<String, int> photoCounts,
    List<String> missingElements,
    List<String> warnings,
  ) {
    final name = system.systemName;

    // System rating must be set
    if (system.rating == ConditionRating.notInspected) {
      missingElements.add('$name rating is required');
    }

    // Deficient or marginal rating requires findings
    if ((system.rating == ConditionRating.deficient ||
            system.rating == ConditionRating.marginal) &&
        system.findings.trim().isEmpty) {
      missingElements.add(
        '$name findings required for ${system.rating.displayLabel} rating',
      );
    }

    // At least 1 photo per system
    if ((photoCounts[photoKey] ?? 0) < 1) {
      missingElements.add('At least 1 $name photo is required');
    }

    // Subsystem warnings (non-blocking)
    for (final sub in system.subsystems) {
      if ((sub.rating == ConditionRating.deficient ||
              sub.rating == ConditionRating.marginal) &&
          sub.findings.trim().isEmpty) {
        warnings.add(
          '${sub.name} subsystem has ${sub.rating.displayLabel} rating '
          'without findings (recommended)',
        );
      }
    }
  }
}
