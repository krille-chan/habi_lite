import 'package:flutter/material.dart';

import 'package:habi_lite/models/habit.dart';
import 'package:habi_lite/models/habit_achieved.dart';
import 'package:habi_lite/utils/same_day_extension.dart';

class HabitWidget extends StatelessWidget {
  final Habit habit;
  final List<HabitAchieved> achieved;
  final bool reordering;
  final int index;
  final void Function(bool)? setAchieved;
  final void Function()? pickDateForAchieved;
  final void Function()? onEdit;
  final void Function()? onUnArchive;
  final void Function()? onDelete;
  final bool flying;

  const HabitWidget({
    required this.habit,
    required this.achieved,
    required this.index,
    this.setAchieved,
    this.pickDateForAchieved,
    this.onEdit,
    this.reordering = false,
    this.flying = false,
    this.onUnArchive,
    this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final description = habit.description;
    final theme = Theme.of(context);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: habit.color,
      brightness: theme.brightness,
    );
    final setAchieved = this.setAchieved;
    final today = DateTime.now().dateOnly;
    const dayTileSpacing = 4.0;
    final currentWeek = today.subtract(Duration(days: today.weekday - 1));
    final achievedDates = achieved.map((a) => a.createdAt.toDateInt()).toSet();
    final achievedToday = achievedDates.contains(today.toDateInt());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        clipBehavior: Clip.hardEdge,
        elevation: flying ? 10 : 0,
        shadowColor: theme.colorScheme.surfaceContainerHighest.withAlpha(128),
        color: colorScheme.primaryContainer,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    habit.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (onUnArchive != null)
                  IconButton(
                    style: IconButton.styleFrom(
                      foregroundColor: colorScheme.onPrimaryContainer,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: colorScheme.primaryFixedDim,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onUnArchive,
                    icon: const Icon(Icons.settings_backup_restore_outlined),
                  ),
                if (onDelete != null)
                  IconButton(
                    style: IconButton.styleFrom(
                      foregroundColor: colorScheme.onPrimaryContainer,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: colorScheme.primaryFixedDim,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_forever_outlined),
                  ),
                if (onEdit != null)
                  IconButton(
                    style: IconButton.styleFrom(
                      foregroundColor: colorScheme.onPrimaryContainer,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: colorScheme.primaryFixedDim,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                  ),
                if (setAchieved != null)
                  IconButton(
                    style: IconButton.styleFrom(
                      foregroundColor: colorScheme.onPrimaryContainer,
                      backgroundColor: achievedToday
                          ? colorScheme.primary
                          : colorScheme.surfaceContainerLowest,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: colorScheme.primaryFixedDim,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => setAchieved(!achievedToday),
                    icon: Icon(
                      achievedToday
                          ? Icons.cancel_outlined
                          : Icons.task_alt_rounded,
                      color: achievedToday
                          ? colorScheme.onPrimary
                          : colorScheme.primary,
                    ),
                  ),
                if (reordering)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ReorderableDragStartListener(
                      index: index,
                      child: Icon(
                        Icons.drag_indicator_outlined,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
              ],
            ),
            InkWell(
              onTap: pickDateForAchieved,
              child: SizedBox(
                height: 132,
                child: ListView.builder(
                  reverse: true,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(
                    right: 8.0,
                    bottom: 12.0,
                    top: 12.0,
                  ),
                  itemBuilder: (context, i) {
                    final week = currentWeek.subtract(Duration(days: i * 7));
                    return Column(
                      spacing: dayTileSpacing,
                      verticalDirection: VerticalDirection.up,
                      children: [
                        for (var i = 6; i >= 0; i--)
                          Builder(
                            builder: (context) {
                              final tileDate =
                                  week.add(Duration(days: i)).toDateInt();
                              final achieved = achievedDates.contains(tileDate);
                              return Container(
                                width: 12.0,
                                height: 12.0,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: dayTileSpacing,
                                ),
                                decoration: BoxDecoration(
                                  color: achieved
                                      ? colorScheme.primary
                                      : colorScheme.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              );
                            },
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
            if (description != null)
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 16.0,
                ),
                child: Text(
                  description,
                  style: theme.textTheme.labelSmall,
                  textAlign: TextAlign.left,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
