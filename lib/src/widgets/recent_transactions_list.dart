import 'package:flutter/material.dart';

import 'transaction_tile.dart';

class RecentTransactionsList extends StatelessWidget {
  const RecentTransactionsList({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      ('Mercado', 'NuBank', '- R\$ 70,00', Color(0xFFE85A5A)),
      ('Freela', 'Inter', '+ R\$ 900,00', Color(0xFF00A889)),
      ('Cinema', 'Mercado Pago', '- R\$ 45,00', Color(0xFFE85A5A)),
    ];

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TransactionTile(
            title: item.$1,
            subtitle: item.$2,
            amount: item.$3,
            amountColor: item.$4,
          ),
        );
      },
    );
  }
}
