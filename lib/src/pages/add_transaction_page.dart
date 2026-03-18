import 'package:flutter/material.dart';

import '../widgets/date_picker_field.dart';
import '../widgets/selector_field.dart';
import '../widgets/transaction_type_selector.dart';

class AddTransactionPage extends StatelessWidget {
  const AddTransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova transação'),
        backgroundColor: const Color(0xFF5B1FA6),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
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
              const SelectorField(
                label: 'Categoria',
                hint: 'Selecione uma categoria',
                icon: Icons.category_outlined,
              ),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Transação salva com sucesso.')),
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
    );
  }
}
