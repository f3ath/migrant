import 'package:migrant/migrant.dart';

/// The database wrapper which performs the migration.
class Database {
  Database(this._gateway);

  final DatabaseGateway _gateway;

  /// Applies the migrations from the [source].
  /// This method does not catch exceptions thrown by the [source]
  /// or the underlying [DatabaseGateway].
  /// Error handling is the responsibility of the caller.
  Future<void> upgrade(MigrationSource source) async {
    while (true) {
      final currentVersion = await _gateway.currentVersion();
      if (currentVersion == null) {
        final migration = await source.getFirst();
        if (migration == null) break;
        await _gateway.initialize(migration);
        continue;
      }
      final migration = await source.getNext(currentVersion);
      if (migration == null) break;
      migration.version.assertHigherThan(currentVersion);
      await _gateway.upgrade(currentVersion, migration);
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
