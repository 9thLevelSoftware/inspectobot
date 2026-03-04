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
    };
  }
}

