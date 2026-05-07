import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../services/auth_store.dart';
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
  String? _userInitial;

  @override
  void initState() {
    super.initState();
    _loadUserInitial();
  }

  Future<void> _loadUserInitial() async {
    try {
      final profile = await AuthStore.getUserProfile();
      if (!mounted) return;

      setState(() {
        _userInitial = profile.initial;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _userInitial = null;
      });
    }
  }

  void _goToHome() {
    if (_currentIndex == 0) return;

    setState(() {
      _currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        onLogoTap: _goToHome,
        userInitial: _userInitial,
      ),
      TransactionsPage(
        onLogoTap: _goToHome,
        userInitial: _userInitial,
      ),
      AddTransactionPage(
        onLogoTap: _goToHome,
        userInitial: _userInitial,
      ),
      BanksPage(
        onLogoTap: _goToHome,
        userInitial: _userInitial,
      ),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

@Preview(name: 'Login Page Preview')
Widget previewMainNavigation() {
  return const MaterialApp(
    home: MainNavigation(),
  );
}
