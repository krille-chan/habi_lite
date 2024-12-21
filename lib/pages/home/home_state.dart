import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:habi_lite/models/app_state.dart';
import 'package:habi_lite/models/habit_achieved.dart';
import 'package:habi_lite/utils/get_l10n.dart';
import 'package:habi_lite/utils/same_day_extension.dart';
import 'package:habi_lite/widgets/habit_edit_bottom_sheet/habit_edit_bottom_sheet.dart';
import 'package:habi_lite/widgets/habit_edit_bottom_sheet/habit_edit_state.dart';
import '../../models/habit.dart';

class HomeState extends ChangeNotifier {
  final AppState appState;

  List<({Habit habit, List<HabitAchieved> achieved})>? habits;
  bool reordering = false;

  HomeState(this.appState) {
    _loadHabits();
  }

  void _loadHabits() async {
    habits = await appState.getAllHabits();
    notifyListeners();
  }

  void createHabit(BuildContext context) async {
    final habitIntent = await showDialog<SaveHabitIntent>(
      context: context,
      builder: (context) => HabitEditBottomSheet(HabitEditState()),
    );
    if (habitIntent == null) return;
    if (!context.mounted) return;

    await appState.createHabit(habitIntent.habit);
    _loadHabits();
  }

  void editHabit(BuildContext context, Habit initialHabit) async {
    final habitIntent = await showDialog<HabitIntent>(
      context: context,
      builder: (context) => HabitEditBottomSheet(
        HabitEditState(
          initialHabit: initialHabit,
        ),
      ),
    );
    if (habitIntent == null) return;
    if (!context.mounted) return;

    if (habitIntent is ArchiveHabitIntent) {
      await appState.setHabitArchived(initialHabit.databaseId!, true);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.habitArchived)));
    } else if (habitIntent is SaveHabitIntent) {
      await appState.updateHabit(habitIntent.habit);
    }
    _loadHabits();
  }

  void pickDateAndSetAchieved(BuildContext context, Habit habit) async {
    final now = DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365 * 100)),
      lastDate: now,
      confirmText: context.l10n.changeEntry,
      helpText: habit.title,
      initialDate: now,
    );
    if (newDate == null) return;
    if (!context.mounted) return;

    HapticFeedback.heavyImpact();
    final deleted = await appState.deleteHabitAchieved(
      habit.databaseId!,
      newDate,
    );
    if (!deleted) {
      await appState.createHabitAchieved(
        HabitAchieved(
          createdAt: newDate,
          habitId: habit.databaseId!,
        ),
      );
    }
    _loadHabits();
  }

  void setAchieved(int habitId, {DateTime? date}) async {
    date ??= DateTime.now().dateOnly;
    HapticFeedback.heavyImpact();
    await appState.createHabitAchieved(
      HabitAchieved(
        createdAt: date,
        habitId: habitId,
      ),
    );
    _loadHabits();
  }

  void removeAchieved(int habitId, {DateTime? date}) async {
    date ??= DateTime.now().dateOnly;
    HapticFeedback.mediumImpact();
    await appState.deleteHabitAchieved(
      habitId,
      date,
    );
    _loadHabits();
  }

  void toggleReordering() {
    reordering = !reordering;
    notifyListeners();
  }

  void onReorder(int oldIndex, int newIndex) async {
    final habits = this.habits!;

    if (newIndex > oldIndex) newIndex--;
    if (oldIndex == newIndex) return;

    final from = habits[oldIndex].habit;
    final to = habits[newIndex].habit;

    habits.insert(newIndex, habits.removeAt(oldIndex));

    this.habits = habits;

    await appState.changeHabitOrders(from, to);
    _loadHabits();
  }
}
