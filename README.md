# Database schema migration tool for Dart

A super simple tool which reads the migrations from some source (e.g. from the local file system)
and applies them to a database (e.g. PostgreSQL or SQLite). Nothing fancy.

Supported migrations sources:
- In-memory (included with this package)
- Local file system ([migrant_source_fs](https://pub.dev/packages/migrant_source_fs))

Supported database engines:
- SQLite ([migrant_db_sqlite](https://pub.dev/packages/migrant_db_sqlite))
- PostgreSQL ([migrant_db_postgresql](https://pub.dev/packages/migrant_db_postgresql))

Example:
```dart
import 'dart:io';

import 'package:migrant/migrant.dart';
import 'package:migrant_db_sqlite/migrant_db_sqlite.dart';
import 'package:migrant_source_fs/migrant_source_fs.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Database;

Future<void> main() async {
  // Migration files must start with 4 digits which define the version.
  final fileNameFormat = FileNameFormat(RegExp(r'\d{4}'));

  // Reading migrations from this directory.
  // Try adding more migrations in there!
  final directory = Directory('example/migrations');

  // Migration source.
  final migrations = LocalDirectory(directory, fileNameFormat);

  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
  }

  // This is where the database file is placed.
  print("Database path:${await databaseFactoryFfi.getDatabasesPath()}");

  // The SQLite connection. We're using a local file.
  var connection = await databaseFactoryFfi.openDatabase('example.db');

  // The gateway is provided by this package.
  final gateway = SQLiteGateway(connection);

  // Extra capabilities may be added like this. See the implementation below.
  final loggingGateway = LoggingGatewayWrapper(gateway);

  // Applying migrations.
  await Database(loggingGateway).migrate(migrations);

  // At this point the table "foo" is ready.
  await connection.insert('test', {
    'id': DateTime.now().toIso8601String(),
    'foo': 'hello',
    'bar': 'world',
  });

  // See some data inserted.
  print(await connection.query('test'));
}

// Compose everything!
class LoggingGatewayWrapper implements DatabaseGateway {
  LoggingGatewayWrapper(this.gateway);

  final DatabaseGateway gateway;

  @override
  Future<void> apply(Migration migration) async {
    print('Applying version ${migration.version}...');
    await gateway.apply(migration);
    print('Version ${migration.version} has been applied.');
  }

  @override
  Future<String?> currentVersion() async {
    final version = await gateway.currentVersion();
    print('The database is at version $version.');
    return version;
  }
}

```