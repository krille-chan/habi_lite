import 'package:flutter/widgets.dart';

import 'package:sqflite/sqflite.dart';

Future<void> createSchema(Database database) =>
    database.transaction((transaction) async {
      for (final table in DatabaseTables.values) {
        await transaction.execute(
          'CREATE TABLE IF NOT EXISTS ${table.name} ${table.creationQueryColumns}',
        );
      }
    });

enum DatabaseTables {
  habit(
    '(id INTEGER PRIMARY KEY, title TEXT NO NULL, description TEXT, createdAt INTEGER NOT NULL, sortOrder INTEGER NOT NULL, archivedAt INTEGER, color STRING NOT NULL)',
  ),
  habitAchieved(
    '(id INTEGER PRIMARY KEY, habitId INTEGER NOT NULL, createdAt INTEGER NOT NULL)',
  ),
  ;

  const DatabaseTables(this.creationQueryColumns);

  final String creationQueryColumns;
}

Future<void> upgradeSchema(
  Database database,
  int oldVersion,
  int newVersion,
) async {
  debugPrint('Upgrade Database from version $oldVersion to $newVersion');
  // TODO: Implement database migration
}
