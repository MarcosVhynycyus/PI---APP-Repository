import 'package:flutter/material.dart';

import '../models/ai_response_model.dart';
import '../services/ai_advisor_service.dart';
import '../services/auth_store.dart';
import '../widgets/ai_advice_card.dart';
import '../widgets/page_header.dart';

class AiAdvisorPage extends StatefulWidget {
  const AiAdvisorPage({
    super.key,
    this.onLogoTap,
    this.userInitial,
  });

  final VoidCallback? onLogoTap;
  final String? userInitial;

  @override
  State<AiAdvisorPage> createState() => _AiAdvisorPageState();
}

class _AiAdvisorPageState extends State<AiAdvisorPage> {
  final _service = AiAdvisorService();

  AiResponseModel? _response;
  bool _isLoading = false;
  String? _error;
  String? _loadedUserInitial;

  String? get _headerUserInitial {
    final widgetInitial = widget.userInitial?.trim();

    if (widgetInitial != null && widgetInitial.isNotEmpty) {
      return widgetInitial;
    }

    return _loadedUserInitial;
  }

  @override
  void initState() {
    super.initState();
    _loadUserInitial();
  }

  Future<void> _loadUserInitial() async {
    if (widget.userInitial?.trim().isNotEmpty ?? false) {
      return;
    }

    try {
      final profile = await AuthStore.getUserProfile();

      if (!mounted) return;

      setState(() {
        _loadedUserInitial = profile.initial;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loadedUserInitial = null;
      });
    }
  }

  void _goToMain() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/main',
      (route) => false,
    );
  }

  Future<void> _requestAiResponse() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _service.getAiResponse();

      if (!mounted) return;

      setState(() {
        _response = response;
        _error = null;
        _isLoading = false;
      });
    } on AiAdvisorException catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = 'Nao foi possivel gerar o conselho.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          PageHeader(
            title: 'Concelheiro de IA',
            showLogo: true,
            showBackButton: true,
            customIcon: Icons.auto_awesome,
            onLogoTap: widget.onLogoTap ?? _goToMain,
            userInitial: _headerUserInitial,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildActionCard(context),
                const SizedBox(height: 16),
                AiAdviceCard(
                  advice: _response?.advice,
                  isLoading: _isLoading,
                  errorMessage: _error,
                  onRetry: _isLoading ? null : _requestAiResponse,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF5B1FA6).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF5B1FA6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Conselho financeiro por IA',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isLoading ? null : _requestAiResponse,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.bolt_outlined),
              label: Text(_isLoading ? 'Gerando...' : 'Gerar conselho'),
            ),
          ),
        ],
      ),
    );
  }
}
