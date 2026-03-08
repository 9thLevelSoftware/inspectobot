import 'package:flutter/material.dart';

import 'package:inspectobot/common/widgets/section_header.dart';
import 'package:inspectobot/features/inspection/domain/condition_rating.dart';
import 'package:inspectobot/features/inspection/domain/general_inspection_compliance_validator.dart';
import 'package:inspectobot/features/inspection/domain/general_inspection_form_data.dart';
import 'package:inspectobot/features/inspection/domain/system_inspection_data.dart';
import 'package:inspectobot/theme/theme.dart';

/// General Inspection review step: summary, compliance check, and branch flags.
///
/// Displays a system completion checklist, compliance banners, general comments
/// field, and condition flag toggles.
class GeneralInspectionReviewStep extends StatelessWidget {
  const GeneralInspectionReviewStep({
    super.key,
    required this.formData,
    required this.onChanged,
    this.hasInspectorLicense = false,
    this.photoCounts = const {},
  });

  final GeneralInspectionFormData formData;
  final ValueChanged<GeneralInspectionFormData> onChanged;
  final bool hasInspectorLicense;
  final Map<String, int> photoCounts;

  List<SystemInspectionData> get _allSystems => [
        formData.structural,
        formData.exterior,
        formData.roofing,
        formData.plumbing,
        formData.electrical,
        formData.hvac,
        formData.insulationVentilation,
        formData.appliances,
        formData.lifeSafety,
      ];

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;

    return SingleChildScrollView(
      padding: tokens.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Compliance banner
          _buildComplianceBanner(context),

          SizedBox(height: tokens.spacingMd),

          // 2. System completion checklist
          const SectionHeader(title: 'System Condition Summary'),
          SizedBox(height: tokens.spacingSm),
          ..._allSystems.map((system) {
            final isRated =
                system.rating != ConditionRating.notInspected;
            return ListTile(
              leading: Icon(
                isRated ? Icons.check_circle : Icons.cancel,
                color: isRated ? Palette.success : Palette.error,
              ),
              title: Text(system.systemName),
              trailing: Text(system.rating.displayLabel),
            );
          }),

          SizedBox(height: tokens.spacingLg),

          // 3. General comments
          const SectionHeader(title: 'General Comments'),
          SizedBox(height: tokens.spacingSm),
          TextFormField(
            initialValue: formData.generalComments,
            decoration: const InputDecoration(
              labelText: 'General Comments',
              alignLabelWithHint: true,
            ),
            maxLines: null,
            minLines: 4,
            textInputAction: TextInputAction.newline,
            onChanged: (value) {
              onChanged(formData.copyWith(generalComments: value));
            },
          ),

          SizedBox(height: tokens.spacingLg),

          // 4. Branch flag toggles
          const SectionHeader(title: 'Condition Flags'),
          SizedBox(height: tokens.spacingSm),
          SwitchListTile(
            title: const Text('Safety Hazard Identified'),
            value: formData.safetyHazard,
            onChanged: (value) {
              onChanged(formData.copyWith(safetyHazard: value));
            },
          ),
          SwitchListTile(
            title: const Text('Moisture/Mold Evidence'),
            value: formData.moistureMoldEvidence,
            onChanged: (value) {
              onChanged(formData.copyWith(moistureMoldEvidence: value));
            },
          ),
          SwitchListTile(
            title: const Text('Pest Evidence'),
            value: formData.pestEvidence,
            onChanged: (value) {
              onChanged(formData.copyWith(pestEvidence: value));
            },
          ),
          SwitchListTile(
            title: const Text('Structural Concern'),
            value: formData.structuralConcern,
            onChanged: (value) {
              onChanged(formData.copyWith(structuralConcern: value));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceBanner(BuildContext context) {
    final result = GeneralInspectionComplianceValidator.validate(
      formData,
      hasInspectorLicense: hasInspectorLicense,
      photoCounts: photoCounts,
    );

    final widgets = <Widget>[];

    if (!result.isCompliant) {
      widgets.add(
        Container(
          width: double.infinity,
          padding: AppEdgeInsets.cardPaddingCompact,
          decoration: BoxDecoration(
            color: Palette.error.withValues(alpha: 0.15),
            borderRadius: AppRadii.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Missing Required Elements',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Palette.error,
                    ),
              ),
              const SizedBox(height: AppSpacing.spacingXs),
              ...result.missingElements.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '• $e',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Palette.error,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (result.warnings.isNotEmpty && result.isCompliant) {
      widgets.add(
        Container(
          width: double.infinity,
          padding: AppEdgeInsets.cardPaddingCompact,
          decoration: BoxDecoration(
            color: Palette.warning.withValues(alpha: 0.15),
            borderRadius: AppRadii.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Warnings',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Palette.warning,
                    ),
              ),
              const SizedBox(height: AppSpacing.spacingXs),
              ...result.warnings.map(
                (w) => Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '• $w',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Palette.warning,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (widgets.isEmpty) return const SizedBox.shrink();
    return Column(children: widgets);
  }
}
