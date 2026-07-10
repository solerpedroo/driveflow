import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/driveflow_gradient_background.dart';
import '../providers/auth_providers.dart';
import 'login_screen.dart';

/// Gate de autenticação — fallback se redirect demorar.
class AuthGateScreen extends ConsumerWidget {
  const AuthGateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);

    return auth.when(
      loading: () => const DriveFlowGradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, _) => DriveFlowGradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(child: Text('Erro ao verificar sessão: $error')),
        ),
      ),
      data: (user) {
        if (user == null) {
          return const LoginScreen();
        }
        return const DriveFlowGradientBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }
}
