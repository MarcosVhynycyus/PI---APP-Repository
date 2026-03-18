import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      height: 72,
      selectedIndex: currentIndex,
      backgroundColor: const Color(0xFF241136),
      indicatorColor: const Color(0xFF5B1FA6),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 12, color: Colors.white),
      ),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined, color: Colors.white), selectedIcon: Icon(Icons.home, color: Colors.white), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.receipt_long_outlined, color: Colors.white), selectedIcon: Icon(Icons.receipt_long, color: Colors.white), label: 'Transações'),
        NavigationDestination(icon: Icon(Icons.add_circle_outline, color: Colors.white), selectedIcon: Icon(Icons.add_circle, color: Colors.white), label: 'Lançar'),
        NavigationDestination(icon: Icon(Icons.account_balance_outlined, color: Colors.white), selectedIcon: Icon(Icons.account_balance, color: Colors.white), label: 'Bancos'),
        NavigationDestination(icon: Icon(Icons.person_outline, color: Colors.white), selectedIcon: Icon(Icons.person, color: Colors.white), label: 'Perfil'),
      ],
      onDestinationSelected: onTap,
    );
  }
}
