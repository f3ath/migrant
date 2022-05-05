import 'package:migrant/migrant.dart';
import 'package:migrant/src/in_memory.dart';
import 'package:migrant/testing.dart';
import 'package:test/test.dart';

void main() {
  final source = InMemory({
    '01': 'Version 01',
    '02': 'Version 02',
    '03': 'Version 03',
  });

  test('All migrations applied', () async {
    final gateway = TestGateway();
    final database = Database(gateway);
    await database.migrate(source);
    expect(gateway.appliedVersions, equals(['01', '02', '03']));
  });

  test('Can start from current version', () async {
    final gateway = TestGateway(initialVersion: '01');
    final database = Database(gateway);
    await database.migrate(source);
    expect(gateway.appliedVersions, equals(['02', '03']));
  });

  test('Throws when migrations come out of order', () async {
    final database = Database(TestGateway());
    expect(() async {
      await database.migrate(AsIs([
        Migration('2', ''),
        Migration('1', ''),
      ]));
    }, throwsStateError);
  });
}
