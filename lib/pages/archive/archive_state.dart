import 'package:flutter/material.dart';

import 'package:habi_lite/models/app_state.dart';
import 'package:habi_lite/models/habit.dart';
import 'package:habi_lite/models/habit_achieved.dart';
import 'package:habi_lite/utils/get_l10n.dart';

class ArchiveState extends ChangeNotifier {
  final AppState appState;
  List<({Habit habit, List<HabitAchieved> achieved})>? habits;

  ArchiveState(this.appState) {
    _loadHabits();
  }

  void _loadHabits() async {
    habits = await appState.getAllHabits(archived: true);
    notifyListeners();
  }

  void unarchive(BuildContext context, int id) async {
    await appState.setHabitArchived(id, false);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.l10n.habitRestored)));
    _loadHabits();
  }

  void delete(BuildContext context, int id) async {
    await appState.deleteHabit(id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.l10n.habitDeleted)));
    _loadHabits();
  }
}
