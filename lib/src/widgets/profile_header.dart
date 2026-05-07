import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    this.onSettingsTap,
  });

  final String name;
  final String email;
  final VoidCallback? onSettingsTap;

  String get _displayName {
    final trimmedName = name.trim();
    return trimmedName.isEmpty ? 'Usuário' : trimmedName;
  }

  String get _displayEmail {
    final trimmedEmail = email.trim();
    return trimmedEmail.isEmpty ? 'E-mail não informado' : trimmedEmail;
  }

  String get _avatarInitial {
    final displayName = _displayName.trim();
    return displayName.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3A0A73), Color(0xFF7D2AE8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            child: Text(
              _avatarInitial,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF241136),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _displayEmail,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          if (onSettingsTap == null)
            const Icon(Icons.settings, color: Colors.white)
          else
            IconButton(
              tooltip: 'Configurações',
              onPressed: onSettingsTap,
              icon: const Icon(Icons.settings, color: Colors.white),
            ),
        ],
      ),
    );
  }
}
