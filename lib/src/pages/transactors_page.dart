import 'package:flutter/material.dart';

import '../models/transactor_model.dart';
import '../services/auth_store.dart';
import '../services/transactors_service.dart';
import '../widgets/page_header.dart';
import '../widgets/transactor_card.dart';

class TransactorsPage extends StatefulWidget {
  const TransactorsPage({
    super.key,
    this.onLogoTap,
    this.userInitial,
  });

  final VoidCallback? onLogoTap;
  final String? userInitial;

  @override
  State<TransactorsPage> createState() => _TransactorsPageState();
}

class _TransactorsPageState extends State<TransactorsPage> {
  final _service = TransactorsService();

  List<TransactorModel> _transactors = [];

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
    _loadTransactors();
  }

  Future<void> _loadUserInitial() async {
    if (widget.userInitial?.trim().isNotEmpty ?? false) {
      return;
    }

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

  Future<void> _loadTransactors({
    bool showLoader = true,
  }) async {
    if (showLoader) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final result = await _service.getUserTransactors();

      if (!mounted) return;

      setState(() {
        _transactors = result;
        _error = null;
        _isLoading = false;
      });
    } on TransactorsException catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = 'Erro ao carregar Transatores!';
        _isLoading = false;
      });
    }
  }

  Future<void> _createTransactor() async {
    if (_isMutating) return;

    try {
      final payload = await _showTransactorDialog();

      if (payload == null) return;

      _setMutating(true);

      await _service.createTransactor(
        payload,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Transator criado com sucesso!',
          ),
        ),
      );

      await _loadTransactors(
        showLoader: false,
      );
    } on TransactorsException catch (e) {
      if (!mounted) return;

      _showError(e.message);
    } catch (_) {
      if (!mounted) return;

      _showError(
        'Não foi possível criar o Transator!',
      );
    } finally {
      _setMutating(false);
    }
  }

  Future<void> _editTransactor(
    TransactorModel transactor,
  ) async {
    if (_isMutating) return;

    try {
      final payload = await _showTransactorDialog(
        transactor: transactor,
      );

      if (payload == null) return;

      _setMutating(true);

      await _service.updateTransactor(
        transactor.idTransactor,
        payload,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Transator atualizado com sucesso!',
          ),
        ),
      );

      await _loadTransactors(
        showLoader: false,
      );
    } on TransactorsException catch (e) {
      if (!mounted) return;

      _showError(e.message);
    } catch (_) {
      if (!mounted) return;

      _showError(
        'Não foi possível atualizar o Transator!',
      );
    } finally {
      _setMutating(false);
    }
  }

  Future<void> _deleteTransactor(
    TransactorModel transactor,
  ) async {
    if (_isMutating) return;

    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'Excluir Transator',
          ),
          content: Text(
            'Tem certeza que deseja excluir "${transactor.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancelar',
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Excluir',
              ),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      _setMutating(true);

      await _service.deleteTransactor(
        transactor.idTransactor,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Transator excluído com sucesso!',
          ),
        ),
      );

      await _loadTransactors(
        showLoader: false,
      );
    } on TransactorsException catch (e) {
      if (!mounted) return;

      _showError(e.message);
    } catch (_) {
      if (!mounted) return;

      _showError(
        'Não foi possível excluir o Transator!',
      );
    } finally {
      _setMutating(false);
    }
  }

  Future<Map<String, dynamic>?> _showTransactorDialog({
    TransactorModel? transactor,
  }) async {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _TransactorFormDialog(
        transactor: transactor,
      ),
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
        onPressed: _isMutating ? null : _createTransactor,
        icon: const Icon(Icons.add),
        label: const Text(
          'Novo',
        ),
      ),
      body: Stack(
        children: [
          IgnorePointer(
            ignoring: _isMutating,
            child: Column(
              children: [
                PageHeader(
                  title: 'Transatores',
                  showLogo: true,
                  showBackButton: true,
                  customIcon: Icons.people,
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
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null && _transactors.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _loadTransactors,
              child: const Text(
                'Tentar novamente',
              ),
            ),
          ],
        ),
      );
    }

    if (_transactors.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum Transator encontrado!',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadTransactors(
        showLoader: false,
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _transactors.length,
        itemBuilder: (context, index) {
          final transactor = _transactors[index];

          return Padding(
            padding: const EdgeInsets.only(
              bottom: 12,
            ),
            child: TransactorCard(
              data: TransactorCardData(
                name: transactor.name,
                color: _getColor(
                  transactor.idTransactor,
                ),
              ),
              onEdit: _isMutating
                  ? null
                  : () => _editTransactor(
                        transactor,
                      ),
              onDelete: _isMutating
                  ? null
                  : () => _deleteTransactor(
                        transactor,
                      ),
            ),
          );
        },
      ),
    );
  }
}

class _TransactorFormDialog extends StatefulWidget {
  final TransactorModel? transactor;

  const _TransactorFormDialog({
    this.transactor,
  });

  @override
  State<_TransactorFormDialog> createState() => _TransactorFormDialogState();
}

class _TransactorFormDialogState extends State<_TransactorFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.transactor?.name ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final formState = _formKey.currentState;

    if (formState == null || !formState.validate()) {
      return;
    }

    Navigator.of(context).pop({
      'name': _nameController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transactor != null;

    return AlertDialog(
      title: Text(
        isEditing ? 'Editar Transator' : 'Novo Transator',
      ),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nome',
            hintText: 'Ex: Mercado, Empresa, Cliente',
          ),
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _submit(),
          validator: (value) {
            if ((value ?? '').trim().isEmpty) {
              return 'Informe o nome do Transator!';
            }

            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancelar',
          ),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text(
            'Salvar',
          ),
        ),
      ],
    );
  }
}
