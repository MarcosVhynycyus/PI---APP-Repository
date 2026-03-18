import 'package:flutter/material.dart';

import '../widgets/app_logo.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1B0630),
              Color(0xFF6412C5),
              Color(0xFFB663FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(child: AppLogo(size: 84)),
                    const SizedBox(height: 20),
                    Text(
                      'Entrar',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF241136),
                          ),
                    ),
                    const SizedBox(height: 24),
                    const Text('E-mail'),
                    const SizedBox(height: 8),
                    const TextField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(hintText: 'Insira seu e-mail'),
                    ),
                    const SizedBox(height: 16),
                    const Text('Senha'),
                    const SizedBox(height: 8),
                    const TextField(
                      obscureText: true,
                      decoration: InputDecoration(hintText: 'Digite sua senha'),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF241136),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => Navigator.pushReplacementNamed(context, '/main'),
                        child: const Text('ENTRAR'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ainda não tem uma conta? Cadastre-se!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.black54,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
