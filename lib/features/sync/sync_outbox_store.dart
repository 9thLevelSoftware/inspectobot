import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../media/local_media_store.dart';
import 'sync_operation.dart';

class SyncOutboxStore {
  SyncOutboxStore({DirectoryProvider? directoryProvider})
      : _directoryProvider = directoryProvider ?? getApplicationDocumentsDirectory;

  final DirectoryProvider _directoryProvider;

  Future<void> enqueue(
    SyncOperation operation, {
    bool Function(SyncOperation existing)? replaceWhere,
  }) async {
    final operations = await _readAll();
    if (replaceWhere != null) {
      operations.removeWhere(replaceWhere);
    }
    operations.add(operation);
    await _writeAll(operations);
  }

  Future<List<SyncOperation>> listAll() async {
    return _readAll();
  }

  Future<List<SyncOperation>> listByStatus(SyncOperationStatus status) async {
    final operations = await _readAll();
    return operations.where((op) => op.status == status).toList(growable: false);
  }

  Future<void> markInFlight(String operationId) async {
    await _updateStatus(operationId, SyncOperationStatus.inFlight);
  }

  Future<void> markCompleted(String operationId) async {
    await _updateStatus(operationId, SyncOperationStatus.completed);
  }

  Future<void> markFailed(String operationId, {required String error}) async {
    final operations = await _readAll();
    final index = operations.indexWhere((op) => op.operationId == operationId);
    if (index < 0) {
      return;
    }
    final current = operations[index];
    operations[index] = current.copyWith(
      status: SyncOperationStatus.failed,
      retryCount: current.retryCount + 1,
      lastError: error,
      lastAttemptAt: DateTime.now().toUtc(),
    );
    await _writeAll(operations);
  }

  Future<void> remove(String operationId) async {
    final operations = await _readAll();
    operations.removeWhere((op) => op.operationId == operationId);
    await _writeAll(operations);
  }

  Future<File> _outboxFile() async {
    final dir = await _directoryProvider();
    final queueDir = Directory('${dir.path}/sync_queue');
    await queueDir.create(recursive: true);
    return File('${queueDir.path}/sync_outbox.json');
  }

  Future<File> _corruptFile() async {
    final dir = await _directoryProvider();
    final queueDir = Directory('${dir.path}/sync_queue');
    await queueDir.create(recursive: true);
    return File('${queueDir.path}/sync_outbox_corrupt.jsonl');
  }

  Future<List<SyncOperation>> _readAll() async {
    final file = await _outboxFile();
    if (!await file.exists()) {
      return <SyncOperation>[];
    }

    final raw = await file.readAsString();
    if (raw.trim().isEmpty) {
      return <SyncOperation>[];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List<dynamic>) {
      await _parkCorruptRecord(<String, dynamic>{
        'reason': 'outbox payload is not a list',
        'payload': decoded,
      });
      return <SyncOperation>[];
    }

    final operations = <SyncOperation>[];
    for (var i = 0; i < decoded.length; i++) {
      final row = decoded[i];
      if (row is! Map) {
        await _parkCorruptRecord(<String, dynamic>{
          'reason': 'row is not an object',
          'index': i,
          'payload': row,
        });
        continue;
      }
      try {
        operations.add(SyncOperation.fromJson(Map<String, dynamic>.from(row)));
      } on FormatException catch (error) {
        await _parkCorruptRecord(<String, dynamic>{
          'reason': error.message,
          'index': i,
          'payload': row,
        });
      }
    }

    return operations;
  }

  Future<void> _writeAll(List<SyncOperation> operations) async {
    final file = await _outboxFile();
    final payload = operations.map((op) => op.toJson()).toList(growable: false);
    await file.writeAsString(jsonEncode(payload), flush: true);
  }

  Future<void> _updateStatus(
    String operationId,
    SyncOperationStatus status,
  ) async {
    final operations = await _readAll();
    final index = operations.indexWhere((op) => op.operationId == operationId);
    if (index < 0) {
      return;
    }

    operations[index] = operations[index].copyWith(
      status: status,
      lastAttemptAt: DateTime.now().toUtc(),
      lastError: status == SyncOperationStatus.completed ? null : operations[index].lastError,
    );
    await _writeAll(operations);
  }

  Future<void> _parkCorruptRecord(Map<String, dynamic> record) async {
    final file = await _corruptFile();
    final line = jsonEncode(<String, dynamic>{
      'captured_at': DateTime.now().toUtc().toIso8601String(),
      ...record,
    });
    if (!await file.exists()) {
      await file.writeAsString('$line\n', flush: true);
      return;
    }
    await file.writeAsString('$line\n', mode: FileMode.append, flush: true);
  }
}
