import 'package:flutter/material.dart';

import '../models/financial_movement_model.dart';
import '../services/balance_refresh_notifier.dart';
import '../services/finacial_movements_service.dart';
import 'transaction_tile.dart';

class RecentTransactionsList extends StatefulWidget {
  final FinancialMovementsService? financialMovementsService;
  final int limit;

  const RecentTransactionsList({
    super.key,
    this.financialMovementsService,
    this.limit = 3,
  });

  @override
  State<RecentTransactionsList> createState() => _RecentTransactionsListState();
}

class _RecentTransactionsListState extends State<RecentTransactionsList> {
  late final FinancialMovementsService _financialMovementsService;

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
        _movements = movements.take(widget.limit).toList();
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
        _error = 'Erro ao carregar transações recentes.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const _RecentTransactionsPlaceholder(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_error != null && _movements.isEmpty) {
      return _RecentTransactionsPlaceholder(
        child: Row(
          children: [
            Expanded(
              child: Text(
                _error!,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => _loadMovements(),
              child: const Text('Tentar'),
            ),
          ],
        ),
      );
    }

    if (_movements.isEmpty) {
      return const _RecentTransactionsPlaceholder(
        child: Text(
          'Nenhuma transação encontrada.',
          style: TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _movements.length,
      itemBuilder: (context, index) {
        final item = _movements[index];

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
    );
  }
}

class _RecentTransactionsPlaceholder extends StatelessWidget {
  final Widget child;

  const _RecentTransactionsPlaceholder({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}
