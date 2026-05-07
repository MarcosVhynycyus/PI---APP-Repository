class AccountPlanModel {
  final int idAccountPlan;
  final String description;

  const AccountPlanModel({
    required this.idAccountPlan,
    required this.description,
  });

  factory AccountPlanModel.fromJson(Map<String, dynamic> json) {
    final idRaw = json['id_account_plan'] ?? json['idAccountPlan'];
    final description = (json['description'] ?? '').toString().trim();

    final idAccountPlan = _parseId(idRaw);

    if (description.isEmpty) {
      throw const FormatException('Account plan description is missing.');
    }

    return AccountPlanModel(
      idAccountPlan: idAccountPlan,
      description: description,
    );
  }

  static int _parseId(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    final parsed = int.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;

    throw const FormatException('Invalid account plan id.');
  }
}
