# InspectoBot — Codebase Map

## Overview
- **Framework**: Flutter (Dart)
- **Production files**: 109 (.dart) in lib/
- **Test files**: 81 (.dart) in test/
- **Assets**: 7 (PDF templates + field maps)
- **Dependencies**: 17 packages (no code generation)
- **State Management**: Pure Dart controllers + ChangeNotifier (no Bloc/Provider/Riverpod)
- **Navigation**: GoRouter with auth guards + deep linking
- **Backend**: Supabase (auth, database, storage)
- **Theme**: Material 3 dark-only, custom ThemeExtension tokens, primary orange (#F28C38)

## Architecture
Feature-based clean architecture: `lib/features/<name>/{data,domain,presentation}/`
- **DI**: GetIt service locator (`app/service_locator.dart`)
- **Serialization**: Manual toJson/fromJson (no freezed/json_serializable)
- **App Shell**: 2-tab bottom nav (Dashboard, Inspector Identity) + full-screen inspection flows

## Structure

```
lib/
  app/          # App shell, GoRouter config, GetIt DI, Supabase bootstrap (8 files)
  common/       # 22 reusable widgets + utilities (23 files)
  theme/        # Design tokens, palette, typography, extensions (6 files, 1060 LOC)
  data/         # Supabase client provider (1 file)
  features/
    inspection/ # Core wizard, form logic, session controller (19 files)
    auth/       # Email/password + tenant resolution (11 files)
    pdf/        # Hybrid on-device + cloud fallback generation (10 files)
    media/      # Camera capture, JPEG compression, sync queue (6 files)
    delivery/   # Report artifacts + native share sheet (5 files)
    identity/   # Inspector profile + signature management (4 files)
    sync/       # SyncScheduler + outbox + connectivity runner (4 files)
    audit/      # Event logging (2 files)
    retention/  # Policy engine (2 files)
    signing/    # Signature evidence + hashing (2 files)
    storage/    # Path contract utilities (1 file)
```

## Key Domain Models
- `FormType` enum: fourPoint, roofCondition, windMitigation (3 values)
- `InspectionDraft`: client info, property info, enabledForms, wizardSnapshot, captured media paths
- `FormRequirements`: 50+ evidence rules with branch predicates per form type
- `WizardProgressSnapshot`: linear wizard state with completion map + branch context
- `EvidenceRequirement`: mandatory evidence per form (photo | document) with conditional logic
- `InspectorProfile` + `SignatureRecord`: license info + non-repudiation hashing

## Subsystem Maturity

### PDF Pipeline (HIGH)
- Template-based: `assets/pdf/templates/{formType}.pdf`
- Field maps: JSON-driven (`assets/pdf/maps/{formType}.v1.json`)
- PdfOrchestrator: on-device primary, cloud fallback
- Size budget retry loop (10MB default, 3 compression levels)
- **Adding new forms**: add template + map to assets + FormType enum value + requirements

### Sync Infrastructure (MODERATE)
- SyncScheduler: singleton, app lifecycle + connectivity aware
- SyncOutboxStore: file-based queue (`sync_queue/sync_outbox.json`)
- PendingMediaSyncStore: separate media queue
- MediaSyncRemoteStore: Supabase storage uploads
- **Gaps**: no exponential backoff, no dead-letter queue, no transactional sync

### Media Capture (MODERATE)
- ImagePicker-based (no live viewfinder)
- JPEG compression via flutter_image_compress
- Local manifest per inspection (`media_manifests/{inspectionId}.json`)
- **Gaps**: no audio capture, no video, photos only

### Common Widgets (22 components)
- Inputs: text field, checkbox tile, date picker, dropdown
- Display: button, completion chip, status badge, status card, error banner, empty state
- Layout: section card, section group, section header, reach zone scaffold, progress bar
- Specialized: form type card, inspection card, wizard progress indicator, loading overlay, signature pad

## Docs Folder (Ground Truth for AI Super App)
- 13 PDFs: 4-Point samples (5), roof condition (2), sinkhole (1), residential manual (1), contracts/misc (4)
- 3 Office docs: HUDreport.doc, fullinspection.doc, 4point50.doc
- 1 spreadsheet, 4 images, 1 HTML guide
- blueprint.md: wireframes, schema, architecture notes

## Risk Areas for AI Expansion
1. No audio/video capture infrastructure (entire AI capture HUD is net-new)
2. Manual serialization scales poorly to 7+ form types with unified schema
3. Sync not transactional (partial syncs possible)
4. Cloud PDF service stubbed (not production-ready)
5. No conflict resolution (last-write-wins)
6. Signature hashing only (no cryptographic signing)
7. No LLM/AI integration infrastructure exists

---
*Updated: 2026-03-07 via codebase-mapper*
