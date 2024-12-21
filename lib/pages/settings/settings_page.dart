import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:habi_lite/config/app_constants.dart';
import 'package:habi_lite/pages/settings/settings_state.dart';
import 'package:habi_lite/utils/get_l10n.dart';

class SettingsPage extends StatelessWidget {
  final SettingsState state;

  const SettingsPage(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settings),
      ),
      body: ListView(
        children: [
          ValueListenableBuilder(
            valueListenable: state.appState.themeMode,
            builder: (context, themeMode, _) {
              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: SegmentedButton<ThemeMode>(
                  selected: {themeMode},
                  onSelectionChanged: (selected) =>
                      state.appState.setThemeMode(selected.single),
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text(context.l10n.light),
                      icon: const Icon(Icons.light_mode_outlined),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text(context.l10n.dark),
                      icon: const Icon(Icons.dark_mode_outlined),
                    ),
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text(context.l10n.system),
                      icon: const Icon(Icons.auto_mode_outlined),
                    ),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Material(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12.0),
              clipBehavior: Clip.hardEdge,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(context.l10n.archivedHabits),
                    leading: const Icon(Icons.archive_outlined),
                    onTap: () => context.go('/settings/archive'),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Material(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12.0),
              clipBehavior: Clip.hardEdge,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(
                      context.l10n.appDataSettings,
                      style: TextStyle(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(context.l10n.importData),
                    leading: const Icon(Icons.upload_outlined),
                    onTap: () => state.importAppData(context),
                  ),
                  ListTile(
                    title: Text(context.l10n.exportData),
                    leading: const Icon(Icons.download_outlined),
                    onTap: () => state.exportAppData(context),
                  ),
                  ListTile(
                    iconColor: theme.colorScheme.error,
                    textColor: theme.colorScheme.error,
                    title: Text(context.l10n.resetData),
                    leading: const Icon(Icons.delete_forever_outlined),
                    onTap: () => state.deleteAppData(context),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Material(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12.0),
              clipBehavior: Clip.hardEdge,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(
                      context.l10n.info,
                      style: TextStyle(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(context.l10n.sourceCode),
                    leading: const Icon(Icons.source_outlined),
                    onTap: () => launchUrlString(AppConstants.sourceCodeUrl),
                  ),
                  ListTile(
                    title: Text(context.l10n.licenses),
                    leading: const Icon(Icons.gavel_outlined),
                    onTap: () => showLicensePage(
                      context: context,
                      applicationName: AppConstants.applicationName,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
