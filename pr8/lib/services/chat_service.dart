
import 'dart:math';

import '../models/message.dart';
import '../models/operator.dart';

class ChatService {
  ChatService({this.failureRate = 0.2})
      : _random = Random();

  final double failureRate;
  final Random _random;

  Future<T> _request<T>(
    T Function() response, {
    int delayMs = 700,
  }) async {
    await Future<void>.delayed(
      Duration(milliseconds: delayMs),
    );

    if (_random.nextDouble() < failureRate) {
      throw StateError('Сервер тимчасово недоступний');
    }

    return response();
  }

  Future<List<ChatMessage>> loadMessages() {
    return _request(
      () => <ChatMessage>[
        ChatMessage(
          id: '1',
          text: 'Добрий день! Чим можемо допомогти?',
          isFromOperator: true,
          sentAt: DateTime.now().subtract(
            const Duration(minutes: 5),
          ),
        ),
        ChatMessage(
          id: '2',
          text: 'У мене питання щодо замовлення.',
          isFromOperator: false,
          sentAt: DateTime.now().subtract(
            const Duration(minutes: 4),
          ),
        ),
      ],
    );
  }

  Future<SupportOperator> loadOperator() {
    return _request(
      () => const SupportOperator(
        id: 'operator-1',
        name: 'Олена',
        role: 'Фахівець підтримки',
        isOnline: true,
      ),
    );
  }

  Future<void> sendMessage(String text) async {
    await _request(
      () => true,
      delayMs: 500,
    ).timeout(
      const Duration(seconds: 3),
    );
  }

  Future<String> generateReply(String text) async {
    await Future<void>.delayed(
      Duration(
        seconds: 2 + _random.nextInt(4),
      ),
    );

    if (_random.nextDouble() < failureRate) {
      throw StateError('Оператор тимчасово недоступний');
    }

    return 'Дякуємо за повідомлення! '
        'Наш спеціаліст допоможе вам із питанням: $text';
  }
}
