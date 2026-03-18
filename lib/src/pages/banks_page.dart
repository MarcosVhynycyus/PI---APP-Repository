import 'package:flutter/material.dart';

import '../widgets/bank_account_card.dart';

class BanksPage extends StatelessWidget {
  const BanksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final banks = const [
      BankAccountData(name: 'NuBank', account: 'Cc: 00000', agency: 'Ag: 00000-0', balance: 'R\$ 2.350,00', color: Color(0xFFF2C300)),
      BankAccountData(name: 'Inter', account: 'Cc: 00001', agency: 'Ag: 00000-1', balance: 'R\$ 5.780,90', color: Color(0xFF5C4DB1)),
      BankAccountData(name: 'Mercado Pago', account: 'Cc: 00002', agency: 'Ag: 00000-2', balance: 'R\$ 980,00', color: Color(0xFF53B6F0)),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contas'),
        backgroundColor: const Color(0xFF5B1FA6),
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: banks.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: BankAccountCard(data: banks[index]),
        ),
      ),
    );
  }
}
