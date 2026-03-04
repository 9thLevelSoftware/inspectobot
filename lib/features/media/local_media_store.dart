import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../inspection/domain/required_photo_category.dart';

typedef DirectoryProvider = Future<Directory> Function();

class LocalMediaStore {
  LocalMediaStore({DirectoryProvider? directoryProvider})
      : _directoryProvider = directoryProvider ?? getApplicationDocumentsDirectory;

  final DirectoryProvider _directoryProvider;

  Future<void> saveCapture({
    required String inspectionId,
    required RequiredPhotoCategory category,
    required String filePath,
  }) async {
    final file = await _manifestFile(inspectionId);
    final manifest = await _readManifest(file);
    manifest[category.name] = filePath;
    await file.writeAsString(jsonEncode(manifest), flush: true);
  }

  Future<Map<RequiredPhotoCategory, String>> readCaptures(
    String inspectionId,
  ) async {
    final file = await _manifestFile(inspectionId);
    if (!await file.exists()) {
      return <RequiredPhotoCategory, String>{};
    }

    final manifest = await _readManifest(file);
    final output = <RequiredPhotoCategory, String>{};
    for (final entry in manifest.entries) {
      final matching = RequiredPhotoCategory.values.where(
        (c) => c.name == entry.key,
      );
      if (matching.isEmpty) {
        continue;
      }
      output[matching.first] = entry.value;
    }
    return output;
  }

  Future<File> _manifestFile(String inspectionId) async {
    final dir = await _directoryProvider();
    final root = Directory('${dir.path}/media_manifests');
    await root.create(recursive: true);
    return File('${root.path}/$inspectionId.json');
  }

  Future<Map<String, String>> _readManifest(File file) async {
    if (!await file.exists()) {
      return <String, String>{};
    }
    final raw = await file.readAsString();
    if (raw.trim().isEmpty) {
      return <String, String>{};
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return <String, String>{};
    }

    return decoded.map((key, value) => MapEntry(key, value.toString()));
  }
}
