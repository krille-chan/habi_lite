import 'package:go_router/go_router.dart';

import 'package:habi_lite/models/app_state.dart';
import 'package:habi_lite/pages/archive/archive_page.dart';
import 'package:habi_lite/pages/archive/archive_state.dart';
import 'package:habi_lite/pages/home/home_page.dart';
import 'package:habi_lite/pages/home/home_state.dart';
import 'package:habi_lite/pages/settings/settings_page.dart';
import 'package:habi_lite/pages/settings/settings_state.dart';

GoRouter buildRouter(AppState appState) => GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => HomePage(HomeState(appState)),
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) =>
                  SettingsPage(SettingsState(appState)),
              routes: [
                GoRoute(
                  path: '/archive',
                  builder: (context, state) =>
                      ArchivePage(ArchiveState(appState)),
                ),
              ],
            ),
          ],
        ),
      ],
    );
