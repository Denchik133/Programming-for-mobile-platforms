enum TemperatureUnit {
  celsius,
  fahrenheit,
  kelvin,
}

extension TemperatureUnitExtension on TemperatureUnit {
  String get label {
    switch (this) {
      case TemperatureUnit.celsius:
        return 'Цельсій (°C)';
      case TemperatureUnit.fahrenheit:
        return 'Фаренгейт (°F)';
      case TemperatureUnit.kelvin:
        return 'Кельвін (K)';
    }
  }
}

class TemperatureConversionException implements Exception {
  const TemperatureConversionException(this.message);

  final String message;
}

class TemperatureConverter {
  const TemperatureConverter();

  double convert({
    required double value,
    required TemperatureUnit from,
    required TemperatureUnit to,
  }) {
    final celsius = _toCelsius(value, from);

    if (celsius < -273.15) {
      throw const TemperatureConversionException(
        'Температура не може бути нижчою за абсолютний нуль.',
      );
    }

    return _fromCelsius(celsius, to);
  }

  double _toCelsius(double value, TemperatureUnit unit) {
    switch (unit) {
      case TemperatureUnit.celsius:
        return value;
      case TemperatureUnit.fahrenheit:
        return (value - 32) * 5 / 9;
      case TemperatureUnit.kelvin:
        return value - 273.15;
    }
  }

  double _fromCelsius(double value, TemperatureUnit unit) {
    switch (unit) {
      case TemperatureUnit.celsius:
        return value;
      case TemperatureUnit.fahrenheit:
        return value * 9 / 5 + 32;
      case TemperatureUnit.kelvin:
        return value + 273.15;
    }
  }
}