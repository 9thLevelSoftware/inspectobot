import 'dart:typed_data';

import '../../inspection/domain/form_type.dart';
import '../pdf_generation_input.dart';
import '../domain/pdf_size_budget.dart';
import 'narrative_exceptions.dart';
import 'narrative_media_resolver.dart';
import 'narrative_pdf_renderer.dart';
import 'narrative_print_theme.dart';
import 'narrative_render_context.dart';
import 'narrative_template_registry.dart';

/// Orchestrates narrative PDF generation for a single form type.
///
/// Resolves photos, builds a [NarrativeRenderContext], then delegates
/// to [NarrativePdfRenderer] to produce the final PDF bytes.
class NarrativeReportEngine {
  NarrativeReportEngine({
    required NarrativeTemplateRegistry registry,
    required NarrativeMediaResolver mediaResolver,
    required NarrativePrintTheme theme,
    NarrativePdfRenderer? renderer,
  })  : _registry = registry,
        _mediaResolver = mediaResolver,
        _theme = theme,
        _renderer = renderer ?? const NarrativePdfRenderer();

  final NarrativeTemplateRegistry _registry;
  final NarrativeMediaResolver _mediaResolver;
  final NarrativePrintTheme _theme;
  final NarrativePdfRenderer _renderer;

  /// Whether this engine has a registered template for [formType].
  bool supports(FormType formType) => _registry.supports(formType);

  /// Generates narrative PDF bytes for the given [formType].
  ///
  /// Throws [NarrativeTemplateNotFoundError] if no template is registered.
  /// Throws [NarrativeRenderException] if rendering fails.
  Future<Uint8List> generate({
    required PdfGenerationInput input,
    required FormType formType,
    required PdfSizeRetryStep retryStep,
  }) async {
    // 1. Look up template
    final template = _registry.require(formType);

    // 2. Resolve photos
    final resolvedPhotos = await _mediaResolver.resolveAll(
      input: input,
      photoKeys: template.requiredPhotoKeys,
      retryStep: retryStep,
    );

    // 3. Build render context from input
    final context = _buildRenderContext(input, resolvedPhotos, formType);

    // 4. Get form data
    final formData = input.narrativeFormData[formType] ?? {};
    final branchContext = input.branchContext;

    // 5. Render
    try {
      return await _renderer.render(
        template: template,
        theme: _theme,
        context: context,
        formData: formData,
        branchContext: branchContext,
      );
    } catch (e) {
      throw NarrativeRenderException(
        message: 'Failed to render narrative PDF',
        formType: formType,
        cause: e,
      );
    }
  }

  NarrativeRenderContext _buildRenderContext(
    PdfGenerationInput input,
    Map<String, List<ResolvedNarrativePhoto>> resolvedPhotos,
    FormType formType,
  ) {
    final formData = input.narrativeFormData[formType] ?? {};
    return NarrativeRenderContext(
      resolvedPhotos: resolvedPhotos,
      signatureBytes: input.signatureBytes,
      formData: formData,
      inspectorName: input.fieldValues['inspector_name'] ?? '',
      inspectorLicense: input.fieldValues['inspector_license'] ?? '',
      inspectorCompany: input.fieldValues['inspector_company'] ?? '',
      clientName: input.clientName,
      propertyAddress: input.propertyAddress,
      inspectionDate: DateTime.now(),
      inspectionId: input.inspectionId,
    );
  }
}
