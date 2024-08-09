import 'package:migrant/migrant.dart';
import 'package:migrant/testing.dart';
import 'package:test/test.dart';

Future<void> main() async {
  group('Database', () {
    final migrations = [
      Migration('01', []),
      Migration('02', []),
      Migration('03', []),
    ];
    final source = InMemory(migrations);

    test('applies all migrations', () async {
      final gateway = TestGateway();
      final database = Database(gateway);
      await database.upgrade(source);
      expect(gateway.appliedMigrations, equals(migrations));
    });

    test('starts from the current version', () async {
      final gateway = TestGateway()..appliedMigrations.add(migrations.first);
      final database = Database(gateway);
      await database.upgrade(source);
      expect(gateway.appliedMigrations, equals(migrations));
    });

    test('noop when all migrations are already applied', () async {
      final gateway = TestGateway()..appliedMigrations.addAll(migrations);
      final database = Database(gateway);
      await database.upgrade(source);
      expect(gateway.appliedMigrations, equals(migrations));
    });

    test('Throws when migrations come out of order', () async {
      final database = Database(TestGateway());
      expect(() async {
        await database.upgrade(
            MockSource(Migration('02', []), next: Migration('01', [])));
      }, throwsStateError);
    });
  });
}
