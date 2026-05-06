import 'api_client.dart';
import 'auth_store.dart';

class TransactorsException implements Exception {
  final String message;

  TransactorsException(this.message);

  @override
  String toString() => message;
}

class TransactorsService {
  final ApiClient api;

  TransactorsService({ApiClient? api}) : api = api ?? ApiClient();

  Future<String> _getTokenOrThrow() async {
    final token = await AuthStore.getToken();

    if (token == null || token.isEmpty) {
      throw TransactorsException(
        'Sessao expirada. Faca login novamente.',
      );
    }

    return token;
  }

  Future<List<dynamic>> getTransactors() async {
    try {
      final token = await _getTokenOrThrow();
      final response = await api.get(
        '/transactors',
        token: token,
      );

      final data = response['data'];

      if (data is List<dynamic>) {
        return data;
      }

      throw TransactorsException('Resposta invalida da API.');
    } on ApiException catch (e) {
      throw TransactorsException(e.message);
    } on TransactorsException {
      rethrow;
    } catch (_) {
      throw TransactorsException(
        'Connection error with API.',
      );
    }
  }

  Future<List<dynamic>> getUserTransactors() async {
    try {
      final token = await _getTokenOrThrow();
      final response = await api.get(
        '/user-transactors',
        token: token,
      );

      final data = response['data'];

      if (data is List<dynamic>) {
        return data;
      }

      throw TransactorsException(
        'Resposta invalida da API.',
      );
    } on ApiException catch (e) {
      throw TransactorsException(e.message);
    } on TransactorsException {
      rethrow;
    } catch (_) {
      throw TransactorsException(
        'Connection error with API',
      );
    }
  }

  Future<void> createTransactor(
    Map<String, dynamic> body,
  ) async {
    try {
      final token = await _getTokenOrThrow();
      await api.post(
        '/transactors',
        body: body,
        token: token,
      );
    } on ApiException catch (e) {
      throw TransactorsException(e.message);
    } on TransactorsException {
      rethrow;
    } catch (_) {
      throw TransactorsException(
        'Connection error with API.',
      );
    }
  }

  Future<void> updateTransactor(
    int id,
    Map<String, dynamic> body,
  ) async {
    try {
      final token = await _getTokenOrThrow();
      await api.put(
        '/transactors/$id',
        body: body,
        token: token,
      );
    } on ApiException catch (e) {
      throw TransactorsException(e.message);
    } catch (_) {
      throw TransactorsException(
        'Connection error with API.',
      );
    }
  }

  Future<void> deleteTransactor(
    int id,
  ) async {
    try {
      final token = await _getTokenOrThrow();
      await api.delete(
        '/transactors/$id',
        token: token,
      );
    } on ApiException catch (e) {
      throw TransactorsException(e.message);
    } catch (_) {
      throw TransactorsException(
        'Connection error with API.',
      );
    }
  }
}
