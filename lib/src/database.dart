import 'package:migrant/migrant.dart';

/// The database wrapper which performs the migration.
class Database {
  Database(this._gateway);

  final DatabaseGateway _gateway;

  /// Applies the migrations from the [source].
  Future<void> migrate(MigrationSource source) async {
    while (true) {
      final currentVersion = await _gateway.currentVersion();
      if (currentVersion != null) {
        final migration = await source.getNext(currentVersion);
        if (migration == null) break;
        migration.version.assertHigherThan(currentVersion);
        await _gateway.upgrade(migration, currentVersion);
      } else {
        final migration = await source.getFirst();
        if (migration == null) break;
        await _gateway.apply(migration);
      }
    }
  }
}

extension on String {
  assertHigherThan(String other) {
    if (compareTo(other) <= 0) {
      throw StateError('Version "$this" must be higher than "$other"');
    }
  }
}
