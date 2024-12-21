import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:habi_lite/pages/home/home_state.dart';
import 'package:habi_lite/utils/get_l10n.dart';
import 'package:habi_lite/widgets/habit_widget.dart';

class HomePage extends StatelessWidget {
  final HomeState state;
  const HomePage(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.applicationName),
        actions: [
          IconButton(
            onPressed: state.toggleReordering,
            icon: ListenableBuilder(
              listenable: state,
              builder: (context, _) => Icon(
                state.reordering ? Icons.close : Icons.sort_outlined,
              ),
            ),
          ),
          IconButton(
            onPressed: () => context.go('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
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
              child: FloatingActionButton.extended(
                onPressed: () => state.createHabit(context),
                label: Text(context.l10n.newHabit),
                icon: const Icon(Icons.edit_outlined),
              ),
            );
          }
          if (state.reordering) {
            return ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              onReorder: state.onReorder,
              itemCount: habits.length,
              proxyDecorator: (child, i, __) => HabitWidget(
                key: ValueKey(habits[i].habit.databaseId),
                habit: habits[i].habit,
                achieved: habits[i].achieved,
                index: i,
                reordering: true,
                flying: true,
              ),
              itemBuilder: (context, i) => HabitWidget(
                key: ValueKey(habits[i].habit.databaseId),
                habit: habits[i].habit,
                achieved: habits[i].achieved,
                index: i,
                reordering: true,
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
              pickDateForAchieved: () => state.pickDateAndSetAchieved(
                context,
                habits[i].habit,
              ),
              onEdit: () => state.editHabit(context, habits[i].habit),
              setAchieved: (achieved) => achieved
                  ? state.setAchieved(habits[i].habit.databaseId!)
                  : state.removeAchieved(habits[i].habit.databaseId!),
            ),
          );
        },
      ),
      floatingActionButton: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          if (state.habits?.isEmpty ?? true) return const SizedBox.shrink();
          return FloatingActionButton(
            onPressed: () => state.createHabit(context),
            child: const Icon(Icons.edit_outlined),
          );
        },
      ),
    );
  }
}
