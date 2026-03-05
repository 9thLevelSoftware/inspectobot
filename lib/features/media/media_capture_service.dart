import 'dart:io';

import 'package:file_picker/file_picker.dart';
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
typedef PickDocument = Future<String?> Function();
typedef CompressPhoto = Future<List<int>?> Function(String path);
typedef WriteCapture =
    Future<File> Function({
      required String inspectionId,
      required RequiredPhotoCategory category,
      required CapturedMediaType mediaType,
      required String sourcePath,
      List<int>? bytes,
    });
typedef OperationIdFactory = String Function();

class MediaCaptureService {
  MediaCaptureService({
    PickPhoto? pickPhoto,
    PickDocument? pickDocument,
    CompressPhoto? compressPhoto,
    WriteCapture? writeCapture,
    LocalMediaStore? localStore,
    PendingMediaSyncStore? pendingSyncStore,
    OperationIdFactory? operationIdFactory,
  }) : _pickPhoto = pickPhoto ?? _defaultPickPhoto,
       _pickDocument = pickDocument ?? _defaultPickDocument,
       _compressPhoto = compressPhoto ?? _defaultCompressPhoto,
       _writeCapture = writeCapture ?? _defaultWriteCapture,
       _localStore = localStore ?? LocalMediaStore(),
       _pendingSyncStore = pendingSyncStore ?? PendingMediaSyncStore(),
       _operationIdFactory = operationIdFactory ?? SyncOperation.newId;

  final PickPhoto _pickPhoto;
  final PickDocument _pickDocument;
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
    final pickedPath = mediaType == CapturedMediaType.document
        ? await _pickDocument()
        : await _pickPhoto();
    if (pickedPath == null) {
      return null;
    }

    File outputFile;
    int byteSize;
    if (mediaType == CapturedMediaType.document) {
      if (!_isSupportedDocumentPath(pickedPath)) {
        return null;
      }
      outputFile = await _writeCapture(
        inspectionId: inspectionId,
        category: category,
        mediaType: mediaType,
        sourcePath: pickedPath,
      );
      byteSize = await outputFile.length();
    } else {
      final compressed = await _compressPhoto(pickedPath);
      if (compressed == null || compressed.isEmpty) {
        return null;
      }
      outputFile = await _writeCapture(
        inspectionId: inspectionId,
        category: category,
        mediaType: mediaType,
        sourcePath: pickedPath,
        bytes: compressed,
      );
      byteSize = compressed.length;
    }

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
      byteSize: byteSize,
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
    final recovered =
        lostData.file ??
        (lostData.files?.isNotEmpty == true ? lostData.files!.first : null);
    if (recovered == null) {
      return null;
    }
    return recovered.path;
  }

  static Future<String?> _defaultPickDocument() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const <String>['pdf', 'png', 'jpg', 'jpeg'],
    );
    final file = picked?.files.isNotEmpty == true ? picked!.files.first : null;
    return file?.path;
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
    required CapturedMediaType mediaType,
    required String sourcePath,
    List<int>? bytes,
  }) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final captureDir = Directory('${docsDir.path}/captures/$inspectionId');
    await captureDir.create(recursive: true);

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sourceExtension = _normalizedExtension(sourcePath);
    final extension = mediaType == CapturedMediaType.document
        ? (sourceExtension.isEmpty ? '.pdf' : sourceExtension)
        : '.jpg';
    final filename = '${category.name}_${timestamp}$extension';
    final output = File('${captureDir.path}/$filename');
    if (mediaType == CapturedMediaType.document) {
      await File(sourcePath).copy(output.path);
      return output;
    }

    if (bytes == null || bytes.isEmpty) {
      throw StateError(
        'Photo capture bytes are required for photo media type.',
      );
    }
    await output.writeAsBytes(bytes, flush: true);
    return output;
  }

  static bool _isSupportedDocumentPath(String path) {
    const allowed = <String>{'.pdf', '.png', '.jpg', '.jpeg'};
    return allowed.contains(_normalizedExtension(path));
  }

  static String _normalizedExtension(String path) {
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex < 0 || dotIndex == path.length - 1) {
      return '';
    }
    return path.substring(dotIndex).toLowerCase();
  }
}
