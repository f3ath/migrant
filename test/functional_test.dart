import 'dart:io';

import 'package:migrant/migrant.dart';
import 'package:migrant/testing.dart';
import 'package:migrant_source_fs/migrant_source_fs.dart';
import 'package:test/test.dart';

void main() {
  test('All migrations applied', () async {
    final gateway = TestGateway();
    final database = Database(gateway);
    await database.migrate(LocalDirectory(
        Directory('test/migrations'), FileNameFormat(RegExp(r'\d{4}'))));
    expect(
        gateway.log,
        equals([
          '0000:create table foo (id text not null);',
          '0001:alter table foo add column name text;',
          '0002:drop table foo;',
        ]));
    expect(await gateway.currentVersion(), equals('0002'));
  });

  test('Can start from current version', () async {
    final gateway = TestGateway(version: '0000');
    final database = Database(gateway);
    await database.migrate(LocalDirectory(
        Directory('test/migrations'), FileNameFormat(RegExp(r'\d{4}'))));
    expect(
        gateway.log,
        equals([
          '0001:alter table foo add column name text;',
          '0002:drop table foo;',
        ]));
    expect(await gateway.currentVersion(), equals('0002'));
  });

  test('Throws when migrations come out of order', () async {
    final database = Database(TestGateway());
    expect(() async {
      await database.migrate(TestMigrationSource([
        Migration('2', ''),
        Migration('1', ''),
      ]));
    }, throwsStateError);
  });
}
