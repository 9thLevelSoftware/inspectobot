# Codebase Concerns

**Analysis Date:** 2026-03-04

## Tech Debt

**Cloud PDF fallback is scaffold-only:**
- Issue: Cloud fallback path is wired in orchestration but the cloud provider method returns `null` for every request.
- Files: `lib/features/pdf/cloud_pdf_service.dart`, `lib/features/pdf/pdf_orchestrator.dart`, `README.md`
- Impact: Any on-device PDF failure has no real fallback, so report generation can fail hard in field use.
- Fix approach: Implement a real cloud client in `lib/features/pdf/cloud_pdf_service.dart` with timeout/retry and typed errors; keep orchestration contract in `lib/features/pdf/pdf_orchestrator.dart`.

**Offline sync queue has no worker/consumer:**
- Issue: Media capture enqueues sync tasks, but no application path reads pending tasks and uploads them.
- Files: `lib/features/media/media_capture_service.dart`, `lib/features/media/pending_media_sync_store.dart`, `README.md`
- Impact: Queue grows without remote sync, so offline-first media never leaves device storage.
- Fix approach: Add a sync runner service that uses `PendingMediaSyncStore.listPending()` and `markUploaded()` plus network/backoff handling.

**PDF input model omits photo payload paths:**
- Issue: PDF generation input only carries captured category names, not file paths.
- Files: `lib/features/pdf/pdf_generation_input.dart`, `lib/features/inspection/presentation/form_checklist_page.dart`, `lib/features/pdf/on_device_pdf_service.dart`
- Impact: Generated reports include text bullets for categories but cannot embed required proof photos.
- Fix approach: Extend `PdfGenerationInput` with category-to-file mappings and consume them in `OnDevicePdfService` layout/render logic.

## Known Bugs

**Captured-photo errors can bubble without user-safe handling in capture flow:**
- Symptoms: If camera/compression/write throws inside capture, the action has no local `try/catch` in `_capture` and the UI path can fail without structured recovery messaging.
- Files: `lib/features/inspection/presentation/form_checklist_page.dart`, `lib/features/media/media_capture_service.dart`
- Trigger: Camera permission denial, image compressor native failure, or file write exception.
- Workaround: Relaunch capture after fixing permission/device state; no in-app retry UX exists.

**Deserialized sync tasks accept invalid empty IDs/paths:**
- Symptoms: Queue items deserialize with empty `taskId`, `inspectionId`, or `filePath` when JSON fields are absent.
- Files: `lib/features/media/media_sync_task.dart`
- Trigger: Corrupt or partially-written `pending_media_sync.json` payload.
- Workaround: Delete malformed queue file under app documents `sync_queue/pending_media_sync.json`.

## Security Considerations

**No app-level auth/identity boundary in runtime flow:**
- Risk: App opens directly to inspection dashboard with no sign-in gate.
- Files: `lib/main.dart`, `lib/app/app.dart`, `lib/app/routes.dart`
- Current mitigation: Not detected.
- Recommendations: Add authenticated entry routing before inspection features and tie inspection ownership to identity.

**Sensitive inspection artifacts are stored unencrypted on local filesystem:**
- Risk: Client/property data, captured photos, and queue metadata are persisted as plain files in app documents storage.
- Files: `lib/features/media/local_media_store.dart`, `lib/features/media/media_capture_service.dart`, `lib/features/media/pending_media_sync_store.dart`
- Current mitigation: Not detected.
- Recommendations: Encrypt at-rest payloads and add secure storage strategy for manifests/queue metadata.

## Performance Bottlenecks

**Queue persistence rewrites entire JSON blob per mutation:**
- Problem: Every enqueue/markUploaded reads then rewrites the full task list.
- Files: `lib/features/media/pending_media_sync_store.dart`
- Cause: `_readAll()` + `_writeAll()` full-file strategy for each operation.
- Improvement path: Move to append/update-friendly local DB (for example SQLite) or chunked storage with indexes.

**Manifest persistence rewrites full file per capture update:**
- Problem: Capture save reads and rewrites entire manifest map each write.
- Files: `lib/features/media/local_media_store.dart`
- Cause: `saveCapture()` serializes complete JSON object every mutation.
- Improvement path: Use transactional local DB table keyed by `inspectionId + category`.

## Fragile Areas

**Enum-name based serialization couples storage to source renames:**
- Files: `lib/features/media/media_sync_task.dart`, `lib/features/inspection/domain/required_photo_category.dart`
- Why fragile: Stored `category` and `status` use enum `.name`; any rename silently breaks parse and drops tasks.
- Safe modification: Keep stable serialized tokens separate from enum symbol names and add migration logic.
- Test coverage: No migration/rename resilience tests in `test/features/media/pending_media_sync_store_test.dart`.

**Timestamp-based identifiers are collision-prone under rapid writes:**
- Files: `lib/features/inspection/domain/inspection_draft.dart`, `lib/features/media/media_capture_service.dart`, `lib/features/pdf/on_device_pdf_service.dart`
- Why fragile: IDs and filenames rely on `DateTime.now().millisecondsSinceEpoch`; concurrent actions in the same millisecond can collide.
- Safe modification: Replace with UUID generation and preserve deterministic naming only for display.
- Test coverage: No collision tests in `test/features/media/media_capture_service_test.dart`.

## Scaling Limits

**Pending sync queue has unbounded growth and no pruning policy:**
- Current capacity: Single JSON file stores all pending tasks.
- Limit: File size and full rewrite cost increase with queued captures.
- Scaling path: Add bounded retry policy, archival/pruning, and segmented storage.

**Generated media/report artifacts have no lifecycle cleanup:**
- Current capacity: Captures and temporary PDFs persist until OS/app cleanup behavior.
- Limit: Long-running usage accumulates local storage and slows file operations.
- Scaling path: Add retention/cleanup jobs for stale captures, completed queue items, and old generated PDFs.

## Dependencies at Risk

**Platform plugin chain for camera/compression is failure-sensitive:**
- Risk: `image_picker` and `flutter_image_compress` depend on platform permissions and native codecs.
- Impact: Capture pipeline returns `null` or throws, blocking required-photo completion.
- Migration plan: Abstract capture/compression adapters behind interfaces and add fallback quality/size strategy.

## Missing Critical Features

**No backend integration for auth/storage/sync pipeline:**
- Problem: Core app flow stores local state only; no remote identity, upload, or cross-device persistence path exists.
- Blocks: Production multi-user workflow, centralized auditability, and durable report/media delivery.

**No signature workflow for inspection completion:**
- Problem: Inspection flow lacks inspector/client signature collection and persistence.
- Blocks: Compliance-driven completion flow and signed report lifecycle.

## Test Coverage Gaps

**PDF generation paths are untested:**
- What's not tested: `PdfOrchestrator` fallback behavior and `OnDevicePdfService` output contract.
- Files: `lib/features/pdf/pdf_orchestrator.dart`, `lib/features/pdf/on_device_pdf_service.dart`, `lib/features/pdf/cloud_pdf_service.dart`
- Risk: Runtime failures and silent regressions in report generation.
- Priority: High

**Inspection presentation flow is minimally tested:**
- What's not tested: New inspection form validation branches, required-photo completion gate transitions, and capture/PDF error UX.
- Files: `lib/features/inspection/presentation/new_inspection_page.dart`, `lib/features/inspection/presentation/form_checklist_page.dart`, `test/widget_test.dart`
- Risk: Broken user journey without automated detection.
- Priority: High

**Domain constraints are untested:**
- What's not tested: `FormRequirements.forForms` mapping correctness and form/category coverage rules.
- Files: `lib/features/inspection/domain/form_requirements.dart`, `lib/features/inspection/domain/form_type.dart`, `lib/features/inspection/domain/required_photo_category.dart`
- Risk: Compliance rules drift or mismatch without failing tests.
- Priority: Medium

---

*Concerns audit: 2026-03-04*
