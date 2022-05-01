import 'migrant.dart';

/// A testing gateway instance.
class TestGateway extends DatabaseGateway {
  TestGateway({this.version = null});

  String? version;

  @override
  Future<String?> currentVersion() async => version;

  @override
  Future<void> apply(Migration migration) async {
    version = migration.version;
    log.add('${migration.version}:${migration.statement}');
  }

  final log = <String>[];
}

/// A testing migration source.
class TestMigrationSource implements MigrationSource {
  TestMigrationSource(Iterable<Migration> migrations)
      : _migrations = Stream.fromIterable(migrations);

  final Stream<Migration> _migrations;

  @override
  Stream<Migration> read({String? afterVersion = null}) => _migrations;
}
