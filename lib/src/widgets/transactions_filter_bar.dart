import 'package:flutter/material.dart';

enum TransactionsFilter {
  all,
  incomes,
  expenses,
}

class TransactionsFilterBar extends StatelessWidget {
  final TransactionsFilter selectedFilter;
  final ValueChanged<TransactionsFilter> onChanged;

  const TransactionsFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const filters = [
      _TransactionFilterOption(TransactionsFilter.all, 'Todas'),
      _TransactionFilterOption(TransactionsFilter.incomes, 'Receitas'),
      _TransactionFilterOption(TransactionsFilter.expenses, 'Despesas'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: filters
            .map(
              (filter) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  selected: filter.value == selectedFilter,
                  label: Text(filter.label),
                  onSelected: (_) => onChanged(filter.value),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _TransactionFilterOption {
  final TransactionsFilter value;
  final String label;

  const _TransactionFilterOption(this.value, this.label);
}
