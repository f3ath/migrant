import 'package:migrant/src/migration.dart';

/// A gateway to the actual database.
abstract class DatabaseGateway {
  /// Applies the [migration] and records the new version.
  Future<void> apply(Migration migration);

  /// Applies the [migration] if the current version is [expectedCurrentVersion].
  Future<void> upgrade(Migration migration, String expectedCurrentVersion);

  /// Returns the current version or null if the version is not yet defined.
  Future<String?> currentVersion();
}
