import 'dart:io';

import 'package:migrant/migrant.dart';
import 'package:test/test.dart';

void main() {
  test('All migrations applied', () async {
    final gateway = TestGateway();
    final database = Database(gateway);
    await database.migrate(LocalDirectory(
        Directory('test/migrations'), FileNameFormat(RegExp(r'\d{4}'))));
    expect(
        gateway._log,
        equals([
          '0000:create foo:create table foo (id text not null);',
          '0001:alter foo:alter table foo add column name text;',
          '0002:drop foo:drop table foo;',
        ]));
    expect(await gateway.currentVersion(), equals('0002'));
  });

  test('Can start from current version', () async {
    final gateway = TestGateway(version: '0000');
    final database = Database(gateway);
    await database.migrate(LocalDirectory(
        Directory('test/migrations'), FileNameFormat(RegExp(r'\d{4}'))));
    expect(
        gateway._log,
        equals([
          '0001:alter foo:alter table foo add column name text;',
          '0002:drop foo:drop table foo;',
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
            matchedFile.match.isGreaterThan(afterVersion))
        .toList();
    matchedFiles.sort();

    for (final file in matchedFiles) {
      yield await file.toMigration();
    }
  }
}

class MatchedFile implements Comparable<MatchedFile> {
  MatchedFile(this._file, this.match);

  final File _file;

  final FileNameMatch match;

  @override
  int compareTo(MatchedFile other) => match.compareTo(other.match);

  bool isVersionGreaterThan(String other) => match.isGreaterThan(other);

  Future<Migration> toMigration() async =>
      Migration(match.version, await _file.readAsString(),
          summary: match.summary);
}

/// Defines the format of the file name.
class FileNameFormat {
  FileNameFormat(this._versionFormat, {String extension = '.sql'})
      : _extension = extension;

  final RegExp _versionFormat;

  final String _extension;

  /// Matches the [name] against the format,
  /// returns a [FileNameMatch] if successful.
  FileNameMatch? match(String name) {
    if (!name.endsWith(_extension)) return null;
    final version = _versionFormat.matchAsPrefix(name)?.group(0);
    if (version == null) return null;
    final start = version.length;
    final end = name.length - _extension.length;
    final summary = name.substring(start, end).replaceAll('_', ' ').trim();
    return FileNameMatch(version, summary);
  }
}

/// A format match on a file name.
class FileNameMatch implements Comparable<FileNameMatch> {
  FileNameMatch(this.version, this.summary) {
    if (version.isEmpty) throw ArgumentError('Version must not be empty');
  }

  /// Migration version.
  final String version;

  /// Migration summary.
  final String summary;

  @override
  int compareTo(FileNameMatch other) => version.compareTo(other.version);

  bool isGreaterThan(String other) => version.compareTo(other) > 0;
}

class TestGateway extends DatabaseGateway {
  TestGateway({String? version = null}) {
    _version = version;
  }

  String? _version;

  @override
  Future<String?> currentVersion() async => _version;

  @override
  Future<void> apply(Migration migration) async {
    _version = migration.version;
    _log.add(
        '${migration.version}:${migration.summary}:${migration.statement}');
  }

  final _log = <String>[];
}

class TestMigrationSource implements MigrationSource {
  TestMigrationSource(Iterable<Migration> migrations)
      : _migrations = Stream.fromIterable(migrations);

  final Stream<Migration> _migrations;

  @override
  Stream<Migration> read({String? afterVersion = null}) => _migrations;
}
