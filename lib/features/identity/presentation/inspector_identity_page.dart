import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:inspectobot/common/widgets/widgets.dart';
import 'package:inspectobot/features/identity/data/inspector_profile_repository.dart';
import 'package:inspectobot/features/identity/data/signature_repository.dart';
import 'package:inspectobot/features/identity/domain/inspector_profile.dart';
import 'package:inspectobot/theme/theme.dart';

class InspectorIdentityPage extends StatefulWidget {
  const InspectorIdentityPage({
    super.key,
    required this.organizationId,
    required this.userId,
    InspectorProfileRepository? profileRepository,
    SignatureRepository? signatureRepository,
  })  : _profileRepository = profileRepository,
        _signatureRepository = signatureRepository;

  final String organizationId;
  final String userId;
  final InspectorProfileRepository? _profileRepository;
  final SignatureRepository? _signatureRepository;

  @override
  State<InspectorIdentityPage> createState() => _InspectorIdentityPageState();
}

class _InspectorIdentityPageState extends State<InspectorIdentityPage> {
  final _licenseTypeController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _signatureController = SignaturePadController();
  bool _saving = false;
  bool _loading = true;
  String? _errorMessage;
  SignatureRecord? _signatureRecord;

  late final InspectorProfileRepository _profileRepository =
      widget._profileRepository ?? InspectorProfileRepository.live();
  late final SignatureRepository _signatureRepository =
      widget._signatureRepository ?? SignatureRepository.live();

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    setState(() => _loading = true);
    try {
      final profile = await _profileRepository.loadProfile(
        organizationId: widget.organizationId,
        userId: widget.userId,
      );
      final signature = await _signatureRepository.loadSignature(
        organizationId: widget.organizationId,
        userId: widget.userId,
      );
      if (!mounted) return;
      setState(() {
        _licenseTypeController.text = profile?.licenseType ?? '';
        _licenseNumberController.text = profile?.licenseNumber ?? '';
        _signatureRecord = signature;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Failed to load identity data.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _licenseTypeController.dispose();
    _licenseNumberController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      final profile = InspectorProfile(
        organizationId: widget.organizationId,
        userId: widget.userId,
        licenseType: _licenseTypeController.text.trim(),
        licenseNumber: _licenseNumberController.text.trim(),
      );
      await _profileRepository.upsertProfile(profile);

      SignatureRecord? newRecord;
      if (_signatureController.isNotEmpty) {
        final encoded = Uint8List.fromList(
          utf8.encode(
            jsonEncode(
              _signatureController.points
                  .map((point) => {'x': point.dx, 'y': point.dy})
                  .toList(),
            ),
          ),
        );
        newRecord = await _signatureRepository.saveSignature(
          organizationId: widget.organizationId,
          userId: widget.userId,
          bytes: encoded,
        );
      }

      if (!mounted) return;
      setState(() => _signatureRecord = newRecord ?? _signatureRecord);
      AppSnackBar.success(context, 'Identity saved.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Failed to save identity.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _metadataRow(String label, String value) {
    final tokens = context.appTokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: tokens.fieldLabel),
        SizedBox(width: tokens.spacingSm),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inspector Identity')),
      body: LoadingOverlay(
        isLoading: _loading,
        child: ReachZoneScaffold(
          body: ListView(
            padding: AppEdgeInsets.pagePadding,
            children: [
              SectionCard(
                title: 'License Information',
                child: Column(
                  children: [
                    AppTextField(
                      label: 'License Type',
                      controller: _licenseTypeController,
                    ),
                    SizedBox(height: AppSpacing.spacingMd),
                    AppTextField(
                      label: 'License Number',
                      controller: _licenseNumberController,
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.spacingLg),
              SectionCard(
                title: 'Signature',
                child: Column(
                  children: [
                    SignaturePad(
                      controller: _signatureController,
                      height: 200,
                    ),
                    SizedBox(height: AppSpacing.spacingSm),
                    Row(
                      children: [
                        AppButton(
                          variant: AppButtonVariant.text,
                          label: 'Clear',
                          icon: Icons.clear,
                          onPressed: () => _signatureController.clear(),
                        ),
                        const Spacer(),
                        if (_signatureRecord != null)
                          const StatusBadge(
                            label: 'Saved',
                            type: StatusBadgeType.success,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_signatureRecord != null) ...[
                SizedBox(height: AppSpacing.spacingMd),
                SectionCard(
                  title: 'Signature Details',
                  density: SectionCardDensity.compact,
                  child: Column(
                    children: [
                      _metadataRow('Hash', _signatureRecord!.fileHash),
                      SizedBox(height: AppSpacing.spacingXs),
                      _metadataRow(
                        'Captured',
                        _signatureRecord!.capturedAt.toLocal().toString(),
                      ),
                    ],
                  ),
                ),
              ],
              if (_errorMessage != null) ...[
                SizedBox(height: AppSpacing.spacingMd),
                ErrorBanner(message: _errorMessage!),
              ],
            ],
          ),
          stickyBottom: AppButton(
            label: 'Save Identity',
            loadingLabel: 'Saving...',
            onPressed: _save,
            isLoading: _saving,
            isThumbZone: true,
            icon: Icons.save,
          ),
        ),
      ),
    );
  }
}
