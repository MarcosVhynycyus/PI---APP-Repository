import 'package:flutter/material.dart';
import '../models/account_plan_model.dart';
import '../services/account_plans_service.dart';
import '../widgets/page_header.dart';
import '../widgets/date_picker_field.dart';
import '../widgets/selector_field.dart';
import '../widgets/transaction_type_selector.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _accountPlansService = AccountPlansService();

  bool _isLoadingCategories = true;
  String? _categoriesError;
  List<AccountPlanModel> _categories = [];
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadCategories();
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
        _selectedCategoryId = categories.isNotEmpty
            ? (_selectedCategoryId ?? categories.first.idAccountPlan)
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

  Widget _buildCategoryField() {
    if (_isLoadingCategories) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Categoria', style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          LinearProgressIndicator(),
        ],
      );
    }

    if (_categoriesError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Categoria',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            _categoriesError!,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _loadCategories,
            child: const Text('Tentar novamente'),
          ),
        ],
      );
    }

    if (_categories.isEmpty) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Categoria', style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text('Nenhuma categoria encontrada.'),
        ],
      );
    }

    return DropdownButtonFormField<int>(
      initialValue: _selectedCategoryId,
      decoration: const InputDecoration(
        labelText: 'Categoria',
        prefixIcon: Icon(Icons.category_outlined),
      ),
      items: _categories
          .map(
            (category) => DropdownMenuItem<int>(
              value: category.idAccountPlan,
              child: Text(category.description),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategoryId = value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const PageHeader(
            title: "Transações",
            showLogo: true,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TransactionTypeSelector(),
                  const SizedBox(height: 16),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Valor',
                      prefixText: 'R\$ ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryField(),
                  const SizedBox(height: 16),
                  const SelectorField(
                    label: 'Conta bancária',
                    hint: 'Selecione uma conta',
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                  const SizedBox(height: 16),
                  const DatePickerField(),
                  const SizedBox(height: 16),
                  const TextField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Descrição',
                      hintText: 'Descreva a transação',
                    ),
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
                      onPressed: () {
                        if (_categories.isNotEmpty &&
                            _selectedCategoryId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Selecione uma categoria.'),
                            ),
                          );
                          return;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Transação salva com sucesso.')),
                        );
                      },
                      child: const Text('Salvar transação'),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
