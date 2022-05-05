import 'package:migrant/src/migration.dart';

/// A source of migration data.
abstract class MigrationSource {
  /// Streams the migrations ordered by version, ascending.
  /// If [afterVersion] is passed, all migrations with versions less or
  /// equal to it will be skipped.
  Stream<Migration> read({String? afterVersion});
}
