import 'package:flutter/material.dart';

class TransactorCardData {
  final String name;
  final Color color;

  const TransactorCardData({
    required this.name,
    required this.color,
  });
}

class TransactorCard extends StatelessWidget {
  final TransactorCardData data;

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TransactorCard({
    super.key,
    required this.data,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 90,
            margin: const EdgeInsets.only(
              left: 16,
              top: 16,
              bottom: 16,
            ),
            decoration: BoxDecoration(
              color: data.color,
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          const SizedBox(width: 20),

          Expanded(
            child: Text(
              data.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E1E),
              ),
            ),
          ),

          IconButton(
            onPressed: onEdit,
            icon: const Icon(
              Icons.edit_outlined,
              color: Color(0xFF5C4DB1),
              size: 28,
            ),
          ),

          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline,
              color: Color(0xFFD50000),
              size: 28,
            ),
          ),

          const SizedBox(width: 12),
        ],
      ),
    );
  }
}