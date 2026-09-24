import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AppConfig.hasSupabaseConfiguration ? AuthService.currentUser : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.person_outline, size: 48),
            const SizedBox(height: 16),
            Text(user?.email ?? 'Demo profile',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            const Text('Account and stock-platform connection controls belong here.'),
            const Spacer(),
            if (user != null)
              FilledButton.tonalIcon(
                onPressed: () async {
                  await AuthService.signOut();
                  if (context.mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Выйти'),
              ),
          ],
        ),
      ),
    );
  }
}
