import 'dart:io';

import '../data/pdf_media_resolver.dart';
import '../domain/pdf_size_budget.dart';
import '../pdf_generation_input.dart';
import 'narrative_render_context.dart';

/// Resolves photo keys from a [PdfGenerationInput] into byte data
/// for narrative PDF embedding.
///
/// Resolution strategy per photo path:
/// 1. Try local file read
/// 2. If local fails and [remoteReadBytes] is provided, try remote
/// 3. Failed resolutions are non-fatal: bytes=null with a failureReason
class NarrativeMediaResolver {
  const NarrativeMediaResolver({this.remoteReadBytes});

  /// Optional remote reader for fetching images from cloud storage.
  final PdfRemoteMediaReader? remoteReadBytes;

  /// Resolves all requested photo keys into [ResolvedNarrativePhoto] maps.
  ///
  /// Returns a map from source key to a list of resolved photos.
  /// Keys with no media paths in [input.evidenceMediaPaths] are skipped.
  /// Failures are captured in [ResolvedNarrativePhoto.failureReason] --
  /// this method never throws.
  Future<Map<String, List<ResolvedNarrativePhoto>>> resolveAll({
    required PdfGenerationInput input,
    required Set<String> photoKeys,
    required PdfSizeRetryStep retryStep,
  }) async {
    if (photoKeys.isEmpty) {
      return const {};
    }

    final result = <String, List<ResolvedNarrativePhoto>>{};

    for (final key in photoKeys) {
      final paths = input.evidenceMediaPaths[key];
      if (paths == null || paths.isEmpty) {
        continue;
      }

      final photos = <ResolvedNarrativePhoto>[];
      for (final rawPath in paths) {
        final path = rawPath.trim();
        if (path.isEmpty) {
          continue;
        }

        final resolved = await _resolvePhoto(
          sourceKey: key,
          path: path,
          retryStep: retryStep,
        );
        photos.add(resolved);
      }

      if (photos.isNotEmpty) {
        result[key] = photos;
      }
    }

    return result;
  }

  Future<ResolvedNarrativePhoto> _resolvePhoto({
    required String sourceKey,
    required String path,
    required PdfSizeRetryStep retryStep,
  }) async {
    // Try local file first
    try {
      final file = File(path);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        if (bytes.isNotEmpty) {
          return ResolvedNarrativePhoto(
            sourceKey: sourceKey,
            originalPath: path,
            bytes: bytes,
          );
        }
      }
    } catch (e) {
      // Fall through to remote attempt
    }

    // Try remote reader if available
    final remoteReader = remoteReadBytes;
    if (remoteReader != null) {
      try {
        final remoteBytes = await remoteReader(path);
        if (remoteBytes != null && remoteBytes.isNotEmpty) {
          return ResolvedNarrativePhoto(
            sourceKey: sourceKey,
            originalPath: path,
            bytes: remoteBytes,
          );
        }
      } catch (e) {
        return ResolvedNarrativePhoto(
          sourceKey: sourceKey,
          originalPath: path,
          failureReason: 'Remote read failed: $e',
        );
      }
    }

    return ResolvedNarrativePhoto(
      sourceKey: sourceKey,
      originalPath: path,
      failureReason: 'Unable to resolve: file not found locally'
          '${remoteReader == null ? "" : " and remote read returned no data"}',
    );
  }
}
