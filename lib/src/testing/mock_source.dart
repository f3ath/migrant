import 'package:migrant/src/migration.dart';
import 'package:migrant/src/migration_source.dart';

class MockSource implements MigrationSource {
  MockSource(this.first, {this.next});

  Migration first;
  Migration? next;

  @override
  Future<Migration> getInitial() async => first;

  @override
  Future<Migration?> getNext(String currentVersion) async => next;
}
