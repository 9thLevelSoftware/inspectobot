import 'package:inspectobot/features/media/media_sync_task.dart';

String buildMediaStoragePath({
  required String organizationId,
  required String userId,
  required String inspectionId,
  required String mediaId,
  required CapturedMediaType mediaType,
}) {
  final extension = mediaType == CapturedMediaType.document ? 'pdf' : 'jpg';
  return 'org/$organizationId/users/$userId/inspections/$inspectionId/media/$mediaId.$extension';
}

String buildReportArtifactStoragePath({
  required String organizationId,
  required String userId,
  required String inspectionId,
  required String fileName,
}) {
  return 'org/$organizationId/users/$userId/reports/$inspectionId/$fileName';
}
