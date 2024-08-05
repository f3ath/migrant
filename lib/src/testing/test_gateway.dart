import 'package:migrant/src/database_gateway.dart';
import 'package:migrant/src/migration.dart';

/// A testing gateway instance.
class TestGateway extends DatabaseGateway {
  TestGateway();

  /// All the applied migrations.
  final appliedMigrations = <Migration>[];

  /// All applied migration versions.
  List<String> get appliedVersions =>
      appliedMigrations.map((e) => e.version).toList();

  @override
  Future<String?> currentVersion() async =>
      appliedMigrations.lastOrNull?.version;

  @override
  Future<void> initialize(Migration migration) async {
    appliedMigrations.add(migration);
  }

  @override
  Future<void> upgrade(String fromVersion, Migration migration) async {
    appliedMigrations.add(migration);
  }
}
