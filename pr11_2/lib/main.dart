import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/dio_client.dart';
import 'core/storage/secure_key_value_store.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/data/auth_api.dart';
import 'features/auth/data/local_mock_auth_server.dart';
import 'features/auth/providers/auth_controller.dart';
import 'features/auth/screens/auth_gate.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final secureStore = PlatformSecureKeyValueStore.create();
  final tokenStorage = TokenStorage(secureStore);
  final mockServer = LocalMockAuthServer(storage: secureStore);
  final dio = createAuthDio(tokenStorage: tokenStorage, mockServer: mockServer);
  final authApi = AuthApi(dio, mockServer);

  runApp(
    ChangeNotifierProvider(
      create: (_) =>
          AuthController(api: authApi, tokenStorage: tokenStorage)
            ..initialize(),
      child: const AuthDemoApp(),
    ),
  );
}

class AuthDemoApp extends StatelessWidget {
  const AuthDemoApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'JWT Auth Demo',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF365A78)),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF4F6F9),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    ),
    home: const AuthGate(),
  );
}
