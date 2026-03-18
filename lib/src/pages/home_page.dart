import 'package:flutter/material.dart';

import '../widgets/balance_card.dart';
import '../widgets/expense_chart.dart';
import '../widgets/page_header.dart';
import '../widgets/recent_transactions_list.dart';
import '../widgets/section_header.dart';
import '../widgets/summary_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              PageHeader(title: 'Home', showLogo: true),
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SummaryCard(),
                    SizedBox(height: 16),
                    BalanceCard(),
                    SizedBox(height: 16),
                    ExpenseChart(),
                    SizedBox(height: 16),
                    SectionHeader(title: 'Transações recentes'),
                    SizedBox(height: 12),
                    RecentTransactionsList(),
                    SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
