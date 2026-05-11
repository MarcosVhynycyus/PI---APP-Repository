import 'package:flutter/material.dart';
import '../models/account_model.dart';
import '../models/financial_movement_model.dart';
import '../services/balance_refresh_notifier.dart';
import '../services/banks_service.dart';
import '../services/finacial_movements_service.dart';
import '../widgets/balance_card.dart';
import '../widgets/expense_chart.dart';
import '../widgets/page_header.dart';
import '../widgets/recent_transactions_list.dart';
import '../widgets/section_header.dart';
import '../widgets/summary_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.onLogoTap,
    this.userInitial,
    this.financialMovementsService,
  });

  final VoidCallback? onLogoTap;
  final String? userInitial;
  final FinancialMovementsService? financialMovementsService;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _banksService = BanksService();
  late final FinancialMovementsService _financialMovementsService;

  bool _isLoadingBalance = true;
  double _userBalance = 0;
  String? _balanceError;
  bool _isLoadingAccounts = true;
  List<AccountModel> _accounts = [];
  String? _accountsError;
  bool _isLoadingExpenseChart = true;
  List<double> _monthlyExpenseValues = [];
  String? _expenseChartError;

  @override
  void initState() {
    super.initState();
    _financialMovementsService =
        widget.financialMovementsService ?? FinancialMovementsService();
    BalanceRefreshNotifier.listenable.addListener(
      _onBalanceShouldRefresh,
    );
    _loadUserBalance();
    _loadUserAccounts();
    _loadExpenseChartValues();
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
    _loadExpenseChartValues(showLoader: false);
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

  Future<void> _loadExpenseChartValues({bool showLoader = true}) async {
    if (showLoader) {
      setState(() {
        _isLoadingExpenseChart = true;
      });
    }

    try {
      final result =
          await _financialMovementsService.getUserFinancialMovements();
      final movements = result
          .whereType<Map>()
          .map((item) => FinancialMovementModel.fromJson(item))
          .toList();
      final values = buildMonthlyExpenseChartValues(
        movements,
        DateTime.now(),
      );

      if (!mounted) return;

      setState(() {
        _monthlyExpenseValues = values;
        _expenseChartError = null;
        _isLoadingExpenseChart = false;
      });
    } on FinancialMovementsException catch (e) {
      if (!mounted) return;
      setState(() {
        _expenseChartError = e.message;
        _isLoadingExpenseChart = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _expenseChartError = 'Erro ao carregar resumo mensal.';
        _isLoadingExpenseChart = false;
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
              PageHeader(
                title: 'Home',
                showLogo: true,
                onLogoTap: widget.onLogoTap,
                userInitial: widget.userInitial,
              ),
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
                    _buildExpenseChart(),
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

  Widget _buildExpenseChart() {
    if (_isLoadingExpenseChart) {
      return const _ChartPlaceholder(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_expenseChartError != null && _monthlyExpenseValues.isEmpty) {
      return _ChartPlaceholder(
        child: Row(
          children: [
            Expanded(
              child: Text(
                _expenseChartError!,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: _loadExpenseChartValues,
              child: const Text('Tentar'),
            ),
          ],
        ),
      );
    }

    return ExpenseChart(values: _monthlyExpenseValues);
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

class _ChartPlaceholder extends StatelessWidget {
  final Widget child;

  const _ChartPlaceholder({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 210),
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
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

@visibleForTesting
List<double> buildMonthlyExpenseChartValues(
  List<FinancialMovementModel> movements,
  DateTime referenceDate,
) {
  final weeklyTotals = List<double>.filled(5, 0);

  for (final movement in movements) {
    final movementDate = movement.movementDate;
    final isSameMonth = movementDate.year == referenceDate.year &&
        movementDate.month == referenceDate.month;

    if (!movement.isExpense || !isSameMonth || movement.value <= 0) {
      continue;
    }

    final weekIndex = (movementDate.day - 1) ~/ 7;
    final safeIndex =
        weekIndex >= weeklyTotals.length ? weeklyTotals.length - 1 : weekIndex;

    weeklyTotals[safeIndex] += movement.value;
  }

  final hasMovements = weeklyTotals.any((value) => value > 0);
  return hasMovements ? weeklyTotals : const [];
}
