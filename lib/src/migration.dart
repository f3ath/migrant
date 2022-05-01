/// An atomic migration.
class Migration {
  Migration(this.version, this.statement);

  /// The migration version.
  final String version;

  /// The statement to execute.
  final String statement;
}
