import 'package:flutter/material.dart';
import '../models/account_plan_model.dart';
import '../services/account_plans_service.dart';
import '../services/auth_store.dart';
import '../widgets/account_plan_card.dart';
import '../widgets/page_header.dart';

class AccountPlansPage extends StatefulWidget {
  const AccountPlansPage({
    super.key,
    this.onLogoTap,
    this.userInitial,
  });

  final VoidCallback? onLogoTap;
  final String? userInitial;

  @override
  State<AccountPlansPage> createState() => _AccountPlansPageState();
}

class _AccountPlansPageState extends State<AccountPlansPage> {
  final _service = AccountPlansService();

  List<AccountPlanModel> _accountPlans = [];
  bool _isLoading = true;
  bool _isMutating = false;
  String? _error;
  String? _loadedUserInitial;

  String? get _headerUserInitial {
    final widgetInitial = widget.userInitial?.trim();
    if (widgetInitial != null && widgetInitial.isNotEmpty) {
      return widgetInitial;
    }

    return _loadedUserInitial;
  }

  @override
  void initState() {
    super.initState();
    _loadUserInitial();
    _loadAccountPlans();
  }

  Future<void> _loadUserInitial() async {
    if (widget.userInitial?.trim().isNotEmpty ?? false) return;

    try {
      final profile = await AuthStore.getUserProfile();
      if (!mounted) return;

      setState(() {
        _loadedUserInitial = profile.initial;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loadedUserInitial = null;
      });
    }
  }

  void _goToMain() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/main',
      (route) => false,
    );
  }

  Future<void> _loadAccountPlans({bool showLoader = true}) async {
    if (showLoader) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final result = await _service.getUserAccountPlans();
      if (!mounted) return;

      setState(() {
        _accountPlans = result;
        _error = null;
        _isLoading = false;
      });
    } on AccountPlansException catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = 'Erro ao carregar planos de conta.';
        _isLoading = false;
      });
    }
  }

  Future<void> _createAccountPlan() async {
    if (_isMutating) return;

    try {
      final payload = await _showAccountPlanDialog();
      if (payload == null) return;

      _setMutating(true);
      await _service.createAccountPlan(payload);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plano de conta criado com sucesso.')),
      );

      await _loadAccountPlans(showLoader: false);
    } on AccountPlansException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (_) {
      if (!mounted) return;
      _showError('Nao foi possivel criar o plano de conta.');
    } finally {
      _setMutating(false);
    }
  }

  Future<void> _editAccountPlan(AccountPlanModel accountPlan) async {
    if (_isMutating) return;

    try {
      final payload = await _showAccountPlanDialog(accountPlan: accountPlan);
      if (payload == null) return;

      _setMutating(true);
      await _service.updateAccountPlan(accountPlan.idAccountPlan, payload);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plano de conta atualizado com sucesso.')),
      );

      await _loadAccountPlans(showLoader: false);
    } on AccountPlansException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (_) {
      if (!mounted) return;
      _showError('Nao foi possivel atualizar o plano de conta.');
    } finally {
      _setMutating(false);
    }
  }

  Future<void> _deleteAccountPlan(AccountPlanModel accountPlan) async {
    if (_isMutating) return;

    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Excluir plano de conta'),
          content: Text(
            'Tem certeza que deseja excluir "${accountPlan.description}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      _setMutating(true);
      await _service.deleteAccountPlan(accountPlan.idAccountPlan);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plano de conta excluido com sucesso.')),
      );

      await _loadAccountPlans(showLoader: false);
    } on AccountPlansException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (_) {
      if (!mounted) return;
      _showError('Nao foi possivel excluir o plano de conta.');
    } finally {
      _setMutating(false);
    }
  }

  Future<Map<String, dynamic>?> _showAccountPlanDialog({
    AccountPlanModel? accountPlan,
  }) async {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _AccountPlanFormDialog(accountPlan: accountPlan),
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

  Color _getColor(int id) {
    final colors = [
      const Color(0xFFF2C300),
      const Color(0xFF5C4DB1),
      const Color(0xFF53B6F0),
      const Color(0xFF00C853),
      const Color(0xFFD50000),
    ];

    return colors[id % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isMutating ? null : _createAccountPlan,
        icon: const Icon(Icons.add),
        label: const Text('Novo plano'),
      ),
      body: Stack(
        children: [
          IgnorePointer(
            ignoring: _isMutating,
            child: Column(
              children: [
                PageHeader(
                  title: 'Planos de conta',
                  showLogo: true,
                  onLogoTap: widget.onLogoTap ?? _goToMain,
                  userInitial: _headerUserInitial,
                ),
                Expanded(
                  child: _buildContent(),
                ),
              ],
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

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _accountPlans.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _loadAccountPlans,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_accountPlans.isEmpty) {
      return const Center(
        child: Text('Nenhum plano de conta encontrado.'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadAccountPlans(showLoader: false),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _accountPlans.length,
        itemBuilder: (context, index) {
          final accountPlan = _accountPlans[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AccountPlanCard(
              data: AccountPlanCardData(
                description: accountPlan.description,
                code: 'Plano: ${accountPlan.idAccountPlan}',
                color: _getColor(accountPlan.idAccountPlan),
              ),
              onEdit: _isMutating ? null : () => _editAccountPlan(accountPlan),
              onDelete:
                  _isMutating ? null : () => _deleteAccountPlan(accountPlan),
            ),
          );
        },
      ),
    );
  }
}

class _AccountPlanFormDialog extends StatefulWidget {
  final AccountPlanModel? accountPlan;

  const _AccountPlanFormDialog({this.accountPlan});

  @override
  State<_AccountPlanFormDialog> createState() => _AccountPlanFormDialogState();
}

class _AccountPlanFormDialogState extends State<_AccountPlanFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.accountPlan?.description ?? '',
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    Navigator.of(context).pop({
      'description': _descriptionController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.accountPlan != null;

    return AlertDialog(
      title: Text(isEditing ? 'Editar plano de conta' : 'Novo plano de conta'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Descricao',
            hintText: 'Ex: Alimentacao, Salario, Moradia',
          ),
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _submit(),
          validator: (value) {
            if ((value ?? '').trim().isEmpty) {
              return 'Informe a descricao do plano de conta.';
            }
            return null;
          },
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
