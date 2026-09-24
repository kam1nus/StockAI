import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../services/auth_service.dart';

/// Routes a configured app to its signed-in experience.
///
/// Without a private configuration, the public prototype remains runnable in
/// local demo mode; authentication-dependent actions are simply unavailable.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.hasSupabaseConfiguration) {
      return home;
    }

    return StreamBuilder<AuthState>(
      stream: AuthService.authChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return AuthService.isLoggedIn ? home : const _SignInScreen();
      },
    );
  }
}

class _SignInScreen extends StatelessWidget {
  const _SignInScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Authentication UI is represented by the service layer in this '
            'prototype. Connect your own Supabase project to continue.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
