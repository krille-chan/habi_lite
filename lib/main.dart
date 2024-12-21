import 'package:flutter/material.dart';

import 'package:habi_lite/config/router.dart';
import 'package:habi_lite/models/app_state.dart';
import 'package:habi_lite/widgets/habi_lite_app.dart';

void main() async {
  debugPrint('Welcome to HabiLite <3');

  WidgetsFlutterBinding.ensureInitialized();

  final appState = await AppState.init();

  runApp(
    HabiLiteApp(
      appState: appState,
      router: buildRouter(appState),
    ),
  );
}
