import 'package:flutter/material.dart';

import 'package:inspectobot/common/widgets/widgets.dart';
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

    return SingleChildScrollView(
      padding: AppEdgeInsets.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Report & Delivery', style: AppTypography.sectionTitle),
          const SizedBox(height: AppSpacing.spacingLg),
          SectionCard(
            title: 'Generate Report',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!isComplete || !canGenerate)
                  Text(
                    'Blocked: ${readiness.missingItems.join(", ")}',
                    style: AppTypography.fieldLabelRequired,
                  ),
                const SizedBox(height: AppSpacing.spacingSm),
                AppButton(
                  key: const ValueKey('generate-pdf-button'),
                  label: isGenerating ? 'Generating...' : 'Generate PDF',
                  icon: Icons.picture_as_pdf,
                  onPressed: isComplete && canGenerate && !isGenerating
                      ? onGeneratePdf
                      : null,
                  isLoading: isGenerating,
                  loadingLabel: 'Generating...',
                  isThumbZone: true,
                ),
              ],
            ),
          ),
          if (lastPdfPath != null) ...[
            SizedBox(height: AppSpacing.spacingMd),
            SelectableText('Last PDF: $lastPdfPath'),
          ],
          if (lastArtifact != null) ...[
            SizedBox(height: AppSpacing.spacingLg),
            SectionCard(
              title: 'Delivery Actions',
              child: Wrap(
                spacing: AppSpacing.spacingSm,
                runSpacing: AppSpacing.spacingSm,
                children: [
                  AppButton(
                    key: const ValueKey('delivery-download-button'),
                    label: 'Download',
                    icon: Icons.download,
                    onPressed: onDownload,
                    variant: AppButtonVariant.outlined,
                  ),
                  AppButton(
                    key: const ValueKey('delivery-secure-share-button'),
                    label: 'Secure Share',
                    icon: Icons.ios_share,
                    onPressed: onShare,
                    variant: AppButtonVariant.outlined,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
