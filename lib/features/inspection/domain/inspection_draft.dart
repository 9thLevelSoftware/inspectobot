import 'form_type.dart';
import 'inspection_wizard_state.dart';
import 'required_photo_category.dart';

class InspectionDraft {
  InspectionDraft({
    required this.inspectionId,
    required this.organizationId,
    required this.userId,
    required this.clientName,
    required this.clientEmail,
    required this.clientPhone,
    required this.propertyAddress,
    required this.inspectionDate,
    required this.yearBuilt,
    required this.enabledForms,
    WizardProgressSnapshot? wizardSnapshot,
    int? initialStepIndex,
  })  : wizardSnapshot = wizardSnapshot ?? WizardProgressSnapshot.empty,
        initialStepIndex = initialStepIndex ?? 0;

  final String inspectionId;
  final String organizationId;
  final String userId;
  final String clientName;
  final String clientEmail;
  final String clientPhone;
  final String propertyAddress;
  final DateTime inspectionDate;
  final int yearBuilt;
  final Set<FormType> enabledForms;
  final WizardProgressSnapshot wizardSnapshot;
  final int initialStepIndex;

  final Set<RequiredPhotoCategory> capturedCategories =
      <RequiredPhotoCategory>{};
  final Map<RequiredPhotoCategory, String> capturedPhotoPaths =
      <RequiredPhotoCategory, String>{};
}
