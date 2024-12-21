import 'package:flutter/material.dart';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:habi_lite/config/app_constants.dart';
import 'package:habi_lite/config/app_theme.dart';
import 'package:habi_lite/models/app_state.dart';

class HabiLiteApp extends StatelessWidget {
  final AppState appState;
  final GoRouter router;

  const HabiLiteApp({required this.appState, required this.router, super.key});
  static final GlobalKey routerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (light, dark) => ValueListenableBuilder(
        valueListenable: appState.themeMode,
        builder: (context, themeMode, _) {
          return MaterialApp.router(
            key: routerKey,
            title: AppConstants.applicationName,
            routerConfig: router,
            theme: buildTheme(
              Brightness.light,
              light?.primary,
            ),
            darkTheme: buildTheme(
              Brightness.dark,
              dark?.primary,
            ),
            themeMode: themeMode,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          );
        },
      ),
    );
  }
}
