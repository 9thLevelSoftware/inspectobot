/// Registry of schema migrations for [PropertyData] JSON payloads.
///
/// Each time the serialized shape of PropertyData changes in a
/// backward-incompatible way, bump [currentVersion] and add a migration
/// function to the chain inside [migrate].
abstract final class PropertyDataMigrations {
  static const int currentVersion = 1;

  /// Migrates a raw JSON map to [currentVersion].
  ///
  /// If the map is already at [currentVersion] or newer it is returned as-is.
  static Map<String, dynamic> migrate(Map<String, dynamic> json) {
    final version = json['schema_version'] as int? ?? 1;

    if (version >= currentVersion) {
      // Forward compat or current: preserve as-is.
      return json;
    }

    var result = Map<String, dynamic>.from(json);
    // Migration chain placeholder:
    // if (version < 2) result = _migrateV1toV2(result);

    result['schema_version'] = currentVersion;
    return result;
  }
}
