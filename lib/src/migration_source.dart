import 'package:migrant/src/migration.dart';

abstract interface class MigrationSource {
  /// Returns the first migration.
  Future<Migration?> getFirst();

  /// Returns the next migration after the [currentVersion].
  Future<Migration?> getNext(String currentVersion);
}
