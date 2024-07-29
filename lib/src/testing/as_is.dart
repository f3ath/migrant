import 'package:migrant/src/migration.dart';
import 'package:migrant/src/migration_source.dart';

/// Unsorted dumb source which does not respect version order.
/// Useful for testing error scenarios.
class AsIs implements MigrationSource {
  AsIs(this._migrations);

  final Iterable<Migration> _migrations;

  /// Returns the migrations as-is, regardless of the version order.
  /// Ignores [afterVersion] argument.
  @override
  Stream<Migration> read({String? afterVersion}) =>
      Stream.fromIterable(_migrations);
}
