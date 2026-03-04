import 'package:flutter/material.dart';

import '../../media/media_capture_service.dart';
import '../../pdf/cloud_pdf_service.dart';
import '../../pdf/on_device_pdf_service.dart';
import '../../pdf/pdf_generation_input.dart';
import '../../pdf/pdf_orchestrator.dart';
import '../domain/form_requirements.dart';
import '../domain/inspection_draft.dart';
import '../domain/required_photo_category.dart';

class FormChecklistPage extends StatefulWidget {
  const FormChecklistPage({super.key, required this.draft});

  final InspectionDraft draft;

  @override
  State<FormChecklistPage> createState() => _FormChecklistPageState();
}

class _FormChecklistPageState extends State<FormChecklistPage> {
  final _mediaCapture = MediaCaptureService();
  late final PdfOrchestrator _pdfOrchestrator;
  bool _isGenerating = false;
  String? _lastPdfPath;

  @override
  void initState() {
    super.initState();
    _pdfOrchestrator = PdfOrchestrator(
      onDevice: const OnDevicePdfService(),
      cloud: const CloudPdfService(),
    );
  }

  List<RequiredPhotoCategory> get _requiredCategories =>
      FormRequirements.forForms(widget.draft.enabledForms);

  bool get _isComplete {
    final captured = widget.draft.capturedCategories;
    return _requiredCategories.every(captured.contains);
  }

  Future<void> _capture(RequiredPhotoCategory category) async {
    final result = await _mediaCapture.captureRequiredPhoto(
      inspectionId: widget.draft.inspectionId,
      category: category,
    );
    if (!mounted || result == null) {
      return;
    }

    setState(() {
      widget.draft.capturedCategories.add(category);
      widget.draft.capturedPhotoPaths[category] = result.filePath;
    });
  }

  Future<void> _generatePdf() async {
    setState(() => _isGenerating = true);
    try {
      final file = await _pdfOrchestrator.generate(
        PdfGenerationInput(
          clientName: widget.draft.clientName,
          propertyAddress: widget.draft.propertyAddress,
          enabledForms: widget.draft.enabledForms,
          capturedCategories: widget.draft.capturedCategories,
        ),
      );
      final length = await file.length();
      final sizeKb = (length / 1024).toStringAsFixed(1);
      if (!mounted) {
        return;
      }
      setState(() {
        _lastPdfPath = file.path;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF generated (${sizeKb}KB): ${file.path}')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF generation failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Required Photos')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Inspection for ${widget.draft.clientName}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(widget.draft.propertyAddress),
          Text('Date: ${widget.draft.inspectionDate.toIso8601String().split('T').first}'),
          Text('Year built: ${widget.draft.yearBuilt}'),
          const SizedBox(height: 8),
          const Text(
            'Selected Forms',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          ...widget.draft.enabledForms.map((form) => Text('- ${form.label}')),
          const SizedBox(height: 16),
          ..._requiredCategories.map((category) {
            final captured = widget.draft.capturedCategories.contains(category);
            return Card(
              child: ListTile(
                title: Text(category.label),
                subtitle: Text(captured ? 'Captured' : 'Required'),
                trailing: captured
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : OutlinedButton(
                        onPressed: () => _capture(category),
                        child: const Text('Capture'),
                      ),
              ),
            );
          }),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _isComplete && !_isGenerating ? _generatePdf : null,
            icon: _isGenerating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.picture_as_pdf),
            label: Text(_isComplete
                ? 'Generate PDF'
                : 'Capture all required photos first'),
          ),
          if (_lastPdfPath != null) ...[
            const SizedBox(height: 12),
            SelectableText('Last PDF: $_lastPdfPath'),
          ],
        ],
      ),
    );
  }
}

