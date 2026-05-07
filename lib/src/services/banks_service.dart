import 'api_client.dart';
import 'auth_store.dart';
import 'balance_refresh_notifier.dart';
import '../models/account_model.dart';

class BanksException implements Exception {
  final String message;

  BanksException(this.message);

  @override
  String toString() => message;
}

class BanksService {
  final ApiClient api;

  BanksService({ApiClient? api}) : api = api ?? ApiClient();

  Future<String> _getTokenOrThrow() async {
    final token = await AuthStore.getToken();

    if (token == null || token.isEmpty) {
      throw BanksException(
        'Sessao expirada. Faca login novamente.',
      );
    }

    return token;
  }

  //==========
  // GET BANK
  //==========

  Future<List<AccountModel>> getUserAccounts() async {
    try {
      final token = await _getTokenOrThrow();

      final response = await api.get('/user-accounts', token: token);

      final data = response['data'];

      if (data is List<dynamic>) {
        return data.map((item) {
          if (item is Map<String, dynamic>) {
            return AccountModel.fromJson(item);
          }

          if (item is Map) {
            return AccountModel.fromJson(Map<String, dynamic>.from(item));
          }

          throw BanksException('Resposta invalida da API.');
        }).toList();
      }
      throw BanksException('Resposta invalida da API.');
    } on ApiException catch (e) {
      throw BanksException(e.message);
    } on BanksException {
      rethrow;
    } on FormatException {
      throw BanksException('Resposta invalida da API.');
    } catch (_) {
      throw BanksException('Connection error with API.');
    }
  }

  Future<List<AccountModel>> getBanks() async {
    return getUserAccounts();
  }

  Future<double> getUserBalance() async {
    try {
      final token = await _getTokenOrThrow();
      final response = await api.get('/user-balance', token: token);
      final rawBalance = response['balance'];

      if (rawBalance is num) {
        return rawBalance.toDouble();
      }

      if (rawBalance is String) {
        final parsed = double.tryParse(rawBalance.replaceAll(',', '.'));
        if (parsed != null) {
          return parsed;
        }
      }

      throw BanksException('Resposta invalida da API.');
    } on ApiException catch (e) {
      throw BanksException(e.message);
    } on BanksException {
      rethrow;
    } catch (_) {
      throw BanksException('Connection error with API.');
    }
  }

  //===========
  // POST BANK
  //===========

  Future<void> createBank(Map<String, dynamic> body) async {
    try {
      final token = await _getTokenOrThrow();
      final payload = _buildAccountPayload(body);

      await api.post(
        '/accounts',
        body: payload,
        token: token,
      );

      BalanceRefreshNotifier.notifyChanged();
    } on ApiException catch (e) {
      throw BanksException(e.message);
    } on BanksException {
      rethrow;
    } catch (_) {
      throw BanksException('Connection error with API.');
    }
  }

  //=============
  // UPDATE BANK
  //=============

  Future<void> updateBank(int id, Map<String, dynamic> body) async {
    try {
      final token = await _getTokenOrThrow();
      final payload = _buildAccountPayload(body);

      await api.put(
        '/accounts/$id',
        body: payload,
        token: token,
      );

      BalanceRefreshNotifier.notifyChanged();
    } on ApiException catch (e) {
      throw BanksException(e.message);
    } on BanksException {
      rethrow;
    } catch (_) {
      throw BanksException('Connection error with API.');
    }
  }

  //=============
  // DELETE BANK
  //=============

  Future<void> deleteBank(int id) async {
    try {
      final token = await _getTokenOrThrow();

      await api.delete(
        '/accounts/$id',
        token: token,
      );

      BalanceRefreshNotifier.notifyChanged();
    } on ApiException catch (e) {
      throw BanksException(e.message);
    } on BanksException {
      rethrow;
    } catch (_) {
      throw BanksException('Connection error with API.');
    }
  }

  Map<String, dynamic> _buildAccountPayload(
    Map<String, dynamic> body,
  ) {
    final description = (body['description'] ?? '').toString().trim();
    final balance = _parseBalance(body['balance']);

    if (description.isEmpty) {
      throw BanksException('Descricao da conta e obrigatoria.');
    }

    if (balance == null || balance < 0) {
      throw BanksException('Saldo invalido.');
    }

    return {
      'description': description,
      'balance': balance,
    };
  }

  double? _parseBalance(dynamic value) {
    if (value is num) return value.toDouble();

    final parsed = double.tryParse(
      value?.toString().trim().replaceAll(',', '.') ?? '',
    );
    return parsed;
  }
}
