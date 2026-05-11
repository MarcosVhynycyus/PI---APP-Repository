import 'package:finansme_flutter/src/widgets/expense_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('normalizes chart values proportionally', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ExpenseChart(
            title: 'Resumo de despesas',
            values: [10, 20, 0],
          ),
        ),
      ),
    );

    final firstBar = tester.widget<Container>(
      find.byKey(const ValueKey('expense-chart-bar-0')),
    );
    final secondBar = tester.widget<Container>(
      find.byKey(const ValueKey('expense-chart-bar-1')),
    );
    final thirdBar = tester.widget<Container>(
      find.byKey(const ValueKey('expense-chart-bar-2')),
    );

    expect(find.text('Resumo de despesas'), findsOneWidget);
    expect(firstBar.constraints?.maxHeight, 60);
    expect(secondBar.constraints?.maxHeight, 120);
    expect(thirdBar.constraints?.maxHeight, 0);
  });

  testWidgets('shows empty state when there are no chart values',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ExpenseChart(values: []),
        ),
      ),
    );

    expect(find.text('Resumo mensal'), findsOneWidget);
    expect(find.text('Nenhuma movimentação no período.'), findsOneWidget);
    expect(find.byKey(const ValueKey('expense-chart-bar-0')), findsNothing);
  });

  testWidgets('shows empty state when every chart value is zero',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ExpenseChart(values: [0, 0, 0]),
        ),
      ),
    );

    expect(find.text('Nenhuma movimentação no período.'), findsOneWidget);
    expect(find.byKey(const ValueKey('expense-chart-bar-0')), findsNothing);
  });
}
