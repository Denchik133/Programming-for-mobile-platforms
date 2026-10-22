
import 'dart:async';
import 'dart:math';

/// Сервіс для імітації отримання погоди.
class WeatherService {
  final Random _random = Random();

  /// Імітує отримання поточної погоди для міста.
  Future<Map<String, dynamic>> fetchCurrentWeather(
    String city,
  ) async {
    final normalizedCity = city.trim();

    if (normalizedCity.isEmpty) {
      throw ArgumentError('Місто не вказано');
    }

    await Future<void>.delayed(
      const Duration(seconds: 2),
    );

    final temperature = 10 + _random.nextInt(21);

    return {
      'city': normalizedCity,
      'temperature': temperature,
      'description': _getWeatherDescription(temperature),
    };
  }

  /// Генерує потік випадкових температур.
  ///
  /// За замовчуванням генерує 5 значень з інтервалом в 1 секунду.
  Stream<int> temperatureUpdates({int times = 5}) async* {
    for (var i = 0; i < times; i++) {
      await Future<void>.delayed(
        const Duration(seconds: 1),
      );

      yield -5 + _random.nextInt(36);
    }
  }

  String _getWeatherDescription(int temperature) {
    if (temperature < 10) {
      return 'Холодно';
    } else if (temperature < 20) {
      return 'Прохолодно';
    } else {
      return 'Тепло';
    }
  }
}
