import 'package:migrant/src/migration.dart';
import 'package:migrant/src/migration_source.dart';

/// A source of migration data.
/// This default implementation is a simple in-memory storage.
class InMemory implements MigrationSource {
  /// Creates a new instance from the version-to-migration map.
  InMemory(Map<String, String> versionToMigration) {
    _migrations.addAll(
        versionToMigration.entries.map((_) => Migration(_.key, _.value)));
    _migrations.sort((a, b) => a.version.compareTo(b.version));
  }

  final _migrations = <Migration>[];

  @override
  Stream<Migration> read({String? afterVersion}) =>
      Stream.fromIterable(_migrations.where((_) =>
          afterVersion == null || _.version.compareTo(afterVersion) > 0));
}
