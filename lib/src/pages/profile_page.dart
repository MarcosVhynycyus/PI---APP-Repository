import 'package:flutter/material.dart';
import '../services/auth_store.dart';
import '../widgets/profile_header.dart';
import '../widgets/settings_tile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await AuthStore.getUserProfile();
      if (!mounted) return;

      setState(() {
        _name = profile.name;
        _email = profile.email;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _name = '';
        _email = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ProfileHeader(
              name: _name,
              email: _email,
            ),
            const SizedBox(height: 24),
            Text('Configurações',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const SettingsTile(icon: Icons.person_outline, title: 'Meu Perfil'),
            const SettingsTile(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Minha Conta'),
            SettingsTile(
              icon: Icons.category_outlined,
              title: 'Planos de Conta',
              onTap: () => Navigator.pushNamed(context, '/account-plans'),
            ),
            const SettingsTile(icon: Icons.currency_exchange, title: 'Moeda'),
            const SizedBox(height: 24),
            Text('Segurança',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const SettingsTile(
                icon: Icons.lock_outline, title: 'Alterar senha'),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFB00020),
                side: const BorderSide(color: Color(0xFFB00020)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () async {
                await AuthStore.logout();

                if (!context.mounted) return;

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sair'),
            ),
          ],
        ),
      ),
    );
  }
}
