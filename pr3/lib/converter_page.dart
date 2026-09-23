import 'package:flutter/material.dart';

import 'converter.dart';

class ConverterPage extends StatefulWidget {
  const ConverterPage({super.key});

  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  final TextEditingController _inputController = TextEditingController();
  final TemperatureConverter _converter = const TemperatureConverter();

  TemperatureUnit _fromUnit = TemperatureUnit.celsius;
  TemperatureUnit _toUnit = TemperatureUnit.fahrenheit;

  String? _result;
  String? _error;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _convert() {
    FocusScope.of(context).unfocus();

    final text = _inputController.text.trim().replaceAll(',', '.');

    if (text.isEmpty) {
      setState(() {
        _result = null;
        _error = 'Введіть число для конвертації.';
      });
      return;
    }

    final value = double.tryParse(text);

    if (value == null || !value.isFinite) {
      setState(() {
        _result = null;
        _error = 'Введіть коректне число, наприклад 25 або -12,5.';
      });
      return;
    }

    try {
      final converted = _converter.convert(
        value: value,
        from: _fromUnit,
        to: _toUnit,
      );

      setState(() {
        _error = null;
        _result = '${converted.toStringAsFixed(2)} ${_toUnit.symbol}';
      });
    } on TemperatureConversionException catch (exception) {
      setState(() {
        _result = null;
        _error = exception.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Конвертер температури'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Введіть значення та оберіть одиниці вимірювання.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _inputController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Значення',
                  hintText: 'Наприклад, 25',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _convert(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TemperatureUnit>(
                initialValue: _fromUnit,
                decoration: const InputDecoration(
                  labelText: 'З якої одиниці',
                  border: OutlineInputBorder(),
                ),
                items: TemperatureUnit.values
                    .map(
                      (unit) => DropdownMenuItem<TemperatureUnit>(
                        value: unit,
                        child: Text(unit.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _fromUnit = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TemperatureUnit>(
                initialValue: _toUnit,
                decoration: const InputDecoration(
                  labelText: 'В яку одиницю',
                  border: OutlineInputBorder(),
                ),
                items: TemperatureUnit.values
                    .map(
                      (unit) => DropdownMenuItem<TemperatureUnit>(
                        value: unit,
                        child: Text(unit.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _toUnit = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _convert,
                icon: const Icon(Icons.calculate),
                label: const Text('Конвертувати'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 15,
                  ),
                ),
              ],
              if (_result != null) ...[
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          'Результат',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _result!,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

extension TemperatureUnitSymbol on TemperatureUnit {
  String get symbol {
    switch (this) {
      case TemperatureUnit.celsius:
        return '°C';
      case TemperatureUnit.fahrenheit:
        return '°F';
      case TemperatureUnit.kelvin:
        return 'K';
    }
  }
}