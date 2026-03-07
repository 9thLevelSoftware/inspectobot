import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/property_data_migrations.dart';

void main() {
  group('PropertyDataMigrations', () {
    test('currentVersion is 1', () {
      expect(PropertyDataMigrations.currentVersion, 1);
    });

    test('migrate with version 1 data returns data with schema_version 1', () {
      final input = <String, dynamic>{
        'schema_version': 1,
        'inspection_id': 'test',
      };
      final result = PropertyDataMigrations.migrate(input);

      expect(result['schema_version'], 1);
      expect(result['inspection_id'], 'test');
    });

    test('migrate with missing schema_version defaults to 1', () {
      final input = <String, dynamic>{
        'inspection_id': 'test',
      };
      final result = PropertyDataMigrations.migrate(input);

      // Missing defaults to 1, which is >= currentVersion, so returned as-is.
      expect(result['inspection_id'], 'test');
    });

    test('migrate with version > currentVersion returns unchanged (forward compat)', () {
      final input = <String, dynamic>{
        'schema_version': 99,
        'inspection_id': 'future',
      };
      final result = PropertyDataMigrations.migrate(input);

      expect(result['schema_version'], 99);
      expect(result['inspection_id'], 'future');
    });
  });
}
