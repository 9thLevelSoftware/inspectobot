# External Integrations

**Analysis Date:** 2026-03-04

## APIs & External Services

**PDF Generation Services:**
- On-device PDF service (active) - generates reports locally with no network call in `lib/features/pdf/on_device_pdf_service.dart`.
  - SDK/Client: `pdf` package from `pubspec.yaml`.
  - Auth: Not applicable (local generation only).
- Cloud PDF fallback (scaffold only) - placeholder returns `null` in `lib/features/pdf/cloud_pdf_service.dart`.
  - SDK/Client: Not detected in current code (`lib/features/pdf/cloud_pdf_service.dart`).
  - Auth: Not detected.

**Planned but Not Wired:**
- Supabase auth/storage/sync is documented as pending in `README.md` and architecture notes in `docs/design.md`/`docs/blueprint.md`; no active Supabase SDK integration exists under `lib/`.
  - SDK/Client: Not detected in `pubspec.yaml` and `lib/` imports.
  - Auth: Not detected.

## Data Storage

**Databases:**
- None detected (no SQLite/ORM/remote DB package declared in `pubspec.yaml`, no database client usage in `lib/`).
  - Connection: Not applicable.
  - Client: Not applicable.

**File Storage:**
- Local filesystem only using `path_provider` document/temp directories:
  - media manifests in `lib/features/media/local_media_store.dart` (`media_manifests/<inspectionId>.json`)
  - sync queue in `lib/features/media/pending_media_sync_store.dart` (`sync_queue/pending_media_sync.json`)
  - generated PDFs in `lib/features/pdf/on_device_pdf_service.dart` (temporary directory files)

**Caching:**
- None detected (no explicit cache service/package in `pubspec.yaml` or `lib/`).

## Authentication & Identity

**Auth Provider:**
- Custom/none at current implementation stage.
  - Implementation: No sign-in SDK or auth flow code found in `lib/`; README explicitly marks Supabase auth as not wired in `README.md`.

## Monitoring & Observability

**Error Tracking:**
- None detected (no Sentry/Crashlytics/New Relic dependencies in `pubspec.yaml`).

**Logs:**
- No centralized logging integration detected; behavior is local exception propagation in service logic like `lib/features/pdf/pdf_orchestrator.dart`.

## CI/CD & Deployment

**Hosting:**
- Not applicable for backend hosting in current codebase (mobile client only in `android/` and `ios/`).

**CI Pipeline:**
- None detected (`.github/workflows/` not present under `C:/Users/dasbl/AndroidStudioProjects/InspectoBot`).

## Environment Configuration

**Required env vars:**
- No runtime API secrets/env vars detected in app code (`lib/`).
- Local development machine paths required in `android/local.properties` (`flutter.sdk`, `sdk.dir`).

**Secrets location:**
- Not applicable for current implementation (no API keys/secrets configured in tracked source files).

## Webhooks & Callbacks

**Incoming:**
- None detected (no webhook endpoints/server code in `lib/`, `android/`, or `ios/`).

**Outgoing:**
- None detected (no HTTP client calls in active app services under `lib/features/`).

---

*Integration audit: 2026-03-04*
