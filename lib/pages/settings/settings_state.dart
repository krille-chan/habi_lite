import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';

import 'package:habi_lite/config/app_constants.dart';
import 'package:habi_lite/models/app_state.dart';
import 'package:habi_lite/utils/get_l10n.dart';
import 'package:habi_lite/widgets/adaptive_dialog_button.dart';

class SettingsState extends ChangeNotifier {
  final AppState appState;

  SettingsState(this.appState);

  void importAppData(BuildContext context) async {
    final picked = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      allowedExtensions: ['json', 'JSON'],
      type: FileType.custom,
      withData: true,
    );
    final file = picked?.xFiles.firstOrNull;
    if (file == null) return;
    if (!context.mounted) return;
    try {
      final count = await appState
          .importDataFromJson(jsonDecode(await file.readAsString()));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.importedCountDataSets(count))),
      );
    } catch (e, _) {
      if (!context.mounted) {
        showAdaptiveDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) => AlertDialog.adaptive(
            title: Text(context.l10n.errorWhileImportingData),
            content: Text(e.toString()),
            actions: [
              AdaptiveDialogButton(
                onPressed: context.pop,
                label: context.l10n.cancel,
              ),
            ],
          ),
        );
      }
      rethrow;
    }
  }

  void exportAppData(BuildContext context) async {
    final jsonData = await appState.exportDataAsJson();
    await FilePicker.platform.saveFile(
      fileName:
          '${AppConstants.applicationName} Backup ${DateTime.now().toIso8601String()}.json',
      allowedExtensions: ['json', 'JSON'],
      bytes: Uint8List.fromList(utf8.encode(jsonData)),
    );
  }

  void deleteAppData(BuildContext context) async {
    final consent = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(context.l10n.resetData),
        content: Text(context.l10n.resetDataWarning),
        actions: [
          AdaptiveDialogButton(
            onPressed: () => context.pop<bool>(true),
            label: context.l10n.resetData,
            isDestructive: true,
          ),
          AdaptiveDialogButton(
            onPressed: () => context.pop<bool>(false),
            label: context.l10n.cancel,
          ),
        ],
      ),
    );
    if (consent != true) return;
    if (!context.mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final title = context.l10n.allDataHasBeenReset;
    await appState.resetAllData();
    scaffoldMessenger.showSnackBar(SnackBar(content: Text(title)));
  }
}
