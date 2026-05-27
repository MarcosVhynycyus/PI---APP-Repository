import 'package:flutter/material.dart';
import '../services/auth_store.dart';
import '../services/user_service.dart';
import '../widgets/profile_header.dart';
import '../widgets/settings_tile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    this.onOpenAccounts,
    this.onProfileChanged,
  });

  final VoidCallback? onOpenAccounts;
  final VoidCallback? onProfileChanged;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _userService = UserService();

  String _name = '';
  String _email = '';
  bool _isMutating = false;

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

  Future<void> _editProfile() async {
    if (_isMutating) return;

    final result = await showDialog<_ProfileFormData>(
      context: context,
      builder: (_) => _ProfileFormDialog(initialName: _name),
    );

    if (result == null) return;

    await _alterUser(
      name: result.name,
      password: result.password,
      fallbackMessage: 'Perfil atualizado com sucesso.',
    );
  }

  Future<void> _changePassword() async {
    if (_isMutating) return;

    final result = await showDialog<_PasswordFormData>(
      context: context,
      builder: (_) => _PasswordFormDialog(initialName: _name),
    );

    if (result == null) return;

    await _alterUser(
      name: result.name,
      password: result.password,
      fallbackMessage: 'Senha alterada com sucesso.',
    );
  }

  Future<void> _alterUser({
    required String name,
    required String password,
    required String fallbackMessage,
  }) async {
    try {
      _setMutating(true);

      final message = await _userService.alterUser(
        name: name,
        password: password,
      );

      if (!mounted) return;

      setState(() {
        _name = name.trim();
      });

      widget.onProfileChanged?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message.trim().isEmpty ? fallbackMessage : message),
        ),
      );
    } on UserException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (_) {
      if (!mounted) return;
      _showError('Nao foi possivel atualizar seus dados.');
    } finally {
      _setMutating(false);
    }
  }

  void _openAccounts() {
    final onOpenAccounts = widget.onOpenAccounts;
    if (onOpenAccounts != null) {
      onOpenAccounts();
      return;
    }

    _showError('Tela de contas indisponivel neste contexto.');
  }

  Future<void> _logout() async {
    await AuthStore.logout();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _setMutating(bool value) {
    if (!mounted) return;

    setState(() {
      _isMutating = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IgnorePointer(
            ignoring: _isMutating,
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ProfileHeader(
                    name: _name,
                    email: _email,
                    onSettingsTap: _editProfile,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Configurações',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  SettingsTile(
                    icon: Icons.person_outline,
                    title: 'Meu Perfil',
                    onTap: _editProfile,
                    trailing: const Icon(Icons.edit_outlined),
                  ),
                  SettingsTile(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Minha Conta',
                    onTap: _openAccounts,
                  ),
                  SettingsTile(
                    icon: Icons.category_outlined,
                    title: 'Planos de Conta',
                    onTap: () => Navigator.pushNamed(context, '/account-plans'),
                  ),
                  SettingsTile(
                    icon: Icons.people,
                    title: 'Transatores',
                    onTap: () => Navigator.pushNamed(context, '/transactors'),
                  ),
                  SettingsTile(
                    icon: Icons.auto_awesome,
                    title: 'Concelheiro de IA',
                    onTap: () => Navigator.pushNamed(context, '/ai-advisor'),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Segurança',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  SettingsTile(
                    icon: Icons.lock_outline,
                    title: 'Alterar senha',
                    iconColor: const Color(0xFFB00020),
                    onTap: _changePassword,
                    trailing: const Icon(Icons.edit_outlined),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFB00020),
                      side: const BorderSide(color: Color(0xFFB00020)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _isMutating ? null : _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Sair'),
                  ),
                ],
              ),
            ),
          ),
          if (_isMutating)
            const Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

class _ProfileFormData {
  const _ProfileFormData({
    required this.name,
    required this.password,
  });

  final String name;
  final String password;
}

class _ProfileFormDialog extends StatefulWidget {
  const _ProfileFormDialog({required this.initialName});

  final String initialName;

  @override
  State<_ProfileFormDialog> createState() => _ProfileFormDialogState();
}

class _ProfileFormDialogState extends State<_ProfileFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    Navigator.of(context).pop(
      _ProfileFormData(
        name: _nameController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar perfil'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  hintText: 'Informe seu nome',
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if ((value ?? '').trim().length < 3) {
                    return 'Informe ao menos 3 caracteres.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  hintText: 'Confirme sua senha',
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                validator: (value) {
                  if ((value ?? '').length < 8) {
                    return 'Informe ao menos 8 caracteres.';
                  }

                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

class _PasswordFormData {
  const _PasswordFormData({
    required this.name,
    required this.password,
  });

  final String name;
  final String password;
}

class _PasswordFormDialog extends StatefulWidget {
  const _PasswordFormDialog({required this.initialName});

  final String initialName;

  @override
  State<_PasswordFormDialog> createState() => _PasswordFormDialogState();
}

class _PasswordFormDialogState extends State<_PasswordFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmationController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _passwordController = TextEditingController();
    _confirmationController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  void _submit() {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    Navigator.of(context).pop(
      _PasswordFormData(
        name: _nameController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Alterar senha'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do perfil',
                  hintText: 'Informe seu nome',
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if ((value ?? '').trim().length < 3) {
                    return 'Informe ao menos 3 caracteres.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nova senha',
                  hintText: 'Informe a nova senha',
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if ((value ?? '').length < 8) {
                    return 'Informe ao menos 8 caracteres.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmationController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmar senha',
                  hintText: 'Repita a nova senha',
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'As senhas nao conferem.';
                  }

                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
