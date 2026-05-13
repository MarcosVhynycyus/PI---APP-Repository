import 'package:finansme_flutter/src/widgets/transaction_type_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('emits documented movement type ids', (tester) async {
    final selectedIds = <int>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TransactionTypeSelector(
            selectedTypeMovementId: TransactionTypeSelector.expenseMovementId,
            onChanged: selectedIds.add,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Receita'));
    await tester.pump();

    await tester.tap(find.text('Despesa'));
    await tester.pump();

    expect(selectedIds, [
      TransactionTypeSelector.incomeMovementId,
      TransactionTypeSelector.expenseMovementId,
    ]);
  });
}
