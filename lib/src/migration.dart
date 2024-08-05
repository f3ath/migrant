/// An atomic migration.
class Migration {
  Migration(this.version, this.statements);

  /// The migration version.
  final String version;

  /// The statements to execute.
  final List<String> statements;
}
