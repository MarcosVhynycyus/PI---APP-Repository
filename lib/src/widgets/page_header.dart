import 'package:flutter/material.dart';

import 'app_logo.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final bool showLogo;
  final VoidCallback? onLogoTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSearchTap;
  final String? userInitial;

  const PageHeader({
    super.key,
    required this.title,
    this.showLogo = false,
    this.onLogoTap,
    this.onNotificationTap,
    this.onSearchTap,
    this.userInitial,
  });

  String get _avatarInitial {
    final trimmedInitial = userInitial?.trim() ?? '';
    if (trimmedInitial.isEmpty) return 'U';

    return trimmedInitial.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3A0A73), Color(0xFF7D2AE8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          if (showLogo) _buildLogo(),
          if (showLogo) const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (onNotificationTap != null)
            IconButton(
              tooltip: 'Notificações',
              onPressed: onNotificationTap,
              icon: const Icon(
                Icons.notifications_none,
                color: Colors.white,
              ),
            ),
          if (onSearchTap != null)
            IconButton(
              tooltip: 'Buscar',
              onPressed: onSearchTap,
              icon: const Icon(Icons.search, color: Colors.white),
            ),
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Text(
              _avatarInitial,
              style: const TextStyle(
                color: Color(0xFF241136),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    const logo = AppLogo();

    if (onLogoTap == null) return logo;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onLogoTap,
      child: logo,
    );
  }
}
