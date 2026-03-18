import 'package:flutter/material.dart';

class TransactionsFilterBar extends StatelessWidget {
  const TransactionsFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final filters = ['Todas', 'Receitas', 'Despesas'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: filters
            .map(
              (filter) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  selected: filter == 'Todas',
                  label: Text(filter),
                  onSelected: (_) {},
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
