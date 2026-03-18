import 'package:flutter/material.dart';

import '../widgets/custom_bottom_navigation_bar.dart';
import 'add_transaction_page.dart';
import 'banks_page.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'transactions_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  late final List<Widget> _pages = const [
    HomePage(),
    TransactionsPage(),
    AddTransactionPage(),
    BanksPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
