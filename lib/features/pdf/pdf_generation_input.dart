import 'dart:typed_data';

import '../inspection/domain/form_type.dart';
import '../inspection/domain/required_photo_category.dart';

class PdfGenerationInput {
  PdfGenerationInput({
    required this.inspectionId,
    required this.organizationId,
    required this.userId,
    required this.clientName,
    required this.propertyAddress,
    required this.enabledForms,
    required this.capturedCategories,
    this.wizardCompletion = const <String, bool>{},
    this.branchContext = const <String, dynamic>{},
    this.fieldValues = const <String, String>{},
    this.checkboxValues = const <String, bool>{},
    this.evidenceMediaPaths = const <String, List<String>>{},
    this.signatureBytes,
  });

  final String inspectionId;
  final String organizationId;
  final String userId;
  final String clientName;
  final String propertyAddress;
  final Set<FormType> enabledForms;
  final Set<RequiredPhotoCategory> capturedCategories;
  final Map<String, bool> wizardCompletion;
  final Map<String, dynamic> branchContext;
  final Map<String, String> fieldValues;
  final Map<String, bool> checkboxValues;
  final Map<String, List<String>> evidenceMediaPaths;
  final Uint8List? signatureBytes;

  Map<String, dynamic> toCanonicalPayload() {
    final forms = enabledForms.map((form) => form.code).toList(growable: false)
      ..sort();
    final categories = capturedCategories
        .map((category) => category.name)
        .toList(growable: false)
      ..sort();
    final completionKeys = wizardCompletion.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList(growable: false)
      ..sort();
    final branchEntries = branchContext.entries.toList(growable: false)
      ..sort((a, b) => a.key.compareTo(b.key));
    final canonicalBranchContext = <String, dynamic>{};
    for (final entry in branchEntries) {
      canonicalBranchContext[entry.key] = entry.value;
    }

    final fieldEntries = fieldValues.entries.toList(growable: false)
      ..sort((a, b) => a.key.compareTo(b.key));
    final canonicalFieldValues = <String, String>{};
    for (final entry in fieldEntries) {
      canonicalFieldValues[entry.key] = entry.value;
    }

    final checkboxEntries = checkboxValues.entries.toList(growable: false)
      ..sort((a, b) => a.key.compareTo(b.key));
    final canonicalCheckboxValues = <String, bool>{};
    for (final entry in checkboxEntries) {
      canonicalCheckboxValues[entry.key] = entry.value;
    }

    final evidenceEntries = evidenceMediaPaths.entries.toList(growable: false)
      ..sort((a, b) => a.key.compareTo(b.key));
    final canonicalEvidencePaths = <String, List<String>>{};
    for (final entry in evidenceEntries) {
      final sortedPaths = List<String>.from(entry.value)..sort();
      canonicalEvidencePaths[entry.key] = sortedPaths;
    }

    return <String, dynamic>{
      'inspection_id': inspectionId,
      'organization_id': organizationId,
      'user_id': userId,
      'client_name': clientName,
      'property_address': propertyAddress,
      'enabled_forms': forms,
      'captured_categories': categories,
      'wizard_completion_keys': completionKeys,
      'branch_context': canonicalBranchContext,
      'field_values': canonicalFieldValues,
      'checkbox_values': canonicalCheckboxValues,
      'evidence_media_paths': canonicalEvidencePaths,
    };
  }
}

