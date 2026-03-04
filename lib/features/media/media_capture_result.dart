import '../inspection/domain/required_photo_category.dart';

class MediaCaptureResult {
  const MediaCaptureResult({
    required this.category,
    required this.filePath,
    required this.byteSize,
  });

  final RequiredPhotoCategory category;
  final String filePath;
  final int byteSize;
}

