/// An atomic migration.
class Migration {
  const Migration(this.version, this.statement);

  /// The migration version.
  final String version;

  /// The statement to execute.
  final String statement;
}
