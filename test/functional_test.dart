import 'dart:io';

import 'package:migrant/migrant.dart';
import 'package:migrant/testing.dart';
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

/// Reads migrations from a local filesystem.
class LocalDirectory extends MigrationSource {
  LocalDirectory(this._dir, this._format);

  final Directory _dir;
  final FileNameFormat _format;

  Stream<Migration> read({String? afterVersion = null}) async* {
    final entries = await _dir.list().toList();
    final matchedFiles = entries
        .whereType<File>()
        .map((file) {
          final name = file.uri.pathSegments.last;
          final match = _format.match(name);
          if (match == null) return null;
          return MatchedFile(file, match);
        })
        .whereType<MatchedFile>()
        .where((matchedFile) =>
            afterVersion == null ||
            matchedFile.version.compareTo(afterVersion) > 0)
        .toList();
    matchedFiles.sort();

    for (final file in matchedFiles) {
      yield await file.toMigration();
    }
  }
}

class MatchedFile implements Comparable<MatchedFile> {
  MatchedFile(this._file, this.version);

  final File _file;

  final String version;

  @override
  int compareTo(MatchedFile other) => version.compareTo(other.version);

  Future<Migration> toMigration() async =>
      Migration(version, await _file.readAsString());
}

/// Defines the format of the file name.
class FileNameFormat {
  FileNameFormat(this._versionFormat, {String extension = '.sql'})
      : _extension = extension;

  final RegExp _versionFormat;

  final String _extension;

  /// Matches the [name] against the format,
  /// returns a [FileNameMatch] if successful.
  String? match(String name) {
    if (!name.endsWith(_extension)) return null;
    return _versionFormat.matchAsPrefix(name)?.group(0);
  }
}
