import 'dart:async';

import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor(this._dio, {this.maxRetries = 2});

  final Dio _dio;
  final int maxRetries;

  // Retry transport and server failures once; never retry client-side 4xx errors.
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    final retries = request.extra['retryCount'] as int? ?? 0;
    final isRetryable =
        err.response == null || (err.response?.statusCode ?? 0) >= 500;
    if (!isRetryable ||
        retries >= maxRetries ||
        request.cancelToken?.isCancelled == true) {
      handler.next(err);
      return;
    }

    request.extra['retryCount'] = retries + 1;
    await Future<void>.delayed(Duration(milliseconds: 250 * (retries + 1)));
    try {
      handler.resolve(await _dio.fetch<dynamic>(request));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }
}
