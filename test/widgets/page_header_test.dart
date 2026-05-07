import 'package:finansme_flutter/src/widgets/app_logo.dart';
import 'package:finansme_flutter/src/widgets/page_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows provided user initial', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PageHeader(
            title: 'Home',
            showLogo: true,
            userInitial: 'm',
          ),
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('M'), findsOneWidget);
    expect(find.text('A'), findsNothing);
  });

  testWidgets('shows fallback avatar initial when user data is unavailable',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PageHeader(
            title: 'Home',
            userInitial: '   ',
          ),
        ),
      ),
    );

    expect(find.text('U'), findsOneWidget);
  });

  testWidgets('hides notification and search actions without callbacks',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PageHeader(title: 'Home'),
        ),
      ),
    );

    expect(find.byIcon(Icons.notifications_none), findsNothing);
    expect(find.byIcon(Icons.search), findsNothing);
  });

  testWidgets('calls optional action callbacks', (tester) async {
    var logoTaps = 0;
    var notificationTaps = 0;
    var searchTaps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PageHeader(
            title: 'Home',
            showLogo: true,
            onLogoTap: () => logoTaps++,
            onNotificationTap: () => notificationTaps++,
            onSearchTap: () => searchTaps++,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(AppLogo));
    await tester.tap(find.byIcon(Icons.notifications_none));
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();

    expect(logoTaps, 1);
    expect(notificationTaps, 1);
    expect(searchTaps, 1);
  });

  testWidgets('logo does not navigate without a callback', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PageHeader(
            title: 'Home',
            showLogo: true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(AppLogo));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Home'), findsOneWidget);
  });
}
