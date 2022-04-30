import 'package:migrant/src/migration.dart';

/// A gateway to the actual database.
abstract class DatabaseGateway {
  /// Applies the migration and records its version.
  Future<void> apply(Migration migration);

  /// Returns the current version or null if the version is not yet defined.
  Future<String?> currentVersion();
}
