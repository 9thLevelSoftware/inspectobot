# Architecture

**Analysis Date:** 2026-03-04

## Pattern Overview

**Overall:** Feature-first Flutter client with local-file persistence and UI-level orchestration.

**Key Characteristics:**
- UI screens in `lib/features/inspection/presentation/` directly orchestrate services from `lib/features/media/` and `lib/features/pdf/`.
- Domain rules and enums are isolated in `lib/features/inspection/domain/` and imported by presentation and service layers.
- Persistence is device-local JSON and files via `path_provider` in `lib/features/media/local_media_store.dart` and `lib/features/media/pending_media_sync_store.dart`.

## Layers

**Application Bootstrap Layer:**
- Purpose: Start Flutter runtime and compose top-level app shell.
- Location: `lib/main.dart`, `lib/app/app.dart`, `lib/app/routes.dart`
- Contains: `main()` entrypoint, `MaterialApp`, initial route constants.
- Depends on: Flutter framework and the initial inspection screen in `lib/features/inspection/presentation/dashboard_page.dart`.
- Used by: Platform runners from `android/` and `ios/`.

**Presentation Layer:**
- Purpose: Render screens, collect form input, trigger capture and PDF actions.
- Location: `lib/features/inspection/presentation/`
- Contains: `DashboardPage` in `lib/features/inspection/presentation/dashboard_page.dart`, `NewInspectionPage` in `lib/features/inspection/presentation/new_inspection_page.dart`, `FormChecklistPage` in `lib/features/inspection/presentation/form_checklist_page.dart`.
- Depends on: Domain models from `lib/features/inspection/domain/`, media services from `lib/features/media/`, and PDF services from `lib/features/pdf/`.
- Used by: App shell route map in `lib/app/app.dart` and in-flow `Navigator` transitions between pages.

**Domain Layer:**
- Purpose: Define inspection form types, required category rules, and in-memory draft state.
- Location: `lib/features/inspection/domain/`
- Contains: Enums in `lib/features/inspection/domain/form_type.dart` and `lib/features/inspection/domain/required_photo_category.dart`, requirement map in `lib/features/inspection/domain/form_requirements.dart`, draft model in `lib/features/inspection/domain/inspection_draft.dart`.
- Depends on: Core Dart types only.
- Used by: Presentation screens, media queue model in `lib/features/media/media_sync_task.dart`, and PDF input in `lib/features/pdf/pdf_generation_input.dart`.

**Media Capture and Local Persistence Layer:**
- Purpose: Capture camera photos, compress images, store manifests, and queue pending sync tasks.
- Location: `lib/features/media/`
- Contains: Capture orchestration in `lib/features/media/media_capture_service.dart`, local manifest store in `lib/features/media/local_media_store.dart`, queue store in `lib/features/media/pending_media_sync_store.dart`, queue entity in `lib/features/media/media_sync_task.dart`.
- Depends on: `image_picker`, `flutter_image_compress`, `path_provider`, and domain category enums.
- Used by: `FormChecklistPage` in `lib/features/inspection/presentation/form_checklist_page.dart`.

**PDF Generation Layer:**
- Purpose: Build inspection PDF locally and provide fallback strategy abstraction.
- Location: `lib/features/pdf/`
- Contains: Strategy enum in `lib/features/pdf/pdf_strategy.dart`, orchestrator in `lib/features/pdf/pdf_orchestrator.dart`, local generator in `lib/features/pdf/on_device_pdf_service.dart`, cloud placeholder in `lib/features/pdf/cloud_pdf_service.dart`, DTO in `lib/features/pdf/pdf_generation_input.dart`.
- Depends on: `pdf`, `path_provider`, and inspection domain enums.
- Used by: `FormChecklistPage` in `lib/features/inspection/presentation/form_checklist_page.dart`.

## Data Flow

**Inspection Creation to PDF Flow:**

1. App starts at `lib/main.dart`, builds `InspectoBotApp` in `lib/app/app.dart`, and loads `DashboardPage` from `lib/features/inspection/presentation/dashboard_page.dart`.
2. User creates draft details in `lib/features/inspection/presentation/new_inspection_page.dart`, which instantiates `InspectionDraft` from `lib/features/inspection/domain/inspection_draft.dart`.
3. Checklist requirements are computed by `FormRequirements.forForms` in `lib/features/inspection/domain/form_requirements.dart`, then rendered in `lib/features/inspection/presentation/form_checklist_page.dart`.
4. Photo capture action calls `MediaCaptureService.captureRequiredPhoto` in `lib/features/media/media_capture_service.dart`, which writes JPEG files, saves manifest entries via `lib/features/media/local_media_store.dart`, and enqueues sync tasks via `lib/features/media/pending_media_sync_store.dart`.
5. PDF generation action builds `PdfGenerationInput` in `lib/features/pdf/pdf_generation_input.dart`, then calls `PdfOrchestrator.generate` in `lib/features/pdf/pdf_orchestrator.dart` to try on-device generation (`lib/features/pdf/on_device_pdf_service.dart`) with cloud fallback (`lib/features/pdf/cloud_pdf_service.dart`).

**State Management:**
- Use local widget state (`StatefulWidget`) in `lib/features/inspection/presentation/new_inspection_page.dart` and `lib/features/inspection/presentation/form_checklist_page.dart`.
- Keep mutable draft state on `InspectionDraft` sets/maps in `lib/features/inspection/domain/inspection_draft.dart`.
- Persist captured artifacts to filesystem JSON/files through `lib/features/media/local_media_store.dart` and `lib/features/media/pending_media_sync_store.dart`.

## Key Abstractions

**InspectionDraft:**
- Purpose: Hold active inspection identity and captured-progress state while navigating screens.
- Examples: `lib/features/inspection/domain/inspection_draft.dart`, consumed by `lib/features/inspection/presentation/new_inspection_page.dart` and `lib/features/inspection/presentation/form_checklist_page.dart`.
- Pattern: Mutable in-memory aggregate passed through constructor navigation.

**FormRequirements Rule Map:**
- Purpose: Convert enabled form set into merged required photo categories.
- Examples: `lib/features/inspection/domain/form_requirements.dart`, applied in `lib/features/inspection/presentation/form_checklist_page.dart`.
- Pattern: Static rule table + pure merge function.

**MediaCaptureService:**
- Purpose: Encapsulate camera pick, compression, write, manifest update, and sync queue enqueue.
- Examples: `lib/features/media/media_capture_service.dart`.
- Pattern: Service object with injectable function dependencies (`PickPhoto`, `CompressPhoto`, `WriteCapture`) for testability.

**PdfOrchestrator:**
- Purpose: Enforce primary strategy and fallback sequence for report generation.
- Examples: `lib/features/pdf/pdf_orchestrator.dart` with providers in `lib/features/pdf/on_device_pdf_service.dart` and `lib/features/pdf/cloud_pdf_service.dart`.
- Pattern: Strategy selection plus failover orchestration.

## Entry Points

**Flutter Runtime Entrypoint:**
- Location: `lib/main.dart`
- Triggers: Native launch from `android/` and `ios/` runners.
- Responsibilities: Call `runApp(const InspectoBotApp())`.

**App Composition Entrypoint:**
- Location: `lib/app/app.dart`
- Triggers: Called by `main()` in `lib/main.dart`.
- Responsibilities: Build theme, initial route, and route table.

**Primary User Flow Entrypoints:**
- Location: `lib/features/inspection/presentation/dashboard_page.dart` and `lib/features/inspection/presentation/new_inspection_page.dart`
- Triggers: User taps "New Inspection" then "Continue to Required Photos".
- Responsibilities: Navigate into the inspection flow and create `InspectionDraft` for downstream steps.

## Error Handling

**Strategy:** Guard clauses for invalid or canceled operations plus localized `try/catch` around async PDF generation.

**Patterns:**
- Return `null` for canceled/invalid capture in `lib/features/media/media_capture_service.dart` and short-circuit UI updates in `lib/features/inspection/presentation/form_checklist_page.dart`.
- Wrap PDF generation in `try/catch/finally` and show feedback via `SnackBar` in `lib/features/inspection/presentation/form_checklist_page.dart`.
- Fallback from on-device to cloud in `lib/features/pdf/pdf_orchestrator.dart`; cloud currently returns `null` in `lib/features/pdf/cloud_pdf_service.dart`.

## Cross-Cutting Concerns

**Logging:** Not detected in application code under `lib/`; no logger abstraction is present.
**Validation:** Use form validators in `lib/features/inspection/presentation/new_inspection_page.dart` and completion gate checks in `lib/features/inspection/presentation/form_checklist_page.dart`.
**Authentication:** Not implemented in current runtime flow; no auth module exists under `lib/` and no auth client is configured in `pubspec.yaml`.

---

*Architecture analysis: 2026-03-04*
