import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_exceptions.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_template.dart';

/// Registry of narrative templates keyed by [FormType].
///
/// The orchestrator uses this to look up the correct template before
/// rendering a narrative report. Templates are registered at app startup.
class NarrativeTemplateRegistry {
  const NarrativeTemplateRegistry({
    this.templates = const <FormType, NarrativeTemplate>{},
  });

  /// Registered templates keyed by their target form type.
  final Map<FormType, NarrativeTemplate> templates;

  /// Returns the template for [formType], or `null` if not registered.
  NarrativeTemplate? lookup(FormType formType) => templates[formType];

  /// Returns the template for [formType], or throws
  /// [NarrativeTemplateNotFoundError] if not registered.
  NarrativeTemplate require(FormType formType) {
    final template = lookup(formType);
    if (template == null) {
      throw NarrativeTemplateNotFoundError(formType);
    }
    return template;
  }

  /// Whether a template is registered for [formType].
  bool supports(FormType formType) => templates.containsKey(formType);
}
