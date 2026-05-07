import 'package:finansme_flutter/src/widgets/profile_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows provided profile data', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileHeader(
            name: 'Ana Silva',
            email: 'ana@finansme.com',
          ),
        ),
      ),
    );

    expect(find.text('Ana Silva'), findsOneWidget);
    expect(find.text('ana@finansme.com'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('Nome do usuário'), findsNothing);
    expect(find.text('usuario@finansme.com'), findsNothing);
  });

  testWidgets('shows fallback data when profile data is unavailable',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileHeader(
            name: '   ',
            email: '',
          ),
        ),
      ),
    );

    expect(find.text('Usuário'), findsOneWidget);
    expect(find.text('E-mail não informado'), findsOneWidget);
    expect(find.text('U'), findsOneWidget);
  });

  testWidgets('calls settings callback when settings icon is tapped',
      (tester) async {
    var tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileHeader(
            name: 'Bruno Costa',
            email: 'bruno@finansme.com',
            onSettingsTap: () => tapCount++,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pump();

    expect(tapCount, 1);
  });
}
