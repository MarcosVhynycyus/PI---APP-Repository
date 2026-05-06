import 'package:flutter/material.dart';

class AccountPlanCardData {
  final String description;
  final String code;
  final Color color;

  const AccountPlanCardData({
    required this.description,
    required this.code,
    required this.color,
  });
}

class AccountPlanCard extends StatelessWidget {
  final AccountPlanCardData data;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AccountPlanCard({
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
            height: 72,
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
                const SizedBox(height: 6),
                Text(
                  data.code,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          onEdit != null || onDelete != null
              ? PopupMenuButton<_AccountPlanAction>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: Color(0xFF5B1FA6),
                  ),
                  onSelected: (action) {
                    if (action == _AccountPlanAction.edit) {
                      onEdit?.call();
                      return;
                    }

                    onDelete?.call();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: _AccountPlanAction.edit,
                      child: Text('Editar'),
                    ),
                    PopupMenuItem(
                      value: _AccountPlanAction.delete,
                      child: Text('Excluir'),
                    ),
                  ],
                )
              : const Icon(Icons.category, color: Color(0xFF5B1FA6)),
        ],
      ),
    );
  }
}

enum _AccountPlanAction {
  edit,
  delete,
}
