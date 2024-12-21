import 'package:flutter/material.dart';

import 'package:habi_lite/pages/archive/archive_state.dart';
import 'package:habi_lite/utils/get_l10n.dart';
import 'package:habi_lite/widgets/habit_widget.dart';

class ArchivePage extends StatelessWidget {
  final ArchiveState state;
  const ArchivePage(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.archivedHabits),
      ),
      body: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          final habits = state.habits;
          if (habits == null) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
          if (habits.isEmpty) {
            return Center(
              child: Icon(
                Icons.archive,
                color: theme.colorScheme.surfaceContainerHighest,
                size: 128,
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: habits.length,
            itemBuilder: (context, i) => HabitWidget(
              habit: habits[i].habit,
              achieved: habits[i].achieved,
              index: i,
              onUnArchive: () =>
                  state.unarchive(context, habits[i].habit.databaseId!),
              onDelete: () =>
                  state.delete(context, habits[i].habit.databaseId!),
            ),
          );
        },
      ),
    );
  }
}
