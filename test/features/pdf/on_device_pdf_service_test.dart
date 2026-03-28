import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/pdf/data/pdf_media_resolver.dart';
import 'package:inspectobot/features/pdf/data/pdf_size_budget_config_store.dart';
import 'package:inspectobot/features/pdf/data/pdf_template_asset_loader.dart';
import 'package:inspectobot/features/pdf/domain/pdf_size_budget.dart';
import 'package:inspectobot/features/pdf/models/pdf_field_definition.dart';
import 'package:inspectobot/features/pdf/models/pdf_field_map.dart';
import 'package:inspectobot/features/pdf/models/pdf_manifest_entry.dart';
import 'package:inspectobot/features/pdf/on_device_pdf_service.dart';
import 'package:inspectobot/features/pdf/pdf_generation_input.dart';
import 'package:inspectobot/features/pdf/services/pdf_renderer.dart';

class _MockTemplateAssetLoader extends Mock implements PdfTemplateAssetLoader {}
class _MockMediaResolver extends Mock implements PdfMediaResolver {}
class _MockSizeBudgetStore extends Mock implements PdfSizeBudgetConfigStore {}
class _MockRenderer extends Mock implements PdfRenderer {}

void main() {
  group('OnDevicePdfService', () {
    late OnDevicePdfService service;
    late _MockTemplateAssetLoader mockTemplateLoader;
    late _MockMediaResolver mockMediaResolver;
    late _MockSizeBudgetStore mockBudgetStore;
    late _MockRenderer mockRenderer;

    setUp(() {
      mockTemplateLoader = _MockTemplateAssetLoader();
      mockMediaResolver = _MockMediaResolver();
      mockBudgetStore = _MockSizeBudgetStore();
      mockRenderer = _MockRenderer();

      service = OnDevicePdfService(
        templateAssetLoader: mockTemplateLoader,
        mediaResolver: mockMediaResolver,
        sizeBudgetStore: mockBudgetStore,
        renderer: mockRenderer,
        outputDirectoryProvider: () async => Directory.systemTemp,
      );
    });

    group('generate()', () {
      test('should generate PDF successfully for single form', () async {
        final input = _buildInput(enabledForms: {FormType.fourPoint});

        final budget = PdfSizeBudget(
          maxBytes: 10 * 1024 * 1024,
          retrySteps: [PdfRetryStep(photoBudget: 1.0, imageQuality: 90)],
        );
        when(() => mockBudgetStore.load()).thenReturn(budget);

        final fieldMap = PdfFieldMap(
          formType: FormType.fourPoint,
          fields: [],
        );
        final templateBundle = PdfTemplateBundle(
          manifestEntry: PdfManifestEntry(
            formType: FormType.fourPoint,
            version: '1.0',
            templateAssetPath: 'assets/test.pdf',
            fieldMapAssetPath: 'assets/map.json',
          ),
          fieldMap: fieldMap,
          templateBytes: Uint8List.fromList([1, 2, 3]),
        );
        when(() => mockTemplateLoader.load(FormType.fourPoint))
            .thenAnswer((_) async => templateBundle);

        final resolved = ResolvedPdfFieldData(
          imageByFieldKey: {},
          textByFieldKey: {},
          unresolvedMediaByFieldKey: {},
        );
        when(() => mockMediaResolver.resolve(
          input: any(named: 'input'),
          fieldMap: any(named: 'fieldMap'),
        )).thenAnswer((_) async => resolved);

        final pdfBytes = Uint8List.fromList([4, 5, 6]);
        when(() => mockRenderer.render(any())).thenAnswer((_) async => pdfBytes);

        final result = await service.generate(input);

        expect(result, isA<File>());
        expect(await result.exists(), isTrue);
      });

      test('should generate PDF for multiple forms sorted by code', () async {
        final input = _buildInput(
          enabledForms: {
            FormType.windMitigation,
            FormType.fourPoint,
            FormType.roofCondition,
          },
        );

        final budget = PdfSizeBudget(
          maxBytes: 10 * 1024 * 1024,
          retrySteps: [PdfRetryStep(photoBudget: 1.0, imageQuality: 90)],
        );
        when(() => mockBudgetStore.load()).thenReturn(budget);

        for (final form in [FormType.fourPoint, FormType.roofCondition, FormType.windMitigation]) {
          final templateBundle = PdfTemplateBundle(
            manifestEntry: PdfManifestEntry(
              formType: form,
              version: '1.0',
              templateAssetPath: 'assets/${form.code}.pdf',
              fieldMapAssetPath: 'assets/${form.code}.json',
            ),
            fieldMap: PdfFieldMap(formType: form, fields: []),
            templateBytes: Uint8List.fromList([1]),
          );
          when(() => mockTemplateLoader.load(form))
              .thenAnswer((_) async => templateBundle);
        }

        when(() => mockMediaResolver.resolve(
          input: any(named: 'input'),
          fieldMap: any(named: 'fieldMap'),
        )).thenAnswer((_) async => ResolvedPdfFieldData(
          imageByFieldKey: {},
          textByFieldKey: {},
          unresolvedMediaByFieldKey: {},
        ));

        final pdfBytes = Uint8List.fromList([4, 5, 6]);
        when(() => mockRenderer.render(any())).thenAnswer((_) async => pdfBytes);

        final result = await service.generate(input);

        expect(result, isA<File>());

        // Verify forms are loaded in sorted order
        verify(() => mockTemplateLoader.load(FormType.fourPoint)).called(1);
        verify(() => mockTemplateLoader.load(FormType.roofCondition)).called(1);
        verify(() => mockTemplateLoader.load(FormType.windMitigation)).called(1);
      });

      test('should throw when retry steps are empty', () async {
        final input = _buildInput();

        final budget = PdfSizeBudget(
          maxBytes: 10 * 1024 * 1024,
          retrySteps: [],
        );
        when(() => mockBudgetStore.load()).thenReturn(budget);

        expect(
          () => service.generate(input),
          throwsA(isA<PdfSizeBudgetConfigError>()),
        );
      });

      test('should throw size budget exceeded when over budget', () async {
        final input = _buildInput(enabledForms: {FormType.fourPoint});

        final budget = PdfSizeBudget(
          maxBytes: 100,
          retrySteps: [
            PdfRetryStep(photoBudget: 1.0, imageQuality: 90),
            PdfRetryStep(photoBudget: 0.5, imageQuality: 70),
          ],
        );
        when(() => mockBudgetStore.load()).thenReturn(budget);

        final templateBundle = PdfTemplateBundle(
          manifestEntry: PdfManifestEntry(
            formType: FormType.fourPoint,
            version: '1.0',
            templateAssetPath: 'assets/test.pdf',
            fieldMapAssetPath: 'assets/map.json',
          ),
          fieldMap: PdfFieldMap(formType: FormType.fourPoint, fields: []),
          templateBytes: Uint8List.fromList([1, 2, 3]),
        );
        when(() => mockTemplateLoader.load(FormType.fourPoint))
            .thenAnswer((_) async => templateBundle);

        when(() => mockMediaResolver.resolve(
          input: any(named: 'input'),
          fieldMap: any(named: 'fieldMap'),
        )).thenAnswer((_) async => ResolvedPdfFieldData(
          imageByFieldKey: {},
          textByFieldKey: {},
          unresolvedMediaByFieldKey: {},
        ));

        // Return bytes that exceed budget
        final largePdfBytes = Uint8List(1000);
        when(() => mockRenderer.render(any())).thenAnswer((_) async => largePdfBytes);

        expect(
          () => service.generate(input),
          throwsA(isA<PdfGenerationSizeBudgetExceeded>()),
        );
      });

      test('should retry with next step when within budget after retry', () async {
        final input = _buildInput(enabledForms: {FormType.fourPoint});

        final budget = PdfSizeBudget(
          maxBytes: 500,
          retrySteps: [
            PdfRetryStep(photoBudget: 1.0, imageQuality: 90),
            PdfRetryStep(photoBudget: 0.5, imageQuality: 70),
          ],
        );
        when(() => mockBudgetStore.load()).thenReturn(budget);

        final templateBundle = PdfTemplateBundle(
          manifestEntry: PdfManifestEntry(
            formType: FormType.fourPoint,
            version: '1.0',
            templateAssetPath: 'assets/test.pdf',
            fieldMapAssetPath: 'assets/map.json',
          ),
          fieldMap: PdfFieldMap(formType: FormType.fourPoint, fields: []),
          templateBytes: Uint8List.fromList([1, 2, 3]),
        );
        when(() => mockTemplateLoader.load(FormType.fourPoint))
            .thenAnswer((_) async => templateBundle);

        when(() => mockMediaResolver.resolve(
          input: any(named: 'input'),
          fieldMap: any(named: 'fieldMap'),
        )).thenAnswer((_) async => ResolvedPdfFieldData(
          imageByFieldKey: {},
          textByFieldKey: {},
          unresolvedMediaByFieldKey: {},
        ));

        // First render exceeds budget, second succeeds
        final largeBytes = Uint8List(1000);
        final smallBytes = Uint8List(100);
        when(() => mockRenderer.render(any())).thenAnswer((invocation) async {
          final request = invocation.positionalArguments[0] as PdfRenderRequest;
          return request.retryStep.photoBudget == 1.0 ? largeBytes : smallBytes;
        });

        final result = await service.generate(input);

        expect(result, isA<File>());
        verify(() => mockRenderer.render(any())).called(2);
      });

      test('should throw when required evidence is not resolved', () async {
        final input = _buildInput(
          enabledForms: {FormType.fourPoint},
          wizardCompletion: {'roof_photo': true},
        );

        final budget = PdfSizeBudget(
          maxBytes: 10 * 1024 * 1024,
          retrySteps: [PdfRetryStep(photoBudget: 1.0, imageQuality: 90)],
        );
        when(() => mockBudgetStore.load()).thenReturn(budget);

        final fieldMap = PdfFieldMap(
          formType: FormType.fourPoint,
          fields: [
            const PdfFieldDefinition(
              key: 'roof_photo_field',
              type: PdfFieldType.image,
              sourceKey: 'roof_photo',
            ),
          ],
        );
        final templateBundle = PdfTemplateBundle(
          manifestEntry: PdfManifestEntry(
            formType: FormType.fourPoint,
            version: '1.0',
            templateAssetPath: 'assets/test.pdf',
            fieldMapAssetPath: 'assets/map.json',
          ),
          fieldMap: fieldMap,
          templateBytes: Uint8List.fromList([1, 2, 3]),
        );
        when(() => mockTemplateLoader.load(FormType.fourPoint))
            .thenAnswer((_) async => templateBundle);

        final resolved = ResolvedPdfFieldData(
          imageByFieldKey: {},
          textByFieldKey: {},
          unresolvedMediaByFieldKey: {'roof_photo_field': 'File not found'},
        );
        when(() => mockMediaResolver.resolve(
          input: any(named: 'input'),
          fieldMap: any(named: 'fieldMap'),
        )).thenAnswer((_) async => resolved);

        expect(
          () => service.generate(input),
          throwsA(isA<PdfGenerationException>()),
        );
      });

      test('should handle template asset loading errors', () async {
        final input = _buildInput(enabledForms: {FormType.fourPoint});

        final budget = PdfSizeBudget(
          maxBytes: 10 * 1024 * 1024,
          retrySteps: [PdfRetryStep(photoBudget: 1.0, imageQuality: 90)],
        );
        when(() => mockBudgetStore.load()).thenReturn(budget);

        when(() => mockTemplateLoader.load(FormType.fourPoint))
            .thenThrow(FileSystemException('Template not found'));

        expect(
          () => service.generate(input),
          throwsA(isA<FileSystemException>()),
        );
      });

      test('should handle media resolution failures', () async {
        final input = _buildInput(enabledForms: {FormType.fourPoint});

        final budget = PdfSizeBudget(
          maxBytes: 10 * 1024 * 1024,
          retrySteps: [PdfRetryStep(photoBudget: 1.0, imageQuality: 90)],
        );
        when(() => mockBudgetStore.load()).thenReturn(budget);

        final templateBundle = PdfTemplateBundle(
          manifestEntry: PdfManifestEntry(
            formType: FormType.fourPoint,
            version: '1.0',
            templateAssetPath: 'assets/test.pdf',
            fieldMapAssetPath: 'assets/map.json',
          ),
          fieldMap: PdfFieldMap(formType: FormType.fourPoint, fields: []),
          templateBytes: Uint8List.fromList([1, 2, 3]),
        );
        when(() => mockTemplateLoader.load(FormType.fourPoint))
            .thenAnswer((_) async => templateBundle);

        when(() => mockMediaResolver.resolve(
          input: any(named: 'input'),
          fieldMap: any(named: 'fieldMap'),
        )).thenThrow(FileSystemException('Media not found'));

        expect(
          () => service.generate(input),
          throwsA(isA<FileSystemException>()),
        );
      });
    });

    group('constructor', () {
      test('should use default dependencies when none provided', () {
        final defaultService = OnDevicePdfService();

        expect(defaultService, isNotNull);
      });
    });
  });
}

PdfGenerationInput _buildInput({
  Set<FormType>? enabledForms,
  Map<String, bool>? wizardCompletion,
}) {
  return PdfGenerationInput(
    inspectionId: 'test-inspection-123',
    organizationId: 'org-123',
    userId: 'user-123',
    clientName: 'Test Client',
    propertyAddress: '123 Test Street',
    enabledForms: enabledForms ?? {FormType.fourPoint},
    capturedCategories: {},
    evidenceMediaPaths: {},
    wizardCompletion: wizardCompletion ?? {},
    wizardBranchContext: {},
  );
}
