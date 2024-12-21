import 'package:flutter/material.dart';

import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:go_router/go_router.dart';

import 'package:habi_lite/config/app_theme.dart';
import 'package:habi_lite/utils/get_l10n.dart';
import 'package:habi_lite/widgets/habit_edit_bottom_sheet/habit_edit_state.dart';

class HabitEditBottomSheet extends StatelessWidget {
  final HabitEditState state;

  const HabitEditBottomSheet(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const colorPickerSize = 32.0;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Material(
        borderRadius: BorderRadius.circular(16.0),
        clipBehavior: Clip.hardEdge,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close_outlined),
              onPressed: () => context.pop(null),
            ),
            title: Text(context.l10n.newHabit),
            actions: [
              if (state.initialHabit != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    icon: const Icon(Icons.archive_outlined),
                    onPressed: () => state.archive(context),
                  ),
                ),
              ListenableBuilder(
                listenable: state,
                builder: (context, _) => Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    onPressed:
                        state.canSave ? () => state.finish(context) : null,
                    child: Text(context.l10n.save),
                  ),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              TextField(
                controller: state.titleController,
                onChanged: state.onChangeTitle,
                decoration: InputDecoration(
                  labelText: context.l10n.title,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: state.descriptionController,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: context.l10n.description,
                ),
              ),
              const SizedBox(height: 16),
              const ListTile(
                title: Text('Farbe auswählen:'),
                contentPadding: EdgeInsets.zero,
              ),
              ListenableBuilder(
                listenable: state,
                builder: (context, _) => GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 64,
                  ),
                  itemCount: habitColors.length,
                  itemBuilder: (context, i) {
                    final color = habitColors[i];
                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Tooltip(
                        message: '#${color.toHexString().toUpperCase()}',
                        child: InkWell(
                          borderRadius: BorderRadius.circular(32.0),
                          onTap: () => state.updateColor(color),
                          child: Material(
                            color: color,
                            elevation: 1,
                            borderRadius: BorderRadius.circular(32.0),
                            child: SizedBox(
                              width: colorPickerSize,
                              height: colorPickerSize,
                              child: state.color == color
                                  ? Center(
                                      child: Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
