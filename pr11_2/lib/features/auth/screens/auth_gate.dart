import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_controller.dart';
import 'auth_screen.dart';
import 'profile_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) => Consumer<AuthController>(
    builder: (context, auth, _) => switch (auth.status) {
      AuthStatus.checking => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      AuthStatus.signedOut => const AuthScreen(),
      AuthStatus.signedIn => const ProfileScreen(),
    },
  );
}
