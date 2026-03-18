import 'package:flutter/material.dart';

import '../widgets/page_header.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/transactions_filter_bar.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      const _TransactionData('McDonald’s', 'NuBank', '- R\$ 50,00', Color(0xFFE85A5A)),
      const _TransactionData('Salário', 'Mercado Pago', '+ R\$ 6500,00', Color(0xFF00A889)),
      const _TransactionData('Uber', 'NuBank', '- R\$ 17,00', Color(0xFFE85A5A)),
      const _TransactionData('Mercado', 'Inter', '- R\$ 775,00', Color(0xFFE85A5A)),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5B1FA6),
        foregroundColor: Colors.white,
        title: const Text('Transações', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.tune)),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TransactionsFilterBar(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TransactionTile(
                    title: item.title,
                    subtitle: item.subtitle,
                    amount: item.amount,
                    amountColor: item.amountColor,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionData {
  final String title;
  final String subtitle;
  final String amount;
  final Color amountColor;

  const _TransactionData(this.title, this.subtitle, this.amount, this.amountColor);
}
