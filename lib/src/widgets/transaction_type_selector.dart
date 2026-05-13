import 'package:flutter/material.dart';

class TransactionTypeSelector extends StatelessWidget {
  final int selectedTypeMovementId;
  final ValueChanged<int> onChanged;

  const TransactionTypeSelector({
    super.key,
    required this.selectedTypeMovementId,
    required this.onChanged,
  });

  static const incomeMovementId = 1;
  static const expenseMovementId = 2;

  @override
  Widget build(BuildContext context) {
    final isExpenseSelected = selectedTypeMovementId == expenseMovementId;
    final isIncomeSelected = selectedTypeMovementId == incomeMovementId;

    return Row(
      children: [
        Expanded(
          child: _TransactionTypeButton(
            isSelected: isExpenseSelected,
            icon: Icons.arrow_downward,
            label: 'Despesa',
            onPressed: () => onChanged(expenseMovementId),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TransactionTypeButton(
            isSelected: isIncomeSelected,
            icon: Icons.arrow_upward,
            label: 'Receita',
            onPressed: () => onChanged(incomeMovementId),
          ),
        ),
      ],
    );
  }
}

class _TransactionTypeButton extends StatelessWidget {
  final bool isSelected;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _TransactionTypeButton({
    required this.isSelected,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );

    if (isSelected) {
      return FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF5B1FA6),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: shape,
        ),
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      );
    }

    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF5B1FA6),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: shape,
      ),
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
