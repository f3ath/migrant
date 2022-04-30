import 'package:migrant/src/migration.dart';

/// A source of migration data.
abstract class MigrationSource {
  /// Returns all migrations sorted by version ascending.
  ///
  /// If [afterVersion] is provided, only the migrations with the versions
  /// higher than [afterVersion] will be returned.
  Stream<Migration> read({String? afterVersion = null});
}
