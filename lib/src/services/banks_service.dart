import 'api_client.dart';
import 'auth_store.dart';

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

  Future<List<dynamic>> getBanks() async {
    try {
      final token = await _getTokenOrThrow();

      final response = await api.get('/user-accounts', token: token);

      final data = response['data'];

      if (data is List<dynamic>) {
        return data;
      }
      throw BanksException('Resposta inválida da API');
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

      await api.post(
        '/accounts',
        body: body,
        token: token,
      );
    } on ApiException catch (e) {
      throw BanksException(e.message);
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

      await api.put(
        '/accounts/$id',
        body: body,
        token: token,
      );
    } on ApiException catch (e) {
      throw BanksException(e.message);
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
    } on ApiException catch (e) {
      throw BanksException(e.message);
    } catch (_) {
      throw BanksException('Connection error with API.');
    }
  }
}
