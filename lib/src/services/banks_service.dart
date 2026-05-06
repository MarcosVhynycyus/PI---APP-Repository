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

  //==========
  // GET BANK
  //==========

  Future<List<dynamic>> getBanks() async {
    try {
      final token = await AuthStore.getToken();

      final response = await api.get(
        '/user-accounts',
        token: token
      );

      final data = response['data'];

      if (data is List<dynamic>) {
        return data;
      }
      throw BanksException('Resposta inválida da API'); 
    } on ApiException catch (e) {
      throw BanksException(e.message);
    } catch (_) {
      throw BanksException('Connection error with API.');
    }
  }

  //===========
  // POST BANK
  //===========

  Future<void> createBank(Map<String, dynamic> body) async {
    try {
      final token = await AuthStore.getToken();

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
      final token = await AuthStore.getToken();

      await api.put(
        'accounts/$id',
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
      final token = await AuthStore.getToken();

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