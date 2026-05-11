class FinancialMovementModel {
  static const incomeMovementId = 1;
  static const expenseMovementId = 2;

  final int idFinancialMovement;
  final int typeMovementId;
  final DateTime movementDate;
  final String docNum;
  final double value;
  final String reason;

  const FinancialMovementModel({
    required this.idFinancialMovement,
    required this.typeMovementId,
    required this.movementDate,
    required this.docNum,
    required this.value,
    required this.reason,
  });

  factory FinancialMovementModel.fromJson(Map<dynamic, dynamic> json) {
    final id = _parseInt(json['id_financial_movement']);
    final reason = (json['reason'] ?? '').toString().trim();

    return FinancialMovementModel(
      idFinancialMovement: id,
      typeMovementId: _parseInt(json['type_movement_id']),
      movementDate: _parseDate(json['movement_date']),
      docNum: (json['doc_num'] ?? '').toString().trim(),
      value: _parseDouble(json['value']),
      reason: reason.isEmpty ? 'Movimentação #$id' : reason,
    );
  }

  bool get isIncome => typeMovementId == incomeMovementId;

  bool get isExpense => typeMovementId == expenseMovementId;

  String get title => reason;

  String get subtitle {
    final parts = [
      if (docNum.isNotEmpty) 'Doc. $docNum',
      _formatDate(movementDate),
    ];

    return parts.join(' • ');
  }

  String get formattedAmount {
    final sign = isIncome ? '+' : '-';
    final fixed = value.toStringAsFixed(2).replaceAll('.', ',');

    return '$sign R\$ $fixed';
  }

  static int compareMostRecentFirst(
    FinancialMovementModel left,
    FinancialMovementModel right,
  ) {
    final dateComparison = right.movementDate.compareTo(left.movementDate);
    if (dateComparison != 0) return dateComparison;

    return right.idFinancialMovement.compareTo(left.idFinancialMovement);
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();

    final raw = value?.toString().trim() ?? '';
    return double.tryParse(raw.replaceAll(',', '.')) ?? 0;
  }

  static DateTime _parseDate(dynamic value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    return parsed ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  static String _formatDate(DateTime date) {
    if (date.millisecondsSinceEpoch == 0) return 'Data não informada';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year.toString().padLeft(4, '0')}';
  }
}
