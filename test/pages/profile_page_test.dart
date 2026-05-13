import 'package:finansme_flutter/src/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('opens profile dialog from profile tile', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProfilePage(),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Meu Perfil'));
    await tester.pumpAndSettle();

    expect(find.text('Editar perfil'), findsOneWidget);
    expect(find.text('Nome'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
  });

  testWidgets('calls accounts callback from account tile', (tester) async {
    var accountTaps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: ProfilePage(
          onOpenAccounts: () => accountTaps++,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Minha Conta'));
    await tester.pump();

    expect(accountTaps, 1);
  });

  testWidgets('opens password dialog from security tile', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProfilePage(),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Alterar senha'));
    await tester.pumpAndSettle();

    expect(find.text('Alterar senha'), findsWidgets);
    expect(find.text('Nova senha'), findsOneWidget);
    expect(find.text('Confirmar senha'), findsOneWidget);
  });
}
