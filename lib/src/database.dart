import 'package:migrant/src/database_gateway.dart';
import 'package:migrant/src/migration_source.dart';

/// The database wrapper which performs the migration.
class Database {
  Database(this._gateway);

  final DatabaseGateway _gateway;

  /// Applies the migrations from the [source].
  Future<void> migrate(MigrationSource source) async {
    while (true) {
      final current = await _gateway.currentVersion();
      final migrationsToApply = source.read(afterVersion: current);
      if (await migrationsToApply.isEmpty) break;
      final migration = await migrationsToApply.first;
      migration.version.mustBeHigherThan(current);
      await _gateway.apply(migration, assertCurrentVersion: current);
    }
  }
}

extension on String {
  mustBeHigherThan(String? other) {
    if (other != null && compareTo(other) <= 0) {
      throw StateError('Version "$this" must be higher than "$other"');
    }
  }
}
