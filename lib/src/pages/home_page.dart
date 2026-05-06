import 'package:flutter/material.dart';
import '../services/balance_refresh_notifier.dart';
import '../services/banks_service.dart';
import '../widgets/balance_card.dart';
import '../widgets/expense_chart.dart';
import '../widgets/page_header.dart';
import '../widgets/recent_transactions_list.dart';
import '../widgets/section_header.dart';
import '../widgets/summary_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _banksService = BanksService();

  bool _isLoadingBalance = true;
  double _userBalance = 0;
  String? _balanceError;

  @override
  void initState() {
    super.initState();
    BalanceRefreshNotifier.listenable.addListener(
      _onBalanceShouldRefresh,
    );
    _loadUserBalance();
  }

  @override
  void dispose() {
    BalanceRefreshNotifier.listenable.removeListener(
      _onBalanceShouldRefresh,
    );
    super.dispose();
  }

  void _onBalanceShouldRefresh() {
    if (!mounted) return;
    _loadUserBalance(showLoader: false);
  }

  Future<void> _loadUserBalance({bool showLoader = true}) async {
    if (showLoader) {
      setState(() {
        _isLoadingBalance = true;
      });
    }

    try {
      final balance = await _banksService.getUserBalance();
      if (!mounted) return;

      setState(() {
        _userBalance = balance;
        _balanceError = null;
        _isLoadingBalance = false;
      });
    } on BanksException catch (e) {
      if (!mounted) return;
      setState(() {
        _balanceError = e.message;
        _isLoadingBalance = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _balanceError = 'Erro ao carregar saldo.';
        _isLoadingBalance = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(title: 'Home', showLogo: true),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SummaryCard(
                      isLoading: _isLoadingBalance,
                      totalBalance: _userBalance,
                      errorMessage: _balanceError,
                      onRetry: () => _loadUserBalance(),
                    ),
                    const SizedBox(height: 16),
                    const BalanceCard(),
                    const SizedBox(height: 16),
                    const ExpenseChart(),
                    const SizedBox(height: 16),
                    const SectionHeader(title: 'Transações recentes'),
                    const SizedBox(height: 12),
                    const RecentTransactionsList(),
                    const SizedBox(height: 100),
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
