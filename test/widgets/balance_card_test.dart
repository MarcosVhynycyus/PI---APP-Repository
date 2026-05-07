import 'package:finansme_flutter/src/widgets/balance_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows account data from the API contract', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BalanceCard(
            title: 'Carteira',
            balance: 1250.5,
            subtitle: 'Conta financeira',
          ),
        ),
      ),
    );

    expect(find.text('Carteira'), findsOneWidget);
    expect(find.text('Conta financeira'), findsOneWidget);
    expect(find.text('Saldo disponível'), findsOneWidget);
    expect(find.text('R\$ 1250,50'), findsOneWidget);
    expect(find.text('NuBank'), findsNothing);
    expect(find.textContaining('Ag'), findsNothing);
    expect(find.textContaining('Cc'), findsNothing);
    expect(find.textContaining('Limite'), findsNothing);
  });
}
