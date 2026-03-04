import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/required_photo_category.dart';
import 'package:inspectobot/features/media/local_media_store.dart';

void main() {
  test('local media store saves and reads capture paths', () async {
    final tempRoot = await Directory.systemTemp.createTemp('inspectobot_store_');
    addTearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    final store = LocalMediaStore(directoryProvider: () async => tempRoot);

    await store.saveCapture(
      inspectionId: 'inspection-1',
      category: RequiredPhotoCategory.exteriorFront,
      filePath: 'captures/front.jpg',
    );

    await store.saveCapture(
      inspectionId: 'inspection-1',
      category: RequiredPhotoCategory.windRoofDeck,
      filePath: 'captures/deck.jpg',
    );

    final manifest = await store.readCaptures('inspection-1');

    expect(manifest[RequiredPhotoCategory.exteriorFront], 'captures/front.jpg');
    expect(manifest[RequiredPhotoCategory.windRoofDeck], 'captures/deck.jpg');
  });
}

