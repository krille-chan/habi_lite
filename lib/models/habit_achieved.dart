import 'package:habi_lite/models/default_database_item.dart';

class HabitAchieved extends DefaultDatabaseItem {
  final int habitId;

  HabitAchieved({
    super.databaseId,
    required super.createdAt,
    required this.habitId,
  });

  @override
  Map<String, Object?> toDatabaseRow() => {
        ...super.toDatabaseRow(),
        'habitId': habitId,
      };

  factory HabitAchieved.fromDatabaseRow(Map<String, Object?> row) =>
      HabitAchieved(
        databaseId: row['id'] as int?,
        habitId: row['habitId'] as int,
        createdAt: DateTime.fromMillisecondsSinceEpoch(row['createdAt'] as int),
      );
}

enum HabitAchievedValue { achieved, notAchieved }
