import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_section.dart';

/// Abstract base for narrative report templates.
///
/// Each concrete template defines the section layout and data requirements
/// for a specific [FormType]. The renderer calls [buildSections] to obtain
/// the ordered list of sections, then renders each into PDF widgets.
abstract class NarrativeTemplate {
  const NarrativeTemplate({
    required this.formType,
    required this.revisionLabel,
    required this.title,
  });

  /// The inspection form type this template targets.
  final FormType formType;

  /// Human-readable revision identifier (e.g. "Rev 1.0 — March 2026").
  final String revisionLabel;

  /// Report title rendered on the first page and in page headers.
  final String title;

  /// Returns the ordered list of sections composing this report.
  ///
  /// [formData] contains the raw inspection answers keyed by field id.
  /// [branchContext] provides tenant/branch-level context (company name,
  /// logo URL, etc.) that may influence section content.
  List<NarrativeSection> buildSections({
    required Map<String, dynamic> formData,
    required Map<String, dynamic> branchContext,
  });

  /// Evidence photo source keys this template expects.
  ///
  /// Used by the orchestrator to resolve photos before rendering.
  Set<String> get requiredPhotoKeys;

  /// All formData keys this template reads.
  ///
  /// Used for validation warnings when expected keys are missing.
  Set<String> get referencedFormDataKeys;
}
