import 'package:flutter/material.dart';

import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'package:habi_lite/models/default_database_item.dart';

class Habit extends DefaultDatabaseItem {
  final String title;
  final String? description;
  final int? sortOrder;
  final DateTime? archivedAt;
  final Color color;

  Habit({
    super.databaseId,
    required super.createdAt,
    required this.title,
    this.description,
    this.sortOrder,
    this.archivedAt,
    required this.color,
  });

  @override
  Map<String, Object?> toDatabaseRow() => {
        ...super.toDatabaseRow(),
        'title': title,
        'description': description,
        'sortOrder': sortOrder,
        'color': color.toHexString(),
      };

  factory Habit.fromDatabaseRow(Map<String, Object?> row) => Habit(
        databaseId: row['id'] as int?,
        title: row['title'] as String,
        description: row['description'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(row['createdAt'] as int),
        sortOrder: row['sortOrder'] as int?,
        archivedAt: row['archivedAt'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(row['archivedAt'] as int),
        color: (row['color'] as String).toColor()!,
      );
}

enum HabitInterval { daily, daysInWeek, daysInMonth, continuesly }
