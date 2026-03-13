import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() {
  return integrationDriver(
    onScreenshot: (
      String name,
      List<int> image, [
      Map<String, Object?>? args,
    ]) async {
      final file = File('docs/ui-ux-review/screenshots/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(image, flush: true);
      return true;
    },
  );
}
