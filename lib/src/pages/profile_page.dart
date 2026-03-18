import 'package:flutter/material.dart';

import '../widgets/page_header.dart';
import '../widgets/profile_header.dart';
import '../widgets/settings_tile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const ProfileHeader(),
            const SizedBox(height: 24),
            Text('Configurações', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const SettingsTile(icon: Icons.person_outline, title: 'Meu Perfil'),
            const SettingsTile(icon: Icons.account_balance_wallet_outlined, title: 'Minha Conta'),
            const SettingsTile(icon: Icons.currency_exchange, title: 'Moeda'),
            const SizedBox(height: 24),
            Text('Segurança', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const SettingsTile(icon: Icons.lock_outline, title: 'Alterar senha'),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFB00020),
                side: const BorderSide(color: Color(0xFFB00020)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => Navigator.pushReplacementNamed(context, '/'),
              icon: const Icon(Icons.logout),
              label: const Text('Sair'),
            ),
          ],
        ),
      ),
    );
  }
}
