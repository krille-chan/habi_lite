import 'dart:math';

import 'package:flutter/material.dart';

import 'package:habi_lite/config/app_theme.dart';
import 'package:habi_lite/models/habit.dart';

class HabitEditState extends ChangeNotifier {
  final Habit? initialHabit;

  final TextEditingController titleController = TextEditingController();

  final TextEditingController descriptionController = TextEditingController();

  Color color = habitColors[Random().nextInt(habitColors.length)];

  HabitEditState({this.initialHabit}) {
    final habit = initialHabit;
    if (habit != null) {
      titleController.text = habit.title;
      descriptionController.text = habit.description ?? '';
      color = habit.color;
      canSave = true;
    }
  }

  bool canSave = false;

  void onChangeTitle(String title) {
    final newCanSave = title.trim().isNotEmpty;
    if (canSave == newCanSave) return;
    canSave = newCanSave;
    notifyListeners();
  }

  void updateColor(Color newColor) {
    color = newColor;
    notifyListeners();
  }

  void finish(BuildContext context) => Navigator.of(context).pop<HabitIntent>(
        SaveHabitIntent(
          Habit(
            databaseId: initialHabit?.databaseId,
            title: titleController.text.trim(),
            description: descriptionController.text.isEmpty
                ? null
                : descriptionController.text.trim(),
            createdAt: initialHabit?.createdAt ?? DateTime.now(),
            sortOrder: initialHabit?.sortOrder,
            color: color,
          ),
        ),
      );

  void archive(BuildContext context) =>
      Navigator.of(context).pop<HabitIntent>(ArchiveHabitIntent());
}

abstract class HabitIntent {}

class SaveHabitIntent extends HabitIntent {
  final Habit habit;
  SaveHabitIntent(this.habit) : super();
}

class ArchiveHabitIntent extends HabitIntent {}
