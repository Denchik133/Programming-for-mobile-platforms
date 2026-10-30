import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  PreferencesManager._();

  static PreferencesManager? _instance;
  static SharedPreferences? _prefs;

  static Future<PreferencesManager> getInstance() async {
    if (_instance == null) {
      _instance = PreferencesManager._();
      _prefs = await SharedPreferences.getInstance();
    }

    return _instance!;
  }

  // Типові налаштування
  static const Map<String, dynamic> defaults = {
    'name': '',
    'email': '',
    'age': 18,
    'theme': 'system',
    'fontSize': 16.0,
    'language': 'Українська',
    'compactMode': false,
    'pushNotifications': true,
    'emailNotifications': true,
    'sounds': true,
    'reminderFrequency': 1,
    'registrationDate': '',
    'favoriteCategories': <String>[],
  };

  // CREATE / UPDATE: збереження значення
  Future<bool> saveValue(String key, dynamic value) async {
    try {
      switch (value) {
        case String():
          return await _prefs!.setString(key, value);
        case int():
          return await _prefs!.setInt(key, value);
        case double():
          return await _prefs!.setDouble(key, value);
        case bool():
          return await _prefs!.setBool(key, value);
        case List<String>():
          return await _prefs!.setStringList(key, value);
        default:
          throw ArgumentError('Непідтримуваний тип даних: ${value.runtimeType}');
      }
    } catch (e) {
      throw Exception('Не вдалося зберегти "$key": $e');
    }
  }

  // READ: отримання значення
  T? getValue<T>(String key) {
    try {
      return _prefs!.get(key) as T?;
    } catch (e) {
      throw Exception('Не вдалося прочитати "$key": $e');
    }
  }

  // READ: отримання всіх налаштувань
  Map<String, dynamic> getAll() {
    try {
      final result = <String, dynamic>{};

      for (final key in defaults.keys) {
        result[key] = _prefs!.get(key) ?? defaults[key];
      }

      return result;
    } catch (e) {
      throw Exception('Не вдалося завантажити налаштування: $e');
    }
  }

  // DELETE: видалення одного значення
  Future<bool> deleteValue(String key) async {
    try {
      return await _prefs!.remove(key);
    } catch (e) {
      throw Exception('Не вдалося видалити "$key": $e');
    }
  }

  // Видалення всіх збережених налаштувань
  Future<bool> clearAll() async {
    try {
      return await _prefs!.clear();
    } catch (e) {
      throw Exception('Не вдалося очистити налаштування: $e');
    }
  }

  // Скидання до типових налаштувань
  Future<void> resetToDefaults() async {
    try {
      await clearAll();

      for (final entry in defaults.entries) {
        await saveValue(entry.key, entry.value);
      }
    } catch (e) {
      throw Exception('Не вдалося скинути налаштування: $e');
    }
  }

  // Експорт налаштувань у JSON
  String exportToJson() {
    try {
      return const JsonEncoder.withIndent('  ').convert(getAll());
    } catch (e) {
      throw Exception('Не вдалося експортувати налаштування: $e');
    }
  }
}