import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/pdf/cloud_pdf_service.dart';
import 'package:inspectobot/features/pdf/on_device_pdf_service.dart';
import 'package:inspectobot/features/pdf/pdf_generation_input.dart';
import 'package:inspectobot/features/pdf/pdf_orchestrator.dart';
import 'package:inspectobot/features/pdf/pdf_strategy.dart';

void main() {
  group('PdfOrchestrator narrative routing', () {
    test('overlay-only input with null narrative engine works fine', () async {
      final cloudFile = await _writePdfStub('overlay-only');
      final cloud = _FakeCloudPdfService(
        outcome: CloudPdfGenerationOutcome.generated(cloudFile),
      );
      final onDevice = _RecordingOnDevicePdfService();
      final orchestrator = PdfOrchestrator(
        onDevice: onDevice,
        cloud: cloud,
        primaryStrategy: PdfStrategy.cloudFallback,
      );

      final result = await orchestrator.generate(_overlayInput());

      expect(result, hasLength(1));
      expect(result.first.path, cloudFile.path);
    });

    test('narrative input with null narrative engine throws StateError',
        () async {
      final cloud = _FakeCloudPdfService(
        outcome: const CloudPdfGenerationOutcome.unavailable(
          reason: 'not needed',
        ),
      );
      final onDevice = _RecordingOnDevicePdfService();
      final orchestrator = PdfOrchestrator(
        onDevice: onDevice,
        cloud: cloud,
        primaryStrategy: PdfStrategy.cloudFallback,
      );

      expect(
        () => orchestrator.generate(_narrativeInput()),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('NarrativeReportEngine'),
          ),
        ),
      );
    });

    test('mixed input with null narrative engine throws StateError', () async {
      final cloud = _FakeCloudPdfService(
        outcome: const CloudPdfGenerationOutcome.unavailable(
          reason: 'not needed',
        ),
      );
      final onDevice = _RecordingOnDevicePdfService();
      final orchestrator = PdfOrchestrator(
        onDevice: onDevice,
        cloud: cloud,
        primaryStrategy: PdfStrategy.cloudFallback,
      );

      final input = PdfGenerationInput(
        inspectionId: 'insp-mixed-1',
        organizationId: 'org-1',
        userId: 'user-1',
        clientName: 'Mixed User',
        propertyAddress: '400 Mix Blvd',
        enabledForms: {FormType.fourPoint, FormType.moldAssessment},
        capturedCategories: const {},
      );

      expect(
        () => orchestrator.generate(input),
        throwsA(isA<StateError>()),
      );
    });
  });
}

PdfGenerationInput _overlayInput() {
  return PdfGenerationInput(
    inspectionId: 'insp-overlay-1',
    organizationId: 'org-1',
    userId: 'user-1',
    clientName: 'Overlay User',
    propertyAddress: '100 Overlay Ln',
    enabledForms: {FormType.fourPoint},
    capturedCategories: const {},
  );
}

PdfGenerationInput _narrativeInput() {
  return PdfGenerationInput(
    inspectionId: 'insp-narrative-1',
    organizationId: 'org-1',
    userId: 'user-1',
    clientName: 'Narrative User',
    propertyAddress: '200 Narrative Dr',
    enabledForms: {FormType.moldAssessment},
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
