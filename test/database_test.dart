import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:habi_lite/models/habit.dart';
import 'package:habi_lite/models/habit_achieved.dart';

void main() {
  test('Test Habit class', () {
    final habit = Habit(
      databaseId: 0,
      createdAt: DateTime.now(),
      title: 'Title',
      sortOrder: 1,
      description: 'Description',
      archivedAt: DateTime.now(),
      color: Colors.blue,
    );
    expect(
      habit.toDatabaseRow(),
      Habit.fromDatabaseRow(habit.toDatabaseRow()).toDatabaseRow(),
    );
  });
  test('Test HabitAchieved class', () {
    final habitAchieved = HabitAchieved(
      databaseId: 0,
      createdAt: DateTime.now(),
      habitId: 0,
    );
    expect(
      habitAchieved.toDatabaseRow(),
      HabitAchieved.fromDatabaseRow(habitAchieved.toDatabaseRow())
          .toDatabaseRow(),
    );
  });
}
