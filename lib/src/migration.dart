/// An atomic migration.
class Migration {
  Migration(this.version, this.statement);

  /// The migration version.
  final String version;

  /// The statement to execute.
  final String statement;

  @override
  bool operator ==(Object other) =>
      other is Migration &&
      other.version == version &&
      other.statement == statement;

  @override
  int get hashCode => version.hashCode;
}
