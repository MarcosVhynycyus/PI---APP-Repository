import 'package:finansme_flutter/src/widgets/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('calls callback when tapped', (tester) async {
    var tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SettingsTile(
            icon: Icons.person_outline,
            title: 'Meu Perfil',
            onTap: () => tapCount++,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Meu Perfil'));
    await tester.pump();

    expect(tapCount, 1);
  });

  testWidgets('uses optional icon color and trailing widget', (tester) async {
    const customColor = Color(0xFFB00020);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SettingsTile(
            icon: Icons.lock_outline,
            title: 'Alterar senha',
            iconColor: customColor,
            trailing: Icon(Icons.edit_outlined),
          ),
        ),
      ),
    );

    final leadingIcon = tester.widget<Icon>(
      find.byIcon(Icons.lock_outline),
    );

    expect(leadingIcon.color, customColor);
    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsNothing);
  });
}
