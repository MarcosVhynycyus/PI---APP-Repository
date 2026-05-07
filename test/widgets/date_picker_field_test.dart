import 'package:finansme_flutter/src/widgets/date_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows hint when no date is selected', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DatePickerField(
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Data'), findsOneWidget);
    expect(find.text('Selecione uma data'), findsOneWidget);
  });

  testWidgets('shows formatted selected date', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DatePickerField(
            selectedDate: DateTime(2026, 5, 7),
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('07/05/2026'), findsOneWidget);
    expect(find.text('Selecione uma data'), findsNothing);
  });

  testWidgets('calls onTap when tapped', (tester) async {
    var wasTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DatePickerField(
            onTap: () {
              wasTapped = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Selecione uma data'));
    await tester.pump();

    expect(wasTapped, isTrue);
  });
}
