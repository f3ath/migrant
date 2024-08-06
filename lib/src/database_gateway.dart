import 'package:migrant/src/migration.dart';

/// A gateway to the actual database.
abstract class DatabaseGateway {
  /// Initialize the DB by applying the [migration]. The DB MUST be fresh, e.g. no version defined.
  /// If the DB is not fresh, this method MUST throw an exception.
  /// All migration statements MUST be executed in a single transaction.
  Future<void> initialize(Migration migration);

  /// Applies the [migration] if the current version is [fromVersion].
  /// If the current DB version is not [fromVersion], this method MUST throw an exception.
  /// All migration statements MUST be executed in a single transaction.
  Future<void> upgrade(String fromVersion, Migration migration);

  /// Returns the current version or null if the version is not yet defined.
  Future<String?> currentVersion();
}
