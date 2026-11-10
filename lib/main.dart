import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/database/app_database.dart';
import 'core/services/app_services.dart';
import 'data/levels/level_catalog.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final prefs = await SharedPreferences.getInstance();
  final catalog = await LevelCatalog.load();
  runApp(ProviderScope(
    overrides: [prefsProvider.overrideWithValue(prefs), catalogProvider.overrideWithValue(catalog), databaseProvider.overrideWithValue(AppDatabase())],
    child: const EasterJigsawApp(),
  ));
}
