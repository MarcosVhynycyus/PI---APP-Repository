import 'package:finansme_flutter/src/models/financial_movement_model.dart';
import 'package:finansme_flutter/src/pages/home_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('groups current month expenses by week of month', () {
    final values = buildMonthlyExpenseChartValues(
      [
        _movement(
          id: 1,
          typeMovementId: FinancialMovementModel.expenseMovementId,
          movementDate: DateTime(2026, 5),
          value: 10,
        ),
        _movement(
          id: 2,
          typeMovementId: FinancialMovementModel.expenseMovementId,
          movementDate: DateTime(2026, 5, 8),
          value: 20,
        ),
        _movement(
          id: 3,
          typeMovementId: FinancialMovementModel.expenseMovementId,
          movementDate: DateTime(2026, 5, 29),
          value: 30,
        ),
      ],
      DateTime(2026, 5, 11),
    );

    expect(values, [10, 20, 0, 0, 30]);
  });

  test('ignores incomes and movements outside the current month', () {
    final values = buildMonthlyExpenseChartValues(
      [
        _movement(
          id: 1,
          typeMovementId: FinancialMovementModel.incomeMovementId,
          movementDate: DateTime(2026, 5, 10),
          value: 1000,
        ),
        _movement(
          id: 2,
          typeMovementId: FinancialMovementModel.expenseMovementId,
          movementDate: DateTime(2026, 4, 30),
          value: 50,
        ),
        _movement(
          id: 3,
          typeMovementId: FinancialMovementModel.expenseMovementId,
          movementDate: DateTime(2026, 6),
          value: 60,
        ),
      ],
      DateTime(2026, 5, 11),
    );

    expect(values, isEmpty);
  });
}

FinancialMovementModel _movement({
  required int id,
  required int typeMovementId,
  required DateTime movementDate,
  required double value,
}) {
  return FinancialMovementModel(
    idFinancialMovement: id,
    typeMovementId: typeMovementId,
    movementDate: movementDate,
    docNum: '',
    value: value,
    reason: 'Movimentação',
  );
}
