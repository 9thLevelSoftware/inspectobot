import 'package:flutter/material.dart';

import 'package:inspectobot/theme/theme.dart';

import '../../../delivery/domain/report_artifact.dart';
import '../../domain/report_readiness.dart';

/// Renders the PDF generation button, last PDF path, and delivery actions
/// (download / secure share).
///
/// Pure [StatelessWidget] -- receives all data and callbacks from the parent.
class PdfDeliveryView extends StatelessWidget {
  const PdfDeliveryView({
    super.key,
    required this.readiness,
    required this.isComplete,
    required this.isGenerating,
    this.lastPdfPath,
    this.lastArtifact,
    required this.onGeneratePdf,
    required this.onDownload,
    required this.onShare,
  });

  final ReportReadiness readiness;
  final bool isComplete;
  final bool isGenerating;
  final String? lastPdfPath;
  final ReportArtifact? lastArtifact;
  final VoidCallback onGeneratePdf;
  final VoidCallback onDownload;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final canGenerate = readiness.isReady;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          key: const ValueKey('generate-pdf-button'),
          onPressed: isComplete && canGenerate && !isGenerating
              ? onGeneratePdf
              : null,
          icon: isGenerating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.picture_as_pdf),
          label: Text(
            isComplete && canGenerate
                ? 'Generate PDF'
                : 'Readiness blocked: ${readiness.missingItems.join(', ')}',
          ),
        ),
        if (lastPdfPath != null) ...[
          SizedBox(height: AppSpacing.spacingMd),
          SelectableText('Last PDF: $lastPdfPath'),
        ],
        if (lastArtifact != null) ...[
          SizedBox(height: AppSpacing.spacingMd),
          Wrap(
            spacing: AppSpacing.spacingSm,
            runSpacing: AppSpacing.spacingSm,
            children: [
              OutlinedButton.icon(
                key: const ValueKey('delivery-download-button'),
                onPressed: onDownload,
                icon: const Icon(Icons.download),
                label: const Text('Download'),
              ),
              OutlinedButton.icon(
                key: const ValueKey('delivery-secure-share-button'),
                onPressed: onShare,
                icon: const Icon(Icons.ios_share),
                label: const Text('Secure Share'),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
