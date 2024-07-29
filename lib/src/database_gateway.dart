import 'package:migrant/src/migration.dart';

/// A gateway to the actual database.
abstract class DatabaseGateway {
  /// Applies the [migration] and records its version.
  /// If [assertCurrentVersion] is passed, the gateway should only apply the
  /// migration if the current version matches the [assertCurrentVersion].
  Future<void> apply(Migration migration, {String? assertCurrentVersion});

  /// Returns the current version or null if the version is not yet defined.
  Future<String?> currentVersion();
}
