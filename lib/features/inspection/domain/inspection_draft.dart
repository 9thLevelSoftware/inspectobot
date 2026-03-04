import 'form_type.dart';
import 'required_photo_category.dart';

class InspectionDraft {
  InspectionDraft({
    required this.inspectionId,
    required this.clientName,
    required this.clientEmail,
    required this.clientPhone,
    required this.propertyAddress,
    required this.inspectionDate,
    required this.yearBuilt,
    required this.enabledForms,
  });

  final String inspectionId;
  final String clientName;
  final String clientEmail;
  final String clientPhone;
  final String propertyAddress;
  final DateTime inspectionDate;
  final int yearBuilt;
  final Set<FormType> enabledForms;

  final Set<RequiredPhotoCategory> capturedCategories =
      <RequiredPhotoCategory>{};
  final Map<RequiredPhotoCategory, String> capturedPhotoPaths =
      <RequiredPhotoCategory, String>{};
}
