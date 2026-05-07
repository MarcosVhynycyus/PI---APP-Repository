import 'package:finansme_flutter/src/widgets/page_header.dart';
import 'package:flutter/material.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/transactions_filter_bar.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({
    super.key,
    this.onLogoTap,
    this.userInitial,
  });

  final VoidCallback? onLogoTap;
  final String? userInitial;

  @override
  Widget build(BuildContext context) {
    final items = [
      const _TransactionData(
          'McDonald’s', 'NuBank', '- R\$ 50,00', Color(0xFFE85A5A)),
      const _TransactionData(
          'Salário', 'Mercado Pago', '+ R\$ 6500,00', Color(0xFF00A889)),
      const _TransactionData(
          'Uber', 'NuBank', '- R\$ 17,00', Color(0xFFE85A5A)),
      const _TransactionData(
          'Mercado', 'Inter', '- R\$ 775,00', Color(0xFFE85A5A)),
    ];

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Transações',
            showLogo: true,
            onLogoTap: onLogoTap,
            userInitial: userInitial,
          ),
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

  const _TransactionData(
      this.title, this.subtitle, this.amount, this.amountColor);
}
