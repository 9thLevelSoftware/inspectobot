import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

import 'package:inspectobot/app/navigation_service.dart';
import 'package:inspectobot/app/routes.dart';
import 'package:inspectobot/common/widgets/widgets.dart';
import 'package:inspectobot/features/inspection/data/inspection_repository.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/inspection_draft.dart';
import 'package:inspectobot/features/inspection/domain/inspection_setup.dart';
import 'package:inspectobot/features/media/media_sync_remote_store.dart';
import 'package:inspectobot/features/media/pending_media_sync_store.dart';
import 'package:inspectobot/theme/theme.dart';

const _formDescriptions = {
  FormType.fourPoint:
      'Electrical, HVAC, plumbing, and water heater inspection',
  FormType.roofCondition:
      'Roof age, condition, and remaining useful life assessment',
  FormType.windMitigation:
      'Wind resistance features and discount qualification',
  FormType.wdo: 'Wood-destroying organism inspection (FDACS-13645)',
  FormType.sinkholeInspection:
      'Sinkhole indicators and foundation assessment',
  FormType.moldAssessment:
      'Mold assessment per Chapter 468 MRSA requirements',
  FormType.generalInspection:
      'Full home inspection per Rule 61-30.801',
};

class NewInspectionPage extends StatefulWidget {
  const NewInspectionPage({
    super.key,
    required this.organizationId,
    required this.userId,
    NewInspectionRepositoryProvider? repository,
    this.mediaSyncRemoteStore,
    this.pendingMediaSyncStore,
  }) : repository = repository ?? const _LazyNewInspectionRepository();

  final String organizationId;
  final String userId;
  final NewInspectionRepositoryProvider repository;
  final MediaSyncRemoteStore? mediaSyncRemoteStore;
  final PendingMediaSyncStore? pendingMediaSyncStore;

  @override
  State<NewInspectionPage> createState() => _NewInspectionPageState();
}

class _NewInspectionPageState extends State<NewInspectionPage> {
  static const Uuid _uuid = Uuid();

  /// Form categories for grouped display in the form selection section.
  static const _formCategories = <String, List<FormType>>{
    'Core Inspections': [
      FormType.fourPoint,
      FormType.roofCondition,
      FormType.windMitigation,
    ],
    'Specialized Inspections': [
      FormType.wdo,
      FormType.sinkholeInspection,
    ],
    'Narrative Reports': [
      FormType.moldAssessment,
      FormType.generalInspection,
    ],
  };
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _clientEmailController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  final _propertyAddressController = TextEditingController();
  final _inspectionDateController = TextEditingController();
  final _yearBuiltController = TextEditingController();

  final Set<FormType> _selectedForms = FormType.values.toSet();
  bool _isSaving = false;

  InspectionRepository get _repository => widget.repository.resolve();

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientEmailController.dispose();
    _clientPhoneController.dispose();
    _propertyAddressController.dispose();
    _inspectionDateController.dispose();
    _yearBuiltController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Validators
  // ---------------------------------------------------------------------------

  String? _requiredValidator(String? value, String fieldLabel) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldLabel is required';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    final requiredError = _requiredValidator(value, 'Client email');
    if (requiredError != null) {
      return requiredError;
    }
    final trimmed = value!.trim();
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(trimmed)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _inspectionDateValidator(String? value) {
    final requiredError = _requiredValidator(value, 'Inspection date');
    if (requiredError != null) {
      return requiredError;
    }
    final parsed = DateTime.tryParse(value!.trim());
    if (parsed == null) {
      return 'Enter a valid date (YYYY-MM-DD)';
    }
    final latestAllowed = DateTime.now().add(const Duration(days: 365));
    if (parsed.isAfter(latestAllowed)) {
      return 'Inspection date must be within the next year';
    }
    return null;
  }

  String? _yearBuiltValidator(String? value) {
    final requiredError = _requiredValidator(value, 'Year built');
    if (requiredError != null) {
      return requiredError;
    }
    final parsed = int.tryParse(value!.trim());
    if (parsed == null) {
      return 'Enter a valid year';
    }
    final maxYear = DateTime.now().year + 1;
    if (parsed < 1800 || parsed > maxYear) {
      return 'Year built must be between 1800 and $maxYear';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Save logic
  // ---------------------------------------------------------------------------

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedForms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one inspection form.')),
      );
      return;
    }

    if (_isSaving) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      final setup = InspectionSetup(
        id: _uuid.v4(),
        organizationId: widget.organizationId,
        userId: widget.userId,
        clientName: _clientNameController.text.trim(),
        clientEmail: _clientEmailController.text.trim(),
        clientPhone: _clientPhoneController.text.trim(),
        propertyAddress: _propertyAddressController.text.trim(),
        inspectionDate: DateTime.parse(_inspectionDateController.text.trim()),
        yearBuilt: int.parse(_yearBuiltController.text.trim()),
        enabledForms: _selectedForms,
      );

      final persisted = await _repository.createInspection(setup);
      if (!mounted) {
        return;
      }

      final draft = InspectionDraft(
        inspectionId: persisted.id,
        organizationId: persisted.organizationId,
        userId: persisted.userId,
        clientName: persisted.clientName,
        clientEmail: persisted.clientEmail,
        clientPhone: persisted.clientPhone,
        propertyAddress: persisted.propertyAddress,
        inspectionDate: persisted.inspectionDate,
        yearBuilt: persisted.yearBuilt,
        enabledForms: persisted.enabledForms,
      );

      GetIt.I<NavigationService>().go(
        AppRoutes.inspectionChecklist(persisted.id),
        extra: draft,
      );
    } catch (e) {
      debugPrint('Failed to save inspection setup: $e');
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save inspection setup. Please retry.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.appTokens;

    final expansionTileShape = RoundedRectangleBorder(
      borderRadius: AppRadii.md,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('New Inspection')),
      body: ReachZoneScaffold(
        stickyBottom: SizedBox(
          width: double.infinity,
          child: AppButton(
            label: 'Continue',
            loadingLabel: 'Saving...',
            isLoading: _isSaving,
            isThumbZone: true,
            onPressed: _isSaving ? null : _continue,
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.spacingLg,
              vertical: AppSpacing.spacingSm,
            ),
            children: [
              ExpansionTile(
                title: Text(
                  'Client Information',
                  style: tokens.sectionHeader,
                ),
                initiallyExpanded: true,
                backgroundColor: colorScheme.surface,
                collapsedBackgroundColor: colorScheme.surface,
                iconColor: colorScheme.primary,
                tilePadding: AppEdgeInsets.pageHorizontal,
                childrenPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.spacingLg,
                  vertical: AppSpacing.spacingSm,
                ),
                shape: expansionTileShape,
                collapsedShape: expansionTileShape,
                children: [
                  AppTextField(
                    label: 'Client Name',
                    controller: _clientNameController,
                    validator: (value) =>
                        _requiredValidator(value, 'Client name'),
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: AppSpacing.spacingMd),
                  AppTextField(
                    label: 'Client Email',
                    controller: _clientEmailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: _emailValidator,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: AppSpacing.spacingMd),
                  AppTextField(
                    label: 'Client Phone',
                    controller: _clientPhoneController,
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                        _requiredValidator(value, 'Client phone'),
                    textInputAction: TextInputAction.next,
                  ),
                ],
              ),

              SizedBox(height: AppSpacing.spacingMd),

              ExpansionTile(
                title: Text(
                  'Property Information',
                  style: tokens.sectionHeader,
                ),
                initiallyExpanded: true,
                backgroundColor: colorScheme.surface,
                collapsedBackgroundColor: colorScheme.surface,
                iconColor: colorScheme.primary,
                tilePadding: AppEdgeInsets.pageHorizontal,
                childrenPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.spacingLg,
                  vertical: AppSpacing.spacingSm,
                ),
                shape: expansionTileShape,
                collapsedShape: expansionTileShape,
                children: [
                  AppTextField(
                    label: 'Property Address',
                    controller: _propertyAddressController,
                    validator: (value) =>
                        _requiredValidator(value, 'Property address'),
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: AppSpacing.spacingMd),
                  AppTextField(
                    label: 'Inspection Date',
                    hint: 'YYYY-MM-DD',
                    controller: _inspectionDateController,
                    keyboardType: TextInputType.datetime,
                    validator: _inspectionDateValidator,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: AppSpacing.spacingMd),
                  AppTextField(
                    label: 'Year Built',
                    controller: _yearBuiltController,
                    keyboardType: TextInputType.number,
                    validator: _yearBuiltValidator,
                    textInputAction: TextInputAction.done,
                  ),
                ],
              ),

              SizedBox(height: AppSpacing.spacingMd),

              ExpansionTile(
                title: Text(
                  'Inspection Forms',
                  style: tokens.sectionHeader,
                ),
                initiallyExpanded: true,
                backgroundColor: colorScheme.surface,
                collapsedBackgroundColor: colorScheme.surface,
                iconColor: colorScheme.primary,
                tilePadding: AppEdgeInsets.pageHorizontal,
                childrenPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.spacingLg,
                  vertical: AppSpacing.spacingSm,
                ),
                shape: expansionTileShape,
                collapsedShape: expansionTileShape,
                children: [
                  // Select All / Deselect All toggle
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          if (_selectedForms.length == FormType.values.length) {
                            _selectedForms.clear();
                          } else {
                            _selectedForms.addAll(FormType.values);
                          }
                        });
                      },
                      child: Text(
                        _selectedForms.length == FormType.values.length
                            ? 'Deselect All'
                            : 'Select All',
                      ),
                    ),
                  ),
                  // Category-grouped form cards
                  for (final entry in _formCategories.entries) ...[
                    Padding(
                      padding: EdgeInsets.only(
                        top: entry.key == _formCategories.keys.first
                            ? 0
                            : AppSpacing.spacingSm,
                        bottom: AppSpacing.spacingXs,
                      ),
                      child: Text(
                        entry.key,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                    for (final form in entry.value) ...[
                      FormTypeCard(
                        label: form.label,
                        description: _formDescriptions[form] ?? '',
                        selected: _selectedForms.contains(form),
                        onChanged: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedForms.add(form);
                            } else {
                              _selectedForms.remove(form);
                            }
                          });
                        },
                      ),
                      SizedBox(height: AppSpacing.spacingSm),
                    ],
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

abstract class NewInspectionRepositoryProvider {
  InspectionRepository resolve();
}

class _LazyNewInspectionRepository implements NewInspectionRepositoryProvider {
  const _LazyNewInspectionRepository();

  @override
  InspectionRepository resolve() => InspectionRepository.live();
}
