import 'package:dio/dio.dart';

class AppException implements Exception {
  const AppException(this.message);

  final String message;

  factory AppException.fromDio(DioException error) =>
      AppException(error.message ?? 'Сталася помилка мережі.');

  @override
  String toString() => message;
}
