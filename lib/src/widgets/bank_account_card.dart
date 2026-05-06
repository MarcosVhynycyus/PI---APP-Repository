import 'package:flutter/material.dart';

class BankAccountData {
  final String name;
  final String account;
  final String agency;
  final String balance;
  final Color color;

  const BankAccountData({
    required this.name,
    required this.account,
    required this.agency,
    required this.balance,
    required this.color,
  });
}

class BankAccountCard extends StatelessWidget {
  final BankAccountData data;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BankAccountCard({
    super.key,
    required this.data,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 92,
            decoration: BoxDecoration(
              color: data.color,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 6),
                Text(data.account,
                    style: const TextStyle(color: Colors.black54)),
                Text(data.agency,
                    style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 14),
                Text('Saldo: ${data.balance}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          onEdit != null || onDelete != null
              ? PopupMenuButton<_BankAccountAction>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: Color(0xFF5B1FA6),
                  ),
                  onSelected: (action) {
                    if (action == _BankAccountAction.edit) {
                      onEdit?.call();
                      return;
                    }

                    onDelete?.call();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: _BankAccountAction.edit,
                      child: Text('Editar'),
                    ),
                    PopupMenuItem(
                      value: _BankAccountAction.delete,
                      child: Text('Excluir'),
                    ),
                  ],
                )
              : const Icon(Icons.account_balance, color: Color(0xFF5B1FA6)),
        ],
      ),
    );
  }
}

enum _BankAccountAction {
  edit,
  delete,
}
