# Database schema migration tool for Dart

A super simple tool which reads the migrations from a source (e.g. from the local file system)
and applies them to a database (e.g. PostgreSQL or SQLite). Nothing fancy.

Supported migrations sources:
- In-memory (included with this package)
- Local file system ([migrant_source_fs](https://pub.dev/packages/migrant_source_fs))

Supported database engines:
- SQLite ([migrant_db_sqlite](https://pub.dev/packages/migrant_db_sqlite))
- PostgreSQL ([migrant_db_postgresql](https://pub.dev/packages/migrant_db_postgresql))

Please see the usage examples in the above packages.
