/// An atomic migration.
class Migration {
  Migration(this.version, this.statement, {this.summary});

  /// The migration version.
  final String version;

  /// The statement to execute.
  final String statement;

  /// A short one-line description.
  final String? summary;
}
