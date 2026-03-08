# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

InspectoBot is a Flutter app for Florida insurance inspections supporting 7 form types: 4-Point, Roof Condition, Wind Mitigation, WDO, Sinkhole, Mold Assessment, and General Home Inspection. The app is local-first with dual PDF pipelines (fillable PDF overlays for 5 forms, narrative reports for 2 forms), cross-form evidence sharing, a unified property data schema, and media sync queuing.

## Build & Run Commands

```bash
flutter pub get                    # Install dependencies
flutter test                       # Run all tests
flutter test test/path/to_test.dart  # Run a single test file
flutter analyze                    # Static analysis (linting)
flutter run --dart-define-from-file=.env  # Run with Supabase env vars
```

Environment variables (`SUPABASE_URL`, `SUPABASE_ANON_KEY`) are required at runtime via `--dart-define-from-file=.env`.

## Architecture

### Pattern: Feature-based Clean Architecture (no external state management)

```
lib/
  app/          # App shell, GoRouter config, GetIt DI setup, Supabase bootstrap
  features/     # Feature modules, each with data/ domain/ presentation/ layers
  common/       # Shared widgets (~22 reusable components) and utils
  theme/        # Material 3 dark-only design system with ThemeExtension tokens
  data/         # Supabase client provider
```

### State Management
No Bloc/Provider/Riverpod. Uses **pure Dart controllers + ChangeNotifier**:
- `AuthNotifier` (ChangeNotifier) drives GoRouter's `refreshListenable`
- `InspectionSessionController` is a plain Dart class; parent StatefulWidget calls `setState()` on mutations

### Dependency Injection
**GetIt** service locator configured in `app/service_locator.dart`. Single setup call in `main()` before `runApp()`.

### Routing
**GoRouter** with auth redirect guards in `app/router_config.dart`. Two-tab shell (`/dashboard`, `/inspector-identity`) with full-screen inspection flows. Deep-link support via `inspectobot://` scheme.

### Key Feature Modules

| Module | Purpose |
|--------|---------|
| `auth/` | Email/password auth via Supabase, tenant context resolution |
| `inspection/` | Draft creation, multi-form wizard (7 types), evidence requirements, cross-form evidence sharing via `EvidenceSharingMatrix`, unified `PropertyData` model |
| `media/` | Camera capture, JPEG compression, local manifest, sync queue |
| `pdf/` | `PdfOrchestrator` routes forms to fillable overlay (`OnDevicePdfService`) or narrative (`NarrativeReportEngine`) pipeline; cloud fallback stub |
| `sync/` | `SyncScheduler` drains `SyncOutboxStore` on connectivity/app resume; retry with backoff |
| `identity/` | Inspector profile, signature capture |
| `delivery/` | Report artifacts, native share sheet |

### App Initialization Order (main.dart)
1. `bootstrapSupabase()` — reads env vars, initializes Supabase SDK
2. `setupServiceLocator()` — registers singletons in GetIt
3. `SyncScheduler.instance.start()` — non-blocking, fire-and-forget
4. `runApp(InspectoBotApp())`

## Conventions

- **No code generation** — no build_runner, freezed, or json_serializable. All serialization is manual `toJson()`/`fromJson()`.
- **Testing** — uses `mocktail` for mocking, fake gateway pattern for repositories. Tests mirror `lib/` structure under `test/`.
- **Theme access** — use `context.appTokens` extension for spacing/radii/elevation tokens from `AppTokens` ThemeExtension. Never hardcode colors; use `Palette` constants via theme.
- **Dark theme only** — Material 3 dark theme, primary orange (#F28C38). No light mode.
- **Form types** — `FormType` enum: `fourPoint` (Insp4pt 03-25), `roofCondition` (RCF-1 03-25), `windMitigation` (OIR-B1-1802 Rev 04/26), `wdo` (FDACS-13645), `sinkholeInspection` (Citizens Sinkhole), `moldAssessment` (Ch. 468 Part XVI — narrative), `generalInspection` (Rule 61-30.801 — narrative). Fillable PDF forms use JSON field maps in `assets/pdf/maps/`; narrative forms use `NarrativeTemplate` subclasses.
- **Local persistence** — JSON files in app documents: `media_manifests/{inspectionId}.json`, `sync_queue/pending_media_sync.json`.
- **Commit style** — Conventional Commits: `feat:`, `fix:`, `refactor:`, `test:`, `docs:`.
