import 'package:finansme_flutter/src/models/financial_movement_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses and formats an income movement from the API contract', () {
    final movement = FinancialMovementModel.fromJson({
      'id_financial_movement': 7,
      'type_movement_id': 1,
      'movement_date': '2026-05-11',
      'doc_num': 'NF-10',
      'value': 1250.5,
      'reason': 'Salário',
    });

    expect(movement.isIncome, isTrue);
    expect(movement.isExpense, isFalse);
    expect(movement.title, 'Salário');
    expect(movement.subtitle, 'Doc. NF-10 • 11/05/2026');
    expect(movement.formattedAmount, '+ R\$ 1250,50');
  });

  test('sorts movements by newest date and then highest id', () {
    final movements = [
      FinancialMovementModel.fromJson({
        'id_financial_movement': 1,
        'type_movement_id': 2,
        'movement_date': '2026-05-10',
        'value': 10,
        'reason': 'Antiga',
      }),
      FinancialMovementModel.fromJson({
        'id_financial_movement': 2,
        'type_movement_id': 2,
        'movement_date': '2026-05-11',
        'value': 20,
        'reason': 'Recente',
      }),
      FinancialMovementModel.fromJson({
        'id_financial_movement': 3,
        'type_movement_id': 2,
        'movement_date': '2026-05-11',
        'value': 30,
        'reason': 'Mais recente no mesmo dia',
      }),
    ]..sort(FinancialMovementModel.compareMostRecentFirst);

    expect(
      movements.map((movement) => movement.idFinancialMovement),
      [3, 2, 1],
    );
  });
}
