import 'api_client.dart';
import 'auth_store.dart';

class AccountPlansException implements Exception {
  final String message;

  AccountPlansException(this.message);

  @override
  String toString() => message;
}

class AccountPlansService {
  final ApiClient api;

  AccountPlansService({ApiClient? api}) : api = api ?? ApiClient();

  Future<String> _getTokenOrThrow() async {
    final token = await AuthStore.getToken();

    if (token == null || token.isEmpty) {
      throw AccountPlansException(
        'Sessao expirada. Faca login novamente.',
      );
    }

    return token;
  }

  Future<List<dynamic>> getUserAccountPlans() async {
    try {
      final token = await _getTokenOrThrow();

      final response = await api.get(
        '/user-account-plans',
        token: token,
      );

      final data = response['data'];

      if (data is List<dynamic>) {
        return data;
      }

      throw AccountPlansException('Resposta invalida da API.');
    } on ApiException catch (e) {
      throw AccountPlansException(e.message);
    } on AccountPlansException {
      rethrow;
    } catch (_) {
      throw AccountPlansException('Connection error with API.');
    }
  }

  Future<List<dynamic>> getAccountPlans() async {
    return getUserAccountPlans();
  }
}
