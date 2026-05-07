class AccountModel {
  final int idAccount;
  final String description;
  final double balance;

  const AccountModel({
    required this.idAccount,
    required this.description,
    required this.balance,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    final idRaw = json['id_account'] ?? json['idAccount'];
    final balanceRaw = json['balance'];

    final idAccount = _parseId(idRaw);
    final balance = _parseBalance(balanceRaw);
    final description = (json['description'] ?? '').toString().trim();

    if (description.isEmpty) {
      throw const FormatException('Account description is missing.');
    }

    return AccountModel(
      idAccount: idAccount,
      description: description,
      balance: balance,
    );
  }

  static int _parseId(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    final parsed = int.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;

    throw const FormatException('Invalid account id.');
  }

  static double _parseBalance(dynamic value) {
    if (value is num) return value.toDouble();

    final raw = value?.toString().trim() ?? '';
    final parsed = double.tryParse(raw.replaceAll(',', '.'));
    if (parsed != null) return parsed;

    throw const FormatException('Invalid account balance.');
  }
}
