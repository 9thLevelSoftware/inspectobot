import 'package:flutter/material.dart';

import 'package:inspectobot/features/inspection/domain/general_inspection_form_data.dart';
import 'package:inspectobot/features/inspection/domain/system_inspection_data.dart';
import 'package:inspectobot/features/inspection/presentation/sub_views/general_inspection_scope_step.dart';
import 'package:inspectobot/features/inspection/presentation/sub_views/general_inspection_system_step.dart';
import 'package:inspectobot/features/inspection/presentation/sub_views/general_inspection_review_step.dart';
import 'package:inspectobot/theme/theme.dart';

class GeneralInspectionFormStep extends StatefulWidget {
  const GeneralInspectionFormStep({
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

  @override
  State<GeneralInspectionFormStep> createState() => _GeneralInspectionFormStepState();
}

class _GeneralInspectionFormStepState extends State<GeneralInspectionFormStep>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = <String>[
    'Scope',
    'Structural',
    'Exterior',
    'Roofing',
    'Plumbing',
    'Electrical',
    'HVAC',
    'Insulation',
    'Appliances',
    'Life Safety',
    'Review',
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
    return Column(children: [
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
            GeneralInspectionScopeStep(
              formData: widget.formData,
              onChanged: widget.onChanged,
            ),
            _buildSystemTab(widget.formData.structural),
            _buildSystemTab(widget.formData.exterior),
            _buildSystemTab(widget.formData.roofing),
            _buildSystemTab(widget.formData.plumbing),
            _buildSystemTab(widget.formData.electrical),
            _buildSystemTab(widget.formData.hvac),
            _buildSystemTab(widget.formData.insulationVentilation),
            _buildSystemTab(widget.formData.appliances),
            _buildSystemTab(widget.formData.lifeSafety),
            GeneralInspectionReviewStep(
              formData: widget.formData,
              onChanged: widget.onChanged,
              hasInspectorLicense: widget.hasInspectorLicense,
              photoCounts: widget.photoCounts,
            ),
          ],
        ),
      ),
    ]);
  }

  Widget _buildSystemTab(SystemInspectionData system) {
    return GeneralInspectionSystemStep(
      systemData: system,
      onChanged: (updated) {
        widget.onChanged(widget.formData.updateSystem(system.systemId, updated));
      },
    );
  }
}
