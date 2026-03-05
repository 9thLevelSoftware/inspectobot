import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:inspectobot/features/inspection/data/inspection_repository.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/inspection_draft.dart';
import 'package:inspectobot/features/inspection/domain/inspection_setup.dart';
import 'package:inspectobot/features/media/media_sync_remote_store.dart';
import 'package:inspectobot/features/media/pending_media_sync_store.dart';
import 'package:inspectobot/features/inspection/presentation/form_checklist_page.dart';

class NewInspectionPage extends StatefulWidget {
  const NewInspectionPage({
    super.key,
    required this.organizationId,
    required this.userId,
    NewInspectionRepositoryProvider? repository,
    this.mediaSyncRemoteStore,
    this.pendingMediaSyncStore,
  })
    : repository = repository ?? const _LazyNewInspectionRepository();

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

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => FormChecklistPage(
            draft: draft,
            repository: _repository,
            mediaSyncRemoteStore: widget.mediaSyncRemoteStore,
            pendingMediaSyncStore: widget.pendingMediaSyncStore,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to save inspection setup. Please retry.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Inspection')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _clientNameController,
              decoration: const InputDecoration(labelText: 'Client Name'),
              validator: (value) => _requiredValidator(value, 'Client name'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _clientEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Client Email'),
              validator: _emailValidator,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _clientPhoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Client Phone'),
              validator: (value) => _requiredValidator(value, 'Client phone'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _propertyAddressController,
              decoration: const InputDecoration(labelText: 'Property Address'),
              validator: (value) => _requiredValidator(value, 'Property address'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _inspectionDateController,
              keyboardType: TextInputType.datetime,
              decoration: const InputDecoration(
                labelText: 'Inspection Date',
                hintText: 'YYYY-MM-DD',
              ),
              validator: _inspectionDateValidator,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _yearBuiltController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Year Built'),
              validator: _yearBuiltValidator,
            ),
            const SizedBox(height: 16),
            const Text(
              'Enabled Forms',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            ...FormType.values.map(
              (form) => CheckboxListTile(
                title: Text(form.label),
                value: _selectedForms.contains(form),
                onChanged: (selected) {
                  setState(() {
                    if (selected ?? false) {
                      _selectedForms.add(form);
                    } else {
                      _selectedForms.remove(form);
                    }
                  });
                },
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _isSaving ? null : _continue,
              child: Text(
                _isSaving ? 'Saving...' : 'Continue to Required Photos',
              ),
            ),
          ],
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
