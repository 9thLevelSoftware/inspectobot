import 'package:flutter/material.dart';

import 'package:inspectobot/features/inspection/domain/mold_form_data.dart';
import 'package:inspectobot/features/inspection/presentation/sub_views/mold_moisture_step.dart';
import 'package:inspectobot/features/inspection/presentation/sub_views/mold_observations_step.dart';
import 'package:inspectobot/features/inspection/presentation/sub_views/mold_remediation_step.dart';
import 'package:inspectobot/features/inspection/presentation/sub_views/mold_scope_step.dart';
import 'package:inspectobot/features/inspection/presentation/sub_views/mold_type_location_step.dart';
import 'package:inspectobot/theme/theme.dart';

/// Renders the Mold Assessment form as a tabbed view with 5 tabs.
///
/// Uses [TabBarView] internally, so the parent must provide bounded height
/// (e.g. via [Expanded]).
class MoldFormStep extends StatefulWidget {
  const MoldFormStep({
    super.key,
    required this.formData,
    required this.onChanged,
  });

  final MoldFormData formData;
  final ValueChanged<MoldFormData> onChanged;

  @override
  State<MoldFormStep> createState() => _MoldFormStepState();
}

class _MoldFormStepState extends State<MoldFormStep>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = <String>[
    'Scope',
    'Observations',
    'Moisture',
    'Type/Location',
    'Remediation',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Palette.primary,
          labelColor: Palette.primary,
          unselectedLabelColor: Palette.onSurfaceVariant,
          tabAlignment: TabAlignment.start,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              MoldScopeStep(
                formData: widget.formData,
                onChanged: widget.onChanged,
              ),
              MoldObservationsStep(
                formData: widget.formData,
                onChanged: widget.onChanged,
              ),
              MoldMoistureStep(
                formData: widget.formData,
                onChanged: widget.onChanged,
              ),
              MoldTypeLocationStep(
                formData: widget.formData,
                onChanged: widget.onChanged,
              ),
              MoldRemediationStep(
                formData: widget.formData,
                onChanged: widget.onChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
