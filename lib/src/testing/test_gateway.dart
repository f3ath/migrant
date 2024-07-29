import 'package:migrant/src/database_gateway.dart';
import 'package:migrant/src/migration.dart';

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
  Future<void> apply(Migration migration, {String? assertCurrentVersion}) async {
    appliedMigrations.add(migration);
  }
}
