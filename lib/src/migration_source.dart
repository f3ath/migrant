import 'package:migrant/src/migration.dart';

abstract interface class MigrationSource {
  /// Returns the initial migration to be applied to a fresh database.
  Future<Migration> getInitial();

  /// Returns the next migration after the [version].
  /// Returns `null` if the [version] is the last.
  Future<Migration?> getNext(String version);
}
