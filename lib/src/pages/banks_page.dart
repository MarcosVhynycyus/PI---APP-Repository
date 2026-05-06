import 'package:finansme_flutter/src/services/banks_service.dart';
import 'package:flutter/material.dart';
import '../widgets/page_header.dart';
import '../widgets/bank_account_card.dart';

class BanksPage extends StatefulWidget {
  const BanksPage({super.key});

  @override
  State<BanksPage> createState() => _BanksPageState();
}

class _BanksPageState extends State<BanksPage> {
  final _service = BanksService();
  
  List<BankAccountData> _banks = [];
  bool _isLoading = true;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _loadBanks();
  }

  Future<void> _loadBanks() async {
    try{
      final result = await _service.getBanks();

      final banks = result.map<BankAccountData>((item) {
        return BankAccountData(
          name: item['description'] ?? 'Sem nome',
          account: 'Conta: ${item['idaccount']}',
          agency: 'Agência: ---',
          balance: 'R\$ ${item['balance'] ?? 0}',
          color: _getColor(item['id_account']),
        );
      }).toList();

      if (!mounted) return;
      
      setState(() {
        _banks = banks;
        _isLoading = false;
      });
    } on BanksException catch(e) {
      if(!mounted) return;

      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (_) {
      if(!mounted) return;

      setState(() {
        _error = 'Erro ao carregar contas.';
        _isLoading = false;
      });
    }
  }

  Color _getColor(dynamic id) {
    final colors = [
      const Color(0xFFF2C300),
      const Color(0xFF5C4DB1),
      const Color(0xFF53B6F0),
      const Color(0xFF00C853),
      const Color(0xFFD50000),
    ];

    if (id is int){
      return colors[id % colors.length];
    }

    return colors[0];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const PageHeader(title: "Bancos", showLogo: true,),

          Expanded(child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    if (_banks.isEmpty) {
      return const Center(child: Text('Nenhuma conta encontrada.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _banks.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: BankAccountCard(data: _banks[index]),
      )
    );
  }
}
