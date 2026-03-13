# inspectobot

InspectoBot is a local-first Flutter app for Florida insurance inspections. The current codebase supports 7 form types across dual PDF pipelines:

- Fillable overlay PDFs: 4-Point, Roof Condition, Wind Mitigation, WDO, Sinkhole
- Narrative PDFs: Mold Assessment, General Inspection

## Current Feature Surface

- Supabase-backed auth with tenant membership resolution
- Dashboard for starting and resuming in-progress inspections
- Inspector identity profile and signature capture
- Guided multi-step inspection wizard with cross-form evidence sharing
- Camera/document evidence capture with local manifests and pending sync queue
- On-device PDF generation plus a cloud-PDF backend contract
- Report artifact persistence, signed download links, secure share, and audit trail
- Offline-first inspection persistence with sync outbox and retry scheduling

## Quick Start

```powershell
flutter pub get
flutter analyze
flutter test
flutter test integration_test
flutter run --dart-define-from-file=.env
```

## Runtime Notes

- Remote paths require `SUPABASE_URL` and `SUPABASE_ANON_KEY` via `--dart-define-from-file=.env`.
- Without Supabase configuration, several repositories fall back to in-memory or local-only behavior for development and tests. That is useful for local iteration, but it does not prove remote operational readiness.
- The cloud PDF branch expects a deployed Supabase Edge Function named `generate-report-pdf` when that path is enabled.

## Repository Layout

- `lib/app/`: app bootstrap, router, service locator
- `lib/features/`: feature modules for auth, identity, inspection, media, PDF, sync, delivery, audit, retention
- `assets/pdf/`: pinned fillable PDF templates and field maps
- `supabase/migrations/`: database, storage, and RLS contracts
- `docs/operational-readiness/`: current operational review artifacts and findings

## Operational Review

The current functional readiness review artifacts live under `docs/operational-readiness/` and include:

- the review matrix
- the March 12, 2026 findings report
- the integration smoke harness added under `integration_test/`
