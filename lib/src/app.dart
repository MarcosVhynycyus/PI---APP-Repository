import 'package:flutter/material.dart';

import 'pages/ai_advisor_page.dart';
import 'pages/account_plans_page.dart';
import 'pages/login_page.dart';
import 'pages/main_navigation.dart';
import 'services/auth_store.dart';
import 'pages/transactors_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinansMe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F2F8),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B1FA6),
          primary: const Color(0xFF5B1FA6),
          secondary: const Color(0xFF2B113F),
          surface: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF5B1FA6), width: 1.4),
          ),
        ),
      ),
      home: const SessionGate(),
      routes: {
        '/login': (_) => const LoginPage(),
        '/main': (_) => const MainNavigation(),
        '/ai-advisor': (_) => const AiAdvisorPage(),
        '/account-plans': (_) => const AccountPlansPage(),
        '/transactors': (_) => const TransactorsPage(),
      },
    );
  }
}

class SessionGate extends StatefulWidget {
  const SessionGate({super.key});

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final token = await AuthStore.getToken();

    if (!mounted) return;

    setState(() {
      _isAuthenticated = token != null && token.isNotEmpty;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isAuthenticated) {
      return const MainNavigation();
    }

    return const LoginPage();
  }
}
