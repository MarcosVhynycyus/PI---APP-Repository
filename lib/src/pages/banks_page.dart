import 'package:finansme_flutter/src/services/banks_service.dart';
import 'package:flutter/material.dart';
import '../models/account_model.dart';
import '../widgets/page_header.dart';
import '../widgets/bank_account_card.dart';

class BanksPage extends StatefulWidget {
  const BanksPage({super.key});

  @override
  State<BanksPage> createState() => _BanksPageState();
}

class _BanksPageState extends State<BanksPage> {
  final _service = BanksService();

  List<AccountModel> _banks = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBanks();
  }

  Future<void> _loadBanks({bool showLoader = true}) async {
    if (showLoader) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final result = await _service.getUserAccounts();
      if (!mounted) return;

      setState(() {
        _banks = result;
        _error = null;
        _isLoading = false;
      });
    } on BanksException catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = 'Erro ao carregar contas.';
        _isLoading = false;
      });
    }
  }

  Future<void> _createAccount() async {
    try {
      final payload = await _showAccountDialog();
      if (payload == null) return;

      await _service.createBank(payload);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta criada com sucesso.')),
      );

      await _loadBanks(showLoader: false);
    } on BanksException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (_) {
      if (!mounted) return;
      _showError('Nao foi possivel criar a conta.');
    }
  }

  Future<void> _editAccount(AccountModel account) async {
    try {
      final payload = await _showAccountDialog(account: account);
      if (payload == null) return;

      await _service.updateBank(account.idAccount, payload);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta atualizada com sucesso.')),
      );

      await _loadBanks(showLoader: false);
    } on BanksException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (_) {
      if (!mounted) return;
      _showError('Nao foi possivel atualizar a conta.');
    }
  }

  Future<void> _deleteAccount(AccountModel account) async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Excluir conta'),
          content: Text(
            'Tem certeza que deseja excluir "${account.description}"?',
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

      await _service.deleteBank(account.idAccount);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta excluida com sucesso.')),
      );

      await _loadBanks(showLoader: false);
    } on BanksException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (_) {
      if (!mounted) return;
      _showError('Nao foi possivel excluir a conta.');
    }
  }

  Future<Map<String, dynamic>?> _showAccountDialog({
    AccountModel? account,
  }) async {
    final formKey = GlobalKey<FormState>();
    final descriptionController = TextEditingController(
      text: account?.description ?? '',
    );
    final balanceController = TextEditingController(
      text: account != null
          ? account.balance.toStringAsFixed(2).replaceAll('.', ',')
          : '',
    );

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(account == null ? 'Nova conta' : 'Editar conta'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descricao',
                  hintText: 'Ex: Nubank, Carteira, Inter',
                ),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Informe a descricao da conta.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: balanceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Saldo inicial',
                  hintText: 'Ex: 1200,50',
                  prefixText: 'R\$ ',
                ),
                validator: (value) {
                  final parsed = _parseBalanceInput(value ?? '');
                  if (parsed == null || parsed < 0) {
                    return 'Informe um saldo valido.';
                  }

                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;

              final balance = _parseBalanceInput(balanceController.text);
              if (balance == null) return;

              Navigator.of(dialogContext).pop(
                {
                  'description': descriptionController.text.trim(),
                  'balance': balance,
                },
              );
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    return result;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  double? _parseBalanceInput(String raw) {
    var value = raw.trim();
    if (value.isEmpty) return null;

    if (value.contains(',')) {
      value = value.replaceAll('.', '').replaceAll(',', '.');
    }

    return double.tryParse(value);
  }

  Color _getColor(dynamic id) {
    final colors = [
      const Color(0xFFF2C300),
      const Color(0xFF5C4DB1),
      const Color(0xFF53B6F0),
      const Color(0xFF00C853),
      const Color(0xFFD50000),
    ];

    if (id is int) {
      return colors[id % colors.length];
    }

    return colors[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createAccount,
        icon: const Icon(Icons.add),
        label: const Text('Nova conta'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const PageHeader(
            title: 'Bancos',
            showLogo: true,
          ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _banks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _loadBanks,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_banks.isEmpty) {
      return const Center(child: Text('Nenhuma conta encontrada.'));
    }

    return RefreshIndicator(
      onRefresh: () => _loadBanks(showLoader: false),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _banks.length,
        itemBuilder: (context, index) {
          final account = _banks[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: BankAccountCard(
              data: BankAccountData(
                id: account.idAccount,
                description: account.description,
                balance: account.balance,
                color: _getColor(account.idAccount),
              ),
              onEdit: () => _editAccount(account),
              onDelete: () => _deleteAccount(account),
            ),
          );
        },
      ),
    );
  }
}
