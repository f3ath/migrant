import 'migrant.dart';

/// A testing gateway instance.
class TestGateway extends DatabaseGateway {
  TestGateway({this.initialVersion});

  /// Initial DB version.
  final String? initialVersion;

  /// All the applied migrations.
  final appliedMigrations = <Migration>[];

  /// All applied migration versions.
  List<String> get appliedVersions =>
      appliedMigrations.map((e) => e.version).toList();

  @override
  Future<String?> currentVersion() async => appliedMigrations.isEmpty
      ? initialVersion
      : appliedMigrations.last.version;

  @override
  Future<void> apply(Migration migration) async {
    appliedMigrations.add(migration);
  }
}

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

/// Unsorted dumb source which does not respect version order.
/// Useful for testing error scenarios.
class AsIs implements MigrationSource {
  AsIs(this._migrations);

  final List<Migration> _migrations;

  /// Returns the migrations as-is, regardless of the version order.
  /// Ignores [afterVersion] argument.
  @override
  Stream<Migration> read({String? afterVersion}) =>
      Stream.fromIterable(_migrations);
}
