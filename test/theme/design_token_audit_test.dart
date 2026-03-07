import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final presentationFiles = _findDartFiles([
    'lib/features',
    'lib/common/widgets',
  ]);

  test('no hardcoded Colors in presentation layer', () {
    final violations = <String>[];
    final pattern = RegExp(r'Colors\.\w+');
    for (final file in presentationFiles) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (pattern.hasMatch(lines[i])) {
          violations.add('${file.path}:${i + 1}: ${lines[i].trim()}');
        }
      }
    }
    expect(violations, isEmpty,
        reason: 'Found hardcoded Colors:\n${violations.join('\n')}');
  });

  test('no numeric EdgeInsets in presentation layer', () {
    final violations = <String>[];
    final pattern = RegExp(r'EdgeInsets\.(all|symmetric|only)\(\d');
    for (final file in presentationFiles) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (pattern.hasMatch(lines[i])) {
          violations.add('${file.path}:${i + 1}: ${lines[i].trim()}');
        }
      }
    }
    expect(violations, isEmpty,
        reason: 'Found numeric EdgeInsets:\n${violations.join('\n')}');
  });

  test('no numeric SizedBox in presentation layer', () {
    final violations = <String>[];
    final pattern = RegExp(r'SizedBox\((height|width): \d');
    for (final file in presentationFiles) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (pattern.hasMatch(lines[i])) {
          violations.add('${file.path}:${i + 1}: ${lines[i].trim()}');
        }
      }
    }
    expect(violations, isEmpty,
        reason: 'Found numeric SizedBox:\n${violations.join('\n')}');
  });

  test('no numeric BorderRadius in presentation layer', () {
    final violations = <String>[];
    final pattern = RegExp(r'BorderRadius\.circular\(\d');
    for (final file in presentationFiles) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (pattern.hasMatch(lines[i])) {
          violations.add('${file.path}:${i + 1}: ${lines[i].trim()}');
        }
      }
    }
    expect(violations, isEmpty,
        reason: 'Found numeric BorderRadius:\n${violations.join('\n')}');
  });
}

List<File> _findDartFiles(List<String> directories) {
  final files = <File>[];
  for (final dir in directories) {
    final directory = Directory(dir);
    if (!directory.existsSync()) continue;
    for (final entity in directory.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final path = entity.path.replaceAll('\\', '/');
        if (path.contains('/presentation/') ||
            path.contains('/common/widgets/')) {
          files.add(entity);
        }
      }
    }
  }
  return files;
}
