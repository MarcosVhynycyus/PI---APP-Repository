import 'package:flutter/material.dart';

class DatePickerField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final DateTime? selectedDate;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const DatePickerField({
    super.key,
    required this.onTap,
    this.label = 'Data',
    this.hint = 'Selecione uma data',
    this.icon = Icons.calendar_month_outlined,
    this.selectedDate,
    this.onClear,
  });

  String get _displayText {
    final date = selectedDate;
    if (date == null) return hint;

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year.toString().padLeft(4, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final hasSelectedDate = selectedDate != null;

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
                    _displayText,
                    style: TextStyle(
                      color: hasSelectedDate ? Colors.black87 : Colors.black54,
                    ),
                  ),
                ),
                if (hasSelectedDate && onClear != null)
                  IconButton(
                    onPressed: onClear,
                    icon: const Icon(Icons.close),
                    tooltip: 'Limpar data',
                  )
                else
                  const Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
