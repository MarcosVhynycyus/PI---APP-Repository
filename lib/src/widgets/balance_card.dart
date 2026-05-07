import 'package:flutter/material.dart';

class BalanceCard extends StatelessWidget {
  final String title;
  final double balance;
  final String? subtitle;
  final Color? color;

  const BalanceCard({
    super.key,
    required this.title,
    required this.balance,
    this.subtitle,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
            width: 18,
            height: 86,
            decoration: BoxDecoration(
              color: color ?? const Color(0xFFF2C300),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
                const SizedBox(height: 14),
                const Text(
                  'Saldo disponível',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatCurrency(balance),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    final fixed = value.toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $fixed';
  }
}
