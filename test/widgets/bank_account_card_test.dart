import 'package:finansme_flutter/src/widgets/bank_account_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows account data from the API contract', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BankAccountCard(
            data: BankAccountData(
              id: 1,
              description: 'Carteira',
              balance: 1250.5,
              color: Color(0xFFF2C300),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Carteira'), findsOneWidget);
    expect(find.text('Saldo: R\$ 1250,50'), findsOneWidget);
    expect(find.textContaining('Conta:'), findsNothing);
    expect(find.textContaining('Agencia:'), findsNothing);
  });

  testWidgets('shows optional account details when available', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BankAccountCard(
            data: BankAccountData(
              id: 2,
              description: 'Banco Inter',
              balance: 90,
              color: Color(0xFF5C4DB1),
              account: 'Conta: 12345',
              agency: 'Agencia: 0001',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Banco Inter'), findsOneWidget);
    expect(find.text('Conta: 12345'), findsOneWidget);
    expect(find.text('Agencia: 0001'), findsOneWidget);
    expect(find.text('Saldo: R\$ 90,00'), findsOneWidget);
  });

  testWidgets('calls tap, edit and delete callbacks', (tester) async {
    var tapCount = 0;
    var editCount = 0;
    var deleteCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BankAccountCard(
            data: const BankAccountData(
              id: 3,
              description: 'Nubank',
              balance: 300,
              color: Color(0xFF53B6F0),
            ),
            onTap: () => tapCount++,
            onEdit: () => editCount++,
            onDelete: () => deleteCount++,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Nubank'));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();

    expect(tapCount, 1);
    expect(editCount, 1);
    expect(deleteCount, 1);
  });
}
