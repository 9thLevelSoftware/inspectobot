# Codebase Structure

**Analysis Date:** 2026-03-04

## Directory Layout

```text
inspectobot/
├── lib/                  # Flutter application source (app shell + feature modules)
├── test/                 # Widget and feature-level automated tests
├── android/              # Android runner and Gradle build configuration
├── ios/                  # iOS runner and Xcode project configuration
├── docs/                 # Product and design reference documents
├── .planning/codebase/   # Generated codebase mapping documents for GSD workflows
├── pubspec.yaml          # Dart/Flutter dependencies and project metadata
├── analysis_options.yaml # Dart analyzer and lint configuration
└── README.md             # Current milestone summary and local run instructions
```

## Directory Purposes

**lib/app:**
- Purpose: App bootstrap, top-level MaterialApp composition, and route constants.
- Contains: `app.dart`, `routes.dart`.
- Key files: `lib/app/app.dart`, `lib/app/routes.dart`.

**lib/features/inspection:**
- Purpose: Inspection workflow feature and domain rules.
- Contains: `domain/` enums/models and `presentation/` pages.
- Key files: `lib/features/inspection/domain/inspection_draft.dart`, `lib/features/inspection/domain/form_requirements.dart`, `lib/features/inspection/presentation/new_inspection_page.dart`, `lib/features/inspection/presentation/form_checklist_page.dart`.

**lib/features/media:**
- Purpose: Photo capture pipeline and local persistence for captures/sync queue.
- Contains: Services, DTOs, queue model, and JSON-backed stores.
- Key files: `lib/features/media/media_capture_service.dart`, `lib/features/media/local_media_store.dart`, `lib/features/media/pending_media_sync_store.dart`.

**lib/features/pdf:**
- Purpose: Report-generation strategy and PDF output services.
- Contains: Orchestrator, strategy enum, input DTO, on-device generator, cloud placeholder.
- Key files: `lib/features/pdf/pdf_orchestrator.dart`, `lib/features/pdf/on_device_pdf_service.dart`, `lib/features/pdf/cloud_pdf_service.dart`.

**test/features/media:**
- Purpose: Behavior tests for media capture and local stores.
- Contains: Service/store tests using temporary filesystem fixtures.
- Key files: `test/features/media/media_capture_service_test.dart`, `test/features/media/local_media_store_test.dart`, `test/features/media/pending_media_sync_store_test.dart`.

**android and ios:**
- Purpose: Platform runner projects and native app permissions/build settings.
- Contains: Gradle/Xcode project files, app manifests/plists.
- Key files: `android/app/build.gradle.kts`, `ios/Runner/Info.plist`.

## Key File Locations

**Entry Points:**
- `lib/main.dart`: Flutter runtime entrypoint calling `runApp`.
- `lib/app/app.dart`: App composition entrypoint for routes and theme.

**Configuration:**
- `pubspec.yaml`: SDK constraints and package dependencies.
- `analysis_options.yaml`: Lint/analyzer profile (`flutter_lints`).
- `android/app/build.gradle.kts`: Android app module configuration and SDK targets.
- `ios/Runner/Info.plist`: iOS app metadata and camera/photo usage strings.

**Core Logic:**
- `lib/features/inspection/domain/form_requirements.dart`: Required-photo policy per form type.
- `lib/features/media/media_capture_service.dart`: Capture/compress/write/enqueue orchestration.
- `lib/features/pdf/pdf_orchestrator.dart`: On-device and cloud fallback control flow.
- `lib/features/pdf/on_device_pdf_service.dart`: PDF file creation.

**Testing:**
- `test/widget_test.dart`: App-shell smoke assertion.
- `test/features/media/media_capture_service_test.dart`: Capture pipeline tests.
- `test/features/media/local_media_store_test.dart`: Manifest persistence tests.
- `test/features/media/pending_media_sync_store_test.dart`: Sync queue behavior tests.

## Naming Conventions

**Files:**
- Use `snake_case.dart` for source files, for example `form_checklist_page.dart` and `pending_media_sync_store.dart` under `lib/features/`.

**Directories:**
- Use lowercase feature folders under `lib/features/`, for example `lib/features/inspection/`, `lib/features/media/`, `lib/features/pdf/`.
- Split feature internals by responsibility (`domain` and `presentation`) as shown in `lib/features/inspection/domain/` and `lib/features/inspection/presentation/`.

## Where to Add New Code

**New Feature:**
- Primary code: Add under `lib/features/<feature_name>/` with a `presentation/` folder for UI and a dedicated logic folder (`domain/` or service files) matching `lib/features/inspection/` and `lib/features/media/`.
- Tests: Mirror under `test/features/<feature_name>/` with `*_test.dart` files, following `test/features/media/`.

**New Component/Module:**
- Implementation: Put reusable app shell concerns in `lib/app/`; put user-flow screens in `lib/features/<feature_name>/presentation/`; put domain entities/rules in `lib/features/<feature_name>/domain/`.

**Utilities:**
- Shared helpers: Keep feature-local helpers in the feature directory (for example `lib/features/media/`); when helpers are reused across features, create `lib/common/` and import from there.

## Special Directories

**build:**
- Purpose: Flutter build artifacts.
- Generated: Yes.
- Committed: No.

**.dart_tool:**
- Purpose: Dart/Flutter tool state and package metadata cache.
- Generated: Yes.
- Committed: No.

**.planning/codebase:**
- Purpose: GSD mapping documents consumed by planning and execution commands.
- Generated: Yes.
- Committed: Yes.

---

*Structure analysis: 2026-03-04*
