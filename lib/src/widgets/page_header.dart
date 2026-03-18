import 'package:flutter/material.dart';

import 'app_logo.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final bool showLogo;

  const PageHeader({super.key, required this.title, this.showLogo = false});

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
          if (showLogo) const AppLogo(),
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
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: Colors.white)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: Colors.white)),
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Text('A', style: TextStyle(color: Color(0xFF241136), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
