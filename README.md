# inspectobot

InspectoBot is a Flutter app for Florida insurance inspections (4-Point, Roof Condition, and Wind Mitigation).

## Current Milestone (Phase 1.6 Sync Queue Scaffold)

Implemented in this repository:

- Dashboard with `New Inspection` entrypoint
- Inspection setup with required fields and multi-form selection
- Required-photo compliance checklist with hard gate before PDF generation
- Real camera capture + JPEG compression pipeline for required photos
- Local media manifest persistence per inspection (`media_manifests/<inspectionId>.json`)
- Local pending media sync queue (`sync_queue/pending_media_sync.json`)
- Hybrid PDF orchestration (`on-device` primary, cloud fallback interface)
- On-device PDF generation to a temporary file path

## Project Structure (implemented)

- `lib/app/` app shell and routing
- `lib/features/inspection/` domain + presentation for inspection flow
- `lib/features/media/` capture service, local manifest store, and pending sync queue store
- `lib/features/pdf/` PDF strategy/orchestrator and on-device generation

## Quick Start

```powershell
flutter pub get
flutter test
flutter run
```

## Notes

- Cloud PDF fallback service is scaffolded and returns `null` until API integration is added.
- Supabase uploader/auth are not wired yet; pending media queue is local-only for now.
- Next milestone should wire Supabase auth/storage/RLS and consume pending queue for remote sync.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
