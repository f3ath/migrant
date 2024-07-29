import 'package:migrant/src/migration.dart';
import 'package:migrant/src/migration_source.dart';

/// A source of migration data.
/// This default implementation is a simple in-memory storage.
class InMemory implements MigrationSource {
  InMemory(this._migrations);

  /// Creates a new instance from the version-to-migration map.
  InMemory.fromMap(Map<String, String> versionToMigration)
      : this(versionToMigration.entries
            .map((it) => Migration(it.key, it.value))
            .toList()
          ..sort((a, b) => a.version.compareTo(b.version)));

  final List<Migration> _migrations;

  @override
  Stream<Migration> read({String? afterVersion}) =>
      Stream.fromIterable(_migrations.where((migration) =>
          afterVersion == null ||
          migration.version.compareTo(afterVersion) > 0));
}
