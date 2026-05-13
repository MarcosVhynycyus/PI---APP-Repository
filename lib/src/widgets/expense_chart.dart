import 'package:flutter/material.dart';

class ExpenseChart extends StatelessWidget {
  final List<double> values;
  final String title;

  const ExpenseChart({
    super.key,
    required this.values,
    this.title = 'Resumo mensal',
  });

  static const _chartHeight = 140.0;
  static const _maxBarHeight = 120.0;

  @override
  Widget build(BuildContext context) {
    final bars = _normalizeValues(values);

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          bars.isEmpty ? const _EmptyChartMessage() : _ChartBars(bars: bars),
        ],
      ),
    );
  }

  List<double> _normalizeValues(List<double> values) {
    final maxValue = values.fold<double>(
      0,
      (max, value) => value > max ? value : max,
    );

    if (maxValue <= 0) return const [];

    return values.map((value) => value <= 0 ? 0.0 : value / maxValue).toList();
  }
}

class _ChartBars extends StatelessWidget {
  final List<double> bars;

  const _ChartBars({required this.bars});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ExpenseChart._chartHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: bars.asMap().entries.map(
          (entry) {
            final index = entry.key;
            final heightFactor = entry.value;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    key: ValueKey('expense-chart-bar-$index'),
                    height: ExpenseChart._maxBarHeight * heightFactor,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7D2AE8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}

class _EmptyChartMessage extends StatelessWidget {
  const _EmptyChartMessage();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: ExpenseChart._chartHeight,
      child: Center(
        child: Text(
          'Nenhuma movimentação no período.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
