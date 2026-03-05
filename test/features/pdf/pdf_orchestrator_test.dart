import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/pdf/cloud_pdf_service.dart';
import 'package:inspectobot/features/pdf/on_device_pdf_service.dart';
import 'package:inspectobot/features/pdf/pdf_generation_input.dart';
import 'package:inspectobot/features/pdf/pdf_orchestrator.dart';
import 'package:inspectobot/features/pdf/pdf_strategy.dart';

void main() {
  group('PdfOrchestrator cloudFallback strategy', () {
    test('returns cloud artifact when cloud generation succeeds', () async {
      final cloudFile = await _writePdfStub('cloud-success');
      final cloud = _FakeCloudPdfService(
        outcome: CloudPdfGenerationOutcome.generated(cloudFile),
      );
      final onDevice = _RecordingOnDevicePdfService();
      final orchestrator = PdfOrchestrator(
        onDevice: onDevice,
        cloud: cloud,
        primaryStrategy: PdfStrategy.cloudFallback,
      );

      final generated = await orchestrator.generate(_input());

      expect(generated.path, cloudFile.path);
      expect(onDevice.callCount, 0);
    });

    test('falls back to on-device when cloud is unavailable', () async {
      final cloud = _FakeCloudPdfService(
        outcome: const CloudPdfGenerationOutcome.unavailable(
          reason: 'cloud provider disabled',
        ),
      );
      final onDevice = _RecordingOnDevicePdfService();
      final orchestrator = PdfOrchestrator(
        onDevice: onDevice,
        cloud: cloud,
        primaryStrategy: PdfStrategy.cloudFallback,
      );

      final generated = await orchestrator.generate(_input());

      expect(await generated.exists(), isTrue);
      expect(onDevice.callCount, 1);
    });

    test('fails closed on terminal cloud failure without fallback', () async {
      final cloud = _FakeCloudPdfService(
        outcome: CloudPdfGenerationOutcome.terminalFailure(
          error: StateError('cloud api rejected request'),
          reason: 'terminal cloud failure',
        ),
      );
      final onDevice = _RecordingOnDevicePdfService();
      final orchestrator = PdfOrchestrator(
        onDevice: onDevice,
        cloud: cloud,
        primaryStrategy: PdfStrategy.cloudFallback,
      );

      expect(
        () => orchestrator.generate(_input()),
        throwsA(
          isA<PdfCloudGenerationTerminalFailure>().having(
            (error) => error.message,
            'message',
            contains('terminal cloud failure'),
          ),
        ),
      );
      expect(onDevice.callCount, 0);
    });
  });
}

PdfGenerationInput _input() {
  return PdfGenerationInput(
    inspectionId: 'insp-orchestrator-1',
    organizationId: 'org-1',
    userId: 'user-1',
    clientName: 'Cloud Path User',
    propertyAddress: '200 Strategy Ln',
    enabledForms: {FormType.fourPoint},
    capturedCategories: const {},
  );
}

Future<File> _writePdfStub(String suffix) async {
  final file = File(
    '${Directory.systemTemp.path}/inspectobot_orchestrator_$suffix.pdf',
  );
  await file.writeAsBytes(<int>[1, 2, 3, 4], flush: true);
  return file;
}

class _FakeCloudPdfService extends CloudPdfService {
  const _FakeCloudPdfService({required this.outcome});

  final CloudPdfGenerationOutcome outcome;

  @override
  Future<CloudPdfGenerationOutcome> generate(PdfGenerationInput input) async {
    return outcome;
  }
}

class _RecordingOnDevicePdfService extends OnDevicePdfService {
  int callCount = 0;

  @override
  Future<File> generate(PdfGenerationInput input) async {
    callCount += 1;
    return _writePdfStub('on-device-$callCount');
  }
}
