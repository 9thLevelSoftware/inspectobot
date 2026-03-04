# Coding Conventions

**Analysis Date:** 2026-03-04

## Naming Patterns

**Files:**
- Use `snake_case.dart` for all Dart files in feature folders, such as `lib/features/media/media_capture_service.dart` and `lib/features/inspection/presentation/form_checklist_page.dart`.
- Suffix service/store/value files with role-based nouns (`*_service.dart`, `*_store.dart`, `*_input.dart`, `*_task.dart`) as shown in `lib/features/pdf/on_device_pdf_service.dart`, `lib/features/media/local_media_store.dart`, and `lib/features/pdf/pdf_generation_input.dart`.

**Functions:**
- Use `lowerCamelCase` for methods and top-level functions (`captureRequiredPhoto`, `markUploaded`, `main`) in `lib/features/media/media_capture_service.dart` and `lib/main.dart`.
- Prefix private members with `_` in state classes and services (`_continue`, `_generatePdf`, `_readAll`, `_writeAll`) in `lib/features/inspection/presentation/new_inspection_page.dart` and `lib/features/media/pending_media_sync_store.dart`.

**Variables:**
- Use `lowerCamelCase` for locals and fields (`pickedPath`, `pendingStore`, `primaryStrategy`) in `lib/features/media/media_capture_service.dart` and `test/features/media/media_capture_service_test.dart`.
- Prefix widget-private state fields with `_` in `State` subclasses (`_formKey`, `_selectedForms`, `_isGenerating`) in `lib/features/inspection/presentation/new_inspection_page.dart` and `lib/features/inspection/presentation/form_checklist_page.dart`.

**Types:**
- Use `UpperCamelCase` for classes and enums (`InspectoBotApp`, `MediaSyncTask`, `RequiredPhotoCategory`) in `lib/app/app.dart`, `lib/features/media/media_sync_task.dart`, and `lib/features/inspection/domain/required_photo_category.dart`.
- Keep enum values in `lowerCamelCase` (`cloudFallback`, `windOpeningProtection`) in `lib/features/pdf/pdf_strategy.dart` and `lib/features/inspection/domain/required_photo_category.dart`.

## Code Style

**Formatting:**
- Tool used: Dart formatter via Flutter tooling conventions.
- Formatting follows 2-space indentation and trailing commas for multiline argument lists, seen in `lib/features/inspection/presentation/form_checklist_page.dart` and `lib/features/media/media_capture_service.dart`.

**Linting:**
- Tool used: `flutter_lints` via `analysis_options.yaml`.
- Config includes `package:flutter_lints/flutter.yaml` in `analysis_options.yaml`; no custom overrides are enabled, so default Flutter lint rules apply.

## Import Organization

**Order:**
1. Dart SDK imports first (`import 'dart:io';`) in `lib/features/pdf/on_device_pdf_service.dart` and `lib/features/media/local_media_store.dart`.
2. Package imports second (`package:flutter/...`, `package:path_provider/...`) in `lib/app/app.dart` and `lib/features/media/media_capture_service.dart`.
3. Relative project imports last (`../...` or `./...`) in `lib/features/media/media_capture_service.dart` and `lib/features/inspection/presentation/form_checklist_page.dart`.

**Path Aliases:**
- `package:inspectobot/...` is used for cross-feature imports in UI layers and tests, such as `lib/features/inspection/presentation/new_inspection_page.dart` and `test/widget_test.dart`.
- Relative imports are used for nearby files inside the same feature module, such as `lib/features/pdf/pdf_orchestrator.dart` and `lib/features/media/pending_media_sync_store.dart`.

## Error Handling

**Patterns:**
- Prefer early returns for invalid/null data (`if (pickedPath == null) return null;`) in `lib/features/media/media_capture_service.dart`.
- Use defensive parsing with type guards and fallbacks for persisted JSON in `lib/features/media/local_media_store.dart` and `lib/features/media/media_sync_task.dart`.
- Catch exceptions at orchestration/UI boundaries, then surface fallback behavior or user messages in `lib/features/pdf/pdf_orchestrator.dart` and `lib/features/inspection/presentation/form_checklist_page.dart`.

## Logging

**Framework:** None detected (`console`, `print`, and `debugPrint` are not used in `lib/**/*.dart`).

**Patterns:**
- User-visible runtime feedback uses `ScaffoldMessenger` snack bars in `lib/features/inspection/presentation/new_inspection_page.dart` and `lib/features/inspection/presentation/form_checklist_page.dart`.
- Internal failures are propagated with `throw`/`rethrow` semantics instead of logging in `lib/features/pdf/pdf_orchestrator.dart`.

## Comments

**When to Comment:**
- Keep comments sparse; include only high-level placeholders for not-yet-implemented logic, as in `lib/features/pdf/cloud_pdf_service.dart`.
- Avoid inline explanatory comments in straightforward domain, service, and UI code (`lib/features/inspection/domain/*.dart`, `lib/features/media/*.dart`).

**JSDoc/TSDoc:**
- Not applicable in Dart code.
- Dartdoc-style API comments are not currently used in `lib/**/*.dart`.

## Function Design

**Size:**
- Keep domain/store methods small and single-purpose (`forForms`, `markUploaded`, `_queueFile`) in `lib/features/inspection/domain/form_requirements.dart` and `lib/features/media/pending_media_sync_store.dart`.
- Allow larger UI event handlers when coordinating several operations (`_generatePdf`) in `lib/features/inspection/presentation/form_checklist_page.dart`.

**Parameters:**
- Prefer named parameters with `required` for clarity (`captureRequiredPhoto`, `MediaSyncTask` constructor, `PdfGenerationInput` constructor) in `lib/features/media/media_capture_service.dart`, `lib/features/media/media_sync_task.dart`, and `lib/features/pdf/pdf_generation_input.dart`.

**Return Values:**
- Return nullable values to represent optional outcomes (`Future<MediaCaptureResult?>`, `Future<File?>`) in `lib/features/media/media_capture_service.dart` and `lib/features/pdf/cloud_pdf_service.dart`.
- Use immutable collections on returns where applicable (`toList(growable: false)`) in `lib/features/inspection/domain/form_requirements.dart` and `lib/features/media/pending_media_sync_store.dart`.

## Module Design

**Exports:**
- Direct file imports are used; barrel exports are not present in `lib/**/*.dart`.

**Barrel Files:**
- Not used. Import concrete files directly, for example `lib/features/inspection/presentation/form_checklist_page.dart` importing `lib/features/pdf/pdf_orchestrator.dart` and related dependencies.

---

*Convention analysis: 2026-03-04*
