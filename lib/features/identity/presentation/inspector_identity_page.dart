import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:inspectobot/features/identity/data/inspector_profile_repository.dart';
import 'package:inspectobot/features/identity/data/signature_repository.dart';
import 'package:inspectobot/features/identity/domain/inspector_profile.dart';

class InspectorIdentityPage extends StatefulWidget {
  const InspectorIdentityPage({
    super.key,
    required this.organizationId,
    required this.userId,
    InspectorProfileRepository? profileRepository,
    SignatureRepository? signatureRepository,
  }) : _profileRepository = profileRepository,
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
  final _signaturePoints = <Offset>[];
  bool _saving = false;
  String? _status;
  SignatureRecord? _signatureRecord;

  InspectorProfileRepository get _profileRepository =>
      widget._profileRepository ?? InspectorProfileRepository.live();
  SignatureRepository get _signatureRepository =>
      widget._signatureRepository ?? SignatureRepository.live();

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    final profile = await _profileRepository.loadProfile(
      organizationId: widget.organizationId,
      userId: widget.userId,
    );
    final signature = await _signatureRepository.loadSignature(
      organizationId: widget.organizationId,
      userId: widget.userId,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _licenseTypeController.text = profile?.licenseType ?? '';
      _licenseNumberController.text = profile?.licenseNumber ?? '';
      _signatureRecord = signature;
    });
  }

  @override
  void dispose() {
    _licenseTypeController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _status = null;
    });

    try {
      final profile = InspectorProfile(
        organizationId: widget.organizationId,
        userId: widget.userId,
        licenseType: _licenseTypeController.text.trim(),
        licenseNumber: _licenseNumberController.text.trim(),
      );
      await _profileRepository.upsertProfile(profile);

      if (_signaturePoints.isNotEmpty) {
        final encoded = utf8.encode(
          jsonEncode(
            _signaturePoints
                .map((point) => {'x': point.dx, 'y': point.dy})
                .toList(),
          ),
        );
        _signatureRecord = await _signatureRepository.saveSignature(
          organizationId: widget.organizationId,
          userId: widget.userId,
          bytes: encoded,
        );
      }

      if (!mounted) {
        return;
      }
      setState(() {
        _status = 'Identity saved.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inspector Identity')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _licenseTypeController,
            decoration: const InputDecoration(labelText: 'License Type'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _licenseNumberController,
            decoration: const InputDecoration(labelText: 'License Number'),
          ),
          const SizedBox(height: 20),
          const Text('Draw Signature'),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ColoredBox(
              color: Colors.white,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() => _signaturePoints.add(details.localPosition));
                },
                child: SizedBox(
                  height: 180,
                  child: CustomPaint(
                    painter: _SignaturePainter(points: _signaturePoints),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton(
                onPressed: () => setState(_signaturePoints.clear),
                child: const Text('Clear Signature'),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Saving...' : 'Save Identity'),
              ),
            ],
          ),
          if (_signatureRecord != null) ...[
            const SizedBox(height: 8),
            Text('Latest signature hash: ${_signatureRecord!.fileHash}'),
            Text('Stored at: ${_signatureRecord!.storagePath}'),
          ],
          if (_status != null) ...[
            const SizedBox(height: 8),
            Text(_status!, style: const TextStyle(color: Colors.green)),
          ],
        ],
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  const _SignaturePainter({required this.points});

  final List<Offset> points;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;

    for (var i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
