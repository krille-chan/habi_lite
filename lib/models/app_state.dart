import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'package:habi_lite/config/app_constants.dart';
import 'package:habi_lite/config/settings_keys.dart';
import 'package:habi_lite/models/database_schema.dart';
import 'package:habi_lite/models/habit.dart';
import 'package:habi_lite/models/habit_achieved.dart';

class AppState {
  final Database _database;
  final SharedPreferences _sharedPreferences;
  final ValueNotifier<ThemeMode> themeMode;

  AppState._({
    required this.themeMode,
    required Database database,
    required SharedPreferences sharedPreferences,
  })  : _database = database,
        _sharedPreferences = sharedPreferences;

  static Future<AppState> init() async {
    final sharedPreferences = await SharedPreferences.getInstance();

    final themeModeSettings =
        sharedPreferences.getString(SettingsKeys.themeMode);
    final themeMode = ThemeMode.values
            .singleWhereOrNull((t) => t.name == themeModeSettings) ??
        ThemeMode.system;

    final directory = await getDatabasesPath();
    final database = await openDatabase(
      path.join(directory, '${AppConstants.applicationName}.sqflite'),
      onOpen: createSchema,
      onUpgrade: upgradeSchema,
      version: 1,
    );

    return AppState._(
      themeMode: ValueNotifier(themeMode),
      database: database,
      sharedPreferences: sharedPreferences,
    );
  }

  void setThemeMode(ThemeMode mode) async {
    await _sharedPreferences.setString(
      'theme_mode',
      mode.name,
    );
    themeMode.value = mode;
  }

  Future<String> exportDataAsJson() async {
    final json = <String, Object?>{};
    for (final table in DatabaseTables.values) {
      json[table.name] = await _database.query(table.name);
    }
    return jsonEncode(json);
  }

  Future<int> importDataFromJson(Map<String, Object?> json) async {
    var counter = 0;
    await _database.transaction((transaction) async {
      for (final table in DatabaseTables.values) {
        final rows = List<Map<String, Object?>>.from(json[table.name] as List);
        for (final row in rows) {
          final result = await transaction.insert(
            table.name,
            row,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          if (result != 0) counter++;
        }
      }
    });
    return counter;
  }

  Future<void> createHabit(Habit habit) async {
    final maxSortOrderResult = await _database.query(
      DatabaseTables.habit.name,
      columns: ['max(sortOrder)'],
    );
    final maxSortOrder =
        (maxSortOrderResult.singleOrNull?['max(sortOrder)'] as int?) ?? 0;

    await _database.insert(
      DatabaseTables.habit.name,
      {
        ...habit.toDatabaseRow(),
        'sortOrder': maxSortOrder + 1,
      },
    );
  }

  Future<List<({Habit habit, List<HabitAchieved> achieved})>> getAllHabits({
    bool archived = false,
  }) async {
    final allHabits = await _database
        .query(
          DatabaseTables.habit.name,
          where: '(archivedAt IS NOT NULL) = ?',
          whereArgs: [archived ? 1 : 0],
          orderBy: 'sortOrder',
        )
        .then(
          (rows) => rows.map((json) => Habit.fromDatabaseRow(json)).toList(),
        );

    final habitAndAchievedMap = <({
      Habit habit,
      List<HabitAchieved> achieved,
    })>[];

    for (final habit in allHabits) {
      habitAndAchievedMap.add(
        (
          habit: habit,
          achieved: await _database
              .query(
                DatabaseTables.habitAchieved.name,
                where: 'habitId = ?',
                whereArgs: [
                  habit.databaseId,
                ],
                orderBy: 'createdAt DESC',
              )
              .then(
                (rows) => rows
                    .map((row) => HabitAchieved.fromDatabaseRow(row))
                    .toList(),
              ),
        ),
      );
    }

    return habitAndAchievedMap;
  }

  Future<void> updateHabit(Habit habit) => _database.update(
        DatabaseTables.habit.name,
        habit.toDatabaseRow(),
        where: 'id = ?',
        whereArgs: [habit.databaseId],
      );

  Future<void> setHabitArchived(int id, bool archived) => _database.update(
        DatabaseTables.habit.name,
        {'archivedAt': archived ? DateTime.now().millisecondsSinceEpoch : null},
        where: 'id = ?',
        whereArgs: [id],
      );

  Future<void> deleteHabit(int id) => _database.transaction((db) async {
        db.delete(
          DatabaseTables.habit.name,
          where: 'id = ?',
          whereArgs: [id],
        );
        db.delete(
          DatabaseTables.habitAchieved.name,
          where: 'habitId = ?',
          whereArgs: [id],
        );
      });

  Future<void> createHabitAchieved(HabitAchieved achieved) => _database.insert(
        DatabaseTables.habitAchieved.name,
        achieved.toDatabaseRow(),
      );

  Future<bool> deleteHabitAchieved(int habitId, DateTime date) =>
      _database.delete(
        DatabaseTables.habitAchieved.name,
        where: 'habitId = ? AND createdAt >= ? AND createdAt < ?',
        whereArgs: [
          habitId,
          date.millisecondsSinceEpoch,
          date.add(const Duration(days: 1)).millisecondsSinceEpoch,
        ],
      ).then((rowsAffected) => rowsAffected > 0);

  Future<void> changeHabitOrders(Habit from, Habit to) => _changeSortOrders(
        DatabaseTables.habit.name,
        from.databaseId!,
        to.databaseId!,
        from.sortOrder!,
        to.sortOrder!,
      );

  Future<void> _changeSortOrders(
    String table,
    int fromDatabaseId,
    int toDatabaseId,
    int fromSortOrder,
    int toSortOrder,
  ) {
    assert(fromDatabaseId != toDatabaseId);

    return _database.transaction((transaction) async {
      if (toSortOrder > fromSortOrder) {
        await transaction.rawUpdate(
          'UPDATE $table SET sortOrder = sortOrder-1 WHERE sortOrder <= ?',
          [toSortOrder],
        );
      } else {
        await transaction.rawUpdate(
          'UPDATE $table SET sortOrder = sortOrder+1 WHERE sortOrder >= ?',
          [toSortOrder],
        );
      }
      await transaction.update(
        table,
        {'sortOrder': toSortOrder},
        where: 'id = ?',
        whereArgs: [fromDatabaseId],
      );
    });
  }

  Future<void> resetAllData() => _database.transaction(
        (transaction) => Future.wait(
          DatabaseTables.values.map((db) => transaction.delete(db.name)),
        ),
      );
}
