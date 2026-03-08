import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/required_photo_category.dart';
import 'package:inspectobot/features/pdf/domain/pdf_size_budget.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_media_resolver.dart';
import 'package:inspectobot/features/pdf/pdf_generation_input.dart';

void main() {
  late NarrativeMediaResolver resolver;
  late PdfSizeRetryStep retryStep;

  setUp(() {
    resolver = const NarrativeMediaResolver();
    retryStep = const PdfSizeRetryStep(jpegQuality: 75, maxWidth: 1280);
  });

  PdfGenerationInput buildInput({
    Map<String, List<String>> evidenceMediaPaths = const {},
  }) {
    return PdfGenerationInput(
      inspectionId: 'test-001',
      organizationId: 'org-001',
      userId: 'user-001',
      clientName: 'Test Client',
      propertyAddress: '123 Main St',
      enabledForms: {FormType.fourPoint},
      capturedCategories: const <RequiredPhotoCategory>{},
      evidenceMediaPaths: evidenceMediaPaths,
    );
  }

  group('NarrativeMediaResolver', () {
    test('returns empty map for empty photoKeys', () async {
      final input = buildInput();

      final result = await resolver.resolveAll(
        input: input,
        photoKeys: const {},
        retryStep: retryStep,
      );

      expect(result, isEmpty);
    });

    test('resolves local file paths to bytes', () async {
      // Create a temp file with test content
      final tempDir = await Directory.systemTemp.createTemp('media_test_');
      final tempFile = File('${tempDir.path}/test_photo.jpg');
      final testBytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 0x00]);
      await tempFile.writeAsBytes(testBytes);

      try {
        final input = buildInput(
          evidenceMediaPaths: {
            'roof_photo': [tempFile.path],
          },
        );

        final result = await resolver.resolveAll(
          input: input,
          photoKeys: {'roof_photo'},
          retryStep: retryStep,
        );

        expect(result, contains('roof_photo'));
        expect(result['roof_photo'], hasLength(1));
        expect(result['roof_photo']!.first.isResolved, isTrue);
        expect(result['roof_photo']!.first.bytes, equals(testBytes));
        expect(result['roof_photo']!.first.sourceKey, equals('roof_photo'));
      } finally {
        await tempDir.delete(recursive: true);
      }
    });

    test('returns unresolved entries with failure reasons for missing files',
        () async {
      final input = buildInput(
        evidenceMediaPaths: {
          'missing_photo': ['/nonexistent/path/photo.jpg'],
        },
      );

      final result = await resolver.resolveAll(
        input: input,
        photoKeys: {'missing_photo'},
        retryStep: retryStep,
      );

      expect(result, contains('missing_photo'));
      expect(result['missing_photo']!.first.isResolved, isFalse);
      expect(result['missing_photo']!.first.failureReason, isNotNull);
      expect(result['missing_photo']!.first.failureReason, isNotEmpty);
    });

    test('skips keys with no media paths in input', () async {
      final input = buildInput();

      final result = await resolver.resolveAll(
        input: input,
        photoKeys: {'unknown_key'},
        retryStep: retryStep,
      );

      // Key has no paths, so it's skipped entirely
      expect(result, isEmpty);
    });

    test('falls back to remote reader when local file not found', () async {
      final remoteBytes =
          Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A]);

      final resolver = NarrativeMediaResolver(
        remoteReadBytes: (path) async => remoteBytes,
      );

      final input = buildInput(
        evidenceMediaPaths: {
          'cloud_photo': ['/nonexistent/local/path.jpg'],
        },
      );

      final result = await resolver.resolveAll(
        input: input,
        photoKeys: {'cloud_photo'},
        retryStep: retryStep,
      );

      expect(result, contains('cloud_photo'));
      expect(result['cloud_photo']!.first.isResolved, isTrue);
      expect(result['cloud_photo']!.first.bytes, equals(remoteBytes));
    });

    test('captures remote reader failure gracefully', () async {
      final resolver = NarrativeMediaResolver(
        remoteReadBytes: (path) async => throw Exception('Network error'),
      );

      final input = buildInput(
        evidenceMediaPaths: {
          'error_photo': ['/missing/path.jpg'],
        },
      );

      final result = await resolver.resolveAll(
        input: input,
        photoKeys: {'error_photo'},
        retryStep: retryStep,
      );

      expect(result, contains('error_photo'));
      expect(result['error_photo']!.first.isResolved, isFalse);
      expect(
        result['error_photo']!.first.failureReason,
        contains('remote read failed'),
      );
    });

    test('resolves multiple paths for the same key', () async {
      final tempDir = await Directory.systemTemp.createTemp('media_test_');
      final file1 = File('${tempDir.path}/photo1.jpg');
      final file2 = File('${tempDir.path}/photo2.jpg');
      await file1.writeAsBytes([0x01, 0x02]);
      await file2.writeAsBytes([0x03, 0x04]);

      try {
        final input = buildInput(
          evidenceMediaPaths: {
            'multi_photo': [file1.path, file2.path],
          },
        );

        final result = await resolver.resolveAll(
          input: input,
          photoKeys: {'multi_photo'},
          retryStep: retryStep,
        );

        expect(result['multi_photo'], hasLength(2));
        expect(result['multi_photo']![0].isResolved, isTrue);
        expect(result['multi_photo']![1].isResolved, isTrue);
      } finally {
        await tempDir.delete(recursive: true);
      }
    });
  });
}
