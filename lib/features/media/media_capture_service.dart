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

/// Error types for media capture operations.
enum MediaCaptureError {
  /// Camera permission was denied by the user.
  cameraPermissionDenied,

  /// Gallery/photos permission was denied by the user.
  galleryPermissionDenied,

  /// Photo capture was canceled by the user.
  captureCanceled,

  /// Photo compression failed.
  compressionFailed,

  /// File save operation failed.
  saveFailed,

  /// Unsupported document type.
  unsupportedDocumentType,

  /// Unknown error occurred.
  unknown,
}

/// Result type for media capture operations that can fail.
class MediaCaptureServiceResult {
  const MediaCaptureServiceResult._({
    this.result,
    this.error,
    this.errorMessage,
  });

  /// Success result with captured media.
  factory MediaCaptureServiceResult.success(MediaCaptureResult result) {
    return MediaCaptureServiceResult._(result: result);
  }

  /// Error result with specific error type and message.
  factory MediaCaptureServiceResult.error(
    MediaCaptureError error, {
    String? message,
  }) {
    return MediaCaptureServiceResult._(
      error: error,
      errorMessage: message ?? _defaultErrorMessage(error),
    );
  }

  /// The captured media result, if successful.
  final MediaCaptureResult? result;

  /// The error type, if failed.
  final MediaCaptureError? error;

  /// Human-readable error message.
  final String? errorMessage;

  /// Whether the operation was successful.
  bool get isSuccess => result != null;

  /// Whether the operation failed.
  bool get isError => error != null;

  static String _defaultErrorMessage(MediaCaptureError error) {
    return switch (error) {
      MediaCaptureError.cameraPermissionDenied =>
        'Camera permission denied. Please enable camera access in Settings > Privacy > Camera.',
      MediaCaptureError.galleryPermissionDenied =>
        'Gallery permission denied. Please enable photo access in Settings > Privacy > Photos.',
      MediaCaptureError.captureCanceled =>
        'Photo capture was canceled.',
      MediaCaptureError.compressionFailed =>
        'Failed to process the image. Please try again.',
      MediaCaptureError.saveFailed =>
        'Failed to save the image. Please check storage space and try again.',
      MediaCaptureError.unsupportedDocumentType =>
        'Unsupported file type. Please select a PDF or image file.',
      MediaCaptureError.unknown =>
        'An unexpected error occurred. Please try again.',
    };
  }
}

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

  /// Captures a required photo for an inspection.
  /// 
  /// Returns a [MediaCaptureServiceResult] which contains either the
  /// successful [MediaCaptureResult] or an error with user-friendly message.
  Future<MediaCaptureServiceResult> captureRequiredPhoto({
    required String inspectionId,
    required String organizationId,
    required String userId,
    required RequiredPhotoCategory category,
    String? requirementKey,
    CapturedMediaType mediaType = CapturedMediaType.photo,
    String? evidenceInstanceId,
  }) async {
    String? pickedPath;
    try {
      pickedPath = mediaType == CapturedMediaType.document
          ? await _pickDocument()
          : await _pickPhoto();
    } catch (e) {
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('permission') ||
          errorString.contains('denied')) {
        return MediaCaptureServiceResult.error(
          mediaType == CapturedMediaType.document
              ? MediaCaptureError.galleryPermissionDenied
              : MediaCaptureError.cameraPermissionDenied,
        );
      }
      return MediaCaptureServiceResult.error(
        MediaCaptureError.unknown,
        message: 'Failed to capture: $e',
      );
    }
    
    if (pickedPath == null) {
      return MediaCaptureServiceResult.error(MediaCaptureError.captureCanceled);
    }

    File outputFile;
    int byteSize;
    if (mediaType == CapturedMediaType.document) {
      if (!_isSupportedDocumentPath(pickedPath)) {
        return MediaCaptureServiceResult.error(
          MediaCaptureError.unsupportedDocumentType,
        );
      }
      try {
        outputFile = await _writeCapture(
          inspectionId: inspectionId,
          category: category,
          mediaType: mediaType,
          sourcePath: pickedPath,
        );
        byteSize = await outputFile.length();
      } catch (e) {
        return MediaCaptureServiceResult.error(
          MediaCaptureError.saveFailed,
          message: 'Failed to save document: $e',
        );
      }
    } else {
      List<int>? compressed;
      try {
        compressed = await _compressPhoto(pickedPath);
      } catch (e) {
        return MediaCaptureServiceResult.error(
          MediaCaptureError.compressionFailed,
          message: 'Failed to compress image: $e',
        );
      }
      
      if (compressed == null || compressed.isEmpty) {
        return MediaCaptureServiceResult.error(MediaCaptureError.compressionFailed);
      }
      
      try {
        outputFile = await _writeCapture(
          inspectionId: inspectionId,
          category: category,
          mediaType: mediaType,
          sourcePath: pickedPath,
          bytes: compressed,
        );
        byteSize = compressed.length;
      } catch (e) {
        return MediaCaptureServiceResult.error(
          MediaCaptureError.saveFailed,
          message: 'Failed to save photo: $e',
        );
      }
    }

    try {
      await _localStore.saveCapture(
        inspectionId: inspectionId,
        category: category,
        filePath: outputFile.path,
      );
    } catch (e) {
      // Non-fatal: continue even if local store save fails
    }

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

    return MediaCaptureServiceResult.success(
      MediaCaptureResult(
        category: category,
        filePath: outputFile.path,
        byteSize: byteSize,
      ),
    );
  }

  static Future<String?> _defaultPickPhoto() async {
    final picker = ImagePicker();
    try {
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
    } on Exception catch (e) {
      // Handle permission errors from image_picker
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('permission') || 
          errorString.contains('denied') ||
          errorString.contains('camera_access')) {
        throw _CameraPermissionException();
      }
      return null;
    }
  }

  static Future<String?> _defaultPickDocument() async {
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const <String>['pdf', 'png', 'jpg', 'jpeg'],
      );
      final file = picked?.files.isNotEmpty == true ? picked!.files.first : null;
      return file?.path;
    } on Exception catch (e) {
      // Handle permission errors from file_picker
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('permission') || errorString.contains('denied')) {
        throw _GalleryPermissionException();
      }
      return null;
    }
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
    final filename = '${category.name}_$timestamp$extension';
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

/// Exception thrown when camera permission is denied.
class _CameraPermissionException implements Exception {
  @override
  String toString() => 'Camera permission denied';
}

/// Exception thrown when gallery/photos permission is denied.
class _GalleryPermissionException implements Exception {
  @override
  String toString() => 'Gallery permission denied';
}
