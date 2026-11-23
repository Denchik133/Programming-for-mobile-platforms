import 'package:dio/dio.dart';

class DioErrorInterceptor extends Interceptor {
  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final statusCode = response.statusCode ?? 0;
    if (statusCode >= 400) {
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: _responseMessage(response) ?? _statusMessage(statusCode),
        ),
      );
      return;
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final message =
        _responseMessage(err.response) ?? _transportMessage(err.type);
    handler.next(err.copyWith(message: message));
  }

  String? _responseMessage(Response<dynamic>? response) {
    final data = response?.data;
    if (data is Map) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) return message;
    }
    final status = response?.statusCode;
    if (status != null && status >= 400) return _statusMessage(status);
    return null;
  }

  String _statusMessage(int status) {
    if (status == 401) return 'Потрібно увійти до облікового запису.';
    if (status == 404) return 'Запитаний ресурс не знайдено (404).';
    if (status >= 500) return 'Помилка сервера ($status). Спробуйте пізніше.';
    return 'Не вдалося виконати запит (HTTP $status).';
  }

  String _transportMessage(DioExceptionType type) => switch (type) {
    DioExceptionType.connectionTimeout =>
      'Час очікування з’єднання минув. Перевірте мережу.',
    DioExceptionType.sendTimeout =>
      'Не вдалося надіслати запит вчасно. Спробуйте ще раз.',
    DioExceptionType.receiveTimeout =>
      'Сервер не відповів вчасно. Спробуйте ще раз.',
    DioExceptionType.connectionError => 'Не вдалося з’єднатися із сервером.',
    DioExceptionType.transformTimeout =>
      'Час очікування обробки відповіді минув.',
    DioExceptionType.cancel => 'Запит скасовано.',
    DioExceptionType.badCertificate =>
      'Не вдалося перевірити сертифікат сервера.',
    DioExceptionType.badResponse => 'Сервер повернув помилкову відповідь.',
    DioExceptionType.unknown => 'Сталася невідома мережева помилка.',
  };
}
