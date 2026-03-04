import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../inspection/domain/form_requirements.dart';
import '../inspection/domain/required_photo_category.dart';
import 'local_media_store.dart';
import 'media_capture_result.dart';
import 'media_sync_task.dart';
import 'pending_media_sync_store.dart';
import '../sync/sync_operation.dart';

typedef PickPhoto = Future<String?> Function();
typedef CompressPhoto = Future<List<int>?> Function(String path);
typedef WriteCapture = Future<File> Function({
  required String inspectionId,
  required RequiredPhotoCategory category,
  required List<int> bytes,
});
typedef OperationIdFactory = String Function();

class MediaCaptureService {
  MediaCaptureService({
    PickPhoto? pickPhoto,
    CompressPhoto? compressPhoto,
    WriteCapture? writeCapture,
    LocalMediaStore? localStore,
    PendingMediaSyncStore? pendingSyncStore,
    OperationIdFactory? operationIdFactory,
  })  : _pickPhoto = pickPhoto ?? _defaultPickPhoto,
        _compressPhoto = compressPhoto ?? _defaultCompressPhoto,
        _writeCapture = writeCapture ?? _defaultWriteCapture,
        _localStore = localStore ?? LocalMediaStore(),
        _pendingSyncStore = pendingSyncStore ?? PendingMediaSyncStore(),
        _operationIdFactory = operationIdFactory ?? SyncOperation.newId;

  final PickPhoto _pickPhoto;
  final CompressPhoto _compressPhoto;
  final WriteCapture _writeCapture;
  final LocalMediaStore _localStore;
  final PendingMediaSyncStore _pendingSyncStore;
  final OperationIdFactory _operationIdFactory;

  Future<MediaCaptureResult?> captureRequiredPhoto({
    required String inspectionId,
    required String organizationId,
    required String userId,
    required RequiredPhotoCategory category,
    String? requirementKey,
    CapturedMediaType mediaType = CapturedMediaType.photo,
    String? evidenceInstanceId,
  }) async {
    final pickedPath = await _pickPhoto();
    if (pickedPath == null) {
      return null;
    }

    final compressed = await _compressPhoto(pickedPath);
    if (compressed == null || compressed.isEmpty) {
      return null;
    }

    final outputFile = await _writeCapture(
      inspectionId: inspectionId,
      category: category,
      bytes: compressed,
    );

    await _localStore.saveCapture(
      inspectionId: inspectionId,
      category: category,
      filePath: outputFile.path,
    );

    final resolvedRequirementKey =
        requirementKey ?? FormRequirements.requirementKeyForPhoto(category);
    final resolvedInstanceId = evidenceInstanceId ?? resolvedRequirementKey;

    final task = MediaSyncTask(
      taskId: _operationIdFactory(),
      inspectionId: inspectionId,
      organizationId: organizationId,
      userId: userId,
      requirementKey: resolvedRequirementKey,
      mediaType: mediaType,
      evidenceInstanceId: resolvedInstanceId,
      category: category,
      filePath: outputFile.path,
      createdAt: DateTime.now().toUtc(),
    );
    try {
      await _pendingSyncStore.enqueue(task);
    } catch (_) {
      // Local capture continuity is more important than immediate queue persistence.
    }

    return MediaCaptureResult(
      category: category,
      filePath: outputFile.path,
      byteSize: compressed.length,
    );
  }

  static Future<String?> _defaultPickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      return picked.path;
    }

    final lostData = await picker.retrieveLostData();
    if (lostData.isEmpty) {
      return null;
    }
    final recovered = lostData.file ?? (lostData.files?.isNotEmpty == true ? lostData.files!.first : null);
    if (recovered == null) {
      return null;
    }
    return recovered.path;
  }

  static Future<List<int>?> _defaultCompressPhoto(String path) {
    return FlutterImageCompress.compressWithFile(
      path,
      minWidth: 1280,
      minHeight: 960,
      quality: 75,
      format: CompressFormat.jpeg,
    );
  }

  static Future<File> _defaultWriteCapture({
    required String inspectionId,
    required RequiredPhotoCategory category,
    required List<int> bytes,
  }) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final captureDir = Directory('${docsDir.path}/captures/$inspectionId');
    await captureDir.create(recursive: true);

    final filename =
        '${category.name}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final output = File('${captureDir.path}/$filename');
    await output.writeAsBytes(bytes, flush: true);
    return output;
  }
}
