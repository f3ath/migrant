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
      final current = await _gateway.currentVersion();
      if (current == null) {
        await _gateway.initialize(await source.getInitial());
        continue;
      }
      final migration = await source.getNext(current);
      if (migration == null) break;
      migration.version.assertHigherThan(current);
      await _gateway.upgrade(current, migration);
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
