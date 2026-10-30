import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/settings_store.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = SettingsStore();
  await store.load();
  runApp(RepFlowApp(store: store));
}

class RepFlowApp extends StatelessWidget {
  const RepFlowApp({super.key, required this.store});

  final SettingsStore store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rep Flow',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      home: HomeScreen(store: store),
    );
  }
}
