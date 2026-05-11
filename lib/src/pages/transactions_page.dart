import 'package:flutter/material.dart';

import '../models/financial_movement_model.dart';
import '../services/balance_refresh_notifier.dart';
import '../services/finacial_movements_service.dart';
import '../widgets/page_header.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/transactions_filter_bar.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({
    super.key,
    this.onLogoTap,
    this.userInitial,
    this.financialMovementsService,
  });

  final VoidCallback? onLogoTap;
  final String? userInitial;
  final FinancialMovementsService? financialMovementsService;

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  late final FinancialMovementsService _financialMovementsService;

  var _selectedFilter = TransactionsFilter.all;
  var _isLoading = true;
  String? _error;
  List<FinancialMovementModel> _movements = [];

  @override
  void initState() {
    super.initState();
    _financialMovementsService =
        widget.financialMovementsService ?? FinancialMovementsService();
    BalanceRefreshNotifier.listenable.addListener(_onMovementsShouldRefresh);
    _loadMovements();
  }

  @override
  void dispose() {
    BalanceRefreshNotifier.listenable.removeListener(_onMovementsShouldRefresh);
    super.dispose();
  }

  void _onMovementsShouldRefresh() {
    if (!mounted) return;
    _loadMovements(showLoader: false);
  }

  Future<void> _loadMovements({bool showLoader = true}) async {
    if (showLoader) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final result =
          await _financialMovementsService.getUserFinancialMovements();
      final movements = result
          .whereType<Map>()
          .map((item) => FinancialMovementModel.fromJson(item))
          .toList()
        ..sort(FinancialMovementModel.compareMostRecentFirst);

      if (!mounted) return;

      setState(() {
        _movements = movements;
        _error = null;
        _isLoading = false;
      });
    } on FinancialMovementsException catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = 'Erro ao carregar transações.';
        _isLoading = false;
      });
    }
  }

  List<FinancialMovementModel> get _filteredMovements {
    return switch (_selectedFilter) {
      TransactionsFilter.all => _movements,
      TransactionsFilter.incomes =>
        _movements.where((movement) => movement.isIncome).toList(),
      TransactionsFilter.expenses =>
        _movements.where((movement) => movement.isExpense).toList(),
    };
  }

  void _selectFilter(TransactionsFilter filter) {
    if (_selectedFilter == filter) return;

    setState(() {
      _selectedFilter = filter;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Transações',
            showLogo: true,
            onLogoTap: widget.onLogoTap,
            userInitial: widget.userInitial,
          ),
          TransactionsFilterBar(
            selectedFilter: _selectedFilter,
            onChanged: _selectFilter,
          ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _movements.isEmpty) {
      return _TransactionsMessage(
        message: _error!,
        actionLabel: 'Tentar novamente',
        onAction: () => _loadMovements(),
      );
    }

    final filteredMovements = _filteredMovements;

    if (filteredMovements.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _loadMovements(showLoader: false),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            _TransactionsEmptyMessage(
              text: _movements.isEmpty
                  ? 'Nenhuma transação encontrada.'
                  : 'Nenhuma transação para este filtro.',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadMovements(showLoader: false),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredMovements.length,
        itemBuilder: (context, index) {
          final item = filteredMovements[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TransactionTile(
              title: item.title,
              subtitle: item.subtitle,
              amount: item.formattedAmount,
              amountColor: item.isIncome
                  ? const Color(0xFF00A889)
                  : const Color(0xFFE85A5A),
            ),
          );
        },
      ),
    );
  }
}

class _TransactionsMessage extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _TransactionsMessage({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onAction,
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionsEmptyMessage extends StatelessWidget {
  final String text;

  const _TransactionsEmptyMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
