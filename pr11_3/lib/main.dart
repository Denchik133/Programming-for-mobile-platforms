import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/dio_client.dart';
import 'core/storage/cache_service.dart';
import 'core/storage/connectivity_service.dart';
import 'core/storage/secure_store.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/data/auth_api.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/auth/presentation/auth_gate.dart';
import 'features/tasks/data/task_api.dart';
import 'features/tasks/data/task_repository.dart';
import 'features/tasks/presentation/task_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final secureStore = PlatformSecureStore.create();
  final tokenStorage = TokenStorage(secureStore);
  final connectivity = ConnectivityService();
  final authController = AuthController(
    api: AuthApi(createReqResDio()),
    tokenStorage: tokenStorage,
  );
  await authController.initialize();

  final tasksDio = createTasksDio(
    tokenStorage: tokenStorage,
    onUnauthorized: authController.expireSession,
  );
  final taskRepository = TaskRepository(
    api: TaskApi(tasksDio),
    cache: CacheService(preferences),
    connectivity: connectivity,
  );
  final taskController = TaskController(
    repository: taskRepository,
    connectivity: connectivity,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authController),
        ChangeNotifierProvider.value(value: taskController),
      ],
      child: const TaskManagerApp(),
    ),
  );
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Менеджер завдань',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      fontFamily: 'TaskRoboto',
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF246B65)),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF5F7F6),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      cardTheme: const CardThemeData(elevation: 1),
    ),
    home: const AuthGate(),
  );
}
