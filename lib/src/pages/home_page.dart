import 'package:flutter/material.dart';
import '../models/account_model.dart';
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
  bool _isLoadingAccounts = true;
  List<AccountModel> _accounts = [];
  String? _accountsError;

  @override
  void initState() {
    super.initState();
    BalanceRefreshNotifier.listenable.addListener(
      _onBalanceShouldRefresh,
    );
    _loadUserBalance();
    _loadUserAccounts();
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
    _loadUserAccounts(showLoader: false);
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

  Future<void> _loadUserAccounts({bool showLoader = true}) async {
    if (showLoader) {
      setState(() {
        _isLoadingAccounts = true;
      });
    }

    try {
      final accounts = await _banksService.getUserAccounts();
      if (!mounted) return;

      setState(() {
        _accounts = accounts;
        _accountsError = null;
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
                    _buildAccountBalanceCard(),
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

  Widget _buildAccountBalanceCard() {
    if (_isLoadingAccounts) {
      return const _AccountBalancePlaceholder(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_accountsError != null && _accounts.isEmpty) {
      return _AccountBalancePlaceholder(
        child: Row(
          children: [
            Expanded(
              child: Text(
                _accountsError!,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: _loadUserAccounts,
              child: const Text('Tentar'),
            ),
          ],
        ),
      );
    }

    if (_accounts.isEmpty) {
      return const _AccountBalancePlaceholder(
        child: Text(
          'Nenhuma conta cadastrada.',
          style: TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final account = _accounts.first;

    return BalanceCard(
      title: account.description,
      balance: account.balance,
      subtitle: 'Conta financeira',
      color: _getAccountColor(account.idAccount),
    );
  }

  Color _getAccountColor(int id) {
    const colors = [
      Color(0xFFF2C300),
      Color(0xFF5C4DB1),
      Color(0xFF53B6F0),
      Color(0xFF00C853),
      Color(0xFFD50000),
    ];

    return colors[id % colors.length];
  }
}

class _AccountBalancePlaceholder extends StatelessWidget {
  final Widget child;

  const _AccountBalancePlaceholder({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 122),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: child,
      ),
    );
  }
}
