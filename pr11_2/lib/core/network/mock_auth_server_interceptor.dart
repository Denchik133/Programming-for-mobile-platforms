import 'package:dio/dio.dart';

import '../../features/auth/data/local_mock_auth_server.dart';

class MockAuthServerInterceptor extends Interceptor {
  MockAuthServerInterceptor(this._server);

  final LocalMockAuthServer _server;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final reply = await _server.dispatch(options);
      handler.resolve(
        Response<dynamic>(
          requestOptions: options,
          statusCode: reply.statusCode,
          data: reply.data,
          headers: Headers.fromMap({
            Headers.contentTypeHeader: [Headers.jsonContentType],
          }),
        ),
        true,
      );
    } on Object catch (error) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: error,
          type: DioExceptionType.unknown,
          message: 'Помилка демонстраційного сервера авторизації.',
        ),
      );
    }
  }
}
