import 'package:dio/dio.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = err.response?.statusCode;
    final message = switch (status) {
      400 => 'Перевірте введені дані.',
      401 => 'Сесія завершилася. Увійдіть знову.',
      404 => 'Завдання не знайдено.',
      int value when value >= 500 => 'Сервер тимчасово недоступний.',
      _ => _networkMessage(err.type),
    };
    handler.next(err.copyWith(message: message));
  }

  String _networkMessage(DioExceptionType type) => switch (type) {
    DioExceptionType.connectionTimeout =>
      'Перевищено час очікування з’єднання.',
    DioExceptionType.sendTimeout => 'Не вдалося надіслати запит вчасно.',
    DioExceptionType.receiveTimeout => 'Сервер не відповів вчасно.',
    DioExceptionType.connectionError => 'Немає з’єднання із сервером.',
    DioExceptionType.cancel => 'Запит скасовано.',
    _ => 'Не вдалося виконати мережевий запит.',
  };
}
