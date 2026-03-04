import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/identity/data/signature_repository.dart';

void main() {
  test('buildStoragePath scopes files by org and user', () {
    final repository = SignatureRepository(
      storage: InMemorySignatureGateway(),
      metadata: InMemorySignatureGateway(),
    );

    final path = repository.buildStoragePath(
      organizationId: 'org-123',
      userId: 'user-456',
    );

    expect(path, 'org/org-123/users/user-456/signature.png');
  });

  test('saveSignature stores metadata and reloads it', () async {
    final gateway = InMemorySignatureGateway();
    final repository = SignatureRepository(storage: gateway, metadata: gateway);
    final bytes = Uint8List.fromList([1, 2, 3, 4]);

    final saved = await repository.saveSignature(
      organizationId: 'org-1',
      userId: 'user-1',
      bytes: bytes,
    );
    final loaded = await repository.loadSignature(
      organizationId: 'org-1',
      userId: 'user-1',
    );

    expect(loaded, isNotNull);
    expect(loaded!.storagePath, saved.storagePath);
    expect(loaded.fileHash, saved.fileHash);
  });
}
