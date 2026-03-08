import 'package:flutter/material.dart';

import 'package:inspectobot/common/widgets/section_header.dart';
import 'package:inspectobot/features/inspection/domain/condition_rating.dart';
import 'package:inspectobot/features/inspection/domain/system_inspection_data.dart';
import 'package:inspectobot/theme/theme.dart';

/// Reusable widget that renders the inspection UI for any of the 9 building
/// systems in a General Home Inspection (Rule 61-30.801).
///
/// Displays system-level condition rating and findings, plus expandable
/// subsystem panels when the system has sub-components.
class GeneralInspectionSystemStep extends StatelessWidget {
  const GeneralInspectionSystemStep({
    super.key,
    required this.systemData,
    required this.onChanged,
  });

  final SystemInspectionData systemData;
  final ValueChanged<SystemInspectionData> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;

    return SingleChildScrollView(
      padding: tokens.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: systemData.systemName),
          SizedBox(height: tokens.spacingSm),

          // System-level rating
          Text(
            'Overall Condition Rating',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Palette.onSurfaceVariant,
                ),
          ),
          SizedBox(height: tokens.spacingSm),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ConditionRating>(
              segments: const [
                ButtonSegment(
                  value: ConditionRating.satisfactory,
                  label: Text('Satisfactory'),
                ),
                ButtonSegment(
                  value: ConditionRating.marginal,
                  label: Text('Marginal'),
                ),
                ButtonSegment(
                  value: ConditionRating.deficient,
                  label: Text('Deficient'),
                ),
                ButtonSegment(
                  value: ConditionRating.notInspected,
                  label: Text('N/A'),
                ),
              ],
              selected: {systemData.rating},
              onSelectionChanged: (selected) {
                onChanged(systemData.copyWith(rating: selected.first));
              },
            ),
          ),

          SizedBox(height: tokens.spacingMd),

          // System-level findings
          TextFormField(
            initialValue: systemData.findings,
            decoration: InputDecoration(
              labelText: '${systemData.systemName} Findings',
              alignLabelWithHint: true,
            ),
            maxLines: null,
            minLines: 4,
            textInputAction: TextInputAction.newline,
            onChanged: (value) {
              onChanged(systemData.copyWith(findings: value));
            },
          ),

          SizedBox(height: tokens.spacingLg),

          // Subsystems
          if (systemData.subsystems.isNotEmpty) ...[
            const SectionHeader(title: 'Sub-components'),
            SizedBox(height: tokens.spacingSm),
            ...List.generate(systemData.subsystems.length, (index) {
              final sub = systemData.subsystems[index];
              return ExpansionTile(
                title: Text(sub.name),
                initiallyExpanded: true,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: tokens.spacingMd,
                      vertical: tokens.spacingSm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Condition Rating',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Palette.onSurfaceVariant,
                                  ),
                        ),
                        SizedBox(height: tokens.spacingSm),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<ConditionRating>(
                            segments: const [
                              ButtonSegment(
                                value: ConditionRating.satisfactory,
                                label: Text('Satisfactory'),
                              ),
                              ButtonSegment(
                                value: ConditionRating.marginal,
                                label: Text('Marginal'),
                              ),
                              ButtonSegment(
                                value: ConditionRating.deficient,
                                label: Text('Deficient'),
                              ),
                              ButtonSegment(
                                value: ConditionRating.notInspected,
                                label: Text('N/A'),
                              ),
                            ],
                            selected: {sub.rating},
                            onSelectionChanged: (selected) {
                              _updateSubsystem(
                                index,
                                sub.copyWith(rating: selected.first),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: tokens.spacingMd),
                        TextFormField(
                          initialValue: sub.findings,
                          decoration: InputDecoration(
                            labelText: '${sub.name} Findings',
                            alignLabelWithHint: true,
                          ),
                          maxLines: null,
                          minLines: 3,
                          textInputAction: TextInputAction.newline,
                          onChanged: (value) {
                            _updateSubsystem(
                              index,
                              sub.copyWith(findings: value),
                            );
                          },
                        ),
                        SizedBox(height: tokens.spacingSm),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }

  void _updateSubsystem(int index, SubsystemData updated) {
    final updatedList = List<SubsystemData>.from(systemData.subsystems);
    updatedList[index] = updated;
    onChanged(systemData.copyWith(subsystems: updatedList));
  }
}
