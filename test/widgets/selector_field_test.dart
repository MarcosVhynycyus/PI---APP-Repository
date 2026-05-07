import 'package:finansme_flutter/src/widgets/selector_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows hint when no value is selected', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SelectorField(
            label: 'Categoria',
            hint: 'Selecione uma categoria',
            icon: Icons.category_outlined,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Categoria'), findsOneWidget);
    expect(find.text('Selecione uma categoria'), findsOneWidget);
  });

  testWidgets('shows selected value and calls onTap', (tester) async {
    var wasTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SelectorField(
            label: 'Conta bancária',
            hint: 'Selecione uma conta',
            icon: Icons.account_balance_wallet_outlined,
            value: 'Carteira',
            onTap: () {
              wasTapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Carteira'), findsOneWidget);
    expect(find.text('Selecione uma conta'), findsNothing);

    await tester.tap(find.text('Carteira'));
    await tester.pump();

    expect(wasTapped, isTrue);
  });
}
