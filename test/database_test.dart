import 'package:migrant/migrant.dart';
import 'package:migrant/testing.dart';
import 'package:test/test.dart';

Future<void> main() async {
  group('Database', () {
    final source = InMemory([
      Migration('01', ''),
      Migration('02', ''),
      Migration('03', ''),
    ]);

    test('All migrations applied', () async {
      final gateway = TestGateway();
      final database = Database(gateway);
      await database.migrate(source);
      expect(gateway.appliedVersions, equals(['01', '02', '03']));
    });

    test('Can start from current version', () async {
      final gateway = TestGateway()..appliedMigrations.add(Migration('01', ''));
      final database = Database(gateway);
      await database.migrate(source);
      expect(gateway.appliedVersions, equals(['01', '02', '03']));
    });

    test('Throws when migrations come out of order', () async {
      final database = Database(TestGateway());
      expect(() async {
        await database.migrate(MockSource(
            first: Migration('02', 'Version 02'),
            next: Migration('01', 'Version 01')));
      }, throwsStateError);
    });
  });
}
