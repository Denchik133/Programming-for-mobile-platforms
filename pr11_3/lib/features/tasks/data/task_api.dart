import 'package:dio/dio.dart';

import '../../../core/network/api_endpoints.dart';
import '../domain/task.dart';

abstract interface class TaskRemoteApi {
  Future<List<Task>> getTasks(int userId);
  Future<void> createTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(int id);
}

class TaskApi implements TaskRemoteApi {
  TaskApi(this._dio);

  final Dio _dio;

  @override
  Future<List<Task>> getTasks(int userId) async {
    final response = await _dio.get<List<dynamic>>(
      ApiEndpoints.todos,
      queryParameters: {'userId': userId},
    );
    return (response.data ?? const <dynamic>[])
        .map((item) => Task.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> createTask(Task task) async {
    await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.todos,
      data: task.toJson()..remove('id'),
    );
  }

  @override
  Future<void> updateTask(Task task) async {
    await _dio.patch<Map<String, dynamic>>(
      '${ApiEndpoints.todos}/${task.id}',
      data: task.toJson(),
    );
  }

  @override
  Future<void> deleteTask(int id) async {
    await _dio.delete<void>('${ApiEndpoints.todos}/$id');
  }
}
