# Testing Patterns

**Analysis Date:** 2026-03-04

## Test Framework

**Runner:**
- Flutter test runner (`flutter_test`) via SDK dependency in `pubspec.yaml`.
- Config: Not detected (`jest.config.*`, `vitest.config.*`, and custom Flutter test config files are not present at project root).

**Assertion Library:**
- `package:flutter_test/flutter_test.dart` matchers (`expect`, `isNull`, `isEmpty`, `findsOneWidget`) in `test/features/media/media_capture_service_test.dart` and `test/widget_test.dart`.

**Run Commands:**
```bash
flutter test                 # Run all tests
flutter test --watch         # Watch mode
flutter test --coverage      # Coverage
```

## Test File Organization

**Location:**
- Tests live in a dedicated top-level `test/` tree mirroring production feature structure, for example `test/features/media/` matching `lib/features/media/`.

**Naming:**
- Use `*_test.dart` suffix for all tests, including `test/features/media/local_media_store_test.dart` and `test/widget_test.dart`.

**Structure:**
```text
test/
  widget_test.dart
  features/
    media/
      local_media_store_test.dart
      media_capture_service_test.dart
      pending_media_sync_store_test.dart
```

## Test Structure

**Suite Organization:**
```dart
void main() {
  test('describes behavior', () async {
    final tempRoot = await Directory.systemTemp.createTemp('inspectobot_case_');
    addTearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    // Arrange
    // Act
    // Assert
    expect(result, isNotNull);
  });
}
```
Pattern source: `test/features/media/media_capture_service_test.dart` and `test/features/media/pending_media_sync_store_test.dart`.

**Patterns:**
- Setup pattern: create isolated filesystem state with `Directory.systemTemp.createTemp(...)` in `test/features/media/*.dart`.
- Teardown pattern: register cleanup with `addTearDown` instead of global `tearDown` in `test/features/media/local_media_store_test.dart` and `test/features/media/media_capture_service_test.dart`.
- Assertion pattern: verify both returned value and persisted side effects (`manifest`, queue entries) in `test/features/media/media_capture_service_test.dart`.

## Mocking

**Framework:**
- No dedicated mocking framework detected (`mockito` and `mocktail` are not in `pubspec.yaml`).

**Patterns:**
```dart
final service = MediaCaptureService(
  pickPhoto: () async => pickedFile.path,
  compressPhoto: (path) async => <int>[1, 2, 3],
  writeCapture: ({required inspectionId, required category, required bytes}) async {
    await outputFile.writeAsBytes(bytes, flush: true);
    return outputFile;
  },
  localStore: store,
  pendingSyncStore: pendingStore,
);
```
Pattern source: `test/features/media/media_capture_service_test.dart`.

**What to Mock:**
- Mock platform and I/O boundaries via constructor-injected function typedefs and providers (`pickPhoto`, `compressPhoto`, `writeCapture`, `directoryProvider`) in `lib/features/media/media_capture_service.dart` and `lib/features/media/local_media_store.dart`.

**What NOT to Mock:**
- Do not mock simple domain models/enums (`MediaSyncTask`, `RequiredPhotoCategory`, `FormType`) from `lib/features/media/media_sync_task.dart` and `lib/features/inspection/domain/*.dart`.
- Keep filesystem interactions real but isolated in temporary directories, as done in `test/features/media/*.dart`.

## Fixtures and Factories

**Test Data:**
```dart
final task = MediaSyncTask(
  taskId: 'done-task',
  inspectionId: 'i2',
  category: RequiredPhotoCategory.windRoofDeck,
  filePath: '/tmp/deck.jpg',
  createdAt: DateTime(2026, 1, 3),
);
```
Pattern source: `test/features/media/pending_media_sync_store_test.dart`.

**Location:**
- Inline fixtures are defined directly within each test case in `test/features/media/*.dart`.
- Shared fixture/factory directories are not present under `test/`.

## Coverage

**Requirements:** None enforced (no minimum threshold config detected in repository files).

**View Coverage:**
```bash
flutter test --coverage
```

## Test Types

**Unit Tests:**
- Core coverage is unit-style service/store behavior tests for media persistence and queueing in `test/features/media/local_media_store_test.dart`, `test/features/media/media_capture_service_test.dart`, and `test/features/media/pending_media_sync_store_test.dart`.

**Integration Tests:**
- No dedicated integration test suite detected (`integration_test/` is not present).

**E2E Tests:**
- Not used (no E2E framework/config detected in repository).

## Common Patterns

**Async Testing:**
```dart
test('markUploaded removes queued task', () async {
  await store.enqueue(task);
  await store.markUploaded('done-task');

  final pending = await store.listPending();
  expect(pending, isEmpty);
});
```
Pattern source: `test/features/media/pending_media_sync_store_test.dart`.

**Error Testing:**
```dart
final service = MediaCaptureService(
  pickPhoto: () async => null,
  writeCapture: ({required inspectionId, required category, required bytes}) async {
    throw StateError('should not write when canceled');
  },
);

final result = await service.captureRequiredPhoto(...);
expect(result, isNull);
```
Pattern source: `test/features/media/media_capture_service_test.dart`.

---

*Testing analysis: 2026-03-04*
