import 'package:flutter/material.dart';

class SelectorField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final String? value;
  final VoidCallback onTap;

  const SelectorField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.onTap,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final selectedValue = value?.trim();
    final hasValue = selectedValue != null && selectedValue.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF5B1FA6)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hasValue ? selectedValue : hint,
                    style: TextStyle(
                      color: hasValue ? Colors.black87 : Colors.black54,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
