import 'package:flutter/material.dart';

import 'screens/settings_screen.dart';
import 'services/preferences_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await PreferencesManager.getInstance();

  runApp(SettingsApp(preferences: preferences));
}

class SettingsApp extends StatefulWidget {
  const SettingsApp({
    super.key,
    required this.preferences,
  });

  final PreferencesManager preferences;

  @override
  State<SettingsApp> createState() => _SettingsAppState();
}

class _SettingsAppState extends State<SettingsApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  void _loadTheme() {
    final theme = widget.preferences.getValue<String>('theme') ?? 'system';

    setState(() {
      _themeMode = _parseTheme(theme);
    });
  }

  ThemeMode _parseTheme(String theme) {
    switch (theme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void _changeTheme(String theme) {
    setState(() {
      _themeMode = _parseTheme(theme);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Мої налаштування',
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: SettingsScreen(
        onThemeChanged: _changeTheme,
      ),
    );
  }
}