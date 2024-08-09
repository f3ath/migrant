import 'package:migrant/src/migration.dart';
import 'package:migrant/src/migration_source.dart';

/// A source of migration data.
/// This default implementation is a simple in-memory storage.
class InMemory implements MigrationSource {
  InMemory(this._migrations);

  final List<Migration> _migrations;

  @override
  Future<Migration> getInitial() async => _migrations.first;

  @override
  Future<Migration?> getNext(String currentVersion) async => _migrations
      .where((m) => m.version.compareTo(currentVersion) > 0)
      .firstOrNull;
}
