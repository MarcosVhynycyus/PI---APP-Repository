class TransactorModel {
  final int idTransactor;
  final String name;

  const TransactorModel({
    required this.idTransactor,
    required this.name,
  });

  factory TransactorModel.fromJson(Map<String, dynamic> json) {
    final idRaw = json['id_transator'] ?? json['idTransactor'];
    final name = (json['name'] ?? json['description'] ?? '').toString().trim();

    final idTransactor = _parseId(idRaw);

    if (name.isEmpty) {
      throw const FormatException('Transactor name is missing.');
    }

    return TransactorModel(
      idTransactor: idTransactor,
      name: name,
    );
  }

  static int _parseId(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    final parsed = int.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;

    throw const FormatException('Invalid transactor id.');
  }
}
