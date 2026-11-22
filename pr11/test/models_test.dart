import 'package:flutter_test/flutter_test.dart';
import 'package:pr11/models/todo.dart';
import 'package:pr11/models/user.dart';

void main() {
  group('Todo JSON model', () {
    test('parses and serializes a todo', () {
      const todo = Todo(
        id: 12,
        userId: 3,
        title: 'Read a book',
        completed: false,
      );

      expect(Todo.fromJson(todo.toJson()).toJson(), todo.toJson());
      expect(todo.toJson(includeId: false), {
        'userId': 3,
        'title': 'Read a book',
        'completed': false,
      });
    });

    test('rejects a todo with fields of the wrong type', () {
      expect(
        () => Todo.fromJson({
          'id': '12',
          'userId': 3,
          'title': 'Read a book',
          'completed': false,
        }),
        throwsFormatException,
      );
    });
  });

  test('parses and serializes a user', () {
    const user = User(id: 4, name: 'Jane Doe', email: 'jane@example.com');
    expect(User.fromJson(user.toJson()).toJson(), user.toJson());
  });
}
