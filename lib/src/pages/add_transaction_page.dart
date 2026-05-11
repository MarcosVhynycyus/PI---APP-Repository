import 'package:flutter/material.dart';
import '../models/account_model.dart';
import '../models/account_plan_model.dart';
import '../models/transactor_model.dart';
import '../services/account_plans_service.dart';
import '../services/banks_service.dart';
import '../services/finacial_movements_service.dart';
import '../services/transactors_service.dart';
import '../widgets/page_header.dart';
import '../widgets/date_picker_field.dart';
import '../widgets/selector_field.dart';
import '../widgets/transaction_type_selector.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({
    super.key,
    this.onLogoTap,
    this.userInitial,
  });

  final VoidCallback? onLogoTap;
  final String? userInitial;

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  static const _paidSituationId = 2;

  static const _paymentMethods = [
    _SelectionOption(1, 'Pix'),
    _SelectionOption(2, 'Boleto'),
    _SelectionOption(3, 'Dinheiro'),
    _SelectionOption(4, 'Cartão de crédito'),
    _SelectionOption(5, 'Cartão de débito'),
  ];

  static const _situations = [
    _SelectionOption(1, 'Em aberto'),
    _SelectionOption(_paidSituationId, 'Quitada'),
    _SelectionOption(3, 'Vencida'),
  ];

  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _docNumController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _accountPlansService = AccountPlansService();
  final _banksService = BanksService();
  final _financialMovementsService = FinancialMovementsService();
  final _transactorsService = TransactorsService();

  bool _isSaving = false;
  int _selectedTypeMovementId = TransactionTypeSelector.expenseMovementId;

  bool _isLoadingCategories = true;
  String? _categoriesError;
  List<AccountPlanModel> _categories = [];
  int? _selectedCategoryId;

  bool _isLoadingAccounts = true;
  String? _accountsError;
  List<AccountModel> _accounts = [];
  int? _selectedAccountId;

  bool _isLoadingTransactors = true;
  String? _transactorsError;
  List<TransactorModel> _transactors = [];
  int? _selectedTransactorId;

  int? _selectedPaymentMethodId;
  int? _selectedSituationId;
  DateTime? _selectedMovementDate;
  DateTime? _selectedDueDate;
  DateTime? _selectedPaymentDate;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadAccounts();
    _loadTransactors();
  }

  @override
  void dispose() {
    _valueController.dispose();
    _docNumController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
      _categoriesError = null;
    });

    try {
      final categories = await _accountPlansService.getUserAccountPlans();
      if (!mounted) return;

      setState(() {
        _categories = categories;
        _selectedCategoryId = categories.any(
          (category) => category.idAccountPlan == _selectedCategoryId,
        )
            ? _selectedCategoryId
            : null;
        _isLoadingCategories = false;
      });
    } on AccountPlansException catch (e) {
      if (!mounted) return;
      setState(() {
        _categoriesError = e.message;
        _isLoadingCategories = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _categoriesError = 'Erro ao carregar categorias.';
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _loadAccounts() async {
    setState(() {
      _isLoadingAccounts = true;
      _accountsError = null;
    });

    try {
      final accounts = await _banksService.getUserAccounts();
      if (!mounted) return;

      setState(() {
        _accounts = accounts;
        _selectedAccountId =
            accounts.any((account) => account.idAccount == _selectedAccountId)
                ? _selectedAccountId
                : null;
        _isLoadingAccounts = false;
      });
    } on BanksException catch (e) {
      if (!mounted) return;
      setState(() {
        _accountsError = e.message;
        _isLoadingAccounts = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _accountsError = 'Erro ao carregar contas.';
        _isLoadingAccounts = false;
      });
    }
  }

  Future<void> _loadTransactors() async {
    setState(() {
      _isLoadingTransactors = true;
      _transactorsError = null;
    });

    try {
      final transactors = await _transactorsService.getUserTransactors();
      if (!mounted) return;

      setState(() {
        _transactors = transactors;
        _selectedTransactorId = transactors.any(
          (transactor) => transactor.idTransactor == _selectedTransactorId,
        )
            ? _selectedTransactorId
            : null;
        _isLoadingTransactors = false;
      });
    } on TransactorsException catch (e) {
      if (!mounted) return;
      setState(() {
        _transactorsError = e.message;
        _isLoadingTransactors = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _transactorsError = 'Erro ao carregar transatores.';
        _isLoadingTransactors = false;
      });
    }
  }

  List<_SelectionOption<int>> get _categoryOptions => _categories
      .map(
        (category) => _SelectionOption(
          category.idAccountPlan,
          category.description,
        ),
      )
      .toList();

  List<_SelectionOption<int>> get _accountOptions => _accounts
      .map(
        (account) => _SelectionOption(
          account.idAccount,
          account.description,
        ),
      )
      .toList();

  List<_SelectionOption<int>> get _transactorOptions => _transactors
      .map(
        (transactor) => _SelectionOption(
          transactor.idTransactor,
          transactor.name,
        ),
      )
      .toList();

  String? get _selectedCategoryLabel =>
      _selectedLabel(_categoryOptions, _selectedCategoryId);

  String? get _selectedAccountLabel =>
      _selectedLabel(_accountOptions, _selectedAccountId);

  String? get _selectedTransactorLabel =>
      _selectedLabel(_transactorOptions, _selectedTransactorId);

  String? get _selectedPaymentMethodLabel =>
      _selectedLabel(_paymentMethods, _selectedPaymentMethodId);

  String? get _selectedSituationLabel =>
      _selectedLabel(_situations, _selectedSituationId);

  Future<void> _selectCategory() async {
    final selected = await _showSelectionSheet<int>(
      title: 'Selecionar categoria',
      options: _categoryOptions,
      selectedValue: _selectedCategoryId,
    );

    if (!mounted || selected == null) return;
    setState(() {
      _selectedCategoryId = selected;
    });
  }

  Future<void> _selectAccount() async {
    final selected = await _showSelectionSheet<int>(
      title: 'Selecionar conta bancária',
      options: _accountOptions,
      selectedValue: _selectedAccountId,
    );

    if (!mounted || selected == null) return;
    setState(() {
      _selectedAccountId = selected;
    });
  }

  Future<void> _selectTransactor() async {
    final selected = await _showSelectionSheet<int>(
      title: 'Selecionar transator',
      options: _transactorOptions,
      selectedValue: _selectedTransactorId,
    );

    if (!mounted || selected == null) return;
    setState(() {
      _selectedTransactorId = selected;
    });
  }

  Future<void> _selectPaymentMethod() async {
    final selected = await _showSelectionSheet<int>(
      title: 'Selecionar forma de pagamento',
      options: _paymentMethods,
      selectedValue: _selectedPaymentMethodId,
    );

    if (!mounted || selected == null) return;
    setState(() {
      _selectedPaymentMethodId = selected;
    });
  }

  Future<void> _selectSituation() async {
    final selected = await _showSelectionSheet<int>(
      title: 'Selecionar situação',
      options: _situations,
      selectedValue: _selectedSituationId,
    );

    if (!mounted || selected == null) return;
    setState(() {
      _selectedSituationId = selected;
    });
  }

  Future<void> _pickDate({
    required DateTime? currentDate,
    required ValueChanged<DateTime> onSelected,
  }) async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: currentDate ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
    );

    if (!mounted || selected == null) return;
    setState(() {
      onSelected(selected);
    });
  }

  Future<T?> _showSelectionSheet<T>({
    required String title,
    required List<_SelectionOption<T>> options,
    required T? selectedValue,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);

        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.72,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final option = options[index];
                      final isSelected = option.value == selectedValue;

                      return ListTile(
                        title: Text(option.label),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Color(0xFF5B1FA6),
                              )
                            : null,
                        onTap: () => Navigator.of(context).pop(option.value),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryField() {
    return _buildRemoteSelectorField(
      label: 'Categoria',
      hint: 'Selecione uma categoria',
      icon: Icons.category_outlined,
      value: _selectedCategoryLabel,
      onTap: _selectCategory,
      isLoading: _isLoadingCategories,
      error: _categoriesError,
      isEmpty: _categories.isEmpty,
      emptyMessage: 'Nenhuma categoria encontrada.',
      onRetry: _loadCategories,
    );
  }

  Widget _buildAccountField() {
    return _buildRemoteSelectorField(
      label: 'Conta bancária',
      hint: 'Selecione uma conta',
      icon: Icons.account_balance_wallet_outlined,
      value: _selectedAccountLabel,
      onTap: _selectAccount,
      isLoading: _isLoadingAccounts,
      error: _accountsError,
      isEmpty: _accounts.isEmpty,
      emptyMessage: 'Nenhuma conta encontrada.',
      onRetry: _loadAccounts,
    );
  }

  Widget _buildTransactorField() {
    return _buildRemoteSelectorField(
      label: 'Transator',
      hint: 'Selecione um transator',
      icon: Icons.person_outline,
      value: _selectedTransactorLabel,
      onTap: _selectTransactor,
      isLoading: _isLoadingTransactors,
      error: _transactorsError,
      isEmpty: _transactors.isEmpty,
      emptyMessage: 'Nenhum transator encontrado.',
      onRetry: _loadTransactors,
    );
  }

  Widget _buildPaymentMethodField() {
    return SelectorField(
      label: 'Forma de pagamento',
      hint: 'Selecione a forma de pagamento',
      icon: Icons.payments_outlined,
      value: _selectedPaymentMethodLabel,
      onTap: _selectPaymentMethod,
    );
  }

  Widget _buildSituationField() {
    return SelectorField(
      label: 'Situação',
      hint: 'Selecione a situação',
      icon: Icons.flag_outlined,
      value: _selectedSituationLabel,
      onTap: _selectSituation,
    );
  }

  Widget _buildRemoteSelectorField({
    required String label,
    required String hint,
    required IconData icon,
    required String? value,
    required VoidCallback onTap,
    required bool isLoading,
    required String? error,
    required bool isEmpty,
    required String emptyMessage,
    required VoidCallback onRetry,
  }) {
    if (isLoading) {
      return _SelectionFieldState(
        label: label,
        child: const LinearProgressIndicator(),
      );
    }

    if (error != null) {
      return _SelectionFieldState(
        label: label,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(error, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (isEmpty) {
      return _SelectionFieldState(
        label: label,
        child: Text(emptyMessage),
      );
    }

    return SelectorField(
      label: label,
      hint: hint,
      icon: icon,
      value: value,
      onTap: onTap,
    );
  }

  String? _selectedLabel<T>(
    List<_SelectionOption<T>> options,
    T? selectedValue,
  ) {
    if (selectedValue == null) return null;

    for (final option in options) {
      if (option.value == selectedValue) {
        return option.label;
      }
    }

    return null;
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;

    final missingFields = <String>[];

    if (_selectedCategoryId == null) missingFields.add('categoria');
    if (_selectedAccountId == null) missingFields.add('conta bancária');
    if (_selectedTransactorId == null) missingFields.add('transator');
    if (_selectedPaymentDate != null && _selectedPaymentMethodId == null) {
      missingFields.add('forma de pagamento');
    }
    if (_selectedSituationId == null) missingFields.add('situação');
    if (_selectedMovementDate == null) {
      missingFields.add('data da movimentação');
    }

    if (missingFields.isNotEmpty) {
      _showSnackBar('Selecione ${_formatMissingFields(missingFields)}.');
      return;
    }

    if (_selectedDueDate != null &&
        _selectedDueDate!.isBefore(_selectedMovementDate!)) {
      _showSnackBar(
          'A data de vencimento não pode ser anterior à movimentação.');
      return;
    }

    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    final body = _buildFinancialMovementBody();

    setState(() {
      _isSaving = true;
    });

    try {
      await _financialMovementsService.createFinancialMovement(body);
      if (!mounted) return;

      _clearForm();
      _showSnackBar('Transação lançada com sucesso.');
    } on FinancialMovementsException catch (e) {
      if (!mounted) return;
      _showSnackBar(e.message);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('Erro ao lançar transação.');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatMissingFields(List<String> fields) {
    if (fields.length == 1) return fields.first;

    final allButLast = fields.take(fields.length - 1).join(', ');
    return '$allButLast e ${fields.last}';
  }

  double? _parseCurrencyInput(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    final normalized = trimmed.contains(',')
        ? trimmed.replaceAll('.', '').replaceAll(',', '.')
        : trimmed;

    return double.tryParse(normalized);
  }

  String _formatDateForApi(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> _buildFinancialMovementBody() {
    final movementDate = _selectedMovementDate!;
    final dueDate = _selectedDueDate ?? movementDate;

    return {
      'type_movement_id': _selectedTypeMovementId,
      'movement_date': _formatDateForApi(movementDate),
      'due_date': _formatDateForApi(dueDate),
      'payment_date': _selectedPaymentDate == null
          ? null
          : _formatDateForApi(_selectedPaymentDate!),
      'doc_num': _docNumController.text.trim(),
      'transator_id': _selectedTransactorId!,
      'value': _parseCurrencyInput(_valueController.text)!,
      'payment_method_id': _selectedPaymentMethodId,
      'situation_id': _selectedSituationId!,
      'account_id': _selectedAccountId!,
      'account_plan_id': _selectedCategoryId!,
      'reason': _descriptionController.text.trim(),
    };
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _valueController.clear();
    _docNumController.clear();
    _descriptionController.clear();

    setState(() {
      _selectedTypeMovementId = TransactionTypeSelector.expenseMovementId;
      _selectedCategoryId = null;
      _selectedAccountId = null;
      _selectedTransactorId = null;
      _selectedPaymentMethodId = null;
      _selectedSituationId = null;
      _selectedMovementDate = null;
      _selectedDueDate = null;
      _selectedPaymentDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Transações',
              showLogo: true,
              onLogoTap: widget.onLogoTap,
              userInitial: widget.userInitial,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TransactionTypeSelector(
                      selectedTypeMovementId: _selectedTypeMovementId,
                      onChanged: (typeMovementId) {
                        setState(() {
                          _selectedTypeMovementId = typeMovementId;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _valueController,
                      decoration: const InputDecoration(
                        labelText: 'Valor',
                        prefixText: 'R\$ ',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        final parsed = _parseCurrencyInput(value ?? '');
                        if (parsed == null || parsed <= 0) {
                          return 'Informe um valor válido.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _docNumController,
                      maxLength: 50,
                      decoration: const InputDecoration(
                        labelText: 'Número do documento',
                        hintText: 'Informe o documento',
                        counterText: '',
                      ),
                      validator: (value) {
                        final docNum = (value ?? '').trim();
                        if (docNum.isEmpty) {
                          return 'Informe o número do documento.';
                        }
                        if (docNum.length > 50) {
                          return 'Informe no máximo 50 caracteres.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DatePickerField(
                      label: 'Data da movimentação',
                      hint: 'Selecione a data da movimentação',
                      selectedDate: _selectedMovementDate,
                      onTap: () => _pickDate(
                        currentDate: _selectedMovementDate,
                        onSelected: (date) => _selectedMovementDate = date,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DatePickerField(
                      label: 'Data de vencimento',
                      hint: 'Sem vencimento informado',
                      selectedDate: _selectedDueDate,
                      onTap: () => _pickDate(
                        currentDate: _selectedDueDate ?? _selectedMovementDate,
                        onSelected: (date) => _selectedDueDate = date,
                      ),
                      onClear: () {
                        setState(() {
                          _selectedDueDate = null;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryField(),
                    const SizedBox(height: 16),
                    _buildAccountField(),
                    const SizedBox(height: 16),
                    _buildTransactorField(),
                    const SizedBox(height: 16),
                    DatePickerField(
                      label: 'Data de pagamento',
                      hint: 'Sem pagamento informado',
                      selectedDate: _selectedPaymentDate,
                      onTap: () => _pickDate(
                        currentDate:
                            _selectedPaymentDate ?? _selectedMovementDate,
                        onSelected: (date) => _selectedPaymentDate = date,
                      ),
                      onClear: () {
                        setState(() {
                          _selectedPaymentDate = null;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildPaymentMethodField(),
                    const SizedBox(height: 16),
                    _buildSituationField(),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        hintText: 'Descreva a transação',
                      ),
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Informe a descrição.';
                        }

                        return null;
                      },
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
                        onPressed: _handleSave,
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Salvar transação'),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionFieldState extends StatelessWidget {
  final String label;
  final Widget child;

  const _SelectionFieldState({
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _SelectionOption<T> {
  final T value;
  final String label;

  const _SelectionOption(this.value, this.label);
}
