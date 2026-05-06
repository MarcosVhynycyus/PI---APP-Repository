import 'api_client.dart';
import 'auth_store.dart';
import '../models/account_plan_model.dart';

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

  Future<List<AccountPlanModel>> getUserAccountPlans() async {
    try {
      final token = await _getTokenOrThrow();

      final response = await api.get(
        '/user-account-plans',
        token: token,
      );

      final data = response['data'];

      if (data is List<dynamic>) {
        return data.map((item) {
          if (item is Map<String, dynamic>) {
            return AccountPlanModel.fromJson(item);
          }

          if (item is Map) {
            return AccountPlanModel.fromJson(Map<String, dynamic>.from(item));
          }

          throw AccountPlansException('Resposta invalida da API.');
        }).toList();
      }

      throw AccountPlansException('Resposta invalida da API.');
    } on ApiException catch (e) {
      throw AccountPlansException(e.message);
    } on AccountPlansException {
      rethrow;
    } on FormatException {
      throw AccountPlansException('Resposta invalida da API.');
    } catch (_) {
      throw AccountPlansException('Connection error with API.');
    }
  }

  Future<List<AccountPlanModel>> getAccountPlans() async {
    // Endpoint geral /account-plans nao deve ser usado no app para leitura.
    return getUserAccountPlans();
  }

  Future<void> createAccountPlan(Map<String, dynamic> body) async {
    try {
      final token = await _getTokenOrThrow();
      final payload = _buildAccountPlanPayload(body);

      await api.post(
        '/account-plans',
        body: payload,
        token: token,
      );
    } on ApiException catch (e) {
      throw AccountPlansException(e.message);
    } on AccountPlansException {
      rethrow;
    } catch (_) {
      throw AccountPlansException('Connection error with API.');
    }
  }

  Future<void> updateAccountPlan(int id, Map<String, dynamic> body) async {
    try {
      final token = await _getTokenOrThrow();
      final payload = _buildAccountPlanPayload(body);

      await api.put(
        '/account-plans/$id',
        body: payload,
        token: token,
      );
    } on ApiException catch (e) {
      throw AccountPlansException(e.message);
    } on AccountPlansException {
      rethrow;
    } catch (_) {
      throw AccountPlansException('Connection error with API.');
    }
  }

  Future<void> deleteAccountPlan(int id) async {
    try {
      final token = await _getTokenOrThrow();

      await api.delete(
        '/account-plans/$id',
        token: token,
      );
    } on ApiException catch (e) {
      throw AccountPlansException(e.message);
    } on AccountPlansException {
      rethrow;
    } catch (_) {
      throw AccountPlansException('Connection error with API.');
    }
  }

  Map<String, dynamic> _buildAccountPlanPayload(Map<String, dynamic> body) {
    final description = (body['description'] ?? '').toString().trim();

    if (description.isEmpty) {
      throw AccountPlansException('Descricao do plano de conta e obrigatoria.');
    }

    return {'description': description};
  }
}
