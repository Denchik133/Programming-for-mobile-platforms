
import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService weatherService = WeatherService();
  final TextEditingController cityController =
      TextEditingController(text: 'Київ');

  Map<String, dynamic>? weather;
  List<int> temperatures = [];

  bool isLoadingWeather = false;
  bool isStreaming = false;
  String? errorMessage;

  @override
  void dispose() {
    cityController.dispose();
    super.dispose();
  }

  Future<void> loadWeather() async {
    setState(() {
      isLoadingWeather = true;
      errorMessage = null;
      weather = null;
    });

    try {
      final result = await weatherService.fetchCurrentWeather(
        cityController.text,
      );

      if (!mounted) return;

      setState(() {
        weather = result;
      });
    } on ArgumentError catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.message.toString();
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Не вдалося отримати погоду: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoadingWeather = false;
        });
      }
    }
  }

  Future<void> startTemperatureStream() async {
    setState(() {
      temperatures = [];
      isStreaming = true;
    });

    try {
      await for (final temperature
          in weatherService.temperatureUpdates(times: 5)) {
        if (!mounted) return;

        setState(() {
          temperatures.add(temperature);
        });
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Помилка потоку: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isStreaming = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Завдання 4: Погода'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'Отримання погоди (Future)',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(
                  labelText: 'Назва міста',
                  hintText: 'Наприклад, Київ',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => loadWeather(),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: isLoadingWeather ? null : loadWeather,
                child: const Text('Отримати погоду'),
              ),
              if (isLoadingWeather) ...[
                const SizedBox(height: 16),
                const Center(
                  child: CircularProgressIndicator(),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Завантаження...',
                  textAlign: TextAlign.center,
                ),
              ],
              if (errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              if (weather != null) ...[
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.wb_sunny,
                      color: Colors.orange,
                      size: 36,
                    ),
                    title: Text(weather!['city'] as String),
                    subtitle: Text(
                      weather!['description'] as String,
                    ),
                    trailing: Text(
                      '${weather!['temperature']} °C',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
              const Divider(height: 40),
              const Text(
                'Потік температур (Stream)',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Отримуємо п’ять значень з інтервалом в одну секунду.',
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed:
                    isStreaming ? null : startTemperatureStream,
                icon: const Icon(Icons.thermostat),
                label: const Text('Запустити потік'),
              ),
              if (isStreaming) ...[
                const SizedBox(height: 12),
                const LinearProgressIndicator(),
              ],
              const SizedBox(height: 12),
              if (temperatures.isEmpty && !isStreaming)
                const Text('Натисни кнопку, щоб почати.')
              else
                ...temperatures.asMap().entries.map(
                  (entry) => Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${entry.key + 1}'),
                      ),
                      title: Text(
                        'Температура: ${entry.value} °C',
                      ),
                    ),
                  ),
                ),
              if (!isStreaming && temperatures.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Потік завершено.',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
