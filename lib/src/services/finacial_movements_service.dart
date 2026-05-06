import 'api_client.dart';
import 'auth_store.dart';
import 'balance_refresh_notifier.dart';

class FinancialMovementsException implements Exception {
  final String message;
  FinancialMovementsException(this.message);

  @override
  String toString() => message;
}

class FinancialMovementsService {
  final ApiClient api;

  FinancialMovementsService({ApiClient? api}) : api = api ?? ApiClient();

  Future<String> _getTokenOrThrow() async {
    final token = await AuthStore.getToken();

    if (token == null || token.isEmpty) {
      throw FinancialMovementsException(
        'Sessao expirada. Faca login novamente.',
      );
    }

    return token;
  }

  Future<List<dynamic>> getFinancialMovements() async {
    try {
      final token = await _getTokenOrThrow();
      final response = await api.get(
        '/financial-movements',
        token: token,
      );

      final data = response['data'];
      if (data is List<dynamic>) {
        return data;
      }

      throw FinancialMovementsException(
        'Resposta invalida da API.',
      );
    } on ApiException catch (e) {
      throw FinancialMovementsException(e.message);
    } on FinancialMovementsException {
      rethrow;
    } catch (_) {
      throw FinancialMovementsException(
        'Connection error with API.',
      );
    }
  }

  Future<List<dynamic>> getUserFinancialMovements() async {
    try {
      final token = await _getTokenOrThrow();
      final response = await api.get(
        '/user-financial-movements',
        token: token,
      );

      final data = response['data'];
      if (data is List<dynamic>) {
        return data;
      }

      throw FinancialMovementsException(
        'Resposta invalida da API.',
      );
    } on ApiException catch (e) {
      throw FinancialMovementsException(e.message);
    } on FinancialMovementsException {
      rethrow;
    } catch (_) {
      throw FinancialMovementsException(
        'Connection error with API.',
      );
    }
  }

  Future<void> createFinancialMovement(
    Map<String, dynamic> body,
  ) async {
    try {
      final token = await _getTokenOrThrow();

      final requiredFields = [
        'type_movement_id',
        'movement_date',
        'due_date',
        'payment_date',
        'doc_num',
        'transator_id',
        'value',
        'payment_method_id',
        'situation_id',
        'account_id',
        'account_plan_id',
        'reason',
      ];

      for (final field in requiredFields) {
        if (!body.containsKey(field)) {
          throw FinancialMovementsException(
            'Missing required field: $field',
          );
        }
      }

      await api.post(
        '/financial-movements',
        body: body,
        token: token,
      );

      BalanceRefreshNotifier.notifyChanged();
    } on ApiException catch (e) {
      throw FinancialMovementsException(e.message);
    } on FinancialMovementsException {
      rethrow;
    } catch (_) {
      throw FinancialMovementsException(
        'Connection error with API.',
      );
    }
  }

  Future<void> updateFinancialMovement(
    int id,
    Map<String, dynamic> body,
  ) async {
    try {
      final token = await _getTokenOrThrow();

      await api.put(
        '/financial-movements/$id',
        body: body,
        token: token,
      );

      BalanceRefreshNotifier.notifyChanged();
    } on ApiException catch (e) {
      throw FinancialMovementsException(e.message);
    } catch (_) {
      throw FinancialMovementsException(
        'Connection error with API.',
      );
    }
  }

  Future<void> deleteFinancialMovement(int id) async {
    try {
      final token = await _getTokenOrThrow();
      await api.delete(
        '/financial-movements/$id',
        token: token,
      );

      BalanceRefreshNotifier.notifyChanged();
    } on ApiException catch (e) {
      throw FinancialMovementsException(e.message);
    } catch (_) {
      throw FinancialMovementsException(
        'Connection error with API.',
      );
    }
  }
}
