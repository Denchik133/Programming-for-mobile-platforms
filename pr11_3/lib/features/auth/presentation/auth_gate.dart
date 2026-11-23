import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_controller.dart';
import 'login_screen.dart';
import '../../tasks/presentation/task_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) => Consumer<AuthController>(
    builder: (context, auth, _) {
      if (auth.isLoading && auth.session == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      final session = auth.session;
      return session == null
          ? const LoginScreen()
          : TaskScreen(userId: session.userId, email: session.email);
    },
  );
}
