import 'package:inspectobot/features/inspection/domain/form_type.dart';

class NarrativeRenderException implements Exception {
  const NarrativeRenderException({
    required this.message,
    required this.formType,
    this.cause,
  });

  final String message;
  final FormType formType;
  final Object? cause;

  @override
  String toString() =>
      'NarrativeRenderException($formType): $message${cause != null ? ' cause=$cause' : ''}';
}

class NarrativeTemplateNotFoundError implements Exception {
  const NarrativeTemplateNotFoundError(this.formType);

  final FormType formType;

  @override
  String toString() => 'No narrative template registered for ${formType.code}';
}
