import 'package:flutter/material.dart';

class BankAccountData {
  final int id;
  final String description;
  final double balance;
  final Color color;
  final String? account;
  final String? agency;

  const BankAccountData({
    required this.id,
    required this.description,
    required this.balance,
    required this.color,
    this.account,
    this.agency,
  });
}

class BankAccountCard extends StatelessWidget {
  final BankAccountData data;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BankAccountCard({
    super.key,
    required this.data,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
                  Text(
                    data.description,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (_hasAccountDetails) ...[
                    const SizedBox(height: 6),
                    if (_hasValue(data.account))
                      Text(
                        data.account!,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    if (_hasValue(data.agency))
                      Text(
                        data.agency!,
                        style: const TextStyle(color: Colors.black54),
                      ),
                  ],
                  const SizedBox(height: 14),
                  Text(
                    'Saldo: ${_formatCurrency(data.balance)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
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
                    itemBuilder: (_) => [
                      if (onEdit != null)
                        const PopupMenuItem(
                          value: _BankAccountAction.edit,
                          child: Text('Editar'),
                        ),
                      if (onDelete != null)
                        const PopupMenuItem(
                          value: _BankAccountAction.delete,
                          child: Text('Excluir'),
                        ),
                    ],
                  )
                : const Icon(
                    Icons.account_balance,
                    color: Color(0xFF5B1FA6),
                  ),
          ],
        ),
      ),
    );
  }

  bool get _hasAccountDetails =>
      _hasValue(data.account) || _hasValue(data.agency);

  bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;

  String _formatCurrency(double value) {
    final fixed = value.toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $fixed';
  }
}

enum _BankAccountAction {
  edit,
  delete,
}
