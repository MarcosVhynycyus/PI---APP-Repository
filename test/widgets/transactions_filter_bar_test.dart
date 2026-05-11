import 'package:finansme_flutter/src/widgets/transactions_filter_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('emits selected transaction filter', (tester) async {
    final selectedFilters = <TransactionsFilter>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TransactionsFilterBar(
            selectedFilter: TransactionsFilter.all,
            onChanged: selectedFilters.add,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Receitas'));
    await tester.pump();

    await tester.tap(find.text('Despesas'));
    await tester.pump();

    expect(selectedFilters, [
      TransactionsFilter.incomes,
      TransactionsFilter.expenses,
    ]);
  });
}
