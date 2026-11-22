import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/todo.dart';
import '../models/user.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiService {
  ApiService({http.Client? client, this.timeout = const Duration(seconds: 10)})
    : _client = client ?? http.Client();

  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  static const Map<String, String> _headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=UTF-8',
  };

  final http.Client _client;
  final Duration timeout;

  void close() => _client.close();

  Future<List<Todo>> getTodos({int? userId}) async {
    final uri = Uri.parse(
      '$baseUrl/todos',
    ).replace(queryParameters: userId == null ? null : {'userId': '$userId'});
    final response = await _send(() => _client.get(uri, headers: _headers));
    final json = _decode(response.body);
    if (json is! List) {
      throw const ApiException('Сервер повернув некоректний список завдань.');
    }
    try {
      return json
          .map((item) => Todo.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(growable: false);
    } on FormatException {
      throw const ApiException('Сервер повернув некоректний JSON завдань.');
    } on TypeError {
      throw const ApiException('Сервер повернув некоректний JSON завдань.');
    }
  }

  Future<List<User>> getUsers() async {
    final response = await _send(
      () => _client.get(Uri.parse('$baseUrl/users'), headers: _headers),
    );
    final json = _decode(response.body);
    if (json is! List) {
      throw const ApiException(
        'Сервер повернув некоректний список користувачів.',
      );
    }
    try {
      return json
          .map((item) => User.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(growable: false);
    } on FormatException {
      throw const ApiException(
        'Сервер повернув некоректний JSON користувачів.',
      );
    } on TypeError {
      throw const ApiException(
        'Сервер повернув некоректний JSON користувачів.',
      );
    }
  }

  Future<Todo> createTodo(Todo todo) async {
    final body = todo.toJson(includeId: false);
    final response = await _send(
      () => _client.post(
        Uri.parse('$baseUrl/todos'),
        headers: _headers,
        body: jsonEncode(body),
      ),
    );
    return _parseTodo(response.body);
  }

  Future<Todo> updateTodo(Todo todo) async {
    final response = await _send(
      () => _client.put(
        Uri.parse('$baseUrl/todos/${todo.id}'),
        headers: _headers,
        body: jsonEncode(todo.toJson()),
      ),
    );
    return _parseTodo(response.body);
  }

  Future<Todo> updateCompleted(int id, bool completed) async {
    final response = await _send(
      () => _client.patch(
        Uri.parse('$baseUrl/todos/$id'),
        headers: _headers,
        body: jsonEncode({'completed': completed}),
      ),
    );
    return _parseTodo(response.body);
  }

  Future<void> deleteTodo(int id) async {
    await _send(() => _client.delete(Uri.parse('$baseUrl/todos/$id')));
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    late final http.Response response;
    try {
      response = await request().timeout(timeout);
    } on TimeoutException {
      throw const ApiException(
        'Час очікування відповіді минув. Спробуйте ще раз.',
      );
    } on SocketException {
      throw const ApiException(
        'Немає з’єднання з інтернетом. Перевірте мережу.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Не вдалося з’єднатися із сервером. Перевірте мережу.',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }
    if (response.statusCode == 404) {
      throw const ApiException(
        'Запитаний ресурс не знайдено (404).',
        statusCode: 404,
      );
    }
    if (response.statusCode >= 500) {
      throw ApiException(
        'Помилка сервера (${response.statusCode}). Спробуйте пізніше.',
        statusCode: response.statusCode,
      );
    }
    throw ApiException(
      'Не вдалося виконати запит (HTTP ${response.statusCode}).',
      statusCode: response.statusCode,
    );
  }

  dynamic _decode(String body) {
    try {
      return jsonDecode(body);
    } on FormatException {
      throw const ApiException('Сервер повернув некоректну JSON-відповідь.');
    }
  }

  Todo _parseTodo(String body) {
    final json = _decode(body);
    if (json is! Map) {
      throw const ApiException('Сервер повернув некоректне завдання.');
    }
    try {
      return Todo.fromJson(Map<String, dynamic>.from(json));
    } on FormatException {
      throw const ApiException('Сервер повернув некоректний JSON завдання.');
    } on TypeError {
      throw const ApiException('Сервер повернув некоректний JSON завдання.');
    }
  }
}
