import 'package:flutter/material.dart';

class AiAdviceCard extends StatelessWidget {
  final String? advice;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const AiAdviceCard({
    super.key,
    this.advice,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
  });

  bool get _hasAdvice => advice?.trim().isNotEmpty ?? false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return const _AiAdviceStatus(
        key: ValueKey('loading-ai-advice'),
        icon: Icons.auto_awesome,
        title: 'Gerando conselho...',
        child: Padding(
          padding: EdgeInsets.only(top: 12),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final error = errorMessage?.trim();
    if (error != null && error.isNotEmpty) {
      return _AiAdviceStatus(
        key: const ValueKey('error-ai-advice'),
        icon: Icons.error_outline,
        iconColor: const Color(0xFFB00020),
        title: 'Nao foi possivel gerar o conselho.',
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ],
        ),
      );
    }

    if (_hasAdvice) {
      return Column(
        key: const ValueKey('filled-ai-advice'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF5B1FA6).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.psychology_alt_outlined,
                  color: Color(0xFF5B1FA6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Conselho financeiro',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SelectableText(
            advice!.trim(),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.45,
                  color: const Color(0xFF1E1E1E),
                ),
          ),
        ],
      );
    }

    return const _AiAdviceStatus(
      key: ValueKey('empty-ai-advice'),
      icon: Icons.psychology_alt_outlined,
      title: 'Nenhum conselho gerado ainda.',
    );
  }
}

class _AiAdviceStatus extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final Widget? child;

  const _AiAdviceStatus({
    super.key,
    required this.icon,
    required this.title,
    this.iconColor = const Color(0xFF5B1FA6),
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 30,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        if (child != null) child!,
      ],
    );
  }
}
