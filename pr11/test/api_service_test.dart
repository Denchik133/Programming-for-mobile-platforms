import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pr11/models/todo.dart';
import 'package:pr11/services/api_service.dart';

void main() {
  const todoJson = {
    'id': 7,
    'userId': 2,
    'title': 'Prepare notes',
    'completed': false,
  };

  group('ApiService', () {
    test(
      'loads todos and sends the user filter as a query parameter',
      () async {
        late Uri requestedUri;
        final api = ApiService(
          client: MockClient((request) async {
            requestedUri = request.url;
            return http.Response(jsonEncode([todoJson]), 200);
          }),
        );
        addTearDown(api.close);

        final todos = await api.getTodos(userId: 2);

        expect(requestedUri.path, '/todos');
        expect(requestedUri.queryParameters, {'userId': '2'});
        expect(todos.single.title, 'Prepare notes');
      },
    );

    test('executes POST, PUT, PATCH and DELETE requests', () async {
      final requests = <http.Request>[];
      final api = ApiService(
        client: MockClient((request) async {
          requests.add(request);
          if (request.method == 'DELETE') {
            return http.Response('', 200);
          }
          return http.Response(jsonEncode(todoJson), 200);
        }),
      );
      addTearDown(api.close);
      const todo = Todo(
        id: 7,
        userId: 2,
        title: 'Prepare notes',
        completed: false,
      );

      await api.createTodo(todo);
      await api.updateTodo(todo.copyWith(title: 'Updated notes'));
      await api.updateCompleted(todo.id, true);
      await api.deleteTodo(todo.id);

      expect(requests.map((request) => request.method), [
        'POST',
        'PUT',
        'PATCH',
        'DELETE',
      ]);
      expect(jsonDecode(requests.first.body), {
        'userId': 2,
        'title': 'Prepare notes',
        'completed': false,
      });
      expect(jsonDecode(requests[2].body), {'completed': true});
    });

    test('maps HTTP 404 to a readable API error', () async {
      final api = ApiService(
        client: MockClient((_) async => http.Response('Not found', 404)),
      );
      addTearDown(api.close);

      await expectLater(
        api.getTodos(),
        throwsA(
          isA<ApiException>()
              .having((error) => error.statusCode, 'statusCode', 404)
              .having((error) => error.message, 'message', contains('404')),
        ),
      );
    });

    test('maps HTTP 500 to a readable server error', () async {
      final api = ApiService(
        client: MockClient((_) async => http.Response('Server error', 500)),
      );
      addTearDown(api.close);

      await expectLater(
        api.getTodos(),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
            contains('Помилка сервера'),
          ),
        ),
      );
    });

    test('reports an invalid JSON response', () async {
      final api = ApiService(
        client: MockClient((_) async => http.Response('{bad json', 200)),
      );
      addTearDown(api.close);

      await expectLater(
        api.getTodos(),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
            contains('некоректну JSON'),
          ),
        ),
      );
    });

    test('reports an offline connection', () async {
      final api = ApiService(
        client: MockClient((_) async => throw const SocketException('offline')),
      );
      addTearDown(api.close);

      await expectLater(
        api.getTodos(),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
          contains('інтернетом'),
          ),
        ),
      );
    });

    test('times out a slow request', () async {
      final api = ApiService(
        client: MockClient((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 40));
          return http.Response(jsonEncode([todoJson]), 200);
        }),
        timeout: const Duration(milliseconds: 5),
      );
      addTearDown(api.close);

      await expectLater(
        api.getTodos(),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
            contains('очікування'),
          ),
        ),
      );
    });
  });
}
