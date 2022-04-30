import 'package:migrant/src/database_gateway.dart';
import 'package:migrant/src/migration_source.dart';

/// The database wrapper which performs the migration.
class Database {
  Database(this._gateway);

  final DatabaseGateway _gateway;

  /// Applies the migrations from the [source].
  Future<void> migrate(MigrationSource source) async {
    String? current = await _gateway.currentVersion();
    await for (final migration in source.read(afterVersion: current)) {
      final next = migration.version;
      if (current != null) _enforceOrder(current, next);
      await _gateway.apply(migration);
      current = next;
    }
  }

  _enforceOrder(String prev, String next) {
    if (prev.compareTo(next) >= 0) {
      throw StateError(
          'Next migration version ($next) is lower than current ($prev)');
    }
  }
}
