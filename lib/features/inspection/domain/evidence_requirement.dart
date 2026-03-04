import 'form_type.dart';
import 'required_photo_category.dart';

enum EvidenceMediaType { photo, document }

typedef EvidencePredicate = bool Function(Map<String, dynamic> branchContext);

class EvidenceRequirement {
  const EvidenceRequirement({
    required this.key,
    required this.label,
    required this.form,
    required this.mediaType,
    required this.minimumCount,
    this.category,
    this.group,
    this.isRequired = _alwaysRequired,
  });

  final String key;
  final String label;
  final FormType form;
  final EvidenceMediaType mediaType;
  final int minimumCount;
  final RequiredPhotoCategory? category;
  final String? group;
  final EvidencePredicate isRequired;

  bool applies(Map<String, dynamic> branchContext) => isRequired(branchContext);

  static bool _alwaysRequired(Map<String, dynamic> _) => true;
}
